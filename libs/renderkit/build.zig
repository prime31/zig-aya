const std = @import("std");
const Module = std.build.Module;
const Builder = @import("std").build.Builder;

pub const ShaderCompileStep = @import("shader_compiler/shader_compiler.zig").ShaderCompileStep;

pub fn linkArtifact(exe: *std.build.LibExeObjStep, target: std.zig.CrossTarget) void {
    if (target.isDarwin()) {
        exe.linkFramework("OpenGL");
    } else if (target.isWindows()) {
        exe.linkSystemLibrary("kernel32");
        exe.linkSystemLibrary("user32");
        exe.linkSystemLibrary("shell32");
        exe.linkSystemLibrary("gdi32");
    } else if (target.isLinux()) {
        exe.linkSystemLibrary("GL");
    }
}

pub fn getModule(b: *std.Build) *Module {
    return b.createModule(.{
        .source_file = .{ .path = thisDir() ++ "/renderkit/renderkit.zig" },
    });
}

inline fn thisDir() []const u8 {
    return comptime std.fs.path.dirname(@src().file) orelse ".";
}
