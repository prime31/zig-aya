const std = @import("std");

const Allocator = std.mem.Allocator;

pub fn typeId(comptime T: type) usize {
    return @intFromPtr(&PerTypeGlobalStruct(T).unique_global);
}

fn PerTypeGlobalStruct(comptime _: type) type {
    return struct {
        pub var unique_global: u1 = 0;
    };
}

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
/// if T.init(Allocator) or T.deinit() exists it will be called
pub const ErasedPtr = struct {
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
                    if (@typeInfo(T) == .Struct)
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
