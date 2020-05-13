const std = @import("std");
const fna = @import("fna");
const mojo = fna.mojo;
const aya = @import("aya");

const png = @embedFile("../assets/font.png");
const Allocator = std.mem.Allocator;

pub const Shader = extern struct {
    effect: ?*fna.Effect = null,
    mojoEffect: ?*mojo.Effect = null,
};

var vertDecl: fna.VertexDeclaration = undefined;
var vertBindings: fna.VertexBufferBinding = undefined;
var vertBuffer: ?*fna.Buffer = undefined;
var vertElems: [3]fna.VertexElement = undefined;

pub fn main() anyerror!void {
    try aya.run(.{
        .init = init,
        .update = update,
        .render = render,
    });

    const c = aya.math.Color.light_gray;
    // const tex = fna.img.load(device, "assets/font.png");
    // std.debug.warn("loaded tex: {}\n", .{tex});
}

fn init() void {
    const shader = createShader();
    createMesh();
}

fn update() void {}

fn render() void {
    fna.FNA3D_ApplyVertexBufferBindings(aya.gfx.device, &vertBindings, 1, 0, 0);
    fna.FNA3D_DrawPrimitives(aya.gfx.device, .triangle_list, 0, 2);
}

fn createMesh() void {
    vertElems[0] = fna.VertexElement{
        .offset = 0,
        .vertexElementFormat = .vector2,
        .vertexElementUsage = .position,
        .usageIndex = 0,
    };
    vertElems[1] = fna.VertexElement{
        .offset = 8,
        .vertexElementFormat = .vector2,
        .vertexElementUsage = .texture_coordinate,
        .usageIndex = 0,
    };
    vertElems[2] = fna.VertexElement{
        .offset = 16,
        .vertexElementFormat = .color,
        .vertexElementUsage = .color,
        .usageIndex = 0,
    };
    vertDecl = fna.VertexDeclaration{
        .vertexStride = 20,
        .elementCount = 3,
        .elements = &vertElems,
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

    const indices = [_]u16{
        0, 1, 2, 0, 2, 3,
    };

    vertBindings = fna.VertexBufferBinding{
        .vertexBuffer = vertBuffer,
        .vertexDeclaration = vertDecl,
        .vertexOffset = 0,
        .instanceFrequency = 0,
    };
}

fn createShader() !aya.gfx.Shader {
    var shader = try aya.gfx.Shader.initFromFile("assets/VertexColor.fxb");
    shader.apply();

    return shader;
}
