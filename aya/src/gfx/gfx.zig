const std = @import("std");
const aya = @import("../../aya.zig");
const renderkit = @import("renderkit");
const math = aya.math;

pub const ResolutionPolicy = @import("resolution_policy.zig").ResolutionPolicy;
pub const ResolutionScaler = @import("resolution_policy.zig").ResolutionScaler;
pub const PostProcessStack = @import("post_process_stack.zig").PostProcessStack;

// high level wrapper objects that use the low-level backend api
pub const Texture = @import("texture.zig").Texture;
pub const OffscreenPass = @import("offscreen_pass.zig").OffscreenPass;
pub const Shader = @import("shader.zig").Shader;

// even higher level wrappers for 2D game dev
pub const Mesh = @import("mesh.zig").Mesh;
pub const DynamicMesh = @import("mesh.zig").DynamicMesh;

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
    batcher_max_sprites: usize = 1000, // defines the size of the vertex/index buffers based on the number of sprites/quads
    texture_filter: renderkit.TextureFilter = .nearest,
};

pub const PassConfig = struct {
    color_action: renderkit.ClearAction = .clear,
    color: math.Color = math.Color.aya,
    stencil_action: renderkit.ClearAction = .dont_care,
    stencil: u8 = 0,
    depth_action: renderkit.ClearAction = .dont_care,
    depth: f64 = 0,

    trans_mat: ?math.Mat32 = null,
    shader: ?Shader = null,
    pass: ?OffscreenPass = null,

    pub fn asClearCommand(self: PassConfig) renderkit.ClearCommand {
        return .{
            .color = self.color.asArray(),
            .color_action = self.color_action,
            .stencil_action = self.stencil_action,
            .stencil = self.stencil,
            .depth_action = self.depth_action,
            .depth = self.depth,
        };
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

    state.shader = Shader.init(@embedFile("assets/default.vs"), @embedFile("assets/default.fs")) catch unreachable;
    state.shader.bind();
    state.shader.setUniformName(i32, "MainTex", 0);

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

pub fn setShader(shader: ?Shader) void {
    const new_shader = shader orelse state.shader;

    draw.batcher.flush();
    new_shader.bind();
    new_shader.setUniformName(math.Mat32, "TransformMatrix", state.transform_mat);
}

/// calling this instead of beginPass skips all rendering to the faux backbuffer including blitting it to screen. The default pipeline
/// will not be set and no render texture will be set. This is useful when making a full ImGui application.
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
        renderkit.renderer.beginDefaultPass(clear_command, size.w, size.h);
        proj_mat = math.Mat32.initOrtho(@intToFloat(f32, size.w), @intToFloat(f32, size.h));
    } else {
        const pass = config.pass orelse state.default_pass.pass;
        renderkit.renderer.beginPass(pass.pass, clear_command);
        // inverted for OpenGL offscreen passes
        if (renderkit.current_renderer == .opengl) {
            proj_mat = math.Mat32.initOrthoInverted(pass.color_texture.width, pass.color_texture.height);
        } else {
            proj_mat = math.Mat32.initOrtho(pass.color_texture.width, pass.color_texture.height);
        }
    }

    // if (config.pass) |pass| {
    //     renderkit.renderer.beginPass(pass.pass, clear_command);
    //     // inverted for OpenGL offscreen passes
    //     if (renderkit.current_renderer == .opengl) {
    //         proj_mat = math.Mat32.initOrthoInverted(pass.color_texture.width, pass.color_texture.height);
    //     } else {
    //         proj_mat = math.Mat32.initOrtho(pass.color_texture.width, pass.color_texture.height);
    //     }
    // } else {
    //     const size = aya.window.drawableSize();
    //     renderkit.renderer.beginDefaultPass(clear_command, size.w, size.h);
    //     proj_mat = math.Mat32.initOrtho(@intToFloat(f32, size.w), @intToFloat(f32, size.h));
    // }

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
    renderkit.renderer.endPass();
}

pub fn flush() void {
    draw.batcher.flush();
}

pub fn postProcess(stack: *PostProcessStack) void {
    state.transform_mat = math.Mat32.initOrtho(state.default_pass.pass.color_texture.width, state.default_pass.pass.color_texture.height);
    stack.process(state.default_pass.pass);
}

/// renders the default OffscreenPass to the backbuffer using the ResolutionScaler
pub fn blitToScreen(letterbox_color: math.Color) void {
    if (state.blitted_to_screen) return;
    state.blitted_to_screen = true;

    // TODO: Hack until we get window resized events
    state.default_pass.onWindowResizedCallback();

    beginPass(.{ .color = letterbox_color });
    const scaler = state.default_pass.scaler;
    draw.texScale(state.default_pass.pass.color_texture, @intToFloat(f32, scaler.x), @intToFloat(f32, scaler.y), scaler.scale);
    endPass();
}

/// if we havent yet blitted to the screen do so now
pub fn commitFrame() void {
    if (!state.blitted_to_screen) {
        blitToScreen(math.Color.black);
    }

    draw.batcher.end();
    state.blitted_to_screen = false;
    renderkit.renderer.commitFrame();
}

// import all the drawing methods
usingnamespace @import("draw.zig");
