const std = @import("std");
const ecs = @import("ecs");
const flecs = ecs.c;

pub const Position = struct { x: f32, y: f32 };

pub fn main() !void {
    var world = ecs.Ecs.init();
    defer world.deinit();

    const entity1 = world.newEntityWithName("Entity1");
    const entity2 = world.newEntityWithName("Entity2");
    const entity3 = world.newEntityWithName("Entity3");
    const entity4 = world.newEntityWithName("Entity4");

    entity1.set(Position{ .x = 0, .y = 0 });
    entity2.set(Position{ .x = 2, .y = 2 });
    entity3.set(Position{ .x = 3, .y = 3 });
    entity4.set(Position{ .x = 4, .y = 4 });

    std.debug.print("\n\niterate Position with a Term\n", .{});
    var term = ecs.Term(Position).init(world);
    defer term.deinit();

    var iter = term.iterator();
    while (iter.next()) |pos| {
        std.debug.print("pos: {}, entity: {}, name: {s}\n", .{ pos, iter.entity(), iter.entity().getName() });
    }

    std.debug.print("\n\niterate Position with a Term each\n", .{});
    term.each(eachTerm);
}

fn eachTerm(entity: ecs.Entity, pos: *Position) void {
    std.debug.print("pos: {}, entity: {} name: {s}\n", .{ pos, entity, entity.getName() });
}
