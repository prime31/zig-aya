const std = @import("std");
const aya = @import("../../aya.zig");
const renderkit = @import("renderkit");
const renderer = renderkit.renderer;
const fs = aya.fs;

pub const Shader = struct {
    shader: renderkit.ShaderProgram,

    pub fn initFromFile(vert_path: []const u8, frag_path: []const u8) !Shader {
        var vert = try fs.readZ(aya.mem.tmp_allocator, vert_path);
        var frag = try fs.readZ(aya.mem.tmp_allocator, frag_path);
        return try Shader.init(vert, frag);
    }

    pub fn init(vert: [:0]const u8, frag: [:0]const u8) !Shader {
        return Shader{ .shader = renderer.createShaderProgram(void, .{ .vs = vert, .fs = frag }) };
    }

    pub fn initWithFragUniform(comptime FragUniformT: type, vert: [:0]const u8, frag: [:0]const u8) !Shader {
        return Shader{ .shader = renderer.createShaderProgram(FragUniformT, .{ .vs = vert, .fs = frag }) };
    }

    pub fn initWithFrag(comptime FragUniformT: type, frag: [:0]const u8) !Shader {
        const vert = @embedFile("assets/default.vs");

        // TODO: this is a bit hacky. come up with a better way
        const default_frag = @embedFile("assets/default.fs");
        const default_frag_pre = default_frag[0 .. std.mem.indexOfScalar(u8, default_frag, '}').? + 2];
        const final_frag = try std.mem.concat(aya.mem.allocator, u8, &[_][]const u8{ default_frag_pre, frag, "\x00" });

        return Shader{ .shader = renderer.createShaderProgram(FragUniformT, .{ .vs = vert, .fs = final_frag[0 .. final_frag.len - 1 :0] }) };
    }

    pub fn deinit(self: Shader) void {
        renderer.destroyShaderProgram(self.shader);
    }

    pub fn bind(self: Shader) void {
        renderer.useShaderProgram(self.shader);
    }

    pub fn setFragUniform(self: Shader, comptime FragUniformT: type, value: FragUniformT) void {
        renderer.setShaderProgramFragmentUniform(FragUniformT, self.shader, value);
    }

    pub fn setUniformName(self: Shader, comptime T: type, name: [:0]const u8, value: T) void {
        renderer.setShaderProgramUniform(T, self.shader, name, value);
    }
};
