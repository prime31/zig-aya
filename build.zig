const std = @import("std");
const Builder = std.build.Builder;

// libs
const flecs_build = @import("libs/flecs/build.zig");
const stb_build = @import("libs/stb/build.zig");
const zgui_build = @import("libs/zgui/build.zig");
const zig_gamedev_build = @import("libs/zig-gamedev/build.zig");

const Options = struct {
    build_options: *std.build.Step.Options,
    enable_imgui: bool,
    include_flecs_explorer: bool,
};

const install_options: enum { all, only_current } = .only_current;

pub fn build(b: *std.Build) !void {
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
        try addExecutable(b, target, optimize, options, p[0], p[1]);
    }
    try addExecutable(b, target, optimize, options, "shit", "examples/app/locals.zig");

    addTests(b, target, optimize);

    flecs_build.addFlecsUpdateStep(b, target);
}

fn addExecutable(b: *std.build, target: std.zig.CrossTarget, optimize: std.builtin.OptimizeMode, options: Options, name: []const u8, source: []const u8) !void {
    const mach_core_dep = b.dependency("mach_core", .{
        .target = target,
        .optimize = optimize,
    });

    // gather modules
    zig_gamedev_build.prepare(b, target, optimize);
    const stb_module = stb_build.getModule(b);
    const zmath_module = zig_gamedev_build.getMathModule(b);
    const zmesh_module = zig_gamedev_build.getMeshModule();
    const zgui_module = zgui_build.getModule(b, mach_core_dep.module("mach-core"), options.enable_imgui);

    const glfw_dep = b.dependency("mach_glfw", .{
        .target = target,
        .optimize = optimize,
    });

    // aya module gets all previous modules as dependencies
    const aya_module = b.createModule(.{
        .source_file = .{ .path = "src/aya.zig" },
        .dependencies = &.{
            .{ .name = "stb", .module = stb_module },
            .{ .name = "zgui", .module = zgui_module },
            .{ .name = "zmath", .module = zmath_module },
            .{ .name = "zmesh", .module = zmesh_module },
            .{ .name = "mach-core", .module = mach_core_dep.module("mach-core") },
            .{ .name = "mach-glfw", .module = glfw_dep.module("mach-glfw") },
            .{
                .name = "build_options",
                .module = b.createModule(.{
                    .source_file = options.build_options.getOutput(),
                }),
            },
        },
    });

    const native_target = (try std.zig.system.NativeTargetInfo.detect(target)).target;
    const app = try @import("mach_core").App.init(b, mach_core_dep.builder, .{
        .name = name,
        .src = source,
        .target = target,
        .deps = &.{
            .{ .name = "zgui", .module = zgui_module },
            .{ .name = "aya", .module = aya_module },
        },
        .optimize = optimize,
        .custom_entrypoint = if (native_target.cpu.arch != .wasm32) thisDir() ++ "/src/mach_main.zig" else null,
    });

    app.compile.addModule("aya", aya_module);

    // link all libs
    flecs_build.linkArtifact(b, app.compile, target, optimize, options.include_flecs_explorer);
    stb_build.linkArtifact(app.compile);
    zig_gamedev_build.linkArtifact(app.compile);
    if (options.enable_imgui)
        zgui_build.linkArtifact(b, app.compile, target, optimize);

    const run_cmd = b.addRunArtifact(app.compile);

    if (install_options == .only_current) {
        const add_install_step = b.addInstallArtifact(app.compile, .{});
        run_cmd.step.dependOn(&add_install_step.step);
    } else {
        b.installArtifact(app.compile);
        run_cmd.step.dependOn(b.getInstallStep());
    }

    var buffer: [100]u8 = undefined;
    const description = std.fmt.bufPrint(buffer[0..], "Run {s}", .{name}) catch unreachable;
    const run_step = b.step(name, description);
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
