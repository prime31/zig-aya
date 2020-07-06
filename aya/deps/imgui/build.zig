const builtin = @import("builtin");
const std = @import("std");
const Builder = std.build.Builder;

pub const LibType = enum(i32) {
    static,
    dynamic, // requires DYLD_LIBRARY_PATH to point to the dylib path
    exe_compiled,
};

pub fn build(b: *std.build.Builder) anyerror!void {
    const exe = b.addStaticLibrary("JunkLib", null);
    linkArtifact(b, exe, b.standardTargetOptions(.{}), .static, "");
    exe.install();
}

/// rel_path is used to add package paths. It should be the the same path used to include this build file
pub fn linkArtifact(b: *Builder, artifact: *std.build.LibExeObjStep, target: std.build.Target, lib_type: LibType) void {
    switch (lib_type) {
        .static => {
            const lib = b.addStaticLibrary("imgui", null);
            lib.setBuildMode(builtin.Mode.ReleaseSmall);
            lib.setTarget(target);

            compileImGui(b, lib, target);
            lib.install();

            artifact.linkLibrary(lib);
        },
        .dynamic => {
            @panic("not implemented");
        },
        .exe_compiled => {
            compileImGui(b, artifact, target);
        },
    }
}

fn compileImGui(b: *Builder, exe: *std.build.LibExeObjStep, target: std.build.Target) void {
    if (target.isWindows()) {
        exe.linkSystemLibrary("user32");
        exe.linkSystemLibrary("gdi32");
    } else if (target.isDarwin()) {
        const frameworks_dir = macosFrameworksDir(b) catch unreachable;
        exe.addFrameworkDir(frameworks_dir);
        exe.linkFramework("Foundation");
        exe.linkFramework("Cocoa");
        exe.linkFramework("Quartz");
        exe.linkFramework("QuartzCore");
        exe.linkFramework("Metal");
        exe.linkFramework("MetalKit");
        exe.linkFramework("OpenGL");
        exe.linkFramework("Audiotoolbox");
        exe.linkFramework("CoreAudio");
        exe.linkSystemLibrary("c++");
        exe.enableSystemLinkerHack();
    } else {
        @panic("OS not supported. Try removing panic in build.zig if you want to test this");
    }

    exe.addIncludeDir("deps/imgui/cimgui/imgui");

    const cpp_args = [_][]const u8{"-Wno-return-type-c-linkage"};
    exe.addCSourceFile("aya/deps/imgui/cimgui/imgui/imgui.cpp", &cpp_args);
    exe.addCSourceFile("aya/deps/imgui/cimgui/imgui/imgui_demo.cpp", &cpp_args);
    exe.addCSourceFile("aya/deps/imgui/cimgui/imgui/imgui_draw.cpp", &cpp_args);
    exe.addCSourceFile("aya/deps/imgui/cimgui/imgui/imgui_widgets.cpp", &cpp_args);
    exe.addCSourceFile("aya/deps/imgui/cimgui/cimgui.cpp", &cpp_args);
}


// helper function to get SDK path on Mac
fn macosFrameworksDir(b: *Builder) ![]u8 {
    var str = try b.exec(&[_][]const u8{ "xcrun", "--show-sdk-path" });
    const strip_newline = std.mem.lastIndexOf(u8, str, "\n");
    if (strip_newline) |index| {
        str = str[0..index];
    }
    const frameworks_dir = try std.mem.concat(b.allocator, u8, &[_][]const u8{ str, "/System/Library/Frameworks" });
    return frameworks_dir;
}