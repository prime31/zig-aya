const std = @import("std");
const aya = @import("../aya.zig");
const rk = @import("renderkit");
const gfx = @import("graphics_context.zig");

const Size = aya.math.Size;
const Texture = aya.render.Texture;

pub const OffscreenPass = struct {
    pass: rk.Pass,
    color_texture: Texture,
    color_texture2: ?Texture = null,
    color_texture3: ?Texture = null,
    color_texture4: ?Texture = null,
    depth_stencil_texture: ?Texture = null,

    pub fn init(width: i32, height: i32) OffscreenPass {
        return initWithOptions(width, height, .nearest, .clamp);
    }

    pub fn initWithOptions(width: i32, height: i32, filter: rk.TextureFilter, wrap: rk.TextureWrap) OffscreenPass {
        const color_tex = Texture.initOffscreen(width, height, filter, wrap);

        const pass = rk.createPass(.{
            .color_img = color_tex.img,
        });
        return .{ .pass = pass, .color_texture = color_tex };
    }

    pub fn initMrt(width: i32, height: i32, num_render_targets: u8, filter: rk.TextureFilter, wrap: rk.TextureWrap) OffscreenPass {
        std.debug.assert(num_render_targets > 1 and num_render_targets <= 4);

        var config = std.mem.zeroes(rk.PassDesc);
        var mrts: [4]?Texture = [_]?Texture{null} ** 4;
        for (0..num_render_targets) |i| {
            mrts[i] = Texture.initOffscreen(width, height, filter, wrap);
            if (i == 0) config.color_img = mrts[i].?.img;
            if (i == 1) config.color_img2 = mrts[i].?.img;
            if (i == 2) config.color_img3 = mrts[i].?.img;
            if (i == 3) config.color_img4 = mrts[i].?.img;
        }

        const pass = rk.createPass(config);
        return .{
            .pass = pass,
            .color_texture = mrts[0].?,
            .color_texture2 = mrts[1],
            .color_texture3 = mrts[2],
            .color_texture4 = mrts[3],
        };
    }

    pub fn initWithStencil(width: i32, height: i32, filter: rk.TextureFilter, wrap: rk.TextureWrap) OffscreenPass {
        const color_tex = Texture.initOffscreen(width, height, filter, wrap);
        const depth_stencil_img = Texture.initStencil(width, height, filter, wrap);

        const pass = rk.createPass(.{
            .color_img = color_tex.img,
            .depth_stencil_img = depth_stencil_img.img,
        });
        return .{ .pass = pass, .color_texture = color_tex, .depth_stencil_texture = depth_stencil_img };
    }

    pub fn deinit(self: *const OffscreenPass) void {
        // Pass MUST be destroyed first! It relies on the Textures being present.
        rk.destroyPass(self.pass);
        self.color_texture.deinit();
        if (self.color_texture2) |tex| tex.deinit();
        if (self.color_texture3) |tex| tex.deinit();
        if (self.color_texture4) |tex| tex.deinit();
        if (self.depth_stencil_texture) |ds| ds.deinit();
    }

    pub fn resize(self: *OffscreenPass, width: i32, height: i32) void {
        self.deinit();
        self.* = if (self.depth_stencil_texture != null) OffscreenPass.initWithStencil(width, height, .nearest, .clamp) else OffscreenPass.init(width, height);
    }
};

pub const DefaultOffscreenPass = struct {
    pass: OffscreenPass,
    policy: gfx.ResolutionPolicy,
    scaler: gfx.ResolutionScaler,
    design_w: i32,
    design_h: i32,

    pub fn init(w: i32, h: i32, filter: rk.TextureFilter, policy: gfx.ResolutionPolicy, depth_stencil: bool) DefaultOffscreenPass {
        // fetch the Resolution_Scaler first since it will decide the render texture size
        var scaler = policy.getScaler(w, h);

        return .{
            .pass = if (policy != .none) if (depth_stencil) OffscreenPass.initWithStencil(w, h, filter, .clamp) else OffscreenPass.initWithOptions(w, h, filter, .clamp) else undefined,
            .policy = policy,
            .scaler = scaler,
            .design_w = w,
            .design_h = h,
        };
    }

    pub fn deinit(self: DefaultOffscreenPass) void {
        if (self.policy != .none) {
            self.pass.deinit();
        }
    }

    pub fn onWindowResizedCallback(self: *DefaultOffscreenPass, size: Size) void {
        if (self.policy == .none) return;

        if (size.w != 0 and size.h != 0 and self.policy == .default and (size.w != self.design_w or size.h != self.design_h)) {
            self.pass.resize(size.w, size.h);
            self.design_w = size.w;
            self.design_h = size.h;
        }
        self.scaler = self.policy.getScaler(self.design_w, self.design_h);
    }
};
