const std = @import("std");
const aya = @import("aya");
const math = aya.math;
usingnamespace @import("imgui");

const fixme_tile_size: usize = 16;

const editor = @import("../editor.zig");

pub const AppState = @import("app_state.zig").AppState;
pub const Tileset = @import("tileset.zig").Tileset;

const Camera = @import("../camera.zig").Camera;
const Point = struct { x: usize, y: usize };

/// given a mouse position returns the tile under it
pub fn tileIndexUnderMouse(position: ImVec2, tile_size: usize, camera: Camera) ?Point {
    // mouse positions need to be subtracted from origin of content rect to get into screen space (window space really)
    const mouse_screen = position.subtract(ogGetCursorScreenPos());
    return tileIndexUnderPos(camera.igScreenToWorld(mouse_screen), tile_size);
}

/// given a world-space position returns the tile under it
pub fn tileIndexUnderPos(position: ImVec2, tile_size: usize) ?Point {
    if (position.x < 0 or position.y < 0) return null;
    return Point{ .x = @divTrunc(@floatToInt(usize, position.x), tile_size), .y = @divTrunc(@floatToInt(usize, position.y), tile_size) };
}

pub const Size = struct {
    w: usize,
    h: usize,

    pub fn init(width: usize, height: usize) Size {
        return .{ .w = width, .h = height };
    }
};

/// convenience struct for housing a tile that saves the trouble of bitshifting for setting/getting upper bits
pub const Tile = extern union {
    value: u16,
    comps: packed struct {
        tile_index: u12,
        reserved: u1,
        horizontal: u1,
        vertical: u1,
        diagonal: u1,
    },

    pub fn init(value: u16) Tile {
        return .{ .value = value };
    }
};

const TileRenderInfo = struct {
    id: u16,
    rot: f32 = 0,
    sx: f32 = 1,
    sy: f32 = 1,
    ox: f32 = 0,
    oy: f32 = 0,

    pub fn init(tid: u16, tile_size: usize) TileRenderInfo {
        const tile = Tile{ .value = tid };
        var info = TileRenderInfo{ .id = tile.value };

        const flip_h = tile.comps.horizontal == 1;
        const flip_v = tile.comps.vertical == 1;

        // deal with flipping/rotating if necessary
        if (tile.comps.diagonal == 1) {
            // set the origin based on the tile_size if we are rotated
            info.ox = @intToFloat(f32, tile_size) / 2.0;
            info.oy = @intToFloat(f32, tile_size) / 2.0;

            if (flip_h) info.sx *= -1;
            if (flip_v) info.sy *= -1;

            if (tile.comps.horizontal == 1) {
                if (flip_h and flip_v) {
                    info.rot = aya.math.pi_over_2;
                } else if (flip_h) {
                    info.rot = -aya.math.pi_over_2;
                } else if (flip_v) {
                    info.rot = aya.math.pi_over_2;
                } else {
                    info.rot = -aya.math.pi_over_2;
                }
            }
        }

        return info;
    }

    pub fn transformMatrix(self: TileRenderInfo, x: f32, y: f32) aya.math.Mat32 {
        return aya.math.Mat32.initTransform(.{ .x = x, .y = y, .angle = self.rot, .sx = self.sx, .sy = self.sy, .ox = self.ox, .oy = self.oy });
    }
};

pub const Tilemap = struct {
    size: Size,
    data: []u16,

    pub fn init(size: Size) Tilemap {
        var data = aya.mem.allocator.alloc(u16, size.w * size.h) catch unreachable;
        std.mem.set(u16, data, 0);
        return .{
            .size = size,
            .data = data,
        };
    }

    pub fn initWithData(data: []const u16, size: Size) Tilemap {
        return .{
            .size = size,
            .data = std.mem.dupe(aya.mem.allocator, u16, data) catch unreachable,
        };
    }

    pub fn deinit(self: Tilemap) void {
        aya.mem.allocator.free(self.data);
    }

    pub fn clear(self: TilemapLayer) void {
        std.mem.set(u16, self.data, 0);
    }

    pub fn getTile(self: Tilemap, tile: Point) u16 {
        if (tile.x > self.size.w or tile.y > self.size.h) {
            return 0;
        }
        return self.data[tile.x + tile.y * self.size.w];
    }

    pub fn setTile(self: Tilemap, tile: Point, value: u16) void {
        self.data[tile.x + tile.y * self.size.w] = value;
    }

    fn draw(self: @This(), tileset: Tileset) void {
        var y: usize = 0;
        while (y < self.size.h) : (y += 1) {
            var x: usize = 0;
            while (x < self.size.w) : (x += 1) {
                const tile = self.data[x + y * self.size.w];
                if (tile == 0) continue;

                // deal with flipped/rotated tiles
                var info = TileRenderInfo.init(tile - 1, tileset.tile_size);
                const vp = tileset.viewportForTile(tile - 1);

                const tx = @intToFloat(f32, x * tileset.tile_size) + info.ox;
                const ty = @intToFloat(f32, y * tileset.tile_size) + info.oy;
                const mat = info.transformMatrix(tx, ty);

                aya.draw.texViewport(tileset.tex, vp, mat);
            }
        }
    }
};

