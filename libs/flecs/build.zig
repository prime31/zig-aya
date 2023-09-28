const std = @import("std");
const Builder = std.build.Builder;

// UPDATING FLECS (or use the `update_flecs` step)
// - copy flecs.c and flecs.h
// - zig translate-c flecs.h > ../../src/ecs/flecs/flecs.zig

pub fn linkArtifact(b: *std.build, exe: *std.Build.Step.Compile, target: std.zig.CrossTarget, optimize: std.builtin.Mode, include_flecs_explorer: bool) void {
    exe.addIncludePath(.{ .path = thisDir() ++ "/lib" });
    exe.linkLibrary(buildStaticLibrary(b, target, optimize, include_flecs_explorer));
}

fn buildStaticLibrary(b: *std.build, target: std.zig.CrossTarget, optimize: std.builtin.Mode, include_flecs_explorer: bool) *std.Build.CompileStep {
    const lib = b.addStaticLibrary(.{
        .name = "flecs",
        .target = target,
        .optimize = optimize,
    });
    lib.linkLibC();
    lib.addIncludePath(.{ .path = thisDir() ++ "/lib" });
    lib.addCSourceFile(.{
        .file = .{ .path = thisDir() ++ "/lib/flecs.c" },
        .flags = &.{
            "-fno-sanitize=undefined",
            "-DFLECS_USE_OS_ALLOC",
            "-DFLECS_NO_CPP",
            "-DFLECS_NO_PLECS",
            "-DFLECS_NO_SNAPSHOT",
            "-DFLECS_NO_DOC",
            "-DFLECS_NO_COREDOC",
            "-DFLECS_NO_APP",
            "-DFLECS_NO_META_C",
            if (include_flecs_explorer) "" else "-DFLECS_NO_STATS",
            if (include_flecs_explorer) "" else "-DFLECS_NO_MONITOR",
            if (include_flecs_explorer) "" else "-DFLECS_NO_HTTP",
            if (include_flecs_explorer) "" else "-DFLECS_NO_REST",
            if (@import("builtin").mode == .Debug) "-DFLECS_SANITIZE" else "",
        },
    });

    if (lib.target.isWindows())
        lib.linkSystemLibraryName("ws2_32");

    return lib;
}

// cImport doesn't yet work with zls so for now we manually generate the file
fn addTranslateCStep(b: *std.build, target: std.zig.CrossTarget, optimize: std.builtin.Mode) void {
    const trans_c = b.addTranslateC(.{
        .source_file = .{ .path = thisDir() ++ "/lib/flecs.h" },
        .target = target,
        .optimize = optimize,
    });

    trans_c.c_macros.append("FLECS_NO_CPP") catch unreachable;
    trans_c.c_macros.append("FLECS_USE_OS_ALLOC") catch unreachable;

    if (@import("builtin").mode == .Debug)
        trans_c.c_macros.append("FLECS_SANITIZE") catch unreachable;

    // doesnt work with zls either
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

fn getAllExamples(b: *std.build.Builder, root_directory: []const u8) [][2][]const u8 {
    var list = std.ArrayList([2][]const u8).init(b.allocator);

    const recursor = struct {
        fn search(alloc: std.mem.Allocator, directory: []const u8, filelist: *std.ArrayList([2][]const u8)) void {
            var dir = std.fs.cwd().openIterableDir(directory, .{ .access_sub_paths = true }) catch unreachable;
            defer dir.close();

            var iter = dir.iterate();
            while (iter.next() catch unreachable) |entry| {
                if (entry.kind == .file) {
                    if (std.mem.endsWith(u8, entry.name, ".zig")) {
                        const abs_path = std.fs.path.join(alloc, &[_][]const u8{ directory, entry.name }) catch unreachable;
                        const name = std.fs.path.basename(abs_path);

                        filelist.append([2][]const u8{ name[0 .. name.len - 4], abs_path }) catch unreachable;
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

pub fn getModule(b: *std.Build) *std.build.Module {
    return b.createModule(.{
        .source_file = .{ .path = thisDir() ++ "/src/ecs.zig" },
    });
}

inline fn thisDir() []const u8 {
    return comptime std.fs.path.dirname(@src().file) orelse ".";
}
