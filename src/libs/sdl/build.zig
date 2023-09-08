const std = @import("std");
const Builder = std.build.Builder;

pub fn linkArtifact(exe: *std.build.LibExeObjStep) void {
    exe.linkSystemLibrary("SDL3");
    exe.linkLibCpp();

    exe.addIncludePath(.{ .path = thisDir() });

    if (@import("builtin").os.tag == .macos) {
        exe.addRPath(.{ .path = "@executable_path/Frameworks" });
        exe.addRPath(.{ .path = thisDir() ++ "/libs/macos" });
        exe.addLibraryPath(.{ .path = thisDir() ++ "/libs/macos" });
    } else if (@import("builtin").os.tag == .windows) {
        // Windows include dirs for SDL2. This requires downloading SDL2 dev and extracting to c:\SDL2
        exe.addLibraryPath(.{ .cwd_relative = "c:\\SDL2\\lib\\x64" });

        // SDL2.dll needs to be copied to the zig-cache/bin folder
        // TODO: installFile doesnt seeem to work so manually copy the file over
        // b.installFile("c:\\SDL2\\lib\\x64\\SDL2.dll", "bin\\SDL2.dll");

        // TODO: copy buitl sdl3 dlls in libs/windows
        std.fs.cwd().makePath("zig-out\\bin") catch unreachable;
        const src_dir = std.fs.cwd().openDir("c:\\SDL2\\lib\\x64", .{}) catch unreachable;
        src_dir.copyFile("SDL2.dll", std.fs.cwd(), "zig-out\\bin\\SDL2.dll", .{}) catch unreachable;
    }
}

pub fn getModule(b: *std.Build) *std.build.Module {
    return b.createModule(.{
        .source_file = .{ .path = thisDir() ++ "/sdl.zig" },
    });
}

inline fn thisDir() []const u8 {
    return comptime std.fs.path.dirname(@src().file) orelse ".";
}
