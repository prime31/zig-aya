const std = @import("std");
const aya = @import("aya");

const App = aya.App;
const Iterator = aya.Iterator;
const Query = aya.Query;
const Commands = aya.Commands;

pub const Position = struct { x: f32 = 0, y: f32 = 0 };
pub const Velocity = struct { x: f32 = 0, y: f32 = 0 };

pub fn main() !void {
    App.init()
        .addSystems(aya.Startup, AddEntitiesSystem)
        .addSystems(aya.Update, FirstSystem)
        .run();
}

const AddEntitiesSystem = struct {
    pub fn run(commands: Commands) void {
        commands.newEntity().set(Position{});
        commands.newEntity().set(Position{});
        commands.newEntity().set(Velocity{});
    }
};

const FirstSystem = struct {
    vel: *Velocity,

    pub fn run(iter: *Iterator(FirstSystem), query: *Query(FirstSystemLocalQuery)) void {
        const v = iter.single();
        std.debug.print("-- FirstSystem called with 1 result: {}\n", .{v});

        var query_it = query.iterator();
        while (query_it.next()) |_| {}
        std.debug.print("-- positions count: {} \n", .{query_it.iter.count});
    }
};

const FirstSystemLocalQuery = struct {
    pos: *const Position,
};
