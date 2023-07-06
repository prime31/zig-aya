const std = @import("std");
const aya = @import("../../aya.zig");
const OffscreenPass = aya.gfx.OffscreenPass;

/// manaages a list of PostProcessors that are used to process a render texture before blitting it to the screen.
pub const PostProcessStack = struct {
    processors: std.ArrayList(*PostProcessor),
    allocator: std.mem.Allocator,
    pass: OffscreenPass,

    pub fn init(allocator: ?std.mem.Allocator, design_w: i32, _: i32) PostProcessStack {
        _ = design_w;
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
            fn deinit(proc: *PostProcessor, allocator: std.mem.Allocator) void {
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
            self.pass.resize(@as(i32, @intFromFloat(pass.color_texture.width)), @as(i32, @intFromFloat(pass.color_texture.height)));
        }

        for (self.processors.items, 0..) |p, i| {
            const offscreen_pass = if (!aya.math.isEven(i)) pass else self.pass;
            const tex = if (aya.math.isEven(i)) pass.color_texture else self.pass.color_texture;
            p.process(p, offscreen_pass, tex);
        }

        // if there was an odd number of post processors blit to the OffscreenPass that was passed in so it gets blitted to the backbuffer
        if (!aya.math.isEven(self.processors.items.len)) {
            aya.gfx.beginPass(.{ .clear_color = false, .pass = pass });
            aya.draw.tex(self.pass.color_texture, 0, 0);
            aya.gfx.endPass();
        }
    }
};

/// implementors must have initialize, deinit and process methods defined and a postprocessor: *PostProcessor field.
/// The initialize method is where default values should be set since this will be a heap allocated object.
pub const PostProcessor = struct {
    process: fn (*PostProcessor, OffscreenPass, aya.gfx.Texture) void,
    deinit: fn (self: *PostProcessor, allocator: std.mem.Allocator) void = undefined,

    /// can be used externally, to get the original PostProcessor by Type or by the PostProcessor to get itself interface methods.
    pub fn getParent(self: *PostProcessor, comptime T: type) *T {
        return @fieldParentPtr(T, "postprocessor", self);
    }

    // helper method for taking the final texture from a postprocessor and blitting it. Simple postprocessors
    // can get away with just calling this method directly.
    pub fn blit(_: *PostProcessor, pass: OffscreenPass, tex: aya.gfx.Texture, shader: *aya.gfx.Shader) void {
        aya.gfx.beginPass(.{ .clear_color = false, .pass = pass, .shader = shader });
        aya.draw.tex(tex, 0, 0);
        aya.gfx.endPass();
    }
};
