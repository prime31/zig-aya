const aya = @import("../aya.zig");

const Quad = aya.Quad;
const Vec2 = aya.Vec2;
const RectI = aya.RectI;
const Mat32 = aya.Mat32;
const Color = aya.Color;

const Batcher = aya.Batcher;
const FontBook = aya.FontBook;
const Texture = aya.Texture;

pub const draw = struct {
    pub var batcher: Batcher = undefined;
    pub var fontbook: *FontBook = undefined;

    var quad: Quad = Quad.init(0, 0, 1, 1, 1, 1);
    var white_tex: Texture = undefined;

    pub fn init(config: anytype) !void {
        white_tex = Texture.initSingleColor(0xFFFFFFFF);

        batcher = Batcher.init(null, config.batcher_max_sprites);

        fontbook = FontBook.init(128, 128, .nearest);
        _ = fontbook.addFontMem("ProggyTiny", @embedFile("assets/ProggyTiny.ttf"), false);
        fontbook.setSize(10);
    }

    pub fn deinit() void {
        batcher.deinit();
        white_tex.deinit();
        fontbook.deinit();
    }

    /// binds a Texture to the BufferBindings in the Batchers DynamicMesh
    pub fn bindTexture(texture: Texture, slot: c_uint) void {
        batcher.mesh.bindImage(texture.img, slot);
    }

    /// unbinds a previously bound texture. All texture slots > 0 must be unbound manually!
    pub fn unbindTexture(slot: c_uint) void {
        batcher.mesh.bindImage(0, slot);
    }

    // Drawing
    pub fn tex(texture: Texture, x: f32, y: f32) void {
        quad.setFill(texture.width, texture.height);

        var mat = Mat32.initTransform(.{ .x = x, .y = y });
        batcher.draw(texture, quad, mat, Color.white);
    }

    pub fn texScale(texture: Texture, x: f32, y: f32, scale: f32) void {
        quad.setFill(texture.width, texture.height);

        var mat = Mat32.initTransform(.{ .x = x, .y = y, .sx = scale, .sy = scale });
        batcher.draw(texture, quad, mat, Color.white);
    }

    pub fn texScaleOrigin(texture: Texture, x: f32, y: f32, scale: f32, ox: f32, oy: f32) void {
        quad.setFill(texture.width, texture.height);

        var mat = Mat32.initTransform(.{ .x = x, .y = y, .sx = scale, .sy = scale, .ox = ox, .oy = oy });
        batcher.draw(texture, quad, mat, Color.white);
    }

    pub fn texViewport(texture: Texture, viewport: RectI, transform: Mat32) void {
        quad.setImageDimensions(texture.width, texture.height);
        quad.setViewportRectI(viewport);
        batcher.draw(texture, quad, transform, Color.white);
    }

    pub fn text(str: []const u8, x: f32, y: f32, fb: ?*FontBook) void {
        var book = fb orelse fontbook;
        // TODO: dont hardcode scale as 4
        var matrix = Mat32.initTransform(.{ .x = x, .y = y, .sx = 2, .sy = 2 });

        var fons_quad = book.getQuad();
        var iter = book.getTextIterator(str);
        while (book.textIterNext(&iter, &fons_quad)) {
            quad.positions[0] = .{ .x = fons_quad.x0, .y = fons_quad.y0 };
            quad.positions[1] = .{ .x = fons_quad.x1, .y = fons_quad.y0 };
            quad.positions[2] = .{ .x = fons_quad.x1, .y = fons_quad.y1 };
            quad.positions[3] = .{ .x = fons_quad.x0, .y = fons_quad.y1 };

            quad.uvs[0] = .{ .x = fons_quad.s0, .y = fons_quad.t0 };
            quad.uvs[1] = .{ .x = fons_quad.s1, .y = fons_quad.t0 };
            quad.uvs[2] = .{ .x = fons_quad.s1, .y = fons_quad.t1 };
            quad.uvs[3] = .{ .x = fons_quad.s0, .y = fons_quad.t1 };

            batcher.draw(book.texture.?, quad, matrix, Color{ .value = iter.color });
        }
    }

    pub fn textOptions(str: []const u8, fb: ?*FontBook, options: struct { x: f32, y: f32, rot: f32 = 0, sx: f32 = 1, sy: f32 = 1, alignment: FontBook.Align = .default, color: Color = Color.white }) void {
        var book = fb orelse fontbook;
        var matrix = Mat32.initTransform(.{ .x = options.x, .y = options.y, .angle = options.rot, .sx = options.sx, .sy = options.sy });
        book.setAlign(options.alignment);

        var fons_quad = book.getQuad();
        var iter = book.getTextIterator(str);
        while (book.textIterNext(&iter, &fons_quad)) {
            quad.positions[0] = .{ .x = fons_quad.x0, .y = fons_quad.y0 };
            quad.positions[1] = .{ .x = fons_quad.x1, .y = fons_quad.y0 };
            quad.positions[2] = .{ .x = fons_quad.x1, .y = fons_quad.y1 };
            quad.positions[3] = .{ .x = fons_quad.x0, .y = fons_quad.y1 };

            quad.uvs[0] = .{ .x = fons_quad.s0, .y = fons_quad.t0 };
            quad.uvs[1] = .{ .x = fons_quad.s1, .y = fons_quad.t0 };
            quad.uvs[2] = .{ .x = fons_quad.s1, .y = fons_quad.t1 };
            quad.uvs[3] = .{ .x = fons_quad.s0, .y = fons_quad.t1 };

            batcher.draw(book.texture.?, quad, matrix, options.color);
        }
    }

    pub fn point(position: Vec2, size: f32, color: Color) void {
        quad.setFill(size, size);

        const offset = if (size == 1) 0 else size * 0.5;
        var mat = Mat32.initTransform(.{ .x = position.x, .y = position.y, .ox = offset, .oy = offset });
        batcher.draw(white_tex, quad, mat, color);
    }

    pub fn line(start: Vec2, end: Vec2, thickness: f32, color: Color) void {
        quad.setFill(1, 1);

        const angle = start.angleBetween(end);
        const length = start.distance(end);

        var mat = Mat32.initTransform(.{ .x = start.x, .y = start.y, .angle = angle, .sx = length, .sy = thickness });
        batcher.draw(white_tex, quad, mat, color);
    }

    pub fn rect(position: Vec2, width: f32, height: f32, color: Color) void {
        quad.setFill(width, height);
        var mat = Mat32.initTransform(.{ .x = position.x, .y = position.y });
        batcher.draw(white_tex, quad, mat, color);
    }

    pub fn hollowRect(position: Vec2, width: f32, height: f32, thickness: f32, color: Color) void {
        const tr = Vec2{ .x = position.x + width, .y = position.y };
        const br = Vec2{ .x = position.x + width, .y = position.y + height };
        const bl = Vec2{ .x = position.x, .y = position.y + height };

        line(position, tr, thickness, color);
        line(tr, br, thickness, color);
        line(br, bl, thickness, color);
        line(bl, position, thickness, color);
    }

    pub fn circle(center: Vec2, radius: f32, thickness: f32, resolution: i32, color: Color) void {
        quad.setFill(white_tex.width, white_tex.height);

        var last = Vec2.init(1, 0);
        last.scale(radius);
        var last_p = last.orthogonal();

        var i: usize = 0;
        while (i <= resolution) : (i += 1) {
            const at = Vec2.angleToVec(@as(f32, @floatFromInt(i)) * aya.pi_over_2 / @as(f32, @floatFromInt(resolution)), radius);
            const at_p = at.orthogonal();

            line(center.add(last), center.add(at), thickness, color);
            line(center.subtract(last), center.subtract(at), thickness, color);
            line(center.add(last_p), center.add(at_p), thickness, color);
            line(center.subtract(last_p), center.subtract(at_p), thickness, color);

            last = at;
            last_p = at_p;
        }
    }

    pub fn hollowPolygon(verts: []const Vec2, thickness: f32, color: Color) void {
        var i: usize = 0;
        while (i < verts.len - 1) : (i += 1) {
            line(verts[i], verts[i + 1], thickness, color);
        }
        line(verts[verts.len - 1], verts[0], thickness, color);
    }
};
