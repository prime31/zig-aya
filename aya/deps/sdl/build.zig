const builtin = @import("builtin");
const std = @import("std");
const Builder = std.build.Builder;

pub fn build(_: *Builder) void {}

pub fn linkArtifact(b: *Builder, exe: *std.build.LibExeObjStep, _: std.zig.CrossTarget, comptime prefix_path: []const u8) void {
    if (prefix_path.len > 0 and !std.mem.endsWith(u8, prefix_path, "/")) @panic("prefix-path must end with '/' if it is not empty");
    exe.linkSystemLibrary("c");
    exe.linkSystemLibrary("sdl2");

    if (@import("builtin").os.tag == .windows) {
        // Windows include dirs for SDL2. This requires downloading SDL2 dev and extracting to c:\SDL2
        exe.addLibPath("c:\\SDL2\\lib\\x64");

        // SDL2.dll needs to be copied to the zig-cache/bin folder
        // TODO: installFile doesnt seeem to work so manually copy the file over
        b.installFile("c:\\SDL2\\lib\\x64\\SDL2.dll", "bin\\SDL2.dll");

        std.fs.cwd().makePath("zig-cache\\bin") catch unreachable;
        const src_dir = std.fs.cwd().openDir("c:\\SDL2\\lib\\x64", .{}) catch unreachable;
        src_dir.copyFile("SDL2.dll", std.fs.cwd(), "zig-cache\\bin\\SDL2.dll", .{}) catch unreachable;
    }

    exe.addModule("sdl", getModule(b, prefix_path));
}

pub fn getModule(b: *std.Build, comptime prefix_path: []const u8) *std.build.Module {
    if (prefix_path.len > 0 and !std.mem.endsWith(u8, prefix_path, "/")) @panic("prefix-path must end with '/' if it is not empty");
    return b.createModule(.{
        .source_file = .{ .path = prefix_path ++ "aya/deps/sdl/sdl.zig" },
    });
}
