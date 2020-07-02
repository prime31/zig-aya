const std = @import("std");
const aya = @import("aya");
const data = @import("data");
const Map = data.Map;
const Rule = data.Rule;
const RuleTile = data.RuleTile;
const AppState = @import("tilekit.zig").AppState;

/// runs the input map directly from Map through all the pre-processing rules and copies the data into state
pub fn preprocessInputMap(state: *AppState) void {
    @memcpy(state.processed_map_data.ptr, state.map.data.ptr, state.processed_map_data.len);
    // std.mem.copy(u8, state.processed_map_data, state.map.data);
}

pub fn transformTileWithRules(state: *AppState, x: usize, y: usize) u32 {
    for (state.map.rules.items) |*rule| {
        if (rule.selected_data.len == 0) continue;

        for (rule.pattern_data) |pattern, i| {
            if (pattern.state == .none) continue;
            const x_offset = @intCast(i32, @mod(i, 5)) - 2;
            const y_offset = @intCast(i32, @divTrunc(i, 5)) - 2;

            // stay in bounds!
            const actual_x = @intCast(i32, x) + x_offset;
            const actual_y = @intCast(i32, y) + y_offset;
            const processed_tile = if (actual_x < 0 or actual_y < 0) 0 else state.getProcessedTile(@intCast(usize, actual_x), @intCast(usize, actual_y));

            // if any rule fails, we are done
            if (!pattern.passes(processed_tile)) {
                return 0;
            }
        }

        // all RuleTiles passed. we use the chance to decide if we will return a tile
        if (aya.math.rand.chance(@intToFloat(f32, rule.chance) / 100)) {
            return @intCast(u32, rule.resultTile() + 1);
        }
    }

    return 0;
}