pub const TilemapLayer = struct {
    name: [:0]const u8,
    tilemap: Tilemap,
    tileset: Tileset,
    shift_dragged: bool = false,
    dragged: bool = false,
    prev_mouse_pos: ImVec2 = .{},

    pub fn init(name: []const u8, size: Size) TilemapLayer {
        return .{
            .name = aya.mem.allocator.dupeZ(u8, name) catch unreachable,
            .tilemap = Tilemap.init(size),
            .tileset = Tileset.init(fixme_tile_size),
        };
    }

    pub fn deinit(self: @This()) void {
        aya.mem.allocator.free(self.name);
        self.tilemap.deinit();
        self.tileset.deinit();
    }

    pub fn draw(self: *@This(), state: *AppState, is_selected: bool) void {
        if (is_selected) {
            self.tilemap.draw(self.tileset);
            self.tileset.draw(state);
        }
    }

    pub fn handleSceneInput(self: *@This(), state: *AppState, camera: Camera, mouse_world: ImVec2) void {
        if (!igIsItemHovered(ImGuiHoveredFlags_None)) return;

        // TODO: this check above really exists in Scene and shouldnt be here. Somehow propograte that data here.
        if (igIsMouseDragging(ImGuiMouseButton_Left, 0) and (igGetIO().KeyAlt or igGetIO().KeySuper)) return;

        if (tileIndexUnderPos(mouse_world, 16)) |tile| {
            const pos = math.Vec2{ .x = @intToFloat(f32, tile.x * self.tileset.tile_size), .y = @intToFloat(f32, tile.y * self.tileset.tile_size) };

            // dont draw the current tile under the mouse if we are shift-dragging
            if (!self.shift_dragged) aya.draw.hollowRect(pos, 16, 16, 1, math.Color.yellow);

            if (ogIsAnyMouseDragging() and igGetIO().KeyShift) { // box selection with left/right mouse + shift
                var dragged_pos = igGetIO().MousePos.subtract(ogGetAnyMouseDragDelta());
                if (tileIndexUnderMouse(dragged_pos, self.tileset.tile_size, camera)) |tile2| {
                    const min_x = @intToFloat(f32, std.math.min(tile.x, tile2.x) * self.tileset.tile_size);
                    const min_y = @intToFloat(f32, std.math.max(tile.y, tile2.y) * self.tileset.tile_size);
                    const max_x = @intToFloat(f32, std.math.max(tile.x, tile2.x) * self.tileset.tile_size);
                    const max_y = @intToFloat(f32, std.math.min(tile.y, tile2.y) * self.tileset.tile_size);

                    const color = if (igIsMouseDragging(ImGuiMouseButton_Left, 0)) math.Color.white else math.Color.red;
                    aya.draw.hollowRect(.{ .x = min_x, .y = max_y }, max_x - min_x, min_y - max_y, 1, color);

                    self.shift_dragged = true;
                }
            } else if (ogIsAnyMouseReleased() and self.shift_dragged) {
                self.shift_dragged = false;

                var drag_delta = if (igIsMouseReleased(ImGuiMouseButton_Left)) ogGetMouseDragDelta(ImGuiMouseButton_Left, 0) else ogGetMouseDragDelta(ImGuiMouseButton_Right, 0);
                var dragged_pos = igGetIO().MousePos.subtract(drag_delta);
                if (tileIndexUnderMouse(dragged_pos, self.tileset.tile_size, camera)) |tile2| {
                    const min_x = std.math.min(tile.x, tile2.x);
                    var min_y = std.math.min(tile.y, tile2.y);
                    const max_x = std.math.max(tile.x, tile2.x);
                    const max_y = std.math.max(tile.y, tile2.y);

                    // either set the tile to a brush or 0 depending on mouse button
                    const tile_value = if (igIsMouseReleased(ImGuiMouseButton_Left)) self.tileset.selected.value + 1 else 0;
                    while (min_y <= max_y) : (min_y += 1) {
                        var x = min_x;
                        while (x <= max_x) : (x += 1) {
                            self.tilemap.setTile(.{ .x = x, .y = min_y }, tile_value);
                        }
                    }
                }
            } else if (ogIsAnyMouseDown() and !igGetIO().KeyShift) {
                // if the mouse was down last frame, get last mouse pos and ensure we dont skip tiles when drawing
                const tile_value = if (igIsMouseDown(ImGuiMouseButton_Left)) self.tileset.selected.value + 1 else 0;
                if (self.dragged) {
                    self.commitInBetweenTiles(tile, camera, tile_value);
                }
                self.dragged = true;
                self.prev_mouse_pos = igGetIO().MousePos;

                self.tilemap.setTile(tile, tile_value);
            } else if (ogIsAnyMouseReleased()) {
                self.dragged = false;
            }
        }

        aya.draw.text(self.name, 0, 0, null);
    }

    pub fn commitInBetweenTiles(self: *@This(), tile: Point, camera: Camera, color: u16) void {
        if (tileIndexUnderMouse(self.prev_mouse_pos, self.tileset.tile_size, camera)) |prev_tile| {
            const abs_x = std.math.absInt(@intCast(i32, tile.x) - @intCast(i32, prev_tile.x)) catch unreachable;
            const abs_y = std.math.absInt(@intCast(i32, tile.y) - @intCast(i32, prev_tile.y)) catch unreachable;
            if (abs_x <= 1 and abs_y <= 1) {
                return;
            }

            editor.utils.bresenham(&self.tilemap, @intToFloat(f32, prev_tile.x), @intToFloat(f32, prev_tile.y), @intToFloat(f32, tile.x), @intToFloat(f32, tile.y), color);
        }
    }
};

