const std = @import("std");
const aya = @import("../aya.zig");
const shaders = @import("shaders");
const sokol = @import("sokol");
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
            .pass = OffscreenPass.init(sokol.sapp_width(), sokol.sapp_height(), .nearest),
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
        for (self.processors.items) |p, i| {
            const offscreen_pass = if (!aya.math.isEven(i)) pass else self.pass;
            const tex = if (aya.math.isEven(i)) pass.color_tex else self.pass.color_tex;
            p.process(p, offscreen_pass, tex);
        }

        // if there was an odd number of post processors blit to the OffscreenPass that was passed in so it gets blitted to the backbuffer
        if (!aya.math.isEven(self.processors.items.len)) {
            aya.gfx.beginPass(.{ .color_action = .SG_ACTION_DONTCARE, .pass = pass, .pipeline = aya.gfx.defaultPipeline() });
            aya.draw.tex(self.pass.color_tex, 0, 0);
            aya.gfx.endPass();
        }
    }
};

/// implmentors must have initialize, deinit and process methods defined. The initialize method is where default values
/// should be set since this will be a heap allocated object.
pub const PostProcessor = struct {
    process: fn (*PostProcessor, OffscreenPass, aya.gfx.Texture) void,
    deinit: fn (self: *PostProcessor, allocator: *std.mem.Allocator) void = undefined,

    /// can be used externally, to get the original PostProcessor by Type or by the PostProcessor to get itself interface methods.
    pub fn getParent(self: *PostProcessor, comptime T: type) *T {
        return @fieldParentPtr(T, "postprocessor", self);
    }

    // helper method for taking the final texture from a postprocessor and blitting it. Simple postprocessors
    // can get away with just calling this method directly.
    pub fn blit(self: *PostProcessor, pass: OffscreenPass, tex: aya.gfx.Texture, pipeline: aya.gfx.Pipeline) void {
        aya.gfx.beginPass(.{ .color_action = .SG_ACTION_DONTCARE, .pass = pass, .pipeline = pipeline });
        aya.draw.tex(tex, 0, 0);
        aya.gfx.endPass();
    }
};

pub const Sepia = struct {
    postprocessor: PostProcessor,
    pipeline: aya.gfx.Pipeline,
    sepia_tone: aya.math.Vec3,

    pub fn deinit(self: @This()) void {
        self.pipeline.deinit();
    }

    pub fn initialize(self: *@This(), data: anytype) void {
        self.pipeline = aya.gfx.Pipeline.init(shaders.sepia_shader_desc());
        self.postprocessor = .{ .process = process };

        self.sepia_tone = .{ .x = 1.2, .y = 1.0, .z = 0.8 };
        self.pipeline.setFragUniform(0, &self.sepia_tone);
    }

    pub fn process(processor: *PostProcessor, pass: OffscreenPass, tex: aya.gfx.Texture) void {
        const self = processor.getParent(@This());
        processor.blit(pass, tex, self.pipeline);
    }

    pub fn setTone(self: *@This(), tone: aya.math.Vec3) void {
        self.sepia_tone = tone;
        self.pipeline.setFragUniform(0, &self.sepia_tone);
    }
};

pub const Vignette = struct {
    postprocessor: PostProcessor,
    pipeline: aya.gfx.Pipeline,
    params: struct { radius: f32, power: f32 },

    pub fn deinit(self: @This()) void {
        self.pipeline.deinit();
    }

    pub fn initialize(self: *@This(), data: anytype) void {
        self.pipeline = aya.gfx.Pipeline.init(shaders.vignette_shader_desc());
        self.postprocessor = .{ .process = process };

        self.params = .{ .radius = 1.2, .power = 1 };
        self.pipeline.setFragUniform(0, &self.params);
    }

    pub fn process(processor: *PostProcessor, pass: OffscreenPass, tex: aya.gfx.Texture) void {
        const self = processor.getParent(@This());
        processor.blit(pass, tex, self.pipeline);
    }

    pub fn setUniforms(self: *@This(), radius: f32, power: 32) void {
        self.params.radius = radius;
        self.params.power = power;
        self.pipeline.setFragUniform(0, &self.params);
    }
};

pub const PixelGlitch = struct {
    postprocessor: PostProcessor,
    pipeline: aya.gfx.Pipeline,
    params: Params,

    pub const Params = struct { vertical_size: f32, horizontal_offset: f32, screen_size: aya.math.Vec2 };

    pub fn deinit(self: @This()) void {
        self.pipeline.deinit();
    }

    pub fn initialize(self: *@This(), data: anytype) void {
        self.pipeline = aya.gfx.Pipeline.init(shaders.pixel_glitch_shader_desc());
        self.postprocessor = .{ .process = process };

        self.params = .{ .vertical_size = 0.5, .horizontal_offset = 10, .screen_size = aya.window.sizeVec2() };
        self.pipeline.setFragUniform(0, &self.params);
    }

    pub fn process(processor: *PostProcessor, pass: OffscreenPass, tex: aya.gfx.Texture) void {
        const self = processor.getParent(@This());
        processor.blit(pass, tex, self.pipeline);
    }

    pub fn setUniforms(self: *@This(), vertical_size: f32, horizontal_offset: f32, screen_size: aya.math.Vec2) void {
        self.params.vertical_size = vertical_size;
        self.params.horizontal_offset = horizontal_offset;
        self.params.screen_size = screen_size;
        self.pipeline.setFragUniform(0, &self.params);
    }

    pub fn setParams(self: *@This(), params: Params) void {
        self.params = params;
        self.pipeline.setFragUniform(0, &self.params);
    }
};
