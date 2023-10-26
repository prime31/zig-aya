const std = @import("std");
const aya = @import("../aya.zig");
const rk = @import("renderkit");
const gfx = @import("gfx.zig");

pub const OffscreenPass = struct {
    pass: rk.Pass,
    color_texture: gfx.Texture,
    depth_stencil_texture: ?gfx.Texture = null,

    pub fn init(width: i32, height: i32) OffscreenPass {
        return initWithOptions(width, height, .nearest, .clamp);
    }

    pub fn initWithOptions(width: i32, height: i32, filter: rk.TextureFilter, wrap: rk.TextureWrap) OffscreenPass {
        const color_tex = gfx.Texture.initOffscreen(width, height, filter, wrap);

        const pass = rk.createPass(.{
            .color_img = color_tex.img,
        });
        return .{ .pass = pass, .color_texture = color_tex };
    }

    pub fn initWithStencil(width: i32, height: i32, filter: rk.TextureFilter, wrap: rk.TextureWrap) OffscreenPass {
        const color_tex = gfx.Texture.initOffscreen(width, height, filter, wrap);
        const depth_stencil_img = gfx.Texture.initStencil(width, height, filter, wrap);

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
        if (self.depth_stencil_texture) |depth_stencil| {
            depth_stencil.deinit();
        }
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

    pub fn init(w: i32, h: i32, filter: rk.TextureFilter, policy: gfx.ResolutionPolicy) DefaultOffscreenPass {
        // fetch the Resolution_Scaler first since it will decide the render texture size
        var scaler = policy.getScaler(w, h);

        const pass = DefaultOffscreenPass{
            .pass = if (policy != .none) OffscreenPass.initWithOptions(w, h, filter, .clamp) else undefined,
            .policy = policy,
            .scaler = scaler,
            .design_w = w,
            .design_h = h,
        };

        // TODO: remove the hack from gfx.blitToScreen that calls onWindowResizedCallback when this works
        //aya.window.subscribe(.resize, onWindowResizedCallback, pass, false);

        return pass;
    }

    pub fn deinit(self: DefaultOffscreenPass) void {
        // TODO: unsubscribe from window resize event
        if (self.policy != .none) {
            self.pass.deinit();
        }
    }

    pub fn onWindowResizedCallback(self: *DefaultOffscreenPass, w: c_int, h: c_int) void {
        // const size = aya.window.drawableSize();
        const size: struct { w: c_int, h: c_int } = .{ .w = w, .h = h };
        std.debug.print("----- fix size here too\n", .{});
        if (size.w != 0 and size.h != 0 and self.policy == .default and (size.w != self.design_w or size.h != self.design_h)) {
            self.pass.resize(size.w, size.h);
            self.design_w = size.w;
            self.design_h = size.h;
        }
        self.scaler = self.policy.getScaler(self.design_w, self.design_h);
    }
};
