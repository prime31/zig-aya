const std = @import("std");
const aya = @import("../../aya.zig");
const renderkit = @import("renderkit");
const math = aya.math;

// import all the drawing methods
pub const draw = @import("draw.zig").draw;

pub const ResolutionPolicy = @import("resolution_policy.zig").ResolutionPolicy;
pub const ResolutionScaler = @import("resolution_policy.zig").ResolutionScaler;
pub const PostProcessStack = @import("post_process_stack.zig").PostProcessStack;
pub const PostProcessor = @import("post_process_stack.zig").PostProcessor;

// high level wrapper objects that use the low-level backend api
pub const Texture = @import("texture.zig").Texture;
pub const OffscreenPass = @import("offscreen_pass.zig").OffscreenPass;
pub const Shader = @import("shader.zig").Shader;
pub const ShaderState = @import("shader.zig").ShaderState;

// even higher level wrappers for 2D game dev
pub const Mesh = @import("mesh.zig").Mesh;
pub const DynamicMesh = @import("mesh.zig").DynamicMesh;
pub const InstancedMesh = @import("mesh.zig").InstancedMesh;

pub const Batcher = @import("batcher.zig").Batcher;
pub const MultiBatcher = @import("multi_batcher.zig").MultiBatcher;
pub const TriangleBatcher = @import("triangle_batcher.zig").TriangleBatcher;

pub const AtlasBatch = @import("atlas_batch.zig").AtlasBatch;
pub const FontBook = @import("fontbook.zig").FontBook;

pub const Vertex = extern struct {
    pos: math.Vec2 = .{ .x = 0, .y = 0 },
    uv: math.Vec2 = .{ .x = 0, .y = 0 },
    col: u32 = 0xFFFFFFFF,
};

pub const Config = struct {
    disable_debug_render: bool = false, // when true, debug rendering will be disabled
    design_width: i32 = 0, // the width of the main offscreen render texture when the policy is not .default
    design_height: i32 = 0, // the height of the main offscreen render texture when the policy is not .default
    resolution_policy: ResolutionPolicy = .default, // defines how the main render texture should be blitted to the backbuffer
    batcher_max_sprites: u16 = 1000, // defines the size of the vertex/index buffers based on the number of sprites/quads
    texture_filter: renderkit.TextureFilter = .nearest,
};

