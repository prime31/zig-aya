const builtin = @import("builtin");
const std = @import("std");
const Builder = std.build.Builder;

pub fn build(b: *Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    const dynamic_fna = b.option(bool, "dynamic_fna", "link FNA/MojoShader dynamically. Requires building FNA via cmake") orelse false;

    // Standard release options allow the person running `zig build` to select between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("fna", "src/main.zig");

    exe.setTarget(target);
    exe.setBuildMode(mode);

    // either dynamically link FNA or build it from source
    if (dynamic_fna) {
        exe.addLibPath("deps/fna/FNA3D/build");
        exe.linkSystemLibrary("FNA3D");
    } else {
        compileFna(b, exe, target);
    }
    exe.addPackagePath("fna", "deps/fna/fna.zig");
    exe.addPackagePath("fna_image", "deps/fna/fna_image.zig");
    exe.addPackagePath("mojoshader", "deps/fna/mojoshader.zig");

    exe.linkSystemLibrary("c");
    exe.linkSystemLibrary("SDL2");
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}

fn compileFna(b: *Builder, exe: *std.build.LibExeObjStep, target: std.build.Target) void {
    if (target.isDarwin()) {
        const frameworks_dir = macos_frameworks_dir(b) catch unreachable;
        exe.addFrameworkDir(frameworks_dir);
        exe.linkFramework("Foundation");
        exe.linkFramework("Cocoa");
        exe.linkFramework("Quartz");
        exe.linkFramework("QuartzCore");
        exe.linkFramework("Metal");
        exe.linkFramework("MetalKit");
        exe.linkFramework("OpenGL");
        exe.linkFramework("Carbon");
        exe.linkSystemLibrary("c++");
    } else if (target.isWindows()) {
        // Windows include dirs for SDL2. This requires downloading SDL2 dev and extracting to c:\SDL2 then renaming
        // the "include" folder to "SDL2". SDL2.dll and SDL2.lib need to be copied to the zig-cache/bin folder
        exe.addLibPath("c:\\SDL2\\lib\\x64");
        exe.addIncludeDir("c:\\SDL2\\SDL2");
        exe.addIncludeDir("c:\\SDL2");
    }

    const is_not_macos = !target.isDarwin();
    const metal_driver = if (!is_not_macos) "-DFNA3D_DRIVER_METAL" else "-dFNA3D_NOTHING";
    const metal_support = if (!is_not_macos) "-DSUPPORT_PROFILE_METAL=1" else "-DSUPPORT_PROFILE_METAL=0";
    const moderngl_driver = if (!is_not_macos) "-dFNA3D_NOTHING" else "-DFNA3D_DRIVER_MODERNGL";
    const threadedgl_driver = if (!is_not_macos) "-dFNA3D_NOTHING" else "-DFNA3D_DRIVER_THREADEDGL";

    const lib_cflags = &[_][]const u8{
        "-std=gnu99",                      "-Wall",                          "-Wno-strict-aliasing",              "-pedantic",
        "-DMOJOSHADER_NO_VERSION_INCLUDE", "-DMOJOSHADER_USE_SDL_STDLIB",    "-DFNA3D_DRIVER_OPENGL",             "-DMOJOSHADER_EFFECT_SUPPORT",
        "-DMOJOSHADER_DEPTH_CLIPPING",     "-DMOJOSHADER_FLIP_RENDERTARGET", "-DMOJOSHADER_XNA4_VERTEX_TEXTURES", "-DSUPPORT_PROFILE_ARB1=0",
        "-DSUPPORT_PROFILE_ARB1_NV=0",     "-DSUPPORT_PROFILE_BYTECODE=0",   "-DSUPPORT_PROFILE_D3D=0",           metal_driver,
        metal_support,                     "-fno-sanitize=undefined",        "-w",                                moderngl_driver,
        threadedgl_driver,
    };
    // -fno-sanitize=undefined fixes a crash in stb hash

    exe.addIncludeDir("deps/fna/FNA3D/include");
    exe.addIncludeDir("deps/fna/FNA3D/MojoShader");
    exe.addIncludeDir("/usr/local/include/SDL2");

    for (fna_src_files) |src_file| {
        const file = b.fmt("deps/fna/FNA3D/src/{}", .{src_file});
        exe.addCSourceFile(file, lib_cflags);
    }

    for (mojo_src_files) |src_file| {
        const file = b.fmt("deps/fna/FNA3D/MojoShader/{}", .{src_file});
        exe.addCSourceFile(file, lib_cflags);
    }
}

// helper function to get SDK path on Mac
fn macos_frameworks_dir(b: *Builder) ![]u8 {
    var str = try b.exec(&[_][]const u8{ "xcrun", "--show-sdk-path" });
    const strip_newline = std.mem.lastIndexOf(u8, str, "\n");
    if (strip_newline) |index| {
        str = str[0..index];
    }
    const frameworks_dir = try std.mem.concat(b.allocator, u8, &[_][]const u8{ str, "/System/Library/Frameworks" });
    return frameworks_dir;
}

const mojo_src_files = [_][]const u8{
    "mojoshader.c",
    "mojoshader_effects.c",
    "mojoshader_common.c",
    "mojoshader_opengl.c",
    "mojoshader_metal.c",
    "profiles/mojoshader_profile_common.c",
    "profiles/mojoshader_profile_glsl.c",
    "profiles/mojoshader_profile_metal.c",
    "profiles/mojoshader_profile_spirv.c",
};

const fna_src_files = [_][]const u8{
    "FNA3D.c",
    "FNA3D_CommandStream.c",
    "FNA3D_Driver_OpenGL.c",
    "FNA3D_Driver_Metal.c",
    "FNA3D_Driver_ModernGL.c",
    "FNA3D_Driver_ThreadedGL.c",
    "FNA3D_Image.c",
    "FNA3D_PipelineCache.c",
};
