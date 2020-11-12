const builtin = @import("builtin");
const std = @import("std");
const Builder = std.build.Builder;

pub fn build(b: *Builder) void {
    const exe = b.addStaticLibrary("JunkLib", null);
    linkArtifact(b, exe, b.standardTargetOptions(.{}), .static, "");
    exe.install();
}

pub fn linkArtifact(b: *Builder, exe: *std.build.LibExeObjStep, target: std.build.Target, comptime prefix_path: []const u8) void {
    exe.addPackage(getPackage(prefix_path));

    exe.linkLibC();
    exe.addIncludeDir(prefix_path ++ "aya/deps/stb/src");

    const lib_cflags = &[_][]const u8{ "-std=c99", "-O3" };
    exe.addCSourceFile(prefix_path ++ "aya/deps/stb/src/stb_image_impl.c", lib_cflags);
}

pub fn getPackage(comptime prefix_path: []const u8) std.build.Pkg {
    return .{
        .name = "stb",
        .path = prefix_path ++ "aya/deps/stb/stb.zig",
    };
}
