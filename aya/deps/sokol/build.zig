const builtin = @import("builtin");
const std = @import("std");
const Builder = std.build.Builder;

pub fn linkArtifact(b: *Builder, exe: *std.build.LibExeObjStep, target: std.build.Target, include_imgui: bool) void {
    exe.linkLibC();

    if (target.isDarwin()) {
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
    } else if (target.isLinux()) {
        // Not tested
        exe.linkSystemLibrary("GL");
        exe.linkSystemLibrary("GLEW");
    }

    exe.addIncludeDir("aya/deps/imgui");
    exe.addIncludeDir("aya/deps/sokol");

    const imgui_flag = if (include_imgui) "-DNOTHING" else "-DDISABLE_IMGUI=1";
    const c_flags = if (std.Target.current.os.tag == .macos) [_][]const u8{ "-std=c99", "-ObjC", "-fobjc-arc", "-O3", imgui_flag } else [_][]const u8{ "-std=c99", "-O3", imgui_flag };

    exe.addCSourceFile("aya/deps/sokol/compile_sokol.c", &c_flags);
}

/// helper function to get SDK path on Mac
fn macosFrameworksDir(b: *Builder) ![]u8 {
    var str = try b.exec(&[_][]const u8{ "xcrun", "--show-sdk-path" });
    const strip_newline = std.mem.lastIndexOf(u8, str, "\n");
    if (strip_newline) |index| {
        str = str[0..index];
    }
    const frameworks_dir = try std.mem.concat(b.allocator, u8, &[_][]const u8{ str, "/System/Library/Frameworks" });
    return frameworks_dir;
}
