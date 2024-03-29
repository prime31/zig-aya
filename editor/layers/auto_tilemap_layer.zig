const std = @import("std");
const aya = @import("aya");
const math = aya.math;
const imgui = @import("imgui");
const icons = imgui.icons;

const root = @import("../main.zig");
const data = root.data;

const AppState = data.AppState;
const Tilemap = data.Tilemap;
const Tileset = data.Tileset;
const TileRenderInfo = data.TileRenderInfo;
const Brushset = data.Brushset;
const Size = data.Size;
const RuleSet = data.RuleSet;
const Rule = data.Rule;
const Point = data.Point;
const Camera = @import("../camera.zig").Camera;

var name_buf: [25:0]u8 = undefined;
var new_rule_label_buf: [25:0]u8 = undefined;
var group_label_buf: [25:0]u8 = undefined;
var rule_label_buf: [25:0]u8 = undefined;
var rename_group_buf: [25:0]u8 = undefined;

var nine_slice_selected: ?usize = null;

var drag_drop_state = struct {
    source: union(enum) {
        rule: *Rule,
        group: u8,
    } = undefined,
    from: usize = 0,
    to: usize = 0,
    above_group: bool = false,
    completed: bool = false,
    active: bool = false,
    rendering_group: bool = false,
    dropped_in_group: bool = false,

    pub fn isGroup(self: @This()) bool {
        return switch (self.source) {
            .group => true,
            else => false,
        };
    }

    pub fn handle(self: *@This(), rules: *std.ArrayList(Rule)) void {
        self.completed = false;
        switch (self.source) {
            .group => swapGroups(rules),
            else => swapRules(rules),
        }
        self.above_group = false;
    }
}{};

