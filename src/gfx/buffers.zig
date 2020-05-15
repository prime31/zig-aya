const std = @import("std");
const fna = @import("../deps/fna/fna.zig");
const aya = @import("../aya.zig");
const gfx = @import("gfx.zig");
const Vec2 = @import("../math/vec2.zig").Vec2;

pub const Vertex = struct {
    pos: Vec2,
    uv: Vec2,
    col: u32 = 0xFFFFFFFF,
};

pub const VertexBuffer = struct {
    buffer: ?*fna.Buffer = undefined,

    var vert_decl_cache = std.StringHashMap(fna.VertexDeclaration).init(aya.mem.allocator);

    //vertex_count: i32, is_dynamic: bool = false, usage: fna.Buffer_Usage = .Write_Only
    pub fn init(comptime T: type, vertex_count: i32, dynamic: bool) VertexBuffer {
        const vert_decl = vertexDeclarationForType(T) catch unreachable;
        const is_dynamic: u8 = if (dynamic) 0 else 1;
        return VertexBuffer{
            .buffer = fna.FNA3D_GenVertexBuffer(aya.gfx.device, is_dynamic, .write_only, vertex_count, vert_decl.vertexStride),
        };
    }

    pub fn initWithUsage(comptime T: type, vertex_count: i32, dynamic: bool, usage: fna.BufferUsage) VertexBuffer {
        buffer = fna.FNA3D_GenVertexBuffer(aya.gfx.device, 0, usage, vertex_count, 20);
        return VertexBuffer{};
    }

    pub fn deinit(self: VertexBuffer) void {
        fna.FNA3D_AddDisposeVertexBuffer(aya.gfx.device, self.buffer);
    }

    fn vertexDeclarationForType(comptime T: type) !fna.VertexDeclaration {
        if (vert_decl_cache.getValue(@typeName(T))) |decl| return decl;

        const vert_decl = switch (T) {
            Vertex => blk: {
                var usages = [_]fna.VertexElementUsage{ .position, .texture_coordinate, .color };
                break :blk try VertexBuffer.vertexDeclarationForTypeUsages(T, usages[0..]);
            },
            else => unreachable,
        };

        _ = vert_decl_cache.put(@typeName(T), vert_decl) catch |err| std.debug.warn("failed caching vertex declartion: {}\n", .{err});

        return vert_decl;
    }

    /// returns a VertexDeclaration for type. The elements array must be freed later! usages are fna.VertexElementUsage
    fn vertexDeclarationForTypeUsages(comptime T: type, usages: []fna.VertexElementUsage) !fna.VertexDeclaration {
        var vert_elems = try vertexElementsForType(T, usages);
        return fna.VertexDeclaration{
            .vertexStride = @intCast(i32, @sizeOf(T)),
            .elementCount = @intCast(i32, vert_elems.len),
            .elements = &vert_elems[0],
        };
    }

    /// returns the VertexElementFormat for a given type
    fn vertexFormatForType(comptime T: type) fna.VertexElementFormat {
        switch (@typeInfo(T)) {
            .Struct => |StructT| {
                const field_type = StructT.fields[0].field_type;
                const field_size = @sizeOf(field_type);

                switch (@typeInfo(field_type)) {
                    .Int => {
                        std.debug.assert(field_size == 2);
                        switch (StructT.fields.len) {
                            2 => return .short2,
                            4 => return .short4,
                            else => unreachable,
                        }
                    },
                    .Float => {
                        switch (field_size) {
                            2 => {
                                switch (StructT.fields.len) {
                                    2 => return .half_vector2,
                                    4 => return .half_vector4,
                                    else => unreachable,
                                }
                            },
                            4 => {
                                switch (StructT.fields.len) {
                                    2 => return .vector2,
                                    4 => return .vector4,
                                    else => unreachable,
                                }
                            },
                            else => unreachable,
                        }
                    },
                    else => unreachable,
                }
            },
            .Int => {
                std.debug.assert(@sizeOf(T) == 4);
                return .color;
            },
            .Float => {
                std.debug.assert(@sizeOf(T) == 4);
                return .single;
            },
            else => unreachable,
        }
        return .single;
    }

    /// returns a []VertexElement for the type. usages should be the VertexElementUsage for each field in order
    fn vertexElementsForType(comptime T: type, usages: []fna.VertexElementUsage) ![]fna.VertexElement {
        var vert_elems = try aya.mem.allocator.alloc(fna.VertexElement, usages.len);
        inline for (@typeInfo(T).Struct.fields) |field, i| {
            vert_elems[i] = fna.VertexElement{
                .offset = @intCast(i32, field.offset.?),
                .vertexElementFormat = vertexFormatForType(field.field_type),
                .vertexElementUsage = usages[i],
                .usageIndex = 0,
            };
        }

        return vert_elems;
    }
};

pub const IndexBuffer = struct {
    buffer: ?*fna.Buffer = undefined,

    pub fn init() IndexBuffer {
        return IndexBuffer{};
    }

    pub fn deinit(self: IndexBuffer) void {
        fna.FNA3D_AddDisposeIndexBuffer(aya.gfx.device, self.buffer);
    }
};

test "test buffers" {
    _ = VertexBuffer.init(Vertex, 10, true);
    std.testing.expectEqual(VertexBuffer.vert_decl_cache.count(), 1);

    var usages = [_]fna.VertexElementUsage{ .position, .texture_coordinate, .color };
    var vert_decl = try VertexBuffer.vertexDeclarationForTypeUsages(Vertex, usages[0..]);
    std.testing.expectEqual(vert_decl.vertexStride, 20);
    std.testing.expectEqual(VertexBuffer.vert_decl_cache.count(), 1);

    const ele1 = vert_decl.elements[0];
    const ele2 = vert_decl.elements[1];
    const ele3 = vert_decl.elements[2];
    std.testing.expectEqual(ele1.offset, 0);
    std.testing.expectEqual(ele2.offset, 8);
    std.testing.expectEqual(ele3.offset, 16);
    std.testing.expectEqual(ele3.vertexElementFormat, .color);
}
