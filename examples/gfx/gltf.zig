const std = @import("std");
const zmesh = @import("zmesh");
const aya = @import("aya");
const wgpu = aya.wgpu;

const Vec = aya.utils.Vec;
const PrimitiveMap = std.AutoHashMap(Primitive, Vec(aya.render.BindGroupHandle));

const Vec2 = aya.math.Vec2;
const Mat32 = aya.math.Mat32;
const Quad = aya.math.Quad;
const Rect = aya.math.Rect;
const RectI = aya.math.RectI;
const Color = aya.math.Color;

const Uniform = extern struct {
    transform_matrix: Mat32,
};

var frame_bind_group: aya.render.BindGroupHandle = undefined;
var gltf_pipeline_layout: wgpu.PipelineLayout = undefined;

pub fn main() !void {
    try aya.run(.{
        .init = init,
        .render = render,
        .shutdown = shutdown,
    });
}

fn init() !void {
    var gctx = aya.gctx;

    pipeline_gpu_data = std.AutoHashMap(u64, GpuPipeline).init(aya.mem.allocator);
    loadGltf();

    const frame_bind_group_layout = gctx.createBindGroupLayout(&.{
        .label = "Frame BindGroupLayout", // Camera/Frame uniforms
        .entries = &.{
            .{ .visibility = .{ .vertex = true }, .buffer = .{ .type = .uniform, .has_dynamic_offset = true } },
        },
    });
    // defer gctx.releaseResource(frame_bind_group_layout); // TODO: do we have to hold onto these?

    frame_bind_group = gctx.createBindGroup(frame_bind_group_layout, &.{
        .{ .buffer_handle = gctx.uniforms.buffer, .size = 256 },
    });

    const node_bind_group_layout = gctx.createBindGroupLayout(&.{
        .label = "Node BindGroupLayout", // Node uniforms
        .entries = &.{
            .{ .visibility = .{ .vertex = true }, .buffer = .{ .type = .uniform } },
            // .{ .visibility = .{ .fragment = true }, .texture = .{} },
            // .{ .visibility = .{ .fragment = true }, .sampler = .{} },
        },
    });
    // defer gctx.releaseResource(node_bind_group_layout); // TODO: do we have to hold onto these?

    var bind_group_layouts = [_]wgpu.BindGroupLayout{ gctx.lookupResource(frame_bind_group_layout).?, gctx.lookupResource(node_bind_group_layout).? };
    gltf_pipeline_layout = aya.gctx.device.createPipelineLayout(&.{
        .bind_group_layout_count = bind_group_layouts.len,
        .bind_group_layouts = &bind_group_layouts,
    });
}

fn shutdown() !void {}

fn render(ctx: *aya.render.RenderContext) !void {
    const bg = aya.gctx.lookupResource(frame_bind_group) orelse return;

    // begin the render pass
    var pass = ctx.beginRenderPass(&.{
        .label = "Ding Render Pass Encoder",
        .color_attachment_count = 1,
        .color_attachments = &.{
            .view = ctx.swapchain_view,
            .load_op = .clear,
            .store_op = .store,
            .clear_value = .{ .r = 0.1, .g = 0.2, .b = 0.3, .a = 1.0 },
        },
    });

    // projection matrix uniform
    {
        const win_size = aya.window.sizeInPixels();

        const mem = aya.gctx.uniforms.allocate(Uniform, 1);
        mem.slice[0] = .{
            .transform_matrix = Mat32.initOrtho(@as(f32, @floatFromInt(win_size.w)), @as(f32, @floatFromInt(win_size.h))),
        };
        pass.setBindGroup(0, bg, &.{mem.offset});
    }

    pass.end();
    pass.release();
}

var pipeline_gpu_data: std.AutoHashMap(u64, GpuPipeline) = undefined;

const Node = zmesh.io.zcgltf.Node;
const Mesh = zmesh.io.zcgltf.Mesh;
const Primitive = zmesh.io.zcgltf.Primitive;
const BufferView = zmesh.io.zcgltf.BufferView;
const Accessor = zmesh.io.zcgltf.Accessor;