/// drawing of the pre-map data (raw, pre-rules) the Tilemap is used. Final rule-processed map is stored n AutoTilemapLayer.
pub const AutoTilemapLayer = struct {
    name: [25:0]u8 = undefined,
    visible: bool = true,
    tilemap: Tilemap,
    final_map: []u16,
    random_map_data: []Randoms,
    brushset: Brushset,
    tileset: Tileset,
    ruleset: RuleSet,
    ruleset_groups: std.AutoHashMap(u8, []const u8),
    draw_raw_pre_map: bool = true,
    map_dirty: bool = false,
    shift_dragged: bool = false,
    dragged: bool = false,
    prev_mouse_pos: imgui.ImVec2 = .{},

    pub const Randoms = struct {
        float: f32,
        int: usize,
    };

    pub fn init(name: []const u8, size: Size, tile_size: usize) AutoTilemapLayer {
        var tmp_data = aya.mem.allocator.alloc(u16, size.w * size.h) catch unreachable;
        @memset(tmp_data, 0);

        var layer = AutoTilemapLayer{
            .tilemap = Tilemap.init(size),
            .final_map = tmp_data,
            .random_map_data = aya.mem.allocator.alloc(Randoms, size.w * size.h) catch unreachable,
            .brushset = Brushset.init(tile_size),
            .tileset = Tileset.init(tile_size),
            .ruleset = RuleSet.init(),
            .ruleset_groups = std.AutoHashMap(u8, []const u8).init(aya.mem.allocator), // TODO: maybe [:0]u8?
        };
        aya.mem.copyZ(u8, &layer.name, name);
        layer.generateRandomData();
        return layer;
    }

    pub fn deinit(self: @This()) void {
        self.tilemap.deinit();
        aya.mem.allocator.free(self.final_map);
        aya.mem.allocator.free(self.random_map_data);
        self.brushset.deinit();
        self.tileset.deinit();
        self.ruleset.deinit();
    }

    pub fn onFileDropped(self: *@This(), _: *AppState, file: []const u8) void {
        if (std.mem.endsWith(u8, file, ".png")) {
            self.tileset.loadTexture(file) catch |err| {
                std.debug.print("tileset failed to load image: {}\n", .{err});
            };
        }
    }

    /// regenerates the stored random data per tile. Needs to be called on seed change or map resize
    pub fn generateRandomData(self: *@This()) void {
        aya.math.rand.seed(self.ruleset.seed);

        // pre-generate random data per tile
        var i: usize = 0;
        while (i < self.tilemap.size.w * self.tilemap.size.h) : (i += 1) {
            self.random_map_data[i] = .{
                .float = aya.math.rand.float(f32),
                .int = aya.math.rand.int(usize),
            };
        }
    }

    pub fn getGroupName(self: @This(), group: u8) []const u8 {
        return self.ruleset_groups.get(group) orelse "Unnamed Group";
    }

    pub fn renameGroup(self: *@This(), group: u8, name: []const u8) void {
        if (self.ruleset_groups.fetchRemove(group)) |entry| {
            aya.mem.allocator.free(entry.value);
        }
        self.ruleset_groups.put(group, aya.mem.allocator.dupe(u8, name) catch unreachable) catch unreachable;
    }

    pub fn removeGroupIfEmpty(self: *@This(), group: u8) void {
        for (self.ruleset.rules.items) |rule| {
            if (rule.group == group) return;
        }
        if (self.ruleset_groups.fetchRemove(group)) |entry| {
            aya.mem.allocator.free(entry.value);
        }
    }

    fn generateFinalMap(self: *@This()) void {
        var y: usize = 0;
        while (y < self.tilemap.size.h) : (y += 1) {
            var x: usize = 0;
            while (x < self.tilemap.size.w) : (x += 1) {
                self.final_map[x + y * self.tilemap.size.w] = self.transformTileWithRuleSet(x, y);
            }
        }
    }

    /// handles transforming a pre-map tile (from the Tileset, painted with the Brushset) to the final_map. based on the Rules.
    fn transformTileWithRuleSet(self: *@This(), x: usize, y: usize) u8 {
        var rule_passed = false;
        for (self.ruleset.rules.items) |*rule| brk: {
            if (rule.result_tiles.len == 0) continue;

            // at least one rule must pass to have a result
            for (rule.rule_tiles, 0..) |rule_tile, i| {
                if (rule_tile.state == .none) continue;
                const x_offset = @as(i32, @intCast(@mod(i, 5))) - 2;
                const y_offset = @as(i32, @intCast(@divTrunc(i, 5))) - 2;

                // stay in bounds! We could be looking for a tile 2 away from x,y in any direction
                const actual_x = @as(i32, @intCast(x)) + x_offset;
                const actual_y = @as(i32, @intCast(y)) + y_offset;
                const processed_tile = if (actual_x < 0 or actual_y < 0 or actual_x >= self.tilemap.size.w or actual_y >= self.tilemap.size.h) 0 else blk: {
                    const index = @as(usize, @intCast(actual_x)) + @as(usize, @intCast(actual_y)) * self.tilemap.size.w;
                    break :blk self.tilemap.data[index];
                };

                // if any rule fails, we are done with this RuleSet
                if (!rule_tile.passes(processed_tile)) {
                    break :brk;
                }

                rule_passed = true;
            }

            // a Rule passed. we use the chance to decide if we will return a tile
            const random = self.random_map_data[x + y * self.tilemap.size.w];
            const chance = random.float < @as(f32, @floatFromInt(rule.chance)) / 100;
            if (rule_passed and chance) {
                return @as(u8, @intCast(rule.resultTile(random.int) + 1));
            }
        }

        return 0;
    }

    pub fn draw(self: *@This(), _: *AppState, is_selected: bool) void {
        if (self.map_dirty and (!is_selected or !self.draw_raw_pre_map)) {
            self.generateFinalMap();
            self.map_dirty = false;
        }

        // If not selected, always draw the final map when visible
        if (!is_selected) {
            if (self.visible) self.tilemap.draw(self.tileset, self.final_map);
            return;
        }

        // selected, so we could be drawing either the raw pre-map or the final tilemap
        if (self.draw_raw_pre_map) {
            self.tilemap.draw(self.brushset, self.tilemap.data);
        } else {
            self.tilemap.draw(self.tileset, self.final_map);
        }
        self.brushset.draw();

        imgui.ogPushStyleVarVec2(imgui.ImGuiStyleVar_WindowMinSize, .{ .x = 365 });
        defer imgui.igPopStyleVar(1);

        defer imgui.igEnd();
        if (!imgui.igBegin("Rules###Inspector", null, imgui.ImGuiWindowFlags_None)) return;

        var group: u8 = 0;
        var delete_index: usize = std.math.maxInt(usize);
        var i: usize = 0;
        while (i < self.ruleset.rules.items.len) : (i += 1) {
            // if we have a Rule in a group render all the Rules in that group at once
            if (self.ruleset.rules.items[i].group > 0 and self.ruleset.rules.items[i].group != group) {
                group = self.ruleset.rules.items[i].group;

                imgui.igPushIDInt(@as(c_int, @intCast(group)));
                groupDropTarget(group, i);
                @memset(&group_label_buf, 0);
                std.mem.copy(u8, &group_label_buf, self.getGroupName(group));
                const header_open = imgui.igCollapsingHeaderBoolPtr(&group_label_buf, null, imgui.ImGuiTreeNodeFlags_DefaultOpen);
                groupDragDrop(group, i);

                if (imgui.igIsItemHovered(imgui.ImGuiHoveredFlags_None) and imgui.igIsMouseClicked(imgui.ImGuiMouseButton_Right, false)) {
                    imgui.ogOpenPopup("##rename-group");
                    std.mem.copy(u8, &rename_group_buf, self.getGroupName(group));
                }

                imgui.ogSetNextWindowPos(imgui.igGetIO().MousePos, imgui.ImGuiCond_Appearing, .{ .x = 0.5 });
                if (imgui.igBeginPopup("##rename-group", imgui.ImGuiWindowFlags_None)) {
                    _ = imgui.ogInputText("##name", &rename_group_buf, rename_group_buf.len);

                    if (imgui.ogButtonEx("Rename Group", .{ .x = -1, .y = 0 })) {
                        imgui.igCloseCurrentPopup();
                        const label_sentinel_index = std.mem.indexOfScalar(u8, &rename_group_buf, 0).?;
                        self.renameGroup(group, rename_group_buf[0..label_sentinel_index]);
                        std.debug.print("grp: {s}\n", .{rename_group_buf[0..label_sentinel_index]});
                    }

                    imgui.igEndPopup();
                }
                imgui.igPopID();

                if (header_open) {
                    imgui.igIndent(10);
                    drag_drop_state.rendering_group = true;
                }
                rulesDragDrop(i, &self.ruleset.rules.items[i], true);

                while (i < self.ruleset.rules.items.len and self.ruleset.rules.items[i].group == group) : (i += 1) {
                    if (header_open and self.drawRule(i)) {
                        delete_index = i;
                    }
                }

                if (header_open) {
                    imgui.igUnindent(10);
                    drag_drop_state.rendering_group = false;
                }

                // if a group is the last item dont try to render any more! else decrement and get back to the loop start since we skipped the last item
                if (i == self.ruleset.rules.items.len) break;
                i -= 1;
                continue;
            }

            if (self.drawRule(i)) {
                delete_index = i;
            }
        }

        if (delete_index < self.ruleset.rules.items.len) {
            const removed = self.ruleset.rules.orderedRemove(delete_index);
            if (removed.group > 0) {
                self.removeGroupIfEmpty(removed.group);
            }
            self.map_dirty = true;
        }

        // handle drag and drop swapping
        if (drag_drop_state.completed) {
            drag_drop_state.handle(&self.ruleset.rules);
        }

        imgui.ogDummy(.{ .y = 5 });

        if (imgui.ogButton("Add Rule")) {
            self.ruleset.addRule();
        }
        imgui.igSameLine(0, 10);

        if (imgui.ogButton("Add 9-Slice")) {
            imgui.ogOpenPopup("nine-slice-wizard");
            // reset temp state
            @memset(&new_rule_label_buf, 0);
            nine_slice_selected = null;
        }
        imgui.igSameLine(0, 10);

        if (imgui.ogButton("Add Inner-4")) {
            imgui.ogOpenPopup("inner-four-wizard");
            // reset temp state
            @memset(&new_rule_label_buf, 0);
            nine_slice_selected = null;
        }
        imgui.igSameLine(0, 10);

        if (imgui.ogButton("Random Seed")) {
            imgui.ogOpenPopup("random-seed");
        }

        imgui.ogSetNextWindowPos(imgui.igGetIO().MousePos, imgui.ImGuiCond_Appearing, .{ .x = 0.8 });
        if (imgui.igBeginPopup("random-seed", imgui.ImGuiWindowFlags_None)) {
            if (imgui.ogDrag(usize, "", &self.ruleset.seed, 1, 0, 1000)) {
                self.generateRandomData();
                self.map_dirty = true;
            }
            imgui.igEndPopup();
        }

        imgui.ogSetNextWindowPos(imgui.igGetIO().MousePos, imgui.ImGuiCond_Appearing, .{ .x = 0.5 });
        if (imgui.igBeginPopup("nine-slice-wizard", imgui.ImGuiWindowFlags_None)) {
            nineSlicePopup(self, 3);
            imgui.igEndPopup();
        }

        imgui.ogSetNextWindowPos(imgui.igGetIO().MousePos, imgui.ImGuiCond_Appearing, .{ .x = 0.5 });
        if (imgui.igBeginPopup("inner-four-wizard", imgui.ImGuiWindowFlags_None)) {
            nineSlicePopup(self, 2);
            imgui.igEndPopup();
        }
    }

    pub fn drawRule(self: *@This(), index: usize) bool {
        var rule = &self.ruleset.rules.items[index];
        imgui.igPushIDPtr(rule);
        defer imgui.igPopID();

        rulesDragDrop(index, rule, false);

        // right-click the move button to add the Rule to a group only if not already in a group
        if (rule.group == 0) {
            if (imgui.igIsItemHovered(imgui.ImGuiHoveredFlags_None) and imgui.igIsMouseClicked(imgui.ImGuiMouseButton_Right, false)) {
                imgui.ogOpenPopup("##group-name");
                @memset(&name_buf, 0);
            }

            imgui.ogSetNextWindowPos(imgui.igGetIO().MousePos, imgui.ImGuiCond_Appearing, .{ .x = 0.5 });
            if (imgui.igBeginPopup("##group-name", imgui.ImGuiWindowFlags_None)) {
                defer imgui.igEndPopup();

                _ = imgui.ogInputText("##group-name", &name_buf, name_buf.len);

                const label_sentinel_index = std.mem.indexOfScalar(u8, &name_buf, 0).?;
                const disabled = label_sentinel_index == 0;
                if (disabled) {
                    imgui.igPushItemFlag(imgui.ImGuiItemFlags_Disabled, true);
                    imgui.igPushStyleVarFloat(imgui.ImGuiStyleVar_Alpha, 0.5);
                }

                if (imgui.ogButtonEx("Add to New Group", .{ .x = -1, .y = 0 })) {
                    imgui.igCloseCurrentPopup();

                    // get the next available group
                    rule.group = self.ruleset.getNextAvailableGroup(self, name_buf[0..label_sentinel_index]);
                    @memset(&name_buf, 0);
                }

                if (disabled) {
                    imgui.igPopItemFlag();
                    imgui.igPopStyleVar(1);
                }
            }
        }

        imgui.igPushItemWidth(115);
        std.mem.copy(u8, &rule_label_buf, &rule.name);
        if (imgui.ogInputText("##name", &rule_label_buf, rule_label_buf.len)) {
            std.mem.copy(u8, &rule.name, &rule_label_buf);
        }
        imgui.igPopItemWidth();
        imgui.igSameLine(0, 4);

        if (imgui.ogButton("Pattern")) {
            imgui.ogOpenPopup("##pattern_popup");
        }
        imgui.igSameLine(0, 4);

        if (imgui.ogButton("Result")) {
            imgui.ogOpenPopup("result_popup");
        }
        imgui.igSameLine(0, 4);

        imgui.igPushItemWidth(50);
        if (imgui.ogDrag(u8, "", &rule.chance, 1, 0, 100)) self.map_dirty = true;
        imgui.igSameLine(0, 4);

        if (imgui.ogButton(icons.copy)) {
            self.ruleset.rules.append(rule.clone()) catch unreachable;
        }
        imgui.igSameLine(0, 4);

        if (imgui.ogButton(icons.trash)) {
            return true;
        }

        // if this is the last item, add an extra drop zone for reordering
        if (index == self.ruleset.rules.items.len - 1) {
            rulesDragDrop(index + 1, rule, true);
        }

        // display the popup a bit to the left to center it under the mouse
        imgui.ogSetNextWindowPos(imgui.igGetIO().MousePos, imgui.ImGuiCond_Appearing, .{ .x = 0.5 });
        if (imgui.igBeginPopup("##pattern_popup", imgui.ImGuiWindowFlags_None)) {
            self.patternPopup(rule);

            var size = imgui.ogGetContentRegionAvail();
            if (imgui.ogButtonEx("Clear", .{ .x = (size.x - 4) / 1.7 })) {
                rule.clearPatternData();
                self.map_dirty = true;
            }
            imgui.igSameLine(0, 4);

            if (imgui.ogButtonEx("...", .{ .x = -1, .y = 0 })) {
                imgui.ogOpenPopup("rules_hamburger");
            }

            self.rulesHamburgerPopup(rule);

            // quick brush selector
            if (imgui.ogKeyPressed(aya.sdl.SDL_SCANCODE_B)) {
                if (imgui.igIsPopupOpenID(imgui.igGetIDStr("##brushes"), imgui.ImGuiPopupFlags_None)) {
                    imgui.igClosePopupToLevel(1, true);
                } else {
                    imgui.ogOpenPopup("##brushes");
                }
            }

            // nested popup
            imgui.ogSetNextWindowPos(imgui.igGetIO().MousePos, imgui.ImGuiCond_Appearing, .{ .x = 0.5 });
            if (imgui.igBeginPopup("##brushes", imgui.ImGuiWindowFlags_NoTitleBar)) {
                self.brushset.drawWithoutWindow();
                imgui.igEndPopup();
            }

            imgui.igEndPopup();
        }

        imgui.ogSetNextWindowPos(imgui.igGetIO().MousePos, imgui.ImGuiCond_Appearing, .{ .x = 0.5 });
        if (imgui.igBeginPopup("result_popup", imgui.ImGuiWindowFlags_NoResize | imgui.ImGuiWindowFlags_AlwaysAutoResize)) {
            self.resultPopup(rule);
            imgui.igEndPopup();
        }

        return false;
    }

    fn patternPopup(self: *@This(), rule: *Rule) void {
        imgui.igText("Pattern");
        imgui.igSameLine(0, imgui.igGetWindowContentRegionWidth() - 65);
        imgui.igText(icons.question_circle);
        imgui.ogUnformattedTooltip(100, "Left Click: select tile and require\nShift + Left Click: select tile and negate\nRight Click: set as empty required\nShift + Right Click: set as empty negated");

        const draw_list = imgui.igGetWindowDrawList();

        const rect_size: f32 = 24;
        const pad: f32 = 4;
        const canvas_size = 5 * rect_size + 4 * pad;
        const thickness: f32 = 2;

        var pos = imgui.ImVec2{};
        imgui.igGetCursorScreenPos(&pos);
        _ = imgui.ogInvisibleButton("##pattern_button", .{ .x = canvas_size, .y = canvas_size }, imgui.ImGuiButtonFlags_None);
        const mouse_pos = imgui.igGetIO().MousePos;
        const hovered = imgui.igIsItemHovered(imgui.ImGuiHoveredFlags_None);

        var y: usize = 0;
        while (y < 5) : (y += 1) {
            var x: usize = 0;
            while (x < 5) : (x += 1) {
                const pad_x = @as(f32, @floatFromInt(x)) * pad;
                const pad_y = @as(f32, @floatFromInt(y)) * pad;
                const offset_x = @as(f32, @floatFromInt(x)) * rect_size;
                const offset_y = @as(f32, @floatFromInt(y)) * rect_size;
                var tl = imgui.ImVec2{ .x = pos.x + pad_x + offset_x, .y = pos.y + pad_y + offset_y };

                var rule_tile = rule.get(x, y);
                if (rule_tile.tile > 0) {
                    imgui.ogAddQuadFilled(draw_list, tl, rect_size, root.colors.brushes[rule_tile.tile - 1]);
                } else {
                    // if empty rule or just with a modifier
                    imgui.ogAddQuadFilled(draw_list, tl, rect_size, root.colors.rgbToU32(0, 0, 0));
                }

                if (x == 2 and y == 2) {
                    const size = rect_size - thickness;
                    var tl2 = tl;
                    tl2.x += 1;
                    tl2.y += 1;
                    imgui.ogAddQuad(draw_list, tl2, size, root.colors.pattern_center, thickness);
                }

                tl.x -= 1;
                tl.y -= 1;
                if (rule_tile.state == .negated) {
                    const size = rect_size + thickness;
                    imgui.ogAddQuad(draw_list, tl, size, root.colors.brush_negated, thickness);
                } else if (rule_tile.state == .required) {
                    const size = rect_size + thickness;
                    imgui.ogAddQuad(draw_list, tl, size, root.colors.brush_required, thickness);
                }

                if (hovered) {
                    if (tl.x <= mouse_pos.x and mouse_pos.x < tl.x + rect_size and tl.y <= mouse_pos.y and mouse_pos.y < tl.y + rect_size) {
                        if (imgui.igIsMouseClicked(imgui.ImGuiMouseButton_Left, false)) {
                            self.map_dirty = true;
                            if (imgui.igGetIO().KeyShift) {
                                rule_tile.negate(self.brushset.selected.comps.tile_index + 1);
                            } else {
                                rule_tile.require(self.brushset.selected.comps.tile_index + 1);
                            }
                        }

                        if (imgui.igIsMouseClicked(imgui.ImGuiMouseButton_Right, false)) {
                            self.map_dirty = true;
                            rule_tile.toggleState(if (imgui.igGetIO().KeyShift) .negated else .required);
                        }
                    }
                }
            }
        }
    }

    fn rulesHamburgerPopup(self: *@This(), rule: *Rule) void {
        imgui.ogSetNextWindowPos(imgui.igGetIO().MousePos, imgui.ImGuiCond_Appearing, .{ .x = 0.5 });
        if (imgui.igBeginPopup("rules_hamburger", imgui.ImGuiWindowFlags_None)) {
            defer imgui.igEndPopup();
            self.map_dirty = true;

            imgui.igText("Shift:");
            imgui.igSameLine(0, 10);
            if (imgui.ogButton(icons.arrow_left)) rule.shift(.left);

            imgui.igSameLine(0, 7);
            if (imgui.ogButton(icons.arrow_up)) rule.shift(.up);

            imgui.igSameLine(0, 7);
            if (imgui.ogButton(icons.arrow_down)) rule.shift(.down);

            imgui.igSameLine(0, 7);
            if (imgui.ogButton(icons.arrow_right)) rule.shift(.right);

            imgui.igText("Flip: ");
            imgui.igSameLine(0, 10);
            if (imgui.ogButton(icons.arrows_alt_h)) rule.flip(.horizontal);

            imgui.igSameLine(0, 4);
            if (imgui.ogButton(icons.arrows_alt_v)) rule.flip(.vertical);
        }
    }

    /// shows the tileset allowing multiple tiles to be selected
    fn resultPopup(self: *@This(), ruleset: *Rule) void {
        var content_start_pos = imgui.ogGetCursorScreenPos();
        const zoom: usize = if (self.tileset.tex.width < 200 and self.tileset.tex.height < 200) 2 else 1;
        const tile_spacing = self.tileset.spacing * zoom;
        const tile_size = self.tileset.tile_size * zoom;

        imgui.ogImage(self.tileset.tex.imTextureID(), @as(i32, @intFromFloat(self.tileset.tex.width)) * @as(i32, @intCast(zoom)), @as(i32, @intFromFloat(self.tileset.tex.height)) * @as(i32, @intCast(zoom)));

        // const draw_list = imgui.igGetWindowDrawList();

        // draw selected tiles
        var iter = ruleset.result_tiles.iter();
        while (iter.next()) |index| {
            // const per_row = self.tileset.tiles_per_row;
            // TODO: HACK!
            const ts = @import("../data/tileset.zig");
            ts.addTileToDrawList(tile_size, content_start_pos, index, self.tileset.tiles_per_row, tile_spacing);
        }

        // check input for toggling state
        if (imgui.igIsItemHovered(imgui.ImGuiHoveredFlags_None)) {
            if (imgui.igIsMouseClicked(0, false)) {
                var tile = tileIndexUnderMouse(@as(usize, @intCast(tile_size + tile_spacing)), content_start_pos);
                const per_row = self.tileset.tiles_per_row;
                ruleset.toggleSelected(@as(u8, @intCast(tile.x + tile.y * per_row)));
                self.map_dirty = true;
            }
        }

        if (imgui.ogButtonEx("Clear", .{ .x = -1 })) {
            ruleset.result_tiles.clear();
            self.map_dirty = true;
        }
    }

    /// TODO: duplicated almost exactly in TilemapLayer
    pub fn handleSceneInput(self: *@This(), state: *AppState, camera: Camera, mouse_world: imgui.ImVec2) void {
        if ((imgui.igGetIO().KeyCtrl or imgui.igGetIO().KeySuper) and imgui.ogKeyPressed(aya.sdl.SDL_SCANCODE_A)) self.draw_raw_pre_map = !self.draw_raw_pre_map;

        if (!imgui.igIsItemHovered(imgui.ImGuiHoveredFlags_None)) return;

        // shortcuts for pressing 1-9 to set the brush, only works when hovering the scene view
        var key: usize = 49;
        while (key < 58) : (key += 1) {
            if (imgui.ogKeyPressed(key)) self.brushset.selected.value = @as(u16, @intCast(key - 49));
        }

        // TODO: this check below really exists in Scene and shouldnt be here. Somehow propograte that data here.
        if (imgui.igIsMouseDragging(imgui.ImGuiMouseButton_Left, 0) and (imgui.igGetIO().KeyAlt or imgui.igGetIO().KeySuper)) return;

        if (root.utils.tileIndexUnderPos(state, mouse_world, 16)) |tile| {
            const pos = math.Vec2{ .x = @as(f32, @floatFromInt(tile.x * self.tileset.tile_size)), .y = @as(f32, @floatFromInt(tile.y * self.tileset.tile_size)) };

            // dont draw the current tile brush under the mouse if we are shift-dragging
            if (!self.shift_dragged) {
                TileRenderInfo.init(self.brushset.selected.value, self.brushset.tile_size).draw(self.brushset, pos);
            }

            // box selection with left/right mouse + shift
            if (imgui.ogIsAnyMouseDragging() and imgui.igGetIO().KeyShift) {
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
                    self.map_dirty = true;
                    const min_x = @min(tile.x, tile2.x);
                    var min_y = @min(tile.y, tile2.y);
                    const max_x = @max(tile.x, tile2.x);
                    const max_y = @max(tile.y, tile2.y);

                    // either set the tile to a brush or 0 depending on mouse button
                    const tile_value = if (imgui.igIsMouseReleased(imgui.ImGuiMouseButton_Left)) self.brushset.selected.value + 1 else 0;
                    while (min_y <= max_y) : (min_y += 1) {
                        var x = min_x;
                        while (x <= max_x) : (x += 1) {
                            self.tilemap.setTile(.{ .x = x, .y = min_y }, tile_value);
                        }
                    }
                }
            } else if (imgui.ogIsAnyMouseDown() and !imgui.igGetIO().KeyShift) {
                self.map_dirty = true;

                // if the mouse was down last frame, get last mouse pos and ensure we dont skip tiles when drawing
                const tile_value = if (imgui.igIsMouseDown(imgui.ImGuiMouseButton_Left)) self.brushset.selected.value + 1 else 0;
                if (self.dragged) {
                    self.commitInBetweenTiles(state, tile, camera, tile_value);
                }
                self.dragged = true;

                self.tilemap.setTile(tile, tile_value);
            } else if (imgui.ogIsAnyMouseReleased()) {
                self.dragged = false;
            }
        }
        self.prev_mouse_pos = imgui.igGetIO().MousePos;
    }

    /// TODO: duplicated in TilemapLayer
    fn commitInBetweenTiles(self: *@This(), state: *AppState, tile: Point, camera: Camera, color: u16) void {
        if (root.utils.tileIndexUnderMouse(state, self.prev_mouse_pos, self.tileset.tile_size, camera)) |prev_tile| {
            const abs_x = @abs(@as(i32, @intCast(tile.x)) - @as(i32, @intCast(prev_tile.x)));
            const abs_y = @abs(@as(i32, @intCast(tile.y)) - @as(i32, @intCast(prev_tile.y)));
            if (abs_x <= 1 and abs_y <= 1) {
                return;
            }

            root.utils.bresenham(&self.tilemap, @as(f32, @floatFromInt(prev_tile.x)), @as(f32, @floatFromInt(prev_tile.y)), @as(f32, @floatFromInt(tile.x)), @as(f32, @floatFromInt(tile.y)), color);
        }
    }
};

