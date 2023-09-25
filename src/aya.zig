const std = @import("std");

pub const utils = @import("utils.zig");

// inner modules
pub usingnamespace @import("app/mod.zig");
pub usingnamespace @import("asset/mod.zig");
pub usingnamespace @import("input/mod.zig");
pub usingnamespace @import("window/window.zig");

pub const ecs = struct {
    const ecs_mod = @import("ecs");

    pub const Entity = ecs_mod.Entity;
    pub const Iterator = ecs_mod.Iterator;
    pub const InOutKind = ecs_mod.InOutKind;
    pub const OperKind = ecs_mod.OperKind;

    pub const Filter = ecs_mod.Filter;
    pub const Query = ecs_mod.Query;
    pub const Term = ecs_mod.Term;

    // system query modifiers
    pub const DontMatch = ecs_mod.DontMatch;
    pub const Mask = ecs_mod.Mask;
    pub const MaskI = ecs_mod.MaskI;
    pub const None = ecs_mod.None;
    pub const Not = ecs_mod.Not;
    pub const Or = ecs_mod.Or;
    pub const Pair = ecs_mod.Pair;
    pub const PairI = ecs_mod.PairI;
    pub const Writeonly = ecs_mod.Writeonly;
    pub const WriteonlyI = ecs_mod.WriteonlyI;
};

// export types
// pub const App = app.App;
// pub const Resources = app.Resources;
// pub const World = app.AppWorld;

// pub const AssetPlugin = assets.AssetPlugin;
// pub const AssetServer = assets.AssetServer;
// pub const Assets = assets.Assets;

// pub const InputPlugin = input.InputPlugin;

// pub const WindowPlugin = window.WindowPlugin;
