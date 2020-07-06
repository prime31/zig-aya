const std = @import("std");
const aya = @import("../aya.zig");

// exports
pub const ResolutionPolicy = @import("resolution_policy.zig").ResolutionPolicy;
pub const ResolutionScaler = @import("resolution_policy.zig").ResolutionScaler;
pub const Texture = @import("textures.zig").Texture;
pub const RenderTexture = @import("textures.zig").RenderTexture;
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

pub const Shader = @import("shader.zig").Shader;
pub const VertexBuffer = @import("buffers.zig").VertexBuffer;
pub const IndexBuffer = @import("buffers.zig").IndexBuffer;

pub const FontBook = @import("fontbook.zig").FontBook;

pub var device: *fna.Device = undefined;

pub const Config = struct {
    disable_debug_render: bool = false, // when true, debug rendering will be disabled
    design_width: i32 = 0, // the width of the main offscreen render texture when the policy is not .default
    design_height: i32 = 0, // the height of the main offscreen render texture when the policy is not .default
    resolution_policy: ResolutionPolicy = .default, // defines how the main render texture should be blitted to the backbuffer
    batcher_max_sprites: i32 = 1000, // defines the size of the vertex/index buffers based on the number of sprites/quads
};

// locals
const DefaultOffscreenPass = @import("offscreen_pass.zig").DefaultOffscreenPass;
const fna = @import("fna");
const math = @import("../math/math.zig");

var state = struct {
    viewport: fna.Viewport = fna.Viewport{ .w = 0, .h = 0 },
    rt_binding: fna.RenderTargetBinding = undefined,
    debug_render_enabled: bool = false,
    default_pass: DefaultOffscreenPass = undefined,
    blitted_to_screen: bool = false,
    sprite_shader: Shader = undefined,
    transform_mat: math.Mat32 = undefined,
}{};

pub fn init(params: *fna.PresentationParameters, config: Config) !void {
    device = fna.Device.init(params, true);

    // initialize all graphics state
    var raster_state = fna.RasterizerState{};
    setRasterizerState(&raster_state);

    var blend_state = fna.BlendState{};
    setBlendState(&blend_state);

    var depth_stencil_state = fna.DepthStencilState{};
    setDepthStencilState(&depth_stencil_state);

    setViewport(.{ .w = params.backBufferWidth, .h = params.backBufferHeight });
    setScissor(.{ .w = params.backBufferWidth, .h = params.backBufferHeight });

    try draw.init(config);
    state.debug_render_enabled = !config.disable_debug_render;

    // if we were passed 0's for design size default to the window/backbuffer size
    var design_w = config.design_width;
    var design_h = config.design_height;
    if (design_w == 0 or design_h == 0) {
        design_w = params.backBufferWidth;
        design_h = params.backBufferHeight;
    }
    state.default_pass = DefaultOffscreenPass.init(design_w, design_h, config.resolution_policy);

    state.sprite_shader = aya.gfx.Shader.initFromBytes(@embedFile("assets/SpriteEffect.fxb")) catch unreachable;
}

pub fn deinit() void {
    state.default_pass.deinit();
    state.sprite_shader.deinit();
    device.deinit();
}

pub fn clear(color: math.Color) void {
    var fna_color = @bitCast(fna.Vec4, color.asVec4());
    device.clear(&fna_color);
}

pub fn clearWithOptions(color: math.Color, options: fna.ClearOptions, depth: f32, stencil: i32) void {
    var fna_color = @bitCast(fna.Vec4, color.asVec4());
    device.clearWithOptions(options, &fna_color, depth, stencil);
}

pub fn setViewport(vp: fna.Viewport) void {
    state.viewport = vp;
    device.setViewport(&state.viewport);
}

pub fn setScissor(rect: math.RectI) void {
    var r = @bitCast(fna.Rect, rect);
    device.setScissorRect(&r);
}

pub fn setRasterizerState(rasterizer_state: *fna.RasterizerState) void {
    device.applyRasterizerState(rasterizer_state);
}

pub fn setBlendState(blend_state: *fna.BlendState) void {
    device.setBlendState(blend_state);
}

pub fn setDepthStencilState(depth_stencil_state: *fna.DepthStencilState) void {
    device.setDepthStencilState(depth_stencil_state);
}