fn groupDropTarget(group: u8, index: usize) void {
    _ = group;
    if (drag_drop_state.active) {
        var cursor = imgui.ogGetCursorPos();
        const old_pos = cursor;
        cursor.y -= 6;
        imgui.ogSetCursorPos(cursor);
        imgui.igPushStyleColorU32(imgui.ImGuiCol_Button, root.colors.rgbToU32(0, 255, 0));
        _ = imgui.ogInvisibleButton("", .{ .x = -1, .y = 8 }, imgui.ImGuiButtonFlags_None);
        imgui.igPopStyleColor(1);
        imgui.ogSetCursorPos(old_pos);
    }

    if (imgui.igBeginDragDropTarget()) {
        defer imgui.igEndDragDropTarget();

        if (imgui.igAcceptDragDropPayload("RULESET_DRAG", imgui.ImGuiDragDropFlags_None)) |payload| {
            _ = payload;
            drag_drop_state.completed = true;
            drag_drop_state.to = index;
            drag_drop_state.above_group = true;
            drag_drop_state.active = false;
        }
    }
}

fn groupDragDrop(group: u8, index: usize) void {
    if (imgui.igBeginDragDropSource(imgui.ImGuiDragDropFlags_SourceNoHoldToOpenOthers)) {
        drag_drop_state.active = true;
        drag_drop_state.from = index;
        drag_drop_state.source = .{ .group = group };
        _ = imgui.igSetDragDropPayload("RULESET_DRAG", null, 0, imgui.ImGuiCond_Once);
        _ = imgui.ogButtonEx("group move", .{ .x = imgui.ogGetContentRegionAvail().x, .y = 20 });
        imgui.igEndDragDropSource();
    }
}

