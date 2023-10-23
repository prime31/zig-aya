const std = @import("std");
const aya = @import("aya.zig");

pub fn implementsTrait(comptime Trait: type, comptime TypeOrInstance: anytype) bool {
    const T = if (@TypeOf(TypeOrInstance) == type) TypeOrInstance else @TypeOf(TypeOrInstance);

    if (!@hasDecl(Trait, "validate"))
        @compileError("Trait " ++ @typeName(Trait) ++ " has no function named validate");
    Trait.validate(T);

    return true;
}

pub fn hasOptionalStringDecl(comptime T: type, comptime name: []const u8) void {
    if (comptime @hasDecl(T, name)) {
        if (comptime !std.meta.trait.isZigString(@TypeOf(@field(T, name)))) {
            @compileError("Trait not satisfied. Optional decl '" ++ name ++ "' should be a string. Found type " ++ @typeName(@TypeOf(@field(T, name))));
        }
    }
}

pub fn hasOptionalTupleDecl(comptime T: type, comptime name: []const u8) void {
    if (comptime @hasDecl(T, name)) {
        if (comptime !std.meta.trait.isTuple(@TypeOf(@field(T, name)))) {
            @compileError("Trait not satisfied. Optional decl '" ++ name ++ "' should be a tuple. Found type " ++ @typeName(@TypeOf(@field(T, name))));
        }
    }
}

pub fn hasOptionalDeclOfType(comptime T: type, comptime name: []const u8, comptime DeclType: type) void {
    if (comptime @hasDecl(T, name)) hasDeclOfType(T, name, DeclType);
}

pub fn hasDeclOfType(comptime T: type, comptime name: []const u8, comptime DeclType: type) void {
    if (comptime !@hasDecl(T, name)) {
        @compileError("Trait not satisfied. Missing decl '" ++ name ++ "' of type " ++ @typeName(DeclType));
    }

    const decl_type = @TypeOf(@field(T, name));
    if (decl_type != DeclType) {
        // handle comptime_int/float
        if (comptime std.meta.trait.isFloat(decl_type) and std.meta.trait.isFloat(DeclType)) return;
        if (comptime std.meta.trait.isIntegral(decl_type) and std.meta.trait.isIntegral(DeclType)) return;

        @compileError("Trait not satisfied. Decl " ++ name ++ " should be of type " ++ @typeName(DeclType) ++ " but it is of type " ++ @typeName(decl_type));
    }
}

/// Returns the error set that the function F returns.
fn ErrorSet(comptime F: type) type {
    return @typeInfo(@typeInfo(F).Fn.return_type.?).ErrorUnion.error_set;
}

pub fn fnHasErrorSetReturnType(comptime F: type) bool {
    const function = @typeInfo(F).Fn;
    if (function.return_type == null) return false;

    const ret_type = @typeInfo(function.return_type.?);
    return ret_type == .ErrorUnion;
}

/// validates T.name has arguments args. Use null for anytype args
pub fn hasFnWithArgs(comptime T: type, comptime name: []const u8, comptime args: anytype, comptime ReturnT: type) void {
    if (comptime !@hasDecl(T, name)) {
        @compileError("Trait not satisfied. Missing function " ++ name);
    }

    const Function = @TypeOf(@field(T, name));
    const info = @typeInfo(Function);
    if (info != .Fn)
        @compileError("hasFnWithArgs expects a function type");

    const function_info = info.Fn;
    if (function_info.is_var_args)
        @compileError("Cannot use hasFnWithArgs for variadic functions");

    inline for (function_info.params, 0..) |arg, i| {
        if (arg.type != args[i]) {
            if (arg.type != null)
                @compileError("Trait not satisfied. Function '" ++ name ++ "' argument should have type " ++ @typeName(args[i]) ++ " but it is of type " ++ @typeName(arg.type.?));
            @compileError("Trait not satisfied. Function '" ++ name ++ "' arguments don't match trait");
        }
    }

    if (function_info.return_type) |ret_type| {
        if (ret_type != ReturnT) {
            @compileError("Trait not satisfied. Function '" ++ name ++ "' return type should be " ++ @typeName(ReturnT) ++ " but it is of type " ++ @typeName(ret_type));
        }
    }
}

pub fn hasFn(comptime T: type, comptime name: []const u8) void {
    if (comptime !@hasDecl(T, name) or @typeInfo(@TypeOf(@field(T, name))) != .Fn) {
        @compileError("Trait not satified. Missing function '" ++ name ++ "'");
    }
}

pub const SystemTrait = struct {
    pub fn validate(comptime T: type) void {
        // run params can be vast so we cant easily validate here
        hasFn(T, "run");
        hasOptionalDeclOfType(T, "no_readonly", bool);
        hasOptionalDeclOfType(T, "interval", f32);
        hasOptionalDeclOfType(T, "instanced", bool);
        hasOptionalDeclOfType(T, "run_when_paused", bool);
        hasOptionalTupleDecl(T, "modifiers");

        hasOptionalStringDecl(T, "name");
    }
};

/// TODO: technically, T.Param could actually be a system struct that can be used to create a filter to pass to prepareAsset...
pub const AssetTypeTrait = struct {
    pub fn validate(comptime T: type) void {
        comptime {
            hasDeclOfType(T, "ExtractedAsset", type);
            hasDeclOfType(T, "PreparedAsset", type);
            hasDeclOfType(T, "Param", type);

            if (@hasDecl(T, "prepareAsset")) {
                const PrepareAssetFn = @TypeOf(@field(T, "prepareAsset"));
                if (!fnHasErrorSetReturnType(PrepareAssetFn))
                    @compileError(@typeName(T) ++ " does not satisfy AssetTypeTrait. prepareAsset function should return an error set");

                if (PrepareAssetFn != fn (*const T.ExtractedAsset, T.Param) ErrorSet(PrepareAssetFn)!T.PreparedAsset)
                    @compileError(@typeName(T) ++ " does not satisfy AssetTypeTrait. prepareAsset function should have signature: `fn prepareAsset(*const T.ExtractedAsset, T.Param) !T.preparedAsset`");
            } else {
                @compileError(@typeName(T) ++ " does not satisfy AssetTypeTrait. Missing function prepareAsset: `fn prepareAsset(*const T.ExtractedAsset, T.Param) !T.preparedAsset`");
            }
        }
    }
};

test "trait.has" {
    const TestAsset = struct {
        pub const ExtractedAsset = u1;
        pub const PreparedAsset = u8;

        pub const Param = struct {};

        pub fn prepareAsset(_: *const ExtractedAsset, _: Param) !PreparedAsset {}
    };

    const TestSystem = struct {
        pub const no_readonly = true;
        pub const interval = 0.5;
        pub const name = "SetVelocity";
        pub const modifiers = .{ u8, u16 };

        pub fn run(_: @This()) void {}
    };

    try std.testing.expect(implementsTrait(AssetTypeTrait, TestAsset));
    try std.testing.expect(implementsTrait(AssetTypeTrait, TestAsset{}));

    try std.testing.expect(implementsTrait(SystemTrait, TestSystem));
}
