const std = @import("std");
const aya = @import("../aya.zig");

const typeId = aya.utils.typeId;

const Allocator = std.mem.Allocator;
const ErasedPtr = aya.utils.ErasedPtr;

pub fn Res(comptime T: type) type {
    return struct {
        pub const res_type = T;
        const Self = @This();

        resource: ?*const T,

        pub fn get(self: Self) ?*const T {
            return self.resource;
        }
    };
}

pub fn ResMut(comptime T: type) type {
    return struct {
        pub const res_mut_type = T;
        const Self = @This();

        resource: ?*T,

        pub fn get(self: Self) ?*T {
            return self.resource;
        }

        pub fn getAssertContains(self: Self) *T {
            std.debug.assert(self.resource != null);
            return self.resource.?;
        }
    };
}

/// Resources are globally unique objects that are stored outside of the ECS. One per type can be stored. Resource
/// types can optionally implement 2 methods: init(Allocator) Self and deinit(Self). If they are present they will be
/// called.
pub const Resources = struct {
    const Self = @This();

    allocator: Allocator,
    resources: std.AutoHashMap(usize, ErasedPtr),

    pub fn init(allocator: Allocator) Self {
        return .{
            .allocator = allocator,
            .resources = std.AutoHashMap(usize, ErasedPtr).init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        var iter = self.resources.iterator();
        while (iter.next()) |entry| entry.value_ptr.deinit(entry.value_ptr.*, self.allocator);
        self.resources.deinit();
    }

    pub fn contains(self: Self, comptime T: type) bool {
        return self.resources.contains(typeId(T));
    }

    /// Resource types can have an optional init() or init(Allocator) method that will be called if present. If not, they
    /// will be zeroInit'ed
    pub fn initResource(self: *Self, comptime T: type) *T {
        const res = self.allocator.create(T) catch unreachable;

        if (@typeInfo(T) == .Struct) {
            res.* = if (@hasDecl(T, "init")) blk: {
                const params = @typeInfo(@TypeOf(T.init)).Fn.params;
                if (params.len == 0) break :blk T.init();
                if (params.len == 1 and params[0].type.? == std.mem.Allocator) break :blk T.init(self.allocator);
                @compileError("Resources with init method must be init() or init(Allocator). " ++ @typeName(T) ++ " has neither");
            } else {
                std.mem.zeroes(T);
            };
        } else {
            res.* = std.mem.zeroes(T);
        }

        self.resources.put(typeId(T), ErasedPtr.initWithPtr(T, @intFromPtr(res))) catch unreachable;
        return res;
    }

    /// Insert a resource that already exists. Resource should be a stack allocated struct. It will be heap allocated
    /// and assigned for storage.
    pub fn insert(self: *Self, resource: anytype) void {
        const T = @TypeOf(resource);
        std.debug.assert(@typeInfo(T) != .Pointer);

        const res = self.allocator.create(T) catch unreachable;
        res.* = resource;
        self.resources.put(typeId(T), ErasedPtr.initWithPtr(T, @intFromPtr(res))) catch unreachable;
    }

    pub fn get(self: Self, comptime T: type) ?*T {
        const res = self.resources.get(typeId(T)) orelse return null;
        return res.asPtr(T);
    }

    pub fn remove(self: *Self, comptime T: type) void {
        if (self.resources.fetchRemove(typeId(T))) |kv| {
            kv.value.deinit(kv.value, self.allocator);
        }
    }
};
