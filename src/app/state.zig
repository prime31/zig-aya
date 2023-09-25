const std = @import("std");
const aya = @import("../aya.zig");
const c = @import("ecs").c;
const app = @import("mod.zig");

const Res = app.Res;
const ResMut = app.ResMut;
const Iterator = @import("ecs").Iterator;

pub fn State(comptime T: type) type {
    return struct {
        const Self = @This();
        base: u64,
        state: T,
        state_map: std.enums.EnumMap(T, u64),

        pub fn init(base: u64, state: T, state_map: std.enums.EnumMap(T, u64)) Self {
            return .{ .base = base, .state = state, .state_map = state_map };
        }

        pub fn entityForTag(self: Self, state: T) u64 {
            return self.state_map.getAssertContains(state);
        }
    };
}

pub fn NextState(comptime T: type) type {
    return struct {
        const Self = @This();
        state: T,

        pub fn init(state: T) Self {
            return .{ .state = state };
        }

        pub fn set(self: *Self, world: *c.ecs_world_t, new_state: T) void {
            self.state = new_state;
            world.newEntity().set(StateChanged(T){ .next_state = new_state });
        }
    };
}

fn StateChanged(comptime T: type) type {
    return struct { next_state: T };
}

pub fn StateChangeCheckSystem(comptime T: type) type {
    return struct {
        const Self = @This();
        next_state: *StateChanged(T),

        pub const name = "StateChangeCheckSystem_" ++ aya.utils.typeNameLastComponent(T);

        pub fn run(state: ResMut(State(T)), iter: *Iterator(Self)) void {
            std.debug.assert(iter.iter.count <= 1);

            // TODO:
            // - when NextState changes, query for all with the base tag of the enum
            //     * (done) any sytems in the current state, normal phases are disabled
            //     * (done) any systems in the current state OnExit run (handle later, needs thought)
            //     * install run_enter_schedule system that will run any systems in OnEnter(current_state)
            //     * any systems in next state OnEnter run (handle later, needs thought)
            //     * any systems with OnTransition(T) { .from: T, .to: T } should be called
            //     * any systems in normal phases are enabled (can use run_if for these or change detection on NextState)

            while (iter.next()) |comps| {
                std.debug.print("-- -- ---- StateChangeCheckSystem(T) {}\n", .{comps.next_state});
                // grab the previous and current State entities and set State(T) to the new state
                const state_res = state.get().?;
                const prev_state_entity = state_res.entityForTag(state_res.state);
                const next_state_entity = state_res.entityForTag(comps.next_state.next_state);

                state.get().?.state = comps.next_state.next_state;

                // disable all systems with prev_state and enable all systems with next_state
                var filter_desc = std.mem.zeroes(c.ecs_filter_desc_t);
                filter_desc.terms[0].id = iter.world().pair(state_res.base, c.EcsWildcard);
                filter_desc.terms[1].id = c.EcsSystem;
                filter_desc.terms[1].inout = c.EcsInOutNone;
                filter_desc.terms[2].id = c.EcsDisabled; // make sure we match disabled systems!
                filter_desc.terms[2].inout = c.EcsInOutNone;
                filter_desc.terms[2].oper = c.EcsOptional;

                const filter = c.ecs_filter_init(iter.world(), &filter_desc);
                defer c.ecs_filter_fini(filter);

                var it = c.ecs_filter_iter(iter.world(), filter);
                while (c.ecs_filter_next(&it)) {
                    var i: usize = 0;
                    while (i < it.count) : (i += 1) {
                        const system_state = c.ecs_get_target(it.world, it.entities[i], state_res.base, 0);
                        if (system_state == prev_state_entity) {
                            c.ecs_enable(it.world.?, it.entities[i], false);
                        } else if (system_state == next_state_entity) {
                            c.ecs_enable(it.world.?, it.entities[i], system_state == next_state_entity);
                        }
                    }
                }

                // delete the entity
                iter.entity().delete();
            }
        }
    };
}
