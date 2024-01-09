const std = @import("std");

pub fn linkArtifact(b: *std.Build, exe: *std.Build.Step.Compile, target: std.Build.ResolvedTarget, optimize: std.builtin.Mode, sdl_include_path: []const u8) void {
    exe.addIncludePath(.{ .path = thisDir() ++ "/lib" });

    const lib = buildStaticLibrary(b, target, optimize);
    lib.addIncludePath(.{ .path = sdl_include_path });
    lib.addIncludePath(.{ .path = thisDir() ++ "/../wgpu/headers" });
    exe.linkLibrary(lib);
}

fn buildStaticLibrary(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.Mode) *std.Build.Step.Compile {
    const lib = b.addStaticLibrary(.{
        .name = "imgui",
        .target = target,
        .optimize = optimize,
    });
    lib.addIncludePath(.{ .path = thisDir() ++ "/lib" });

    lib.linkLibC();

    if (target.result.abi != .msvc)
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

pub fn getModule(b: *std.Build, sdl_module: *std.Build.Module, enable_imgui: bool) *std.Build.Module {
    const step = b.addOptions();
    step.addOption(bool, "enable_imgui", enable_imgui);

    return b.createModule(.{
        .root_source_file = .{ .path = thisDir() ++ "/src/imgui.zig" },
        .imports = &.{
            .{ .name = "sdl", .module = sdl_module },
            .{ .name = "options", .module = step.createModule() },
        },
    });
}

inline fn thisDir() []const u8 {
    return comptime std.fs.path.dirname(@src().file) orelse ".";
}
