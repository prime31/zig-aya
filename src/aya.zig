const std = @import("std");

pub const utils = @import("utils.zig");

// inner modules
const app = @import("app/mod.zig");
const assets = @import("asset/mod.zig");
const input = @import("input/mod.zig");
const window = @import("window/window.zig");

// export types
pub const App = app.App;
pub const Resources = app.Resources;
pub const World = app.AppWorld;

pub const AssetsPlugin = assets.AssetPlugin;
pub const AssetServer = assets.AssetServer;
pub const Assets = assets.Assets;

pub const InputPlugin = input.InputPlugin;

pub const WindowPlugin = window.WindowPlugin;
