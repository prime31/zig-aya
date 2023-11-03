const std = @import("std");
const Builder = std.build.Builder;

// libs
const flecs_build = @import("libs/flecs/build.zig");
const stb_build = @import("libs/stb/build.zig");
const sdl_build = @import("libs/sdl/build.zig");
const imgui_build = @import("libs/imgui/build.zig");
const wgpu_build = @import("libs/wgpu/build.zig");
const zig_gamedev_build = @import("libs/zig-gamedev/build.zig");
const watcher_build = @import("libs/filewatcher/build.zig");

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

    for (getAllExamples(b, "examples")) |p| {
        addExecutable(b, target, optimize, options, p[0], p[1]);
    }

    addTests(b, target, optimize, options);

    flecs_build.addFlecsUpdateStep(b, target);
}

fn addExecutable(b: *std.build, target: std.zig.CrossTarget, optimize: std.builtin.OptimizeMode, options: Options, name: []const u8, source: []const u8) void {
    const exe = b.addExecutable(.{
        .name = name,
        .root_source_file = .{ .path = source },
        .target = target,
        .optimize = optimize,
    });

    if (exe.optimize == .ReleaseFast) exe.strip = true;

    linkLibs(b, exe, target, optimize, options);

    const run_cmd = b.addRunArtifact(exe);

    if (install_options == .only_current) {
        const add_install_step = b.addInstallArtifact(exe, .{});
        run_cmd.step.dependOn(&add_install_step.step);
    } else {
        b.installArtifact(exe);
        run_cmd.step.dependOn(b.getInstallStep());
    }

    var buffer: [100]u8 = undefined;
    const description = std.fmt.bufPrint(buffer[0..], "Run {s}", .{name}) catch unreachable;
    const run_step = b.step(name, description);
    run_step.dependOn(&run_cmd.step);
}

// add tests.zig file runnable via "zig build test"
fn addTests(b: *Builder, target: std.zig.CrossTarget, optimize: std.builtin.OptimizeMode, options: Options) void {
    const tests = b.addTest(.{
        .name = "tests",
        .root_source_file = .{ .path = "src/tests.zig" },
        .target = target,
        .optimize = optimize,
    });

    // in case tests start requiring some modules from libs add them here
    linkLibs(b, tests, target, optimize, options);

    const run_tests = b.addRunArtifact(tests);

    if (install_options == .only_current) {
        const add_install_step = b.addInstallArtifact(tests, .{});
        run_tests.step.dependOn(&add_install_step.step);
    } else {
        b.installArtifact(tests);
        run_tests.step.dependOn(b.getInstallStep());
    }

    const run_step = b.step("test", "Run tests");
    run_step.dependOn(&run_tests.step);
}

fn linkLibs(b: *std.build, exe: *std.Build.Step.Compile, target: std.zig.CrossTarget, optimize: std.builtin.OptimizeMode, options: Options) void {
    flecs_build.linkArtifact(b, exe, target, optimize, options.include_flecs_explorer);

    stb_build.linkArtifact(exe);
    const stb_module = stb_build.getModule(b);

    sdl_build.linkArtifact(b, exe);
    const sdl_module = sdl_build.getModule(b);

    zig_gamedev_build.linkArtifact(b, exe, target, optimize);
    const zmath_module = zig_gamedev_build.getMathModule(b);
    const zmesh_module = zig_gamedev_build.getMeshModule();
    const zpool_module = zig_gamedev_build.getPoolModule(b);

    watcher_build.linkArtifact(exe);
    const watcher_module = watcher_build.getModule(b);

    wgpu_build.linkArtifact(b, exe, target, optimize);
    const wgpu_module = wgpu_build.getModule(b, zpool_module, sdl_module);

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
            .{ .name = "zgpu", .module = wgpu_module },
            .{ .name = "zmath", .module = zmath_module },
            .{ .name = "zmesh", .module = zmesh_module },
            .{ .name = "zpool", .module = zpool_module },
            .{ .name = "watcher", .module = watcher_module },
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
    exe.addModule("zgpu", wgpu_module);
    exe.addModule("zmesh", zmesh_module);
    exe.addModule("watcher", watcher_module);
}

fn getAllExamples(b: *std.build.Builder, root_directory: []const u8) [][2][]const u8 {
    var list = std.ArrayList([2][]const u8).init(b.allocator);

    const recursor = struct {
        fn search(alloc: std.mem.Allocator, directory: []const u8, filelist: *std.ArrayList([2][]const u8)) void {
            if (std.mem.eql(u8, directory, "examples/assets") or std.mem.eql(u8, directory, "examples\\assets")) return;

            var dir = std.fs.cwd().openIterableDir(directory, .{}) catch unreachable;
            defer dir.close();

            var iter = dir.iterate();
            while (iter.next() catch unreachable) |entry| {
                if (entry.kind == .file) {
                    if (std.mem.endsWith(u8, entry.name, ".zig")) {
                        const abs_path = std.fs.path.join(alloc, &[_][]const u8{ directory, entry.name }) catch unreachable;
                        const name = std.fs.path.basename(abs_path);

                        // if in a subfolder, prefix the exe name with `folder_`
                        const name_prefix = if (std.mem.indexOf(u8, directory, std.fs.path.sep_str)) |index| blk: {
                            break :blk std.fmt.allocPrint(alloc, "{s}_", .{directory[index + 1 ..]}) catch unreachable;
                        } else "";

                        const exe_name = std.fmt.allocPrint(alloc, "{s}{s}", .{ name_prefix, name[0 .. name.len - 4] }) catch unreachable;
                        filelist.append([2][]const u8{ exe_name, abs_path }) catch unreachable;
                    }
                } else if (entry.kind == .directory) {
                    const abs_path = std.fs.path.join(alloc, &[_][]const u8{ directory, entry.name }) catch unreachable;
                    search(alloc, abs_path, filelist);
                }
            }
        }
    }.search;

    recursor(b.allocator, root_directory, &list);

    return list.toOwnedSlice() catch unreachable;
}

inline fn thisDir() []const u8 {
    return comptime std.fs.path.dirname(@src().file) orelse ".";
}