/// handles drag/drop sources and targets
fn rulesDragDrop(index: usize, rule: *Rule, drop_only: bool) void {
    var cursor = imgui.ogGetCursorPos();

    if (!drop_only) {
        _ = imgui.ogButton(icons.grip_horizontal);
        imgui.ogUnformattedTooltip(20, if (rule.group > 0) "Click and drag to reorder" else "Click and drag to reorder\nRight-click to add a group");

        imgui.igSameLine(0, 4);
        if (imgui.igBeginDragDropSource(imgui.ImGuiDragDropFlags_None)) {
            drag_drop_state.active = true;
            _ = imgui.igSetDragDropPayload("RULESET_DRAG", null, 0, imgui.ImGuiCond_Once);
            drag_drop_state.from = index;
            drag_drop_state.source = .{ .rule = rule };
            _ = imgui.ogButtonEx(&rule.name, .{ .x = imgui.ogGetContentRegionAvail().x, .y = 20 });
            imgui.igEndDragDropSource();
        }
    }

    // if we are dragging a group dont allow dragging it into another group
    if (drag_drop_state.active and !(drag_drop_state.isGroup() and rule.group > 0)) {
        const old_pos = imgui.ogGetCursorPos();
        cursor.y -= 6;
        imgui.ogSetCursorPos(cursor);
        imgui.igPushStyleColorU32(imgui.ImGuiCol_Button, root.colors.rgbToU32(255, 0, 0));
        _ = imgui.ogInvisibleButton("", .{ .x = -1, .y = 8 }, imgui.ImGuiButtonFlags_None);
        imgui.igPopStyleColor(1);
        imgui.ogSetCursorPos(old_pos);

        if (imgui.igBeginDragDropTarget()) {
            if (imgui.igAcceptDragDropPayload("RULESET_DRAG", imgui.ImGuiDragDropFlags_None)) |payload| {
                _ = payload;
                drag_drop_state.dropped_in_group = drag_drop_state.rendering_group;
                drag_drop_state.completed = true;
                drag_drop_state.to = index;

                // if this is a group being dragged, we cant rule out the operation since we could have 1 to n items in our group
                if (!drag_drop_state.isGroup()) {
                    // dont allow swapping to the same location, which is the drop target above or below the dragged item
                    if (drag_drop_state.from == drag_drop_state.to or (drag_drop_state.to > 0 and drag_drop_state.from == drag_drop_state.to - 1)) {
                        drag_drop_state.completed = false;
                    }
                }
                drag_drop_state.active = false;
            }
            imgui.igEndDragDropTarget();
        }
    }
}

