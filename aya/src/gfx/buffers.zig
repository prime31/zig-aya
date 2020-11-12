const std = @import("std");
const aya = @import("../../aya.zig");
const gfx = aya.gfx;
const Vec2 = @import("../math/vec2.zig").Vec2;
usingnamespace aya.sokol;

pub const Vertex = packed struct {
    pos: Vec2,
    uv: Vec2 = .{ .x = 0, .y = 0 },
    col: u32 = 0xFFFFFFFF,
};

pub const VertexPositionColor = packed struct {
    pos: Vec2,
    col: u32 = 0xFFFFFFFF,
};

pub const VertexBuffer = struct {
    pub fn make(comptime T: type, vertices: []T) sg_buffer {
        var buffer_desc = std.mem.zeroes(sg_buffer_desc);
        buffer_desc.type = .SG_BUFFERTYPE_VERTEXBUFFER;
        buffer_desc.size = @intCast(c_int, vertices.len * @sizeOf(T));
        buffer_desc.usage = .SG_USAGE_IMMUTABLE;
        buffer_desc.content = vertices.ptr;

        return sg_make_buffer(&buffer_desc);
    }

    pub fn makeMutable(comptime T: type, vert_count: usize, usage: sg_usage) sg_buffer {
        var buffer_desc = std.mem.zeroes(sg_buffer_desc);
        buffer_desc.type = .SG_BUFFERTYPE_VERTEXBUFFER;
        buffer_desc.size = @intCast(c_int, vert_count * @sizeOf(T));
        buffer_desc.usage = usage;
        return sg_make_buffer(&buffer_desc);
    }
};

pub const IndexBuffer = struct {
    pub fn make(comptime T: type, indices: []T) sg_buffer {
        std.debug.assert(T == u16 or T == u32);

        var buffer_desc = std.mem.zeroes(sg_buffer_desc);
        buffer_desc.type = .SG_BUFFERTYPE_INDEXBUFFER;
        buffer_desc.size = @intCast(c_int, indices.len * @sizeOf(T));
        buffer_desc.usage = .SG_USAGE_IMMUTABLE;
        buffer_desc.content = indices.ptr;

        return sg_make_buffer(&buffer_desc);
    }

    pub fn makeMutable(comptime T: type, indices_count: usize, usage: sg_usage) sg_buffer {
        std.debug.assert(T == u16 or T == u32);

        var buffer_desc = std.mem.zeroes(sg_buffer_desc);
        buffer_desc.type = .SG_BUFFERTYPE_INDEXBUFFER;
        buffer_desc.size = @intCast(c_int, indices_count * @sizeOf(T));
        buffer_desc.usage = usage;
        return sg_make_buffer(&buffer_desc);
    }
};

pub const Bindings = struct {
    pub fn make(vertex_buffer: sg_buffer, index_buffer: sg_buffer) sg_bindings {
        var bindings = std.mem.zeroes(sg_bindings);
        bindings.vertex_buffers[0] = vertex_buffer;
        bindings.index_buffer = index_buffer;
        return bindings;
    }
};