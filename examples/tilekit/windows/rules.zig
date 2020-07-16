const std = @import("std");
const aya = @import("aya");
const tk = @import("../tilekit.zig");
const colors = @import("../colors.zig");
const brushes_win = @import("brushes.zig");
usingnamespace @import("imgui");

const RuleSet = @import("../data.zig").RuleSet;

var rule_label_buf: [25]u8 = undefined;
var new_rule_label_buf: [25]u8 = undefined;
var nine_slice_selected: ?usize = null;

var drag_drop_state = struct {
    source: union(enum) {
        rule: *RuleSet,
        folder: u8,
    } = undefined,
    from: usize = 0,
    to: usize = 0,
    above_folder: bool = false,
    completed: bool = false,
    active: bool = false,

    pub fn isFolder(self: @This()) bool {
        return switch (self.source) {
            .folder => true,
            else => false,
        };
    }

    pub fn handle(self: *@This(), ruleset: *std.ArrayList(RuleSet)) void {
        self.completed = false;
        switch (self.source) {
            .folder => swapFolders(ruleset),
            else => swapRuleSets(ruleset),
        }
        self.above_folder = false;
    }
}{};

pub fn draw(state: *tk.AppState) void {
    igPushStyleVarVec2(ImGuiStyleVar_WindowMinSize, ImVec2{ .x = 365 });
    defer igPopStyleVar(1);

    if (state.prefs.windows.rules and igBegin("Rules", &state.prefs.windows.rules, ImGuiWindowFlags_None)) {
        defer igEnd();

        // save the cursor position so we can hack a button on the tab bar itself
        var cursor = ogGetCursorPos();
        if (igBeginTabBar("Rules##tabbar", ImGuiTabBarFlags_AutoSelectNewTabs)) {
            defer igEndTabBar();

            cursor.x += igGetWindowContentRegionWidth() - 25;
            igSetCursorPos(cursor);
            if (igButton(" + ", ImVec2{})) {
                state.map.addPreRulesPage();
            }
            if (igIsItemHovered(ImGuiHoveredFlags_None)) {
                ogUnformattedTooltip(20, "Adds a new pre-ruleset, which is a group of rules that transform the input map before regular rules are run");
            }

            if (igBeginTabItem("Final", null, ImGuiTabItemFlags_NoCloseButton)) {
                defer igEndTabItem();
                drawRulesTab(state);
            }

            drawPreRulesTabs(state);
        }

        if (drag_drop_state.active and igIsMouseReleased(ImGuiMouseButton_Left)) {
            drag_drop_state.active = false;
        }
    }
}

fn swapRuleSets(ruleset: *std.ArrayList(RuleSet)) void {
    std.debug.print("drag_drop_state.above_folder: {}\n", .{drag_drop_state.above_folder});
    // dont assign the folder unless we are swapping into a folder proper
    if (!drag_drop_state.above_folder) {
        const folder = ruleset.items[drag_drop_state.to].folder;
        ruleset.items[drag_drop_state.from].folder = folder;
    }

    // get the total number of steps we need to do the swap. We move to index+1 so account for that when moving to a higher index
    var total_swaps = if (drag_drop_state.from > drag_drop_state.to) drag_drop_state.from - drag_drop_state.to else drag_drop_state.to - drag_drop_state.from - 1;
    while (total_swaps > 0) : (total_swaps -= 1) {
        if (drag_drop_state.from > drag_drop_state.to) {
            std.mem.swap(RuleSet, &ruleset.items[drag_drop_state.from], &ruleset.items[drag_drop_state.from - 1]);
            drag_drop_state.from -= 1;
        } else {
            std.mem.swap(RuleSet, &ruleset.items[drag_drop_state.from], &ruleset.items[drag_drop_state.from + 1]);
            drag_drop_state.from += 1;
        }
    }
}

fn swapFolders(ruleset: *std.ArrayList(RuleSet)) void {
    var total_in_folder = blk: {
        var total: usize = 0;
        for (ruleset.items) |rule| {
            if (rule.folder == drag_drop_state.source.folder) total += 1;
        }
        break :blk total;
    };
    var total_swaps = if (drag_drop_state.from > drag_drop_state.to) drag_drop_state.from - drag_drop_state.to else drag_drop_state.to - drag_drop_state.from - total_in_folder;
    if (total_swaps == 0) return;

    while (total_swaps > 0) : (total_swaps -= 1) {
        // when moving up, we can just move each item in our folder up one slot
        if (drag_drop_state.from > drag_drop_state.to) {
            var j: usize = 0;
            while (j < total_in_folder) : (j += 1) {
                std.mem.swap(RuleSet, &ruleset.items[drag_drop_state.from + j], &ruleset.items[drag_drop_state.from - 1 + j]);
            }
            drag_drop_state.from -= 1;
        } else {
            // moving down, we have to move the last item in the folder first each step
            var j: usize = total_in_folder - 1;
            while (j >= 0) : (j -= 1) {
                std.mem.swap(RuleSet, &ruleset.items[drag_drop_state.from + j], &ruleset.items[drag_drop_state.from + 1 + j]);
                if (j == 0) break;
            }
            drag_drop_state.from += 1;
        }
    }
}