/// handles the actual logic to rearrange the Rule for drag/drop when a Rule is reordered
fn swapRules(rules: *std.ArrayList(Rule)) void {
    // dont assign the group unless we are swapping into a group proper
    if (!drag_drop_state.above_group and drag_drop_state.dropped_in_group) {
        const to = if (rules.items.len == drag_drop_state.to) drag_drop_state.to - 1 else drag_drop_state.to;
        const group = rules.items[to].group;
        rules.items[drag_drop_state.from].group = group;
    } else {
        rules.items[drag_drop_state.from].group = 0;
    }

    // get the total number of steps we need to do the swap. We move to index+1 so account for that when moving to a higher index
    var total_swaps = if (drag_drop_state.from > drag_drop_state.to) drag_drop_state.from - drag_drop_state.to else drag_drop_state.to - drag_drop_state.from - 1;
    while (total_swaps > 0) : (total_swaps -= 1) {
        if (drag_drop_state.from > drag_drop_state.to) {
            std.mem.swap(Rule, &rules.items[drag_drop_state.from], &rules.items[drag_drop_state.from - 1]);
            drag_drop_state.from -= 1;
        } else {
            std.mem.swap(Rule, &rules.items[drag_drop_state.from], &rules.items[drag_drop_state.from + 1]);
            drag_drop_state.from += 1;
        }
    }
}

