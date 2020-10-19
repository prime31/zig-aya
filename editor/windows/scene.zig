const std = @import("std");
const aya = @import("aya");
const math = aya.math;
const editor = @import("../editor.zig");
usingnamespace @import("imgui");

pub const Scene = struct {
    pass: ?aya.gfx.OffscreenPass = null,
    cam: editor.Camera = .{},

    pub fn init() Scene {
        return .{};
    }

    pub fn deinit(self: @This()) void {
        self.pass.?.deinit();
    }

    pub fn draw(self: *@This(), state: *editor.AppState) void {
        igPushStyleVarVec2(ImGuiStyleVar_WindowPadding, .{});
        if (igBegin("Scene", null, ImGuiWindowFlags_NoScrollbar)) {
            self.update(state);
        }
        igEnd();
        igPopStyleVar(1);
    }

    pub fn update(self: *@This(), state: *editor.AppState) void {
        // handle initial creation and resizing of the OffscreenPass
        var content_region = ogGetContentRegionAvail();
        if (self.pass) |pass| {
            if (pass.color_tex.width != @floatToInt(i32, content_region.x) or pass.color_tex.height != @floatToInt(i32, content_region.y)) {
                self.pass.?.deinit();
                self.pass = null;
            }
        }

        if (self.pass == null) {
            self.pass = aya.gfx.OffscreenPass.init(@floatToInt(i32, content_region.x), @floatToInt(i32, content_region.y), .nearest);
        }

        const tmp = ogGetCursorScreenPos();
        ogImage(self.pass.?.color_tex.imTextureID(), self.pass.?.color_tex.width, self.pass.?.color_tex.height);
        igSetCursorScreenPos(tmp);
        if (igIsItemHovered(ImGuiHoveredFlags_None)) self.handleInput(state);

        aya.gfx.beginPass(.{ .pass = self.pass.?, .trans_mat = self.cam.transMat() });
        aya.draw.rect(.{}, 200 * 16, 200 * 16, math.Color.black); // the map area defined
        self.render(state);
        aya.gfx.endPass();

        // aya.gfx.beginPass(.{ .pass = self.pass.?, .color_action = .SG_ACTION_DONTCARE, .trans_mat = self.cam.transMat() });
        // aya.draw.hollowRect(.{}, 300, 300, 5, aya.math.Color.sky_blue);
        // const bounds = self.cam.bounds();
        // aya.draw.hollowRect(.{ .x = bounds.x, .y = bounds.y }, bounds.w, bounds.h, 4, math.Color.yellow);
        // aya.gfx.endPass();
    }

    fn render(self: @This(), state: *editor.AppState) void {
        // get mouse in world space
        const mouse_screen = igGetIO().MousePos.subtract(ogGetCursorScreenPos());
        const mouse_world = self.cam.igScreenToWorld(mouse_screen);

        // self.drawGridLines();

        for (state.layers.items) |layer| {
            layer.draw(state);
        }

        // the selected layer now handles input and gets to draw on top of all the other layers
        if (igIsItemHovered(ImGuiHoveredFlags_None) and state.layers.items.len > 0) {
            state.layers.items[state.selected_layer_index].handleSceneInput(state, self.cam, mouse_world);
        }

        aya.draw.rect(.{}, 16, 16, math.Color.white);
        aya.draw.rect(.{ .x = 16, .y = 16 }, 16, 16, math.Color.sky_blue);
        aya.draw.text("wtf", mouse_world.x, mouse_world.y, null);
        aya.draw.text("origin", 0, 0, null);
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

    fn handleInput(self: *@This(), state: *editor.AppState) void {
        // scrolling via drag with alt or super key down
        if (igIsMouseDragging(ImGuiMouseButton_Left, 0) and (igGetIO().KeyAlt or igGetIO().KeySuper)) {
            var scroll_delta = ogGetMouseDragDelta(ImGuiMouseButton_Left, 0);

            self.cam.pos.x -= scroll_delta.x * 1 / self.cam.zoom;
            self.cam.pos.y -= scroll_delta.y * 1 / self.cam.zoom;
            igResetMouseDragDelta(ImGuiMouseButton_Left);
            return;
        }

        if (igGetIO().MouseWheel != 0) {
            self.cam.zoom += igGetIO().MouseWheel * 0.03;
            self.cam.clampZoom();
            igGetIO().MouseWheel = 0;
        }
    }
};
