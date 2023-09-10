const std = @import("std");

pub fn typeId(comptime T: type) usize {
    return @intFromPtr(&TypeIdStruct(T).unique_global);
}

pub fn TypeIdStruct(comptime _: type) type {
    return struct {
        pub var unique_global: u8 = 0;
    };
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
