const std = @import("std");
const Builder = std.build.Builder;

// fix dynamic lib: `install_name_tool -id "@rpath/libwgpu_native.dylib" libwgpu_native.dylib`

const link_type: enum { static, dynamic } = .static;

pub fn linkArtifact(b: *std.build, exe: *std.Build.Step.Compile) void {
    if (link_type == .dynamic)
        exe.linkSystemLibrary("wgpu_native");
    exe.addIncludePath(.{ .path = thisDir() ++ "/headers/webgpu" });

    if (@import("builtin").os.tag == .macos) {
        b.installFile(thisDir() ++ "/libs/macos/libwgpu_native.dylib", "bin/libwgpu_native.dylib");

        if (link_type == .static) {
            exe.addObjectFile(.{ .path = thisDir() ++ "/libs/macos/libwgpu_native.a" });
            exe.linkFramework("MetalKit");
            exe.linkFramework("Metal");
            exe.linkFramework("Cocoa");
            exe.linkFramework("QuartzCore");
        }

        if (link_type == .dynamic) {
            exe.addRPath(.{ .path = "@executable_path" });
            exe.addLibraryPath(.{ .path = thisDir() ++ "/libs/macos" });
        }
    } else if (@import("builtin").os.tag == .windows) {
        // TODO: we dont need all of these...
        exe.addLibraryPath(.{ .path = thisDir() ++ "/libs/windows" });
        exe.addLibraryPath(.{ .cwd_relative = "zig-out/bin" });

        if (link_type == .dynamic) {
            b.installFile(thisDir() ++ "/libs/windows/wgpu_native.dll", "bin/wgpu_native.dll");
            b.installFile(thisDir() ++ "/libs/windows/wgpu_native.dll.lib", "bin/wgpu_native.dll.lib");
        }
    }
}

pub fn getModule(b: *std.Build, zpool: *std.build.Module, sdl: *std.build.Module) *std.build.Module {
    return b.createModule(.{
        .source_file = .{ .path = thisDir() ++ "/src/zgpu.zig" },
        .dependencies = &.{
            .{ .name = "zpool", .module = zpool },
            .{ .name = "sdl", .module = sdl },
        },
    });
}

inline fn thisDir() []const u8 {
    return comptime std.fs.path.dirname(@src().file) orelse ".";
}
