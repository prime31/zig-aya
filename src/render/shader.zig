const std = @import("std");
const aya = @import("../aya.zig");

const Handle = aya.Handle;
const AssetPath = aya.AssetPath;

pub const ShaderRef = union(enum) {
    /// Use the "default" shader for the current context.
    default: void,
    /// A handle to a shader stored in the [`Assets<Shader>`](bevy_asset::Assets) resource
    handle: Handle(Shader),
    /// An asset path leading to a shader
    path: AssetPath,
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
};
