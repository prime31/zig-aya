const std = @import("std");

const wgpu_build = @import("libs/wgpu/build.zig");
const sdl_build = @import("libs/sdl/build.zig");
const stb_build = @import("libs/stb/build.zig");
const imgui_build = @import("libs/imgui/build.zig");
const zig_gamedev_build = @import("libs/zig-gamedev/build.zig");
const fontstash_build = @import("libs/fontstash/build.zig");
const watcher_build = @import("libs/filewatcher/build.zig");

const Options = struct {
    build_options: *std.Build.Step.Options,
    enable_imgui: bool,
    enable_hot_reload: bool,
};

const install_options: enum { all, only_current } = .only_current;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const enable_hot_reload = @import("builtin").os.tag == .macos;

    const options = Options{
        .build_options = b.addOptions(),
        .enable_imgui = b.option(bool, "enable_imgui", "Include/exclude Dear ImGui from the binary") orelse true,
        .enable_hot_reload = b.option(bool, "include_flecs_explorer", "Include/exclude Filewatcher and hot reload") orelse enable_hot_reload,
    };

    options.build_options.addOption(bool, "enable_imgui", options.enable_imgui);
    options.build_options.addOption(bool, "hot_reload", options.enable_hot_reload);

    for (getAllExamples(b, "examples")) |p| {
        addExecutable(b, target, optimize, options, p[0], p[1]);
    }
}

fn addExecutable(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode, options: Options, name: []const u8, source: []const u8) void {
    const exe = b.addExecutable(.{
        .name = name,
        .root_source_file = .{ .path = source },
        .target = target,
        .optimize = optimize,
    });

    //if (optimize == .ReleaseFast) exe.strip = true;

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

fn linkLibs(b: *std.Build, exe: *std.Build.Step.Compile, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode, options: Options) void {
    wgpu_build.linkArtifact(b, exe);
    const wgpu_module = wgpu_build.getModule(b);

    sdl_build.linkArtifact(b, exe);
    const sdl_module = sdl_build.getModule(b);

    stb_build.linkArtifact(exe);
    const stb_module = stb_build.getModule(b);

    if (options.enable_imgui)
        imgui_build.linkArtifact(b, exe, target, optimize, thisDir() ++ "/libs/sdl");
    const imgui_module = imgui_build.getModule(b, sdl_module, options.enable_imgui);

    zig_gamedev_build.linkArtifact(b, exe, target, optimize);
    const zmath_module = zig_gamedev_build.getMathModule(b);
    const zmesh_module = zig_gamedev_build.getMeshModule();
    const zpool_module = zig_gamedev_build.getPoolModule(b);
    const zaudio_package = zig_gamedev_build.getAudioModule();

    fontstash_build.linkArtifact(exe);
    const fontstash_module = fontstash_build.getModule(b);

    if (options.enable_hot_reload)
        watcher_build.linkArtifact(exe);
    const watcher_module = watcher_build.getModule(b, options.enable_hot_reload);

    const aya_module = b.createModule(.{
        .root_source_file = .{ .path = "src/aya.zig" },
        .imports = &.{
            .{ .name = "stb", .module = stb_module },
            .{ .name = "sdl", .module = sdl_module },
            .{ .name = "imgui", .module = imgui_module },
            .{ .name = "wgpu", .module = wgpu_module },
            .{ .name = "zmath", .module = zmath_module },
            .{ .name = "zmesh", .module = zmesh_module },
            .{ .name = "zpool", .module = zpool_module },
            .{ .name = "zaudio", .module = zaudio_package },
            .{ .name = "fontstash", .module = fontstash_module },
            .{ .name = "watcher", .module = watcher_module },
            .{
                .name = "build_options",
                .module = b.createModule(.{
                    .root_source_file = options.build_options.getOutput(),
                }),
            },
        },
    });

    exe.root_module.addImport("aya", aya_module);
    exe.root_module.addImport("wgpu", wgpu_module);
    exe.root_module.addImport("sdl", sdl_module);
    exe.root_module.addImport("stb", stb_module);
    exe.root_module.addImport("imgui", imgui_module);
    exe.root_module.addImport("zmath", zmath_module);
    exe.root_module.addImport("zmesh", zmesh_module);
}

fn getAllExamples(b: *std.Build, root_directory: []const u8) [][2][]const u8 {
    var list = std.ArrayList([2][]const u8).init(b.allocator);

    const recursor = struct {
        fn search(alloc: std.mem.Allocator, directory: []const u8, filelist: *std.ArrayList([2][]const u8)) void {
            if (std.mem.eql(u8, directory, "examples/assets") or std.mem.eql(u8, directory, "examples\\assets")) return;

            var dir = std.fs.cwd().openDir(directory, .{ .iterate = true }) catch unreachable;
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
