const std = @import("std");

pub fn linkArtifact(exe: *std.Build.Step.Compile) void {
    // Dear ImGui will need this
    exe.addIncludePath(.{ .path = thisDir() ++ "/headers/webgpu" });

    if (@import("builtin").os.tag == .macos) {
        exe.addObjectFile(.{ .path = thisDir() ++ "/libs/macos/libwgpu_native.a" });

        exe.linkSystemLibraryName("objc");
        exe.linkFramework("Metal");
        exe.linkFramework("CoreGraphics");
        exe.linkFramework("Foundation");
        exe.linkFramework("IOKit");
        exe.linkFramework("IOSurface");
        exe.linkFramework("QuartzCore");
    } else if (@import("builtin").os.tag == .windows) {
        exe.addObjectFile(.{ .path = thisDir() ++ "/libs/windows/wgpu_native.dll" });
    }
}

pub fn getModule(b: *std.Build) *std.build.Module {
    return b.createModule(.{ .source_file = .{ .path = thisDir() ++ "/src/wgpu.zig" } });
}

inline fn thisDir() []const u8 {
    return comptime std.fs.path.dirname(@src().file) orelse ".";
}
