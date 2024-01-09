const std = @import("std");

pub fn linkArtifact(exe: *std.Build.Step.Compile) void {
    exe.linkLibC();
    exe.addIncludePath(.{ .path = thisDir() ++ "/libs" });

    exe.addCSourceFile(.{
        .file = .{ .path = thisDir() ++ "/libs/stb_impl.c" },
        .flags = &.{ "-std=c99", "-fno-sanitize=undefined" },
    });
}

pub fn getModule(b: *std.Build) *std.Build.Module {
    return b.createModule(.{ .root_source_file = .{ .path = thisDir() ++ "/src/stb.zig" } });
}

inline fn thisDir() []const u8 {
    return comptime std.fs.path.dirname(@src().file) orelse ".";
}
