const std = @import("std");
const aya = @import("../aya.zig");

const Quad = aya.math.Quad;
const Vec2 = aya.math.Vec2;
const RectI = aya.math.RectI;
const Mat32 = aya.math.Mat32;
const Color = aya.math.Color;

const Batcher = aya.render.Batcher;
const FontBook = aya.render.FontBook;
const TextureHandle = aya.render.TextureHandle;

pub const Draw = struct {
    batcher: Batcher,
    fontbook: *FontBook,
    white_tex: TextureHandle,
    quad: Quad = Quad.init(0, 0, 1, 1, 1, 1),

    pub fn init() Draw {
        const fontbook = FontBook.init(128, 128, .nearest);
        _ = fontbook.addFontMem("ProggyTiny", @embedFile("assets/ProggyTiny.ttf"), false);
        fontbook.setSize(10);

        return .{
            .batcher = Batcher.init(5000),
            .white_tex = TextureHandle.initSingleColor(0xFFFFFFFF),
            .fontbook = fontbook,
        };
    }

    pub fn deinit(self: *Draw) void {
        self.batcher.deinit();
        self.fontbook.deinit();
    }

    // Drawing
    pub fn tex(self: *Draw, texture: TextureHandle, x: f32, y: f32) void {
        self.quad.setFill(texture.width, texture.height);

        var mat = Mat32.initTransform(.{ .x = x, .y = y });
        self.batcher.draw(texture, self.quad, mat, Color.white);
    }

    pub fn texScale(self: *Draw, texture: TextureHandle, x: f32, y: f32, scale: f32) void {
        self.quad.setFill(texture.width, texture.height);

        var mat = Mat32.initTransform(.{ .x = x, .y = y, .sx = scale, .sy = scale });
        self.batcher.draw(texture, self.quad, mat, Color.white);
    }

    pub fn texScaleOrigin(self: *Draw, texture: TextureHandle, x: f32, y: f32, scale: f32, ox: f32, oy: f32) void {
        self.quad.setFill(texture.width, texture.height);

        var mat = Mat32.initTransform(.{ .x = x, .y = y, .sx = scale, .sy = scale, .ox = ox, .oy = oy });
        self.batcher.draw(texture, self.quad, mat, Color.white);
    }

    pub fn texViewport(self: *Draw, texture: TextureHandle, viewport: RectI, transform: Mat32) void {
        self.quad.setImageDimensions(texture.width, texture.height);
        self.quad.setViewportRectI(viewport);
        self.batcher.draw(texture, self.quad, transform, Color.white);
    }

    pub fn text(self: *Draw, str: []const u8, x: f32, y: f32, fb: ?*FontBook) void {
        var book = fb orelse self.fontbook;
        // TODO: dont hardcode scale
        var matrix = Mat32.initTransform(.{ .x = x, .y = y, .sx = 2, .sy = 2 });

        var fons_quad = FontBook.Quad{};
        var iter = book.getTextIterator(str);
        while (book.textIterNext(&iter, &fons_quad)) {
            self.quad.positions[0] = .{ .x = fons_quad.x0, .y = fons_quad.y0 };
            self.quad.positions[1] = .{ .x = fons_quad.x1, .y = fons_quad.y0 };
            self.quad.positions[2] = .{ .x = fons_quad.x1, .y = fons_quad.y1 };
            self.quad.positions[3] = .{ .x = fons_quad.x0, .y = fons_quad.y1 };

            self.quad.uvs[0] = .{ .x = fons_quad.s0, .y = fons_quad.t0 };
            self.quad.uvs[1] = .{ .x = fons_quad.s1, .y = fons_quad.t0 };
            self.quad.uvs[2] = .{ .x = fons_quad.s1, .y = fons_quad.t1 };
            self.quad.uvs[3] = .{ .x = fons_quad.s0, .y = fons_quad.t1 };

            self.batcher.draw(book.texture.?, self.quad, matrix, Color{ .value = iter.color });
        }
    }

    pub fn textOptions(self: *Draw, str: []const u8, fb: ?*FontBook, options: struct { x: f32, y: f32, rot: f32 = 0, sx: f32 = 1, sy: f32 = 1, alignment: FontBook.Align = .default, color: Color = Color.white }) void {
        var book = fb orelse self.fontbook;
        var matrix = Mat32.initTransform(.{ .x = options.x, .y = options.y, .angle = options.rot, .sx = options.sx, .sy = options.sy });
        book.setAlign(options.alignment);

        var fons_quad = FontBook.Quad{};
        var iter = book.getTextIterator(str);
        while (book.textIterNext(&iter, &fons_quad)) {
            self.quad.positions[0] = .{ .x = fons_quad.x0, .y = fons_quad.y0 };
            self.quad.positions[1] = .{ .x = fons_quad.x1, .y = fons_quad.y0 };
            self.quad.positions[2] = .{ .x = fons_quad.x1, .y = fons_quad.y1 };
            self.quad.positions[3] = .{ .x = fons_quad.x0, .y = fons_quad.y1 };

            self.quad.uvs[0] = .{ .x = fons_quad.s0, .y = fons_quad.t0 };
            self.quad.uvs[1] = .{ .x = fons_quad.s1, .y = fons_quad.t0 };
            self.quad.uvs[2] = .{ .x = fons_quad.s1, .y = fons_quad.t1 };
            self.quad.uvs[3] = .{ .x = fons_quad.s0, .y = fons_quad.t1 };

            self.batcher.draw(book.texture.?, self.quad, matrix, options.color);
        }
    }

    pub fn point(self: *Draw, position: Vec2, size: f32, color: Color) void {
        self.quad.setFill(size, size);

        const offset = if (size == 1) 0 else size * 0.5;
        var mat = Mat32.initTransform(.{ .x = position.x, .y = position.y, .ox = offset, .oy = offset });
        self.batcher.draw(self.white_tex, self.quad, mat, color);
    }

    pub fn line(self: *Draw, start: Vec2, end: Vec2, thickness: f32, color: Color) void {
        self.quad.setFill(1, 1);

        const angle = start.angleBetween(end);
        const length = start.distance(end);

        var mat = Mat32.initTransform(.{ .x = start.x, .y = start.y, .angle = angle, .sx = length, .sy = thickness });
        self.batcher.draw(self.white_tex, self.quad, mat, color);
    }

    pub fn rect(self: *Draw, position: Vec2, width: f32, height: f32, color: Color) void {
        self.quad.setFill(width, height);
        var mat = Mat32.initTransform(.{ .x = position.x, .y = position.y });
        self.batcher.draw(self.white_tex, self.quad, mat, color);
    }

    pub fn hollowRect(self: *Draw, position: Vec2, width: f32, height: f32, thickness: f32, color: Color) void {
        const tr = Vec2{ .x = position.x + width, .y = position.y };
        const br = Vec2{ .x = position.x + width, .y = position.y + height };
        const bl = Vec2{ .x = position.x, .y = position.y + height };

        self.line(position, tr, thickness, color);
        self.line(tr, br, thickness, color);
        self.line(br, bl, thickness, color);
        self.line(bl, position, thickness, color);
    }

    pub fn circle(self: *Draw, center: Vec2, radius: f32, thickness: f32, resolution: i32, color: Color) void {
        self.quad.setFill(self.white_tex.width, self.white_tex.height);

        var last = Vec2.init(1, 0);
        last.scaleInPlace(radius);
        var last_p = last.orthogonal();

        var i: usize = 0;
        while (i <= resolution) : (i += 1) {
            const at = Vec2.angleToVec(@as(f32, @floatFromInt(i)) * aya.math.pi_over_2 / @as(f32, @floatFromInt(resolution)), radius);
            const at_p = at.orthogonal();

            self.line(center.add(last), center.add(at), thickness, color);
            self.line(center.subtract(last), center.subtract(at), thickness, color);
            self.line(center.add(last_p), center.add(at_p), thickness, color);
            self.line(center.subtract(last_p), center.subtract(at_p), thickness, color);

            last = at;
            last_p = at_p;
        }
    }

    pub fn hollowPolygon(self: *Draw, verts: []const Vec2, thickness: f32, color: Color) void {
        var i: usize = 0;
        while (i < verts.len - 1) : (i += 1) {
            self.line(verts[i], verts[i + 1], thickness, color);
        }
        self.line(verts[verts.len - 1], verts[0], thickness, color);
    }
};
