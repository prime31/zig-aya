const std = @import("std");
const Builder = std.build.Builder;
const gpu = @import("mach_gpu");

pub var mach_module: *std.build.Module = undefined;

pub fn linkArtifact(b: *std.build, exe: *std.Build.Step.Compile, target: std.zig.CrossTarget, optimize: std.builtin.Mode) void {
    gpu.link(b, exe, .{}) catch unreachable;

    const mach_gpu_dep = b.dependency("mach_gpu", .{
        .target = target,
        .optimize = optimize,
    });

    mach_module = mach_gpu_dep.module("mach-gpu");
}

pub fn getModule(b: *std.Build, zpool: *std.build.Module, sdl: *std.build.Module) *std.build.Module {
    return b.createModule(.{
        .source_file = .{ .path = thisDir() ++ "/src/zgpu.zig" },
        .dependencies = &.{
            .{ .name = "zpool", .module = zpool },
            .{ .name = "sdl", .module = sdl },
            .{ .name = "mach_gpu", .module = mach_module },
        },
    });
}

inline fn thisDir() []const u8 {
    return comptime std.fs.path.dirname(@src().file) orelse ".";
}
