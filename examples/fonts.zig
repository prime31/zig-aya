const std = @import("std");
const sdl = @import("sdl");
const aya = @import("aya");
const math = aya.math;
const Color = math.Color;

var book: *aya.gfx.FontBook = undefined;
var font: i32 = 0;

pub fn main() anyerror!void {
    try aya.run(.{
        .init = init,
        .update = update,
        .render = render,
    });
}

fn init() !void {
    book = aya.gfx.FontBook.init(null, 128, 128, .nearest) catch unreachable;
    font = book.addFont("assets/ProggyTiny.ttf");
    book.setSize(10);
}

fn update() !void {
    aya.debug.drawText("what the fuck, im at 0,450. top-left", .{ .x = 0, .y = 450 }, null);
}

fn render() !void {
    aya.gfx.beginPass(.{});
    book.setAlign(.top_left);
    aya.draw.text("top-left", 0, 0, book);
    book.setAlign(.left);

    if (aya.input.mouseDown(.left)) {
        aya.draw.text("pooop, left button", 200, 50, null);
    }

    if (aya.input.mouseDown(.right)) {
        aya.draw.text("fucker, right button", 10, 150, book);
    }

    aya.draw.textOptions("fucker", null, .{ .x = 300, .y = 150, .sx = 3, .sy = 3, .rot = 0.785, .color = Color.yellow });

    aya.draw.hollowRect(.{ .x = 100, .y = 250 }, 128, 128, 1, Color.pink);
    aya.draw.tex(book.texture.?, 100, 250);
    aya.gfx.endPass();
}
