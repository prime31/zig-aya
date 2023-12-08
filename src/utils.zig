const std = @import("std");
const aya = @import("aya.zig");

pub fn typeId(comptime T: type) usize {
    return @intFromPtr(&PerTypeGlobalStruct(T).unique_global);
}

fn PerTypeGlobalStruct(comptime _: type) type {
    return struct {
        pub var unique_global: u1 = 0;
    };
}

/// returns a slice of a typename but only the last component (ex. std.HashMap would return HashMap)
pub fn typeNameLastComponent(comptime T: type) [:0]const u8 {
    const name = @typeName(T);
    const last_dot = if (std.mem.lastIndexOf(u8, name, ".")) |index| index + 1 else 0;
    return name[last_dot..];
}

/// comptime string hashing for type names
pub fn hashTypeName(comptime T: type) u32 {
    return hashStringFnv(u32, @typeName(T));
}

/// Fowler–Noll–Vo string hash. ReturnType should be u32/u64
pub fn hashStringFnv(comptime ReturnType: type, comptime str: []const u8) ReturnType {
    std.debug.assert(ReturnType == u32 or ReturnType == u64);

    const prime = if (ReturnType == u32) @as(u32, 16777619) else @as(u64, 1099511628211);
    var value = if (ReturnType == u32) @as(u32, 2166136261) else @as(u64, 14695981039346656037);
    for (str) |c| {
        value = (value ^ @as(u32, @intCast(c))) *% prime;
    }
    return value;
}

/// stores all resources as erased pointers but retains the ability to deinit them safely via a closure.
/// if T.deinit() exists it will be called
pub const ErasedPtr = struct {
    ptr: usize,
    deinit: *const fn (*ErasedPtr) void,

    pub fn init(comptime T: type) ErasedPtr {
        const res = aya.mem.create(T);
        res.* = if (@hasDecl(T, "init")) T.init(aya.mem.allocator) else std.mem.zeroes(T);
        return initWithPtr(T, @intFromPtr(res));
    }

    pub fn initWithPtr(comptime T: type, ptr: usize) ErasedPtr {
        return .{
            .ptr = ptr,
            .deinit = struct {
                fn deinit(self: *ErasedPtr) void {
                    const res = self.asPtr(T);
                    if (@typeInfo(T) == .Struct)
                        if (@hasDecl(T, "deinit")) res.deinit();
                    aya.mem.destroy(res);
                }
            }.deinit,
        };
    }

    pub fn asPtr(self: ErasedPtr, comptime T: type) *T {
        return @as(*T, @ptrFromInt(self.ptr));
    }
};

pub const ErasedPlugin = struct {
    ptr: usize,
    finish: *const fn (ErasedPlugin, app: *aya.App) void,

    pub fn init(instance: anytype) ErasedPlugin {
        const T = @TypeOf(instance);
        std.debug.assert(@typeInfo(T) == .Struct);

        const res = aya.mem.create(T);
        res.* = instance;

        return .{
            .ptr = @intFromPtr(res),
            .finish = struct {
                fn finish(self: ErasedPlugin, app: *aya.App) void {
                    const plugin = @as(*T, @ptrFromInt(self.ptr));
                    plugin.finish(app);

                    if (@hasDecl(T, "deinit")) plugin.deinit();
                    aya.mem.destroy(plugin);
                }
            }.finish,
        };
    }
};

pub fn Vec(comptime T: type) type {
    return struct {
        const Self = @This();

        list: std.ArrayListUnmanaged(T),

        pub fn init() Self {
            return .{ .list = std.ArrayListUnmanaged(T).initCapacity(aya.mem.allocator, 0) };
        }

        pub fn initCapacity(num: usize) Self {
            return .{ .list = std.ArrayListUnmanaged(T).initCapacity(aya.mem.allocator, num) };
        }

        pub fn deinit(self: *Self) void {
            self.list.deinit(aya.mem.allocator);
        }

        pub fn insert(self: *Self, n: usize, item: T) void {
            self.list.insert(aya.mem.allocator, n, item) catch unreachable;
        }

        pub fn insertSlice(self: *Self, index: usize, items: []const T) void {
            self.list.insertSlice(aya.mem.allocator, index, items) catch unreachable;
        }

        pub fn append(self: *Self, item: T) void {
            self.list.append(aya.mem.allocator, item) catch unreachable;
        }

        pub fn swapRemove(self: *Self, i: usize) T {
            return self.list.swapRemove(i);
        }

        pub fn appendSlice(self: *Self, items: []const T) void {
            self.list.appendSlice(aya.mem.allocator, items) catch unreachable;
        }

        pub fn slice(self: *Self) []T {
            return self.list.items;
        }

        pub fn writer(self: *Self) std.ArrayListUnmanaged(T).Writer {
            return self.list.writer(aya.mem.allocator);
        }

        pub fn clearRetainingCapacity(self: *Self) void {
            self.list.clearRetainingCapacity();
        }

        pub fn clearAndFree(self: *Self) void {
            self.list.clearAndFree(aya.mem.allocator);
        }

        pub fn ensureTotalCapacity(self: *Self, new_capacity: usize) void {
            self.list.ensureTotalCapacity(aya.mem.allocator, new_capacity) catch unreachable;
        }

        pub fn expandToCapacity(self: *Self) void {
            self.list.expandToCapacity();
        }

        pub fn pop(self: *Self) T {
            return self.pop();
        }

        pub fn popOrNull(self: *Self) ?T {
            return self.popOrNull();
        }

        pub fn getLast(self: Self) T {
            return self.getLast();
        }

        pub fn getLastOrNull(self: Self) ?T {
            return self.getLastOrNull();
        }
    };
}
