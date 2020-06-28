const std = @import("std");
const print = std.debug.print;
const aya = @import("aya");
const colors = @import("colors.zig");
const brushes_win = @import("brushes_win.zig");
usingnamespace @import("imgui");

const Map = @import("data.zig").Map;
const Rule = @import("data.zig").Rule;

var label: [25]u8 = undefined;

pub fn draw(open: *bool, map: *Map) void {
    if (open.* and igBegin("Rules", open, ImGuiWindowFlags_None)) {
        var delete_index: usize = std.math.maxInt(usize);
        var i: usize = 0;
        while (i < map.rules.items.len) : (i += 1) {
            igPushIDInt(@intCast(c_int, i));
            if (renderRule(map, &map.rules.items[i])) {
                delete_index = i;
            }
        }

        if (delete_index < map.rules.items.len) {
            _ = map.rules.swapRemove(delete_index);
        }

        if (igButton("Add Rule", ImVec2{})) {
            map.addRule();
        }
        igSameLine(0, 0);

        if (igButton("Add 9-Slice", ImVec2{})) {}

        igEnd();
    }
}

fn renderRule(map: *Map, rule: *Rule) bool {
    igPushItemWidth(100);
    std.mem.copy(u8, &label, &rule.name);
    if (igInputText("##name", &label, 100, ImGuiInputTextFlags_None, null, null)) {
        std.mem.copy(u8, &rule.name, &label);
    }
    igSameLine(0, 0);
    igPopItemWidth();

    if (igButton("Pattern", ImVec2{})) {
        igOpenPopup("pattern_popup");
    }
    igSameLine(0, 0);

    if (igButton("Result", ImVec2{})) {
        igOpenPopup("result_popup");
    }
    igSameLine(0, 0);

    igPushItemWidth(50);
    var min: u8 = 0;
    var max: u8 = 100;
    _ = igDragScalar("", ImGuiDataType_U8, &rule.chance, 1, &min, &max, null, 1);
    // _ = igDragFloat("", &rule.chance, 1, 0, 100, "%.0f", 1);
    // igText("100%");
    igSameLine(0, 0);
    igPopItemWidth();

    if (igButton("Copy", ImVec2{})) {
        map.rules.append(rule.clone()) catch unreachable;
    }
    igSameLine(0, 0);

    if (igButton("Delete", ImVec2{})) {
        return true;
    }

    var pos = igGetIO().MousePos;
    pos.x -= 32 * 5 / 2;
    igSetNextWindowPos(pos, ImGuiCond_Appearing, ImVec2{});
    if (igBeginPopup("pattern_popup", ImGuiWindowFlags_None)) {
        patternPopup(rule);
        igEndPopup();
    }

    if (igBeginPopup("result_popup", ImGuiWindowFlags_None)) {
        resultPopup(rule);
        igEndPopup();
    }

    return false;
}

fn patternPopup(rule: *Rule) void {
    igText("Pattern");

    const draw_list = igGetWindowDrawList();

    const rect_size: f32 = 32;
    const pad: f32 = 4;
    const canvas_size = 5 * rect_size + 4 * pad;
    const thickness: f32 = 2;

    var pos = ImVec2{};
    igGetCursorScreenPos(&pos);
    _ = igInvisibleButton("##but", ImVec2{ .x = canvas_size, .y = canvas_size });
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
                brushes_win.drawBrush(rule_tile.tile - 1, tl);
            } else {
                // if empty rule or just with a modifier
                ImDrawList_AddQuadFilled(draw_list, ImVec2{ .x = tl.x, .y = tl.y }, ImVec2{ .x = tl.x + rect_size, .y = tl.y }, ImVec2{ .x = tl.x + rect_size, .y = tl.y + rect_size }, ImVec2{ .x = tl.x, .y = tl.y + rect_size }, colors.colorRgb(0, 0, 0));
            }

            if (x == 2 and y == 2) {
                const size = rect_size - thickness;
                var tl2 = tl;
                tl2.x += 1;
                tl2.y += 1;
                ImDrawList_AddQuad(draw_list, ImVec2{ .x = tl2.x, .y = tl2.y }, ImVec2{ .x = tl2.x + size, .y = tl2.y }, ImVec2{ .x = tl2.x + size, .y = tl2.y + size }, ImVec2{ .x = tl2.x, .y = tl2.y + size }, colors.pattern_center, thickness);
            }

            tl.x -= 1;
            tl.y -= 1;
            if (rule_tile.state == .negated) {
                const size = rect_size + thickness;
                ImDrawList_AddQuad(draw_list, ImVec2{ .x = tl.x, .y = tl.y }, ImVec2{ .x = tl.x + size, .y = tl.y }, ImVec2{ .x = tl.x + size, .y = tl.y + size }, ImVec2{ .x = tl.x, .y = tl.y + size }, colors.brush_negated, thickness);
            } else if (rule_tile.state == .required) {
                const size = rect_size + thickness;
                ImDrawList_AddQuad(draw_list, ImVec2{ .x = tl.x, .y = tl.y }, ImVec2{ .x = tl.x + size, .y = tl.y }, ImVec2{ .x = tl.x + size, .y = tl.y + size }, ImVec2{ .x = tl.x, .y = tl.y + size }, colors.brush_required, thickness);
            }

            if (hovered) {
                if (tl.x <= mouse_pos.x and mouse_pos.x < tl.x + rect_size and tl.y <= mouse_pos.y and mouse_pos.y < tl.y + rect_size) {
                    if (igIsMouseClicked(1, false)) {
                        rule_tile.toggleState(if (aya.input.keyDown(.SDL_SCANCODE_LSHIFT)) .negated else .required);
                    }

                    if (igIsMouseClicked(0, false)) {
                        if (aya.input.keyDown(.SDL_SCANCODE_LSHIFT)) {
                            rule_tile.negate(brushes_win.selected_brush_index + 1);
                        } else {
                            rule_tile.require(brushes_win.selected_brush_index + 1);
                        }
                    }
                }
            }
        }
    }
}

fn resultPopup(rule: *Rule) void {
    igText("result mo-fo");
    _ = igButton("wtf", ImVec2{});
}