fn loadGltf() void {
    zmesh.init(aya.mem.allocator);
    defer zmesh.deinit();

    const data = zmesh.io.parseAndLoadFile("examples/assets/models/avocado.glb") catch unreachable;
    defer zmesh.io.freeData(data);

    var primitive_instances = PrimitiveMap.init(aya.mem.allocator);

    for (0..data.nodes_count) |i| {
        const node: Node = data.nodes.?[i];
        if (node.mesh != null) setupMeshNode(data, node, &primitive_instances);
    }

    for (0..data.meshes_count) |i| {
        const mesh: Mesh = data.meshes.?[i];
        for (0..mesh.primitives_count) |j| setupPrimitive(data, mesh.primitives[j], &primitive_instances);
    }

    // var mesh_indices = std.ArrayList(u32).init(aya.mem.allocator);
    // var mesh_positions = std.ArrayList([3]f32).init(aya.mem.allocator);
    // var mesh_normals = std.ArrayList([3]f32).init(aya.mem.allocator);

    // zmesh.io.appendMeshPrimitive(
    //     data, // *zmesh.io.cgltf.Data
    //     0, // mesh index
    //     0, // gltf primitive index (submesh index)
    //     &mesh_indices,
    //     &mesh_positions,
    //     &mesh_normals, // normals (optional)
    //     null, // texcoords (optional)
    //     null, // tangents (optional)
    //     null, // colors (optional)
    // ) catch unreachable;
}

fn setupMeshNode(gltf: *zmesh.io.zcgltf.Data, node: Node, primitive_instances: *PrimitiveMap) void {
    _ = gltf;
    std.debug.print("node: {?s}\n", .{node.name});

    const bind_group_layout = aya.gctx.createBindGroupLayout(&.{
        .label = "Node BindGroupLayout", // Node uniforms
        .entries = &.{
            .{ .visibility = .{ .vertex = true }, .buffer = .{ .type = .uniform } },
        },
    });
    defer aya.gctx.releaseResource(bind_group_layout);

    const node_uni_buffer = aya.gctx.createBufferInit(null, .{ .copy_dst = true, .uniform = true }, f32, &node.transformWorld());
    const bind_group = aya.gctx.createBindGroup(bind_group_layout, &.{
        .{ .buffer_handle = node_uni_buffer, .size = 16 * @sizeOf(f32) },
    });

    // Loop through every primitive of the node's mesh and append this node's transform to the primitives instance list
    const mesh = node.mesh.?;
    for (mesh.primitives[0..mesh.primitives_count]) |primitive| {
        var res = primitive_instances.getOrPut(primitive) catch unreachable;
        if (!res.found_existing) res.value_ptr.* = Vec(aya.render.BindGroupHandle).init();
        res.value_ptr.append(bind_group);
    }
}

