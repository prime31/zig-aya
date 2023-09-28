const std = @import("std");
const aya = @import("../aya.zig");
const c = aya.c;
const meta = aya.meta;
const app = @import("mod.zig");

const App = app.App;
const World = app.World;
const Commands = app.Commands;
const Res = app.Res;
const ResMut = app.ResMut;
const Local = app.Local;

const Events = app.Events;
const EventReader = app.EventReader;
const EventWriter = app.EventWriter;

pub const AppWrapper = struct { app: *App };
pub const RunWhenPaused = struct {};
pub const SystemPaused = struct {};

pub const SystemSort = struct {
    phase: u64,
    order_in_phase: i32 = 0,
};

pub fn addSystem(world: *c.ecs_world_t, phase: u64, comptime System: type) u64 {
    return addSystemToEntity(world, c.ecs_new_id(world), phase, System);
}

pub fn addSystemToEntity(world: *c.ecs_world_t, id: u64, phase: u64, comptime System: type) u64 {
    var entity_desc = std.mem.zeroes(c.ecs_entity_desc_t);
    entity_desc.id = id;
    entity_desc.name = if (@hasDecl(System, "name")) System.name else aya.utils.typeNameLastComponent(System);
    if (phase > 0) {
        entity_desc.add[0] = world.componentId(SystemSort);
        entity_desc.add[1] = phase;
        entity_desc.add[2] = c.ecs_make_pair(c.EcsDependsOn, phase); // required for disabling systems by phase
    }

    if (phase > 0 and @hasDecl(System, "run_when_paused") and System.run_when_paused)
        entity_desc.add[3] = world.componentId(RunWhenPaused);

    // Proper order of operations:
    // - loop through all Fn params:
    //      - if an Iterator is found use it to create and set the ecs_system_desc_t
    //      - if not, create a ecs_system_desc_t and fill in the entity, callback and run
    //      - if a Query(T) exists create a Query for it and stick it in a Local

    var system_desc: ?c.ecs_system_desc_t = null;

    // allowed params: *Iterator(T), Querty(T), Res(T), ResMut(T), *World
    const fn_info = @typeInfo(@TypeOf(System.run)).Fn;
    inline for (fn_info.params) |param| {
        if (@typeInfo(param.type.?) == .Pointer) {
            const T = std.meta.Child(param.type.?);

            // check for known associated types. components_type is on Iterator(T)
            if (@hasDecl(T, "components_type")) {
                var tmp_system_desc = std.mem.zeroes(c.ecs_system_desc_t);
                tmp_system_desc.entity = c.ecs_entity_init(world, &entity_desc);
                tmp_system_desc.multi_threaded = true;
                tmp_system_desc.run = wrapSystemFn(System.run);
                tmp_system_desc.query = meta.generateQueryDesc(world, T.components_type);
                tmp_system_desc.interval = if (@hasDecl(T, "interval")) T.interval else 0;
                system_desc = tmp_system_desc;
            }

            // query_type is on Iterator(T)
            if (@hasDecl(T, "query_type")) {
                var query = T.init(world);
                var application: *App = world.getSingleton(AppWrapper).?.app;
                application.world.locals.insert(@TypeOf(query), system_desc.?.entity, query);
            }
        }
    }

    if (system_desc == null) {
        system_desc = std.mem.zeroInit(c.ecs_system_desc_t, .{
            .entity = c.ecs_entity_init(world, &entity_desc),
            .run = wrapSystemFn(System.run),
        });
    }

    return c.ecs_system_init(world, &system_desc.?);
}

pub fn addObserver(world: *c.ecs_world_t, event: u64, runFn: anytype) void {
    var entity_desc = std.mem.zeroes(c.ecs_entity_desc_t);
    entity_desc.id = c.ecs_new_id(world);
    entity_desc.name = @typeName(@TypeOf(runFn));

    // allowed params: *Iterator(T), Res(T), ResMut(T), *World
    const fn_info = @typeInfo(@TypeOf(runFn)).Fn;
    var observer_desc: c.ecs_observer_desc_t = inline for (fn_info.params) |param| {
        if (@typeInfo(param.type.?) == .Pointer) {
            const T = std.meta.Child(param.type.?);
            if (@hasDecl(T, "components_type")) {
                var observer_desc = std.mem.zeroes(c.ecs_observer_desc_t);
                observer_desc.events[0] = event;
                observer_desc.entity = c.ecs_entity_init(world, &entity_desc);
                observer_desc.callback = wrapSystemFn(runFn);
                observer_desc.filter = meta.generateFilterDesc(world, T.components_type);

                if (@hasDecl(T.components_type, "instanced") and T.components_type.instanced) observer_desc.filter.instanced = true;
                break observer_desc;
            }
        }
    } else @panic("observers must have an Iterator");

    _ = c.ecs_observer_init(world, &observer_desc);
}

fn wrapSystemFn(comptime cb: anytype) fn ([*c]c.ecs_iter_t) callconv(.C) void {
    const Closure = struct {
        const callback = cb;

        pub fn closure(it: [*c]c.ecs_iter_t) callconv(.C) void {
            const Args = std.meta.ArgsTuple(@TypeOf(cb));
            var args: Args = undefined;

            var has_iterator = false;
            inline for (@typeInfo(Args).Struct.fields) |f| {
                const Child = meta.FinalChild(f.type);

                if (@hasDecl(Child, "components_type")) {
                    var iterator = aya.Iterator(Child.components_type).init(it, c.ecs_iter_next);
                    @field(args, f.name) = &iterator;
                    has_iterator = true;
                    continue;
                }

                if (@hasDecl(Child, "query_type")) {
                    var application: *App = it.*.world.?.getSingleton(AppWrapper).?.app;
                    @field(args, f.name) = application.world.locals.getLocalMut(Child, it.*.system);
                }

                if (Child == World) {
                    var application = it.*.world.?.getSingleton(AppWrapper).?.app;
                    @field(args, f.name) = &application.world;
                    continue;
                }

                if (Child == Commands) {
                    @field(args, f.name) = Commands.init(it.*.world.?);
                    continue;
                }

                if (@hasDecl(Child, "res_type")) {
                    var application = it.*.world.?.getSingleton(AppWrapper).?.app;
                    @field(args, f.name) = Child{ .resource = application.world.getResource(Child.res_type) };
                    continue;
                }

                if (@hasDecl(Child, "res_mut_type")) {
                    var application = it.*.world.?.getSingleton(AppWrapper).?.app;
                    @field(args, f.name) = Child{ .resource = application.world.getResourceMut(Child.res_mut_type) };
                    continue;
                }

                if (@hasDecl(Child, "event_type")) {
                    var application = it.*.world.?.getSingleton(AppWrapper).?.app;
                    @field(args, f.name) = Child{ .events = application.world.getResourceMut(Events(Child.event_type)).? };
                    continue;
                }

                if (@hasDecl(Child, "local_type")) {
                    var application = it.*.world.?.getSingleton(AppWrapper).?.app;
                    @field(args, f.name) = Child{ .local = application.world.locals.getLocalMut(Child.local_type, it.*.system) };
                    continue;
                }
            }

            @call(.always_inline, callback, args);

            // systems with no Iterator still need to finalize the iterator
            if (!has_iterator) c.ecs_iter_fini(it);
        }
    };
    return Closure.closure;
}