fn drawRulesTab(state: *tk.AppState) void {
    var folder: u8 = 0;
    var delete_index: usize = std.math.maxInt(usize);
    var i: usize = 0;
    while (i < state.map.rulesets.items.len) : (i += 1) {
        // if we have a RuleSet in a folder render all the RuleSets in that folder at once
        if (state.map.rulesets.items[i].folder > 0 and state.map.rulesets.items[i].folder != folder) {
            folder = state.map.rulesets.items[i].folder;

            igPushIDInt(@intCast(c_int, folder));
            folderDropTarget(state.map.rulesets.items[i].folder, i);
            const header_open = igCollapsingHeaderBoolPtr("Folder", null, ImGuiTreeNodeFlags_DefaultOpen);
            folderDragDrop(state.map.rulesets.items[i].folder, i);

            if (igBeginPopupContextItem("##folder", ImGuiMouseButton_Right)) {
                _ = ogInputText("##name", &rule_label_buf, rule_label_buf.len);

                if (igButton("Rename Folder", .{ .x = -1, .y = 0 })) {
                    igCloseCurrentPopup();
                }

                igEndPopup();
            }
            igPopID();

            if (header_open) {
                igIndent(10);
            }
            rulesDragDrop(i, &state.map.rulesets.items[i], true);

            while (i < state.map.rulesets.items.len and state.map.rulesets.items[i].folder == folder) : (i += 1) {
                if (header_open and drawRuleSet(state, &state.map.rulesets, &state.map.rulesets.items[i], i, false)) {
                    delete_index = i;
                }
            }

            if (header_open) {
                igIndent(-10);
            }

            // if a folder is the last item dont try to render any more! else decrement and get back to the loop start since we skipped the last item
            if (i == state.map.rulesets.items.len) break;
            i -= 1;
            continue;
        }

        if (drawRuleSet(state, &state.map.rulesets, &state.map.rulesets.items[i], i, false)) {
            delete_index = i;
        }
    }

    if (delete_index < state.map.rulesets.items.len) {
        _ = state.map.rulesets.orderedRemove(delete_index);
    }

    // handle drag and drop swapping
    if (drag_drop_state.completed) {
        drag_drop_state.handle(&state.map.rulesets);
    }

    if (igButton("Add Rule", ImVec2{})) {
        state.map.addRuleSet();
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
    }

    if (igBeginPopup("inner-four-wizard", ImGuiWindowFlags_None)) {
        nineSlicePopup(state, 2);
    }
}

fn drawPreRulesTabs(state: *tk.AppState) void {
    var delete_index: usize = std.math.maxInt(usize);
    for (state.map.pre_rulesets.items) |*pre_rule, i| {
        var is_tab_open = true;
        igPushIDInt(@intCast(c_int, i) + 3000);
        if (igBeginTabItem("#1", &is_tab_open, ImGuiTabItemFlags_None)) {
            defer igEndTabItem();

            var delete_rule_index: usize = std.math.maxInt(usize);
            for (pre_rule.items) |*rule, j| {
                if (drawRuleSet(state, pre_rule, rule, j, true)) {
                    delete_rule_index = j;
                }
            }

            if (ogButton("Add Rule")) {
                pre_rule.append(RuleSet.init()) catch unreachable;
            }

            if (delete_rule_index < pre_rule.items.len) {
                _ = pre_rule.orderedRemove(delete_rule_index);
            }

            if (drag_drop_state.completed) {
                drag_drop_state.handle(pre_rule);
            }
        }
        igPopID();

        if (!is_tab_open) {
            delete_index = i;
        }
    } // end pre_rules loop

    if (delete_index < state.map.pre_rulesets.items.len) {
        const removed_rules_page = state.map.pre_rulesets.orderedRemove(delete_index);
        removed_rules_page.deinit();
    }
}

