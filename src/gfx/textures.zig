const std = @import("std");
const fna = @import("../deps/fna/fna.zig");
const aya = @import("../aya.zig");

pub const Texture = extern struct {
    tex: ?*fna.Texture = null,
    width: i32 = 0,
    height: i32 = 0,

    var bound_textures: [4]?*fna.Texture = undefined;
    var sampler_state_cache = std.AutoHashMap(*fna.Texture, fna.SamplerState).init(aya.mem.allocator);

    pub fn init(width: i32, height: i32) Texture {
        return Texture{
            .tex = fna.FNA3D_CreateTexture2D(aya.gfx.device, .color, width, height, 1, 0),
            .width = width,
            .height = height,
        };
    }

    pub fn initFromFile(file: []const u8) !Texture {
        var texture = Texture{};

        const c_file = try std.cstr.addNullByte(aya.mem.tmp_allocator, file);
        const img_data = fna.img.load(c_file, &texture.width, &texture.height);

        texture.tex = fna.FNA3D_CreateTexture2D(aya.gfx.device, .color, texture.width, texture.height, 1, 0);
        texture.setData(img_data);
        fna.img.FNA3D_Image_Free(img_data.ptr);

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
        _ = sampler_state_cache.remove(self.tex.?);
        fna.FNA3D_AddDisposeTexture(aya.gfx.device, self.tex);
    }

    pub fn setData(self: Texture, data: []u8) void {
        fna.FNA3D_SetTextureData2D(aya.gfx.device, self.tex, .color, 0, 0, self.width, self.height, 0, &data[0], @intCast(i32, data.len));
    }

    pub fn setColorData(self: Texture, data: []u32) void {
        fna.FNA3D_SetTextureData2D(aya.gfx.device, self.tex, .color, 0, 0, self.width, self.height, 0, &data[0], @intCast(i32, data.len));
    }

    pub fn setSamplerState(self: Texture, sampler_state: fna.SamplerState) void {
        _ = sampler_state_cache.put(self.tex.?, sampler_state) catch |err| std.debug.warn("failed setSamplerState: {}\n", .{err});
    }

    pub fn bind(self: Texture, slot: usize) void {
        // avoid binding already bound textures
        if (bound_textures[slot] == self.tex.?) return;

        var sampler_state = sampler_state_cache.getValue(self.tex.?);
        if (sampler_state == null) sampler_state.? = fna.SamplerState{};
        fna.FNA3D_VerifySampler(aya.gfx.device, @intCast(i32, slot), self.tex, &sampler_state.?);

        bound_textures[slot] = self.tex.?;
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
                .tex = fna.FNA3D_CreateTexture2D(aya.gfx.device, .color, width, height, 1, 1),
                .width = width,
                .height = height,
            },
        };
    }

    pub fn initWithDepthStencil(width: i32, height: i32, format: fna.Depth_Format) RenderTexture {
        var rt = init(width, height);
        rt.depth_stencil_format = format;
        if (format != .none) {
            rt.depth_stencil_buffer = fna.FNA3D_GenDepthStencilRenderbuffer(aya.gfx.device, width, height, format, 0);
        }

        return rt;
    }

    pub fn deinit(self: RenderTexture) void {
        if (self.depth_stencil_buffer != null) {
            fna.FNA3D_AddDisposeRenderbuffer(aya.gfx.device, self.depth_stencil_buffer);
        }
        self.tex.deinit();
    }
};

test "test texture and rendertexture" {
    try aya.window.create(aya.WindowConfig{});
    defer aya.window.deinit();

    var params = fna.PresentationParameters{
        .backBufferWidth = 50,
        .backBufferHeight = 50,
        .deviceWindowHandle = aya.window.sdl_window,
    };
    aya.gfx.device = fna.FNA3D_CreateDevice(&params, 1);

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
