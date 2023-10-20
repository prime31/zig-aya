pub const AssetPath = struct {
    path: Path,
    label: ?[]const u8 = null,
};

// TODO: rust syn::Path
pub const Path = struct {
    str: []const u8,
};
