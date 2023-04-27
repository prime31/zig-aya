const std = @import("std");
const aya = @import("aya");
const math = aya.math;
const root = @import("../main.zig"); //@import("root");
const imgui = @import("imgui");
const icons = imgui.icons;

pub const Scene = struct {
    pass: ?aya.gfx.OffscreenPass = null,
    cam: root.Camera,

    pub fn init() Scene {
        return .{ .cam = root.Camera.init() };
    }

    pub fn deinit(self: @This()) void {
        self.pass.?.deinit();
    }

    pub fn onFileDropped(_: @This(), state: *root.AppState, file: [:0]const u8) void {
        // swallow up any project files and load them
        if (std.mem.endsWith(u8, file, ".editor_extension")) {
            std.debug.print("Scene got an editor extension\n", .{});
        } else if (state.level.layers.items.len > 0) {
            state.level.layers.items[state.selected_layer_index].onFileDropped(state, file);
        }
    }

    pub fn draw(self: *@This(), state: *root.AppState) void {
        imgui.ogPushStyleVarVec2(imgui.ImGuiStyleVar_WindowPadding, .{});
        _ = imgui.igBegin("Scene", null, imgui.ImGuiWindowFlags_NoScrollbar);
        imgui.igPopStyleVar(1);

        self.update(state);
        imgui.igEnd();
    }

    pub fn update(self: *@This(), state: *root.AppState) void {
        // handle initial creation and resizing of the OffscreenPass
        var content_region = imgui.ogGetContentRegionAvail();
        if (self.pass) |pass| {
            if (pass.color_texture.width != content_region.x or pass.color_texture.height != content_region.y) {
                self.pass.?.deinit();
                self.pass = null;
            }
        }

        if (self.pass == null) {
            self.pass = aya.gfx.OffscreenPass.init(@floatToInt(i32, content_region.x), @floatToInt(i32, content_region.y));
            self.cam.window_size = .{ .x = content_region.x, .y = content_region.y };
            if (self.cam.pos.x == 0 and self.cam.pos.y == 0) {
                // TODO: center cam at startup? seems we get odd imgui content sizes first 2 frames so here is a hack
                self.cam.pos = .{ .x = 260, .y = 245 };
            }
        }

        const tmp = imgui.ogGetCursorScreenPos();
        imgui.ogImage(self.pass.?.color_texture.imTextureID(), @floatToInt(i32, self.pass.?.color_texture.width), @floatToInt(i32, self.pass.?.color_texture.height));
        imgui.ogSetCursorScreenPos(tmp);

        // allow dragging a texture from Assets if an EntityLayer is selected
        if (state.level.layers.items.len > 0 and state.level.layers.items[state.selected_layer_index] == .entity and imgui.igBeginDragDropTarget()) {
            defer imgui.igEndDragDropTarget();

            if (imgui.igAcceptDragDropPayload("TEXTURE_ASSET_DRAG", imgui.ImGuiDragDropFlags_None)) |payload| {
                std.debug.assert(payload[0].DataSize == @sizeOf(usize));
                const data = @ptrCast(*usize, @alignCast(@alignOf(usize), payload[0].Data.?));
                const tex_name = state.asset_man.textures.names[data.*];

                const mouse_screen = imgui.igGetIO().MousePos.subtract(imgui.ogGetCursorScreenPos());
                const mouse_world = self.cam.igScreenToWorld(mouse_screen);

                var entity_layer = &state.level.layers.items[state.selected_layer_index].entity;
                var entity = entity_layer.addEntity(tex_name, .{ .x = mouse_world.x, .y = mouse_world.y });
                const index = state.asset_man.textures.indexOfTexture(tex_name);
                entity.sprite = root.data.Sprite.init(state.asset_man.textures.tex, state.asset_man.textures.rects[index], tex_name);
            }
        }

        self.drawToolBar(state);

        // full window button lets us capture any clicks that didnt get used in the toolbar above
        _ = imgui.ogInvisibleButton("##scene_button", imgui.ogGetContentRegionAvail(), imgui.ImGuiButtonFlags_None);
        imgui.ogSetCursorScreenPos(tmp);

        if (imgui.igIsItemHovered(imgui.ImGuiHoveredFlags_None)) self.handleInput(state);

        aya.gfx.beginPass(.{ .color = state.clear_color, .pass = self.pass.?, .trans_mat = self.cam.transMat() });
        // the map area and some decorations
        aya.draw.rect(.{}, @intToFloat(f32, state.level.map_size.w * state.tile_size), @intToFloat(f32, state.level.map_size.h * state.tile_size), state.bg_color);
        aya.draw.hollowRect(.{ .x = -2, .y = -2 }, @intToFloat(f32, state.level.map_size.w * state.tile_size) + 4, @intToFloat(f32, state.level.map_size.h * state.tile_size) + 4, 2, math.Color.light_gray);

        self.render(state);
        aya.gfx.endPass();
    }

    fn render(self: @This(), state: *root.AppState) void {
        // get mouse in world space
        const mouse_screen = imgui.igGetIO().MousePos.subtract(imgui.ogGetCursorScreenPos());
        const mouse_world = self.cam.igScreenToWorld(mouse_screen);

        // self.drawGridLines();

        for (state.level.layers.items, 0..) |*layer, i| {
            layer.draw(state, state.selected_layer_index == i);
            if (state.selected_layer_index == i)
                state.level.layers.items[i].handleSceneInput(state, self.cam, mouse_world);
        }
    }

    fn drawToolBar(self: *@This(), state: *root.AppState) void {
        const cursor_start = imgui.ogGetCursorPos();

        // create a toolbar over the scene view
        imgui.igPushStyleColorU32(imgui.ImGuiCol_Button, root.colors.scene_toolbar_btn);

        // reset position to the start of where we want our button bar
        imgui.igSetCursorPosY(imgui.igGetCursorPosY() + 5);
        imgui.igSetCursorPosX(imgui.igGetCursorPosX() + imgui.igGetWindowContentRegionWidth() - 90);

        if (imgui.ogButton(icons.search)) imgui.igOpenPopup("##zoom-settings", imgui.ImGuiPopupFlags_None);
        imgui.igSameLine(0, 10);
        if (imgui.ogButton(icons.border_all)) imgui.igOpenPopup("##snap-settings", imgui.ImGuiPopupFlags_None);
        imgui.igSameLine(0, 10);
        if (imgui.ogButton(icons.palette)) imgui.igOpenPopup("##color-settings", imgui.ImGuiPopupFlags_None);

        imgui.ogSetCursorPos(cursor_start.add(.{ .x = 5, .y = 5 }));
        if (state.level.layers.items.len > 0) {
            switch (state.level.layers.items[state.selected_layer_index]) {
                .auto_tilemap => |*map| {
                    const label = if (map.draw_raw_pre_map) "Input Map" else "Final Map";
                    if (imgui.ogButton(label)) map.draw_raw_pre_map = !map.draw_raw_pre_map;
                },
                else => {},
            }
        }

        imgui.igPopStyleColor(1);

        imgui.ogSetNextWindowPos(imgui.igGetIO().MousePos, imgui.ImGuiCond_Appearing, .{ .x = 0.5 });
        if (imgui.igBeginPopup("##snap-settings", imgui.ImGuiPopupFlags_None)) {
            _ = imgui.ogDrag(u8, "Snap", &state.snap_size, 0.2, 0, 32);
            imgui.igEndPopup();
        }

        imgui.ogSetNextWindowPos(imgui.igGetIO().MousePos, imgui.ImGuiCond_Appearing, .{ .x = 0.5 });
        if (imgui.igBeginPopup("##zoom-settings", imgui.ImGuiPopupFlags_None)) {
            var zoom = @log2(self.cam.zoom);
            if (imgui.ogDrag(f32, "Zoom", &zoom, 0.1, -1, 2)) {
                self.cam.zoom = std.math.pow(f32, 2, zoom);
                self.cam.clampZoom();
                self.cam.clampToMap(state.level.map_size.w * state.tile_size, state.level.map_size.h * state.tile_size, 80);
            }
            if (imgui.ogButtonEx("Reset Zoom", .{ .x = -1 })) self.cam.zoom = 1;
            imgui.igEndPopup();
        }

        imgui.ogSetNextWindowPos(imgui.igGetIO().MousePos, imgui.ImGuiCond_Appearing, .{ .x = 0.5 });
        if (imgui.igBeginPopup("##color-settings", imgui.ImGuiPopupFlags_None)) {
            var col = state.bg_color.asVec4();
            if (imgui.igColorEdit3("Map Background", &col.x, imgui.ImGuiColorEditFlags_NoInputs))
                state.bg_color = math.Color.fromVec4(col);

            col = state.clear_color.asVec4();
            if (imgui.igColorEdit3("Clear Color", &col.x, imgui.ImGuiColorEditFlags_NoInputs))
                state.clear_color = math.Color.fromVec4(col);

            if (imgui.igColorEdit3("Editor Tint Color", &root.colors.ui_tint.x, imgui.ImGuiColorEditFlags_NoInputs))
                root.colors.setTintColor(root.colors.ui_tint);

            imgui.igEndPopup();
        }
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
        if (imgui.igIsMouseDragging(imgui.ImGuiMouseButton_Left, 2) and (imgui.igGetIO().KeyAlt or imgui.igGetIO().KeySuper)) {
            var scroll_delta = imgui.ogGetMouseDragDelta(imgui.ImGuiMouseButton_Left, 0);

            self.cam.pos.x -= scroll_delta.x * 1 / self.cam.zoom;
            self.cam.pos.y -= scroll_delta.y * 1 / self.cam.zoom;
            imgui.igResetMouseDragDelta(imgui.ImGuiMouseButton_Left);

            // dont allow camera to move outside of map bounds
            self.cam.clampToMap(state.level.map_size.w * state.tile_size, state.level.map_size.h * state.tile_size, 80);
            return;
        }

        if (imgui.igGetIO().MouseWheel != 0) {
            self.cam.zoom += imgui.igGetIO().MouseWheel * 0.1;
            self.cam.clampZoom();
            imgui.igGetIO().MouseWheel = 0;
            self.cam.clampToMap(state.level.map_size.w * state.tile_size, state.level.map_size.h * state.tile_size, 80);
        }
    }
};
