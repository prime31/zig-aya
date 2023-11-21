const std = @import("std");
const sdl = @import("sdl");
const wgpu = @import("wgpu");

const pools = @import("graphics_context.zig");

fn VertexAttributesReturnType(comptime T: type) type {
    return struct {
        attributes: [@typeInfo(T).Struct.fields.len]wgpu.VertexAttribute,

        pub fn vertexBufferLayouts(self: *const @This()) [1]wgpu.VertexBufferLayout {
            return [_]wgpu.VertexBufferLayout{.{
                .array_stride = @sizeOf(T),
                .attribute_count = self.attributes.len,
                .attributes = &self.attributes,
            }};
        }
    };
}

/// translates a vertex Type into the relevant VertexAttribute's and VertexBufferLayout. Doesnt directly support
/// instanced rendering currently.
pub fn vertexAttributesForType(comptime T: type) VertexAttributesReturnType(T) {
    var vert_attributes: [@typeInfo(T).Struct.fields.len]wgpu.VertexAttribute = undefined;
    var attr_index: usize = 0;

    inline for (@typeInfo(T).Struct.fields, 0..) |field, i| {
        _ = i;
        switch (@typeInfo(field.type)) {
            .Array => |arr_info| {
                switch (arr_info.child) {
                    f32 => {
                        switch (arr_info.len) {
                            1 => {
                                vert_attributes[attr_index] = .{ .format = .float32, .offset = @offsetOf(T, field.name), .shader_location = @intCast(attr_index) };
                                attr_index += 1;
                            },
                            2 => {
                                vert_attributes[attr_index] = .{ .format = .float32x2, .offset = @offsetOf(T, field.name), .shader_location = @intCast(attr_index) };
                                attr_index += 1;
                            },
                            3 => {
                                vert_attributes[attr_index] = .{ .format = .float32x3, .offset = @offsetOf(T, field.name), .shader_location = @intCast(attr_index) };
                                attr_index += 1;
                            },
                            4 => {
                                vert_attributes[attr_index] = .{ .format = .float32x4, .offset = @offsetOf(T, field.name), .shader_location = @intCast(attr_index) };
                                attr_index += 1;
                            },
                            else => @panic("invalid f32 array size"),
                        }
                    },
                    else => @panic("unsupported array type"),
                }
            },
            .Int => |type_info| {
                if (type_info.signedness == .signed) {
                    unreachable;
                } else {
                    switch (type_info.bits) {
                        32 => {
                            // u32 is color
                            attr_index += 1;
                            @panic("not finished");
                        },
                        else => unreachable,
                    }
                }
            },
            .Float => {
                attr_index += 1;
                @panic("not finished");
            },
            .Struct => |type_info| {
                const field_type = type_info.fields[0].type;
                switch (@typeInfo(field_type)) {
                    .Float => {
                        switch (type_info.fields.len) {
                            2, 3, 4 => {
                                attr_index.* += 1;
                                @panic("not finished");
                            },
                            else => unreachable,
                        }
                    },
                    else => unreachable,
                }
            },
            else => unreachable,
        }
    }

    var res: VertexAttributesReturnType(T) = undefined;
    res.attributes = vert_attributes;
    return res;
}

// gpu_texture_make(w, h, gpu_texture_format_rgb8, filter_type_nearest, false, lifetime);
// gpu_texture_set_data(input_texture, in_bitmap);
// gpu_texture_clear(textures[(cn-1)%2], (color_t){0});

// typedef struct {
//     gpu_bindgroup_layout_t bgls[3];
//     gpu_pipeline_buffer_desc_t buffers[3];
//     u32                       primitive           : 2;
//     u32                       blend_function_src  : 4;
//     u32                       blend_function_dest : 4;
//     ... etc
// } gpu_pipeline_info_t;

// typedef struct {
//     gpu_pipeline_t      pipeline;
//     u32                 first_vertex;
//     u32                 last_vertex;
//     gpu_buffer_t        vertex_buffers[3];
//     gpu_buffer_t        index_buffer;
//     gpu_texture_t       outputs[3];
//     gpu_texture_t       depth;
//     gpu_bindgroup_t     bindgroups[3];
//     rectu16_t           scissor;
//     rectu16_t           viewport;
//     u32                 num_instances;
// } drawcall_t;

// drawcall_render(&(drawcall_t){
//     .pipeline = pipeline,
//     .last_vertex = 6,
//     .bindgroups = {render_uniform_bindgroup, texture_bindgroup[cn%2]},
// });

pub const DrawCall = struct {
    pipeline: pools.RenderPipelineHandle,
    first_vertex: u32 = 0,
    last_vertex: u32 = 0,
    vertex_buffers: []pools.BufferHandle = &.{},
    index_buffer: ?pools.BufferHandle = null,
    outputs: []pools.TextureHandle = &.{},
    depth: ?pools.TextureHandle = null,
    bindgroups: []pools.BindGroupHandle = &.{},
    scissor: ?u1 = null,
    viewport: ?u1 = null,
    num_instances: u32 = 1,
};
