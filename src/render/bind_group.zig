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

    pub fn getBinding(self: *OwnedBindingResource) wgpu.BindingResource { // wgpu.BindGroupLayoutEntry maybe?
        switch (self) {
            .buffer => {},
            .texture_view => {},
            .sampler => {},
        }
        // match self {
        //     OwnedBindingResource::Buffer(buffer) => buffer.as_entire_binding(),
        //     OwnedBindingResource::TextureView(view) => BindingResource::TextureView(view),
        //     OwnedBindingResource::Sampler(sampler) => BindingResource::Sampler(sampler),
        // }
    }
};

pub const Bindings = struct { id: u32, resource: OwnedBindingResource };

/// A prepared bind group returned as a result of [`AsBindGroup::as_bind_group`].
pub fn PreparedBindGroup(comptime T: type) type {
    return struct {
        const Self = @This();

        bindings: std.ArrayList(Bindings),
        bind_group: zgpu.BindGroupHandle = .{}, // zgpu.BindGroupHandle.nil
        data: T = std.mem.zeroes(T),

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

/// a map containing `OwnedBindingResource`s, keyed by the target binding index
pub fn UnpreparedBindGroup(comptime T: type) type {
    return struct {
        const Self = @This();

        bindings: std.ArrayList(Bindings),
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