pub const PassConfig = struct {
    pub const ColorAttachmentAction = extern struct {
        clear: bool = true,
        color: math.Color = math.Color.aya,
    };

    clear_color: bool = true,
    color: math.Color = math.Color.aya,
    mrt_colors: [3]ColorAttachmentAction = [_]ColorAttachmentAction{.{}} ** 3,
    clear_stencil: bool = false,
    stencil: u8 = 0,
    clear_depth: bool = false,
    depth: f64 = 1,

    trans_mat: ?math.Mat32 = null,
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

pub var state = struct {
    shader: Shader = undefined,
    transform_mat: math.Mat32 = math.Mat32.identity,
    default_pass: DefaultOffscreenPass = undefined,
    blitted_to_screen: bool = false,
    debug_render_enabled: bool = false,
}{};

// locals
const DefaultOffscreenPass = @import("offscreen_pass.zig").DefaultOffscreenPass;

pub fn init(config: Config) void {
    state.debug_render_enabled = !config.disable_debug_render;
    draw.init(config) catch unreachable;

    state.shader = Shader.initDefaultSpriteShader() catch unreachable;

    // if we were passed 0's for design size default to the window/backbuffer size
    var design_w = config.design_width;
    var design_h = config.design_height;
    if (design_w == 0 or design_h == 0) {
        design_w = aya.window.width();
        design_h = aya.window.height();
    }
    state.default_pass = DefaultOffscreenPass.init(design_w, design_h, config.texture_filter, config.resolution_policy);
}

pub fn deinit() void {
    state.shader.deinit();
    state.default_pass.deinit();
    draw.deinit();
}

pub fn getResolutionScaler() ResolutionScaler {
    return state.default_pass.scaler;
}

pub fn getFontBook() *FontBook {
    return draw.fontbook;
}

pub fn createPostProcessStack() PostProcessStack {
    return PostProcessStack.init(null, state.default_pass.design_w, state.default_pass.design_h);
}

pub fn setShader(shader: ?*Shader) void {
    const new_shader = shader orelse &state.shader;

    draw.batcher.flush();
    new_shader.bind();
    new_shader.setTransformMatrix(&state.transform_mat);
}

pub fn beginFrame() void {
    draw.batcher.begin();
}

pub fn setRenderState(rk_state: renderkit.RenderState) void {
    draw.batcher.flush();
    renderkit.setRenderState(rk_state);
}

/// calling this instead of beginPass skips all rendering to the faux backbuffer including blitting it to screen. The default shader
/// will not be set and no render texture will be set. This is useful when making a full ImGui application. Call this at the
/// beginning of render then do all your normal rendering passes. This is the only pass that does not require an endPass call.
/// Note that you will need to do a pass to clear the screen!
pub fn beginNullPass() void {
    state.blitted_to_screen = true;
}

// OffscreenPasses should be rendered first. If no pass is in the PassConfig rendering will be done to the
// DefaultOffscreenPass. After all passes are run you can optionally call postProcess and then blitToScreen.
// If another pass is run after blitToScreen rendering will be to the backbuffer.
pub fn beginPass(config: PassConfig) void {
    var proj_mat: math.Mat32 = math.Mat32.init();
    var clear_command = config.asClearCommand();

    if (state.blitted_to_screen) {
        const size = aya.window.drawableSize();
        renderkit.beginDefaultPass(clear_command, size.w, size.h);
        proj_mat = math.Mat32.initOrtho(@as(f32, @floatFromInt(size.w)), @as(f32, @floatFromInt(size.h)));
    } else {
        const pass = config.pass orelse state.default_pass.pass;
        renderkit.beginPass(pass.pass, clear_command);
        // inverted for OpenGL offscreen passes
        proj_mat = math.Mat32.initOrthoInverted(pass.color_texture.width, pass.color_texture.height);
    }

    // if we were given a transform matrix multiply it here
    if (config.trans_mat) |trans_mat| {
        proj_mat = proj_mat.mul(trans_mat);
    }

    state.transform_mat = proj_mat;

    // if we were given a Shader use it else set the default Pipeline
    setShader(config.shader);
}

pub fn endPass() void {
    // setting the shader will flush the batch
    setShader(null);
    aya.debug.render(state.debug_render_enabled);
    renderkit.endPass();
}

pub fn flush() void {
    draw.batcher.flush();
}

pub fn postProcess(stack: *PostProcessStack) void {
    state.transform_mat = math.Mat32.initOrtho(state.default_pass.pass.color_texture.width, state.default_pass.pass.color_texture.height);
    stack.process(state.default_pass.pass);
}

/// renders the default OffscreenPass to the backbuffer using the ResolutionScaler
pub fn blitToScreen(comptime letterbox_color: math.Color) void {
    if (state.blitted_to_screen) return;
    state.blitted_to_screen = true;

    // TODO: Hack until we get window resized events
    state.default_pass.onWindowResizedCallback();

    beginPass(.{ .color = letterbox_color });
    const scaler = state.default_pass.scaler;
    draw.texScale(state.default_pass.pass.color_texture, @as(f32, @floatFromInt(scaler.x)), @as(f32, @floatFromInt(scaler.y)), scaler.scale);
    endPass();
}

/// if we havent yet blitted to the screen do so now
pub fn commitFrame() void {
    if (!state.blitted_to_screen) blitToScreen(math.Color.black);

    draw.batcher.end();
    state.blitted_to_screen = false;
    renderkit.commitFrame();
}
