const std = @import("std");
const aya = @import("aya.zig");
const math = @import("math/math.zig");
const gfx = aya.gfx;

pub const Debug = struct {
    debug_items: std.ArrayList(DebugDrawCommand),

    const DebugDrawCommand = union(enum) {
        point: Point,
        line: Line,
        rect: Rect,
        circle: Circle,
        text: Text,
    };

    const Point = struct {
        pos: math.Vec2,
        size: f32,
        color: math.Color,
    };

    const Line = struct {
        pt1: math.Vec2,
        pt2: math.Vec2,
        thickness: f32,
        color: math.Color,
    };

    const Rect = struct {
        pos: math.Vec2,
        w: f32,
        h: f32,
        thickness: f32,
        hollow: bool = false,
        color: math.Color,
    };

    const Circle = struct {
        center: math.Vec2,
        r: f32,
        thickness: f32,
        hollow: bool = true,
        color: math.Color,
    };

    const Text = struct {
        pos: math.Vec2,
        text: [:0]const u8,
        color: math.Color,
    };

    pub fn init() !Debug {
        return Debug{
            .debug_items = try std.ArrayList(DebugDrawCommand).initCapacity(aya.mem.allocator, 5),
        };
    }

    pub fn deinit(self: Debug) void {
        self.debug_items.deinit();
    }

    pub fn render(self: *Debug, enabled: bool) void {
        if (enabled) {
            for (self.debug_items.items) |item| {
                switch (item) {
                    .point => |pt| gfx.drawPoint(pt.pos, pt.size, pt.color),
                    .line => |line| gfx.drawLine(line.pt1, line.pt2, line.thickness, line.color),
                    .rect => |rect| {
                        if (rect.hollow) {
                            gfx.drawHollowRect(rect.pos, rect.w, rect.h, rect.thickness, rect.color);
                        } else {
                            gfx.drawRect(rect.pos, rect.w, rect.h, rect.color);
                        }
                    },
                    .circle => |circle| gfx.drawCircle(circle.center, circle.r, circle.thickness, 12, circle.color),
                    .text => {}, // draw_text(item.text.text);
                }
            }
        }
        self.debug_items.items.len = 0;
    }

    pub fn drawPoint(self: *Debug, pos: math.Vec2, size: f32, color: ?math.Color) void {
        const point = Point{ .pos = pos, .size = size, .color = color orelse math.Color.white };
        self.debug_items.append(.{ .point = point }) catch return;
    }

    pub fn drawLine(self: *Debug, pt1, pt2: math.Vec2, thickness: f32, color: ?math.Color) void {
        const line = Line{ .pt2 = pt1, .pt2 = pt2, .thickness = thickness, .color = color orelse math.Color.white };
        self.debug_items.append(.{ .line = line }) catch return;
    }

    pub fn drawRect(self: *Debug, pos: math.Vec2, width: f32, height: f32, thickness: f32, color: ?math.Color) void {
        const rect = Rect{ .pos = pos, .w = width, .h = height, .thickness = thickness, .hollow = false, .color = color orelse math.Color.white };
        self.debug_items.append(.{ .rect = rect }) catch return;
    }

    pub fn drawHollowRect(self: *Debug, pos: math.Vec2, width: f32, height: f32, thickness: f32, color: ?math.Color) void {
        const rect = Rect{ .pos = pos, .w = width, .h = height, .thickness = thickness, .hollow = true, .color = color orelse math.Color.white };
        self.debug_items.append(.{ .rect = rect }) catch return;
    }

    pub fn drawHollowCircle(self: *Debug, center: math.Vec2, radius: f32, thickness: f32, color: ?math.Color) void {
        const circle = Circle{ .center = center, .radius = radius, .thickness = thickness, .color = color orelse math.Color.white };
        self.debug_items.append(.{ .circle = circle }) catch return;
    }

    pub fn drawText(self: *Debug, text: []const u8, pos: math.Vec2, color: ?math.Color) void {
        const c_str = std.mem.dupeZ(aya.mem.tmp_allocator, u8, text) catch return;
        const text_item = Text{ .pos = pos, .text = c_str, .color = color orelse math.Color.white };
        self.debug_items.append(.{ .text = text_item }) catch return;
    }
};
