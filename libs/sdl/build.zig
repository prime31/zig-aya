const std = @import("std");
const Builder = std.build.Builder;

pub fn linkArtifact(b: *std.build, exe: *std.Build.Step.Compile) void {
    exe.linkSystemLibrary("SDL3");
    exe.linkLibCpp();

    exe.addIncludePath(.{ .path = thisDir() });

    if (@import("builtin").os.tag == .macos) {
        b.installFile(thisDir() ++ "/libs/macos/libSDL3.1.0.0.dylib", "bin/libSDL3.1.0.0.dylib");
        b.installFile(thisDir() ++ "/libs/macos/libSDL3.dylib", "bin/libSDL3.dylib");

        exe.addRPath(.{ .path = "@executable_path" });
        exe.addLibraryPath(.{ .path = thisDir() ++ "/libs/macos" });
    } else if (@import("builtin").os.tag == .windows) {
        // Windows include dirs for SDL2. This requires downloading SDL2 dev and extracting to c:\SDL2
        exe.addLibraryPath(.{ .cwd_relative = "c:\\SDL2\\lib\\x64" });

        // SDL2.dll needs to be copied to the zig-cache/bin folder
        // TODO: installFile doesnt seeem to work on Windows so manually copy the file over
        // b.installFile("c:\\SDL2\\lib\\x64\\SDL2.dll", "bin\\SDL2.dll");

        // TODO: copy sdl3 dlls in libs/windows
        std.fs.cwd().makePath("zig-out\\bin") catch unreachable;
        const src_dir = std.fs.cwd().openDir("c:\\SDL2\\lib\\x64", .{}) catch unreachable;
        src_dir.copyFile("SDL2.dll", std.fs.cwd(), "zig-out\\bin\\SDL2.dll", .{}) catch unreachable;
    }
}

pub fn getModule(b: *std.Build, stb_module: *std.build.Module) *std.build.Module {
    return b.createModule(.{
        .source_file = .{ .path = thisDir() ++ "/src/sdl.zig" },
        .dependencies = &.{
            .{ .name = "stb", .module = stb_module },
        },
    });
}

inline fn thisDir() []const u8 {
    return comptime std.fs.path.dirname(@src().file) orelse ".";
}
