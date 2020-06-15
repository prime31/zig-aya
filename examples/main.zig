const std = @import("std");
const fna = @import("fna");
const mojo = fna.mojo;
const aya = @import("aya");

const png = @embedFile("../assets/font.png");
const Allocator = std.mem.Allocator;

var mesh: aya.gfx.Mesh = undefined;
var vertDecl: fna.VertexDeclaration = undefined;
var vertBindings: fna.VertexBufferBinding = undefined;
var vertBuffer: ?*fna.Buffer = undefined;

// defunct example. eventually make this a simple template
pub fn main() !void {
    try aya.run(.{
        .init = init,
        .update = update,
        .render = render,
    });

    mesh.deinit();
}

fn init() void {
    var vertices = [_]aya.gfx.Vertex{
        .{ .pos = .{ .x = 0.5, .y = -0.5 }, .uv = .{ .x = 1, .y = 0 }, .col = 0x00FF0FFF },
        .{ .pos = .{ .x = -0.5, .y = -0.5 }, .uv = .{ .x = 0, .y = 0 }, .col = 0xFF00FFFF },
        .{ .pos = .{ .x = -0.5, .y = 0.5 }, .uv = .{ .x = 0, .y = 1 }, .col = 0x00FFFFFF },
        .{ .pos = .{ .x = 0.5, .y = 0.5 }, .uv = .{ .x = 1, .y = 1 }, .col = 0xFFFFFFFF },
    };
    var indices = [_]u16{
        0, 1, 2, 2, 3, 0,
    };
    mesh = aya.gfx.Mesh.init(aya.gfx.Vertex, 4, 6, false, false);
    mesh.index_buffer.setData(u16, indices[0..], 0, .none);
    mesh.vert_buffer.setData(aya.gfx.Vertex, vertices[0..], 0, .none);

    const shader = createShader();
    createMesh() catch unreachable;
}

fn update() void {}

fn render() void {
    // fna.FNA3D_ApplyVertexBufferBindings(aya.gfx.device, &vertBindings, 1, 0, 0);
    //    fna.FNA3D_DrawPrimitives(aya.gfx.device, .triangle_list, 0, 2);
    mesh.draw(4);
}

fn createMesh() !void {
    var vert_elems = try aya.mem.allocator.alloc(fna.VertexElement, 3);

    vert_elems[0] = fna.VertexElement{
        .offset = 0,
        .vertexElementFormat = .vector2,
        .vertexElementUsage = .position,
        .usageIndex = 0,
    };
    vert_elems[1] = fna.VertexElement{
        .offset = 8,
        .vertexElementFormat = .vector2,
        .vertexElementUsage = .texture_coordinate,
        .usageIndex = 0,
    };
    vert_elems[2] = fna.VertexElement{
        .offset = 16,
        .vertexElementFormat = .color,
        .vertexElementUsage = .color,
        .usageIndex = 0,
    };
    vertDecl = fna.VertexDeclaration{
        .vertexStride = 20,
        .elementCount = 3,
        .elements = &vert_elems[0],
    };

    //@sizeOf(Vec2)
    var vertices = [_]aya.gfx.Vertex{
        .{ .pos = .{ .x = 0.5, .y = 0.5 }, .uv = .{ .x = 1, .y = 1 }, .col = 0xFFFFFFFF },
        .{ .pos = .{ .x = 0.5, .y = -0.5 }, .uv = .{ .x = 1, .y = 0 }, .col = 0x00FF0FFF },
        .{ .pos = .{ .x = -0.5, .y = -0.5 }, .uv = .{ .x = 0, .y = 0 }, .col = 0xFF00FFFF },
        .{ .pos = .{ .x = -0.5, .y = -0.5 }, .uv = .{ .x = 0, .y = 0 }, .col = 0xFF00FFFF },
        .{ .pos = .{ .x = -0.5, .y = 0.5 }, .uv = .{ .x = 0, .y = 1 }, .col = 0x00FFFFFF },
        .{ .pos = .{ .x = 0.5, .y = 0.5 }, .uv = .{ .x = 1, .y = 1 }, .col = 0xFFFFFFFF },
    };

    vertBuffer = fna.FNA3D_GenVertexBuffer(aya.gfx.device, 0, .write_only, vertices.len, 20);
    fna.FNA3D_SetVertexBufferData(aya.gfx.device, vertBuffer, 0, &vertices[0], @intCast(c_int, @sizeOf(aya.gfx.Vertex) * vertices.len), 1, 1, .none);

    vertBindings = fna.VertexBufferBinding{
        .vertexBuffer = vertBuffer,
        .vertexDeclaration = vertDecl,
        .vertexOffset = 0,
        .instanceFrequency = 0,
    };
}

fn createShader() !aya.gfx.Shader {
    // read shader from embedded file
    // var vertColor = @embedFile("../assets/VertexColor.fxb");

    // hack until i figure out how to get around const
    // var slice: [vertColor.len]u8 = undefined;
    // for (vertColor) |s, i|
    //     slice[i] = s;
    var shader = try aya.gfx.Shader.initFromFile("assets/VertexColor.fxb");
    var mat = aya.math.Mat32.initOrthoOffCenter(2, 2);
    shader.setParam(aya.math.Mat32, "TransformMatrix", mat);
    shader.apply();

    return shader;
}
