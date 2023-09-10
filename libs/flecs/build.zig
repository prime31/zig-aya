const std = @import("std");
const Builder = std.build.Builder;

// UPDATING FLECS
// - copy flecs.c and flecs.h
// - zig translate-c flecs.h > flecs.zig

pub fn linkArtifact(b: *std.build, exe: *std.Build.Step.Compile, target: std.zig.CrossTarget, optimize: std.builtin.Mode) void {
    exe.addIncludePath(.{ .path = thisDir() ++ "/libs" });
    exe.linkLibrary(buildStaticLibrary(b, target, optimize));
}

fn buildStaticLibrary(b: *std.build, target: std.zig.CrossTarget, optimize: std.builtin.Mode) *std.Build.CompileStep {
    const lib = b.addStaticLibrary(.{
        .name = "zflecs",
        .target = target,
        .optimize = optimize,
    });
    lib.linkLibC();
    lib.addIncludePath(.{ .path = thisDir() ++ "/libs" });
    lib.addCSourceFile(.{
        .file = .{ .path = thisDir() ++ "/libs/flecs.c" },
        .flags = &.{
            "-fno-sanitize=undefined",
            "-DFLECS_NO_CPP",
            "-DFLECS_USE_OS_ALLOC",
            if (@import("builtin").mode == .Debug) "-DFLECS_SANITIZE" else "",
        },
    });

    if (lib.target.isWindows())
        lib.linkSystemLibraryName("ws2_32");

    return lib;
}

// doesn't yet work with zls so for now we manually generate the file
fn addTranslateCStep(b: *std.build, target: std.zig.CrossTarget, optimize: std.builtin.Mode) void {
    const trans_c = b.addTranslateC(.{
        .source_file = .{ .path = thisDir() ++ "/libs/flecs.h" },
        .target = target,
        .optimize = optimize,
    });
    trans_c.c_macros.append("FLECS_NO_CPP") catch unreachable;
    trans_c.c_macros.append("FLECS_USE_OS_ALLOC") catch unreachable;
    if (@import("builtin").mode == .Debug)
        trans_c.c_macros.append("FLECS_SANITIZE") catch unreachable;

    // const module = b.createModule(.{ .source_file = trans_c.getOutput() });
}

pub fn addFlecsUpdateStep(b: *std.build, target: std.zig.CrossTarget) void {
    // only mac and linux get the update_flecs command
    if (!target.isWindows()) {
        var exe = b.addSystemCommand(&[_][]const u8{ "zsh", thisDir() ++ "/update_flecs.sh" });
        exe.addArg(thisDir());

        const exe_step = b.step("update_flecs", b.fmt("updates Flecs.h/c and runs translate-c", .{}));
        exe_step.dependOn(&exe.step);
    }

    // TODO: write some sort of cleanup function if we end up updating flecs too often
}

pub fn getModule(b: *std.Build) *std.build.Module {
    return b.createModule(.{
        .source_file = .{ .path = thisDir() ++ "/src/ecs.zig" },
    });
}

inline fn thisDir() []const u8 {
    return comptime std.fs.path.dirname(@src().file) orelse ".";
}
