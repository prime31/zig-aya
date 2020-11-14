const std = @import("std");
const aya = @import("../../aya.zig");
const OffscreenPass = aya.gfx.OffscreenPass;

/// manaages a list of PostProcessors that are used to process a render texture before blitting it to the screen.
pub const PostProcessStack = struct {
    processors: std.ArrayList(*PostProcessor),
    allocator: *std.mem.Allocator,
    pass: OffscreenPass,

    pub fn init(allocator: ?*std.mem.Allocator, design_w: i32, design_h: i32) PostProcessStack {
        const alloc = allocator orelse aya.mem.allocator;
        return .{
            .processors = std.ArrayList(*PostProcessor).init(alloc),
            .allocator = alloc,
            .pass = OffscreenPass.init(aya.window.width(), aya.window.height()),
        };
    }

    pub fn deinit(self: PostProcessStack) void {
        for (self.processors.items) |p| {
            p.deinit(p, self.allocator);
        }
        self.processors.deinit();
        self.pass.deinit();
    }

    pub fn add(self: *PostProcessStack, comptime T: type, data: anytype) *T {
        std.debug.assert(@hasDecl(T, "initialize"));
        std.debug.assert(@hasDecl(T, "deinit"));
        std.debug.assert(@hasDecl(T, "process"));
        std.debug.assert(@hasField(T, "postprocessor"));

        var processor = self.allocator.create(T) catch unreachable;
        processor.initialize(data);

        // get a closure so that we can safely deinit this later
        processor.postprocessor.deinit = struct {
            fn deinit(proc: *PostProcessor, allocator: *std.mem.Allocator) void {
                proc.getParent(T).deinit();
                allocator.destroy(@fieldParentPtr(T, "postprocessor", proc));
            }
        }.deinit;

        self.processors.append(&processor.postprocessor) catch unreachable;
        return processor;
    }

    pub fn process(self: *PostProcessStack, pass: OffscreenPass) void {
        // keep our OffscreenPass size in sync with the default pass
        if (pass.color_texture.width != self.pass.color_texture.width or pass.color_texture.height != self.pass.color_texture.height) {
            self.pass.resize(@floatToInt(i32, pass.color_texture.width), @floatToInt(i32, pass.color_texture.height));
        }

        for (self.processors.items) |p, i| {
            const offscreen_pass = if (!aya.math.isEven(i)) pass else self.pass;
            const tex = if (aya.math.isEven(i)) pass.color_texture else self.pass.color_texture;
            p.process(p, offscreen_pass, tex);
        }

        // if there was an odd number of post processors blit to the OffscreenPass that was passed in so it gets blitted to the backbuffer
        if (!aya.math.isEven(self.processors.items.len)) {
            aya.gfx.beginPass(.{ .color_action = .dont_care, .pass = pass });
            aya.draw.tex(self.pass.color_texture, 0, 0);
            aya.gfx.endPass();
        }
    }
};

/// implementors must have initialize, deinit and process methods defined and a postprocessor: *PostProcessor field.
/// The initialize method is where default values should be set since this will be a heap allocated object.
pub const PostProcessor = struct {
    process: fn (*PostProcessor, OffscreenPass, aya.gfx.Texture) void,
    deinit: fn (self: *PostProcessor, allocator: *std.mem.Allocator) void = undefined,

    /// can be used externally, to get the original PostProcessor by Type or by the PostProcessor to get itself interface methods.
    pub fn getParent(self: *PostProcessor, comptime T: type) *T {
        return @fieldParentPtr(T, "postprocessor", self);
    }

    // helper method for taking the final texture from a postprocessor and blitting it. Simple postprocessors
    // can get away with just calling this method directly.
    pub fn blit(self: *PostProcessor, pass: OffscreenPass, tex: aya.gfx.Texture, shader: aya.gfx.Shader) void {
        aya.gfx.beginPass(.{ .color_action = .dont_care, .pass = pass, .shader = shader });
        aya.draw.tex(tex, 0, 0);
        aya.gfx.endPass();
    }
};

const sepia_frag: [:0]const u8 =
    \\uniform vec3 sepia_tone = vec3(1.2, 1.0, 0.8);
    \\
    \\vec4 effect(sampler2D tex, vec2 tex_coord, vec4 vert_color) {
    \\  vec4 color = texture(tex, tex_coord);
    \\
    \\  // convert to greyscale then tint
    \\  float gray_scale = dot(color.rgb, vec3(0.3, 0.59, 0.11));
    \\  color.rgb = mix(color.rgb, gray_scale * sepia_tone, 0.75);
    \\
    \\  return color;
    \\}
;

const vignette_frag: [:0]const u8 =
    \\uniform float radius = 1.25;
    \\uniform float power = 1.0;
    \\
    \\vec4 effect(sampler2D tex, vec2 tex_coord, vec4 vert_color) {
    \\  vec4 color = texture(tex, tex_coord);
    \\
    \\  vec2 dist = (tex_coord - 0.5f) * radius;
    \\  dist.x = 1 - dot(dist, dist) * power;
    \\  color.rgb *= dist.x;
    \\
    \\  return color;
    \\}
