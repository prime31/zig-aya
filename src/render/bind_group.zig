const std = @import("std");
const aya = @import("../aya.zig");
const zgpu = @import("zgpu");
const wgpu = zgpu.wgpu;

/// An owned binding resource of any type (ex: a [`Buffer`], [`TextureView`], etc).
/// This is used by types like [`PreparedBindGroup`] to hold a single list of all
/// render resources used by bindings.
pub const OwnedBindingResource = union(enum) {
    buffer: zgpu.BufferHandle,
    texture_view: zgpu.TextureViewHandle,
    sampler: zgpu.SamplerHandle,
};

pub const Bindings = struct { id: u32, resource: OwnedBindingResource };

/// A prepared bind group returned as a result of [`AsBindGroup::as_bind_group`].
pub fn PreparedBindGroup(comptime T: type) type {
    return struct {
        const Self = @This();

        bindings: std.ArrayList(Bindings),
        bind_group: zgpu.BindGroupHandle = .{}, // zgpu.BindGroupHandle.nil
        data: T,

        pub fn init() Self {
            return .{
                .bindings = std.ArrayList(Bindings).init(aya.allocator),
            };
        }

        pub fn deinit(self: *Self) void {
            self.bindings.deinit();
        }
    };
}
