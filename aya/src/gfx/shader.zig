const std = @import("std");
const fna = @import("fna");
const aya = @import("../aya.zig");
const fs = aya.fs;
const gfx = aya.gfx;

pub const Shader = extern struct {
    effect: *fna.Effect,
    mojo_effect: *fna.mojo.Effect,
    transform_matrix_index: usize = std.math.maxInt(usize),

    pub fn initFromFile(file: []const u8) !Shader {
        var bytes = try fs.read(aya.mem.tmp_allocator, file);
        return initFromBytes(bytes);
    }

    pub fn initFromBytes(bytes: []const u8) !Shader {
        var effect: ?*fna.Effect = null;
        var mojo_effect: ?*fna.mojo.Effect = null;
        gfx.device.createEffect(bytes, &effect, &mojo_effect);

        if (mojo_effect == null or effect == null) return error.ShaderCreationError;

        if (mojo_effect.?.error_count > 0) {
            const errors = mojo_effect.?.errors[0..@intCast(usize, mojo_effect.?.error_count)];
            std.debug.warn("shader compile errors: {}\n", .{errors});
            return error.ShaderCompileError;
        }

        var shader = Shader{
            .effect = effect.?,
            .mojo_effect = mojo_effect.?,
        };

        // store the index of the TransformMatrix param if we have one
        shader.transform_matrix_index = if (shader.getParamIndex("TransformMatrix")) |index| index else |err| shader.transform_matrix_index;

        const techniques = shader.mojo_effect.techniques[0..@intCast(usize, shader.mojo_effect.technique_count)];
        gfx.device.setEffectTechnique(shader.effect, &techniques[0]);

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

            if (shader.mojo_effect.param_count > 0) {
                const params = shader.mojo_effect.params[0..@intCast(usize, shader.mojo_effect.param_count)];
                for (params) |param| {
                    std.debug.warn("Param: {}\n", .{param});
                }
            }
        }

        return shader;
    }

    pub fn deinit(self: Shader) void {
        gfx.device.addDisposeEffect(self.effect);
    }

    pub fn apply(self: Shader) void {
        self.applyPass(0);
    }

    pub fn applyPass(self: Shader, pass: u32) void {
        var effect_changes = std.mem.zeroes(fna.mojo.EffectStateChanges);
        gfx.device.applyEffect(self.effect, pass, &effect_changes);
    }

    /// gets the index of the pass for the current technique. The index can be passed to applyPass
    pub fn getPassIndexForCurrentTechnique(self: Shader, pass_name: []const u8) !u32 {
        const passes = self.mojo_effect.current_technique.passes[0..@intCast(usize, self.mojo_effect.current_technique.pass_count)];
        for (passes) |pass, i| {
            if (aya.utils.cstr_u8_cmp(pass.name, pass_name) == 0) {
                return i;
            }
        }
        return error.PassNotFound;
    }

    pub fn setCurrentTechnique(self: *Shader, name: []const u8) !void {
        const techniques = self.mojo_effect.techniques[0..@intCast(usize, self.mojo_effect.technique_count)];
        for (techniques) |technique, i| {
            if (aya.utils.cstr_u8_cmp(technique.name, name) == 0) {
                return gfx.device.setEffectTechnique(self.effect, &techniques[i]);
            }
        }
        return error.TechnniqueNotFound;
    }

    /// gets the index of the parameter
    pub fn getParamIndex(self: Shader, name: []const u8) !usize {
        if (self.mojo_effect.param_count > 0) {
            const params = self.mojo_effect.params[0..@intCast(usize, self.mojo_effect.param_count)];
            for (params) |param, i| {
                if (aya.utils.cstr_u8_cmp(param.value.name, name) == 0) {
                    return i;
                }
            }
        }
        return error.ParamNotFound;
    }

    /// gets the value of the parameter
    pub fn getParamValue(self: Shader, comptime T: type, name: []const u8) T {
        if (self.mojo_effect.param_count > 0) {
            const params = self.mojo_effect.params[0..@intCast(usize, self.mojo_effect.param_count)];
            for (params) |param| {
                if (aya.utils.cstr_u8_cmp(param.value.name, name) == 0) {
                    return getParamImpl(T, param.value);
                }
            }
        }
        return unreachable;
    }

    /// gets the value of the parameter
    pub fn getParamValueByIndex(self: Shader, comptime T: type, index: usize) T {
        return getParamImpl(T, self.mojo_effect.params[index].value);
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
                    @compileError("Fix me. implement mat32");
                    return Mat32{};
                }
                @compileError("Unsupported struct type '" ++ @typeName(T) ++ "'");
            },
            else => @compileError("Unable to get value of type '" ++ @typeName(T) ++ "'"),
        };
    }

    pub fn setParam(self: Shader, comptime T: type, name: []const u8, value: T) void {
        if (self.mojo_effect.param_count > 0) {
            const params = self.mojo_effect.params[0..@intCast(usize, self.mojo_effect.param_count)];
            for (params) |param| {
                if (aya.utils.cstr_u8_cmp(param.value.name, name) == 0) {
                    return setParamImpl(T, param.value, value);
                }
            }
        }
        @panic("Attempting to set a shader param that doesnt exist");
    }

    pub fn setParamByIndex(self: Shader, comptime T: type, index: usize, value: T) void {
        return setParamImpl(T, self.mojo_effect.params[index].value, value);
    }

    fn setParamImpl(comptime T: type, effect_value: fna.mojo.EffectValue, value: T) void {
        switch (@typeInfo(T)) {
            .Float => effect_value.value.float.* = @floatCast(f32, value),
            .Int => effect_value.value.int.* = @intCast(c_int, value),
            .Struct => {
                if (T == aya.math.Vec2) {
                    std.debug.assert(effect_value.type.parameter_class == .vector);
                    std.debug.assert(effect_value.type.parameter_type == .float);

                    const floats = effect_value.value.float[0..2];
                    floats[0] = value.x;
                    floats[1] = value.y;
                } else if (T == aya.math.Vec3) {
                    std.debug.assert(effect_value.type.parameter_class == .vector);
                    std.debug.assert(effect_value.type.parameter_type == .float);

                    const floats = effect_value.value.float[0..3];
                    floats[0] = value.x;
                    floats[1] = value.y;
                    floats[2] = value.z;
                } else if (T == aya.math.Vec4) {
                    std.debug.assert(effect_value.type.parameter_class == .vector);
                    std.debug.assert(effect_value.type.parameter_type == .float);

                    const floats = effect_value.value.float[0..4];
                    floats[0] = value.x;
                    floats[1] = value.y;
                    floats[2] = value.z;
                    floats[3] = value.w;
                } else if (T == aya.math.Mat32) {
                    std.debug.assert(effect_value.type.parameter_class == .matrix_rows);
                    std.debug.assert(effect_value.type.parameter_type == .float);
                    std.debug.assert(effect_value.type.rows == 2);
                    std.debug.assert(effect_value.type.columns == 3);
                    std.debug.assert(effect_value.value_count == 8);

                    const floats = effect_value.value.float[0..@intCast(usize, effect_value.value_count)];
                    floats[0] = value.data[0];
                    floats[1] = value.data[2];
                    floats[2] = value.data[4];
                    floats[4] = value.data[1];
                    floats[5] = value.data[3];
                    floats[6] = value.data[5];
                }
            },
            else => @compileError("Unable to set value of type '" ++ @typeName(T) ++ "'. Unsupported."),
        }
    }
};

test "test shader" {
    var s = try Shader.initFromFile("assets/VertexColor.fxb");
    _ = try s.setCurrentTechnique("SpriteBlink");
    s.apply();
}
