const std = @import("std");
const sdl = @import("sdl");
const stb = @import("stb");
const imgui = @import("imgui");

const Allocator = std.mem.Allocator;

var rand_impl = std.rand.DefaultPrng.init(42);
const rnd = rand_impl.random();

var gpa = std.heap.GeneralPurposeAllocator(.{}){};

pub fn main() !void {
    defer _ = gpa.detectLeaks();

    const window = sdl.SDL_CreateWindow("fook you sdl3", 1024, 768, sdl.SDL_WINDOW_RESIZABLE) orelse {
        sdl.SDL_Log("Unable to create window: %s", sdl.SDL_GetError());
        @panic("no window created");
    };
    const renderer = sdl.SDL_CreateRenderer(window, null, sdl.SDL_RENDERER_PRESENTVSYNC | sdl.SDL_RENDERER_ACCELERATED) orelse {
        sdl.SDL_Log("Unable to create renderer: %s", sdl.SDL_GetError());
        @panic("no renderer created");
    };

    // Dear ImGui
    imgui.sdl.init(window, renderer);

    var tex = Texture.init(gpa.allocator(), renderer, "examples/assets/sword_dude.png");
    defer tex.deinit();

    var sprites: [200]Sprite = undefined;
    for (0..200) |i| sprites[i] = Sprite.init(tex.w, tex.h);

    blk: while (true) {
        var event: sdl.SDL_Event = undefined;
        while (sdl.SDL_PollEvent(&event) != 0) {
            if (imgui.sdl.handleEvent(&event)) continue;
            switch (event.type) {
                sdl.SDL_EVENT_QUIT => break :blk,
                sdl.SDL_EVENT_WINDOW_CLOSE_REQUESTED => {
                    std.debug.print("window evt: {}\n", .{event.window.type});
                },
                else => {},
            }
        }

        imgui.sdl.newFrame();
        if (imgui.enabled) imgui.igShowDemoWindow(null);

        _ = sdl.SDL_SetRenderDrawColor(renderer, 0xA0, 0xA0, 0xA0, 0xFF);
        _ = sdl.SDL_RenderClear(renderer);

        for (&sprites) |*sprite| {
            sprite.pos.x += sprite.vel.x;
            sprite.pos.y += sprite.vel.y;

            if (sprite.pos.x < 0 or sprite.pos.x > 1024 - tex.w) sprite.flipH();
            if (sprite.pos.y < 0 or sprite.pos.y > 768 - tex.h) sprite.flipY();

            _ = sdl.SDL_RenderTexture(renderer, tex.tex, null, &sprite.pos);
        }

        imgui.sdl.render();
        _ = sdl.SDL_RenderPresent(renderer);
    }

    imgui.sdl.shutdown();

    sdl.SDL_DestroyRenderer(renderer);
    sdl.SDL_DestroyWindow(window);
    sdl.SDL_Quit();
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

    pub fn init(allocator: Allocator, renderer: *sdl.SDL_Renderer, path: []const u8) Texture {
        var image = stb.Image.init(allocator, path) catch unreachable;
        defer image.deinit();

        const tex = sdl.SDL_CreateTexture(renderer, sdl.SDL_PIXELFORMAT_RGBA32, sdl.SDL_TEXTUREACCESS_TARGET, @intCast(image.w), @intCast(image.h));

        const image_data = image.getImageData();
        const rect: sdl.SDL_Rect = .{ .x = 0, .y = 0, .w = @intCast(image.w), .h = @intCast(image.h) };
        _ = sdl.SDL_UpdateTexture(tex, &rect, image_data.ptr, @intCast(image.w * @sizeOf(u32)));
        _ = sdl.SDL_SetTextureBlendMode(tex, sdl.SDL_BLENDMODE_BLEND);

        return .{
            .tex = tex.?,
            .w = @floatFromInt(image.w),
            .h = @floatFromInt(image.h),
        };
    }

    pub fn deinit(self: *Texture) void {
        sdl.SDL_DestroyTexture(self.tex);
    }
};
