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
        exe.addLibraryPath(.{ .path = thisDir() ++ "/libs/windows" });
        exe.addLibraryPath(.{ .cwd_relative = "." });
        exe.addLibraryPath(.{ .path = "." });
        exe.addLibraryPath(.{ .cwd_relative = "zig-out/bin" });

        // SDL3.dll needs to be copied to the zig-cache/bin folder
        b.installFile(thisDir() ++ "/libs/windows/SDL3.dll", "bin/SDL3.dll");
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