/// handles the actual logic to rearrange the Rule for drag/drop when a group is reordered
fn swapGroups(rules: *std.ArrayList(Rule)) void {
    var total_in_group = blk: {
        var total: usize = 0;
        for (rules.items) |rule| {
            if (rule.group == drag_drop_state.source.group) total += 1;
        }
        break :blk total;
    };
    var total_swaps = if (drag_drop_state.from > drag_drop_state.to) drag_drop_state.from - drag_drop_state.to else drag_drop_state.to - drag_drop_state.from - total_in_group;
    if (total_swaps == 0) return;

    while (total_swaps > 0) : (total_swaps -= 1) {
        // when moving up, we can just move each item in our group up one slot
        if (drag_drop_state.from > drag_drop_state.to) {
            var j: usize = 0;
            while (j < total_in_group) : (j += 1) {
                std.mem.swap(Rule, &rules.items[drag_drop_state.from + j], &rules.items[drag_drop_state.from - 1 + j]);
            }
            drag_drop_state.from -= 1;
        } else {
            // moving down, we have to move the last item in the group first each step
            var j: usize = total_in_group - 1;
            while (j >= 0) : (j -= 1) {
                std.mem.swap(Rule, &rules.items[drag_drop_state.from + j], &rules.items[drag_drop_state.from + 1 + j]);
                if (j == 0) break;
            }
            drag_drop_state.from += 1;
        }
    }
}

