const std = @import("std");

const zmath = @import("zmath/build.zig");
const zmesh = @import("zmesh/build.zig");

var zmesh_pkg: zmesh.Package = undefined;

pub fn prepare(b: *std.build, target: std.zig.CrossTarget, optimize: std.builtin.Mode) void {
    zmesh_pkg = zmesh.package(b, target, optimize);
}

pub fn linkArtifact(exe: *std.Build.Step.Compile) void {
    exe.linkLibrary(zmesh_pkg.zmesh_c_cpp);
    zmesh_pkg.link(exe);
}

pub fn getMathModule(b: *std.Build) *std.build.Module {
    return zmath.package(b, .{}).zmath;
}

pub fn getMeshModule() *std.build.Module {
    return zmesh_pkg.zmesh;
}

inline fn thisDir() []const u8 {
    return comptime std.fs.path.dirname(@src().file) orelse ".";
}
