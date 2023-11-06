const std = @import("std");

pub const Package = struct {
    zaudio: *std.Build.Module,
    zaudio_c_cpp: *std.Build.CompileStep,

    pub fn link(pkg: Package, exe: *std.Build.CompileStep) void {
        exe.linkLibrary(pkg.zaudio_c_cpp);
        exe.addModule("zaudio", pkg.zaudio);
    }
};

pub fn package(b: *std.Build, target: std.zig.CrossTarget, optimize: std.builtin.Mode, _: struct {}) Package {
    const zaudio = b.createModule(.{
        .source_file = .{ .path = thisDir() ++ "/src/zaudio.zig" },
    });

    const zaudio_c_cpp = b.addStaticLibrary(.{
        .name = "zaudio",
        .target = target,
        .optimize = optimize,
    });

    zaudio_c_cpp.addIncludePath(.{ .path = thisDir() ++ "/libs/miniaudio" });
    zaudio_c_cpp.linkLibC();

    const host = (std.zig.system.NativeTargetInfo.detect(zaudio_c_cpp.target) catch unreachable).target;

    if (host.os.tag == .macos) {
        zaudio_c_cpp.linkFramework("CoreAudio");
        zaudio_c_cpp.linkFramework("CoreFoundation");
        zaudio_c_cpp.linkFramework("AudioUnit");
        zaudio_c_cpp.linkFramework("AudioToolbox");
    } else if (host.os.tag == .linux) {
        zaudio_c_cpp.linkSystemLibraryName("pthread");
        zaudio_c_cpp.linkSystemLibraryName("m");
        zaudio_c_cpp.linkSystemLibraryName("dl");
    }

    zaudio_c_cpp.addCSourceFile(.{
        .file = .{ .path = thisDir() ++ "/src/zaudio.c" },
        .flags = &.{"-std=c99"},
    });
    zaudio_c_cpp.addCSourceFile(.{
        .file = .{ .path = thisDir() ++ "/libs/miniaudio/miniaudio.c" },
        .flags = &.{
            "-DMA_NO_WEBAUDIO",
            "-DMA_NO_ENCODING",
            "-DMA_NO_NULL",
            "-DMA_NO_JACK",
            "-DMA_NO_DSOUND",
            "-DMA_NO_WINMM",
            "-std=c99",
            "-fno-sanitize=undefined",
            if (host.os.tag == .macos) "-DMA_NO_RUNTIME_LINKING" else "",
        },
    });

    return .{
        .zaudio = zaudio,
        .zaudio_c_cpp = zaudio_c_cpp,
    };
}

inline fn thisDir() []const u8 {
    return comptime std.fs.path.dirname(@src().file) orelse ".";
}