;

const pixel_glitch_frag: [:0]const u8 =
    \\uniform float vertical_size = 5.0; // vertical size in pixels or each row
    \\uniform float horizontal_offset = 10.0; // horizontal shift in pixels
    \\uniform vec2 screen_size = vec2(1024, 768); // screen width/height
    \\
    \\float hash11(float p) {
    \\	  vec3 p3  = fract(vec3(p, p, p) * 0.1031);
    \\    p3 += dot(p3, p3.yzx + 19.19);
    \\    return fract((p3.x + p3.y) * p3.z);
    \\}
    \\
    \\vec4 effect(sampler2D tex, vec2 tex_coord, vec4 vert_color) {
    \\  // convert vertical_size and horizontal_offset from pixels
    \\  float pixels = screen_size.x / vertical_size;
    \\  float offset = horizontal_offset / screen_size.y;
    \\
    \\  // get a number between -1 and 1 to offset the row of pixels by that is dependent on the y position
    \\  float r = hash11(floor(tex_coord.y * pixels)) * 2.0 - 1.0;
    \\  return texture(tex, vec2(tex_coord.x + r * offset, tex_coord.y));
    \\}
;

pub const Sepia = struct {
    postprocessor: PostProcessor,
    shader: aya.gfx.Shader,
    sepia_tone: aya.math.Vec3,

    pub fn deinit(self: @This()) void {
        self.shader.deinit();
    }

    pub fn initialize(self: *@This(), data: anytype) void {
        self.shader = aya.gfx.Shader.initWithFrag(sepia_frag) catch unreachable;
        self.postprocessor = .{ .process = process };
        self.sepia_tone = .{ .x = 1.2, .y = 1.0, .z = 0.8 };
    }

    pub fn process(processor: *PostProcessor, pass: OffscreenPass, tex: aya.gfx.Texture) void {
        const self = processor.getParent(@This());
        processor.blit(pass, tex, self.shader);
    }

    pub fn setTone(self: *@This(), tone: aya.math.Vec3) void {
        self.sepia_tone = tone;
        // TODO: dont bind just to set uniforms...
        self.shader.bind();
        self.shader.setUniformName(aya.math.Vec3, "sepia_tone", self.sepia_tone);
    }
};

pub const Vignette = struct {
    postprocessor: PostProcessor,
    shader: aya.gfx.Shader,
    params: struct { radius: f32, power: f32 },

    pub fn deinit(self: @This()) void {
        self.shader.deinit();
    }

    pub fn initialize(self: *@This(), data: anytype) void {
        self.shader = aya.gfx.Shader.initWithFrag(vignette_frag) catch unreachable;
        self.postprocessor = .{ .process = process };
        self.params = .{ .radius = 1.2, .power = 1 };
    }

    pub fn process(processor: *PostProcessor, pass: OffscreenPass, tex: aya.gfx.Texture) void {
        const self = processor.getParent(@This());
        processor.blit(pass, tex, self.shader);
    }

    pub fn setUniforms(self: *@This(), radius: f32, power: f32) void {
        self.params.radius = radius;
        self.params.power = power;

        // TODO: dont bind just to set uniforms...
        self.shader.bind();
        self.shader.setUniformName(f32, "radius", radius);
        self.shader.setUniformName(f32, "power", power);
    }
};

pub const PixelGlitch = struct {
    postprocessor: PostProcessor,
    shader: aya.gfx.Shader,
    params: Params,

    pub const Params = struct {
        pub const inspect = .{
            .vertical_size = .{ .min = 0.1, .max = 100.0 },
            .horizontal_offset = .{ .min = -100.0, .max = 100.0 },
        };

        vertical_size: f32 = 5,
        horizontal_offset: f32 = 10,
    };

    pub fn deinit(self: @This()) void {
        self.shader.deinit();
    }

    pub fn initialize(self: *@This(), data: anytype) void {
        self.shader = aya.gfx.Shader.initWithFrag(pixel_glitch_frag) catch unreachable;
        self.postprocessor = .{ .process = process };

        // TODO: dont bind just to set uniforms...
        const size = aya.window.size();
        self.params = .{ .vertical_size = 0.5, .horizontal_offset = 10 };
        self.setUniforms(self.params.vertical_size, self.params.horizontal_offset);
    }

    pub fn process(processor: *PostProcessor, pass: OffscreenPass, tex: aya.gfx.Texture) void {
        const self = processor.getParent(@This());
        processor.blit(pass, tex, self.shader);
    }

    pub fn setUniforms(self: *@This(), vertical_size: f32, horizontal_offset: f32) void {
        self.params.vertical_size = vertical_size;
        self.params.horizontal_offset = horizontal_offset;

        // TODO: dont bind just to set uniforms...
        self.shader.bind();
        self.shader.setUniformName(f32, "vertical_size", vertical_size);
        self.shader.setUniformName(f32, "horizontal_offset", horizontal_offset);
        const size = aya.window.size();
        self.shader.setUniformName(aya.math.Vec2, "screen_size", .{ .x = @intToFloat(f32, size.w), .y = @intToFloat(f32, size.h) });
    }
};
