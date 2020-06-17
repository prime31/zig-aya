const builtin = @import("builtin");
const std = @import("std");
const Builder = std.build.Builder;

pub const LibType = enum(i32) {
    static,
    dynamic, // requires DYLD_LIBRARY_PATH to point to the dylib path
    exe_compiled,
};

// TODO: fill in a test builder
// pub fn build(b: *Builder) void {}

/// rel_path is used to add package paths. It should be the the same path used to include this build file
pub fn linkArtifact(b: *Builder, artifact: *std.build.LibExeObjStep, target: std.build.Target, lib_type: LibType, rel_path: []const u8) void {
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
            artifact.addLibPath("deps/fna/FNA3D/build");
            artifact.linkSystemLibrary("FNA3D");
        },
        .exe_compiled => {
            compileFna(b, artifact, target);
        },
    }

    artifact.addPackagePath("fna", std.fs.path.join(b.allocator, &[_][]const u8{ rel_path, "fna.zig" }) catch unreachable);
}

fn compileFna(b: *Builder, exe: *std.build.LibExeObjStep, target: std.build.Target) void {
    if (exe.target.cpu_arch != null and exe.target.cpu_arch.? == .wasm32) {
        exe.addIncludeDir("/Users/desaro/emsdk/upstream/emscripten/system/include");
        exe.addIncludeDir("/Users/desaro/emsdk/upstream/emscripten/system/include/SDL");
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
        exe.linkSystemLibrary("c++");
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

    const has_metal = target.isDarwin();
    const metal_driver = if (has_metal) "-DFNA3D_DRIVER_METAL" else "-dFNA3D_NOTHING";
    const metal_support = if (has_metal) "-DSUPPORT_PROFILE_METAL=1" else "-DSUPPORT_PROFILE_METAL=0";
    const moderngl_driver = if (has_metal) "-dFNA3D_NOTHING" else "-DFNA3D_DRIVER_MODERNGL";
    const threadedgl_driver = if (has_metal) "-dFNA3D_NOTHING" else "-DFNA3D_DRIVER_THREADEDGL";

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