/// helper to find the tile under the mouse given a top-left position of the grid and a grid size
pub fn tileIndexUnderMouse(rect_size: usize, origin: imgui.ImVec2) struct { x: usize, y: usize } {
    var pos = imgui.igGetIO().MousePos;
    pos.x -= origin.x;
    pos.y -= origin.y;

    return .{ .x = @divTrunc(@as(usize, @intFromFloat(pos.x)), rect_size), .y = @divTrunc(@as(usize, @intFromFloat(pos.y)), rect_size) };
}

fn nineSlicePopup(self: *AutoTilemapLayer, selection_size: usize) void {
    self.brushset.drawWithoutWindow();
    imgui.igSameLine(0, 5);

    var content_start_pos = imgui.ogGetCursorScreenPos();
    imgui.ogImage(self.tileset.tex.imTextureID(), @as(i32, @intFromFloat(self.tileset.tex.width)), @as(i32, @intFromFloat(self.tileset.tex.height)));

    const draw_list = imgui.igGetWindowDrawList();

    if (nine_slice_selected) |index| {
        const x = @mod(index, self.tileset.tiles_per_row);
        const y = @divTrunc(index, self.tileset.tiles_per_row);

        var tl = imgui.ImVec2{ .x = @as(f32, @floatFromInt(x)) * @as(f32, @floatFromInt(self.tileset.tile_size + self.tileset.spacing)), .y = @as(f32, @floatFromInt(y)) * @as(f32, @floatFromInt(self.tileset.tile_size + self.tileset.spacing)) };
        tl.x += content_start_pos.x + 1 + @as(f32, @floatFromInt(self.tileset.spacing));
        tl.y += content_start_pos.y + 1 + @as(f32, @floatFromInt(self.tileset.spacing));
        imgui.ogAddQuadFilled(draw_list, tl, @as(f32, @floatFromInt((self.tileset.tile_size + self.tileset.spacing) * selection_size)), root.colors.rule_result_selected_fill);
        imgui.ogAddQuad(draw_list, tl, @as(f32, @floatFromInt((self.tileset.tile_size + self.tileset.spacing) * selection_size)) - 1, root.colors.rule_result_selected_outline, 2);
    }

    // check input for toggling state
    if (imgui.igIsItemHovered(imgui.ImGuiHoveredFlags_None)) {
        if (imgui.igIsMouseClicked(0, false)) {
            var tile = tileIndexUnderMouse(@as(usize, @intCast(self.tileset.tile_size + self.tileset.spacing)), content_start_pos);

            // does the nine-slice fit?
            if (tile.x + selection_size <= self.tileset.tiles_per_row and tile.y + selection_size <= self.tileset.tiles_per_col) {
                nine_slice_selected = @as(usize, @intCast(tile.x + tile.y * self.tileset.tiles_per_row));
            }
        }
    }

    var size = imgui.ogGetContentRegionAvail();
    imgui.igSetNextItemWidth(size.x * 0.6);
    _ = imgui.ogInputText("##nine-slice-name", &new_rule_label_buf, new_rule_label_buf.len);
    imgui.igSameLine(0, 5);

    const label_sentinel_index = std.mem.indexOfScalar(u8, &new_rule_label_buf, 0).?;
    const disabled = label_sentinel_index == 0 or nine_slice_selected == null;
    if (disabled) {
        imgui.igPushItemFlag(imgui.ImGuiItemFlags_Disabled, true);
        imgui.igPushStyleVarFloat(imgui.ImGuiStyleVar_Alpha, 0.5);
    }

    if (imgui.ogButtonEx("Create", imgui.ImVec2{ .x = -1, .y = 0 })) {
        if (selection_size == 3) {
            self.ruleset.addNinceSliceRules(self, new_rule_label_buf[0..label_sentinel_index], nine_slice_selected.?);
        } else {
            self.ruleset.addInnerFourRules(self, new_rule_label_buf[0..label_sentinel_index], nine_slice_selected.?);
        }
        self.map_dirty = true;
        imgui.igCloseCurrentPopup();
    }

    if (disabled) {
        imgui.igPopItemFlag();
        imgui.igPopStyleVar(1);
    }
}
