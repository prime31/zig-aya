const std = @import("std");
const aya = @import("../aya.zig");

const TextureHandle = aya.render.TextureHandle;
const BindGroupHandle = aya.render.BindGroupHandle;

pub const BindGroupCache = struct {
    values: std.AutoHashMapUnmanaged(u32, BindGroupHandle),

    pub fn init() BindGroupCache {
        return .{ .values = .{} };
    }

    pub fn deinit(self: *BindGroupCache) void {
        self.values.deinit(aya.mem.allocator);
    }

    pub fn get(self: *BindGroupCache, texture: TextureHandle) BindGroupHandle {
        return self.values.get(texture.id).?;
    }

    pub fn remove(self: *BindGroupCache, texture: TextureHandle) void {
        _ = self.values.remove(texture.id);
    }

    pub fn containsOrPut(self: *BindGroupCache, texture: TextureHandle) ?*BindGroupHandle {
        var result = self.values.getOrPut(aya.mem.allocator, texture.id) catch unreachable;
        if (!result.found_existing) {
            return result.value_ptr;
        }
        return null;
    }
};

// check to see if a bind group is present. if not, use the pipeline to fetch the BindGroupLayout
// or just create it manually
// if (ibg.containsOrPut) |bind_group_handle| {
// manually create the layout
//      const bind_group_layout = aya.gctx.createBindGroupLayout(&.{
//          .entries = &.{
//              .{ .visibility = .{ .fragment = true }, .texture = .{} },
//              .{ .visibility = .{ .fragment = true }, .sampler = .{} },
//          },
//      });
//      defer aya.gctx.releaseResource(bind_group_layout);

// use the pipeline to get the layout
//     bind_group_handle.* = aya.gctx.createBindGroup(pipeline.getBindGroupLayout(0), &.{
//         .{ .texture_view_handle = tex_view },
//         .{ .sampler_handle = sampler },
//     });
// }
