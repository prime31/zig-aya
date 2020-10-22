const std = @import("std");
const aya = @import("aya");
const math = aya.math;
usingnamespace @import("imgui");

const editor = @import("../editor.zig");
const data = @import("data.zig");
const AppState = data.AppState;
pub const TilemapLayer = data.TilemapLayer;
pub const AutoTilemapLayer = data.AutoTilemapLayer;
pub const EntityLayer = data.EntityLayer;
const Size = data.Size;
const Camera = @import("../camera.zig").Camera;

pub const LayerType = enum(u8) {
    tilemap,
    auto_tilemap,
    entity,
};

pub const Layer = union(LayerType) {
    tilemap: TilemapLayer,
    auto_tilemap: AutoTilemapLayer,
    entity: EntityLayer,

    pub fn init(layer_type: LayerType, layer_name: []const u8, size: Size, tile_size: usize) Layer {
        return switch (layer_type) {
            .tilemap => .{
                .tilemap = TilemapLayer.init(layer_name, size, tile_size),
            },
            .auto_tilemap => .{
                .auto_tilemap = AutoTilemapLayer.init(layer_name, size, tile_size),
            },
            .entity => .{
                .entity = EntityLayer.init(layer_name, size),
            },
        };
    }

    pub fn deinit(self: @This()) void {
        switch (self) {
            .tilemap => |layer| layer.deinit(),
            .auto_tilemap => |layer| layer.deinit(),
            .entity => |layer| layer.deinit(),
        }
    }

    pub fn name(self: @This()) [:0]const u8 {
        return switch (self) {
            .tilemap => |layer| layer.name,
            .auto_tilemap => |layer| layer.name,
            .entity => |layer| layer.name,
        };
    }

    /// used for doing the actual drawing of the layer as it appears in-game (and its associated imgui windows/popups), not the
    /// editing UI that is rendered in the Scene when this is the selected Layer
    pub fn draw(self: *@This(), state: *AppState, is_selected: bool) void {
        switch (self.*) {
            .tilemap => |*layer| layer.draw(state, is_selected),
            .auto_tilemap => |*layer| layer.draw(state, is_selected),
            .entity => |*layer| layer.draw(state, is_selected),
        }
    }

    /// used for the editing UI, called after all other drawing so it can render on top of everything. Called only for the selected Layer.
    pub fn handleSceneInput(self: *@This(), state: *AppState, camera: Camera, mouse_world: ImVec2) void {
        switch (self.*) {
            .tilemap => |*layer| layer.handleSceneInput(state, camera, mouse_world),
            .auto_tilemap => |*layer| layer.handleSceneInput(state, camera, mouse_world),
            .entity => |*layer| layer.handleSceneInput(state, camera, mouse_world),
        }
    }
};