const std = @import("std");
const fna = @import("../deps/fna/fna.zig");
const aya = @import("../aya.zig");
const gfx = @import("gfx.zig");
const Vec2 = @import("../math/vec2.zig").Vec2;

pub const Vertex = packed struct {
    pos: Vec2,
    uv: Vec2,
    col: u32 = 0xFFFFFFFF,
};

pub const VertexPositionColor = packed struct {
    pos: Vec2,
    col: u32 = 0xFFFFFFFF,
};

pub const VertexBuffer = struct {
    buffer: ?*fna.Buffer = undefined,

    var vert_decl_cache = std.StringHashMap(fna.VertexDeclaration).init(aya.mem.allocator);

    pub fn init(comptime T: type, vertex_count: i32, dynamic: bool) VertexBuffer {
        const vert_decl = vertexDeclarationForType(T) catch unreachable;
        return VertexBuffer{
            .buffer = aya.gfx.device.genVertexBuffer(dynamic, .write_only, vertex_count, vert_decl.vertexStride),
        };
    }

    pub fn initWithOptions(comptime T: type, vertex_count: i32, dynamic: bool, usages: []fna.VertexElementUsage) VertexBuffer {
        const vert_decl = blk: {
            if (vert_decl_cache.getValue(@typeName(T))) |decl| {
                break :blk decl;
            } else {
                const vd = vertexDeclarationForTypeUsages(T, usages) catch unreachable;
                _ = vert_decl_cache.put(@typeName(T), vd) catch |err| std.debug.warn("failed caching vertex declartion: {}\n", .{err});
                break :blk vd;
            }
        };

        return VertexBuffer{
            .buffer = aya.gfx.device.genVertexBuffer(dynamic, .write_only, vertex_count, vert_decl.vertexStride),
        };
    }

    pub fn deinit(self: VertexBuffer) void {
        aya.gfx.device.addDisposeVertexBuffer(self.buffer);
    }

    pub fn setData(self: VertexBuffer, comptime T: type, data: []T, offset_in_bytes: i32, options: fna.SetDataOptions) void {
        aya.gfx.device.setVertexBufferData(T, self.buffer, data, offset_in_bytes, options);
    }

    pub fn vertexDeclarationForType(comptime T: type) !fna.VertexDeclaration {
        if (vert_decl_cache.getValue(@typeName(T))) |decl| return decl;

        const vert_decl = switch (T) {
            Vertex => blk: {
                var usages = [_]fna.VertexElementUsage{ .position, .texture_coordinate, .color };
                break :blk try VertexBuffer.vertexDeclarationForTypeUsages(T, usages[0..]);
            },
            VertexPositionColor => blk: {
                var usages = [_]fna.VertexElementUsage{ .position, .color };
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
            .Array => |info| {
                switch (@typeInfo(info.child)) {
                    .Float => |flt_info| {
                        switch (@divExact(flt_info.bits, 8)) {
                            2 => {
                                switch (info.len) {
                                    2 => return .half_vector2,
                                    4 => return .half_vector4,
                                    else => unreachable,
                                }
                            },
                            4 => {
                                switch (info.len) {
                                    2 => return .vector2,
                                    3 => return .vector3,
                                    4 => return .vector4,
                                    else => unreachable,
                                }
                            },
                            else => unreachable,
                        }
                    },
                    .Int => |int_info| {
                        std.debug.assert(info.len == 2 or info.len == 4);
                        switch (@divExact(int_info.bits, 8)) {
                            2 => {
                                switch (info.len) {
                                    2 => return .short2,
                                    4 => return .short4,
                                    else => unreachable,
                                }
                            },
                            else => unreachable,
                        }
                    },
                    else => unreachable,
                }
            },
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

    pub fn init(index_count: i32, dynamic: bool) IndexBuffer {
        return initWithOptions(index_count, dynamic, .write_only, .sixteen_bit);
    }

    pub fn initWithOptions(index_count: i32, dynamic: bool, usage: fna.BufferUsage, index_ele_size: fna.IndexElementSize) IndexBuffer {
        return IndexBuffer{
            .buffer = aya.gfx.device.genIndexBuffer(dynamic, usage, index_count, index_ele_size),
        };
    }

    pub fn deinit(self: IndexBuffer) void {
        aya.gfx.device.addDisposeIndexBuffer(self.buffer);
    }

    pub fn setData(self: IndexBuffer, comptime T: type, data: []T, offset_in_bytes: i32, options: fna.SetDataOptions) void {
        const elem_size = @intCast(i32, @sizeOf(T));
        aya.gfx.device.setIndexBufferData(self.buffer, offset_in_bytes, &data[0], elem_size * @intCast(i32, data.len), options);
    }
};

test "test index buffers" {
    const ibuff = IndexBuffer.init(3, true);
}

test "test vertex buffers" {
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

    const VertexArr = struct {
        pos: [2]f32,
        uv: [2]f32,
        col: u32 = 0xFFFFFFFF,
    };
    _ = VertexBuffer.initWithOptions(VertexArr, 10, false, usages[0..]);
    std.testing.expectEqual(VertexBuffer.vert_decl_cache.count(), 2);

    _ = VertexBuffer.initWithOptions(VertexArr, 10, false, usages[0..]);
    std.testing.expectEqual(VertexBuffer.vert_decl_cache.count(), 2);
}
