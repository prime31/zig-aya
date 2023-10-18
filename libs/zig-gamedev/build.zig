const std = @import("std");

const zmath = @import("zmath/build.zig");
const zmesh = @import("zmesh/build.zig");
const zpool = @import("zpool/build.zig");

var zmesh_module: *std.build.Module = undefined;

pub fn linkArtifact(b: *std.build, exe: *std.Build.Step.Compile, target: std.zig.CrossTarget, optimize: std.builtin.Mode) void {
    const zmesh_pkg = zmesh.package(b, target, optimize);
    exe.linkLibrary(zmesh_pkg.zmesh_c_cpp);
    zmesh_pkg.link(exe);
    zmesh_module = zmesh_pkg.zmesh;
}

pub fn getMathModule(b: *std.Build) *std.build.Module {
    return zmath.package(b, .{}).zmath;
}

pub fn getMeshModule() *std.build.Module {
    return zmesh_module;
}

pub fn getPoolModule(b: *std.Build) *std.build.Module {
    return zpool.getModule(b);
}

inline fn thisDir() []const u8 {
    return comptime std.fs.path.dirname(@src().file) orelse ".";
}
