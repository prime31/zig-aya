const std = @import("std");
const aya = @import("../aya.zig");
const zgpu = @import("zgpu");
const wgpu = zgpu.wgpu;

const Handle = aya.Handle;
const MeshPipeline = aya.MeshPipeline;
const Shader = aya.Shader;
const RenderPipelineDescriptor = aya.RenderPipelineDescriptor;
const MeshVertexBufferLayout = aya.InnerMeshVertexBufferLayout;
const MeshPipelineKey = aya.MeshPipelineKey;

pub fn Material(comptime M: type) type {
    return struct {
        const Self = @This();

        pub const material_type = M;

        pub fn vertexShader(_: Self) aya.ShaderRef {
            if (@hasDecl(M, "vertexShader")) return M.vertexShader();
            return .default;
        }

        pub fn fragmentShader(_: Self) aya.ShaderRef {
            if (@hasDecl(M, "fragmentShader")) return M.fragmentShader();
            return .default;
        }

        pub fn depthBias(_: Self) f32 {
            if (@hasDecl(M, "depthBias")) return M.fragmedepthBiasntShader();
            return 0;
        }

        pub fn prepassVertexShader(_: Self) aya.ShaderRef {
            if (@hasDecl(M, "prepassVertexShader")) return M.prepassVertexShader();
            return .default;
        }

        pub fn prepassFragmentShader(_: Self) aya.ShaderRef {
            if (@hasDecl(M, "prepassFragmentShader")) return M.prepassFragmentShader();
            return .default;
        }

        pub fn deferredVertexShader(_: Self) aya.ShaderRef {
            if (@hasDecl(M, "deferredVertexShader")) return M.deferredVertexShader();
            return .default;
        }

        pub fn deferredFragmentShader(_: Self) aya.ShaderRef {
            if (@hasDecl(M, "deferredFragmentShader")) return M.deferredFragmentShader();
            return .default;
        }

        pub fn specialize(
            _: MaterialPipeline(M),
            _: *RenderPipelineDescriptor,
            _: *MeshVertexBufferLayout,
            _: MaterialPipelineKey(M),
        ) !void {}
    };
}

/// A key uniquely identifying a specialized [`MaterialPipeline`].
pub fn MaterialPipelineKey(comptime M: type) type {
    return struct {
        mesh_key: MeshPipelineKey,
        bind_group_data: M.Data, // TODO: M.Data is a type created by AsBindGroup
    };
}

/// Resource. Render pipeline data for a given [`Material`].
pub fn MaterialPipeline(comptime M: type) type {
    return struct {
        const Self = @This();
        pub const Key = MaterialPipelineKey(M);

        mesh_pipeline: MeshPipeline,
        material_layout: zgpu.BindGroupLayoutHandle,
        vertex_shader: ?Handle(Shader),
        fragment_shader: ?Handle(Shader),

        pub fn specialize(self: Self, key: Key, layout: *MeshVertexBufferLayout) !RenderPipelineDescriptor {
            var descriptor = self.mesh_pipeline.specialize(key.mesh_key, layout);

            if (self.vertex_shader) |vert_shader| descriptor.vertex.shader = vert_shader;
            if (self.fragment_shader) |frag_shader| descriptor.fragment.shader = frag_shader;

            return descriptor;
        }
    };
}

// fn specialize(
//     &self,
//     key: Self::Key,
//     layout: &MeshVertexBufferLayout,
// ) -> Result<RenderPipelineDescriptor, SpecializedMeshPipelineError> {
//     let mut descriptor = self.mesh_pipeline.specialize(key.mesh_key, layout)?;
//     if let Some(vertex_shader) = &self.vertex_shader {
//         descriptor.vertex.shader = vertex_shader.clone();
//     }

//     if let Some(fragment_shader) = &self.fragment_shader {
//         descriptor.fragment.as_mut().unwrap().shader = fragment_shader.clone();
//     }

//     descriptor.layout.insert(1, self.material_layout.clone());

//     M::specialize(self, &mut descriptor, layout, key)?;
//     Ok(descriptor)
// }
