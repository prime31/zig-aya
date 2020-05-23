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
        aya.gfx.drawText(span, book);
        const c_key_lwr = std.ascii.toLower(span[0]);
        aya.gfx.drawText(&[_]u8{c_key_lwr}, book);
    }

    return 0;
}

fn update() void {
    aya.debug.drawText("what the fuck", .{}, null);
}

fn render() void {
    if (aya.input.mouseDown(.left)) {
        aya.gfx.drawText("pooop", null);
    }

    if (aya.input.mouseDown(.right)) {
        aya.gfx.drawText("fucker", book);
    }

    aya.gfx.drawTex(book.texture.?, 10, 60);
    aya.gfx.endPass();
}
