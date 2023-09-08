const std = @import("std");
const typeId = @import("../type_id.zig").typeId;

const Allocator = std.mem.Allocator;

/// Resources are globally unique objects that are stored outside of the ECS. One per type can be stored. Resource
/// types can optionally implement 2 methods: init(Allocator) Self and deinit(Self). If they are present they will be
/// called.
pub const Resources = struct {
    const Self = @This();

    allocator: Allocator,
    resources: std.AutoHashMap(usize, ErasedPtr),

    /// stores all resources as erased pointers but retains the ability to deinit them safely via a closure.
    /// if T.init(Allocator) or T.deinit() exists it will be called
    const ErasedPtr = struct {
        ptr: usize,
        deinit: *const fn (ErasedPtr, Allocator) void,

        pub fn init(comptime T: type, allocator: Allocator) ErasedPtr {
            const res = allocator.create(T) catch unreachable;
            res.* = if (@hasDecl(T, "init")) T.init(allocator) else std.mem.zeroes(T);
            return initWithPtr(T, @intFromPtr(res));
        }

        pub fn initWithPtr(comptime T: type, ptr: usize) ErasedPtr {
            return .{
                .ptr = ptr,
                .deinit = struct {
                    fn deinit(self: ErasedPtr, allocator: Allocator) void {
                        const res = self.asPtr(T);
                        if (@hasDecl(T, "deinit")) res.deinit();
                        allocator.destroy(res);
                    }
                }.deinit,
            };
        }

        pub fn asPtr(self: ErasedPtr, comptime T: type) *T {
            return @as(*T, @ptrFromInt(self.ptr));
        }
    };

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

    pub fn contains(self: *Self, comptime T: type) bool {
        return self.resources.contains(typeId(T));
    }

    /// Resource types can have an optional init(Allocator) method that will be called if present. If not, they
    /// will be zeroInit'ed
    pub fn initResource(self: *Self, comptime T: type) *T {
        const res = self.allocator.create(T) catch unreachable;
        res.* = if (@hasDecl(T, "init")) T.init(self.allocator) else std.mem.zeroes(T);

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
        if (self.resources.get(typeId(T))) |res| {
            return res.asPtr(T);
        }
        return null;
    }

    pub fn remove(self: *Self, comptime T: type) void {
        if (self.resources.fetchRemove(typeId(T))) |kv| {
            kv.value.deinit(kv.value, self.allocator);
        }
    }
};
