const std = @import("std");
const aya = @import("aya");
const math = aya.math;
const data = @import("data.zig");

const ComponentInstance = data.ComponentInstance;

pub const Entity = struct {
    id: u8 = 0,
    name: [25:0]u8 = undefined,
    components: std.ArrayList(ComponentInstance),
    transform: Transform,
    sprite: ?Sprite = null,
    collider: ?Collider = null,

    pub fn init(id: u8, name: []const u8, position: math.Vec2) Entity {
        var entity = Entity{
            .id = id,
            .components = std.ArrayList(ComponentInstance).init(aya.mem.allocator),
            .transform = .{ .pos = position },
        };
        aya.mem.copyZ(u8, &entity.name, name);
        return entity;
    }

    pub fn deinit(self: @This()) void {
        for (self.components.items) |*comp| comp.deinit();
        self.components.deinit();
    }

    pub fn clone(self: @This(), id: u8, state: *data.AppState) Entity {
        // get the last index of name to use. If this is already a clone, dont append a second "(c)" else limit length so that the "(c)" fits.
        const name_sentinel_index = blk: {
            var c_index = std.mem.indexOf(u8, &self.name, " (c)");
            if (c_index != null) break :blk c_index.?;

            var tmp = std.mem.indexOfScalar(u8, &self.name, 0).?;
            if (tmp > 20) break :blk 20;
            break :blk tmp;
        };

        var buf: [25]u8 = undefined;
        var name = std.fmt.bufPrint(&buf, "{s} (c)", .{self.name[0..name_sentinel_index]}) catch unreachable;

        var entity = init(id, name, self.transform.pos.add(.{ .x = 16, .y = 16 }));
        entity.transform.rot = self.transform.rot;
        entity.transform.scale = self.transform.scale;
        entity.sprite = self.sprite;
        entity.collider = self.collider;

        for (self.components.items) |comp| entity.components.append(comp.clone(state)) catch unreachable;
        return entity;
    }

    pub fn addComponent(self: *@This(), component: ComponentInstance) void {
        self.components.append(component) catch unreachable;
    }

    pub fn transformMatrix(self: @This()) math.Mat32 {
        // we definitely have a sprite if this is called so its safe to access it
        const t = self.transform;
        return aya.math.Mat32.initTransform(.{ .x = t.pos.x, .y = t.pos.y, .angle = aya.math.toRadians(t.rot), .sx = t.scale.x, .sy = t.scale.y, .ox = self.sprite.?.origin.x, .oy = self.sprite.?.origin.y });
    }

    pub fn intersects(self: @This(), rect: math.Rect) bool {
        if (self.collider) |collider| if (collider.bounds(self.transform.pos).intersects(rect)) return true;
        if (self.sprite) |sprite| return sprite.bounds(self.transform).intersects(rect);
        return self.bounds().intersects(rect);
    }

    pub fn bounds(self: @This()) math.Rect {
        if (self.sprite == null and self.collider == null) {
            // create a matrix at our origin then translate the top-left and bottom-right corners. We ignore rotatation here.
            const mat = aya.math.Mat32.initTransform(.{ .x = self.transform.pos.x, .y = self.transform.pos.y, .sx = self.transform.scale.x, .sy = self.transform.scale.y });
            const tl = mat.transformVec2(.{ .x = -6, .y = -6 });
            const br = mat.transformVec2(.{ .x = 6, .y = 6 });

            return .{ .x = tl.x, .y = tl.y, .w = br.x - tl.x, .h = br.y - tl.y };
        }

        if (self.sprite != null and self.collider != null) {
            const spr_bounds = self.sprite.?.bounds(self.transform);
            const col_bounds = self.collider.?.bounds(self.transform.pos);
            return spr_bounds.unionRect(col_bounds);
        }
        if (self.sprite != null) return self.sprite.?.bounds(self.transform);
        return self.collider.?.bounds(self.transform.pos);
    }

    pub fn autoFitCollider(self: *@This()) void {
        if (self.sprite == null) return;

        // we definitely have a collider if this is called so its safe to access it
        const spr_bounds = self.sprite.?.bounds(self.transform);
        switch (self.collider.?) {
            .box => |*box| {
                box.w = spr_bounds.w;
                box.h = spr_bounds.h;
                const bound_pos = math.Vec2.init(spr_bounds.x, spr_bounds.y);
                box.offset = bound_pos.subtract(self.transform.pos);
            },
            .circle => |*circle| {
                circle.r = std.math.max(spr_bounds.w, spr_bounds.h) * 0.5;
                circle.offset = spr_bounds.center().subtract(self.transform.pos);
            },
        }
    }
};

pub const Transform = struct {
    pos: aya.math.Vec2 = .{},
    rot: f32 = 0,
    scale: aya.math.Vec2 = .{ .x = 1, .y = 1 },
};

pub const Sprite = struct {
    tex: aya.gfx.Texture,
    rect: math.RectI,
    tex_name: [:0]u8 = undefined,
    origin: aya.math.Vec2 = .{},

    pub fn init(tex: aya.gfx.Texture, rect: math.RectI, name: [:0]const u8) Sprite {
        return .{
            .tex = tex,
            .rect = rect,
            .tex_name = aya.mem.allocator.dupeZ(u8, name) catch unreachable,
            .origin = .{ .x = @intToFloat(f32, rect.w) * 0.5, .y = @intToFloat(f32, rect.h) * 0.5 },
        };
    }

    pub fn initNoTexture() Sprite {
        const tex = aya.gfx.Texture.initCheckerTexture();
        return Sprite.init(tex, .{ .w = @floatToInt(i32, tex.width), .h = @floatToInt(i32, tex.height) }, "default");
    }

    pub fn bounds(self: Sprite, transform: Transform) math.Rect {
        // TODO: take rotation into account when calculating the bounds of the sprite texture
        const tl = transform.pos.subtract(self.origin.mul(transform.scale));
        return .{ .x = tl.x, .y = tl.y, .w = @intToFloat(f32, self.rect.w) * transform.scale.x, .h = @intToFloat(f32, self.rect.h) * transform.scale.y };
    }
};

pub const Collider = union(enum) {
    box: BoxCollider,
    circle: CircleCollider,

    pub fn bounds(self: Collider, pos: math.Vec2) math.Rect {
        return switch (self) {
            .box => |box| box.bounds(pos),
            .circle => |circle| circle.bounds(pos),
        };
    }
};

pub const BoxCollider = struct {
    offset: aya.math.Vec2 = .{},
    w: f32,
    h: f32,

    pub fn init(w: f32, h: f32) BoxCollider {
        return .{ .w = w, .h = h };
    }

    pub fn bounds(self: @This(), pos: math.Vec2) math.Rect {
        const tl = pos.add(self.offset);
        return .{ .x = tl.x, .y = tl.y, .w = self.w, .h = self.h };
    }
};

pub const CircleCollider = struct {
    offset: aya.math.Vec2 = .{},
    r: f32,

    pub fn init(r: f32) CircleCollider {
        return .{ .r = r };
    }

    pub fn bounds(self: @This(), pos: math.Vec2) math.Rect {
        // tl will be the center position - the radius and then the w/h is double the radius
        const tl = pos.add(self.offset).subtract(.{ .x = self.r, .y = self.r });
        return .{ .x = tl.x, .y = tl.y, .w = self.r * 2, .h = self.r * 2 };
    }
};
