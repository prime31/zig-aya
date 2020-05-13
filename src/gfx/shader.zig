const std = @import("std");
const aya = @import("../aya.zig");
const fna = aya.fna;
const fs = aya.fs;
const gfx = aya.gfx;

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

        return shader;
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
};

test "test shader" {
    std.testing.expectError(error.ShaderCreationError, Shader.initFromFile("assets/VertexColor.fxb"));
    // shader.setCurrentTechnique("SpriteBlink"); // need gfx.device for this
}
