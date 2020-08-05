const std = @import("std");
const aya = @import("../aya.zig");
const shaders = @import("shaders");
const sokol = @import("sokol");

/// manaages a list of PostProcessors that are used to process a render texture before blitting it to the screen.
pub const PostProcessStack = struct {
    processors: std.ArrayList(*PostProcessor),
    allocator: *std.mem.Allocator,

    pub fn init(allocator: ?*std.mem.Allocator, design_w: i32, design_h: i32) PostProcessStack {
        const alloc = allocator orelse aya.mem.allocator;
        return .{
            .processors = std.ArrayList(*PostProcessor).init(alloc),
            .allocator = alloc,
        };
    }

    pub fn deinit(self: PostProcessStack) void {
        for (self.processors.items) |p| {
            p.deinit(p, self.allocator);
        }
        self.processors.deinit();
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

    pub fn process(self: *PostProcessStack, pass: aya.gfx.OffscreenPass) void {
        for (self.processors.items) |p| {
            p.process(p, pass.color_tex);
        }
    }
};

/// implmentors must have initialize, deinit and process methods defined. The initialize method is where default values
/// should be set since this will be a heap allocated object.
pub const PostProcessor = struct {
    process: fn (*PostProcessor, aya.gfx.Texture) void,
    deinit: fn (self: *PostProcessor, allocator: *std.mem.Allocator) void = undefined,

    pub fn getParent(self: *PostProcessor, comptime T: type) *T {
        return @fieldParentPtr(T, "postprocessor", self);
    }

    // helper method for taking the final texture from a postprocessor and blitting it. Simple postprocessors
    // can get away with just calling this method directly.
    pub fn blit(self: *PostProcessor, tex: aya.gfx.Texture, pipeline: aya.gfx.Pipeline) void {
        aya.gfx.beginPass(.{ .color_action = .SG_ACTION_DONTCARE, .pipeline = pipeline });
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
        self.pipeline.setFragUniform(0, std.mem.asBytes(&self.sepia_tone));
    }

    pub fn process(processor: *PostProcessor, tex: aya.gfx.Texture) void {
        const self = processor.getParent(@This());
        processor.blit(tex, self.pipeline);
    }
};
