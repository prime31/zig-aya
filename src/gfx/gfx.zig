const std = @import("std");
const aya = @import("../aya.zig");

// exports
pub const ResolutionPolicy = @import("resolution_policy.zig").ResolutionPolicy;
pub const ResolutionScaler = @import("resolution_policy.zig").ResolutionScaler;
pub const Texture = @import("textures.zig").Texture;
pub const RenderTexture = @import("textures.zig").RenderTexture;
pub const OffscreenPass = @import("offscreen_pass.zig").OffscreenPass;

pub const Batcher = @import("batcher.zig").Batcher;
pub const AtlasBatch = @import("atlas_batch.zig").AtlasBatch;

pub const Vertex = @import("buffers.zig").Vertex;
pub const Mesh = @import("mesh.zig").Mesh;
pub const DynamicMesh = @import("mesh.zig").DynamicMesh;

pub const Shader = @import("shader.zig").Shader;
pub const VertexBuffer = @import("buffers.zig").VertexBuffer;
pub const IndexBuffer = @import("buffers.zig").IndexBuffer;

pub var device: *fna.Device = undefined;

pub const Config = struct {
    disable_debug_render: bool,
    design_width: i32,
    design_height: i32,
    resolution_policy: ResolutionPolicy,
    batcher_max_sprites: i32,
};

// locals
const DefaultOffscreenPass = @import("offscreen_pass.zig").DefaultOffscreenPass;
const fna = @import("../deps/fna/fna.zig");
const math = @import("../math/math.zig");

const State = struct {
    viewport: fna.Viewport = fna.Viewport{ .w = 0, .h = 0 },
    white_tex: Texture = undefined,
    rt_binding: fna.RenderTargetBinding = undefined,
    batcher: Batcher = undefined,
    debug_render_enabled: bool = false,
    default_pass: DefaultOffscreenPass = undefined,
    // FontBook
};
var state = State{};

pub fn init(params: *fna.PresentationParameters, config: Config) !void {
    device = fna.Device.init(params, true);
    setPresentationInterval(.one);

    var rasterizer = fna.RasterizerState{};
    device.applyRasterizerState(&rasterizer);

    var blend = fna.BlendState{};
    device.setBlendState(&blend);

    var depthStencil = fna.DepthStencilState{};
    device.setDepthStencilState(&depthStencil);

    setViewport(.{ .w = params.backBufferWidth, .h = params.backBufferHeight });

    var pixels = [_]u32{ 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF };
    state.white_tex = Texture.init(2, 2);
    state.white_tex.setColorData(pixels[0..]);

    state.batcher = try Batcher.init(null, config.batcher_max_sprites);
    state.debug_render_enabled = !config.disable_debug_render;

    // if we were passed 0's for design size default to the window/backbuffer size
    var design_w = config.design_width;
    var design_h = config.design_height;
    if (design_w == 0 or design_h == 0) {
        design_w = params.backBufferWidth;
        design_h = params.backBufferHeight;
    }
    state.default_pass = DefaultOffscreenPass.init(design_w, design_h, config.resolution_policy);

    // state.default_fontbook = new_fontbook(256, 256);
    // fontbook_add_font_mem(state.default_fontbook, default_font_bytes, false);
    // fontbook_set_size(state.default_fontbook, 10);
    //
    // state.default_pass = new_defaultoffscreenpass(design_w, design_h, resolution_policy);
}

pub fn clear(color: math.Color) void {
    var fna_color = @bitCast(fna.Vec4, color.asVec4());
    device.clear(&fna_color);
}

// TODO: use a proper Color
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

pub fn setPresentationInterval(present_interval: fna.PresentInterval) void {
    device.setPresentationInterval(present_interval);
}

pub fn getResolutionScaler() ResolutionScaler {
    return state.default_pass.scaler;
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
    setViewport(.{ .w = new_width, .h = new_height });
    setScissor(.{ .w = new_width, .h = new_height });

    if (clear_target == .discard_contents) clear(.{ .x = 0, .y = 0, .z = 0, .w = 1 });
}

// Drawing
pub fn beginPass() void {} // TODO

pub fn endPass() void {
    state.batcher.flush(false);
    aya.debug.render(state.debug_render_enabled);
}

test "gfx tests" {
    setRenderTexture(null);
}
