const std = @import("std");
const aya = @import("aya");
const tk = @import("../tilekit.zig");
const colors = @import("../colors.zig");
const brushes_win = @import("brushes.zig");
usingnamespace @import("imgui");

const Rule = @import("../map.zig").Rule;
const RuleSet = @import("../map.zig").RuleSet;

var rule_label_buf: [25]u8 = undefined;
var new_rule_label_buf: [25]u8 = undefined;
var pre_ruleset_tab_buf: [5]u8 = undefined;
var nine_slice_selected: ?usize = null;
var current_ruleset: usize = std.math.maxInt(usize);
var ruleset_delete_index: usize = undefined;

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

pub fn draw(state: *tk.AppState) void {
    igPushStyleVarVec2(ImGuiStyleVar_WindowMinSize, ImVec2{ .x = 365 });
    defer igPopStyleVar(1);

    if (state.prefs.windows.rules) {
        current_ruleset = std.math.maxInt(usize);
        _ = igBegin("Rules", &state.prefs.windows.rules, ImGuiWindowFlags_None);
        defer igEnd();

        // save the cursor position so we can hack a button on the tab bar itself
        var cursor = ogGetCursorPos();
        if (igBeginTabBar("Rules##tabbar", ImGuiTabBarFlags_AutoSelectNewTabs)) {
            defer igEndTabBar();

            cursor.x += igGetWindowContentRegionWidth() - 50;
            igSetCursorPos(cursor);
            if (igButton(icons.sliders_h, .{})) {
                igOpenPopup("##seed-repeat");
            }
            igSameLine(0, 5);
            if (igButton(icons.plus, .{})) {
                state.map.addPreRuleSet();
            }
            ogUnformattedTooltip(20, "Adds a new pre-ruleset, which is a group of rules that transform the input map before regular rules are run");

            if (igBeginTabItem("Final", null, ImGuiTabItemFlags_NoCloseButton)) {
                defer igEndTabItem();
                drawRulesTab(state);
            }

            drawPreRulesTabs(state);

            rulesetSettingsPopup(state);
        }

        if (drag_drop_state.active and igIsMouseReleased(ImGuiMouseButton_Left)) {
            drag_drop_state.active = false;
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

fn drawRulesTab(state: *tk.AppState) void {
    var group: u8 = 0;
    var delete_index: usize = std.math.maxInt(usize);
    var i: usize = 0;
    while (i < state.map.ruleset.rules.items.len) : (i += 1) {
        // if we have a Rule in a group render all the Rules in that group at once
        if (state.map.ruleset.rules.items[i].group > 0 and state.map.ruleset.rules.items[i].group != group) {
            group = state.map.ruleset.rules.items[i].group;

            igPushIDInt(@intCast(c_int, group));
            groupDropTarget(state.map.ruleset.rules.items[i].group, i);
            const header_open = igCollapsingHeaderBoolPtr("Group", null, ImGuiTreeNodeFlags_DefaultOpen);
            groupDragDrop(state.map.ruleset.rules.items[i].group, i);

            if (igBeginPopupContextItem("##group", ImGuiMouseButton_Right)) {
                _ = ogInputText("##name", &new_rule_label_buf, new_rule_label_buf.len);

                if (igButton("Rename Group", .{ .x = -1, .y = 0 })) {
                    igCloseCurrentPopup();
                }

                igEndPopup();
            }
            igPopID();

            if (header_open) {
                igIndent(10);
                drag_drop_state.rendering_group = true;
            }
            rulesDragDrop(i, &state.map.ruleset.rules.items[i], true);

            while (i < state.map.ruleset.rules.items.len and state.map.ruleset.rules.items[i].group == group) : (i += 1) {
                if (header_open and drawRuleSet(state, &state.map.ruleset, &state.map.ruleset.rules.items[i], i, false)) {
                    delete_index = i;
                }
            }

            if (header_open) {
                igUnindent(10);
                drag_drop_state.rendering_group = false;
            }

            // if a group is the last item dont try to render any more! else decrement and get back to the loop start since we skipped the last item
            if (i == state.map.ruleset.rules.items.len) break;
            i -= 1;
            continue;
        }

        if (drawRuleSet(state, &state.map.ruleset, &state.map.ruleset.rules.items[i], i, false)) {
            delete_index = i;
        }
    }

    if (delete_index < state.map.ruleset.rules.items.len) {
        _ = state.map.ruleset.rules.orderedRemove(delete_index);
    }

    // handle drag and drop swapping
    if (drag_drop_state.completed) {
        drag_drop_state.handle(&state.map.ruleset.rules);
    }

    if (ogButton("Add Rule")) {
        state.map.ruleset.addRule();
    }
    igSameLine(0, 10);

    if (ogButton("Add 9-Slice")) {
        igOpenPopup("nine-slice-wizard");
        // reset temp state
        std.mem.set(u8, &new_rule_label_buf, 0);
        nine_slice_selected = null;
    }
    igSameLine(0, 10);

    if (ogButton("Add Inner-4")) {
        igOpenPopup("inner-four-wizard");
        // reset temp state
        std.mem.set(u8, &new_rule_label_buf, 0);
        nine_slice_selected = null;
    }

    var pos = igGetIO().MousePos;
    pos.x -= 150;
    igSetNextWindowPos(pos, ImGuiCond_Appearing, ImVec2{});
    if (igBeginPopup("nine-slice-wizard", ImGuiWindowFlags_None)) {
        nineSlicePopup(state, 3);
        igEndPopup();
    }

    if (igBeginPopup("inner-four-wizard", ImGuiWindowFlags_None)) {
        nineSlicePopup(state, 2);
        igEndPopup();
    }
}

fn drawPreRulesTabs(state: *tk.AppState) void {
    for (state.map.pre_rulesets.items) |*ruleset, i| {
        var is_tab_open = true;
        igPushIDInt(@intCast(c_int, i) + 3000);
        _ = std.fmt.bufPrint(&pre_ruleset_tab_buf, "#{}", .{i + 1}) catch unreachable;
        if (igBeginTabItem(&pre_ruleset_tab_buf, &is_tab_open, ImGuiTabItemFlags_None)) {
            defer igEndTabItem();
            current_ruleset = i;

            var delete_rule_index: usize = std.math.maxInt(usize);
            for (ruleset.rules.items) |*rule, j| {
                if (drawRuleSet(state, ruleset, rule, j, true)) {
                    delete_rule_index = j;
                }
            }

            if (ogButton("Add Rule")) {
                ruleset.rules.append(Rule.init()) catch unreachable;
            }

            if (delete_rule_index < ruleset.rules.items.len) {
                _ = ruleset.rules.orderedRemove(delete_rule_index);
            }

            if (drag_drop_state.completed) {
                drag_drop_state.handle(&ruleset.rules);
            }
        }
        igPopID();

        if (!is_tab_open) {
            ruleset_delete_index = i;
            igOpenPopup("Delete RuleSet");
        }
    } // end pre_rules loop

    if (igBeginPopupModal("Delete RuleSet", null, ImGuiWindowFlags_AlwaysAutoResize)) {
        deletePreRuleSetPopup(state);
        igEndPopup();
    }


}

fn deletePreRuleSetPopup(state: *tk.AppState) void {
    igText("Are you sure you want to delete\nthis RuleSet?");
    igSeparator();

    var size = ogGetContentRegionAvail();
    if (igButton("Cancel", ImVec2{ .x = (size.x - 4) / 2 })) {
        igCloseCurrentPopup();
    }
    igSameLine(0, 4);

    igPushStyleColorU32(ImGuiCol_Button, tk.colors.colorRgb(180, 25, 35));
    igPushStyleColorU32(ImGuiCol_ButtonHovered, tk.colors.colorRgb(240, 20, 30));
    if (igButton("Delete", ImVec2{ .x = -1, .y = 0 })) {
        const removed_rules_page = state.map.pre_rulesets.orderedRemove(ruleset_delete_index);
        removed_rules_page.deinit();
        igCloseCurrentPopup();
    }
    igPopStyleColor(2);
}

fn rulesetSettingsPopup(state: *tk.AppState) void {
    if (igBeginPopup("##seed-repeat", ImGuiWindowFlags_None)) {
        var ruleset = if (current_ruleset == std.math.maxInt(usize)) &state.map.ruleset else &state.map.pre_rulesets.items[current_ruleset];
        if (ogDrag(usize, "Seed", &ruleset.seed, 1, 0, 1000)) {
            state.map_data_dirty = true;
        }

        // only pre_rulesets (valid current_ruleset index into their slice) get the repeat control
        if (current_ruleset < std.math.maxInt(usize) and ogDrag(u8, "Repeat", &ruleset.repeat, 0.2, 0, 100)) {
            state.map_data_dirty = true;
        }
        igEndPopup();
    }
}

fn groupDropTarget(group: u8, index: usize) void {
    if (drag_drop_state.active) {
        var cursor = ogGetCursorPos();
        const old_pos = cursor;
        cursor.y -= 5;
        igSetCursorPos(cursor);
        igPushStyleColorU32(ImGuiCol_Button, colors.colorRgb(0, 255, 0));
        _ = igInvisibleButton("", .{ .x = -1, .y = 8 });
        igPopStyleColor(1);
        igSetCursorPos(old_pos);
    }

    if (igBeginDragDropTarget()) {
        defer igEndDragDropTarget();

        if (igAcceptDragDropPayload("RULESET_DRAG", ImGuiDragDropFlags_None)) |payload| {
            drag_drop_state.completed = true;
            drag_drop_state.to = index;
            drag_drop_state.above_group = true;
            drag_drop_state.active = false;
        }
    }
}

fn groupDragDrop(group: u8, index: usize) void {
    if (igBeginDragDropSource(ImGuiDragDropFlags_SourceNoHoldToOpenOthers)) {
        drag_drop_state.active = true;
        drag_drop_state.from = index;
        drag_drop_state.source = .{ .group = group };
        _ = igSetDragDropPayload("RULESET_DRAG", null, 0, ImGuiCond_Once);
        _ = igButton("group move", .{ .x = ogGetContentRegionAvail().x, .y = 20 });
        igEndDragDropSource();
    }
}

/// handles drag/drop sources and targets
fn rulesDragDrop(index: usize, rule: *Rule, drop_only: bool) void {
    var cursor = ogGetCursorPos();

    if (!drop_only) {
        _ = ogButton(icons.grip_horizontal);
        ogUnformattedTooltip(20, "Click and drag to reorder\nRight-click to add a group");

        igSameLine(0, 4);
        if (igBeginDragDropSource(ImGuiDragDropFlags_None)) {
            drag_drop_state.active = true;
            _ = igSetDragDropPayload("RULESET_DRAG", null, 0, ImGuiCond_Once);
            drag_drop_state.from = index;
            drag_drop_state.source = .{ .rule = rule };
            _ = igButton(&rule.name, .{ .x = ogGetContentRegionAvail().x, .y = 20 });
            igEndDragDropSource();
        }
    }

    // if we are dragging a group dont allow dragging it into another group
    if (drag_drop_state.active and !(drag_drop_state.isGroup() and rule.group > 0)) {
        const old_pos = ogGetCursorPos();
        cursor.y -= 5;
        igSetCursorPos(cursor);
        igPushStyleColorU32(ImGuiCol_Button, colors.colorRgb(255, 0, 0));
        _ = igInvisibleButton("", .{ .x = -1, .y = 8 });
        igPopStyleColor(1);
        igSetCursorPos(old_pos);

        if (igBeginDragDropTarget()) {
            if (igAcceptDragDropPayload("RULESET_DRAG", ImGuiDragDropFlags_None)) |payload| {
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
            igEndDragDropTarget();
        }
    }
}

fn drawRuleSet(state: *tk.AppState, ruleset: *RuleSet, rule: *Rule, index: usize, is_pre_rule: bool) bool {
    igPushIDPtr(rule);
    defer igPopID();

    rulesDragDrop(index, rule, false);

    // right-click the move button to add the Rule to a group only if not already in a group
    if (rule.group == 0 and igBeginPopupContextItem("##group", ImGuiMouseButton_Right)) {
        _ = ogInputText("##group-name", &new_rule_label_buf, new_rule_label_buf.len);
        igText("Note: name not supported yet");

        if (igButton("Add to New Group", .{ .x = -1, .y = 0 })) {
            igCloseCurrentPopup();

            // TODO: switch to RuleSet.getNextAvailableGroup
            // get the highest group number and increment it
            var group: u8 = 0;
            for (ruleset.rules.items) |item| {
                group = std.math.max(group, item.group);
            }
            rule.group = group + 1;
            std.mem.set(u8, &new_rule_label_buf, 0);
        }

        igEndPopup();
    }

    igPushItemWidth(115);
    std.mem.copy(u8, &rule_label_buf, &rule.name);
    if (ogInputText("##name", &rule_label_buf, rule_label_buf.len)) {
        std.mem.copy(u8, &rule.name, &rule_label_buf);
    }
    igPopItemWidth();
    igSameLine(0, 4);

    if (ogButton("Pattern")) {
        igOpenPopup("##pattern_popup");
    }
    igSameLine(0, 4);

    if (ogButton("Result")) {
        igOpenPopup("result_popup");
    }
    igSameLine(0, 4);

    igPushItemWidth(50);
    var min: u8 = 0;
    var max: u8 = 100;
    _ = igDragScalar("", ImGuiDataType_U8, &rule.chance, 1, &min, &max, null, 1);
    igSameLine(0, 4);

    if (ogButton(icons.copy)) {
        ruleset.rules.append(rule.clone()) catch unreachable;
    }
    igSameLine(0, 4);

    if (ogButton(icons.trash)) {
        return true;
    }

    // if this is the last item, add an extra drop zone for reordering
    if (index == ruleset.rules.items.len - 1) {
        rulesDragDrop(index + 1, rule, true);
    }

    // display the popup a bit to the left to center it under the mouse
    var pos = igGetIO().MousePos;
    pos.x -= 32 * 5 / 2;
    igSetNextWindowPos(pos, ImGuiCond_Appearing, .{});
    if (igBeginPopup("##pattern_popup", ImGuiWindowFlags_None)) {
        patternPopup(state, rule);

        var size = ogGetContentRegionAvail();
        if (igButton("Clear", ImVec2{ .x = (size.x - 4) / 1.7 })) {
            rule.clearPatternData();
        }
        igSameLine(0, 4);

        if (igButton("...", ImVec2{ .x = -1, .y = 0 })) {
            igOpenPopup("rules_hamburger");
        }

        rulesHamburgerPopup(rule);

        // quick brush selector
        if (aya.input.keyPressed(.SDL_SCANCODE_B)) {
            if (igIsPopupOpenID(igGetIDStr("##brushes"))) {
                igClosePopupToLevel(1, true);
            } else {
                igOpenPopup("##brushes");
            }
        }
        brushes_win.drawPopup(state, "##brushes");
        igEndPopup();
    }

    if (is_pre_rule) {
        pos.x = igGetIO().MousePos.x - @intToFloat(f32, 32) * 5.0 / 2.0;
    } else {
        const zoom: i32 = if (state.texture.width < 200 and state.texture.height < 200) 2 else 1;
        pos.x = igGetIO().MousePos.x - @intToFloat(f32, state.texture.width * zoom) / 2;
    }
    igSetNextWindowPos(pos, ImGuiCond_Appearing, ImVec2{});
    if (igBeginPopup("result_popup", ImGuiWindowFlags_NoResize | ImGuiWindowFlags_AlwaysAutoResize)) {
        resultPopup(state, rule, is_pre_rule);
        igEndPopup();
    }

    return false;
}

fn patternPopup(state: *tk.AppState, rule: *Rule) void {
    igText("Pattern");
    igSameLine(0, igGetWindowContentRegionWidth() - 65);
    igText(icons.question_circle);
    ogUnformattedTooltip(100, "Left Click: select tile and require\nShift + Left Click: select tile and negate\nRight Click: set as empty required\nShift + Right Click: set as empty negated");

    const draw_list = igGetWindowDrawList();

    const rect_size: f32 = 32;
    const pad: f32 = 4;
    const canvas_size = 5 * rect_size + 4 * pad;
    const thickness: f32 = 2;

    var pos = ImVec2{};
    igGetCursorScreenPos(&pos);
    _ = igInvisibleButton("##pattern_button", ImVec2{ .x = canvas_size, .y = canvas_size });
    const mouse_pos = igGetIO().MousePos;
    const hovered = igIsItemHovered(ImGuiHoveredFlags_None);

    var y: usize = 0;
    while (y < 5) : (y += 1) {
        var x: usize = 0;
        while (x < 5) : (x += 1) {
            const pad_x = @intToFloat(f32, x) * pad;
            const pad_y = @intToFloat(f32, y) * pad;
            const offset_x = @intToFloat(f32, x) * rect_size;
            const offset_y = @intToFloat(f32, y) * rect_size;
            var tl = ImVec2{ .x = pos.x + pad_x + offset_x, .y = pos.y + pad_y + offset_y };

            var rule_tile = rule.get(x, y);
            if (rule_tile.tile > 0) {
                brushes_win.drawBrush(32, rule_tile.tile - 1, tl);
            } else {
                // if empty rule or just with a modifier
                ogAddQuadFilled(draw_list, tl, rect_size, colors.colorRgb(0, 0, 0));
            }

            if (x == 2 and y == 2) {
                const size = rect_size - thickness;
                var tl2 = tl;
                tl2.x += 1;
                tl2.y += 1;
                ogAddQuad(draw_list, tl2, size, colors.pattern_center, thickness);
            }

            tl.x -= 1;
            tl.y -= 1;
            if (rule_tile.state == .negated) {
                const size = rect_size + thickness;
                ogAddQuad(draw_list, tl, size, colors.brush_negated, thickness);
            } else if (rule_tile.state == .required) {
                const size = rect_size + thickness;
                ogAddQuad(draw_list, tl, size, colors.brush_required, thickness);
            }

            if (hovered) {
                if (tl.x <= mouse_pos.x and mouse_pos.x < tl.x + rect_size and tl.y <= mouse_pos.y and mouse_pos.y < tl.y + rect_size) {
                    if (igIsMouseClicked(ImGuiMouseButton_Left, false)) {
                        if (igGetIO().KeyShift) {
                            rule_tile.negate(state.selected_brush_index + 1);
                        } else {
                            rule_tile.require(state.selected_brush_index + 1);
                        }
                    }

                    if (igIsMouseClicked(ImGuiMouseButton_Right, false)) {
                        rule_tile.toggleState(if (igGetIO().KeyShift) .negated else .required);
                    }
                }
            }
        }
    }
}

fn rulesHamburgerPopup(rule: *Rule) void {
    var pos = igGetIO().MousePos;
    pos.x -= 100;
    igSetNextWindowPos(pos, ImGuiCond_Appearing, ImVec2{});

    if (igBeginPopup("rules_hamburger", ImGuiWindowFlags_None)) {
        defer igEndPopup();

        igText("Shift:");
        igSameLine(0, 10);
        if (ogButton(icons.arrow_left)) {
            rule.shift(.left);
        }

        igSameLine(0, 7);
        if (ogButton(icons.arrow_up)) {
            rule.shift(.up);
        }

        igSameLine(0, 7);
        if (ogButton(icons.arrow_down)) {
            rule.shift(.down);
        }

        igSameLine(0, 7);
        if (ogButton(icons.arrow_right)) {
            rule.shift(.right);
        }

        igText("Flip: ");
        igSameLine(0, 10);
        if (ogButton(icons.arrows_alt_h)) {
            rule.flip(.horizontal);
        }

        igSameLine(0, 4);
        if (ogButton(icons.arrows_alt_v)) {
            rule.flip(.vertical);
        }
    }
}

/// shows the tileset or brush palette allowing multiple tiles to be selected
fn resultPopup(state: *tk.AppState, ruleset: *Rule, is_pre_rule: bool) void {
    var content_start_pos = ogGetCursorScreenPos();
    const zoom: usize = if (!is_pre_rule and (state.texture.width < 200 and state.texture.height < 200)) 2 else 1;
    const tile_spacing = if (is_pre_rule) 0 else state.map.tile_spacing * zoom;
    const tile_size = if (is_pre_rule) 32 else state.map.tile_size * zoom;

    if (is_pre_rule) {
        brushes_win.draw(state, @intToFloat(f32, tile_size), true);
    } else {
        ogImage(state.texture.tex, state.texture.width * @intCast(i32, zoom), state.texture.height * @intCast(i32, zoom));
    }

    const draw_list = igGetWindowDrawList();

    // draw selected tiles
    var iter = ruleset.result_tiles.iter();
    while (iter.next()) |index| {
        const per_row = if (is_pre_rule) 6 else state.tilesPerRow();
        tk.addTileToDrawList(tile_size, content_start_pos, index, per_row, tile_spacing);
    }

    // check input for toggling state
    if (igIsItemHovered(ImGuiHoveredFlags_None)) {
        if (igIsMouseClicked(0, false)) {
            var tile = tk.tileIndexUnderMouse(@intCast(usize, tile_size + tile_spacing), content_start_pos);
            const per_row = if (is_pre_rule) 6 else state.tilesPerRow();
            ruleset.toggleSelected(@intCast(u8, tile.x + tile.y * per_row));
        }
    }

    if (igButton("Clear", ImVec2{ .x = -1 })) {
        ruleset.result_tiles.clear();
    }
}

fn nineSlicePopup(state: *tk.AppState, selection_size: usize) void {
    brushes_win.draw(state, 16, false);
    igSameLine(0, 5);

    var content_start_pos = ogGetCursorScreenPos();
    ogImage(state.texture.tex, state.texture.width, state.texture.height);

    const draw_list = igGetWindowDrawList();

    if (nine_slice_selected) |index| {
        const x = @mod(index, state.tilesPerRow());
        const y = @divTrunc(index, state.tilesPerRow());

        var tl = ImVec2{ .x = @intToFloat(f32, x) * @intToFloat(f32, state.map.tile_size + state.map.tile_spacing), .y = @intToFloat(f32, y) * @intToFloat(f32, state.map.tile_size + state.map.tile_spacing) };
        tl.x += content_start_pos.x + 1 + @intToFloat(f32, state.map.tile_spacing);
        tl.y += content_start_pos.y + 1 + @intToFloat(f32, state.map.tile_spacing);
        ogAddQuadFilled(draw_list, tl, @intToFloat(f32, (state.map.tile_size + state.map.tile_spacing) * selection_size), colors.rule_result_selected_fill);
        ogAddQuad(draw_list, tl, @intToFloat(f32, (state.map.tile_size + state.map.tile_spacing) * selection_size) - 1, colors.rule_result_selected_outline, 2);
    }

    // check input for toggling state
    if (igIsItemHovered(ImGuiHoveredFlags_None)) {
        if (igIsMouseClicked(0, false)) {
            var tile = tk.tileIndexUnderMouse(@intCast(usize, state.map.tile_size + state.map.tile_spacing), content_start_pos);

            // does the nine-slice fit?
            if (tile.x + selection_size <= state.tilesPerRow() and tile.y + selection_size <= state.tilesPerCol()) {
                nine_slice_selected = @intCast(usize, tile.x + tile.y * state.tilesPerRow());
            }
        }
    }

    var size = ogGetContentRegionAvail();
    igSetNextItemWidth(size.x * 0.6);
    _ = ogInputText("##nine-slice-name", &new_rule_label_buf, new_rule_label_buf.len);
    igSameLine(0, 5);

    const label_sentinel_index = std.mem.indexOfScalar(u8, &new_rule_label_buf, 0).?;
    const disabled = label_sentinel_index == 0 or nine_slice_selected == null;
    if (disabled) {
        igPushItemFlag(ImGuiItemFlags_Disabled, true);
        igPushStyleVarFloat(ImGuiStyleVar_Alpha, 0.5);
    }

    if (igButton("Create", ImVec2{ .x = -1, .y = 0 })) {
        if (selection_size == 3) {
            state.map.ruleset.addNinceSliceRules(state.tilesPerRow(), state.selected_brush_index, new_rule_label_buf[0..label_sentinel_index], nine_slice_selected.?);
        } else {
            state.map.ruleset.addInnerFourRules(state.tilesPerRow(), state.selected_brush_index, new_rule_label_buf[0..label_sentinel_index], nine_slice_selected.?);
        }
        igCloseCurrentPopup();
    }

    if (disabled) {
        igPopItemFlag();
        igPopStyleVar(1);
    }
}