fn folderDropTarget(folder: u8, index: usize) void {
    var cursor = ogGetCursorPos();
    const old_pos = cursor;
    cursor.y -= 5;
    igSetCursorPos(cursor);
    _ = igInvisibleButton("", .{ .x = -1, .y = 8 });
    igSetCursorPos(old_pos);

    if (igBeginDragDropTarget()) {
        defer igEndDragDropTarget();

        if (!drag_drop_state.isFolder()) {
            // dont allow swapping to the same location, which is the drop target above or below the dragged item
            if (drag_drop_state.from == drag_drop_state.to or (drag_drop_state.to > 0 and drag_drop_state.from == drag_drop_state.to - 1)) {
                drag_drop_state.completed = false;
                return;
            }
        }

        if (igAcceptDragDropPayload("RULESET_DRAG", ImGuiDragDropFlags_None)) |payload| {
            drag_drop_state.completed = true;
            drag_drop_state.to = index;
            drag_drop_state.above_folder = true;
            drag_drop_state.active = false;
        }
    }
}

fn folderDragDrop(folder: u8, index: usize) void {
    if (igBeginDragDropSource(ImGuiDragDropFlags_SourceNoHoldToOpenOthers)) {
        drag_drop_state.active = true;
        drag_drop_state.from = index;
        drag_drop_state.source = .{ .folder = folder };
        _ = igSetDragDropPayload("RULESET_DRAG", null, 0, ImGuiCond_Once);
        _ = igText("folder dickhead");
        igEndDragDropSource();
    }
}

