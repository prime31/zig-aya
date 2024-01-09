const std = @import("std");
const Builder = std.Build.Builder;
const install_options: enum { all, only_current } = .only_current;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "sdl",
        .root_source_file = .{ .path = "src/sdl.zig" },
        .target = target,
        .optimize = optimize,
    });

    linkArtifact(b, exe);

    const run_cmd = b.addRunArtifact(exe);

    if (install_options == .only_current) {
        const add_install_step = b.addInstallArtifact(exe, .{});
        run_cmd.step.dependOn(&add_install_step.step);
    } else {
        b.installArtifact(exe);
        run_cmd.step.dependOn(b.getInstallStep());
    }

    var buffer: [100]u8 = undefined;
    const description = std.fmt.bufPrint(buffer[0..], "Run {s}", .{"sdl"}) catch unreachable;
    const run_step = b.step("sdl", description);
    run_step.dependOn(&run_cmd.step);
}

pub fn linkArtifact(b: *std.Build, exe: *std.Build.Step.Compile) void {
    exe.linkSystemLibrary("SDL3");
    exe.linkLibC();
    exe.linkLibCpp();

    exe.addIncludePath(.{ .path = thisDir() ++ "/SDL3" });

    if (@import("builtin").os.tag == .macos) {
        b.installFile(thisDir() ++ "/libs/macos/libSDL3.1.0.0.dylib", "bin/libSDL3.1.0.0.dylib");
        b.installFile(thisDir() ++ "/libs/macos/libSDL3.dylib", "bin/libSDL3.dylib");

        exe.addRPath(.{ .path = "@executable_path" });
        exe.addLibraryPath(.{ .path = thisDir() ++ "/libs/macos" });
    } else if (@import("builtin").os.tag == .windows) {
        // Windows include dirs for SDL2. This requires downloading SDL2 dev and extracting to c:\SDL2
        exe.addLibraryPath(.{ .path = thisDir() ++ "/libs/windows" });
        // exe.addLibraryPath(.{ .cwd_relative = "." });
        // exe.addLibraryPath(.{ .path = "." });
        // exe.addLibraryPath(.{ .cwd_relative = "zig-out/bin" });

        // SDL3.dll needs to be copied to the zig-cache/bin folder
        b.installFile(thisDir() ++ "/libs/windows/SDL3.dll", "bin/SDL3.dll");
    }
}

pub fn getModule(b: *std.Build) *std.Build.Module {
    return b.createModule(.{ .root_source_file = .{ .path = thisDir() ++ "/src/sdl.zig" } });
}

inline fn thisDir() []const u8 {
    return comptime std.fs.path.dirname(@src().file) orelse ".";
}
