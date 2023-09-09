pub fn typeId(comptime T: type) usize {
    return @intFromPtr(&TypeIdStruct(T).unique_global);
}

pub fn TypeIdStruct(comptime _: type) type {
    return struct {
        pub var unique_global: u8 = 0;
    };
}
