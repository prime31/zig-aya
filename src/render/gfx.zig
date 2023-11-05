const std = @import("std");
const sdl = @import("sdl");
const renderkit = @import("renderkit");
const aya = @import("../aya.zig");

pub const ResolutionPolicy = @import("resolution_policy.zig").ResolutionPolicy;
pub const ResolutionScaler = @import("resolution_policy.zig").ResolutionScaler;
pub const PostProcessStack = @import("post_process_stack.zig").PostProcessStack;
pub const PostProcessor = @import("post_process_stack.zig").PostProcessor;

// high level wrapper objects that use the low-level backend api
pub const OffscreenPass = @import("offscreen_pass.zig").OffscreenPass;
pub const Shader = @import("shader.zig").Shader;
pub const ShaderState = @import("shader.zig").ShaderState;

const DefaultOffscreenPass = @import("offscreen_pass.zig").DefaultOffscreenPass;
const Draw = @import("draw.zig").Draw;

const Batcher = aya.Batcher;
const FontBook = aya.FontBook;
const Texture = aya.Texture;

const Vec2 = aya.Vec2;
const Mat32 = aya.Mat32;
const Color = aya.Color;
const Quad = aya.Quad;
const Size = aya.Size;

pub const Vertex = extern struct {
    pos: Vec2 = .{ .x = 0, .y = 0 },
    uv: Vec2 = .{ .x = 0, .y = 0 },
    col: u32 = 0xFFFFFFFF,
};

pub const Config = struct {
    disable_debug_render: bool = false, // when true, debug rendering will be disabled
    design_width: i32 = 0, // the width of the main offscreen render texture when the policy is not .default
    design_height: i32 = 0, // the height of the main offscreen render texture when the policy is not .default
    resolution_policy: ResolutionPolicy = .default, // defines how the main render texture should be blitted to the backbuffer
    texture_filter: renderkit.TextureFilter = .nearest,
};

pub const PassConfig = struct {
    pub const ColorAttachmentAction = extern struct {
        clear: bool = true,
        color: Color = Color.aya,
    };

    clear_color: bool = true,
    color: Color = Color.aya,
    mrt_colors: [3]ColorAttachmentAction = [_]ColorAttachmentAction{.{}} ** 3,
    clear_stencil: bool = false,
    stencil: u8 = 0,
    clear_depth: bool = false,
    depth: f64 = 1,

    trans_mat: ?Mat32 = null,
    shader: ?*Shader = null,
    pass: ?OffscreenPass = null,

    pub fn asClearCommand(self: PassConfig) renderkit.ClearCommand {
        var cmd = renderkit.ClearCommand{};
        cmd.colors[0].clear = self.clear_color;
        cmd.colors[0].color = self.color.asArray();

        for (self.mrt_colors, 0..) |mrt_color, i| {
            cmd.colors[i + 1] = .{
                .clear = mrt_color.clear,
                .color = mrt_color.color.asArray(),
            };
        }

        cmd.clear_stencil = self.clear_stencil;
        cmd.stencil = self.stencil;
        cmd.clear_depth = self.clear_depth;
        cmd.depth = self.depth;
        return cmd;
    }
};

