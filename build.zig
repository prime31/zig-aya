const std = @import("std");
const Builder = std.build.Builder;

// libs
const flecs_build = @import("libs/flecs/build.zig");
const stb_build = @import("libs/stb/build.zig");
const sdl_build = @import("libs/sdl/build.zig");
const imgui_build = @import("libs/imgui/build.zig");

const Options = struct {
    enable_imgui: bool,
};

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const options = Options{
        .enable_imgui = b.option(bool, "enable_imgui", "Include/exclude Dear ImGui from the binary") orelse true,
    };

    // const exe = b.addExecutable(.{
    //     .name = "sdl3-tester",
    //     .root_source_file = .{ .path = "src/main.zig" },
    //     .target = target,
    //     .optimize = optimize,
    // });

    // const aya_module = b.createModule(.{
    //     .source_file = .{ .path = "src/aya.zig" },
    // });
    // exe.addModule("aya", aya_module);

    // // libs
    // sdl_build.linkArtifact(exe);
    // const sdl_module = sdl_build.getModule(b);
    // exe.addModule("sdl", sdl_module);

    // // This declares intent for the executable to be installed into the
    // // standard location when the user invokes the "install" step (the default
    // // step when running `zig build`).
    // b.installArtifact(exe);

    // // This *creates* a Run step in the build graph, to be executed when another
    // // step is evaluated that depends on it. The next line below will establish
    // // such a dependency.
    // const run_cmd = b.addRunArtifact(exe);

    // // By making the run step depend on the install step, it will be run from the
    // // installation directory rather than directly from within the cache directory.
    // // This is not necessary, however, if the application depends on other installed
    // // files, this ensures they will be present and in the expected location.
    // run_cmd.step.dependOn(b.getInstallStep());

    // // This creates a build step. It will be visible in the `zig build --help` menu,
    // // and can be selected like this: `zig build run`
    // // This will evaluate the `run` step rather than the default, which is "install".
    // const run_step = b.step("sdl3-tester", "Run sdl3-tester");
    // run_step.dependOn(&run_cmd.step);

    addExecutable(b, target, optimize, options, "sdl3_gpu", "examples/sdl_gpu.zig");
    addExecutable(b, target, optimize, options, "tester", "examples/tester.zig");
    addExecutable(b, target, optimize, options, "app_init", "examples/app_init.zig");
    addExecutable(b, target, optimize, options, "app_events", "examples/app_events.zig");
    addExecutable(b, target, optimize, options, "app_locals", "examples/app_locals.zig");
    addExecutable(b, target, optimize, options, "app_states", "examples/app_states.zig");
    addExecutable(b, target, optimize, options, "world_subsystems", "examples/world_subsystems.zig");

    addTests(b, target, optimize);

    flecs_build.addFlecsUpdateStep(b, target);
}

fn addExecutable(b: *std.build, target: std.zig.CrossTarget, optimize: std.builtin.OptimizeMode, options: Options, comptime name: []const u8, source: []const u8) void {
    const exe = b.addExecutable(.{
        .name = name,
        .root_source_file = .{ .path = source },
        .target = target,
        .optimize = optimize,
    });

    linkLibs(b, exe, target, optimize, options);

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step(name, "Run '" ++ name ++ "'");
    run_step.dependOn(&run_cmd.step);
}

// add tests.zig file runnable via "zig build test"
fn addTests(b: *Builder, target: std.zig.CrossTarget, optimize: std.builtin.OptimizeMode) void {
    const tests = b.addTest(.{
        .name = "tests",
        .root_source_file = .{ .path = "src/tests.zig" },
        .target = target,
        .optimize = optimize,
    });

    // in case tests start requiring some modules from libs add them here
    // linkLibs(b, tests, target, optimize);

    const run_tests = b.addRunArtifact(tests);
    const run_step = b.step("test", "Run tests");
    run_step.dependOn(&run_tests.step);
}

fn linkLibs(b: *std.build, exe: *std.Build.Step.Compile, target: std.zig.CrossTarget, optimize: std.builtin.OptimizeMode, options: Options) void {
    flecs_build.linkArtifact(b, exe, target, optimize);
    // const flecs_module = flecs_build.getModule(b);

    stb_build.linkArtifact(exe);
    const stb_module = stb_build.getModule(b);

    sdl_build.linkArtifact(b, exe);
    const sdl_module = sdl_build.getModule(b, stb_module);

    if (options.enable_imgui)
        imgui_build.linkArtifact(b, exe, target, optimize, thisDir() ++ "/libs/sdl");
    const imgui_module = imgui_build.getModule(b, sdl_module, options.enable_imgui);

    // aya module gets all previous modules as dependencies
    const aya_module = b.createModule(.{
        .source_file = .{ .path = "src/aya.zig" },
        .dependencies = &.{
            .{ .name = "stb", .module = stb_module },
            .{ .name = "sdl", .module = sdl_module },
            .{ .name = "imgui", .module = imgui_module },
        },
    });

    exe.addModule("aya", aya_module);
    exe.addModule("stb", stb_module);
    exe.addModule("sdl", sdl_module);
    exe.addModule("imgui", imgui_module);
}

inline fn thisDir() []const u8 {
    return comptime std.fs.path.dirname(@src().file) orelse ".";
}
