const std = @import("std");
const sdl = @import("sdl");

var rand_impl = std.rand.DefaultPrng.init(42);
const rnd = rand_impl.random();

pub fn main() !void {
    const window = sdl.SDL_CreateWindow("fook you sdl3", 1024, 768, sdl.SDL_WINDOW_RESIZABLE | sdl.SDL_WINDOW_METAL) orelse {
        sdl.SDL_Log("Unable to create window: %s", sdl.SDL_GetError());
        @panic("no window created");
    };
    const renderer = sdl.SDL_CreateRenderer(window, null, sdl.SDL_RENDERER_PRESENTVSYNC) orelse {
        sdl.SDL_Log("Unable to create renderer: %s", sdl.SDL_GetError());
        @panic("no renderer created");
    };

    const tex = Texture.init(renderer, "examples/assets/icon.bmp");
    defer tex.deinit();

    var sprites: [200]Sprite = undefined;
    for (0..200) |i| sprites[i] = Sprite.init(tex.w, tex.h);

    while (true) {
        var event: sdl.SDL_Event = undefined;
        while (sdl.SDL_PollEvent(&event) != 0) {
            switch (event.type) {
                sdl.SDL_EVENT_QUIT => return,
                sdl.SDL_EVENT_WINDOW_CLOSE_REQUESTED => {
                    std.debug.print("window evt: {}\n", .{event.window.type});
                },
                else => {},
            }
        }

        _ = sdl.SDL_SetRenderDrawColor(renderer, 0xA0, 0xA0, 0xA0, 0xFF);
        _ = sdl.SDL_RenderClear(renderer);

        for (&sprites) |*sprite| {
            sprite.pos.x += sprite.vel.x;
            sprite.pos.y += sprite.vel.y;

            if (sprite.pos.x < 0 or sprite.pos.x > 1024 - tex.w) sprite.flipH();
            if (sprite.pos.y < 0 or sprite.pos.y > 768 - tex.h) sprite.flipY();

            _ = sdl.SDL_RenderTexture(renderer, tex.tex, null, &sprite.pos);
        }

        _ = sdl.SDL_RenderPresent(renderer);
    }
}

const Sprite = struct {
    pos: sdl.SDL_FRect,
    vel: sdl.SDL_FRect,

    pub fn init(w: f32, h: f32) Sprite {
        var sprite = std.mem.zeroes(Sprite);

        sprite.pos.x = @floatFromInt(rnd.intRangeAtMost(u32, 0, 1024));
        sprite.pos.y = @floatFromInt(rnd.intRangeAtMost(u32, 0, 768));
        sprite.pos.w = w;
        sprite.pos.h = h;

        sprite.vel.x = (rnd.float(f32) * 2 - 1) * rnd.float(f32) * 5;
        sprite.vel.y = (rnd.float(f32) * 2 - 1) * rnd.float(f32) * 5;

        return sprite;
    }

    pub fn flipH(self: *Sprite) void {
        self.vel.x = self.vel.x * -1;
    }

    pub fn flipY(self: *Sprite) void {
        self.vel.y = self.vel.y * -1;
    }
};

const Texture = struct {
    tex: *sdl.SDL_Texture = undefined,
    w: f32 = 0,
    h: f32 = 0,

    pub fn init(renderer: *sdl.SDL_Renderer, path: []const u8) Texture {
        const temp = sdl.SDL_LoadBMP(path.ptr);
        defer sdl.SDL_DestroySurface(temp);

        if (temp.*.format.*.palette != null) {
            const pixels = @as(*u32, @alignCast(@ptrCast(temp.*.pixels)));
            _ = sdl.SDL_SetSurfaceColorKey(temp, sdl.SDL_TRUE, pixels.*);
        } else {
            @panic("image has no palette");
        }

        const tex = sdl.SDL_CreateTextureFromSurface(renderer, temp);

        return .{
            .tex = tex.?,
            .w = @floatFromInt(temp.*.w),
            .h = @floatFromInt(temp.*.h),
        };
    }

    pub fn deinit(self: Texture) void {
        sdl.SDL_DestroyTexture(self.tex);
    }
};
