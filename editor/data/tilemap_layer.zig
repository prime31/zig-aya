const std = @import("std");
const aya = @import("aya");
const math = aya.math;
usingnamespace @import("imgui");

const root = @import("root");
const data = @import("data.zig");

const AppState = data.AppState;
const Tilemap = data.Tilemap;
const Tileset = data.Tileset;
const TileRenderInfo = data.TileRenderInfo;
const Size = data.Size;
const Point = data.Point;
const Camera = @import("../camera.zig").Camera;

pub const TilemapLayer = struct {
    name: [25:0]u8 = undefined,
    tilemap: Tilemap,
    tileset: Tileset,
    shift_dragged: bool = false,
    dragged: bool = false,
    prev_mouse_pos: ImVec2 = .{},

    pub fn init(name: []const u8, size: Size, tile_size: usize) TilemapLayer {
        var layer = TilemapLayer{
            .tilemap = Tilemap.init(size),
            .tileset = Tileset.init(tile_size),
        };
        aya.mem.copyZ(u8, &layer.name, name);
        return layer;
    }

    pub fn deinit(self: @This()) void {
        self.tilemap.deinit();
        self.tileset.deinit();
    }

    pub fn onFileDropped(self: *@This(), state: *AppState, file: []const u8) void {
        if (std.mem.endsWith(u8, file, ".png")) {
            self.tileset.loadTexture(file) catch |err| {
                std.debug.print("tileset failed to load image: {}\n", .{err});
            };
        }
    }

    pub fn draw(self: *@This(), state: *AppState, is_selected: bool) void {
        self.tilemap.draw(self.tileset, null);
        if (is_selected) {
            self.tileset.draw();
        }
    }

    pub fn handleSceneInput(self: *@This(), state: *AppState, camera: Camera, mouse_world: ImVec2) void {
        if (!igIsItemHovered(ImGuiHoveredFlags_None)) return;

        // TODO: this check below really exists in Scene and shouldnt be here. Somehow propograte that data here.
        if (igIsMouseDragging(ImGuiMouseButton_Left, 0) and (igGetIO().KeyAlt or igGetIO().KeySuper)) return;

        if (ogKeyUp(aya.sokol.SAPP_KEYCODE_H)) self.tileset.selected.flipH();
        if (ogKeyUp(aya.sokol.SAPP_KEYCODE_V)) self.tileset.selected.flipV();
        if (ogKeyUp(aya.sokol.SAPP_KEYCODE_R)) self.tileset.selected.flipD();

        if (root.utils.tileIndexUnderPos(state, mouse_world, 16)) |tile| {
            const pos = math.Vec2{ .x = @intToFloat(f32, tile.x * self.tileset.tile_size), .y = @intToFloat(f32, tile.y * self.tileset.tile_size) };

            // dont draw the current tile brush under the mouse if we are shift-dragging
            if (!self.shift_dragged) {
                TileRenderInfo.init(self.tileset.selected.value, self.tileset.tile_size).draw(self.tileset, pos);
            }

            if (ogIsAnyMouseDragging() and igGetIO().KeyShift) { // box selection with left/right mouse + shift
                var dragged_pos = igGetIO().MousePos.subtract(ogGetAnyMouseDragDelta());
                if (root.utils.tileIndexUnderMouse(state, dragged_pos, self.tileset.tile_size, camera)) |tile2| {
                    const min_x = @intToFloat(f32, std.math.min(tile.x, tile2.x) * self.tileset.tile_size);
                    const min_y = @intToFloat(f32, std.math.max(tile.y, tile2.y) * self.tileset.tile_size + self.tileset.tile_size);
                    const max_x = @intToFloat(f32, std.math.max(tile.x, tile2.x) * self.tileset.tile_size + self.tileset.tile_size);
                    const max_y = @intToFloat(f32, std.math.min(tile.y, tile2.y) * self.tileset.tile_size);

                    const color = if (igIsMouseDragging(ImGuiMouseButton_Left, 0)) math.Color.white else math.Color.red;
                    aya.draw.hollowRect(.{ .x = min_x, .y = max_y }, max_x - min_x, min_y - max_y, 1, color);

                    self.shift_dragged = true;
                }
            } else if (ogIsAnyMouseReleased() and self.shift_dragged) {
                self.shift_dragged = false;

                var drag_delta = if (igIsMouseReleased(ImGuiMouseButton_Left)) ogGetMouseDragDelta(ImGuiMouseButton_Left, 0) else ogGetMouseDragDelta(ImGuiMouseButton_Right, 0);
                var dragged_pos = igGetIO().MousePos.subtract(drag_delta);
                if (root.utils.tileIndexUnderMouse(state, dragged_pos, self.tileset.tile_size, camera)) |tile2| {
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
                    self.commitInBetweenTiles(state, tile, camera, tile_value);
                }
                self.dragged = true;
                self.prev_mouse_pos = igGetIO().MousePos;

                self.tilemap.setTile(tile, tile_value);
            } else if (ogIsAnyMouseReleased()) {
                self.dragged = false;
            }
        }
    }

    fn commitInBetweenTiles(self: *@This(), state: *AppState, tile: Point, camera: Camera, color: u16) void {
        if (root.utils.tileIndexUnderMouse(state, self.prev_mouse_pos, self.tileset.tile_size, camera)) |prev_tile| {
            const abs_x = std.math.absInt(@intCast(i32, tile.x) - @intCast(i32, prev_tile.x)) catch unreachable;
            const abs_y = std.math.absInt(@intCast(i32, tile.y) - @intCast(i32, prev_tile.y)) catch unreachable;
            if (abs_x <= 1 and abs_y <= 1) {
                return;
            }

            root.utils.bresenham(&self.tilemap, @intToFloat(f32, prev_tile.x), @intToFloat(f32, prev_tile.y), @intToFloat(f32, tile.x), @intToFloat(f32, tile.y), color);
        }
    }
};