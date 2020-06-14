const std = @import("std");
const aya = @import("../aya.zig");

// exports
pub const ResolutionPolicy = @import("resolution_policy.zig").ResolutionPolicy;
pub const ResolutionScaler = @import("resolution_policy.zig").ResolutionScaler;
pub const Texture = @import("textures.zig").Texture;
pub const RenderTexture = @import("textures.zig").RenderTexture;
pub const OffscreenPass = @import("offscreen_pass.zig").OffscreenPass;

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

pub var state = struct {
    viewport: fna.Viewport = fna.Viewport{ .w = 0, .h = 0 },
    rt_binding: fna.RenderTargetBinding = undefined,
    debug_render_enabled: bool = false,
    default_pass: DefaultOffscreenPass = undefined,
    blitted_to_screen: bool = false,
}{};

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

pub fn setPresentationInterval(present_interval: fna.PresentInterval) void {
    device.setPresentationInterval(present_interval);
}

pub fn getResolutionScaler() ResolutionScaler {
    return state.default_pass.scaler;
}

pub fn getFontBook() FontBook {
    return draw.fontbook;
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
    // setViewport(.{ .w = new_width, .h = new_height });
    setScissor(.{ .w = new_width, .h = new_height });

    if (clear_target == .discard_contents) clear(math.Color.black);
}

// Passes

// offscreen passes should be rendered first. If no pass is in the PassConfig rendering will be done to the
// DefaultOffscreenPass. After all passes are run you can optionally call postprocess and then blitToScreen.
// If another pass is run after blitToScreen rendering will be to the backbuffer.
pub fn beginPass() void {
    var proj_mat = math.Mat32.identity;

    // if we already blitted to the screen we can only blit to the backbuffer
    if (state.blitted_to_screen) {
        var w: i32 = undefined;
        var h: i32 = undefined;
        aya.window.drawableSize(&h, &w);
        // clear and set viewport
        proj_mat = math.Mat32.initOrtho(w, h);
    } else {
        // if we were given an OffscreenPass use it else use our DefaultOffscreenPass
        //pass := if config.pass == 0 { &gg.def_pass.offscreen_pass } else { config.pass }
        proj_mat = math.Mat32.initOrtho(pass.color_tex.w, pass.color_tex.h);
    }

    // if we were given a transform matrix multiply it here
    //proj_mat = proj_mat * *config.trans_mat

    // if we were given a Shader use it else set the SpriteEffect

    // set the TransformMatrix if it exists on the Shader
}

pub fn endPass() void {
    draw.batcher.flush(false);
    aya.debug.render(state.debug_render_enabled);
}

// pub fn postprocess(effect_stack: EffectStack) void {
//effect_stack.process(state.default_pass)
// }

// renders the default OffscreenPass to the backbuffer using the ResolutionScaler
pub fn blitToScreen(letterbox_color: math.Color) void {
    state.blitted_to_screen = true;

    // begin_pass({color:letterbox_color trans_mat:0 pipeline:0 pass:0})
    const scaler = state.default_pass.scaler;
    //draw.batcher.draw(state.default_pass.render_tex.texture, {x:scaler.x y:scaler.y sx:scaler.scale sy:scaler.scale})
}

/// if we havent yet blitted to the screen do so now
pub fn commit() void {
    draw.batcher.endFrame();

    if (!state.blitted_to_screen)
        blitToScreen(math.Color.black);

    state.blitted_to_screen = false;
}

// import all the drawing methods
usingnamespace @import("draw.zig");

test "gfx tests" {
    setRenderTexture(null);
}
