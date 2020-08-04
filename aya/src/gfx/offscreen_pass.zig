const std = @import("std");
const gfx = @import("gfx.zig");
const aya = @import("../aya.zig");
usingnamespace @import("sokol");

pub const OffscreenPass = struct {
    color_tex: gfx.Texture,
    depth_tex: gfx.Texture,
    pass: sg_pass,

    pub fn init(w: i32, h: i32, filter: gfx.Texture.Filter) OffscreenPass {
        const color_tex = gfx.Texture.initOffscreen(w, h, filter);
        const depth_tex = gfx.Texture.initDepthStencil(w, h, filter);

        var pass_desc = std.mem.zeroes(sg_pass_desc);
        pass_desc.color_attachments[0].image = color_tex.img;
        pass_desc.depth_stencil_attachment.image = depth_tex.img;

        return .{
            .color_tex = color_tex,
            .depth_tex = depth_tex,
            .pass = sg_make_pass(&pass_desc),
        };
    }

    pub fn deinit(self: OffscreenPass) void {
        sg_destroy_pass(self.pass);
        sg_destroy_image(self.color_tex.img);
        sg_destroy_image(self.depth_tex.img);
    }
};

pub const DefaultOffscreenPass = struct {
    offscreen_pass: OffscreenPass,
    policy: gfx.ResolutionPolicy,
    scaler: gfx.ResolutionScaler,
    design_w: i32,
    design_h: i32,

    pub fn init(w: i32, h: i32, policy: gfx.ResolutionPolicy, filter: gfx.Texture.Filter) DefaultOffscreenPass {
        // fetch the Resolution_Scaler first since it will decide the render texture size
        var scaler = policy.getScaler(w, h);

        const pass = DefaultOffscreenPass{
            .offscreen_pass = if (policy != .none) OffscreenPass.init(w, h, filter) else undefined,
            .policy = policy,
            .scaler = scaler,
            .design_w = w,
            .design_h = h,
        };

        // TODO: we have to update our scaler when the window resizes
        // TODO: remove the hack from gfx.blitToScreen when this works
        // if (self.policy != .none) {
        //aya.window.subscribe(.resize, onWindowResizedCallback, pass, false);

        return pass;
    }

    pub fn deinit(self: DefaultOffscreenPass) void {
        // TODO: unsubscribe from window resize event
        if (self.policy != .none) {
            self.offscreen_pass.deinit();
        }
    }

    pub fn onWindowResizedCallback(self: *DefaultOffscreenPass) void {
        var w = aya.window.width();
        var h = aya.window.height();
        if (self.policy == .default and (w != self.design_w or h != self.design_h)) {
            self.offscreen_pass.color_tex.resize(w, h);
            self.offscreen_pass.depth_tex.resize(w, h);
            self.design_w = w;
            self.design_h = h;
        }
        self.scaler = self.policy.getScaler(self.design_w, self.design_h);
    }
};

test "test offscreen pass" {
    const def_pass = DefaultOffscreenPass.init(320, 240, .best_fit);
    def_pass.deinit();
}
