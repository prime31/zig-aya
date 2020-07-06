const std = @import("std");

/// Optional Group info:
/// - If the value in both objects is equal and positive, the objects always collide.
/// - If the value in both objects is equal and negative, the objects never collide.
pub const CollisionFilter = struct {
    category: u32 = 0xffffffff, /// bit mask describing which layers this object belongs to
    mask: u32 = 0xffffffff, /// bit mask describing which layers this object can collide with
    group: i32 = 0, /// optional override for the bit mask checks

    pub fn init() CollisionFilter {
        return .{};
    }

    pub fn collidesWith(self: CollisionFilter, other: CollisionFilter) bool {
        if (self.group > 0 and self.group == other.group) {
            return true;
        }

        if (self.group < 0 and self.group == other.group) {
            return false;
        }

        return (self.category & other.mask) != 0 and (other.category & self.mask) != 0;
    }
};

test "collidesWith" {
    var a = CollisionFilter.init();
    var b = CollisionFilter.init();

    std.testing.expect(a.collidesWith(b));
    std.testing.expect(b.collidesWith(a));

    a.category = 0xff000000;
    b.mask = 0x00ff0000;
    std.testing.expect(!a.collidesWith(b));

    a.category = 0x0f000000;
    b.mask = 0x0f000000;
    std.testing.expect(a.collidesWith(b));

    a.group = -1;
    b.group = -1;
    std.testing.expect(!a.collidesWith(b));

    a.group = 1;
    b.group = 1;
    std.testing.expect(a.collidesWith(b));
}