fn setupPrimitive(gltf: *zmesh.io.zcgltf.Data, primitive: Primitive, primitive_instances: *PrimitiveMap) void {
    _ = gltf;
    const BufferAttribute = struct {
        location: u32 = 0,
        format: wgpu.VertexFormat = .undefined,
        offset: usize = 0,
    };

    const BufferInfo = struct {
        array_stride: usize,
        attributes: [5]?BufferAttribute = [_]?BufferAttribute{null} ** 5,

        pub fn pushAttribute(self: *@This(), attribute: BufferAttribute) void {
            for (&self.attributes) |*attr| {
                if (attr.* == null) {
                    attr.* = attribute;
                    return;
                }
            }
            unreachable;
        }

        pub fn attributeSlice(self: *@This()) []?BufferAttribute {
            var i: usize = 0;
            while (self.attributes[i] != null) : (i += 1) {}
            return self.attributes[0..i];
        }

        pub fn sortAttributesByLocation(self: *@This()) void {
            var slice = self.attributeSlice();
            std.sort.heap(?BufferAttribute, slice, {}, struct {
                pub fn inner(_: void, a: ?BufferAttribute, b: ?BufferAttribute) bool {
                    return a.?.location < b.?.location;
                }
            }.inner);
        }
    };

    var buffer_layout = std.AutoHashMap(*BufferView, BufferInfo).init(aya.mem.allocator);
    var gpu_buffers = std.AutoHashMap(*BufferInfo, BufferWtf).init(aya.mem.allocator);
    var draw_count: usize = 0;

    for (primitive.attributes[0..primitive.attributes_count]) |attribute| {
        const accessor = attribute.data;
        const buffer_view = accessor.buffer_view.?;

        const shader_location: u32 = switch (attribute.type) {
            .position => 0,
            .normal => 1,
            .texcoord => 2,
            .tangent => 3,
            .color => continue,
            else => continue,
        };

        if (shader_location > 1) continue; // skip tex_coord and tangents for now

        var buffer_res = buffer_layout.getOrPut(buffer_view) catch unreachable;
        const separate = buffer_res.found_existing and @abs(accessor.offset - buffer_res.value_ptr.attributes[0].?.offset) >= buffer_res.value_ptr.array_stride;

        if (!buffer_res.found_existing or separate) {
            buffer_res.value_ptr.* = .{
                .array_stride = buffer_view.stride,
            };

            // bufferLayout.set(separate ? attribName : accessor.bufferView, buffer);
            // buffer_layout.put(if (separate) , value: V)
            gpu_buffers.put(buffer_res.value_ptr, .{
                .buffer = buffer_view,
                .offset = accessor.offset,
            }) catch unreachable;
        } else {
            var gpu_buffer = gpu_buffers.getPtr(buffer_res.value_ptr).?;
            gpu_buffer.offset = @min(gpu_buffer.offset, accessor.offset);
        }

        buffer_res.value_ptr.pushAttribute(.{
            .location = shader_location,
            .format = vertexFormatForAccessor(accessor),
            .offset = accessor.offset,
        });

        draw_count = accessor.count;
    }

    var buffer_iter = buffer_layout.valueIterator();
    while (buffer_iter.next()) |info| {
        const gpu_buffer = gpu_buffers.get(info).?;
        for (info.attributeSlice()) |*attr| attr.*.?.offset -= gpu_buffer.offset;

        // Sort the attributes by shader location.
        info.sortAttributesByLocation();
    }

    // Sort the buffers by their first attribute's shader location
    var sorted_buffer_layouts = aya.mem.tmp_allocator.alloc(*BufferInfo, buffer_layout.count()) catch unreachable;

    buffer_iter = buffer_layout.valueIterator();
    var i: usize = 0;
    while (buffer_iter.next()) |info| {
        sorted_buffer_layouts[i] = info;
        i += 1;
    }

    std.sort.heap(*BufferInfo, sorted_buffer_layouts, {}, struct {
        pub fn inner(_: void, a: *BufferInfo, b: *BufferInfo) bool {
            return a.attributes[0].?.location < b.attributes[0].?.location;
        }
    }.inner);

    // Ensure that the gpuBuffers are saved in the same order as the buffer layout.
    var sorted_gpu_buffers = aya.mem.tmp_allocator.alloc(BufferWtf, buffer_layout.count()) catch unreachable;
    for (sorted_buffer_layouts, 0..) |buffer_wtf, k| {
        sorted_gpu_buffers[k] = gpu_buffers.get(buffer_wtf).?;
    }

    var gpu_primitive = GpuPrimitive{
        .buffers = sorted_gpu_buffers,
        .draw_count = draw_count,
        .instances = primitive_instances.get(primitive).?,
    };

    if (primitive.indices) |indices| {
        gpu_primitive.index_buffer = indices.buffer_view.?.buffer;
        gpu_primitive.index_offset = indices.offset;
        gpu_primitive.index_type = indexFormatForComponentType(indices.component_type);
        gpu_primitive.draw_count = draw_count;
    }

    // Make sure to pass the sorted buffer layout here
    const pipeline_args = .{ primitiveTopologyForMode(primitive.type), sorted_buffer_layouts };
    var pipeline = getPipelineForPrimitive(pipeline_args);

    // Don't need to link the primitive and gpu_primitive any more, but we do need
    // to add the gpu_primitive to the pipeline's list of primitives.
    pipeline.primitives.append(gpu_primitive);
}

const BufferWtf = struct {
    buffer: *BufferView,
    offset: usize = 0,
};

const GpuPrimitive = struct {
    index_buffer: ?*zmesh.io.zcgltf.Buffer = null,
    index_offset: usize = 0,
    index_type: wgpu.IndexFormat = .undefined,
    buffers: []BufferWtf,
    draw_count: usize,
    instances: Vec(aya.render.BindGroupHandle),
};

const GpuPipeline = struct {
    pipeline: aya.render.RenderPipelineHandle,
    primitives: Vec(GpuPrimitive),

    pub fn init(pipeline: aya.render.RenderPipelineHandle) GpuPipeline {
        return .{ .pipeline = pipeline, .primitives = Vec(GpuPrimitive).init() };
    }
};

