const aya = @import("../../aya.zig");
const tilemap = aya.tilemap;
const math = aya.math;

pub const CollisionIterator = struct {
    is_h: bool,
    first_primary: i32,
    last_primary: i32,
    prim_incr: i32,
    first_secondary: i32,
    last_secondary: i32,
    secondary_incr: i32,
    primary: i32,
    secondary: i32,

    const Vec2I = struct { x: i32, y: i32 };

    pub fn init(map: *tilemap.Map, bounds: math.RectI, edge: math.Edge) CollisionIterator {
        const is_h = edge.horizontal();
        const prim_axis = if (is_h) math.Axis.x else math.Axis.y;
        const op_axis = if (prim_axis == .x) math.Axis.y else math.Axis.x;

        const op_dir = edge.opposing();
        const frst_prim = worldToTile(map, bounds.side(op_dir), prim_axis);
        const lst_prim = worldToTile(map, bounds.side(edge), prim_axis);
        const prim_incr: i32 = if (edge.max()) 1 else -1;

        const min = worldToTile(map, if (is_h) bounds.top() else bounds.left(), op_axis);
        const mid = worldToTile(map, if (is_h) bounds.centerY() else bounds.centerX(), op_axis);
        const max = worldToTile(map, if (is_h) bounds.bottom() else bounds.right(), op_axis);

        const is_pos = mid - min < max - mid;
        const frst_secondary = if (is_pos) min else max;
        const lst_secondary = if (!is_pos) min else max;
        const secondary_incr: i32 = if (is_pos) 1 else -1;

        return .{
            .is_h = is_h,
            .first_primary = frst_prim,
            .last_primary = lst_prim,
            .prim_incr = prim_incr,
            .first_secondary = frst_secondary,
            .last_secondary = lst_secondary,
            .secondary_incr = secondary_incr,
            .primary = frst_prim,
            .secondary = frst_secondary - secondary_incr,
        };
    }

    pub fn next(self: *CollisionIterator) ?Vec2I {
        // increment the inner loop
        self.secondary += self.secondary_incr;
        if (self.secondary != self.last_secondary + self.secondary_incr) {
            return self.current();
        }

        // reset the inner loop
        self.secondary = self.first_secondary;

        // increment the outer loop
        self.primary += self.prim_incr;
        if (self.primary == self.last_primary + self.prim_incr) {
            return null;
        }

        return self.current();
    }

    fn current(self: CollisionIterator) Vec2I {
        if (self.is_h) {
            return .{ .x = self.primary, .y = self.secondary };
        }
        return .{ .x = self.secondary, .y = self.primary };
    }
};

fn worldToTile(map: *tilemap.Map, pos: i32, axis: math.Axis) i32 {
    return if (axis == .x) map.worldToTileX(@as(f32, @floatFromInt(pos))) else map.worldToTileY(@as(f32, @floatFromInt(pos)));
}
