const std = @import("std");
const internal = @import("../internal.zig");
const aya = @import("../aya.zig");
const rk = aya.rk;
const fs = aya.fs;

const Mat32 = aya.math.Mat32;

/// default params for the sprite shader. Translates the Mat32 into 2 arrays of f32 for the shader uniform slot.
pub const VertexParams = extern struct {
    pub const metadata = .{
        .uniforms = .{ .VertexParams = .{ .type = .float4, .array_count = 2 } },
        .images = .{"main_tex"},
    };

    transform_matrix: [8]f32 = [_]f32{0} ** 8,

    pub fn init(mat: *Mat32) VertexParams {
        var params = VertexParams{};
        std.mem.copy(f32, &params.transform_matrix, &mat.data);
        return params;
    }
};

fn defaultVertexShader() [:0]const u8 {
    return @embedFile("assets/sprite_vs.glsl");
}

fn defaultFragmentShader() [:0]const u8 {
    return @embedFile("assets/sprite_fs.glsl");
}

pub const Shader = struct {
    shader: rk.ShaderProgram,
    onPostBind: ?*const fn (*Shader) void,
    onSetTransformMatrix: ?*const fn (*Mat32) void,

    const Empty = struct {};

    pub const ShaderOptions = struct {
        /// optional vertex shader file path or shader code. If null, the default sprite shader vertex shader is used
        vert: ?[:0]const u8 = null,

        /// required frag shader file path or shader code.
        frag: [:0]const u8,

        /// optional function that will be called immediately after bind is called allowing you to auto-update uniforms
        onPostBind: ?*const fn (*Shader) void = null,

        /// optional function that lets you override the behavior when the transform matrix is set. This is used when there is a
        /// custom vertex shader and isnt necessary if the standard sprite vertex shader is used. Note that the shader is already
        /// bound when this is called if `gfx.setShader` is used so send your uniform immediately!
        onSetTransformMatrix: ?*const fn (*Mat32) void = null,

        /// used internally to skip checking the cache during hot reload
        force_reload: bool = false,
    };

    pub fn initDefaultSpriteShader() !Shader {
        return initWithVertFrag(VertexParams, Empty, .{ .vert = defaultVertexShader(), .frag = defaultFragmentShader() });
    }

    /// initializes the shader with the default vert uniform and no frag uniform
    pub fn init(options: ShaderOptions) !Shader {
        return initWithVertFrag(VertexParams, Empty, options);
    }

    pub fn initWithFrag(comptime FragUniformT: type, options: ShaderOptions) !Shader {
        return initWithVertFrag(VertexParams, FragUniformT, options);
    }

    pub fn initWithVertFrag(comptime VertUniformT: type, comptime FragUniformT: type, options: ShaderOptions) Shader {
        var cache_shader = false;
        if (!options.force_reload and std.mem.endsWith(u8, options.frag, ".glsl")) {
            if (internal.assets.tryGetShader(options.frag)) |shd| return shd;
            cache_shader = true;
        }

        var free_vert = false;
        var free_frag = false;

        const vert = blk: {
            // if we were not provided a vert shader we substitute in the sprite shader
            if (options.vert) |vert| {
                if (std.mem.endsWith(u8, vert, ".glsl")) {
                    free_vert = true;
                    break :blk fs.readZ(aya.mem.allocator, vert) catch unreachable;
                }
                break :blk vert;
            } else {
                break :blk defaultVertexShader();
            }
        };
        const frag = blk: {
            if (std.mem.endsWith(u8, options.frag, ".glsl")) {
                free_frag = true;
                break :blk fs.readZ(aya.mem.allocator, options.frag) catch unreachable;
            }
            break :blk options.frag;
        };

        const shader = Shader{
            .shader = rk.createShaderProgram(VertUniformT, FragUniformT, .{ .vs = vert, .fs = frag }),
            .onPostBind = options.onPostBind,
            .onSetTransformMatrix = options.onSetTransformMatrix,
        };

        if (cache_shader)
            internal.assets.putShader(VertUniformT, FragUniformT, options, shader);

        // only free data if we loaded from file
        if (free_vert) aya.mem.allocator.free(vert);
        if (free_frag) aya.mem.allocator.free(frag);

        return shader;
    }

    pub fn deinit(self: Shader) void {
        if (internal.assets.releaseShader(self))
            rk.destroyShaderProgram(self.shader);
    }

    pub fn bind(self: *Shader) void {
        rk.useShaderProgram(self.shader);
        if (self.onPostBind) |onPostBind| onPostBind(self);
    }

    pub fn setTransformMatrix(self: Shader, matrix: *Mat32) void {
        if (self.onSetTransformMatrix) |setMatrix| {
            setMatrix(matrix);
        } else {
            var params = VertexParams.init(matrix);
            self.setVertUniform(VertexParams, &params);
        }
    }

    pub fn setVertUniform(self: Shader, comptime VertUniformT: type, value: *VertUniformT) void {
        rk.setShaderProgramUniformBlock(VertUniformT, self.shader, .vs, value);
    }

    pub fn setFragUniform(self: Shader, comptime FragUniformT: type, value: *FragUniformT) void {
        rk.setShaderProgramUniformBlock(FragUniformT, self.shader, .fs, value);
    }
};

/// convenience object that binds a fragment uniform with a Shader. You can optionally wire up the onPostBind method
/// to the Shader.onPostBind so that the FragUniformT object is automatically updated when the Shader is bound.
pub fn ShaderState(comptime FragUniformT: type) type {
    return struct {
        const Self = @This();

        shader: Shader,
        frag_uniform: FragUniformT = .{},
        textures: AdditionalTextures(FragUniformT) = undefined,

        pub fn init(options: Shader.ShaderOptions) Self {
            return .{ .shader = Shader.initWithVertFrag(VertexParams, FragUniformT, options) };
        }

        pub fn deinit(self: Self) void {
            self.shader.deinit();
        }

        pub fn onPostBind(shader: *Shader) void {
            const self = @fieldParentPtr(Self, "shader", shader);
            shader.setFragUniform(FragUniformT, &self.frag_uniform);

            // bind any additional textures, starting at slot 1 because slot 0 will be handled by Batcher
            for (self.textures, 1..) |tex, i| aya.gfx.draw.bindTexture(tex, @intCast(i));
        }

        /// creates a duplicate of this ShaderState sharing the underlying Shader. Clones must have
        /// deinit called as well.
        pub fn clone(self: Self) Self {
            aya.assets.cloneShader(self.shader);
            return self;
        }
    };
}

/// returns an array of Texture that is used when binding the Shader to set any other Textures besides main_tex
fn AdditionalTextures(comptime T: type) type {
    const Texture = aya.render.Texture;

    // the main texture is handled by Mesh/DynamicMesh/Batcher so we only handle additional textures here
    if (@hasDecl(T, "metadata") and @hasField(@TypeOf(T.metadata), "images")) {
        const images = @field(T.metadata, "images");
        const count = images.len;
        if (count > 1) return [count - 1]Texture;
    }

    return [0]Texture;
}
