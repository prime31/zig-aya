const std = @import("std");
const aya = @import("../../aya.zig");
usingnamespace aya.sokol;

// exports
pub const effects = @import("effects.zig");

pub const ResolutionPolicy = @import("resolution_policy.zig").ResolutionPolicy;
pub const ResolutionScaler = @import("resolution_policy.zig").ResolutionScaler;
pub const Texture = @import("texture.zig").Texture;
pub const OffscreenPass = @import("offscreen_pass.zig").OffscreenPass;

pub const PostProcessStack = @import("post_process_stack.zig").PostProcessStack;
// TODO: move Sepia/Vignette to its own file
pub const Sepia = @import("post_process_stack.zig").Sepia;
pub const Vignette = @import("post_process_stack.zig").Vignette;
pub const PixelGlitch = @import("post_process_stack.zig").PixelGlitch;

pub const Batcher = @import("batcher.zig").Batcher;
pub const TriangleBatcher = @import("triangle_batcher.zig").TriangleBatcher;
pub const AtlasBatch = @import("atlas_batch.zig").AtlasBatch;

pub const Vertex = @import("buffers.zig").Vertex;
pub const Mesh = @import("mesh.zig").Mesh;
pub const DynamicMesh = @import("mesh.zig").DynamicMesh;

pub const Pipeline = @import("pipeline.zig").Pipeline;
pub const VertexBuffer = @import("buffers.zig").VertexBuffer;
pub const IndexBuffer = @import("buffers.zig").IndexBuffer;

pub const FontBook = @import("fontbook.zig").FontBook;

pub const Config = struct {
    disable_debug_render: bool = false, // when true, debug rendering will be disabled
    design_width: i32 = 0, // the width of the main offscreen render texture when the policy is not .default
    design_height: i32 = 0, // the height of the main offscreen render texture when the policy is not .default
    resolution_policy: ResolutionPolicy = .default, // defines how the main render texture should be blitted to the backbuffer
    batcher_max_sprites: usize = 1000, // defines the size of the vertex/index buffers based on the number of sprites/quads
    texture_filter: Texture.Filter = .nearest,
};

// locals
const DefaultOffscreenPass = @import("offscreen_pass.zig").DefaultOffscreenPass;
const math = @import("../math/math.zig");

var state = struct {
    debug_render_enabled: bool = false,
    pass_action: sg_pass_action = undefined,
    default_pipeline: Pipeline = undefined,
    default_pass: DefaultOffscreenPass = undefined,
    blitted_to_screen: bool = false,
    transform_mat: math.Mat32 = undefined,
}{};

pub fn init(config: Config) void {
    draw.init(config) catch unreachable;
    state.debug_render_enabled = !config.disable_debug_render;
    state.default_pipeline = Pipeline.initDefaultPipeline();

    // if we were passed 0's for design size default to the window/backbuffer size
    var design_w = config.design_width;
    var design_h = config.design_height;
    if (design_w == 0 or design_h == 0) {
        design_w = aya.window.width();
        design_h = aya.window.height();
    }
    state.default_pass = DefaultOffscreenPass.init(design_w, design_h, config.resolution_policy, config.texture_filter);
}

pub fn deinit() void {
    state.default_pass.deinit();
    state.default_pipeline.deinit();
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

pub fn defaultPipeline() Pipeline {
    return state.default_pipeline;
}

pub fn setPipeline(pipeline: ?Pipeline) void {
    const pip = pipeline orelse state.default_pipeline;

    draw.batcher.flush();
    sg_apply_pipeline(pip.pip);
    pip.setTransformMatrixUniform(state.transform_mat);
    pip.applyUniforms();
}

// Passes
pub const PassConfig = struct {
    color: math.Color = math.Color.aya,
    color_action: sg_action = .SG_ACTION_CLEAR,
    stencil_action: sg_action = .SG_ACTION_CLEAR,
    stencil: u8 = 0,

    trans_mat: ?math.Mat32 = null,
    pipeline: ?Pipeline = null,
    pass: ?OffscreenPass = null,

    pub fn apply(self: PassConfig, pass_action: *sg_pass_action) void {
        pass_action.colors[0].action = self.color_action;
        pass_action.colors[0].val = self.color.asArray();
        pass_action.stencil.action = self.stencil_action;
        pass_action.stencil.val = self.stencil;
    }
};

/// calling this instead of beginPass skips all rendering to the faux backbuffer including blitting it to screen. The default pipeline
/// will not be set and no render texture will be set. This is useful when making a full ImGui application.
pub fn beginNullPass() void {
    state.blitted_to_screen = true;
}

// OffscreenPasses should be rendered first. If no pass is in the PassConfig rendering will be done to the
// DefaultOffscreenPass. After all passes are run you can optionally call postProcess and then blitToScreen.
// If another pass is run after blitToScreen rendering will be to the backbuffer.
pub fn beginPass(config: PassConfig) void {
    config.apply(&state.pass_action);

    var proj_mat: math.Mat32 = math.Mat32.init();

    // if we already blitted to the screen we can only blit to the backbuffer
    if (state.blitted_to_screen) {
        const size = aya.window.size();
        sg_begin_default_pass(&state.pass_action, size.w, size.h);
        proj_mat = math.Mat32.initOrtho(@intToFloat(f32, size.w), @intToFloat(f32, size.h));
    } else {
        // if we were given an OffscreenPass use it else use our DefaultOffscreenPass
        const pass = config.pass orelse state.default_pass.offscreen_pass;
        sg_begin_pass(pass.pass, &state.pass_action);
        proj_mat = math.Mat32.initOrtho(@intToFloat(f32, pass.color_tex.width), @intToFloat(f32, pass.color_tex.height));
    }

    // if we were given a transform matrix multiply it here
    if (config.trans_mat) |trans_mat| {
        proj_mat = proj_mat.mul(trans_mat);
    }

    state.transform_mat = proj_mat;

    // if we were given a Pipeline use it else set the default Pipeline
    setPipeline(config.pipeline);
}

pub fn endPass() void {
    draw.batcher.flush();
    setPipeline(null);
    aya.debug.render(state.debug_render_enabled);
    sg_end_pass();
}

pub fn flush() void {
    draw.batcher.flush();
}

pub fn postProcess(stack: *PostProcessStack) void {
    state.transform_mat = math.Mat32.initOrtho(@intToFloat(f32, state.default_pass.offscreen_pass.color_tex.width), @intToFloat(f32, state.default_pass.offscreen_pass.color_tex.height));
    stack.process(state.default_pass.offscreen_pass);
}

/// renders the default OffscreenPass to the backbuffer using the ResolutionScaler
pub fn blitToScreen(letterbox_color: math.Color) void {
    if (state.blitted_to_screen) return;
    state.blitted_to_screen = true;

    // TODO: Hack until we get window resized events
    state.default_pass.onWindowResizedCallback();

    beginPass(.{.color = letterbox_color});
    const scaler = state.default_pass.scaler;
    draw.texScale(state.default_pass.offscreen_pass.color_tex, @intToFloat(f32, scaler.x), @intToFloat(f32, scaler.y), scaler.scale);
    endPass();
}

/// if we havent yet blitted to the screen do so now
pub fn commit() void {
    if (!state.blitted_to_screen) {
        blitToScreen(math.Color.black);
    }

    draw.batcher.endFrame();
    state.blitted_to_screen = false;
    sg_commit();
}

// import all the drawing methods
usingnamespace @import("draw.zig");

