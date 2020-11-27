const builtin = @import("builtin");
const std = @import("std");
const Builder = std.build.Builder;

pub fn build(b: *Builder) void {
    const exe = b.addStaticLibrary("JunkLib", null);
    linkArtifact(b, exe, b.standardTargetOptions(.{}));
    exe.install();
}

/// prefix_path is used to add package paths. It should be the the same path used to include this build file
pub fn linkArtifact(b: *Builder, exe: *std.build.LibExeObjStep, target: std.build.Target, comptime prefix_path: []const u8) void {
    if (prefix_path.len > 0 and !std.mem.endsWith(u8, prefix_path, "/")) @panic("prefix-path must end with '/' if it is not empty");
    exe.addPackage(getPackage(prefix_path));
    exe.linkLibC();

    const lib_cflags = &[_][]const u8{"-O3"};
    exe.addCSourceFile(prefix_path ++ "aya/deps/fontstash/src/fontstash.c", lib_cflags);
}

pub fn getPackage(comptime prefix_path: []const u8) std.build.Pkg {
    return .{
        .name = "fontstash",
        .path = prefix_path ++ "aya/deps/fontstash/fontstash.zig",
    };
}
