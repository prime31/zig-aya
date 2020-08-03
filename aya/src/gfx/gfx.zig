const std = @import("std");
const aya = @import("../aya.zig");
usingnamespace aya.sokol;

// exports
pub const ResolutionPolicy = @import("resolution_policy.zig").ResolutionPolicy;
pub const ResolutionScaler = @import("resolution_policy.zig").ResolutionScaler;
pub const Texture = @import("texture.zig").Texture;
pub const OffscreenPass = @import("offscreen_pass.zig").OffscreenPass;

pub const PostProcessStack = @import("post_process_stack.zig").PostProcessStack;
// TODO: move Sepia to its own file
pub const Sepia = @import("post_process_stack.zig").Sepia;

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
};

// locals
const DefaultOffscreenPass = @import("offscreen_pass.zig").DefaultOffscreenPass;
const math = @import("../math/math.zig");

var state = struct {
    debug_render_enabled: bool = false,
    default_pass_action: sg_pass_action = undefined,
    default_pipeline: Pipeline = undefined,
    default_pass: DefaultOffscreenPass = undefined,
    blitted_to_screen: bool = false,
    transform_mat: math.Mat32 = undefined,
}{};

pub fn init(config: Config) void {
    draw.init(config) catch unreachable;
    state.debug_render_enabled = !config.disable_debug_render;
    state.default_pipeline = Pipeline.makeDefaultPipeline();

    // if we were passed 0's for design size default to the window/backbuffer size
    var design_w = config.design_width;
    var design_h = config.design_height;
    if (design_w == 0 or design_h == 0) {
        design_w = aya.window.width();
        design_h = aya.window.height();
    }
    state.default_pass = DefaultOffscreenPass.init(design_w, design_h, config.resolution_policy);
}

pub fn deinit() void {
    state.default_pass.deinit();
    state.default_pipeline.deinit();
}

pub fn getResolutionScaler() ResolutionScaler {
    return state.default_pass.scaler;
}

pub fn getFontBook() FontBook {
    return draw.fontbook;
}

pub fn createPostProcessStack() PostProcessStack {
    return PostProcessStack.init(null, state.default_pass.design_w, state.default_pass.design_h);
}

pub fn setPipeline(pipeline: Pipeline) void {
    draw.batcher.flush(false);
    // if (shader.transform_matrix_index < std.math.maxInt(usize)) {
    //     shader.setParamByIndex(aya.math.Mat32, shader.transform_matrix_index, state.transform_mat);
    // }
    sg_apply_pipeline(pipeline.pip);
    sg_apply_uniforms(.SG_SHADERSTAGE_VS, 0, &state.transform_mat.data, @sizeOf(math.Mat32));
}

// Passes
pub const Pass = struct {
    color: ?math.Color = math.Color.aya,
    trans_mat: ?math.Mat32 = null,
    pipeline: ?Pipeline = null,
    render_texture: ?Texture = null,
};

/// calling this instead of beginPass skips all rendering to the faux backbuffer including blitting it to screen. The default shader
/// will not be set and no render texture will be set. This is useful when making a full ImGui application.
pub fn beginNullPass() void {
    state.blitted_to_screen = true;
}

// OffscreenPasses should be rendered first. If no pass is in the PassConfig rendering will be done to the
// DefaultOffscreenPass. After all passes are run you can optionally call postProcess and then blitToScreen.
// If another pass is run after blitToScreen rendering will be to the backbuffer.
pub fn beginPass(config: Pass) void {
    state.default_pass_action.colors[0].action = .SG_ACTION_CLEAR;
    state.default_pass_action.colors[0].val = if (config.color) |col| col.asSlice() else [_]f32{ 0.2, 0.2, 0.2, 1.0 };

    var proj_mat: math.Mat32 = undefined;

    // if we already blitted to the screen we can only blit to the backbuffer
    if (state.blitted_to_screen) {
        sg_begin_default_pass(&state.default_pass_action, aya.window.width(), aya.window.height());
        proj_mat = math.Mat32.initOrtho(@intToFloat(f32, aya.window.width()), @intToFloat(f32, aya.window.height()));
    } else {
        // if we were given an OffscreenPass use it else use our DefaultOffscreenPass
        std.debug.print("----------------- need a pass ass: {}\n", .{"dang"});
        const rt = config.render_texture orelse state.default_pass.render_tex;
        proj_mat = math.Mat32.initOrtho(@intToFloat(f32, rt.width), @intToFloat(f32, rt.height));
        if (config.color) |color| {
            // clear(color);
        }
    }

    // if we were given a transform matrix multiply it here
    if (config.trans_mat) |trans_mat| {
        proj_mat = proj_mat.mul(trans_mat);
    }

    state.transform_mat = proj_mat;

    // if we were given a Pipeline use it else set the default Pipeline
    setPipeline(config.pipeline orelse state.default_pipeline);
}

pub fn endPass() void {
    draw.batcher.flush(false);
    aya.debug.render(state.debug_render_enabled);
    sg_end_pass();
}

pub fn postProcess(stack: *PostProcessStack) void {
    state.transform_mat = math.Mat32.initOrtho(@intToFloat(f32, state.default_pass.render_tex.tex.width), @intToFloat(f32, state.default_pass.render_tex.tex.height));
    stack.process(&state.default_pass.render_tex);
}

/// renders the default OffscreenPass to the backbuffer using the ResolutionScaler
pub fn blitToScreen(letterbox_color: math.Color) void {
    state.blitted_to_screen = true;

    // TODO: Hack until we get window resized events
    state.default_pass.onWindowResizedCallback();

    beginPass(.{.color = letterbox_color});
    const scaler = state.default_pass.scaler;
    draw.texScale(state.default_pass.render_tex, @intToFloat(f32, scaler.x), @intToFloat(f32, scaler.y), scaler.scale);
    endPass();
}

/// if we havent yet blitted to the screen do so now
pub fn commit() void {
    draw.batcher.endFrame();

    if (!state.blitted_to_screen) {
        blitToScreen(math.Color.black);
    }

    state.blitted_to_screen = false;
    sg_commit();
}

// import all the drawing methods
usingnamespace @import("draw.zig");

test "gfx tests" {
    setRenderTexture(null);
}