fn getPipelineForPrimitive(args: anytype) GpuPipeline {
    var hasher = std.hash.Wyhash.init(0);
    std.hash.autoHashStrat(&hasher, args, .Deep);
    const hash = hasher.final();

    if (pipeline_gpu_data.get(hash)) |pip| return pip;

    const shader_module = createWgslShaderModule(aya.fs.readZ(aya.mem.tmp_allocator, "examples/assets/shaders/gltf.wgsl") catch unreachable, null);
    defer shader_module.release();

    const pipe_desc = wgpu.RenderPipelineDescriptor{
        .layout = pipeline_layout,
        .vertex = wgpu.VertexState{
            .module = shader_module,
            .entry_point = "vs_main",
            .buffer_count = desc.vbuffers.len,
            .buffers = desc.vbuffers.ptr,
        },
        .fragment = &wgpu.FragmentState{
            .module = shader_module,
            .entry_point = "fs_main",
            .target_count = 1,
            .targets = &[_]wgpu.ColorTargetState{
                .{
                    .format = swapchain_format,
                    .blend = &desc.blend_state,
                },
            },
        },
    };

    const pipeline_handle = aya.gctx.createPipeline(&.{
        .source = aya.fs.readZ(aya.mem.tmp_allocator, "examples/assets/shaders/gltf.wgsl") catch unreachable,
        .vbuffers = &aya.gpu.vertexAttributesForType(aya.render.Vertex).vertexBufferLayouts(),
        .bgls = &.{ aya.gctx.lookupResource(bind_group_layout0).?, aya.gctx.lookupResource(bind_group_layout1).? },
    });

    const pipeline = GpuPipeline.init(pipeline_handle);
    pipeline_gpu_data.put(hash, pipeline) catch unreachable;
    return pipeline;
}

// getPipelineForPrimitive(args) {
//     const key = JSON.stringify(args);

//     let pipeline = this.pipelineGpuData.get(key);
//     if (pipeline) {
//     return pipeline;
//     }

//     const module = this.getShaderModule();
//     pipeline = this.device.createRenderPipeline({
//     label: 'glTF renderer pipeline',
//     layout: this.gltfPipelineLayout,
//     vertex: {
//         module,
//         entryPoint: 'vertexMain',
//         buffers: args.buffers,
//     },
//     primitive: {
//         topology: args.topology,
//         cullMode: 'back',
//     },
//     multisample: {
//         count: this.app.sampleCount,
//     },
//     depthStencil: {
//         format: this.app.depthFormat,
//         depthWriteEnabled: true,
//         depthCompare: 'less',
//     },
//     fragment: {
//         module,
//         entryPoint: 'fragmentMain',
//         targets: [{
//         format: this.app.colorFormat,
//         }],
//     },
//     });

//     const gpuPipeline = {
//     pipeline,
//     primitives: [] // Start tracking every primitive that uses this pipeline.
//     };

//     this.pipelineGpuData.set(key, gpuPipeline);

//     return gpuPipeline;
// }

fn vertexFormatForAccessor(accessor: *Accessor) wgpu.VertexFormat {
    const count = accessor.type.numComponents();

    switch (accessor.component_type) {
        .invalid => unreachable,
        .r_8 => {
            if (accessor.normalized == 1) {
                if (count == 2) return .snorm8x2;
                return .snorm8x4;
            } else {
                if (count == 2) return .sint8x2;
                return .sint8x4;
            }
        },
        .r_8u => {
            if (accessor.normalized == 1) {
                if (count == 2) return .unorm8x2;
                return .unorm8x4;
            } else {
                if (count == 2) return .uint8x2;
                return .uint8x4;
            }
        },
        .r_16 => {},
        .r_16u => {},
        .r_32u => {},
        .r_32f => {
            return switch (count) {
                1 => .float32,
                2 => .float32x2,
                3 => .float32x3,
                4 => .float32x4,
                else => unreachable,
            };
        },
    }

    unreachable;
}

fn indexFormatForComponentType(comp_type: zmesh.io.zcgltf.ComponentType) wgpu.IndexFormat {
    return switch (comp_type) {
        .r_16u => .uint16,
        .r_32u => .uint16,
        else => unreachable,
    };
}

fn primitiveTopologyForMode(mode: zmesh.io.zcgltf.PrimitiveType) wgpu.PrimitiveTopology {
    return switch (mode) {
        .points => .point_list,
        .lines => .line_list,
        .line_loop => unreachable,
        .line_strip => .line_strip,
        .triangles => .triangle_list,
        .triangle_strip => .triangle_strip,
        .triangle_fan => unreachable,
    };
}

fn createWgslShaderModule(source: [*:0]const u8, label: ?[*:0]const u8) wgpu.ShaderModule {
    const wgsl_desc = wgpu.ShaderModuleWGSLDescriptor{
        .chain = .{ .next = null, .s_type = .shader_module_wgsl_descriptor },
        .code = source,
    };
    const desc = wgpu.ShaderModuleDescriptor{
        .next_in_chain = @ptrCast(&wgsl_desc),
        .label = if (label) |l| l else null,
    };
    return aya.gctx.device.createShaderModule(&desc);
}
