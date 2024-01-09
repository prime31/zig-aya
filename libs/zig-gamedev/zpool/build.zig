const std = @import("std");

pub const Package = struct {
    zpool: *std.Build.Module,

    pub fn link(pkg: Package, exe: *std.Build.Step.Compile) void {
        exe.addModule("zpool", pkg.zpool);
    }
};

pub fn package(
    b: *std.Build,
    _: std.Build.ResolvedTarget,
    _: std.builtin.Mode,
    _: struct {},
) Package {
    const zpool = b.createModule(.{
        .source_file = .{ .path = thisDir() ++ "/src/main.zig" },
    });
    return .{ .zpool = zpool };
}

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    const test_step = b.step("test", "Run zpool tests");
    test_step.dependOn(runTests(b, optimize, target));
}

pub fn runTests(
    b: *std.Build,
    optimize: std.builtin.Mode,
    target: std.Build.ResolvedTarget,
) *std.Build.Step {
    const tests = b.addTest(.{
        .name = "zpool-tests",
        .root_source_file = .{ .path = thisDir() ++ "/src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    return &b.addRunArtifact(tests).step;
}

pub fn getModule(b: *std.Build) *std.Build.Module {
    return b.createModule(.{
        .root_source_file = .{ .path = thisDir() ++ "/src/main.zig" },
    });
}

inline fn thisDir() []const u8 {
    return comptime std.fs.path.dirname(@src().file) orelse ".";
}