pub fn resetBackbuffer(width: i32, height: i32) void {
    device.resetBackbuffer(width, height, aya.window.sdl_window);
    // TODO: why does setting the viewport here cause issues with rendering?
    setViewport(.{ .w = width, .h = height });
    setScissor(.{ .w = width, .h = height });
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

pub fn setRenderTexture(rt: ?RenderTexture) void {
    // early out if we have nothing to change
    if (state.rt_binding.texture == null and rt == null) return;
    if (rt != null and state.rt_binding.texture == rt.?.tex.tex) return;

    var new_width: i32 = undefined;
    var new_height: i32 = undefined;
    var clear_target = fna.RenderTargetUsage.platform_contents;

    // unsetting a render texture
    if (rt == null) {
        device.unSetRenderTarget();
        state.rt_binding.texture = null;

        device.getBackbufferSize(&new_width, &new_height);
        // TODO: save PresentationParams and fetch clear_target from it???
        // we dont need to Resolve the previous target since we dont support mips and multisampling
    } else {
        state.rt_binding.unnamed.twod.width = rt.?.tex.width;
        state.rt_binding.unnamed.twod.height = rt.?.tex.height;
        state.rt_binding.texture = rt.?.tex.tex;

        device.setRenderTarget(&state.rt_binding, rt.?.depth_stencil_buffer, rt.?.depth_stencil_format);

        new_width = rt.?.tex.width;
        new_height = rt.?.tex.height;
        // TODO: store clear_target in RenderTexture so we dont force platform_contents???
        // we dont need to Resolve the previous target since we dont support mips and multisampling
    }

    // Apply new state, clear target if requested
    // TODO: why does setting the viewport screw up rendering to a RT?
    setViewport(.{ .w = new_width, .h = new_height });
    setScissor(.{ .w = new_width, .h = new_height });

    if (clear_target == .discard_contents) clear(math.Color.black);
}

pub fn setShader(shader: Shader) void {
    draw.batcher.flush(false);
    if (shader.transform_matrix_index < std.math.maxInt(usize)) {
        shader.setParamByIndex(aya.math.Mat32, shader.transform_matrix_index, state.transform_mat);
    }
    shader.apply();
}

// Passes

pub const Pass = struct {
    color: ?math.Color = math.Color.aya,
    trans_mat: ?math.Mat32 = null,
    shader: ?Shader = null,
    render_texture: ?RenderTexture = null,
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
    var proj_mat: math.Mat32 = undefined;

    // if we already blitted to the screen we can only blit to the backbuffer
    if (state.blitted_to_screen) {
        var w: i32 = undefined;
        var h: i32 = undefined;
        aya.window.drawableSize(&w, &h);

        proj_mat = math.Mat32.initOrtho(@intToFloat(f32, w), @intToFloat(f32, h));
        setRenderTexture(null);
    } else {
        // if we were given an OffscreenPass use it else use our DefaultOffscreenPass
        const rt = config.render_texture orelse state.default_pass.render_tex;
        proj_mat = math.Mat32.initOrtho(@intToFloat(f32, rt.tex.width), @intToFloat(f32, rt.tex.height));
        setRenderTexture(rt);
        if (config.color) |color| {
            clear(color);
        }
    }

    // if we were given a transform matrix multiply it here
    if (config.trans_mat) |trans_mat| {
        proj_mat = proj_mat.mul(trans_mat);
    }

    state.transform_mat = proj_mat;

    // if we were given a Shader use it else set the SpriteEffect
    setShader(config.shader orelse state.sprite_shader);
}

pub fn endPass() void {
    draw.batcher.flush(false);
    aya.debug.render(state.debug_render_enabled);
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
    clear(letterbox_color);
    const scaler = state.default_pass.scaler;
    draw.texScale(state.default_pass.render_tex.tex, @intToFloat(f32, scaler.x), @intToFloat(f32, scaler.y), scaler.scale);
    endPass();
}

/// if we havent yet blitted to the screen do so now
pub fn commit() void {
    draw.batcher.endFrame();

    if (!state.blitted_to_screen) {
        blitToScreen(math.Color.black);
    }

    state.blitted_to_screen = false;
}

// import all the drawing methods
usingnamespace @import("draw.zig");

test "gfx tests" {
    setRenderTexture(null);
}