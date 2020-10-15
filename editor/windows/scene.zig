const std = @import("std");
const aya = @import("aya");
const math = aya.math;
const editor = @import("../editor.zig");
usingnamespace @import("imgui");

const Camera = struct {
    pos: math.Vec2 = .{},
    zoom: f32 = 1,

    pub fn transMat(self: Camera) math.Mat32 {
        var window_half_size = ogGetWindowSize().scale(0.5);

        var transform = math.Mat32.identity;

        var tmp = math.Mat32.identity;
        tmp.translate(-self.pos.x, -self.pos.y);
        transform = tmp.mul(transform);

        tmp = math.Mat32.identity;
        tmp.scale(self.zoom, self.zoom);
        transform = tmp.mul(transform);

        tmp = math.Mat32.identity;
        tmp.translate(window_half_size.x, window_half_size.y);
        transform = tmp.mul(transform);

        return transform;
    }

    pub fn clampZoom(self: *Camera) void {
        self.zoom = std.math.clamp(self.zoom, 0.2, 5);
    }

    pub fn screenToWorld(self: Camera, pos: math.Vec2) math.Vec2 {
        var inv_trans_mat = self.transMat().invert();
        return inv_trans_mat.transformVec2(pos);
    }

    /// calls screenToWorld converting to ImVec2s
    pub fn igScreenToWorld(self: Camera, pos: ImVec2) ImVec2 {
        const tmp = self.screenToWorld(math.Vec2{ .x = pos.x, .y = pos.y });
        return .{ .x = tmp.x, .y = tmp.y };
    }

    pub fn bounds(self: Camera) math.Rect {
        var window_size = ogGetContentRegionAvail();
        var tl = self.screenToWorld(.{});
        var br = self.screenToWorld(math.Vec2{ .x = window_size.x, .y = window_size.y });

        return math.Rect{ .x = tl.x, .y = tl.y, .w = br.x - tl.x, .h = br.y - tl.y };
    }
};

pub const Scene = struct {
    pass: ?aya.gfx.OffscreenPass = null,
    cam: Camera = .{},

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
        self.render(state);
        aya.gfx.endPass();

        aya.gfx.beginPass(.{ .pass = self.pass.?, .color_action = .SG_ACTION_DONTCARE, .trans_mat = self.cam.transMat() });
        aya.draw.hollowRect(.{}, 300, 300, 5, aya.math.Color.sky_blue);
        const bounds = self.cam.bounds();
        aya.draw.hollowRect(.{ .x = bounds.x, .y = bounds.y }, bounds.w, bounds.h, 4, math.Color.yellow);
        aya.gfx.endPass();
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
            state.layers.items[state.selected_layer_index].handleSceneInput(state, mouse_world);
        }

        aya.draw.rect(.{}, 40, 40, math.Color.white);
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
