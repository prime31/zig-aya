const std = @import("std");
const aya = @import("aya");
const math = aya.math;
const root = @import("../main.zig"); //@import("root");
usingnamespace @import("imgui");

pub const Scene = struct {
    pass: ?aya.gfx.OffscreenPass = null,
    cam: root.Camera,

    pub fn init() Scene {
        return .{ .cam = root.Camera.init() };
    }

    pub fn deinit(self: @This()) void {
        self.pass.?.deinit();
    }

    pub fn onFileDropped(self: @This(), state: *root.AppState, file: []const u8) void {
        // swallow up any project files
        if (std.mem.endsWith(u8, file, ".editor_extension")) {
            std.debug.print("Scene got an editor extension\n", .{});
        } else if (state.layers.items.len > 0) {
            state.layers.items[state.selected_layer_index].onFileDropped(state, file);
        }
    }

    pub fn draw(self: *@This(), state: *root.AppState) void {
        igPushStyleVarVec2(ImGuiStyleVar_WindowPadding, .{});
        _ = igBegin("Scene", null, ImGuiWindowFlags_NoScrollbar);
        igPopStyleVar(1);

        self.update(state);
        igEnd();
    }

    pub fn update(self: *@This(), state: *root.AppState) void {
        // handle initial creation and resizing of the OffscreenPass
        var content_region = ogGetContentRegionAvail();
        if (self.pass) |pass| {
            if (pass.color_texture.width != content_region.x or pass.color_texture.height != content_region.y) {
                self.pass.?.deinit();
                self.pass = null;
            }
        }

        if (self.pass == null) {
            self.pass = aya.gfx.OffscreenPass.init(@floatToInt(i32, content_region.x), @floatToInt(i32, content_region.y));
            if (self.cam.pos.x == 0 and self.cam.pos.y == 0) {
                // TODO: center cam at startup? seems we get odd imgui content sizes first 2 frames so here is a hack
                self.cam.pos = .{ .x = content_region.x / 3, .y = content_region.y / 2.1 };
            }
        }

        const tmp = ogGetCursorScreenPos();
        ogImage(self.pass.?.color_texture.imTextureID(), @floatToInt(i32, self.pass.?.color_texture.width), @floatToInt(i32, self.pass.?.color_texture.height));
        igSetCursorScreenPos(tmp);
        if (igIsItemHovered(ImGuiHoveredFlags_None)) self.handleInput(state);

        aya.gfx.beginPass(.{ .color = math.Color.gray, .pass = self.pass.?, .trans_mat = self.cam.transMat() });
        // the map area and some decorations
        aya.draw.rect(.{}, @intToFloat(f32, state.map_size.w * state.tile_size), @intToFloat(f32, state.map_size.h * state.tile_size), math.Color.black);
        aya.draw.hollowRect(.{ .x = -2, .y = -2 }, @intToFloat(f32, state.map_size.w * state.tile_size) + 4, @intToFloat(f32, state.map_size.h * state.tile_size) + 4, 2, math.Color.light_gray);

        // outer decorations
        aya.draw.point(.{ .x = -40, .y = -40 }, 20, math.Color.light_gray);
        aya.draw.point(.{ .x = -40, .y = @intToFloat(f32, state.map_size.h * state.tile_size) + 40 }, 20, math.Color.light_gray);
        aya.draw.point(.{ .x = @intToFloat(f32, state.map_size.w * state.tile_size) + 40, .y = -40 }, 20, math.Color.light_gray);
        aya.draw.point(.{ .x = @intToFloat(f32, state.map_size.w * state.tile_size) + 40, .y = @intToFloat(f32, state.map_size.h * state.tile_size) + 40 }, 20, math.Color.light_gray);

        self.render(state);
        aya.gfx.endPass();
    }

    fn render(self: @This(), state: *root.AppState) void {
        // get mouse in world space
        const mouse_screen = igGetIO().MousePos.subtract(ogGetCursorScreenPos());
        const mouse_world = self.cam.igScreenToWorld(mouse_screen);

        // self.drawGridLines();

        for (state.layers.items) |*layer, i| {
            layer.draw(state, state.selected_layer_index == i);
        }

        // the selected layer now handles input and gets to draw on top of all the other layers
        if (state.layers.items.len > 0) {
            state.layers.items[state.selected_layer_index].handleSceneInput(state, self.cam, mouse_world);
        }

        // aya.draw.rect(.{}, 16, 16, math.Color.white);
        // aya.draw.rect(.{ .x = 16, .y = 16 }, 16, 16, math.Color.sky_blue);
        // aya.draw.text("wtf", mouse_world.x, mouse_world.y, null);
        // aya.draw.text("origin", 0, 0, null);
    }

    fn drawGridLines(self: @This()) void {
        var grid_major_size: usize = 16;
        var grid_major_color: math.Color = math.Color.fromBytes(255, 255, 255, 50);
        const bounds = self.cam.bounds();

        // get our first visible grid lines
        const grid_size = @intCast(i32, grid_major_size);
        const grid_size_cutoff = grid_size - 1;
        const first_grid_x = @divTrunc(@floatToInt(i32, bounds.x) - grid_size_cutoff, grid_size_cutoff) * grid_size;
        const first_grid_y = @divTrunc(@floatToInt(i32, bounds.y) - grid_size_cutoff, grid_size_cutoff) * grid_size;

        // TODO: when zoomed out far enough, double the grid lines and only display every other one
        var x = first_grid_x;
        var y = first_grid_y;
        while (@intToFloat(f32, y) < bounds.h) : (y += grid_size) {
            while (@intToFloat(f32, x) < bounds.w) : (x += grid_size) {
                var top = math.Vec2{ .x = @intToFloat(f32, x), .y = @intToFloat(f32, y) };
                var bottom = top.add(.{ .y = bounds.h + @intToFloat(f32, grid_size) });
                aya.draw.line(top, bottom, 1, grid_major_color);
            }
        }

        x = first_grid_x;
        y = first_grid_y;
        while (@intToFloat(f32, x) < bounds.w) : (x += grid_size) {
            while (@intToFloat(f32, y) < bounds.h) : (y += grid_size) {
                var left = math.Vec2{ .x = @intToFloat(f32, x), .y = @intToFloat(f32, y) };
                var right = left.add(.{ .x = bounds.w + @intToFloat(f32, grid_size) });
                aya.draw.line(left, right, 1, grid_major_color);
            }
        }
    }

    fn handleInput(self: *@This(), state: *root.AppState) void {
        // scrolling via drag with alt or super key down
        if (igIsMouseDragging(ImGuiMouseButton_Left, 0) and (igGetIO().KeyAlt or igGetIO().KeySuper)) {
            var scroll_delta = ogGetMouseDragDelta(ImGuiMouseButton_Left, 0);

            self.cam.pos.x -= scroll_delta.x * 1 / self.cam.zoom;
            self.cam.pos.y -= scroll_delta.y * 1 / self.cam.zoom;
            igResetMouseDragDelta(ImGuiMouseButton_Left);

            // dont allow camera to move outside of map bounds
            self.cam.clampToMap(state.map_size.w * state.tile_size, state.map_size.h * state.tile_size, 80);
            return;
        }

        if (igGetIO().MouseWheel != 0) {
            self.cam.zoom += igGetIO().MouseWheel * 0.03;
            self.cam.clampZoom();
            igGetIO().MouseWheel = 0;
            self.cam.clampToMap(state.map_size.w * state.tile_size, state.map_size.h * state.tile_size, 80);
        }
    }
};
