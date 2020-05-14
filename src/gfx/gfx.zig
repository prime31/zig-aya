const std = @import("std");

pub const ResolutionPolicy = @import("resolution_policy.zig").ResolutionPolicy;
pub const Texture = @import("texture.zig").Texture;
pub const Vertex = @import("vertices.zig").Vertex;
pub const Shader = @import("shader.zig").Shader;

pub var device: ?*fna.Device = null;

const fna = @import("../deps/fna/fna.zig");

const State = struct {
    viewport: fna.Viewport = fna.Viewport{ .w = 0, .h = 0 },
    white_tex: Texture = undefined,
    // FontBook
    // Batcher
    // Default_Offscreen_Pass
};
var state = State{};

pub fn init(params: *fna.PresentationParameters, disable_debug_render: bool, design_w: i32, design_h: i32, resolution_policy: ResolutionPolicy) void {
    device = fna.FNA3D_CreateDevice(params, 1);
    setPresentationInterval(.one);

    var rasterizer = fna.RasterizerState{};
    fna.FNA3D_ApplyRasterizerState(device, &rasterizer);

    var blend = fna.BlendState{};
    fna.FNA3D_SetBlendState(device, &blend);

    var depthStencil = fna.DepthStencilState{};
    fna.FNA3D_SetDepthStencilState(device, &depthStencil);

    setViewport(.{ .w = params.backBufferWidth, .h = params.backBufferHeight });

    // _batcher = new_batcher();
    //
    var pixels = [_]u32{ 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF };
    state.white_tex = Texture.init(2, 2);
    state.white_tex.setColorData(pixels[0..]);
    // default_fontbook = new_fontbook(256, 256);
    // fontbook_add_font_mem(default_fontbook, default_font_bytes, false);
    // fontbook_set_size(default_fontbook, 10);
    //
    // _default_pass = new_defaultoffscreenpass(design_w, design_h, resolution_policy);
    // fmt.println(_default_pass);
    //
    // _debug_render_enabled = !disable_debug_render;
    // debug_init();
}

pub fn clear(color: fna.Vec4) void {
    clearWithOptions(color, .all, 1, 0);
}

pub fn clearWithOptions(color: fna.Vec4, options: fna.ClearOptions, depth: f32, stencil: i32) void {
    var clear_color = color;
    fna.FNA3D_Clear(device, options, &clear_color, depth, stencil);
}

pub fn setViewport(vp: fna.Viewport) void {
    state.viewport = vp;
    fna.FNA3D_SetViewport(device, &state.viewport);
}

pub fn setPresentationInterval(present_interval: fna.PresentInterval) void {
    fna.FNA3D_SetPresentationInterval(device, present_interval);
}

pub fn getResolutionScaler() ResolutionScaler {
    return .default;
}

pub fn setRenderTexture() void { // render_texture: ^RenderTexture
    }