pub const GraphicsContext = struct {
    shader: Shader = undefined,
    transform_mat: Mat32 = Mat32.identity,
    default_pass: DefaultOffscreenPass,
    blitted_to_screen: bool = false,
    debug_render_enabled: bool = false,
    draw: Draw,

    pub fn init() GraphicsContext {
        const config = Config{}; // TODO: expose this maybe in RenderPlugin?

        const window_pixel_size = aya.window.sizeInPixels();

        // if we were passed 0's for design size default to the window/backbuffer size
        var design_w = config.design_width;
        var design_h = config.design_height;
        if (design_w == 0 or design_h == 0) {
            design_w = window_pixel_size.w;
            design_h = window_pixel_size.h;
        }

        return .{
            .shader = Shader.initDefaultSpriteShader() catch unreachable,
            .debug_render_enabled = !config.disable_debug_render,
            .default_pass = DefaultOffscreenPass.init(design_w, design_h, config.texture_filter, config.resolution_policy),
            .draw = Draw.init(),
        };
    }

    pub fn deinit(self: *GraphicsContext) void {
        self.shader.deinit();
        self.default_pass.deinit();
        self.draw.deinit();
    }

    pub fn setWindowPixelSize(self: *GraphicsContext, size: Size) void {
        self.default_pass.onWindowResizedCallback(size);
    }

    pub fn setShader(self: *GraphicsContext, shader: ?*Shader) void {
        const new_shader = shader orelse &self.shader;

        self.draw.batcher.flush();
        new_shader.bind();
        new_shader.setTransformMatrix(&self.transform_mat);
    }

    pub fn beginFrame(self: *GraphicsContext) void {
        self.draw.batcher.begin();
    }

    pub fn setRenderState(self: *GraphicsContext, rk_state: renderkit.RenderState) void {
        self.draw.batcher.flush();
        renderkit.setRenderState(rk_state);
    }

    /// calling this instead of beginPass skips all rendering to the faux backbuffer including blitting it to screen. The default shader
    /// will not be set and no render texture will be set. This is useful when making a full ImGui application. Call this at the
    /// beginning of render then do all your normal rendering passes. This is the only pass that does not require an endPass call.
    /// Note that you will need to do a pass to clear the screen!
    pub fn beginNullPass(self: *GraphicsContext) void {
        self.blitted_to_screen = true;
    }

    // OffscreenPasses should be rendered first. If no pass is in the PassConfig rendering will be done to the
    // DefaultOffscreenPass. After all passes are run you can optionally call postProcess and then blitToScreen.
    // If another pass is run after blitToScreen rendering will be to the backbuffer.
    pub fn beginPass(self: *GraphicsContext, config: PassConfig) void {
        var proj_mat: Mat32 = Mat32.init();
        var clear_command = config.asClearCommand();

        if (self.blitted_to_screen) {
            const size = aya.window.sizeInPixels();
            renderkit.beginDefaultPass(clear_command, size.w, size.h);
            proj_mat = Mat32.initOrtho(@as(f32, @floatFromInt(size.w)), @as(f32, @floatFromInt(size.h)));
        } else {
            const pass = config.pass orelse self.default_pass.pass;
            renderkit.beginPass(pass.pass, clear_command);
            // inverted for OpenGL offscreen passes
            proj_mat = Mat32.initOrthoInverted(pass.color_texture.width, pass.color_texture.height);
        }

        // if we were given a transform matrix multiply it here
        if (config.trans_mat) |trans_mat| {
            proj_mat = proj_mat.mul(trans_mat);
        }

        self.transform_mat = proj_mat;

        // if we were given a Shader use it else set the default Pipeline
        self.setShader(config.shader);
    }

    pub fn endPass(self: *GraphicsContext) void {
        // setting the shader will flush the batch
        self.setShader(null);
        if (aya.debug.render(&self.draw, self.debug_render_enabled))
            self.flush();
        renderkit.endPass();
    }

    pub fn flush(self: *GraphicsContext) void {
        self.draw.batcher.flush();
    }

    pub fn postProcess(self: *GraphicsContext, stack: *PostProcessStack) void {
        self.transform_mat = Mat32.initOrtho(self.default_pass.pass.color_texture.width, self.default_pass.pass.color_texture.height);
        stack.process(self.default_pass.pass);
    }

    /// renders the default OffscreenPass to the backbuffer using the ResolutionScaler
    pub fn blitToScreen(self: *GraphicsContext, letterbox_color: Color) void {
        if (self.blitted_to_screen) return;
        self.blitted_to_screen = true;

        self.beginPass(.{ .color = letterbox_color });
        const scaler = self.default_pass.scaler;
        self.draw.texScale(self.default_pass.pass.color_texture, @as(f32, @floatFromInt(scaler.x)), @as(f32, @floatFromInt(scaler.y)), scaler.scale);
        self.endPass();
    }

    /// if we havent yet blitted to the screen do so now
    pub fn commitFrame(self: *GraphicsContext) void {
        if (!self.blitted_to_screen) self.blitToScreen(Color.black);

        self.draw.batcher.end();
        self.blitted_to_screen = false;
        renderkit.commitFrame();
    }
};
