const std = @import("std");
const aya = @import("aya");
const shaders = @import("shaders");
const Pipeline = aya.gfx.Pipeline;

var rt: aya.gfx.Texture = undefined;
var map: aya.gfx.Texture = undefined;
var block: aya.gfx.Texture = undefined;
var mode7_pip: Pipeline = undefined;
var mode7_uniform = aya.gfx.effects.Mode7.Params{};
var camera: Camera = undefined;
var blocks: std.ArrayList(aya.math.Vec2) = undefined;

const Block = struct {
    tex: aya.gfx.Texture,
    pos: aya.math.Vec2,
    scale: f32,
    dist: f32,
};

const Camera = struct {
    sw: f32,
    sh: f32,
    x: f32 = 0,
    y: f32 = 0,
    r: f32 = 0,
    z: f32 = 32,
    f: f32 = 1,
    o: f32 = 1,
    x1: f32 = 0,
    y1: f32 = 0,
    x2: f32 = 0,
    y2: f32 = 0,
    sprites: std.ArrayList(Block) = undefined,

    pub fn init(sw: f32, sh: f32) Camera {
        var cam = Camera{ .sw = sw, .sh = sh, .sprites = std.ArrayList(Block).init(aya.mem.allocator) };
        cam.setRotation(0);
        return cam;
    }

    pub fn deinit(self: Camera) void {
        self.sprites.deinit();
    }

    pub fn setRotation(self: *Camera, rot: f32) void {
        self.r = rot;
        self.x1 = std.math.sin(rot);
        self.y1 = std.math.cos(rot);
        self.x2 = -std.math.cos(rot);
        self.y2 = std.math.sin(rot);
    }

    pub fn toWorld(self: Camera, pos: aya.math.Vec2) aya.math.Vec2 {
        const sx = (self.sw / 2 - pos.x) * self.z / (self.sw / self.sh);
        const sy = (self.o * self.sh - pos.y) * (self.z / self.f);

        const rot_x = sx * self.x1 + sy * self.y1;
        const rot_y = sx * self.x2 + sy * self.y2;

        return .{ .x = rot_x / pos.y + self.x, .y = rot_y / pos.y + self.y };
    }

    pub fn toScreen(self: Camera, pos: aya.math.Vec2) struct { x: f32, y: f32, size: f32 } {
        const obj_x = -(self.x - pos.x) / self.z;
        const obj_y = (self.y - pos.y) / self.z;

        const space_x = (-obj_x * self.x1 - obj_y * self.y1);
        const space_y = (obj_x * self.x2 + obj_y * self.y2) * self.f;

        const distance = 1 - space_y;
        const screen_x = (space_x / distance) * self.o * self.sw + self.sw / 2;
        const screen_y = ((space_y + self.o - 1) / distance) * self.sh + self.sh;

        // Should be approximately one pixel on the plane
        const size = ((1 / distance) / self.z * self.o) * self.sw;

        return .{ .x = screen_x, .y = screen_y, .size = size };
    }

    pub fn placeSprite(self: *Camera, tex: aya.gfx.Texture, pos: aya.math.Vec2, scale: f32) void {
        const dim = self.toScreen(pos);

        const width = @intToFloat(f32, tex.width);
        const height = @intToFloat(f32, tex.height);

        const sx2 = (dim.size * scale) / width;

        if (sx2 < 0) return;

        _ = self.sprites.append(.{
            .tex = tex,
            .pos = .{ .x = dim.x, .y = dim.y },
            .scale = sx2,
            .dist = dim.size,
        }) catch unreachable;
    }

    pub fn renderSprites(self: *Camera) void {
        if (self.sprites.items.len > 0) {
            std.sort.sort(Block, self.sprites.items, {}, sort);
        }

        for (self.sprites.items) |sprite| {
            const width = @intToFloat(f32, sprite.tex.width);
            const height = @intToFloat(f32, sprite.tex.height);
            aya.draw.texScaleOrigin(sprite.tex, sprite.pos.x, sprite.pos.y, sprite.scale, width / 2, height);
        }
        self.sprites.items.len = 0;
    }

    fn sort(ctx: void, a: Block, b: Block) bool {
        return a.dist < b.dist;
    }
};

pub fn main() !void {
    try aya.run(.{
        .init = init,
        .update = update,
        .render = render,
        .shutdown = shutdown,
        .window = .{
            .width = 800,
            .height = 600,
        },
        .gfx = .{
            .batcher_max_sprites = 10000,
        },
    });
}

fn init() void {
    camera = Camera.init(@intToFloat(f32, aya.window.width()), @intToFloat(f32, aya.window.height()));

    rt = aya.gfx.Texture.init(800, 600, .nearest);
    map = aya.gfx.Texture.initFromFile("assets/mario_kart.png", .nearest) catch unreachable;
    block = aya.gfx.Texture.initFromFile("assets/block.png", .nearest) catch unreachable;
    mode7_pip = aya.gfx.effects.Mode7.init();

    blocks = std.ArrayList(aya.math.Vec2).init(aya.mem.allocator);
    _ = blocks.append(.{ .x = 0, .y = 0 }) catch unreachable;

    // uncomment for sorting stress test
    // var x: usize = 4;
    // while (x < 512) : (x += 12) {
    //     var y: usize = 4;
    //     while (y < 512) : (y += 12) {
    //         _ = blocks.append(.{ .x = @intToFloat(f32, x), .y = @intToFloat(f32, y) }) catch unreachable;
    //     }
    // }
}

