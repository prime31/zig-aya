const std = @import("std");
const aya = @import("aya");
const math = aya.math;
const Color = math.Color;

var manager: EntityManager = undefined;

pub fn main() !void {
    try aya.run(.{
        .init = init,
        .update = update,
        .render = render,
    });

    manager.deinit();
}

fn init() void {
    manager = EntityManager.init();
    var player = manager.create(Player);
    manager.destroy(player.entity, Player);

    var e2 = manager.create(Enemy);
}

fn update() void {}

fn render() void {
    aya.gfx.beginPass(.{});
    aya.draw.line(aya.math.Vec2.init(0, 0), aya.math.Vec2.init(640, 480), 2, aya.math.Color.blue);
    aya.gfx.endPass();
}

pub const Player = struct {
    entity: *Entity = undefined,
};

pub const Enemy = struct {
    entity: *Entity = undefined,
};

pub const Entity = struct {
    pos: math.Vec2 = .{},

    slot: usize = 0,
    entity_type: enum { player, enemy } = .player,
    derivied_pointer: usize = 0,

    pub fn cast(self: Entity, comptime T: type) *T {
        return @intToPtr(*T, self.derivied_pointer);
    }
};

pub const EntityManager = struct {
    entities: std.ArrayList(Entity),
    occupied: std.ArrayList(bool),

    const batch_size = 100;

    const EntityBatch = struct {
        entities: [batch_size]Entity = [_]Entity{.{}} ** batch_size,
        occupied: [batch_size]bool = [_]bool{false} ** batch_size,

        pub fn init() EntityBatch {
            return .{};
        }

        pub fn findEmpty(self: EntityBatch) ?usize {
            for (self.occupied) |occupied, i| {
                if (!occupied) {
                    return i;
                }
            }
            return null;
        }
    };

    pub fn init() EntityManager {
        return .{
            .entities = std.ArrayList(Entity).init(aya.mem.allocator),
            .occupied = std.ArrayList(bool).init(aya.mem.allocator),
        };
    }

    pub fn deinit(self: EntityManager) void {
        self.entities.deinit();
        self.occupied.deinit();
    }

    pub fn create(self: *EntityManager, comptime T: type) *T {
        var index: usize = std.math.maxInt(usize);
        for (self.occupied.items) |occupied, i| {
            if (!occupied) {
                index = i;
                break;
            }
        }

        if (index == std.math.maxInt(usize)) {
            index = self.entities.items.len;
            _ = self.entities.addOne() catch unreachable;
            _ = self.occupied.addOne() catch unreachable;
        }

        self.occupied.items[index] = false;
        var entity = &self.entities.items[index];
        entity.slot = index;

        var derived = aya.mem.allocator.create(T) catch unreachable;
        derived.entity = &self.entities.items[index];
        entity.derivied_pointer = @ptrToInt(derived);
        return derived;
    }

    pub fn destroy(self: *EntityManager, entity: *Entity, comptime T: type) void {
        self.occupied.items[entity.slot] = false;
        aya.mem.allocator.destroy(entity.cast(T));
    }
};
