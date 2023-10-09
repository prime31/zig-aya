const std = @import("std");
const aya = @import("../aya.zig");
const c = @import("../ecs/mod.zig").c;
const app = @import("mod.zig");

const Res = app.Res;
const ResMut = app.ResMut;
const Iterator = @import("../ecs/mod.zig").Iterator;
const Commands = app.Commands;

/// Resource. Stores the tags needed for the State T
pub fn State(comptime T: type) type {
    std.debug.assert(@typeInfo(T) == .Enum);

    return struct {
        const Self = @This();
        const StateMap = std.enums.EnumMap(T, u64);

        /// the entity for the State enum type T
        base_entity: u64,
        state: T,
        state_map: StateMap,
        enter_state_map: StateMap,
        exit_state_map: StateMap,

        pub fn init(base_entity: u64, state: T, state_map: StateMap, enter_state_map: StateMap, exit_state_map: StateMap) Self {
            return .{
                .base_entity = base_entity,
                .state = state,
                .state_map = state_map,
                .enter_state_map = enter_state_map,
                .exit_state_map = exit_state_map,
            };
        }

        pub fn entityForTag(self: Self, state: T) u64 {
            return self.state_map.getAssertContains(state);
        }

        pub fn entityForEnterTag(self: Self, state: T) u64 {
            return self.enter_state_map.getAssertContains(state);
        }

        pub fn entityForExitTag(self: Self, state: T) u64 {
            return self.exit_state_map.getAssertContains(state);
        }
    };
}

/// Resource. Grab and call `NextState(T).set` to trigger a state change
pub fn NextState(comptime T: type) type {
    std.debug.assert(@typeInfo(T) == .Enum);

    return struct {
        const Self = @This();
        state: T,

        pub fn init(state: T) Self {
            return .{ .state = state };
        }

        pub fn set(self: *Self, commands: Commands, new_state: T) void {
            self.state = new_state;
            commands.spawnEmpty().set(StateChanged(T){ .next_state = new_state });
        }
    };
}

pub fn OnEnter(comptime enum_tag: anytype) type {
    std.debug.assert(@typeInfo(@TypeOf(enum_tag)) == .Enum);

    return struct {
        pub const on_enter = true;
        pub const state_type = @TypeOf(enum_tag);
        pub const state = enum_tag;
    };
}

pub fn OnExit(comptime enum_tag: anytype) type {
    std.debug.assert(@typeInfo(@TypeOf(enum_tag)) == .Enum);

    return struct {
        pub const on_exit = true;
        pub const state_type = @TypeOf(enum_tag);
        pub const state = enum_tag;
    };
}

// Relationships used to tag OnTransitions
pub const FromTransition = struct {};
pub const ToTransition = struct {};

pub fn OnTransition(comptime from_enum_tag: anytype, comptime to_enum_tag: anytype) type {
    std.debug.assert(@typeInfo(@TypeOf(from_enum_tag)) == .Enum);
    std.debug.assert(@TypeOf(from_enum_tag) == @TypeOf(to_enum_tag));
    std.debug.assert(from_enum_tag != to_enum_tag);

    return struct {
        pub const on_transition = true;
        pub const state_type = @TypeOf(from_enum_tag);
        pub const from_state = from_enum_tag;
        pub const to_state = to_enum_tag;
    };
}

fn StateChanged(comptime T: type) type {
    std.debug.assert(@typeInfo(T) == .Enum);

    return struct { next_state: T };
}

