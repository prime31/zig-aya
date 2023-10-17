const std = @import("std");

pub const Package = struct {
    zmesh: *std.Build.Module,
    zmesh_c_cpp: *std.Build.CompileStep,

    pub fn link(pkg: Package, exe: *std.Build.CompileStep) void {
        exe.linkLibrary(pkg.zmesh_c_cpp);
    }
};

pub fn package(b: *std.Build, target: std.zig.CrossTarget, optimize: std.builtin.Mode) Package {
    const zmesh = b.createModule(.{
        .source_file = .{ .path = thisDir() ++ "/src/main.zig" },
    });

    const zmesh_c_cpp = b.addStaticLibrary(.{
        .name = "zmesh",
        .target = target,
        .optimize = optimize,
    });

    const abi = (std.zig.system.NativeTargetInfo.detect(target) catch unreachable).target.abi;
    zmesh_c_cpp.linkLibC();
    if (abi != .msvc)
        zmesh_c_cpp.linkLibCpp();

    zmesh_c_cpp.addIncludePath(.{ .path = thisDir() ++ "/libs/par_shapes" });
    zmesh_c_cpp.addCSourceFile(.{
        .file = .{ .path = thisDir() ++ "/libs/par_shapes/par_shapes.c" },
        .flags = &.{ "-std=c99", "-fno-sanitize=undefined", "-DPAR_SHAPES_T=uint16_t" },
    });

    zmesh_c_cpp.addCSourceFiles(&.{
        thisDir() ++ "/libs/meshoptimizer/clusterizer.cpp",
        thisDir() ++ "/libs/meshoptimizer/indexgenerator.cpp",
        thisDir() ++ "/libs/meshoptimizer/vcacheoptimizer.cpp",
        thisDir() ++ "/libs/meshoptimizer/vcacheanalyzer.cpp",
        thisDir() ++ "/libs/meshoptimizer/vfetchoptimizer.cpp",
        thisDir() ++ "/libs/meshoptimizer/vfetchanalyzer.cpp",
        thisDir() ++ "/libs/meshoptimizer/overdrawoptimizer.cpp",
        thisDir() ++ "/libs/meshoptimizer/overdrawanalyzer.cpp",
        thisDir() ++ "/libs/meshoptimizer/simplifier.cpp",
        thisDir() ++ "/libs/meshoptimizer/allocator.cpp",
    }, &.{""});
    zmesh_c_cpp.addIncludePath(.{ .path = thisDir() ++ "/libs/cgltf" });
    zmesh_c_cpp.addCSourceFile(.{
        .file = .{ .path = thisDir() ++ "/libs/cgltf/cgltf.c" },
        .flags = &.{"-std=c99"},
    });

    return .{
        .zmesh = zmesh,
        .zmesh_c_cpp = zmesh_c_cpp,
    };
}

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    const test_step = b.step("test", "Run zmesh tests");
    test_step.dependOn(runTests(b, optimize, target));
}

pub fn runTests(
    b: *std.Build,
    optimize: std.builtin.Mode,
    target: std.zig.CrossTarget,
) *std.Build.Step {
    const tests = b.addTest(.{
        .name = "zmesh-tests",
        .root_source_file = .{ .path = thisDir() ++ "/src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    const zmesh_pkg = package(b, target, optimize, .{});
    zmesh_pkg.link(tests);

    return &b.addRunArtifact(tests).step;
}

inline fn thisDir() []const u8 {
    return comptime std.fs.path.dirname(@src().file) orelse ".";
}