/// handles drag/drop sources and targets
fn rulesDragDrop(index: usize, rule: *RuleSet, drop_only: bool) void {
    var cursor = ogGetCursorPos();

    if (!drop_only) {
        _ = ogButton(icons.grip_horizontal);
        if (igIsItemHovered(ImGuiHoveredFlags_None)) {
            ogUnformattedTooltip(20, "Click and drag to reorder\nRight-click to add a folder");
        }

        igSameLine(0, 4);
        if (igBeginDragDropSource(ImGuiDragDropFlags_None)) {
            drag_drop_state.active = true;
            _ = igSetDragDropPayload("RULESET_DRAG", null, 0, ImGuiCond_Once);
            drag_drop_state.from = index;
            drag_drop_state.source = .{ .rule = rule };
            _ = igText(&rule.name);
            igEndDragDropSource();
        }
    }

    // if we are dragging a folder dont allow dragging it into another folder
    if (drag_drop_state.active and !(drag_drop_state.isFolder() and rule.folder > 0)) {
        const old_pos = ogGetCursorPos();
        cursor.y -= 5;
        igSetCursorPos(cursor);
        _ = igInvisibleButton("", .{ .x = -1, .y = 8 });
        igSetCursorPos(old_pos);

        if (igBeginDragDropTarget()) {
            if (igAcceptDragDropPayload("RULESET_DRAG", ImGuiDragDropFlags_None)) |payload| {
                drag_drop_state.completed = true;
                drag_drop_state.to = index;

                // if this is a folder being dragged, we can rule out the operation since we could have 1 to n items in our folder
                if (!drag_drop_state.isFolder()) {
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

fn drawRuleSet(state: *tk.AppState, parent: *std.ArrayList(RuleSet), rule: *RuleSet, index: usize, is_pre_rule: bool) bool {
    igPushIDPtr(rule);
    defer igPopID();

    rulesDragDrop(index, rule, false);

    // right-click the move button to add the RuleSet to a folder only if not already in a folder
    if (rule.folder == 0 and igBeginPopupContextItem("##folder", ImGuiMouseButton_Right)) {
        _ = ogInputText("##name", &new_rule_label_buf, new_rule_label_buf.len);

        if (igButton("Add to New Folder", .{ .x = -1, .y = 0 })) {
            igCloseCurrentPopup();

            // get the highest folder number and increment it
            var folder: u8 = 0;
            for (parent.items) |item| {
                folder = std.math.max(folder, item.folder);
            }
            rule.folder = folder + 1;
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

    if (igButton("Pattern", ImVec2{})) {
        igOpenPopup("##pattern_popup");
    }
    igSameLine(0, 4);

    if (igButton("Result", ImVec2{})) {
        igOpenPopup("result_popup");
    }
    igSameLine(0, 4);

    igPushItemWidth(50);
    var min: u8 = 0;
    var max: u8 = 100;
    _ = igDragScalar("", ImGuiDataType_U8, &rule.chance, 1, &min, &max, null, 1);
    igSameLine(0, 4);

    if (igButton(icons.copy, ImVec2{})) {
        parent.append(rule.clone()) catch unreachable;
    }
    igSameLine(0, 4);

    if (ogButton(icons.trash)) {
        return true;
    }

    // if this is the last item, add an extra drop zone for reordering
    if (index == parent.items.len - 1) {
        rulesDragDrop(index + 1, rule, true);
    }

    // display the popup a bit to the left to center it under the mouse
    var pos = igGetIO().MousePos;
    pos.x -= 32 * 5 / 2;
    igSetNextWindowPos(pos, ImGuiCond_Appearing, ImVec2{});
    if (igBeginPopup("##pattern_popup", ImGuiWindowFlags_None)) {
        patternPopup(state, rule);

        var size = ogGetContentRegionAvail();
        if (igButton("Clear", ImVec2{ .x = (size.x - 4) / 1.3 })) {
            rule.clearPatternData();
        }
        igSameLine(0, 4);
        if (igButton("...", ImVec2{ .x = -1, .y = 0 })) {
            igOpenPopup("rules_hamburger");
        }

        rulesHamburgerPopup(rule);

        igEndPopup();
    }

    if (is_pre_rule) {
        pos.x = igGetIO().MousePos.x - @intToFloat(f32, state.map.tile_size) * 5.0 / 2.0;
    } else {
        pos.x = igGetIO().MousePos.x - @intToFloat(f32, state.texture.width) / 2;
    }
    igSetNextWindowPos(pos, ImGuiCond_Appearing, ImVec2{});
    if (igBeginPopup("result_popup", ImGuiWindowFlags_NoResize | ImGuiWindowFlags_AlwaysAutoResize)) {
        resultPopup(state, rule, is_pre_rule);
        igEndPopup();
    }

    return false;
}

fn patternPopup(state: *tk.AppState, rule: *RuleSet) void {
    igText("Pattern");

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
                    if (igIsMouseClicked(0, false)) {
                        if (aya.input.keyDown(.SDL_SCANCODE_LSHIFT)) {
                            rule_tile.negate(state.selected_brush_index + 1);
                        } else {
                            rule_tile.require(state.selected_brush_index + 1);
                        }
                    }

                    if (igIsMouseClicked(1, false)) {
                        rule_tile.toggleState(if (aya.input.keyDown(.SDL_SCANCODE_LSHIFT)) .negated else .required);
                    }
                }
            }
        }
    }
}

fn rulesHamburgerPopup(rule: *RuleSet) void {
    var pos = igGetIO().MousePos;
    pos.x -= 100;
    igSetNextWindowPos(pos, ImGuiCond_Appearing, ImVec2{});

    if (igBeginPopup("rules_hamburger", ImGuiWindowFlags_None)) {
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

        igEndPopup();
    }
}

/// shows the tileset or brush palette allowing multiple tiles to be selected
fn resultPopup(state: *tk.AppState, ruleset: *RuleSet, is_pre_rule: bool) void {
    var content_start_pos = ogGetCursorScreenPos();
    const tile_spacing = if (is_pre_rule) 0 else state.map.tile_spacing;

    if (is_pre_rule) {
        brushes_win.draw(state, @intToFloat(f32, state.map.tile_size), true);
    } else {
        ogImage(state.texture.tex, state.texture.width, state.texture.height);
    }

    const draw_list = igGetWindowDrawList();

    // draw selected tiles
    var iter = ruleset.result_tiles.iter();
    while (iter.next()) |index| {
        const per_row = if (is_pre_rule) 6 else state.tilesPerRow();
        const x = @mod(index, per_row);
        const y = @divTrunc(index, per_row);

        var tl = ImVec2{ .x = @intToFloat(f32, x) * @intToFloat(f32, state.map.tile_size + tile_spacing), .y = @intToFloat(f32, y) * @intToFloat(f32, state.map.tile_size + tile_spacing) };
        tl.x += content_start_pos.x + @intToFloat(f32, tile_spacing);
        tl.y += content_start_pos.y + @intToFloat(f32, tile_spacing);
        ogAddQuadFilled(draw_list, tl, @intToFloat(f32, state.map.tile_size), colors.rule_result_selected_fill);

        // offset by 1 extra pixel because quad outlines are drawn larger than the size passed in and we shrink the size by our outline width
        tl.x += 1;
        tl.y += 1;
        ogAddQuad(draw_list, tl, @intToFloat(f32, state.map.tile_size - 2), colors.rule_result_selected_outline, 2);
    }

    // check input for toggling state
    if (igIsItemHovered(ImGuiHoveredFlags_None)) {
        if (igIsMouseClicked(0, false)) {
            var tile = tk.tileIndexUnderMouse(@intCast(usize, state.map.tile_size + tile_spacing), content_start_pos);
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
            state.map.addNinceSliceRules(state.tilesPerRow(), state.selected_brush_index, new_rule_label_buf[0..label_sentinel_index], nine_slice_selected.?);
        } else {
            state.map.addInnerFourRules(state.tilesPerRow(), state.selected_brush_index, new_rule_label_buf[0..label_sentinel_index], nine_slice_selected.?);
        }
        igCloseCurrentPopup();
    }

    if (disabled) {
        igPopItemFlag();
        igPopStyleVar(1);
    }
}
