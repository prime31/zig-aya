const std = @import("std");
const aya = @import("../aya.zig");
const fna = aya.fna;
const fs = aya.fs;
const gfx = aya.gfx;

pub fn cmp(a: []const u8, b: [*:0]const u8) i8 {
    var index: usize = 0;
    while (a[index] == b[index] and a[index] != 0) : (index += 1) {}
    if (a[index] > b[index]) {
        return 1;
    } else if (a[index] < b[index]) {
        return -1;
    } else {
        return 0;
    }
}

pub const Shader = extern struct {
    effect: ?*fna.Effect = null,
    mojo_effect: ?*fna.mojo.Effect = null,

    pub fn initFromFile(file: []const u8) !Shader {
        var bytes = try fs.read(aya.mem.tmp_allocator, file);

        var shader = Shader{};
        fna.FNA3D_CreateEffect(gfx.device, &bytes[0], @intCast(u32, bytes.len), &shader.effect, &shader.mojo_effect);

        if (shader.mojo_effect == null) return error.ShaderCreationError;

        if (shader.mojo_effect.?.error_count > 0) {
            const errors = shader.mojo_effect.?.errors[0..@intCast(usize, shader.mojo_effect.?.error_count)];
            std.debug.warn("shader compile errors: {}\n", .{errors});
            return error.ShaderCompileError;
        }

        const techniques = shader.mojo_effect.?.techniques[0..@intCast(usize, shader.mojo_effect.?.technique_count)];
        fna.FNA3D_SetEffectTechnique(gfx.device, shader.effect, &techniques[0]);

        // debug shader techniques/passes and params
        comptime const debug_shader = false;
        if (debug_shader) {
            for (techniques) |technique| {
                std.debug.warn("technique: {s}\n", .{technique.name});
                const passes = technique.passes[0..@intCast(usize, technique.pass_count)];
                for (passes) |pass| {
                    std.debug.warn("\tPass: {s}\n", .{pass.name});
                }
            }

            if (shader.mojo_effect.?.param_count > 0) {
                const params = shader.mojo_effect.?.params[0..@intCast(usize, shader.mojo_effect.?.param_count)];
                for (params) |param| {
                    std.debug.warn("Param: {}\n", .{param});
                }
            }
        }

        return shader;
    }

    pub fn deinit(self: Shader) void {
        fna.FNA3D_AddDisposeEffect(gfx.device, self.effect);
    }

    pub fn apply(self: @This()) void {
        var effect_changes = std.mem.zeroes(fna.mojo.EffectStateChanges);
        fna.FNA3D_ApplyEffect(gfx.device, self.effect, 0, &effect_changes);
    }

    pub fn setCurrentTechnique(self: @This(), name: [:0]const u8) !void {
        const techniques = self.mojo_effect.?.techniques[0..@intCast(usize, self.mojo_effect.?.technique_count)];
        for (techniques) |technique, i| {
            if (std.cstr.cmp(name, technique.name) == 0) {
                fna.FNA3D_SetEffectTechnique(gfx.device, self.effect, &techniques[i]);
                return;
            }
        }

        return error.TechnniqueNotFound;
    }

    pub fn getParam(self: @This(), comptime T: type, name: []const u8) T {
        if (self.mojo_effect.?.param_count > 0) {
            const params = self.mojo_effect.?.params[0..@intCast(usize, self.mojo_effect.?.param_count)];
            for (params) |param| {
                if (cmp(name, param.value.name) == 0) {
                    return getParamImpl(T, param.value);
                }
            }
        }
        return unreachable;
    }

    fn getParamImpl(comptime T: type, value: fna.mojo.EffectValue) T {
        return switch (@typeInfo(T)) {
            .Float => @floatCast(T, value.float.*),
            .Int => @intCast(T, value.int.*),
            .Struct => {
                if (T == Vec2) {
                    std.debug.assert(value.type.parameter_class == .vector);
                    std.debug.assert(value.type.parameter_type == .float);
                    const floats = value.float.*[0..2];
                    return Vec2{
                        .x = floats[0],
                        .y = floats[1],
                    };
                } else if (T == Mat32) {
                    std.debug.assert(value.type.parameter_class == .matrix_rows);
                    std.debug.assert(value.type.parameter_type == .float);
                    std.debug.assert(value.type.rows == 2);
                    std.debug.assert(value.type.columns == 3);
                    return T{};
                }
                @compileError("Unsupported struct type '" ++ @typeName(T) ++ "'");
            },
            else => @compileError("Unable to get value of type '" ++ @typeName(T) ++ "'"),
        };
    }

    pub fn setParam(self: @This(), comptime T: type, name: []const u8, value: T) void {
        if (self.mojo_effect.?.param_count > 0) {
            const params = self.mojo_effect.?.params[0..@intCast(usize, self.mojo_effect.?.param_count)];
            for (params) |param| {
                if (cmp(name, param.value.name) == 0) {
                    return setParamImpl(T, param.value, value);
                }
            }
        }
        return unreachable;
    }

    fn setParamImpl(comptime T: type, effect_value: fna.mojo.EffectValue, value: T) void {
        switch (@typeInfo(T)) {
            .Float => value.float.* = @floatCast(f32, value),
            .Int => value.int.* = @intCast(c_int, value),
            .Struct => {
                if (T == Vec2) {
                    std.debug.assert(value.type.parameter_class == .vector);
                    std.debug.assert(value.type.parameter_type == .float);
                    const floats = value.float.*[0..2];
                    floats[0] = value.x;
                    floats[1] = value.y;
                } else if (T == Mat32) {
                    std.debug.assert(value.type.parameter_class == .matrix_rows);
                    std.debug.assert(value.type.parameter_type == .float);
                    std.debug.assert(value.type.rows == 2);
                    std.debug.assert(value.type.columns == 3);
                }
                @compileError("Unsupported struct type '" ++ @typeName(T) ++ "'");
            },
            else => @compileError("Unable to set value of type '" ++ @typeName(T) ++ "'"),
        }
    }
};

test "test shader" {
    std.testing.expectError(error.ShaderCreationError, Shader.initFromFile("assets/VertexColor.fxb"));
    // var s = Shader{};
    // _ = s.getParam(f32, "fart");
    // shader.setCurrentTechnique("SpriteBlink"); // need gfx.device for this
}
