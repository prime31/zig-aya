const std = @import("std");
const aya = @import("../aya.zig");
const RenderTexture = aya.gfx.RenderTexture;

pub const PostProcessStack = struct {
    processors: std.ArrayList(*PostProcessor),
    render_texture: RenderTexture,
    allocator: *std.mem.Allocator,

    pub fn init(allocator: ?*std.mem.Allocator, design_w: i32, design_h: i32) PostProcessStack {
        const alloc = allocator orelse aya.mem.allocator;
        return .{
            .processors = std.ArrayList(*PostProcessor).init(alloc),
            .render_texture = RenderTexture.init(design_w, design_h),
            .allocator = alloc,
        };
    }

    pub fn deinit(self: PostProcessStack) void {
        for (self.processors.items) |p| {
            p.deinit(p, self.allocator);
        }
        self.processors.deinit();
        self.render_texture.deinit();
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

    pub fn process(self: *PostProcessStack, rt: *RenderTexture) void {
        std.debug.assert(rt.tex.width == self.render_texture.tex.width);
        std.debug.assert(rt.tex.height == self.render_texture.tex.height);

        for (self.processors.items) |p, i| {
            const src = if (aya.math.isEven(i)) rt.* else self.render_texture;
            const dst = if (!aya.math.isEven(i)) rt.* else self.render_texture;
            p.process(p, src, dst);
        }

        // if there was an odd number of post processors swap the RTs so the last one written to is what gets blitted later
        if (!aya.math.isEven(self.processors.items.len)) {
            std.mem.swap(RenderTexture, rt, &self.render_texture);
        }
    }
};

pub const PostProcessor = struct {
    process: fn (*PostProcessor, RenderTexture, RenderTexture) void,
    deinit: fn (self: *PostProcessor, allocator: *std.mem.Allocator) void = undefined,

    pub fn getParent(self: *PostProcessor, comptime T: type) *T {
        return @fieldParentPtr(T, "postprocessor", self);
    }

    // helper method for taking the final texture from a postprocessor and blitting it. Simple postprocessors
    // can get away with just calling this method directly.
    pub fn blit(self: PostProcessor, src: RenderTexture, dst: RenderTexture, shader: aya.gfx.Shader) void {
        aya.gfx.beginPass(.{ .render_texture = dst, .shader = shader });
        aya.draw.tex(src.tex, 0, 0);
        aya.gfx.endPass();
    }
};

pub const Sepia = struct {
    postprocessor: PostProcessor,
    shader: aya.gfx.Shader,

    pub fn deinit(self: @This()) void {
        self.shader.deinit();
    }

    pub fn initialize(self: *@This(), data: anytype) void {
        self.shader = aya.gfx.Shader.initFromFile("assets/Sepia.fxb") catch unreachable;
        self.shader.setParam(aya.math.Vec3, "_sepiaTone", aya.math.Vec3{ .x = 1.2, .y = 1.0, .z = 0.8 });
        self.postprocessor = .{ .process = process };
    }

    pub fn process(processor: *PostProcessor, src: RenderTexture, dst: RenderTexture) void {
        const self = processor.getParent(@This());
        processor.blit(src, dst, self.shader);
    }
};
