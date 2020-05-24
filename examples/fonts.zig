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

fn init() void {
    book = aya.gfx.FontBook.init(null, 128, 128, .point) catch unreachable;
    font = book.addFont("assets/ProggyTiny.ttf");
    book.setSize(10);

    var shader = aya.gfx.Shader.initFromFile("assets/SpriteEffect.fxb") catch unreachable;
    var mat = aya.math.Mat32.initOrtho(640, 480);
    shader.setParam(aya.math.Mat32, "TransformMatrix", mat);
    shader.apply();

    sdl.SDL_AddEventWatch(onKeyPressed, null);
}

fn onKeyPressed(ctx: ?*c_void, evt: [*c]sdl.SDL_Event) callconv(.C) c_int {
    if (evt[0].type == sdl.SDL_KEYUP) {
        const c_key = sdl.SDL_GetKeyName(evt[0].key.keysym.sym);

        const span = std.mem.spanZ(c_key);
        aya.gfx.drawText(span, 40, 50, book);
        const c_key_lwr = std.ascii.toLower(span[0]);
        aya.gfx.drawText(&[_]u8{c_key_lwr}, 20, 50, book);
    }

    return 0;
}

fn update() void {
    aya.debug.drawText("what the fuck", .{}, null);
}

fn render() void {
    if (aya.input.mouseDown(.left)) {
        aya.gfx.drawText("pooop", 200, 50, null);
    }

    if (aya.input.mouseDown(.right)) {
        aya.gfx.drawText("fucker", 200, 50, book);
    }

    aya.gfx.drawTextOptions("fucker", null, .{ .x = 300, .y = 150, .sx = 3, .sy = 3, .rot = 0.785, .color = Color.yellow });

    aya.gfx.drawTex(book.texture.?, 10, 60);
    aya.gfx.endPass();
}
