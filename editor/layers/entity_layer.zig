const std = @import("std");
const root = @import("../main.zig");
const aya = @import("aya");
const math = aya.math;
usingnamespace @import("imgui");

const data = root.data;
const inspectors = @import("../inspectors.zig");

const AppState = data.AppState;
const Entity = data.Entity;
const Size = data.Size;
const Camera = @import("../camera.zig").Camera;

var name_buf: [25:0]u8 = undefined;

pub const EntityLayer = struct {
    name: [25:0]u8 = undefined,
    visible: bool = true,
    entities: std.ArrayList(Entity),
    selected_index: ?usize = null,
    dragged_index: ?usize = null,
    dragged_start_pos: math.Vec2 = .{},
    showing_entity_ctx_menu: bool = false,
    id_counter: u8 = 0,

    pub fn init(name: []const u8, size: Size) EntityLayer {
        var layer = EntityLayer{
            .entities = std.ArrayList(Entity).init(aya.mem.allocator),
        };
        aya.mem.copyZ(u8, &layer.name, name);
        return layer;
    }

    pub fn deinit(self: @This()) void {
        self.entities.deinit();
    }

    pub fn onFileDropped(self: *@This(), state: *AppState, file: []const u8) void {
        if (std.mem.endsWith(u8, file, ".png")) {
            if (self.selected_index) |selected_index| {
                var texture = aya.gfx.Texture.initFromFile(file, .nearest) catch |err| {
                    std.debug.print("EntityLayer failed to load image: {}\n", .{err});
                    return;
                };

                var selected_entity = &self.entities.items[selected_index];
                // TODO: dont leak the sprite texture if we already have a sprite here
                selected_entity.sprite = root.data.Sprite.init(texture);
                if (selected_entity.collider != null) selected_entity.autoFitCollider();
            }
        }
    }

    pub fn addEntity(self: *@This(), name: []const u8, position: math.Vec2) *Entity {
        self.entities.append(Entity.init(self.getNextEntityId(), name, position)) catch unreachable;
        self.selected_index = self.entities.items.len - 1;
        return &self.entities.items[self.entities.items.len - 1];
    }

    fn cloneEntity(self: *@This(), entity: Entity, state: *AppState) *Entity {
        self.entities.append(entity.clone(self.getNextEntityId(), state)) catch unreachable;
        self.selected_index = self.entities.items.len - 1;
        return &self.entities.items[self.entities.items.len - 1];
    }

    fn getNextEntityId(self: *@This()) u8 {
        self.id_counter += 1;
        return self.id_counter;
    }

    pub fn getEntityWithId(self: @This(), id: u8) ?Entity {
        for (self.entities.items) |entity| {
            if (entity.id == id) return entity;
        }
        return null;
    }

    /// draws the entities window and optionally the inspector window
    pub fn draw(self: *@This(), state: *AppState, is_selected: bool) void {
        // TODO: draw entity sprites if we are not selected and self.visible
        if (is_selected) {
            self.drawEntitiesWindow(state);

            if (self.selected_index) |selected_index|
                self.drawInspectorWindow(state, &self.entities.items[selected_index]);
        }
    }

    /// handles input from the Scene view and does aya rendering of entities
    pub fn handleSceneInput(self: *@This(), state: *AppState, camera: Camera, mouse_world: ImVec2) void {
        for (self.entities.items) |entity, i| {
            if (entity.sprite) |sprite| {
                aya.draw.texViewport(sprite.tex, .{ .w = @floatToInt(i32, sprite.tex.width), .h = @floatToInt(i32, sprite.tex.height) }, entity.transformMatrix());
            } else {
                aya.draw.rect(entity.transform.pos, 15 * entity.transform.scale.x, 15 * entity.transform.scale.y, math.Color.blue);
            }

            if (entity.collider) |collider| {
                switch (collider) {
                    .box => |box| {
                        const bounds = box.bounds(entity.transform.pos);
                        aya.draw.hollowRect(.{ .x = bounds.x, .y = bounds.y }, bounds.w, bounds.h, 1, math.Color.white);
                    },
                    .circle => |circle| aya.draw.circle(entity.transform.pos.add(circle.offset), circle.r, 1, 6, math.Color.yellow),
                }
            }

            for (entity.components.items) |comp| {
                for (comp.props.items) |prop| {
                    if (std.meta.activeTag(prop.value) == .entity_link and prop.value.entity_link > 0) {
                        const linked_entity = self.getEntityWithId(prop.value.entity_link).?;
                        aya.draw.line(entity.transform.pos, linked_entity.transform.pos, 1, math.Color.sky_blue);
                    }
                }
            }

            // highlight the selected entity
            if (self.selected_index == i) {
                const bounds = entity.bounds();
                aya.draw.rect(.{ .x = bounds.x, .y = bounds.y }, bounds.w, bounds.h, math.Color.parse("#FFFFFF33") catch unreachable);
                aya.draw.point(entity.transform.pos, 2, math.Color.gray);
            }
        }

        // object picking and dragging
        if (!igIsMouseDown(ImGuiMouseButton_Left)) self.dragged_index = null;

        if (igIsItemHovered(ImGuiHoveredFlags_None)) {
            if (self.dragged_index != null and igIsMouseDragging(ImGuiMouseButton_Left, 2)) {
                // if we are dragging an entity, move it taking into account the snap set
                const drag_delta = ogGetMouseDragDelta(ImGuiMouseButton_Left, 0).scale(1 / camera.zoom);
                const new_pos = self.dragged_start_pos.add(.{ .x = drag_delta.x, .y = drag_delta.y });
                const max_pos = math.Vec2.init(@intToFloat(f32, state.level.map_size.w * state.tile_size), @intToFloat(f32, state.level.map_size.h * state.tile_size));
                self.entities.items[self.dragged_index.?].transform.pos = new_pos.clamp(.{}, max_pos).snapTo(@intToFloat(f32, state.snap_size));
            } else if (igIsMouseClicked(ImGuiMouseButton_Left, false) or igIsMouseClicked(ImGuiMouseButton_Right, false)) {
                // get a world-space rect for object picking with a fudge-factor size of 6 pixels
                var rect = aya.math.Rect{ .x = mouse_world.x - 3, .y = mouse_world.y - 3, .w = 6, .h = 6 };
                self.selected_index = for (self.entities.items) |entity, i| {
                    if (entity.intersects(rect)) {
                        // store off our dragged_index and the position so we can snap it as its dragged around
                        self.dragged_index = i;
                        self.dragged_start_pos = entity.transform.pos;
                        break i;
                    }
                } else null;
            }
        }

        // context menu for entity commands
        if (self.selected_index != null and igBeginPopupContextItem("##entity-scene-context-menu", ImGuiMouseButton_Right)) {
            if (igMenuItemBool("Clone Entity", null, false, true)) _ = self.cloneEntity(self.entities.items[self.selected_index.?], state); 
            igEndPopup();
        }
    }

    /// draws all the entities in the scene allowing one to be selected which will be displayed in a separate inspector
    fn drawEntitiesWindow(self: *@This(), state: *AppState) void {
        defer igEnd();
        var win_name: [150:0]u8 = undefined;
        const tmp_name = std.fmt.bufPrintZ(&win_name, "{s}###Entities", .{std.mem.spanZ(&self.name)}) catch unreachable;
        if (!igBegin(tmp_name, null, ImGuiWindowFlags_None)) return;

        var delete_index: ?usize = null;
        for (self.entities.items) |*entity, i| {
            igPushIDPtr(entity);
            var rename_index: ?usize = null;

            _ = ogButton(icons.grip_horizontal);
            const drag_grip_w = ogGetItemRectSize().x + 5; // 5 is for the SameLine pad
            ogUnformattedTooltip(-1, "Click and drag to reorder");
            igSameLine(0, 10);

            if (ogSelectableBool(&entity.name, self.selected_index == i, ImGuiSelectableFlags_None, .{ .x = igGetWindowContentRegionWidth() - drag_grip_w - 30 })) {
                self.selected_index = i;
            }

            if (igBeginPopupContextItem("##entity-context-menu", ImGuiMouseButton_Right)) {
                if (igMenuItemBool("Rename", null, false, true)) rename_index = i;
                if (igMenuItemBool("Clone Entity", null, false, true)) _ = self.cloneEntity(entity.*, state);
                igEndPopup();
            }

            // make some room for the delete button
            igSameLine(igGetWindowContentRegionWidth() - 8, 0);
            if (ogButton(icons.trash)) {
                delete_index = i;
            }

            if (rename_index != null) {
                std.mem.copy(u8, &name_buf, entity.name[0..]);
                ogOpenPopup("##rename-entity");
            }

            self.renameEntityPopup(entity);
            igPopID();
        }

        if (delete_index) |index| {
            if (self.selected_index) |selected_index| {
                if (self.entities.items.len == 1 or index == selected_index) {
                    self.selected_index = null;
                } else if (index < selected_index) {
                    self.selected_index = selected_index - 1;
                }
            }

            var entity = self.entities.orderedRemove(index);
            entity.deinit();

            // reset any components with a link to the deleted entity
            for (self.entities.items) |*e| {
                for (e.components.items) |*comp| {
                    for (comp.props.items) |*prop| {
                        if (std.meta.activeTag(prop.value) == .entity_link and prop.value.entity_link == entity.id)
                            prop.value.entity_link = 0;
                    }
                }
            }
        }

        if (self.entities.items.len > 0) ogDummy(.{ .y = 5 });

        // right-align the button
        igSetCursorPosX(igGetCursorPosX() + igGetWindowContentRegionWidth() - 75);
        if (ogButton("Add Entity")) {
            ogOpenPopup("##add-entity");
            std.mem.set(u8, &name_buf, 0);
        }

        self.addEntityPopup();
    }

    fn drawInspectorWindow(self: *@This(), state: *AppState, entity: *Entity) void {
        igPushIDPtr(entity);
        defer igPopID();

        defer igEnd();
        if (!igBegin("Inspector###Inspector", null, ImGuiWindowFlags_None)) return;

        inspectors.inspectString("Name", &entity.name, entity.name.len, null);
        ogDummy(.{ .y = 5 });

        if (igCollapsingHeaderBoolPtr("Transform", null, ImGuiTreeNodeFlags_DefaultOpen)) {
            igIndent(10);
            inspectors.inspectTransform(&entity.transform);
            igUnindent(10);
        }
        ogDummy(.{ .y = 5 });

        if (entity.sprite) |*sprite| {
            var is_open = true;
            if (igCollapsingHeaderBoolPtr("Sprite", &is_open, ImGuiTreeNodeFlags_DefaultOpen)) {
                igIndent(10);
                inspectors.inspectSprite(sprite);
                igUnindent(10);
            }

            if (!is_open) entity.sprite = null;
            ogDummy(.{ .y = 5 });
        }

        if (entity.collider) |*collider| {
            var is_open = true;
            const collider_name = if (collider.* == .box) "Box Collider" else "Circle Collider";
            if (igCollapsingHeaderBoolPtr(collider_name, &is_open, ImGuiTreeNodeFlags_DefaultOpen)) {
                igIndent(10);
                inspectors.inspectCollider(collider);

                if (entity.sprite != null) {
                    igSetCursorPosX(igGetCursorPosX() + 100);
                    if (ogButtonEx("Autofit Collider " ++ icons.arrows_alt, .{ .x = -1 }))
                        entity.autoFitCollider();
                }
                igUnindent(10);
            }

            if (!is_open) entity.collider = null;
            ogDummy(.{ .y = 5 });
        }

        // component editor
        var delete_index: ?usize = null;
        for (entity.components.items) |*comp, i| {
            igPushIDPtr(comp);
            defer igPopID();

            var is_open = true;
            var src_comp = state.componentWithId(comp.component_id);
            if (igCollapsingHeaderBoolPtr(&src_comp.name, &is_open, ImGuiTreeNodeFlags_DefaultOpen)) {
                igIndent(10);
                defer igUnindent(10);

                for (comp.props.items) |*prop| {
                    var src_prop = src_comp.propertyWithId(prop.property_id);

                    switch (prop.value) {
                        .string => |*str| inspectors.inspectString(&src_prop.name, str, str.len, &src_prop.value.string),
                        .float => |*flt| inspectors.inspectFloat(&src_prop.name, flt, src_prop.value.float),
                        .int => |*int| inspectors.inspectInt(&src_prop.name, int, src_prop.value.int),
                        .bool => |*b| inspectors.inspectBool(&src_prop.name, b, src_prop.value.bool),
                        .vec2 => |*v2| inspectors.inspectVec2(&src_prop.name, v2, src_prop.value.vec2),
                        .enum_values => |*enums| unreachable,
                        .entity_link => |*entity_link| inspectors.inspectEntityLink(&src_prop.name, entity.id, entity_link, self.entities),
                    }
                }
            }

            if (!is_open) delete_index = i;

            ogDummy(.{ .y = 5 });
        }

        if (delete_index) |index| entity.components.orderedRemove(index).deinit();

        // add component
        if (ogButton("Add Component"))
            ogOpenPopup("add-component");

        if (igBeginPopup("add-component", ImGuiWindowFlags_None)) {
            if (entity.sprite == null and igMenuItemBool("Sprite", null, false, true)) {
                entity.sprite = root.data.Sprite.init(aya.gfx.Texture.initCheckerTexture());
            }

            if (entity.collider == null) {
                if (igMenuItemBool("Box Collider", null, false, true)) {
                    entity.collider = .{ .box = .{ .w = 10, .h = 10 } };
                    entity.autoFitCollider();
                }
                if (igMenuItemBool("Circle Collider", null, false, true)) {
                    entity.collider = .{ .circle = .{ .r = 10 } };
                    entity.autoFitCollider();
                }
            }
            igSeparator();

            // only show components that havent already been added
            for (state.components.items) |comp| blk: {
                for (entity.components.items) |comp_instance| {
                    if (comp_instance.component_id == comp.id) break :blk;
                }

                if (igMenuItemBool(&comp.name, null, false, true)) {
                    entity.addComponent(comp.spawnInstance());
                }
            }

            igEndPopup();
        }
    }

    fn addEntityPopup(self: *@This()) void {
        ogSetNextWindowPos(igGetIO().MousePos, ImGuiCond_Appearing, .{ .x = 0.5 });
        if (igBeginPopup("##add-entity", ImGuiWindowFlags_None)) {
            defer igEndPopup();

            _ = ogInputText("##entity-name", &name_buf, name_buf.len);

            const label_sentinel_index = std.mem.indexOfScalar(u8, &name_buf, 0).?;
            const disabled = label_sentinel_index == 0;
            ogPushDisabled(disabled);

            igPushStyleColorU32(ImGuiCol_Button, root.colors.rgbToU32(25, 180, 45));
            if (ogButtonEx("Add Entity", .{ .x = -1, .y = 0 })) {
                _ = self.addEntity(name_buf[0..label_sentinel_index], root.scene.cam.pos);
                igCloseCurrentPopup();
            }
            igPopStyleColor(1);

            ogPopDisabled(disabled);
        }
    }

    fn renameEntityPopup(self: *@This(), entity: *Entity) void {
        if (igBeginPopup("##rename-entity", ImGuiWindowFlags_None)) {
            _ = ogInputText("", &name_buf, name_buf.len);

            const name = name_buf[0..std.mem.indexOfScalar(u8, &name_buf, 0).?];
            if (ogButtonEx("Rename Entity", .{ .x = -1, .y = 0 }) and name.len > 0) {
                aya.mem.copyZ(u8, &entity.name, name);
                igCloseCurrentPopup();
            }

            igEndPopup();
        }
    }
};
