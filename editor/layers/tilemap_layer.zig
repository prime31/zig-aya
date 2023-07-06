const std = @import("std");
const aya = @import("aya");
const math = aya.math;
const imgui = @import("imgui");

const root = @import("root");
const data = root.data;

const AppState = data.AppState;
const Tilemap = data.Tilemap;
const Tileset = data.Tileset;
const TileRenderInfo = data.TileRenderInfo;
const Size = data.Size;
const Point = data.Point;
const Camera = @import("../camera.zig").Camera;

pub const TilemapLayer = struct {
    name: [25:0]u8 = undefined,
    visible: bool = true,
    tilemap: Tilemap,
    tileset: Tileset,
    shift_dragged: bool = false,
    dragged: bool = false,
    prev_mouse_pos: imgui.ImVec2 = .{},

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

    pub fn onFileDropped(self: *@This(), _: *AppState, file: []const u8) void {
        if (std.mem.endsWith(u8, file, ".png")) {
            self.tileset.loadTexture(file) catch |err| {
                std.debug.print("tileset failed to load image: {}\n", .{err});
            };
        }
    }

    pub fn draw(self: *@This(), state: *AppState, is_selected: bool) void {
        if (is_selected or self.visible) self.tilemap.draw(self.tileset, null);
        if (is_selected) self.tileset.draw(state);
    }

    pub fn handleSceneInput(self: *@This(), state: *AppState, camera: Camera, mouse_world: imgui.ImVec2) void {
        if (!imgui.igIsItemHovered(imgui.ImGuiHoveredFlags_None)) return;

        // TODO: this check below really exists in Scene and shouldnt be here. Somehow propograte that data here.
        if (imgui.igIsMouseDragging(imgui.ImGuiMouseButton_Left, 0) and (imgui.igGetIO().KeyAlt or imgui.igGetIO().KeySuper)) return;

        if (imgui.ogKeyUp(aya.sdl.SDL_SCANCODE_H)) self.tileset.selected.flipH();
        if (imgui.ogKeyUp(aya.sdl.SDL_SCANCODE_V)) self.tileset.selected.flipV();
        if (imgui.ogKeyUp(aya.sdl.SDL_SCANCODE_R)) self.tileset.selected.flipD();

        if (root.utils.tileIndexUnderPos(state, mouse_world, 16)) |tile| {
            const pos = math.Vec2{ .x = @as(f32, @floatFromInt(tile.x * self.tileset.tile_size)), .y = @as(f32, @floatFromInt(tile.y * self.tileset.tile_size)) };

            // dont draw the current tile brush under the mouse if we are shift-dragging
            if (!self.shift_dragged) {
                TileRenderInfo.init(self.tileset.selected.value, self.tileset.tile_size).draw(self.tileset, pos);
            }

            if (imgui.ogIsAnyMouseDragging() and imgui.igGetIO().KeyShift) { // box selection with left/right mouse + shift
                var dragged_pos = imgui.igGetIO().MousePos.subtract(imgui.ogGetAnyMouseDragDelta());
                if (root.utils.tileIndexUnderMouse(state, dragged_pos, self.tileset.tile_size, camera)) |tile2| {
                    const min_x = @as(f32, @floatFromInt(@min(tile.x, tile2.x) * self.tileset.tile_size));
                    const min_y = @as(f32, @floatFromInt(@max(tile.y, tile2.y) * self.tileset.tile_size + self.tileset.tile_size));
                    const max_x = @as(f32, @floatFromInt(@max(tile.x, tile2.x) * self.tileset.tile_size + self.tileset.tile_size));
                    const max_y = @as(f32, @floatFromInt(@min(tile.y, tile2.y) * self.tileset.tile_size));

                    const color = if (imgui.igIsMouseDragging(imgui.ImGuiMouseButton_Left, 0)) math.Color.white else math.Color.red;
                    aya.draw.hollowRect(.{ .x = min_x, .y = max_y }, max_x - min_x, min_y - max_y, 1, color);

                    self.shift_dragged = true;
                }
            } else if (imgui.ogIsAnyMouseReleased() and self.shift_dragged) {
                self.shift_dragged = false;

                var drag_delta = if (imgui.igIsMouseReleased(imgui.ImGuiMouseButton_Left)) imgui.ogGetMouseDragDelta(imgui.ImGuiMouseButton_Left, 0) else imgui.ogGetMouseDragDelta(imgui.ImGuiMouseButton_Right, 0);
                var dragged_pos = imgui.igGetIO().MousePos.subtract(drag_delta);
                if (root.utils.tileIndexUnderMouse(state, dragged_pos, self.tileset.tile_size, camera)) |tile2| {
                    const min_x = @min(tile.x, tile2.x);
                    var min_y = @min(tile.y, tile2.y);
                    const max_x = @max(tile.x, tile2.x);
                    const max_y = @max(tile.y, tile2.y);

                    // either set the tile to a brush or 0 depending on mouse button
                    const tile_value = if (imgui.igIsMouseReleased(imgui.ImGuiMouseButton_Left)) self.tileset.selected.value + 1 else 0;
                    while (min_y <= max_y) : (min_y += 1) {
                        var x = min_x;
                        while (x <= max_x) : (x += 1) {
                            self.tilemap.setTile(.{ .x = x, .y = min_y }, tile_value);
                        }
                    }
                }
            } else if (imgui.ogIsAnyMouseDown() and !imgui.igGetIO().KeyShift) {
                // if the mouse was down last frame, get last mouse pos and ensure we dont skip tiles when drawing
                const tile_value = if (imgui.igIsMouseDown(imgui.ImGuiMouseButton_Left)) self.tileset.selected.value + 1 else 0;
                if (self.dragged) {
                    self.commitInBetweenTiles(state, tile, camera, tile_value);
                }
                self.dragged = true;
                self.prev_mouse_pos = imgui.igGetIO().MousePos;

                self.tilemap.setTile(tile, tile_value);
            } else if (imgui.ogIsAnyMouseReleased()) {
                self.dragged = false;
            }
        }
    }

    fn commitInBetweenTiles(self: *@This(), state: *AppState, tile: Point, camera: Camera, color: u16) void {
        if (root.utils.tileIndexUnderMouse(state, self.prev_mouse_pos, self.tileset.tile_size, camera)) |prev_tile| {
            const abs_x = std.math.absInt(@as(i32, @intCast(tile.x)) - @as(i32, @intCast(prev_tile.x))) catch unreachable;
            const abs_y = std.math.absInt(@as(i32, @intCast(tile.y)) - @as(i32, @intCast(prev_tile.y))) catch unreachable;
            if (abs_x <= 1 and abs_y <= 1) {
                return;
            }

            root.utils.bresenham(&self.tilemap, @as(f32, @floatFromInt(prev_tile.x)), @as(f32, @floatFromInt(prev_tile.y)), @as(f32, @floatFromInt(tile.x)), @as(f32, @floatFromInt(tile.y)), color);
        }
    }
};
