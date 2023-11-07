const std = @import("std");
const watcher = @import("watcher");
const aya = @import("aya.zig");
const rk = aya.rk;

const Texture = aya.render.Texture;
const Shader = aya.render.Shader;
const ShaderOptions = aya.render.Shader.ShaderOptions;

fn RefCounted(comptime T: type) type {
    return struct {
        obj: T,
        cnt: u8 = 1,
    };
}

/// encapsulates a Shader and the ShaderOptions used to create it
const ShaderInfo = struct {
    shader: Shader,
    options: ShaderOptions,
    rebuilder: *const fn (ShaderOptions) ?rk.ShaderProgram,

    pub fn init(comptime VertUniformT: type, comptime FragUniformT: type, options: ShaderOptions, shader: Shader) ShaderInfo {
        const closure = struct {
            fn closure(opts: ShaderOptions) ?rk.ShaderProgram {
                return if (Shader.initWithVertFrag(VertUniformT, FragUniformT, opts)) |shdr| {
                    if (shdr.shader > 0) return shdr.shader;
                    return null;
                } else |_| return null;
            }
        }.closure;

        return .{
            .shader = shader,
            .options = options,
            .rebuilder = closure,
        };
    }

    pub fn rebuildShader(self: ShaderInfo) ?rk.ShaderProgram {
        return self.rebuilder(self.options);
    }
};

const asset_path = "examples/assets";

pub const Assets = struct {
    textures: std.StringHashMap(RefCounted(Texture)),
    shaders: std.StringHashMap(RefCounted(ShaderInfo)),

    pub fn init() Assets {
        // disable hot reload if the FileWatcher is disbled
        if (watcher.enabled)
            watcher.watchPath(asset_path, onFileChanged);

        return .{
            .textures = std.StringHashMap(RefCounted(Texture)).init(aya.mem.allocator),
            .shaders = std.StringHashMap(RefCounted(ShaderInfo)).init(aya.mem.allocator),
        };
    }

    pub fn deinit(self: *Assets) void {
        var texture_iter = self.textures.valueIterator();
        while (texture_iter.next()) |rc| rc.obj.deinit();
        self.textures.deinit();

        var shader_iter = self.shaders.valueIterator();
        while (shader_iter.next()) |rc| rc.obj.shader.deinit();
        self.shaders.deinit();
    }

    // Textures
    pub fn loadTexture(self: *Assets, file: []const u8, filter: rk.TextureFilter) Texture {
        if (self.textures.getPtr(file)) |rc| {
            rc.cnt += 1;
            return rc.obj;
        }

        const texture = Texture.initFromFile(file, filter);
        self.textures.put(file, .{ .obj = texture }) catch unreachable;
        return texture;
    }

    /// increases the ref count on the texture
    pub fn cloneTexture(self: *Assets, texture: Texture) void {
        var iter = self.textures.valueIterator();
        while (iter.next()) |rc| {
            if (rc.obj.img == texture.img) {
                rc.cnt += 1;
                return;
            }
        }
    }

    pub fn releaseTexture(self: *Assets, tex: Texture) void {
        var iter = self.textures.iterator();
        while (iter.next()) |*entry| {
            if (entry.value_ptr.obj.img == tex.img) {
                entry.value_ptr.cnt -= 1;
                if (entry.value_ptr.cnt == 0) {
                    _ = self.textures.removeByPtr(entry.key_ptr);
                    tex.deinit();
                }
                return;
            }
        }
    }

    fn hotReloadTexture(self: *Assets, path: []const u8) void {
        if (self.textures.getPtr(path)) |rc| {
            var wh: usize = 0;
            const new_img = Texture.dataFromFile(path, &wh, &wh) catch unreachable;
            rc.obj.setData(u8, new_img);
        }
    }

    // Shaders
    pub fn loadShader(self: *Assets, comptime VertUniformT: type, comptime FragUniformT: type, options: ShaderOptions) !Shader {
        // we need to be loading a fragment shader from a file for hot reload to work
        if (!std.mem.endsWith(u8, options.frag, ".glsl")) return Shader.initWithVertFrag(VertUniformT, FragUniformT, options);

        if (self.shaders.getPtr(options.frag)) |rc| {
            rc.cnt += 1;
            return rc.obj.shader;
        }

        const shader = try Shader.initWithVertFrag(VertUniformT, FragUniformT, options);
        try self.shaders.put(options.frag, .{ .obj = ShaderInfo.init(VertUniformT, FragUniformT, options, shader) });
        return shader;
    }

    /// increases the ref count on the shader
    pub fn cloneShader(self: *Assets, shader: Shader) void {
        var iter = self.shaders.valueIterator();
        while (iter.next()) |rc| {
            if (rc.obj.shader.shader == shader.shader) {
                rc.cnt += 1;
                return;
            }
        }
    }

    pub fn releaseShader(self: *Assets, shader: Shader) void {
        var iter = self.shaders.iterator();
        while (iter.next()) |*entry| {
            if (entry.value_ptr.obj.shader.shader == shader.shader) {
                entry.value_ptr.cnt -= 1;
                if (entry.value_ptr.cnt == 0) {
                    _ = self.shaders.removeByPtr(entry.key_ptr);
                    shader.deinit();
                }
                return;
            }
        }
    }

    fn hotReloadShader(self: *Assets, path: []const u8) void {
        if (self.shaders.getPtr(path)) |rc| {
            if (rc.obj.rebuildShader()) |new_shader| {
                rk.replaceShaderProgram(rc.obj.shader.shader, new_shader);
            } else {
                std.debug.print("[ERROR] Shader hot reload failed for shader: {s}\n", .{path});
            }
        }
    }
};

// hot reload handler
fn onFileChanged(path: [*c]const u8) callconv(.C) void {
    const path_span = std.mem.span(path);
    if (std.mem.indexOf(u8, path_span, asset_path)) |index| {
        const ext = std.fs.path.extension(path_span);
        if (std.mem.eql(u8, ext, ".png"))
            aya.assets.hotReloadTexture(path_span[index..]);
        if (std.mem.eql(u8, ext, ".glsl"))
            aya.assets.hotReloadShader(path_span[index..]);
    }
}
