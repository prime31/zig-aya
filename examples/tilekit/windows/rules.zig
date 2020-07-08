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

pub fn draw(state: *tk.AppState) void {
    igPushStyleVarVec2(ImGuiStyleVar_WindowMinSize, ImVec2{.x=365});
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
                igBeginTooltip();
                defer igEndTooltip();

                igPushTextWrapPos(igGetFontSize() * 20);
                igTextUnformatted("Adds a new pre-rule, which will transform the input map before regular rules are run", null);
                igPopTextWrapPos();
            }

            if (igBeginTabItem("Final", null, ImGuiTabItemFlags_NoCloseButton)) {
                defer igEndTabItem();
                renderRulesTab(state);
            }

            renderPreRulesTabs(state);
        }
    }
}

fn renderRulesTab(state: *tk.AppState) void {
    var delete_index: usize = std.math.maxInt(usize);
    var i: usize = 0;
    while (i < state.map.rulesets.items.len) : (i += 1) {
        igPushIDInt(@intCast(c_int, i) + 1000);
        if (renderRuleSet(state, &state.map.rulesets, &state.map.rulesets.items[i], false)) {
            delete_index = i;
        }
        igPopID();
    }

    if (delete_index < state.map.rulesets.items.len) {
        _ = state.map.rulesets.orderedRemove(delete_index);
    }

    if (igButton("Add Rule", ImVec2{})) {
        state.map.addRule();
    }
    igSameLine(0, 10);

    if (igButton("Add 9-Slice", ImVec2{})) {
        igOpenPopup("nine-slice-wizard");
        // reset temp state
        std.mem.set(u8, &new_rule_label_buf, 0);
        nine_slice_selected = null;
    }
    igSameLine(0, 10);

    if (igButton("Add Inner-4", ImVec2{})) {
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

fn renderPreRulesTabs(state: *tk.AppState) void {
    var delete_index: usize = std.math.maxInt(usize);
    for (state.map.pre_rulesets.items) |*pre_rule, i| {
        var is_tab_open = true;
        igPushIDInt(@intCast(c_int, i) + 3000);
        if (igBeginTabItem("#1", &is_tab_open, ImGuiTabItemFlags_None)) {
            defer igEndTabItem();

            var delete_rule_index: usize = std.math.maxInt(usize);
            for (pre_rule.items) |*rule, j| {
                igPushIDPtr(rule);
                if (renderRuleSet(state, pre_rule, rule, true)) {
                    delete_rule_index = j;
                }
            }

            if (igButton("Add Rule", ImVec2{})) {
                pre_rule.append(RuleSet.init()) catch unreachable;
            }

            if (delete_rule_index < pre_rule.items.len) {
                _ = pre_rule.orderedRemove(delete_rule_index);
            }
            igPopID();
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

fn renderRuleSet(state: *tk.AppState, parent: *std.ArrayList(RuleSet), rule: *RuleSet, is_pre_rule: bool) bool {
    igPushItemWidth(125);
    std.mem.copy(u8, &rule_label_buf, &rule.name);
    if (ogInputText("##name", &rule_label_buf, rule_label_buf.len)) {
        std.mem.copy(u8, &rule.name, &rule_label_buf);
    }
    igSameLine(0, 4);
    igPopItemWidth();

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

        var tl = ImVec2{ .x = @intToFloat(f32, x) * @intToFloat(f32, state.map.tile_size), .y = @intToFloat(f32, y) * @intToFloat(f32, state.map.tile_size) };
        tl.x += content_start_pos.x + 1;
        tl.y += content_start_pos.y + 1;
        ogAddQuadFilled(draw_list, tl, @intToFloat(f32, state.map.tile_size), colors.rule_result_selected_fill);
        ogAddQuad(draw_list, tl, @intToFloat(f32, state.map.tile_size), colors.rule_result_selected_outline, 2);
    }

    // check input for toggling state
    if (igIsItemHovered(ImGuiHoveredFlags_None)) {
        if (igIsMouseClicked(0, false)) {
            var tile = tk.tileIndexUnderMouse(@intCast(usize, state.map.tile_size), content_start_pos);
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

        var tl = ImVec2{ .x = @intToFloat(f32, x) * @intToFloat(f32, state.map.tile_size), .y = @intToFloat(f32, y) * @intToFloat(f32, state.map.tile_size) };
        tl.x += content_start_pos.x + 1;
        tl.y += content_start_pos.y + 1;
        ogAddQuadFilled(draw_list, tl, @intToFloat(f32, state.map.tile_size * selection_size), colors.rule_result_selected_fill);
        ogAddQuad(draw_list, tl, @intToFloat(f32, state.map.tile_size * selection_size), colors.rule_result_selected_outline, 2);
    }

    // check input for toggling state
    if (igIsItemHovered(ImGuiHoveredFlags_None)) {
        if (igIsMouseClicked(0, false)) {
            var tile = tk.tileIndexUnderMouse(@intCast(usize, state.map.tile_size), content_start_pos);

            // does the nine-slice fit?
            if (tile.x + selection_size <= state.tilesPerRow()) {
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

