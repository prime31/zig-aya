const std = @import("std");

const mach_gpu_dawn = @import("mach_gpu_dawn");

pub fn linkArtifact(b: *std.build, exe: *std.Build.Step.Compile, target: std.zig.CrossTarget, optimize: std.builtin.Mode, sdl_include_path: []const u8) void {
    exe.addIncludePath(.{ .path = thisDir() ++ "/lib" });

    const lib = buildStaticLibrary(b, target, optimize);
    lib.addIncludePath(.{ .path = sdl_include_path });
    lib.addIncludePath(.{ .path = thisDir() ++ "/../wgpu/headers" });

    mach_gpu_dawn.link(b, lib, .{});

    exe.linkLibrary(lib);
}

fn buildStaticLibrary(b: *std.build, target: std.zig.CrossTarget, optimize: std.builtin.Mode) *std.Build.CompileStep {
    const lib = b.addStaticLibrary(.{
        .name = "imgui",
        .target = target,
        .optimize = optimize,
    });
    lib.addIncludePath(.{ .path = thisDir() ++ "/lib" });

    lib.linkLibC();

    const abi = (std.zig.system.NativeTargetInfo.detect(target) catch unreachable).target.abi;
    if (abi != .msvc)
        lib.linkLibCpp();

    const cflags = &.{ "-fno-sanitize=undefined", "-Wno-return-type-c-linkage" };
    lib.addCSourceFiles(
        .{ .files = &.{
            thisDir() ++ "/lib/imgui.cpp",
            thisDir() ++ "/lib/imgui_widgets.cpp",
            thisDir() ++ "/lib/imgui_tables.cpp",
            thisDir() ++ "/lib/imgui_draw.cpp",
            thisDir() ++ "/lib/imgui_demo.cpp",
            thisDir() ++ "/lib/backends/imgui_impl_wgpu.cpp",
            thisDir() ++ "/lib/backends/imgui_impl_sdl3.cpp",
            thisDir() ++ "/lib/cimgui.cpp",
        }, .flags = cflags },
    );

    return lib;
}

pub fn getModule(b: *std.Build, sdl_module: *std.build.Module, enable_imgui: bool) *std.build.Module {
    const step = b.addOptions();
    step.addOption(bool, "enable_imgui", enable_imgui);

    return b.createModule(.{
        .source_file = .{ .path = thisDir() ++ "/src/imgui.zig" },
        .dependencies = &.{
            .{ .name = "sdl", .module = sdl_module },
            .{ .name = "options", .module = step.createModule() },
        },
    });
}

inline fn thisDir() []const u8 {
    return comptime std.fs.path.dirname(@src().file) orelse ".";
}
