const std = @import("std");
const aya = @import("../aya.zig");

const Handle = aya.Handle;
const AssetPath = aya.AssetPath;

pub const ShaderRef = union(enum) {
    /// Use the "default" shader for the current context.
    default: void,
    /// A handle to a shader stored in the `Assets(Shader)`
    handle: Handle(Shader),
    /// An asset path leading to a shader
    path: AssetPath,

    pub fn getHandle(self: ShaderRef, shaders: *aya.Assets(Shader), asset_server: *aya.AssetServer) ?Handle(Shader) {
        return switch (self) {
            .default => null,
            .handle => |h| h,
            .path => |path| asset_server.load(Shader, shaders, path.path.str, {}),
        };
    }
};

pub const ShaderImport = union(enum) {
    asset_path: []const u8,
    custom: []const u8,
};

pub const ShaderDefVal = union(enum) {
    bool: struct { str: []const u8, val: bool },
    int: struct { str: []const u8, val: i32 },
    uint: struct { str: []const u8, val: u32 },
};

/// Asset.
pub const Shader = struct {
    path: []const u8,
    source: []const u8,
    import_path: ShaderImport,
    imports: std.ArrayList(ShaderImport),
    // extra imports not specified in the source string
    // additional_imports: Vec<naga_oil::compose::ImportDefinition>,
    // any shader defs that will be included when this module is used
    shader_defs: std.ArrayList(ShaderDefVal),
    // we must store strong handles to our dependencies to stop them
    // from being immediately dropped if we are the only user.
    file_dependencies: std.ArrayList(Handle(Shader)),

    pub fn fromWgsl(source: []const u8, path: []const u8) Shader {
        // let (import_path, imports) = Shader::preprocess(&source, &path);
        return Shader{
            .path = path,
            .imports = undefined,
            .import_path = .{ .asset_path = "" },
            .source = source,
            // .additional_imports: Default::default(),
            .shader_defs = undefined,
            .file_dependencies = undefined,
        };
    }
};

// AssetLoader
pub fn loadShader(path: []const u8, _: void) Shader {
    const source = aya.fs.read(path) catch unreachable;
    const extension = std.fs.path.extension(path);

    const shader = blk: {
        if (std.mem.eql(u8, extension, ".wgls"))
            break :blk Shader.fromWgsl(source, path);
        if (std.mem.eql(u8, extension, ".comp"))
            break :blk Shader.fromWgsl(source, path);
        unreachable;
    };

    return shader;
}
