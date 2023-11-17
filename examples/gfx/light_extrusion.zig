const std = @import("std");
const shaders = @import("shaders");
const aya = @import("aya");
const ig = aya.ig;

const DynamicMesh = aya.render.DynamicMesh;
const Texture = aya.render.Texture;
const Color = aya.math.Color;
const Shader = aya.render.Shader;

const Vec2 = aya.math.Vec2;
const Mat32 = aya.math.Mat32;

var light_extrusion_shader: LightExtrusionShader = undefined;
var light_extrusion_mesh: LightExtrusionMesh = undefined;

var light_pos = Vec2.init(240, 220);

pub fn main() !void {
    std.debug.print("\n", .{});
    try aya.run(.{
        .init = init,
        .render = render,
        .update = update,
        .shutdown = shutdown,
    });
}

fn init() !void {
    light_extrusion_shader = LightExtrusionShader.init();
    light_extrusion_mesh = LightExtrusionMesh.init(64);
}

fn update() !void {
    _ = ig.igSliderFloat2("light pos", &light_pos.x, 0, 1500, null, ig.ImGuiSliderFlags_NoInput);
    _ = ig.igDragFloat2("light pos", &light_pos.x, 5, 0, 1500, null, ig.ImGuiSliderFlags_None);

    aya.debug.drawPoint(light_pos, 16, Color.yellow);
}

fn render() !void {
    aya.gfx.beginPass(.{});

    aya.gfx.endPass();
}

fn shutdown() !void {
    light_extrusion_shader.deinit();
    light_extrusion_mesh.deinit();
}

pub const LightExtrusionVertex = extern struct {
    pos: Vec2 = .{ .x = 0, .y = 0 },
    normal: Vec2 = .{ .x = 0, .y = 0 },
};

pub const LightExtrusionShader = struct {
    const LightExtrusionVertexParams = extern struct {
        pub const metadata = .{
            .uniforms = .{ .params = .{ .type = .float4, .array_count = 2 } },
        };

        params: [8]f32 = [_]f32{0} ** 8,
    };

    shader: Shader,
    vert_uniform: LightExtrusionVertexParams = .{},

    pub fn init() LightExtrusionShader {
        const vert = "examples/assets/shaders/light_extrusion_vs.glsl";
        const frag = "examples/assets/shaders/light_extrusion_fs.glsl";
        var shader = Shader.initWithVertFrag(
            LightExtrusionVertexParams,
            struct {},
            .{ .frag = frag, .vert = vert },
        );

        shader.onSetTransformMatrix = struct {
            fn set(self: *Shader, mat: *Mat32) void {
                var params = shaders.DeferredVertexParams{};
                std.mem.copy(f32, &params.transform_matrix, &mat.data);
                self.setVertUniform(shaders.DeferredVertexParams, &params);
            }
        }.set;

        return .{ .shader = shader };
    }

    pub fn deinit(self: LightExtrusionShader) void {
        self.shader.deinit();
    }

    pub fn setLightPos(self: *LightExtrusionShader, pos: Vec2) void {
        self.vert_uniform.params[6] = pos.x;
        self.vert_uniform.params[7] = pos.y;
    }
};

const LightExtrusionMesh = struct {
    mesh: DynamicMesh(u16, LightExtrusionVertex),
    vert_index: usize = 0,

    pub fn init(max_tris: u16) LightExtrusionMesh {
        var indices = aya.mem.tmp_allocator.alloc(u16, max_tris * 3) catch unreachable;
        var i: usize = 0;
        while (i < max_tris) : (i += 1) {
            indices[i * 3 + 0] = @as(u16, @intCast(i)) * 4 + 0;
            indices[i * 3 + 1] = @as(u16, @intCast(i)) * 4 + 1;
            indices[i * 3 + 2] = @as(u16, @intCast(i)) * 4 + 2;
        }

        return .{ .mesh = DynamicMesh(u16, LightExtrusionVertex).init(max_tris * 3, indices) };
    }

    pub fn deinit(self: *LightExtrusionMesh) void {
        self.mesh.deinit();
    }

    pub fn uploadAndRender(self: *LightExtrusionMesh) void {
        self.mesh.updateAllVerts();
        self.mesh.drawAllVerts();
    }

    pub fn appendRect(self: *LightExtrusionMesh) void {
        const pos = Vec2.init(200, 200);
        const width = 100;
        const height = 100;

        var verts = self.mesh.verts[self.vert_index .. self.vert_index + 4];
        verts[0].pos = pos; // tl
        verts[0].normal = .{ .x = -0.5, .y = -0.5 };

        verts[1].pos = .{ .x = pos.x + width, .y = pos.y }; // tr
        verts[1].normal = .{ .x = 0.5, .y = 0.5 };

        verts[2].pos = .{ .x = pos.x + width, .y = pos.y + height }; // br
        verts[2].normal = .{ .x = 0.5, .y = -0.5 };

        verts[3].pos = .{ .x = pos.x, .y = pos.y + height }; // bl
        verts[3].normal = .{ .x = -0.5, .y = -0.5 };
        // self.mesh.appendVertSlice(start_index: usize, num_verts: usize)
    }
};
