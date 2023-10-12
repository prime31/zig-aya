const std = @import("std");
const Builder = std.build.Builder;

// libs
const flecs_build = @import("libs/flecs/build.zig");
const stb_build = @import("libs/stb/build.zig");
const sdl_build = @import("libs/sdl/build.zig");
const imgui_build = @import("libs/imgui/build.zig");
const zig_gamedev_build = @import("libs/zig-gamedev/build.zig");
const sokol_build = @import("libs/sokol/build.zig");

const Options = struct {
    build_options: *std.build.Step.Options,
    enable_imgui: bool,
    include_flecs_explorer: bool,
};

const install_options: enum { all, only_current } = .only_current;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const options = Options{
        .build_options = b.addOptions(),
        .enable_imgui = b.option(bool, "enable_imgui", "Include/exclude Dear ImGui from the binary") orelse true,
        .include_flecs_explorer = b.option(bool, "include_flecs_explorer", "Include/exclude Flecs REST, HTTP, STATS and MONITOR modules") orelse true,
    };

    options.build_options.addOption(bool, "enable_imgui", options.enable_imgui);
    options.build_options.addOption(bool, "include_flecs_explorer", options.include_flecs_explorer);

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
    addExecutable(b, target, optimize, options, "app_pause", "examples/app_pause.zig");
    addExecutable(b, target, optimize, options, "app_phases", "examples/app_phases.zig");
    addExecutable(b, target, optimize, options, "app_sets", "examples/app_sets.zig");
    addExecutable(b, target, optimize, options, "app_custom_runner", "examples/app_custom_runner.zig");
    addExecutable(b, target, optimize, options, "app_multi_query_system", "examples/app_multi_query_system.zig");
    addExecutable(b, target, optimize, options, "app_window", "examples/app_window.zig");
    addExecutable(b, target, optimize, options, "app_input", "examples/app_input.zig");
    addExecutable(b, target, optimize, options, "app_input_gamepad", "examples/app_input_gamepad.zig");
    addExecutable(b, target, optimize, options, "app_gamepad_rumble", "examples/app_gamepad_rumble.zig");
    addExecutable(b, target, optimize, options, "ecs_exclusive_tag", "examples/ecs_exclusive_tag.zig");
    addExecutable(b, target, optimize, options, "world_subsystems", "examples/world_subsystems.zig");
    addExecutable(b, target, optimize, options, "systems_intervals", "examples/systems_intervals.zig");
    addExecutable(b, target, optimize, options, "gfx_clear", "examples/gfx_clear.zig");

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

    const run_cmd = b.addRunArtifact(exe);

    if (install_options == .only_current) {
        const add_install_step = b.addInstallArtifact(exe, .{});
        run_cmd.step.dependOn(&add_install_step.step);
    } else {
        b.installArtifact(exe);
        run_cmd.step.dependOn(b.getInstallStep());
    }

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
    flecs_build.linkArtifact(b, exe, target, optimize, options.include_flecs_explorer);

    stb_build.linkArtifact(exe);
    const stb_module = stb_build.getModule(b);

    sdl_build.linkArtifact(b, exe);
    const sdl_module = sdl_build.getModule(b, stb_module);

    if (options.enable_imgui)
        imgui_build.linkArtifact(b, exe, target, optimize, thisDir() ++ "/libs/sdl");
    const imgui_module = imgui_build.getModule(b, sdl_module, options.enable_imgui);

    zig_gamedev_build.linkArtifact(b, exe, target, optimize);
    const zmath_module = zig_gamedev_build.getMathModule(b);
    const zmesh_module = zig_gamedev_build.getMeshModule();

    const sokol_dep = b.dependency("sokol", .{
        .target = target,
        .optimize = optimize,
    });
    exe.linkLibrary(sokol_dep.artifact("sokol"));

    // macos metal helpers
    sokol_build.linkArtifact(exe);
    const sokol_module = sokol_build.getModule(b);

    // aya module gets all previous modules as dependencies
    const aya_module = b.createModule(.{
        .source_file = .{ .path = "src/aya.zig" },
        .dependencies = &.{
            .{ .name = "stb", .module = stb_module },
            .{ .name = "sdl", .module = sdl_module },
            .{ .name = "imgui", .module = imgui_module },
            .{ .name = "zmath", .module = zmath_module },
            .{ .name = "zmesh", .module = zmesh_module },
            .{ .name = "sokol", .module = sokol_dep.module("sokol") },
            .{ .name = "metal", .module = sokol_module },
            .{
                .name = "build_options",
                .module = b.createModule(.{
                    .source_file = options.build_options.getOutput(),
                }),
            },
        },
    });

    exe.addModule("aya", aya_module);
    exe.addModule("stb", stb_module);
    exe.addModule("sdl", sdl_module);
    exe.addModule("imgui", imgui_module);
    exe.addModule("zmath", zmath_module);
}

inline fn thisDir() []const u8 {
    return comptime std.fs.path.dirname(@src().file) orelse ".";
}
