const std = @import("std");
const aya = @import("aya");
const data = @import("data.zig");
const Map = data.Map;
const Rule = data.Rule;
const RuleTile = data.RuleTile;
const AppState = @import("tilekit.zig").AppState;

/// runs the input map directly from Map through all the pre-processing rules and copies the data into state
pub fn generateProcessedMap(state: *AppState) void {
    @memcpy(state.processed_map_data.ptr, state.map.data.ptr, state.map.data.len);

    if (state.map.pre_rulesets.items.len == 0) {
        return;
    }

    // we need an extra buffer so that we can write into it for each iteration so our rules dont go hog-crazy as we iterate
    var buffer = aya.mem.tmp_allocator.alloc(u8, state.map.data.len) catch unreachable;
    @memcpy(buffer.ptr, state.map.data.ptr, buffer.len);

    var i: usize = 0;
    while (i < state.map.repeat) : (i += 1) {
        var y: usize = 0;
        while (y < state.map.h) : (y += 1) {
            var x: usize = 0;
            while (x < state.map.w) : (x += 1) {
                for (state.map.pre_rulesets.items) |ruleset| {
                    buffer[x + y * state.map.w] = transformTileWithRuleSet(state, state.processed_map_data, ruleset.items, true, x, y);
                    @memcpy(state.processed_map_data.ptr, buffer.ptr, buffer.len);
                }
            }
        }
    }
}

pub fn generateOutputMap(state: *AppState) void {
    var y: usize = 0;
    while (y < state.map.h) : (y += 1) {
        var x: usize = 0;
        while (x < state.map.w) : (x += 1) {
            state.final_map_data[x + y * state.map.w] = transformTileWithRuleSet(state, state.processed_map_data, state.map.ruleset.items, false, x, y);
        }
    }
}

pub fn transformTileWithRuleSet(state: *AppState, tile_source: []u8, rules: []Rule, is_pre_ruleset: bool, x: usize, y: usize) u8 {
    for (rules) |*rule| brk: {
        if (rule.result_tiles.len == 0) continue;

        // at least one rule must pass to have a result
        var rule_passed = false;
        for (rule.rule_tiles) |rule_tile, i| {
            if (rule_tile.state == .none) continue;
            const x_offset = @intCast(i32, @mod(i, 5)) - 2;
            const y_offset = @intCast(i32, @divTrunc(i, 5)) - 2;

            // stay in bounds! We could be looking for a tile 2 away from x,y in any direction
            const actual_x = @intCast(i32, x) + x_offset;
            const actual_y = @intCast(i32, y) + y_offset;
            const processed_tile = if (actual_x < 0 or actual_y < 0 or actual_x >= state.map.w or actual_y >= state.map.h) 0 else blk: {
                const index = @intCast(usize, actual_x) + @intCast(usize, actual_y) * state.map.w;
                break :blk tile_source[index];
            };

            // if any rule fails, we are done with this RuleSet
            if (!rule_tile.passes(processed_tile)) {
                break :brk;
            }

            rule_passed = true;
        }

        // a Rule passed. we use the chance to decide if we will return a tile
        // const chance = aya.math.rand.chance(@intToFloat(f32, ruleset.chance) / 100);
        const random = state.random_map_data[x + y * state.map.w];
        const chance = random.float < @intToFloat(f32, rule.chance) / 100;
        if (rule_passed and chance) {
            return @intCast(u8, rule.resultTile(random.int) + 1);
        }
    }

    if (is_pre_ruleset) {
        return tile_source[x + y * state.map.w];
    }

    return 0;
}