fn shutdown() void {
    map.deinit();
    block.deinit();
    mode7_pip.deinit();
    blocks.deinit();
    camera.deinit();
}

fn update() void {
    const move_speed = 140.0;
    if (aya.input.keyDown(.SAPP_KEYCODE_W)) {
        camera.x += std.math.cos(camera.r) * move_speed * aya.time.dt();
        camera.y += std.math.sin(camera.r) * move_speed * aya.time.dt();
    } else if (aya.input.keyDown(.SAPP_KEYCODE_S)) {
        camera.x = camera.x - std.math.cos(camera.r) * move_speed * aya.time.dt();
        camera.y = camera.y - std.math.sin(camera.r) * move_speed * aya.time.dt();
    }

    if (aya.input.keyDown(.SAPP_KEYCODE_A)) {
        camera.x += std.math.cos(camera.r - std.math.pi / 2.0) * move_speed * aya.time.dt();
        camera.y += std.math.sin(camera.r - std.math.pi / 2.0) * move_speed * aya.time.dt();
    } else if (aya.input.keyDown(.SAPP_KEYCODE_D)) {
        camera.x += std.math.cos(camera.r + std.math.pi / 2.0) * move_speed * aya.time.dt();
        camera.y += std.math.sin(camera.r + std.math.pi / 2.0) * move_speed * aya.time.dt();
    }

    if (aya.input.keyDown(.SAPP_KEYCODE_I)) {
        camera.f += aya.time.dt();
    } else if (aya.input.keyDown(.SAPP_KEYCODE_O)) {
        camera.f -= aya.time.dt();
    }

    if (aya.input.keyDown(.SAPP_KEYCODE_K)) {
        camera.o += aya.time.dt();
    } else if (aya.input.keyDown(.SAPP_KEYCODE_L)) {
        camera.o -= aya.time.dt();
    }

    if (aya.input.keyDown(.SAPP_KEYCODE_MINUS)) {
        camera.z += aya.time.dt() * 10;
    } else if (aya.input.keyDown(.SAPP_KEYCODE_EQUAL)) {
        camera.z -= aya.time.dt() * 10;
    }

    if (aya.input.keyDown(.SAPP_KEYCODE_Q)) {
        camera.setRotation(@mod(camera.r, std.math.tau) - aya.time.dt());
    } else if (aya.input.keyDown(.SAPP_KEYCODE_E)) {
        camera.setRotation(@mod(camera.r, std.math.tau) + aya.time.dt());
    }

    if (aya.input.mousePressed(.left)) {
        var pos = camera.toWorld(aya.input.mousePosVec());
        _ = blocks.append(pos) catch unreachable;
    }
}

fn render() void {
    aya.gfx.beginPass(.{});
    drawPlane();

    var pos = camera.toScreen(camera.toWorld(aya.input.mousePosVec()));
    aya.draw.circle(.{ .x = pos.x, .y = pos.y }, pos.size, 2, 8, aya.math.Color.white);
    const width = @intToFloat(f32, block.width);
    const height = @intToFloat(f32, block.height);
    aya.draw.texScaleOrigin(block, pos.x, pos.y, pos.size, width / 2, height);
    //draw(spriteimg,x,y,0,s/spriteimg:getWidth(),s/spriteimg:getHeight(),spriteimg:getWidth()/2,spriteimg:getHeight())
    // aya.draw.texScale(block, pos.x - (@intToFloat(f32, block.width) * pos.size / 2), pos.y - @intToFloat(f32, block.height) * pos.size, pos.size);

    for (blocks.items) |b| {
        camera.placeSprite(block, b, 8);
    }
    camera.renderSprites();

    aya.gfx.endPass();
}

fn drawPlane() void {
    mode7_uniform.mapw = @intToFloat(f32, map.width);
    mode7_uniform.maph = @intToFloat(f32, map.height);

    mode7_uniform.x = camera.x;
    mode7_uniform.y = camera.y;
    mode7_uniform.zoom = camera.z;
    mode7_uniform.fov = camera.f;
    mode7_uniform.offset = camera.o;
    mode7_uniform.wrap = 0;

    mode7_uniform.x1 = camera.x1;
    mode7_uniform.y1 = camera.y1;
    mode7_uniform.x2 = camera.x2;
    mode7_uniform.y2 = camera.y2;
    mode7_pip.setFragUniform(0, &mode7_uniform);
    aya.draw.bindTexture(map, 1);

    aya.gfx.setPipeline(mode7_pip);
    aya.draw.tex(rt, 0, 0);
    aya.gfx.setPipeline(null);
    aya.draw.unbindTexture(1);
}
