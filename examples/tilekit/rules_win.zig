const std = @import("std");
const print = std.debug.print;
const aya = @import("aya");
const tk = @import("tilekit.zig");
const colors = @import("colors.zig");
const brushes_win = @import("brushes_win.zig");
usingnamespace @import("imgui");

const Rule = @import("data.zig").Rule;

var label: [25]u8 = undefined;

pub fn draw(state: *tk.AppState) void {
    if (state.rules and igBegin("Rules", &state.rules, ImGuiWindowFlags_None)) {
        var delete_index: usize = std.math.maxInt(usize);
        var i: usize = 0;
        while (i < state.map.rules.items.len) : (i += 1) {
            igPushIDInt(@intCast(c_int, i));
            if (renderRule(state, &state.map.rules.items[i])) {
                delete_index = i;
            }
        }

        if (delete_index < state.map.rules.items.len) {
            _ = state.map.rules.swapRemove(delete_index);
        }

        if (igButton("Add Rule", ImVec2{})) {
            state.map.addRule();
        }
        igSameLine(0, 10);

        if (igButton("Add 9-Slice", ImVec2{})) {}

        igEnd();
    }
}

fn renderRule(state: *tk.AppState, rule: *Rule) bool {
    igPushItemWidth(100);
    std.mem.copy(u8, &label, &rule.name);
    if (igInputText("##name", &label, 100, ImGuiInputTextFlags_None, null, null)) {
        std.mem.copy(u8, &rule.name, &label);
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

    if (igButton("Copy", ImVec2{})) {
        state.map.rules.append(rule.clone()) catch unreachable;
    }
    igSameLine(0, 4);

    if (ogButton("Delete")) {
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

    igSetNextWindowPos(pos, ImGuiCond_Appearing, ImVec2{});
    if (igBeginPopup("result_popup", ImGuiWindowFlags_NoResize | ImGuiWindowFlags_AlwaysAutoResize)) {
        resultPopup(state, rule);
        igEndPopup();
    }

    return false;
}

fn patternPopup(state: *tk.AppState, rule: *Rule) void {
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

fn rulesHamburgerPopup(rule: *Rule) void {
    var pos = igGetIO().MousePos;
    pos.x -= 100;
    igSetNextWindowPos(pos, ImGuiCond_Appearing, ImVec2{});

    if (igBeginPopup("rules_hamburger", ImGuiWindowFlags_None)) {
        igText("Shift:");
        igSameLine(0, 10);
        if (ogButton("<")) {
            rule.shift(.left);
        }

        igSameLine(0, 7);
        if (ogButton("^")) {
            rule.shift(.up);
        }

        igSameLine(0, 7);
        if (ogButton("\\/")) {
            rule.shift(.down);
        }

        igSameLine(0, 7);
        if (ogButton(">")) {
            rule.shift(.right);
        }

        igText("Flip: ");
        igSameLine(0, 10);
        if (ogButton("Horiz")) {
            rule.flip(.horizontal);
        }

        igSameLine(0, 4);
        if (ogButton("Vert")) {
            rule.flip(.vertical);
        }

        igEndPopup();
    }
}

fn resultPopup(state: *tk.AppState, rule: *Rule) void {
    var content_start_pos = ogGetCursorScreenPos();

    ogImage(state.texture);

    // draw selected tiles
    var iter = rule.selected_data.iter();
    while (iter.next()) |index| {}

    // check input for toggling state
    if (igIsItemHovered(ImGuiHoveredFlags_None)) {
        if (igIsMouseClicked(0, false)) {
            var tile = tileIndexUnderMouse(@floatToInt(usize, state.map_rect_size), content_start_pos);
        }
    }
}

fn tileIndexUnderMouse(rect_size: usize, screen_space_offset: ImVec2) struct { x: usize, y: usize } {
    var pos = igGetIO().MousePos;
    pos.x -= screen_space_offset.x;
    pos.y -= screen_space_offset.y;

    return .{ .x = @divTrunc(@floatToInt(usize, pos.x), rect_size), .y = @divTrunc(@floatToInt(usize, pos.y), rect_size) };
}
