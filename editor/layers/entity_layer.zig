const std = @import("std");
const root = @import("../main.zig");
const aya = @import("aya");
const math = aya.math;
const imgui = @import("imgui");
const icons = imgui.icons;

const data = root.data;
const inspectors = @import("../inspectors.zig");

const AppState = data.AppState;
const Entity = data.Entity;
const Size = data.Size;
const Camera = @import("../camera.zig").Camera;

var name_buf: [25:0]u8 = undefined;
var dnd_swap: ?struct { remove_from: usize, insert_into: usize } = null;

pub const EntityLayer = struct {
    name: [25:0]u8 = undefined,
    visible: bool = true,
    entities: std.ArrayList(Entity),
    id_counter: u8 = 0,
    selected_index: ?usize = null,
    dragged_index: ?usize = null,
    dragged_start_pos: math.Vec2 = .{},
    showing_entity_ctx_menu: bool = false,

    pub fn init(name: []const u8, size: Size) EntityLayer {
        _ = size;
        var layer = EntityLayer{
            .entities = std.ArrayList(Entity).init(aya.mem.allocator),
        };
        aya.mem.copyZ(u8, &layer.name, name);
        return layer;
    }

    pub fn deinit(self: @This()) void {
        self.entities.deinit();
    }

    pub fn onFileDropped(self: *@This(), _: *AppState, file: [:0]const u8) void {
        if (std.mem.endsWith(u8, file, ".png")) {
            if (self.selected_index) |selected_index| {
                var texture = aya.gfx.Texture.initFromFile(file, .nearest) catch |err| {
                    std.debug.print("EntityLayer failed to load image: {}\n", .{err});
                    return;
                };

                var selected_entity = &self.entities.items[selected_index];
                // TODO: dont leak the sprite texture if we already have a sprite here
                selected_entity.sprite = root.data.Sprite.init(texture, .{ .w = @floatToInt(i32, texture.width), .h = @floatToInt(i32, texture.height) }, file);
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
        if (is_selected) {
            self.drawEntitiesWindow(state);

            if (self.selected_index) |selected_index|
                self.drawInspectorWindow(state, &self.entities.items[selected_index]);
        } else if (self.visible) {
            // if we are not selected but visible then draw just the sprites
            for (self.entities.items) |entity| {
                if (entity.sprite) |sprite| aya.draw.texViewport(sprite.tex, sprite.rect, entity.transformMatrix());
            }
        }
    }

    /// handles input from the Scene view and does aya rendering of entities
    pub fn handleSceneInput(self: *@This(), state: *AppState, camera: Camera, mouse_world: imgui.ImVec2) void {
        for (self.entities.items) |entity, i| {
            if (entity.sprite) |sprite| {
                aya.draw.texViewport(sprite.tex, sprite.rect, entity.transformMatrix());
            } else {
                // if we have no sprite we just draw the bounds, which default to some size so that we have something to look at and select
                const bounds = entity.bounds();
                aya.draw.rect(.{ .x = bounds.x, .y = bounds.y }, bounds.w, bounds.h, math.Color.blue);
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
                    if (std.meta.activeTag(prop.value) == .entity_link and prop.value.entity_link.entity > 0) {
                        const linked_entity = self.getEntityWithId(prop.value.entity_link.entity).?;
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
        if (!imgui.igIsMouseDown(imgui.ImGuiMouseButton_Left)) self.dragged_index = null;

        if (imgui.igIsItemHovered(imgui.ImGuiHoveredFlags_None)) {
            // make sure alt/super isnt pressed since that is a Scene drag!
            if (self.dragged_index != null and imgui.igIsMouseDragging(imgui.ImGuiMouseButton_Left, 2) and !(imgui.igGetIO().KeyAlt or imgui.igGetIO().KeySuper)) {
                // if we are dragging an entity, move it taking into account the snap set
                const drag_delta = imgui.ogGetMouseDragDelta(imgui.ImGuiMouseButton_Left, 0).scale(1 / camera.zoom);
                const new_pos = self.dragged_start_pos.add(.{ .x = drag_delta.x, .y = drag_delta.y });
                const max_pos = math.Vec2.init(@intToFloat(f32, state.level.map_size.w * state.tile_size), @intToFloat(f32, state.level.map_size.h * state.tile_size));
                self.entities.items[self.dragged_index.?].transform.pos = new_pos.clamp(.{}, max_pos).snapTo(@intToFloat(f32, state.snap_size));
            } else if (imgui.igIsMouseClicked(imgui.ImGuiMouseButton_Left, false) or imgui.igIsMouseClicked(imgui.ImGuiMouseButton_Right, false)) {
                // get a world-space rect for object picking with a fudge-factor size of 6 pixels
                var rect = aya.math.Rect{ .x = mouse_world.x - 3, .y = mouse_world.y - 3, .w = 6, .h = 6 };
                self.selected_index = for (self.entities.items) |entity, i| {
                    if (entity.selectable and entity.intersects(rect)) {
                        // store off our dragged_index and the position so we can snap it as its dragged around
                        self.dragged_index = i;
                        self.dragged_start_pos = entity.transform.pos;
                        break i;
                    }
                } else null;
            }
        }

        // allow moving the selected entity with the arrow keys
        if (self.selected_index) |index| {
            var moved = false;
            const move_amt = if (state.snap_size > 0) @intToFloat(f32, state.snap_size) else 1;
            var delta = aya.math.Vec2{};

            if (imgui.ogKeyPressed(aya.sdl.SDL_SCANCODE_LEFT)) {
                delta.x -= move_amt;
                moved = true;
            }
            if (imgui.ogKeyPressed(aya.sdl.SDL_SCANCODE_RIGHT)) {
                delta.x = move_amt;
                moved = true;
            }
            if (imgui.ogKeyPressed(aya.sdl.SDL_SCANCODE_UP)) {
                delta.y -= move_amt;
                moved = true;
            }
            if (imgui.ogKeyPressed(aya.sdl.SDL_SCANCODE_DOWN)) {
                delta.y = move_amt;
                moved = true;
            }
            if (moved) {
                delta = delta.add(self.entities.items[index].transform.pos);
                const max_pos = math.Vec2.init(@intToFloat(f32, state.level.map_size.w * state.tile_size), @intToFloat(f32, state.level.map_size.h * state.tile_size));
                self.entities.items[index].transform.pos = delta.clamp(.{}, max_pos); //.snapTo(@intToFloat(f32, state.snap_size));
            }
        }

        // context menu for entity commands
        if (self.selected_index != null and imgui.igBeginPopupContextItem("##entity-scene-context-menu", imgui.ImGuiMouseButton_Right)) {
            if (imgui.igMenuItemBool("Clone Entity", null, false, true)) _ = self.cloneEntity(self.entities.items[self.selected_index.?], state);
            imgui.igEndPopup();
        }
    }

    /// draws all the entities in the scene allowing one to be selected which will be displayed in a separate inspector
    fn drawEntitiesWindow(self: *@This(), state: *AppState) void {
        defer imgui.igEnd();
        var win_name: [150:0]u8 = undefined;
        const tmp_name = std.fmt.bufPrintZ(&win_name, "{s}###Entities", .{std.mem.sliceTo(&self.name, 0)}) catch unreachable;
        if (!imgui.igBegin(tmp_name, null, imgui.ImGuiWindowFlags_None)) return;

        var delete_index: ?usize = null;
        for (self.entities.items) |*entity, i| {
            imgui.igPushIDPtr(entity);
            var rename_index: ?usize = null;

            // make a drop zone above each entity
            const cursor = imgui.ogGetCursorPos();
            imgui.ogSetCursorPos(cursor.subtract(.{ .y = 6 }));
            _ = imgui.ogInvisibleButton("", .{ .x = -1, .y = 8 }, imgui.ImGuiButtonFlags_None);

            if (imgui.igBeginDragDropTarget()) {
                defer imgui.igEndDragDropTarget();

                if (imgui.igAcceptDragDropPayload("ENTITY_DRAG", imgui.ImGuiDragDropFlags_None)) |payload| {
                    std.debug.assert(payload[0].DataSize == @sizeOf(usize));
                    const dragged_index = @ptrCast(*usize, @alignCast(@alignOf(usize), payload[0].Data.?));
                    if (i > dragged_index.* and i - dragged_index.* > 1) {
                        dnd_swap = .{ .remove_from = dragged_index.*, .insert_into = i - 1 };
                    } else if (i < dragged_index.*) {
                        dnd_swap = .{ .remove_from = dragged_index.*, .insert_into = i };
                    }
                }
            }
            imgui.ogSetCursorPos(cursor);

            _ = imgui.ogButton(icons.grip_horizontal);
            if (imgui.igBeginDragDropSource(imgui.ImGuiDragDropFlags_None)) {
                defer imgui.igEndDragDropSource();

                _ = imgui.igSetDragDropPayload("ENTITY_DRAG", &i, @sizeOf(usize), imgui.ImGuiCond_Once);
                imgui.igText(std.mem.sliceTo(&entity.name, 0));
            }

            const drag_grip_w = imgui.ogGetItemRectSize().x + 5; // 5 is for the SameLine pad
            imgui.ogUnformattedTooltip(-1, "Click and drag to reorder");
            imgui.igSameLine(0, 10);

            if (imgui.ogSelectableBool(&entity.name, self.selected_index == i, imgui.ImGuiSelectableFlags_None, .{ .x = imgui.igGetWindowContentRegionWidth() - drag_grip_w - 55 })) {
                self.selected_index = i;
            }

            if (imgui.igBeginPopupContextItem("##entity-context-menu", imgui.ImGuiMouseButton_Right)) {
                if (imgui.igMenuItemBool("Rename", null, false, true)) rename_index = i;
                if (imgui.igMenuItemBool("Clone Entity", null, false, true)) _ = self.cloneEntity(entity.*, state);
                imgui.igEndPopup();
            }

            imgui.igSameLine(imgui.igGetWindowContentRegionWidth() - 35, 0);
            if (imgui.ogButtonEx(if (entity.selectable) icons.lock_open else icons.lock, .{ .x = 23 }))
                entity.selectable = !entity.selectable;
            imgui.ogUnformattedTooltip(100, "Entity selectable in scene view state");

            // make some room for the delete button
            imgui.igSameLine(imgui.igGetWindowContentRegionWidth() - 8, 0);
            if (imgui.ogButton(icons.trash))
                delete_index = i;

            // make a drop zone below only the last layer
            if (self.entities.items.len - 1 == i) {
                const cursor2 = imgui.ogGetCursorPos();
                imgui.ogSetCursorPos(cursor.add(.{ .y = imgui.igGetFrameHeight() - 6 }));
                _ = imgui.ogInvisibleButton("", .{ .x = -1, .y = 8 }, imgui.ImGuiButtonFlags_None);

                if (imgui.igBeginDragDropTarget()) {
                    defer imgui.igEndDragDropTarget();

                    if (imgui.igAcceptDragDropPayload("ENTITY_DRAG", imgui.ImGuiDragDropFlags_None)) |payload| {
                        std.debug.assert(payload[0].DataSize == @sizeOf(usize));
                        const dropped_index = @ptrCast(*usize, @alignCast(@alignOf(usize), payload[0].Data.?));
                        if (dropped_index.* != i)
                            dnd_swap = .{ .remove_from = dropped_index.*, .insert_into = i };
                    }
                }
                imgui.ogSetCursorPos(cursor2);
            }

            if (rename_index != null) {
                std.mem.copy(u8, &name_buf, entity.name[0..]);
                imgui.ogOpenPopup("##rename-entity");
            }

            self.renameEntityPopup(entity);
            imgui.igPopID();
        }

        if (dnd_swap) |swapper| {
            const removed = self.entities.orderedRemove(swapper.remove_from);
            self.entities.insert(swapper.insert_into, removed) catch unreachable;

            // handle updating the selected index
            if (self.selected_index) |selected_index| {
                if (swapper.remove_from == selected_index) {
                    self.selected_index = swapper.insert_into;
                } else if (swapper.remove_from < selected_index and swapper.insert_into >= selected_index) {
                    self.selected_index.? -= 1;
                } else if (swapper.remove_from > selected_index and swapper.insert_into <= selected_index) {
                    self.selected_index.? += 1;
                }
            }
            dnd_swap = null;
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
                        if (std.meta.activeTag(prop.value) == .entity_link and prop.value.entity_link.entity == entity.id)
                            prop.value.entity_link.entity = 0;
                    }
                }
            }
        }

        if (self.entities.items.len > 0) imgui.ogDummy(.{ .y = 5 });

        // right-align the button
        imgui.igSetCursorPosX(imgui.igGetCursorPosX() + imgui.igGetWindowContentRegionWidth() - 75);
        if (imgui.ogButton("Add Entity")) {
            imgui.ogOpenPopup("##add-entity");
            std.mem.set(u8, &name_buf, 0);
        }

        self.addEntityPopup();
    }

    fn drawInspectorWindow(self: *@This(), state: *AppState, entity: *Entity) void {
        imgui.igPushIDPtr(entity);
        defer imgui.igPopID();

        defer imgui.igEnd();
        if (!imgui.igBegin("Inspector###Inspector", null, imgui.ImGuiWindowFlags_None)) return;

        inspectors.inspectString("Name", &entity.name, entity.name.len, null);
        imgui.ogDummy(.{ .y = 5 });

        if (imgui.igCollapsingHeaderBoolPtr("Transform", null, imgui.ImGuiTreeNodeFlags_DefaultOpen)) {
            imgui.igIndent(10);
            inspectors.inspectTransform(&entity.transform);
            imgui.igUnindent(10);
        }
        imgui.ogDummy(.{ .y = 5 });

        if (entity.sprite) |*sprite| {
            var is_open = true;
            if (imgui.igCollapsingHeaderBoolPtr("Sprite", &is_open, imgui.ImGuiTreeNodeFlags_DefaultOpen)) {
                imgui.igIndent(10);
                inspectors.inspectSprite(state, sprite);
                imgui.igUnindent(10);
            }

            if (!is_open) {
                entity.sprite.?.deinit();
                entity.sprite = null;
            }
            imgui.ogDummy(.{ .y = 5 });
        }

        if (entity.collider) |*collider| {
            var is_open = true;
            const collider_name = if (collider.* == .box) "Box Collider" else "Circle Collider";
            if (imgui.igCollapsingHeaderBoolPtr(collider_name, &is_open, imgui.ImGuiTreeNodeFlags_DefaultOpen)) {
                imgui.igIndent(10);
                inspectors.inspectCollider(collider);

                if (entity.sprite != null) {
                    imgui.igSetCursorPosX(imgui.igGetCursorPosX() + 100);
                    if (imgui.ogButtonEx("Autofit Collider " ++ icons.arrows_alt, .{ .x = -1 }))
                        entity.autoFitCollider();
                }
                imgui.igUnindent(10);
            }

            if (!is_open) entity.collider = null;
            imgui.ogDummy(.{ .y = 5 });
        }

        // component editor
        var delete_index: ?usize = null;
        for (entity.components.items) |*comp, i| {
            imgui.igPushIDPtr(comp);
            defer imgui.igPopID();

            var is_open = true;
            var src_comp = state.componentWithId(comp.component_id);
            if (imgui.igCollapsingHeaderBoolPtr(&src_comp.name, &is_open, imgui.ImGuiTreeNodeFlags_DefaultOpen)) {
                imgui.igIndent(10);
                defer imgui.igUnindent(10);

                for (comp.props.items) |*prop| {
                    var src_prop = src_comp.propertyWithId(prop.property_id);

                    switch (prop.value) {
                        .string => |*str| inspectors.inspectString(&src_prop.name, str, str.len, &src_prop.value.string),
                        .float => |*flt| inspectors.inspectFloat(&src_prop.name, flt, src_prop.value.float),
                        .int => |*int| inspectors.inspectInt(&src_prop.name, int, src_prop.value.int),
                        .bool => |*b| inspectors.inspectBool(&src_prop.name, b, src_prop.value.bool),
                        .vec2 => |*v2| inspectors.inspectVec2(&src_prop.name, v2, src_prop.value.vec2),
                        .enum_value => |*enum_value| inspectors.inspectEnum(&src_prop.name, &enum_value.index, src_prop.value.enum_values),
                        .entity_link => |*entity_link| inspectors.inspectEntityLink(&src_prop.name, entity.id, &entity_link.entity, self.entities),
                    }
                }
            }

            if (!is_open) delete_index = i;

            imgui.ogDummy(.{ .y = 5 });
        }

        if (delete_index) |index| entity.components.orderedRemove(index).deinit();

        // add component
        if (imgui.ogButton("Add Component"))
            imgui.ogOpenPopup("add-component");

        if (imgui.igBeginPopup("add-component", imgui.ImGuiWindowFlags_None)) {
            if (entity.sprite == null and imgui.igMenuItemBool("Sprite", null, false, true)) {
                entity.sprite = root.data.Sprite.initNoTexture(state);
            }

            if (entity.collider == null) {
                if (imgui.igMenuItemBool("Box Collider", null, false, true)) {
                    entity.collider = .{ .box = .{ .w = 10, .h = 10 } };
                    entity.autoFitCollider();
                }
                if (imgui.igMenuItemBool("Circle Collider", null, false, true)) {
                    entity.collider = .{ .circle = .{ .r = 10 } };
                    entity.autoFitCollider();
                }
            }
            imgui.igSeparator();

            // only show components that havent already been added
            for (state.components.items) |comp| blk: {
                for (entity.components.items) |comp_instance| {
                    if (comp_instance.component_id == comp.id) break :blk;
                }

                if (imgui.igMenuItemBool(&comp.name, null, false, true)) {
                    entity.addComponent(comp.spawnInstance());
                }
            }

            imgui.igEndPopup();
        }
    }

    fn addEntityPopup(self: *@This()) void {
        imgui.ogSetNextWindowPos(imgui.igGetIO().MousePos, imgui.ImGuiCond_Appearing, .{ .x = 0.5 });
        if (imgui.igBeginPopup("##add-entity", imgui.ImGuiWindowFlags_None)) {
            defer imgui.igEndPopup();

            _ = imgui.ogInputText("##entity-name", &name_buf, name_buf.len);

            const label_sentinel_index = std.mem.indexOfScalar(u8, &name_buf, 0).?;
            const disabled = label_sentinel_index == 0;
            imgui.ogPushDisabled(disabled);

            imgui.igPushStyleColorU32(imgui.ImGuiCol_Button, root.colors.rgbToU32(25, 180, 45));
            if (imgui.ogButtonEx("Add Entity", .{ .x = -1, .y = 0 })) {
                _ = self.addEntity(name_buf[0..label_sentinel_index], root.scene.cam.pos);
                imgui.igCloseCurrentPopup();
            }
            imgui.igPopStyleColor(1);

            imgui.ogPopDisabled(disabled);
        }
    }

    fn renameEntityPopup(_: *@This(), entity: *Entity) void {
        if (imgui.igBeginPopup("##rename-entity", imgui.ImGuiWindowFlags_None)) {
            _ = imgui.ogInputText("", &name_buf, name_buf.len);

            const name = name_buf[0..std.mem.indexOfScalar(u8, &name_buf, 0).?];
            if (imgui.ogButtonEx("Rename Entity", .{ .x = -1, .y = 0 }) and name.len > 0) {
                aya.mem.copyZ(u8, &entity.name, name);
                imgui.igCloseCurrentPopup();
            }

            imgui.igEndPopup();
        }
    }
};
