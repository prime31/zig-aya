const builtin = @import("builtin");
const std = @import("std");
const Builder = std.build.Builder;
const fna_build = @import("deps/fna/build.zig");

pub fn build(b: *Builder) void {
    const target = b.standardTargetOptions(.{});

    // windows static lib compilation of FNA causes an SDL header issue so its forced as exe_compiled
    const lib_type_int = b.option(i32, "lib_type", "0: static, 1: dynamic, 2: exe compiled") orelse 0;
    const lib_type = if (target.isWindows()) .exe_compiled else @intToEnum(fna_build.LibType, lib_type_int);

    const exe = b.addExecutable("aya", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(b.standardReleaseOptions());

    // fna can be dynamic, static or compiled in
    fna_build.linkArtifact(b, exe, target, lib_type);
    // fna_build.compileFna(b, exe, target);

    exe.linkSystemLibrary("c");
    exe.linkSystemLibrary("SDL2");
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    addTests(b, target);
}

fn addTests(b: *Builder, target: std.build.Target) void {
    var t = b.addTest("src/test.zig");
    fna_build.linkArtifact(b, t, target, .exe_compiled);

    t.linkSystemLibrary("c");
    t.linkSystemLibrary("SDL2");

    const test_step = b.step("test", "Run tests in test.zig");
    test_step.dependOn(&t.step);
}
