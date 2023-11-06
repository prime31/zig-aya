const std = @import("std");
const aya = @import("../aya.zig");

const Draw = @import("draw.zig").Draw;
const Vec2 = aya.math.Vec2;
const Color = aya.math.Color;

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
        pos: Vec2,
        size: f32,
        color: Color,
    };

    const Line = struct {
        pt1: Vec2,
        pt2: Vec2,
        thickness: f32,
        color: Color,
    };

    const Rect = struct {
        pos: Vec2,
        w: f32,
        h: f32,
        thickness: f32 = 0,
        hollow: bool = false,
        color: Color,
    };

    const Circle = struct {
        center: Vec2,
        r: f32,
        thickness: f32,
        hollow: bool = true,
        color: Color,
    };

    const Text = struct {
        pos: Vec2,
        text: []const u8,
        color: Color,
    };

    pub fn init() Debug {
        return Debug{
            .debug_items = std.ArrayList(DebugDrawCommand).initCapacity(aya.allocator, 5) catch unreachable,
        };
    }

    pub fn deinit(self: Debug) void {
        self.debug_items.deinit();
    }

    /// renders
    pub fn render(self: *Debug, draw: *Draw, enabled: bool) bool {
        if (enabled and self.debug_items.items.len > 0) {
            for (self.debug_items.items) |item| {
                switch (item) {
                    .point => |pt| draw.point(pt.pos, pt.size, pt.color),
                    .line => |line| draw.line(line.pt1, line.pt2, line.thickness, line.color),
                    .rect => |rect| {
                        if (rect.hollow) {
                            draw.hollowRect(rect.pos, rect.w, rect.h, rect.thickness, rect.color);
                        } else {
                            draw.rect(rect.pos, rect.w, rect.h, rect.color);
                        }
                    },
                    .circle => |circle| draw.circle(circle.center, circle.r, circle.thickness, 12, circle.color),
                    .text => |text| draw.textOptions(text.text, null, .{ .x = text.pos.x, .y = text.pos.y, .color = text.color, .sx = 2, .sy = 2 }),
                }
            }
            self.debug_items.items.len = 0;
            return true;
        }
        self.debug_items.items.len = 0;
        return false;
    }

    pub fn drawPoint(self: *Debug, pos: Vec2, size: f32, color: ?Color) void {
        const point = Point{ .pos = pos, .size = size, .color = color orelse Color.white };
        self.debug_items.append(.{ .point = point }) catch return;
    }

    pub fn drawLine(self: *Debug, pt1: Vec2, pt2: Vec2, thickness: f32, color: ?Color) void {
        const line = Line{ .pt2 = pt1, .pt2 = pt2, .thickness = thickness, .color = color orelse Color.white };
        self.debug_items.append(.{ .line = line }) catch return;
    }

    pub fn drawRect(self: *Debug, pos: Vec2, width: f32, height: f32, color: ?Color) void {
        const rect = Rect{ .pos = pos, .w = width, .h = height, .hollow = false, .color = color orelse Color.white };
        self.debug_items.append(.{ .rect = rect }) catch return;
    }

    pub fn drawHollowRect(self: *Debug, pos: Vec2, width: f32, height: f32, thickness: f32, color: ?Color) void {
        const rect = Rect{ .pos = pos, .w = width, .h = height, .thickness = thickness, .hollow = true, .color = color orelse Color.white };
        self.debug_items.append(.{ .rect = rect }) catch return;
    }

    pub fn drawHollowCircle(self: *Debug, center: Vec2, radius: f32, thickness: f32, color: ?Color) void {
        const circle = Circle{ .center = center, .r = radius, .thickness = thickness, .color = color orelse Color.white };
        self.debug_items.append(.{ .circle = circle }) catch return;
    }

    pub fn drawText(self: *Debug, text: []const u8, pos: Vec2, color: ?Color) void {
        const text_item = Text{ .pos = pos, .text = text, .color = color orelse Color.white };
        self.debug_items.append(.{ .text = text_item }) catch return;
    }

    pub fn drawTextFmt(self: *Debug, comptime fmt: []const u8, args: anytype, pos: Vec2, color: ?Color) void {
        const text = std.fmt.allocPrint(aya.tmp_allocator, fmt, args) catch |err| {
            std.debug.print("drawTextFormat error: {}\n", .{err});
            return;
        };

        const text_item = Text{ .pos = pos, .text = text, .color = color orelse Color.white };
        self.debug_items.append(.{ .text = text_item }) catch return;
    }
};
