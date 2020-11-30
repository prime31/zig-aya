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
    entities: std.ArrayList(Entity),
    selected_index: usize = 0,
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

    pub fn addEntity(self: *@This(), name: []const u8, position: math.Vec2) void {
        self.id_counter += 1;
        self.entities.append(Entity.init(self.id_counter, name, position)) catch unreachable;
        self.selected_index = self.entities.items.len - 1;
    }

    pub fn draw(self: *@This(), state: *AppState, is_selected: bool) void {
        if (is_selected) {
            self.drawEntitiesWindow();

            if (self.entities.items.len > 0)
                self.drawInspectorWindow(state, &self.entities.items[self.selected_index]);
        }
    }

    pub fn handleSceneInput(self: @This(), state: *AppState, camera: Camera, mouse_world: ImVec2) void {
        for (self.entities.items) |entity| {
            aya.draw.point(entity.transform.pos, 15, math.Color.blue);
        }
    }

    /// draws all the entities in the scene allowing one to be selected which will be displayed in a separate inspector
    fn drawEntitiesWindow(self: *@This()) void {
        defer igEnd();
        var win_name: [50:0]u8 = undefined;
        const tmp_name = std.fmt.bufPrintZ(&win_name, "{}###Entities", .{std.mem.spanZ(&self.name)}) catch unreachable;
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
            if (self.entities.items.len == 1 or index == self.selected_index) {
                self.selected_index = 0;
            } else if (index < self.selected_index) {
                self.selected_index -= 1;
            }
            var entity = self.entities.orderedRemove(index);
            entity.deinit();
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
                        .string => |*str| {
                            inspectors.inspectString(&src_prop.name, str, str.len, &src_prop.value.string);
                        },
                        .float => |*flt| {
                            inspectors.inspectFloat(&src_prop.name, flt, src_prop.value.float);
                        },
                        .int => |*int| {
                            inspectors.inspectInt(&src_prop.name, int, src_prop.value.int);
                        },
                        .bool => |*b| {
                            inspectors.inspectBool(&src_prop.name, b, src_prop.value.bool);
                        },
                        .vec2 => |*v2| {
                            inspectors.inspectVec2(&src_prop.name, v2, src_prop.value.vec2);
                        },
                    }
                }
            }

            if (!is_open) delete_index = i;

            ogDummy(.{ .y = 5 });
        }

        if (delete_index) |index| entity.components.orderedRemove(index).deinit();

        // add component
        var show_add_collider_popup = false;
        if (ogButton("Add Component"))
            ogOpenPopup("add-component");

        if (igBeginPopup("add-component", ImGuiWindowFlags_None)) {
            if (entity.sprite == null and igMenuItemBool("Sprite", null, false, true)) {
                entity.sprite = .{};
            }

            if (entity.collider == null and igMenuItemBool("Collider", null, false, true)) {
                show_add_collider_popup = true;
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

        // TODO: why dont nested popups work properly? this block should be in the previous popup
        if (show_add_collider_popup) ogOpenPopup("add-collider");

        ogSetNextWindowPos(igGetIO().MousePos, ImGuiCond_Appearing, .{ .x = 0.5 });
        if (igBeginPopup("add-collider", ImGuiWindowFlags_None)) {
            // TODO: size the initial colliders if we have a Sprite to get the size from
            if (igMenuItemBool("Box Collider", null, false, true)) {
                entity.collider = .{ .box = .{ .pos = .{}, .w = 10, .h = 10 } };
            }
            if (igMenuItemBool("Circle Collider", null, false, true)) {
                entity.collider = .{ .circle = .{ .pos = .{}, .r = 10 } };
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
            if (disabled) {
                igPushItemFlag(ImGuiItemFlags_Disabled, true);
                igPushStyleVarFloat(ImGuiStyleVar_Alpha, 0.5);
            }

            igPushStyleColorU32(ImGuiCol_Button, root.colors.rgbToU32(25, 180, 45));
            if (ogButtonEx("Add Entity", .{ .x = -1, .y = 0 })) {
                igCloseCurrentPopup();

                // get the next available group
                self.addEntity(name_buf[0..label_sentinel_index], root.scene.cam.screenToWorld(.{ .x = 200, .y = 100 }));
            }
            igPopStyleColor(1);

            if (disabled) {
                igPopItemFlag();
                igPopStyleVar(1);
            }
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
