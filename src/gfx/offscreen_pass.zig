const std = @import("std");
const gfx = @import("gfx.zig");
const aya = @import("../aya.zig");

pub const DefaultOffscreenPass = struct {
    render_tex: gfx.RenderTexture,
    policy: gfx.ResolutionPolicy,
    scaler: gfx.ResolutionScaler,
    design_w: i32,
    design_h: i32,

    pub fn init(w: i32, h: i32, policy: gfx.ResolutionPolicy) DefaultOffscreenPass {
        // fetch the Resolution_Scaler first since it will decide the render texture size
        var scaler = policy.getScaler(w, h);

        const pass = DefaultOffscreenPass{
            .render_tex = gfx.RenderTexture.init(w, h),
            .policy = policy,
            .scaler = scaler,
            .design_w = w,
            .design_h = h,
        };

        // TODO: we have to update our scaler when the window resizes
        // TODO: remove the hack from gfx.blitToScreen when this works
        //aya.window.subscribe(.resize, onWindowResizedCallback, pass, false);

        return pass;
    }

    pub fn deinit(self: DefaultOffscreenPass) void {
        // TODO: unsubscribe from window resize event
        self.render_tex.deinit();
    }

    pub fn onWindowResizedCallback(self: *DefaultOffscreenPass) void {
        // TODO: if the policy is .default we need to recreate the render textures with the new backbuffer size
        var w: i32 = 0;
        var h: i32 = 0;
        aya.window.drawableSize(&w, &h);
        if (self.policy == .default and (w != self.design_w or h != self.design_h)) {
            self.render_tex.resize(w, h);
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
