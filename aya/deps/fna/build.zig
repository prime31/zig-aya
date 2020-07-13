const builtin = @import("builtin");
const std = @import("std");
const Builder = std.build.Builder;

pub const LibType = enum(i32) {
    static,
    dynamic, // requires DYLD_LIBRARY_PATH to point to the dylib path
    exe_compiled,
};

pub fn build(b: *std.build.Builder) anyerror!void {
    const exe = b.addStaticLibrary("JunkLib", null);
    linkArtifact(b, exe, b.standardTargetOptions(.{}), .exe_compiled);
    exe.install();
}

/// rel_path is used to add package paths. It should be the the same path used to include this build file
pub fn linkArtifact(b: *Builder, artifact: *std.build.LibExeObjStep, target: std.build.Target, lib_type: LibType) void {
    switch (lib_type) {
        .static => {
            const lib = b.addStaticLibrary("FNA3D", null);
            lib.setBuildMode(builtin.Mode.ReleaseSmall);
            lib.setTarget(target);

            compileFna(b, lib, target);
            lib.install();

            artifact.linkLibrary(lib);
        },
        .dynamic => {
            std.debug.print("ensure FNA3D gets build as a static lib via CMAKE\n", .{});
            artifact.addLibPath("aya/deps/fna/FNA3D/build");
            artifact.linkSystemLibrary("FNA3D");
        },
        .exe_compiled => {
            compileFna(b, artifact, target);
        },
    }
}

fn compileFna(b: *Builder, exe: *std.build.LibExeObjStep, target: std.build.Target) void {
    if (exe.target.cpu_arch != null and exe.target.cpu_arch.? == .wasm32) {
        exe.addIncludeDir("~/emsdk/upstream/emscripten/system/include");
        exe.addIncludeDir("~/emsdk/upstream/emscripten/system/include/SDL");
    } else if (target.isDarwin()) {
        const frameworks_dir = macosFrameworksDir(b) catch unreachable;
        exe.addFrameworkDir(frameworks_dir);
        exe.linkFramework("Foundation");
        exe.linkFramework("Cocoa");
        exe.linkFramework("Quartz");
        exe.linkFramework("QuartzCore");
        exe.linkFramework("Metal");
        exe.linkFramework("MetalKit");
        exe.linkFramework("OpenGL");
        exe.linkFramework("Carbon");
        exe.addIncludeDir("/usr/local/include/SDL2");
    } else if (target.isWindows()) {
        // Windows include dirs for SDL2. This requires downloading SDL2 dev and extracting to c:\SDL2 then renaming
        // the "include" folder to "SDL2". SDL2.dll and SDL2.lib need to be copied to the zig-cache/bin folder
        exe.addLibPath("c:\\SDL2\\lib\\x64");
        exe.addIncludeDir("c:\\SDL2\\SDL2");
        exe.addIncludeDir("c:\\SDL2");
    } else if (target.isLinux()) {
        exe.addIncludeDir("/usr/local/include/SDL2");
    }

    const lib_cflags = &[_][]const u8{
        "-std=gnu99",                      "-Wall",                          "-Wno-strict-aliasing",              "-pedantic",
        "-DMOJOSHADER_NO_VERSION_INCLUDE", "-DMOJOSHADER_USE_SDL_STDLIB",    "-DFNA3D_DRIVER_OPENGL",             "-DMOJOSHADER_EFFECT_SUPPORT",
        "-DMOJOSHADER_DEPTH_CLIPPING",     "-DMOJOSHADER_FLIP_RENDERTARGET", "-DMOJOSHADER_XNA4_VERTEX_TEXTURES", "-DSUPPORT_PROFILE_ARB1=0",
        "-DSUPPORT_PROFILE_ARB1_NV=0",     "-DSUPPORT_PROFILE_BYTECODE=0",   "-DSUPPORT_PROFILE_D3D=0",           "-w",
        "-fno-sanitize=undefined",
    };
    // -fno-sanitize=undefined fixes a crash in stb hash

    const platform_cflags = if (std.Target.current.os.tag == .macosx) blk: {
        break :blk &[_][]const u8{ "-DSUPPORT_PROFILE_HLSL=0", "-DFNA3D_DRIVER_METAL", "-DSUPPORT_PROFILE_METAL=1" };
    } else if (std.Target.current.os.tag == .windows) blk: {
        break :blk &[_][]const u8{ "-DFNA3D_DRIVER_D3D11", "-DSUPPORT_PROFILE_HLSL=1", "-DSUPPORT_PROFILE_METAL=0" };
    } else blk: {
        break :blk &[_][]const u8{ "-DSUPPORT_PROFILE_HLSL=0", "-DSUPPORT_PROFILE_METAL=0" };
    };

    const cflags = lib_cflags ++ platform_cflags;

    // for builds from the root dir of the project
    exe.addIncludeDir("aya/deps/fna/FNA3D/include");
    exe.addIncludeDir("aya/deps/fna/FNA3D/MojoShader");

    // for local builds with this build file as the root of the build
    exe.addIncludeDir("FNA3D/include");
    exe.addIncludeDir("FNA3D/MojoShader");

    for (fna_src_files) |src_file| {
        const file = b.fmt("aya/deps/fna/FNA3D/src/{}", .{src_file});
        exe.addCSourceFile(file, cflags);
    }

    for (mojo_src_files) |src_file| {
        const file = b.fmt("aya/deps/fna/FNA3D/MojoShader/{}", .{src_file});
        exe.addCSourceFile(file, cflags);
    }
}

// helper function to get SDK path on Mac
fn macosFrameworksDir(b: *Builder) ![]u8 {
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
    "mojoshader_d3d11.c",
    "mojoshader_opengl.c",
    "mojoshader_metal.c",
    "profiles/mojoshader_profile_common.c",
    "profiles/mojoshader_profile_glsl.c",
    "profiles/mojoshader_profile_hlsl.c",
    "profiles/mojoshader_profile_metal.c",
    "profiles/mojoshader_profile_spirv.c",
};

const fna_src_files = [_][]const u8{
    "FNA3D.c",
    "FNA3D_Driver_D3D11.c",
    "FNA3D_Driver_OpenGL.c",
    "FNA3D_Driver_Metal.c",
    "FNA3D_Image.c",
    "FNA3D_PipelineCache.c",
};
