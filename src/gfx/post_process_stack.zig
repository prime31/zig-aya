const std = @import("std");
const aya = @import("../aya.zig");

pub const PostProcessStack = struct {
    processors: std.ArrayList(*PostProcessor),
    allocator: *std.mem.Allocator,

    pub fn init(allocator: ?*std.mem.Allocator) PostProcessStack {
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

    pub fn add(self: *PostProcessStack, comptime T: type, data: var) *T {
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

    pub fn process(self: PostProcessStack, pass: aya.gfx.OffscreenPass) void {
        for (self.processors.items) |p| {
            p.process(p, pass);
        }
    }
};

pub const PostProcessor = struct {
    process: fn (*PostProcessor, aya.gfx.OffscreenPass) void,
    deinit: fn (self: *PostProcessor, allocator: *std.mem.Allocator) void = undefined,

    pub fn getParent(self: *PostProcessor, comptime T: type) *T {
        return @fieldParentPtr(T, "postprocessor", self);
    }

    // helper method for taking the final texture from a postprocessor and blitting it. Simple postprocessors
    // can get away with just calling this method directly.
    pub fn blit(self: PostProcessor, tex: aya.gfx.Texture, shader: aya.gfx.Shader) void {
        aya.gfx.beginPass(.{});
        shader.apply();
        aya.draw.tex(tex, 0, 0);
        aya.gfx.endPass();
    }
};

pub const Sepia = struct {
    postprocessor: PostProcessor,
    shader: aya.gfx.Shader,

    pub fn deinit(self: @This()) void {
        self.shader.deinit();
    }

    pub fn initialize(self: *@This(), data: var) void {
        self.shader = aya.gfx.Shader.initFromFile("assets/Sepia.fxb") catch unreachable;
        self.shader.setParam(aya.math.Vec3, "_sepiaTone", aya.math.Vec3{ .x = 1.2, .y = 1.0, .z = 0.8 });
        self.postprocessor = .{
            .process = process,
        };
    }

    pub fn process(processor: *PostProcessor, pass: aya.gfx.OffscreenPass) void {
        const self = processor.getParent(@This());
        processor.blit(pass.render_tex.tex, self.shader);
    }
};
