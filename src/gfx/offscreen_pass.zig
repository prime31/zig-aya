const gfx = @import("gfx.zig");

pub const OffscreenPass = struct {
    render_tex: gfx.RenderTexture,

    pub fn init(w: i32, h: i32) OffscreenPass {
        return OffscreenPass{
            .render_tex = gfx.RenderTexture.init(w, h),
        };
    }

    pub fn deinit(self: OffscreenPass) void {
        self.render_tex.deinit();
    }
};

pub const DefaultOffscreenPass = struct {
    offscreen_pass: OffscreenPass,
    policy: gfx.ResolutionPolicy,
    scaler: gfx.ResolutionScaler,
    design_w: i32,
    design_h: i32,

    pub fn init(w: i32, h: i32, policy: gfx.ResolutionPolicy) DefaultOffscreenPass {
        // fetch the Resolution_Scaler first since it will decide the render texture size
        var scaler = policy.getScaler(w, h);

        const pass = DefaultOffscreenPass{
            .offscreen_pass = OffscreenPass.init(w, h),
            .policy = policy,
            .scaler = scaler,
            .design_w = w,
            .design_h = h,
        };

        // TODO: we have to update our scaler when the window resizes
        // TODO: if the policy is .default we need to recreate the render textures with the new backbuffer size
        //aya.window.subscribe(.resize, onWindowResizedCallback, pass, false);

        return pass;
    }

    pub fn deinit(self: DefaultOffscreenPass) void {
        // TODO: unsubscribe from window resize event
        self.offscreen_pass.deinit();
    }

    pub fn onWindowResizedCallback(self: *DefaultOffscreenPass) void {
        self.scaler = self.policy.getScaler(self.design_w, self.design_h);
    }
};

test "test offscreen pass" {
    const pass = OffscreenPass.init(320, 240);
    pass.deinit();

    const def_pass = DefaultOffscreenPass.init(320, 240, .best_fit);
    def_pass.deinit();
}
