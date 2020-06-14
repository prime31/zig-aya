const gfx = @import("gfx.zig");
const math = @import("../math/math.zig");

pub const draw = struct {
    // Drawing
    pub fn tex(texture: gfx.Texture, x: f32, y: f32) void {
        gfx.state.quad.setFill(texture.width, texture.height);

        var mat = math.Mat32.initTransform(.{ .x = x, .y = y });
        gfx.state.batcher.draw(texture.tex, gfx.state.quad, mat, math.Color.white);
    }

    pub fn texScale(texture: Texture, x: f32, y: f32, scale: f32) void {
        state.quad.setFill(texture.width, texture.height);

        var mat = math.Mat32.initTransform(.{ .x = x, .y = y, .angle = 0, .sx = scale, .sy = scale });
        state.batcher.draw(texture.tex, state.quad, mat, math.Color.white);
    }

    pub fn text(str: []const u8, x: f32, y: f32, fontbook: ?*gfx.FontBook) void {
        var book = if (fontbook != null) fontbook.? else gfx.state.fontbook;
        var matrix = math.Mat32.initTransform(.{ .x = x, .y = y, .sx = 4, .sy = 4 });
        book.setAlign(.default);

        var fons_quad = book.getQuad();
        var iter = book.getTextIterator(str);
        while (book.textIterNext(&iter, &fons_quad)) {
            gfx.state.quad.positions[0] = .{ .x = fons_quad.x0, .y = fons_quad.y0 };
            gfx.state.quad.positions[1] = .{ .x = fons_quad.x1, .y = fons_quad.y0 };
            gfx.state.quad.positions[2] = .{ .x = fons_quad.x1, .y = fons_quad.y1 };
            gfx.state.quad.positions[3] = .{ .x = fons_quad.x0, .y = fons_quad.y1 };

            gfx.state.quad.uvs[0] = .{ .x = fons_quad.s0, .y = fons_quad.t0 };
            gfx.state.quad.uvs[1] = .{ .x = fons_quad.s1, .y = fons_quad.t0 };
            gfx.state.quad.uvs[2] = .{ .x = fons_quad.s1, .y = fons_quad.t1 };
            gfx.state.quad.uvs[3] = .{ .x = fons_quad.s0, .y = fons_quad.t1 };

            gfx.state.batcher.draw(book.texture.?.tex, gfx.state.quad, matrix, math.Color.white);
        }
    }

    pub fn textOptions(str: []const u8, fontbook: ?*gfx.FontBook, options: struct { x: f32, y: f32, rot: f32 = 0, sx: f32 = 1, sy: f32 = 1, alignment: gfx.FontBook.Align = .default, color: math.Color = math.Color.White }) void {
        var book = if (fontbook != null) fontbook.? else gfx.state.fontbook;
        var matrix = math.Mat32.initTransform(.{ .x = options.x, .y = options.y, .angle = options.rot, .sx = options.sx, .sy = options.sy });
        book.setAlign(options.alignment);

        var fons_quad = book.getQuad();
        var iter = book.getTextIterator(str);
        while (book.textIterNext(&iter, &fons_quad)) {
            gfx.state.quad.positions[0] = .{ .x = fons_quad.x0, .y = fons_quad.y0 };
            gfx.state.quad.positions[1] = .{ .x = fons_quad.x1, .y = fons_quad.y0 };
            gfx.state.quad.positions[2] = .{ .x = fons_quad.x1, .y = fons_quad.y1 };
            gfx.state.quad.positions[3] = .{ .x = fons_quad.x0, .y = fons_quad.y1 };

            gfx.state.quad.uvs[0] = .{ .x = fons_quad.s0, .y = fons_quad.t0 };
            gfx.state.quad.uvs[1] = .{ .x = fons_quad.s1, .y = fons_quad.t0 };
            gfx.state.quad.uvs[2] = .{ .x = fons_quad.s1, .y = fons_quad.t1 };
            gfx.state.quad.uvs[3] = .{ .x = fons_quad.s0, .y = fons_quad.t1 };

            gfx.state.batcher.draw(book.texture.?.tex, gfx.state.quad, matrix, options.color);
        }
    }

    pub fn point(position: math.Vec2, size: f32, color: math.Color) void {
        gfx.state.quad.setFill(@floatToInt(i32, size), @floatToInt(i32, size));

        const offset = if (size == 1) 0 else size * 0.5;
        var mat = math.Mat32.initTransform(.{ .x = position.x, .y = position.y, .ox = offset, .oy = offset });
        gfx.state.batcher.draw(gfx.state.white_tex.tex, gfx.state.quad, mat, color);
    }

    pub fn line(start: math.Vec2, end: math.Vec2, thickness: f32, color: math.Color) void {
        gfx.state.quad.setFill(1, 1);

        const angle = start.angleBetween(end);
        const length = start.distance(end);

        var mat = math.Mat32.initTransform(.{ .x = start.x, .y = start.y, .angle = angle, .sx = length, .sy = thickness });
        gfx.state.batcher.draw(gfx.state.white_tex.tex, gfx.state.quad, mat, color);
    }

    pub fn rect(position: math.Vec2, width: f32, height: f32, color: math.Color) void {
        gfx.state.quad.setFill(@floatToInt(i32, width), @floatToInt(i32, height));
        var mat = math.Mat32.initTransform(.{ .x = position.x, .y = position.y });
        gfx.state.batcher.draw(gfx.state.white_tex.tex, gfx.state.quad, mat, color);
    }

    pub fn hollowRect(position: math.Vec2, width: f32, height: f32, thickness: f32, color: math.Color) void {
        const tr = math.Vec2{ .x = position.x + width, .y = position.y };
        const br = math.Vec2{ .x = position.x + width, .y = position.y + height };
        const bl = math.Vec2{ .x = position.x, .y = position.y + height };

        line(position, tr, thickness, color);
        line(tr, br, thickness, color);
        line(br, bl, thickness, color);
        line(bl, position, thickness, color);
    }

    pub fn circle(center: math.Vec2, radius: f32, thickness: f32, resolution: i32, color: math.Color) void {
        gfx.state.quad.setFill(gfx.state.white_tex.width, gfx.state.white_tex.height);

        var last = math.Vec2.init(1, 0);
        last.scale(radius);
        var last_p = last.orthogonal();

        var i: usize = 0;
        while (i <= resolution) : (i += 1) {
            const at = math.Vec2.angleToVec(@intToFloat(f32, i) * math.pi_over_2 / @intToFloat(f32, resolution), radius);
            const at_p = at.orthogonal();

            line(center.add(last), center.add(at), thickness, color);
            line(center.subtract(last), center.subtract(at), thickness, color);
            line(center.add(last_p), center.add(at_p), thickness, color);
            line(center.subtract(last_p), center.subtract(at_p), thickness, color);

            last = at;
            last_p = at_p;
        }
    }

    pub fn hollowPolygon(verts: []const math.Vec2, thickness: f32, color: math.Color) void {
        var i: usize = 0;
        while (i < verts.len - 1) : (i += 1) {
            line(verts[i], verts[i + 1], thickness, color);
        }
        line(verts[verts.len - 1], verts[0], thickness, color);
    }
};