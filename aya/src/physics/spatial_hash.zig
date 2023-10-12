const std = @import("std");
const aya = @import("../../aya.zig");
const physics = @import("physics.zig");

// stores a mapping of the hashed position -> list of id's in the cell
const CellMap = physics.MultiHashMap(u64, u32);

pub const SpatialHash = struct {
    cells: CellMap,
    colliders: std.AutoHashMap(u32, physics.Collider),
    cell_size: u32,
    inv_cell_size: f32,
    id_counter: u32 = 0,
    bounds: aya.math.RectI = .{},
    allocator: std.mem.Allocator,

    pub fn init(allocator: ?std.mem.Allocator, cell_size: u32) SpatialHash {
        const alloc = allocator orelse aya.mem.allocator;

        return .{
            .cells = CellMap.init(alloc),
            .colliders = std.AutoHashMap(u32, physics.Collider).init(alloc),
            .cell_size = cell_size,
            .inv_cell_size = 1 / @as(f32, @floatFromInt(cell_size)),
            .allocator = alloc,
        };
    }

    pub fn deinit(self: *SpatialHash) void {
        self.cells.deinit();
        self.colliders.deinit();
    }

    fn expandBounds(self: *SpatialHash, x: i32, y: i32, x1: i32, y1: i32) void {
        // expand our bounds to encompass the new collider
        if (!self.bounds.contains(x, y)) {
            self.bounds = self.bounds.unionPoint(x, y);
        }
        if (!self.bounds.contains(x1, y1)) {
            self.bounds = self.bounds.unionPoint(x1, y1);
        }
    }

    /// gets the cell x,y values for a world-space x,y value
    fn cellCoords(self: SpatialHash, x: f32, y: f32) struct { x: i32, y: i32 } {
        return .{
            .x = @as(i32, @intFromFloat(@trunc(x * self.inv_cell_size))),
            .y = @as(i32, @intFromFloat(@trunc(y * self.inv_cell_size))),
        };
    }

    pub fn add(self: *SpatialHash, collider: physics.Collider) u32 {
        const id = self.id_counter;
        self.id_counter += 1;

        const bounds = collider.bounds();
        const tl = self.cellCoords(bounds.x, bounds.y);
        const br = self.cellCoords(bounds.right(), bounds.bottom());

        // expand our bounds to encompass the new collider
        self.expandBounds(tl.x, tl.y, br.x, br.y);

        return id;
    }
};

test {
    var hash = SpatialHash.init(std.testing.allocator, 150);
    defer hash.deinit();

    const circle = physics.Collider.init(physics.ColliderKind{
        .circle = .{
            .x = 10,
            .y = 10,
            .r = 20,
        },
    });
    const circle_id = hash.add(circle);
    _ = circle_id;
}
