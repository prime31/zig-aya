const std = @import("std");

const mach_gpu_dawn = @import("mach_gpu_dawn");

pub fn linkArtifact(b: *std.build, exe: *std.Build.Step.Compile, target: std.zig.CrossTarget, optimize: std.builtin.Mode, sdl_include_path: []const u8) void {
    const zgui_c_cpp = b.addStaticLibrary(.{
        .name = "zgui",
        .target = target,
        .optimize = optimize,
    });

    zgui_c_cpp.addIncludePath(.{ .path = thisDir() ++ "/libs" });
    zgui_c_cpp.addIncludePath(.{ .path = thisDir() ++ "/libs/imgui" });
    zgui_c_cpp.addIncludePath(.{ .path = thisDir() ++ "/libs/imgui/backends" });
    zgui_c_cpp.addIncludePath(.{ .path = sdl_include_path });

    zgui_c_cpp.linkLibC();
    zgui_c_cpp.linkLibCpp();

    const cflags = &.{"-fno-sanitize=undefined"};
    zgui_c_cpp.addCSourceFile(.{ .file = .{ .path = thisDir() ++ "/libs/zgui.cpp" }, .flags = cflags });

    zgui_c_cpp.addCSourceFile(.{ .file = .{ .path = thisDir() ++ "/libs/imgui/imgui.cpp" }, .flags = cflags });
    zgui_c_cpp.addCSourceFile(.{ .file = .{ .path = thisDir() ++ "/libs/imgui/imgui_widgets.cpp" }, .flags = cflags });
    zgui_c_cpp.addCSourceFile(.{ .file = .{ .path = thisDir() ++ "/libs/imgui/imgui_tables.cpp" }, .flags = cflags });
    zgui_c_cpp.addCSourceFile(.{ .file = .{ .path = thisDir() ++ "/libs/imgui/imgui_draw.cpp" }, .flags = cflags });
    zgui_c_cpp.addCSourceFile(.{ .file = .{ .path = thisDir() ++ "/libs/imgui/imgui_demo.cpp" }, .flags = cflags });

    zgui_c_cpp.addCSourceFile(.{ .file = .{ .path = thisDir() ++ "/libs/imgui/backends/imgui_impl_wgpu.cpp" }, .flags = cflags });
    zgui_c_cpp.addCSourceFile(.{ .file = .{ .path = thisDir() ++ "/libs/imgui/backends/imgui_impl_sdl3.cpp" }, .flags = cflags });

    mach_gpu_dawn.link(b, zgui_c_cpp, .{});

    exe.linkLibrary(zgui_c_cpp);
    exe.addIncludePath(.{ .path = thisDir() ++ "/libs" });
}

pub fn getModule(b: *std.Build, sdl_module: *std.build.Module, enable_imgui: bool) *std.build.Module {
    const step = b.addOptions();
    step.addOption(bool, "enable_imgui", enable_imgui);

    return b.createModule(.{
        .source_file = .{ .path = thisDir() ++ "/src/imgui.zig" },
        .dependencies = &.{
            .{ .name = "options", .module = step.createModule() },
            .{ .name = "sdl", .module = sdl_module },
        },
    });
}

pub fn build(_: *std.Build) void {}

inline fn thisDir() []const u8 {
    return comptime std.fs.path.dirname(@src().file) orelse ".";
}
