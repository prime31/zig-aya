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

const State = struct {
    viewport: fna.Viewport = fna.Viewport{ .w = 0, .h = 0 },
    white_tex: Texture = undefined,
    rt_binding: fna.RenderTargetBinding = undefined,
    batcher: Batcher = undefined,
    debug_render_enabled: bool = false,
    default_pass: DefaultOffscreenPass = undefined,
    quad: math.Quad = math.Quad.init(0, 0, 1, 1, 1, 1),
    fontbook: *FontBook = undefined,
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

    state.fontbook = try FontBook.init(null, 128, 128, .point);
    _ = state.fontbook.addFontMem("ProggyTiny", @embedFile("assets/ProggyTiny.ttf"), false);
    state.fontbook.setSize(10);
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
pub fn beginPass() void {} // TODO

pub fn endPass() void {
    state.batcher.flush(false);
    aya.debug.render(state.debug_render_enabled);
}

/// if we havent yet blitted to the screen do so now
pub fn commit() void {
    state.batcher.endFrame();

    // TODO: deal with final blit
}

// Drawing
pub fn drawTex(texture: Texture, x: f32, y: f32) void {
    state.quad.setFill(texture.width, texture.height);

    var mat = math.Mat32.initTransform(.{ .x = x, .y = y });
    state.batcher.draw(texture.tex, state.quad, mat, math.Color.white);
}

pub fn drawTexScale(texture: Texture, x: f32, y: f32, scale: f32) void {
    state.quad.setFill(texture.width, texture.height);

    var mat = math.Mat32.initTransform(.{ .x = x, .y = y, .angle = 0, .sx = scale, .sy = scale });
    state.batcher.draw(texture.tex, state.quad, mat, math.Color.white);
}

pub fn drawText(str: []const u8, fontbook: ?*FontBook) void {
    const cstr = std.cstr.addNullByte(aya.mem.tmp_allocator, str) catch unreachable;
    drawTextZ(cstr, fontbook);
}

pub fn drawTextZ(cstr: [:0]const u8, fontbook: ?*FontBook) void {
    var book = if (fontbook != null) fontbook.? else state.fontbook;
    var matrix = math.Mat32.initTransform(.{ .x = 20, .y = 40, .sx = 4, .sy = 4 });
    book.setAlign(.left);

    var fons_quad = book.getQuad();
    var iter = book.getTextIterator(cstr);
    while (book.textIterNext(&iter, &fons_quad)) {
        state.quad.positions[0] = .{ .x = fons_quad.x0, .y = fons_quad.y0 };
        state.quad.positions[1] = .{ .x = fons_quad.x1, .y = fons_quad.y0 };
        state.quad.positions[2] = .{ .x = fons_quad.x1, .y = fons_quad.y1 };
        state.quad.positions[3] = .{ .x = fons_quad.x0, .y = fons_quad.y1 };

        state.quad.uvs[0] = .{ .x = fons_quad.s0, .y = fons_quad.t0 };
        state.quad.uvs[1] = .{ .x = fons_quad.s1, .y = fons_quad.t0 };
        state.quad.uvs[2] = .{ .x = fons_quad.s1, .y = fons_quad.t1 };
        state.quad.uvs[3] = .{ .x = fons_quad.s0, .y = fons_quad.t1 };

        state.batcher.draw(book.texture.?.tex, state.quad, matrix, aya.math.Color.white);
    }
}

pub fn drawPoint(position: math.Vec2, size: f32, color: math.Color) void {
    state.quad.setFill(@floatToInt(i32, size), @floatToInt(i32, size));

    const offset = if (size == 1) 0 else size * 0.5;
    var mat = math.Mat32.initTransform(.{ .x = position.x, .y = position.y, .ox = offset, .oy = offset });
    state.batcher.draw(state.white_tex.tex, state.quad, mat, color);
}

pub fn drawLine(start: math.Vec2, end: math.Vec2, thickness: f32, color: math.Color) void {
    state.quad.setFill(1, 1);

    const angle = start.angleBetween(end);
    const length = start.distance(end);

    var mat = math.Mat32.initTransform(.{ .x = start.x, .y = start.y, .angle = angle, .sx = length, .sy = thickness });
    state.batcher.draw(state.white_tex.tex, state.quad, mat, color);
}

pub fn drawRect(position: math.Vec2, width: f32, height: f32, color: math.Color) void {
    state.quad.setFill(@floatToInt(i32, width), @floatToInt(i32, height));
    var mat = math.Mat32.initTransform(.{ .x = position.x, .y = position.y });
    state.batcher.draw(state.white_tex.tex, state.quad, mat, color);
}

pub fn drawHollowRect(position: math.Vec2, width: f32, height: f32, thickness: f32, color: math.Color) void {
    const tr = math.Vec2{ .x = position.x + width, .y = position.y };
    const br = math.Vec2{ .x = position.x + width, .y = position.y + height };
    const bl = math.Vec2{ .x = position.x, .y = position.y + height };

    drawLine(position, tr, thickness, color);
    drawLine(tr, br, thickness, color);
    drawLine(br, bl, thickness, color);
    drawLine(bl, position, thickness, color);
}

pub fn drawCircle(center: math.Vec2, radius: f32, thickness: f32, resolution: i32, color: math.Color) void {
    state.quad.setFill(state.white_tex.width, state.white_tex.height);

    var last = math.Vec2.init(1, 0);
    last.scale(radius);
    var last_p = last.orthogonal();

    var i: usize = 0;
    while (i <= resolution) : (i += 1) {
        const at = math.Vec2.angleToVec(@intToFloat(f32, i) * math.pi_over_2 / @intToFloat(f32, resolution), radius);
        const at_p = at.orthogonal();

        drawLine(center.add(last), center.add(at), thickness, color);
        drawLine(center.subtract(last), center.subtract(at), thickness, color);
        drawLine(center.add(last_p), center.add(at_p), thickness, color);
        drawLine(center.subtract(last_p), center.subtract(at_p), thickness, color);

        last = at;
        last_p = at_p;
    }
}

pub fn drawHollowPolygon(verts: []const math.Vec2, thickness: f32, color: math.Color) void {
    var i: usize = 0;
    while (i < verts.len - 1) : (i += 1) {
        drawLine(verts[i], verts[i + 1], thickness, color);
    }
    drawLine(verts[verts.len - 1], verts[0], thickness, color);
}

test "gfx tests" {
    setRenderTexture(null);
}
