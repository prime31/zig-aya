const std = @import("std");
const Builder = std.build.Builder;

pub fn linkArtifact(exe: *std.Build.Step.Compile) void {
    if (@import("builtin").os.tag == .macos) {
        exe.linkFramework("MetalKit");
        exe.linkFramework("Metal");
        exe.linkFramework("Cocoa");

        exe.addIncludePath(.{ .path = thisDir() ++ "/lib" });
        exe.addIncludePath(.{ .path = thisDir() ++ "/../sdl/SDL3" });

        exe.addCSourceFile(.{
            .file = .{ .path = thisDir() ++ "/lib/metal_util.c" },
            .flags = &.{ "-DSOKOL_METAL", "-ObjC" },
        });
    }
}

pub fn getModule(b: *std.Build) *std.build.Module {
    return b.createModule(.{ .source_file = .{ .path = thisDir() ++ "/src/metal_util.zig" } });
}

inline fn thisDir() []const u8 {
    return comptime std.fs.path.dirname(@src().file) orelse ".";
}
