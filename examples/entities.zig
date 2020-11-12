const std = @import("std");
const aya = @import("aya");
const math = aya.math;
const Color = math.Color;

pub fn main() !void {
    try aya.run(.{
        .init = init,
        .update = update,
        .render = render,
    });
}

fn init() !void {
    var manager = EntityManager.init();
    defer manager.deinit();

    var player = manager.create(Player);
    manager.destroy(player.entity, Player);

    var e2 = manager.create(Enemy);

    generational();
}

fn generational() void {
    var manager = GenerationalEntityManager.init(10);
    defer manager.deinit();

    var player = manager.create();
    var enemy = manager.create();

    var player_id = player.id;
    std.debug.print("get player before dead: {}\n", .{manager.getEntity(player_id)});
    manager.destroy(player);
    std.debug.print("get player after dead: {}\n", .{manager.getEntity(player_id)});

    player = manager.create();

    player_id = player.id;
    std.debug.print("get player before dead: {}\n", .{manager.getEntity(player_id)});
    manager.destroy(player);
    std.debug.print("get player after dead: {}\n", .{manager.getEntity(player_id)});
}

fn update() !void {}

fn render() !void {
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

        self.occupied.items[index] = true;
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


pub const GenerationalEntity = struct {
    id: u32,
    pos: math.Vec2 = .{},
};

pub const GenerationalEntityManager = struct {
    entities: []GenerationalEntity,
    handles: []EntityHandle,

    const EntityHandle = struct {
        index: u16,
        generation: u16 = 0,
    };

    pub fn init(count: usize) GenerationalEntityManager {
        var handles = aya.mem.allocator.alloc(EntityHandle, count) catch unreachable;
        var i = count - 1;
        while (count >= 0) : (i -= 1) {
            handles[i] = .{ .index = @intCast(u16, count - 1 - i) };
            if (i == 0) break;
        }

        return .{
            .entities = aya.mem.allocator.alloc(GenerationalEntity, count) catch unreachable,
            .handles = handles,
        };
    }

    pub fn deinit(self: GenerationalEntityManager) void {
        aya.mem.allocator.free(self.entities);
        aya.mem.allocator.free(self.handles);
    }

    pub fn create(self: *GenerationalEntityManager) *GenerationalEntity {
        var slot = self.handles[self.handles.len - 1];
        slot.generation += 1;
        self.handles.len -= 1;

        var entity = &self.entities[slot.index];
        entity.* = std.mem.zeroes(GenerationalEntity);
        entity.id = @bitCast(u32, slot);

        return entity;
    }

    pub fn destroy(self: *GenerationalEntityManager, entity: *GenerationalEntity) void {
        const slot = @bitCast(EntityHandle, entity.id);
        self.handles.len += 1;
        self.handles[self.handles.len - 1] = slot;
        entity.*.id = std.math.maxInt(u32);
    }

    pub fn getEntity(self: *GenerationalEntityManager, id: u32) ?*GenerationalEntity {
        const slot = @bitCast(EntityHandle, id);
        var entity = &self.entities[slot.index];

        if (entity.id == id) return entity;
        return null;
    }
};