pub fn StateChangeCheckSystem(comptime T: type) type {
    return struct {
        const Self = @This();
        next_state: *StateChanged(T),

        pub const name = "StateChangeCheckSystem_" ++ aya.utils.typeNameLastComponent(T);

        pub fn run(state: ResMut(State(T)), iter: *Iterator(Self)) void {
            // - when NextState changes, query for all with the base tag of the enum
            //     * any systems in current state OnExit run
            //     * any systems in next state OnEnter run
            //     * any systems with OnTransitionn with matching from and to states run
            //     * any systems in the current state are disabled
            //     * any systems in the next state are enabled
            //     * (maybe TODO) install run_enter_schedule system that will run any systems in OnEnter(current_state)any systems with OnTransition(T) { .from: T, .to: T } should be called

            while (iter.next()) |comps| {
                // grab the previous and current State entities and set State(T) to the new state
                const state_res: *State(T) = state.get().?;
                const prev_state_entity = state_res.entityForTag(state_res.state);
                const next_state_entity = state_res.entityForTag(comps.next_state.next_state);

                // run OnExits
                {
                    var filter_desc = c.ecs_filter_desc_t{};
                    filter_desc.terms[0].id = c.EcsSystem;
                    filter_desc.terms[0].inout = c.EcsInOutNone;
                    filter_desc.terms[1].id = state_res.entityForExitTag(state_res.state);
                    filter_desc.terms[1].inout = c.EcsInOutNone;

                    const filter = c.ecs_filter_init(iter.commands().ecs, &filter_desc);
                    defer c.ecs_filter_fini(filter);

                    var it = c.ecs_filter_iter(iter.commands().ecs, filter);
                    while (c.ecs_filter_next(&it)) {
                        var i: usize = 0;
                        while (i < it.count) : (i += 1) {
                            _ = c.ecs_run(iter.iter.real_world, it.entities[i], 0, null);
                        }
                    }
                }

                // run OnEnters
                {
                    var filter_desc = c.ecs_filter_desc_t{};
                    filter_desc.terms[0].id = c.EcsSystem;
                    filter_desc.terms[0].inout = c.EcsInOutNone;
                    filter_desc.terms[1].id = state_res.entityForEnterTag(comps.next_state.next_state);
                    filter_desc.terms[1].inout = c.EcsInOutNone;

                    const filter = c.ecs_filter_init(iter.commands().ecs, &filter_desc);
                    defer c.ecs_filter_fini(filter);

                    var it = c.ecs_filter_iter(iter.commands().ecs, filter);
                    while (c.ecs_filter_next(&it)) {
                        var i: usize = 0;
                        while (i < it.count) : (i += 1) {
                            _ = c.ecs_run(iter.iter.real_world, it.entities[i], 0, null);
                        }
                    }
                }

                // run OnTransitions
                {
                    var filter_desc = c.ecs_filter_desc_t{};
                    filter_desc.terms[0].id = c.EcsSystem;
                    filter_desc.terms[0].inout = c.EcsInOutNone;
                    filter_desc.terms[1].id = iter.commands().ecs.pair(FromTransition, prev_state_entity);
                    filter_desc.terms[1].inout = c.EcsInOutNone;
                    filter_desc.terms[2].id = iter.commands().ecs.pair(ToTransition, next_state_entity);
                    filter_desc.terms[2].inout = c.EcsInOutNone;

                    const filter = c.ecs_filter_init(iter.commands().ecs, &filter_desc);
                    defer c.ecs_filter_fini(filter);

                    var it = c.ecs_filter_iter(iter.commands().ecs, filter);
                    while (c.ecs_filter_next(&it)) {
                        var i: usize = 0;
                        while (i < it.count) : (i += 1) {
                            _ = c.ecs_run(iter.iter.real_world, it.entities[i], 0, null);
                        }
                    }
                }

                state.get().?.state = comps.next_state.next_state;

                // disable all systems with prev_state and enable all systems with next_state
                var filter_desc = c.ecs_filter_desc_t{};
                filter_desc.terms[0].id = iter.commands().ecs.pair(state_res.base_entity, c.EcsWildcard);
                filter_desc.terms[1].id = c.EcsSystem;
                filter_desc.terms[1].inout = c.EcsInOutNone;
                filter_desc.terms[2].id = c.EcsDisabled; // make sure we match disabled systems!
                filter_desc.terms[2].inout = c.EcsInOutNone;
                filter_desc.terms[2].oper = c.EcsOptional;

                const filter = c.ecs_filter_init(iter.commands().ecs, &filter_desc);
                defer c.ecs_filter_fini(filter);

                var it = c.ecs_filter_iter(iter.commands().ecs, filter);
                while (c.ecs_filter_next(&it)) {
                    var i: usize = 0;
                    while (i < it.count) : (i += 1) {
                        const system_state = c.ecs_get_target(it.world, it.entities[i], state_res.base_entity, 0);
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
