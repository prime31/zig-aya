const builtin = @import("builtin");
const std = @import("std");
const Builder = std.build.Builder;

const build_impl_type: enum { exe, static_lib, object_files } = .static_lib;
var framework_dir: ?[]u8 = null;

pub fn build(b: *std.build.Builder) anyerror!void {
    const exe = b.addStaticLibrary("JunkLib", null);
    linkArtifact(b, exe, b.standardTargetOptions(.{}), .static, "");
    exe.install();
}

/// prefix_path is used to add package paths. It should be the the same path used to include this build file
pub fn linkArtifact(b: *Builder, exe: *std.build.LibExeObjStep, target: std.zig.CrossTarget, comptime prefix_path: []const u8) void {
    if (prefix_path.len > 0 and !std.mem.endsWith(u8, prefix_path, "/")) @panic("prefix-path must end with '/' if it is not empty");
    exe.addModule("imgui_gl", getImGuiModule(b, prefix_path));

    if (target.isWindows()) {
        exe.linkSystemLibrary("user32");
        exe.linkSystemLibrary("gdi32");
    } else if (target.isDarwin()) {
        macosAddSdkDirs(b, exe) catch unreachable;
        exe.linkFramework("Foundation");
        exe.linkFramework("Cocoa");
        exe.linkFramework("Quartz");
        exe.linkFramework("QuartzCore");
        exe.linkFramework("OpenGL");
        exe.linkFramework("Audiotoolbox");
        exe.linkFramework("CoreAudio");
        exe.linkSystemLibrary("c++");
    } else {
        exe.linkLibC();
        exe.linkSystemLibrary("c++");
    }

    const base_path = prefix_path ++ "aya/deps/imgui/";
    exe.addIncludePath(std.Build.LazyPath.relative(base_path ++ "cimgui/imgui"));
    exe.addIncludePath(std.Build.LazyPath.relative(base_path ++ "cimgui/imgui/examples"));

    const cpp_args = [_][]const u8{"-Wno-return-type-c-linkage"};
    exe.addCSourceFiles(.{ .files = &[_][]const u8{
        base_path ++ "cimgui/imgui/imgui.cpp",
        base_path ++ "cimgui/imgui/imgui_demo.cpp",
        base_path ++ "cimgui/imgui/imgui_draw.cpp",
        base_path ++ "cimgui/imgui/imgui_widgets.cpp",
        base_path ++ "cimgui/cimgui.cpp",
        base_path ++ "temporary_hacks.cpp",
    }, .flags = &cpp_args });

    addImGuiGlImplementation(b, exe, target, prefix_path);
}

fn addImGuiGlImplementation(_: *Builder, exe: *std.build.LibExeObjStep, _: std.zig.CrossTarget, comptime prefix_path: []const u8) void {
    const base_path = prefix_path ++ "aya/deps/imgui/";
    const cpp_args = [_][]const u8{ "-Wno-return-type-c-linkage", "-DIMGUI_IMPL_API=extern \"C\"", "-DIMGUI_IMPL_OPENGL_LOADER_GL3W" };

    // what we actually want to work but for some reason on macos it doesnt
    exe.linkSystemLibrary("SDL2");
    exe.addIncludePath(std.Build.LazyPath.relative(base_path ++ "cimgui/imgui/examples/libs/gl3w"));
    exe.addIncludePath(std.Build.LazyPath{ .cwd_relative = "/usr/local/include/SDL2" });
    exe.addIncludePath(std.Build.LazyPath{ .cwd_relative = "/opt/homebrew/include/SDL2" });

    exe.addCSourceFiles(.{ .files = &[_][]const u8{
        base_path ++ "cimgui/imgui/examples/libs/gl3w/GL/gl3w.c",
        base_path ++ "cimgui/imgui/examples/imgui_impl_opengl3.cpp",
        base_path ++ "cimgui/imgui/examples/imgui_impl_sdl.cpp",
    }, .flags = &cpp_args });
}

/// helper function to get SDK path on Mac
fn macosFrameworksDir(b: *Builder) ![]u8 {
    if (framework_dir) |dir| return dir;

    var str = b.exec(&[_][]const u8{ "xcrun", "--show-sdk-path" });
    const strip_newline = std.mem.lastIndexOf(u8, str, "\n");
    if (strip_newline) |index| {
        str = str[0..index];
    }
    framework_dir = try std.mem.concat(b.allocator, u8, &[_][]const u8{ str, "/System/Library/Frameworks" });
    return framework_dir.?;
}

fn macosAddSdkDirs(b: *Builder, step: *std.build.LibExeObjStep) !void {
    var sdk_dir = b.exec(&[_][]const u8{ "xcrun", "--show-sdk-path" });
    const newline_index = std.mem.lastIndexOf(u8, sdk_dir, "\n");
    if (newline_index) |idx| {
        sdk_dir = sdk_dir[0..idx];
    }
    framework_dir = try std.mem.concat(b.allocator, u8, &[_][]const u8{ sdk_dir, "/System/Library/Frameworks" });
    const usrinclude_dir = try std.mem.concat(b.allocator, u8, &[_][]const u8{ sdk_dir, "/usr/include" });
    step.addFrameworkPath(std.Build.LazyPath{ .cwd_relative = framework_dir.? });
    step.addFrameworkPath(std.Build.LazyPath{ .cwd_relative = usrinclude_dir });
}

pub fn getImGuiModule(b: *std.Build, comptime prefix_path: []const u8) *std.build.Module {
    if (prefix_path.len > 0 and !std.mem.endsWith(u8, prefix_path, "/")) @panic("prefix-path must end with '/' if it is not empty");
    return b.createModule(.{
        .source_file = .{ .path = prefix_path ++ "aya/deps/imgui/imgui.zig" },
    });
}

pub fn getImGuiGlModule(b: *std.Build, comptime prefix_path: []const u8) *std.build.Module {
    if (prefix_path.len > 0 and !std.mem.endsWith(u8, prefix_path, "/")) @panic("prefix-path must end with '/' if it is not empty");
    return b.createModule(.{
        .source_file = .{ .path = prefix_path ++ "aya/deps/imgui/imgui_gl.zig" },
    });
}