pub const AutoTilemapLayer = struct {
    name: [:0]const u8,
    tilemap: Tilemap,
    tileset: Tileset,

    pub fn init(name: []const u8, size: Size) AutoTilemapLayer {
        return .{
            .name = aya.mem.allocator.dupeZ(u8, name) catch unreachable,
            .tilemap = Tilemap.init(size),
            .tileset = Tileset.init(fixme_tile_size),
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

pub const EntityLayer = struct {
    name: [:0]const u8,

    pub fn init(name: []const u8, size: Size) EntityLayer {
        return .{ .name = aya.mem.allocator.dupeZ(u8, name) catch unreachable };
    }

    pub fn deinit(self: @This()) void {
        aya.mem.allocator.free(self.name);
    }

    pub fn draw(self: @This(), state: *AppState, is_selected: bool) void {}

    pub fn handleSceneInput(self: @This(), state: *AppState, camera: Camera, mouse_world: ImVec2) void {
        aya.draw.text(self.name, 100, 0, null);
    }
};

pub const LayerType = enum(u8) {
    tilemap,
    auto_tilemap,
    entity,
};

pub const Layer = union(LayerType) {
    tilemap: TilemapLayer,
    auto_tilemap: AutoTilemapLayer,
    entity: EntityLayer,

    pub fn init(layer_type: LayerType, layer_name: []const u8, size: Size) Layer {
        return switch (layer_type) {
            .tilemap => .{
                .tilemap = TilemapLayer.init(layer_name, size),
            },
            .auto_tilemap => .{
                .auto_tilemap = AutoTilemapLayer.init(layer_name, size),
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
    /// editing UI that is rendered in the Scene
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

pub const Entity = struct {
    name: [:0]const u8,

    pub fn init(name: []const u8) Entity {
        return .{ .name = aya.mem.allocator.dupeZ(u8, name) catch unreachable };
    }

    pub fn deinit(self: @This()) void {
        aya.mem.allocator.free(self.name);
    }
};
