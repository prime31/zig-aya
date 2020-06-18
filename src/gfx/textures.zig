const std = @import("std");
const fna = @import("../deps/fna/fna.zig");
const aya = @import("../aya.zig");

pub const Texture = extern struct {
    tex: *fna.Texture = undefined,
    width: i32 = 0,
    height: i32 = 0,

    var bound_textures: [4]*fna.Texture = undefined;
    var sampler_state_cache = std.AutoHashMap(*fna.Texture, fna.SamplerState).init(aya.mem.allocator);

    pub fn init(width: i32, height: i32) Texture {
        return Texture{
            .tex = aya.gfx.device.createTexture2D(.color, width, height, 1, false).?,
            .width = width,
            .height = height,
        };
    }

    pub fn initFromFile(file: []const u8) !Texture {
        var texture = Texture{};

        const c_file = try std.cstr.addNullByte(aya.mem.tmp_allocator, file);
        const img_data = fna.img.load(c_file, &texture.width, &texture.height);

        texture.tex = aya.gfx.device.createTexture2D(.color, texture.width, texture.height, 1, false).?;
        texture.setData(img_data);
        fna.img.FNA3D_Image_Free(img_data.ptr);

        return texture;
    }

    pub fn initFromData(data: []u8, width: i32, height: i32) !Texture {
        var texture = Texture{
            .width = width,
            .height = height,
        };

        texture.tex = aya.gfx.device.createTexture2D(.color, texture.width, texture.height, 1, false).?;
        texture.setData(data);

        return texture;
    }

    pub fn initCheckerboard() Texture {
        var pixels = [_]u32{
            0xFFFFFFFF, 0xFF000000, 0xFFFFFFFF, 0xFF000000,
            0xFF000000, 0xFFFFFFFF, 0xFF000000, 0xFFFFFFFF,
            0xFFFFFFFF, 0xFF000000, 0xFFFFFFFF, 0xFF000000,
            0xFF000000, 0xFFFFFFFF, 0xFF000000, 0xFFFFFFFF,
        };

        const tex = init(4, 4);
        tex.setColorData(pixels[0..]);
        tex.setSamplerState(fna.SamplerState{});
        return tex;
    }

    pub fn deinit(self: Texture) void {
        _ = sampler_state_cache.remove(self.tex);
        aya.gfx.device.addDisposeTexture(self.tex);
    }

    pub fn setData(self: Texture, data: []u8) void {
        aya.gfx.device.setTextureData2D(self.tex, .color, 0, 0, self.width, self.height, 0, &data[0], @intCast(i32, data.len));
    }

    pub fn setColorData(self: Texture, data: []u32) void {
        aya.gfx.device.setTextureData2D(self.tex, .color, 0, 0, self.width, self.height, 0, &data[0], @intCast(i32, data.len));
    }

    pub fn setSamplerState(self: Texture, sampler_state: fna.SamplerState) void {
        _ = sampler_state_cache.put(self.tex, sampler_state) catch |err| std.debug.warn("failed setSamplerState: {}\n", .{err});
    }

    pub fn bind(self: Texture, slot: usize) void {
        bindTexture(self.tex, slot);
    }

    pub fn bindTexture(fna_texture: *fna.Texture, slot: usize) void {
        // avoid binding already bound textures
        if (bound_textures[slot] == fna_texture) return;

        var sampler_state = sampler_state_cache.getValue(fna_texture);
        if (sampler_state == null) {
            sampler_state = fna.SamplerState{};
            _ = sampler_state_cache.put(fna_texture, sampler_state.?) catch |err| std.debug.warn("failed caching sampler state: {}\n", .{err});
        }
        aya.gfx.device.verifySampler(@intCast(i32, slot), fna_texture, &sampler_state.?);

        bound_textures[slot] = fna_texture;
    }
};

pub const RenderTexture = extern struct {
    tex: Texture = undefined,
    render_target_usage: fna.RenderTargetUsage = .platform_contents,
    depth_stencil_buffer: ?*fna.Renderbuffer = null,
    depth_stencil_format: fna.DepthFormat = .none,

    pub fn init(width: i32, height: i32) RenderTexture {
        return RenderTexture{
            .tex = .{
                .tex = aya.gfx.device.createTexture2D(.color, width, height, 1, true).?,
                .width = width,
                .height = height,
            },
        };
    }

    pub fn initWithDepthStencil(width: i32, height: i32, format: fna.DepthFormat) RenderTexture {
        var rt = init(width, height);
        rt.depth_stencil_format = format;
        if (format != .none) {
            rt.depth_stencil_buffer = aya.gfx.device.genDepthStencilRenderbuffer(width, height, format, 0);
        }

        return rt;
    }

    pub fn deinit(self: RenderTexture) void {
        if (self.depth_stencil_buffer != null) {
            aya.gfx.device.addDisposeRenderbuffer(self.depth_stencil_buffer);
        }
        self.tex.deinit();
    }

    pub fn resize(self: *RenderTexture, width: i32, height: i32) void {
        self.deinit();

        const rt: RenderTexture = if (self.depth_stencil_format != .none)
            RenderTexture.initWithDepthStencil(width, height, self.depth_stencil_format)
        else
            RenderTexture.init(width, height);

        self.tex = rt.tex;
        self.depth_stencil_buffer = rt.depth_stencil_buffer;
    }
};

test "test texture and rendertexture" {
    aya.window = try @import("../window.zig").Window.init(aya.WindowConfig{});
    defer aya.window.deinit();

    var params = fna.PresentationParameters{
        .backBufferWidth = 50,
        .backBufferHeight = 50,
        .deviceWindowHandle = aya.window.sdl_window,
    };
    aya.gfx.device = fna.Device.init(&params, true);

    const tex = try Texture.initFromFile("assets/font.png");
    tex.deinit();

    const tex2 = Texture.init(4, 4);
    tex2.deinit();

    const tex3 = Texture.initCheckerboard();
    tex3.bind(0);
    tex3.bind(0);
    tex3.deinit();

    const rt = RenderTexture.init(40, 40);
    rt.deinit();
}
