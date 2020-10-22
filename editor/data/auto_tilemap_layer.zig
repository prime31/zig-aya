const std = @import("std");
const aya = @import("aya");
const math = aya.math;
usingnamespace @import("imgui");

const editor = @import("../editor.zig");
const data = @import("data.zig");

const AppState = data.AppState;
const Tilemap = data.Tilemap;
const Tileset = data.Tileset;
const Size = data.Size;
const Camera = @import("../camera.zig").Camera;

pub const AutoTilemapLayer = struct {
    name: [:0]const u8,
    tilemap: Tilemap,
    tileset: Tileset,

    pub fn init(name: []const u8, size: Size, tile_size: usize) AutoTilemapLayer {
        return .{
            .name = aya.mem.allocator.dupeZ(u8, name) catch unreachable,
            .tilemap = Tilemap.init(size),
            .tileset = Tileset.init(tile_size),
        };
    }

    pub fn deinit(self: @This()) void {
        aya.mem.allocator.free(self.name);
        self.tilemap.deinit();
        self.tileset.deinit();
    }

    pub fn draw(self: @This(), state: *AppState, is_selected: bool) void {}

    pub fn handleSceneInput(self: @This(), state: *AppState, camera: Camera, mouse_world: ImVec2) void {
        aya.draw.text(self.name, 100, 0, null);
    }
};