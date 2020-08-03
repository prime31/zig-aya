const std = @import("std");
const aya = @import("../aya.zig");
const fs = aya.fs;
const gfx = aya.gfx;
usingnamespace aya.sokol;

pub const Pipeline = extern struct {
    pip: sg_pipeline,
    shader: sg_shader,

    pub fn init() Pipeline {
        return .{};
    }

    pub fn deinit(self: Pipeline) void {}

    // static methods
    pub fn makeDefaultPipeline() Pipeline {
        var shader_desc = getDefaultShaderDesc();
        const shader = makeShader("", "", &shader_desc);

        var pipeline_desc = getDefaultPipelineDesc();
        pipeline_desc.shader = shader;
        return .{ .pip = sg_make_pipeline(&pipeline_desc), .shader = shader };
    }

    pub fn getDefaultPipelineDesc() sg_pipeline_desc {
        var pipeline_desc = std.mem.zeroes(sg_pipeline_desc);
        pipeline_desc.layout.attrs[0].format = .SG_VERTEXFORMAT_FLOAT2;
        pipeline_desc.layout.attrs[1].format = .SG_VERTEXFORMAT_FLOAT3;
        pipeline_desc.layout.attrs[2].format = .SG_VERTEXFORMAT_UBYTE4N;
        // pipeline_desc.layout.buffers[0].stride = 28;

        pipeline_desc.index_type = .SG_INDEXTYPE_UINT16;

        pipeline_desc.blend.enabled = true;
        pipeline_desc.blend.src_factor_rgb = .SG_BLENDFACTOR_SRC_ALPHA;
        pipeline_desc.blend.dst_factor_rgb = .SG_BLENDFACTOR_ONE_MINUS_SRC_ALPHA;
        pipeline_desc.blend.src_factor_alpha = .SG_BLENDFACTOR_ONE;
        pipeline_desc.blend.dst_factor_alpha = .SG_BLENDFACTOR_ONE_MINUS_SRC_ALPHA;

        pipeline_desc.depth_stencil.depth_compare_func = .SG_COMPAREFUNC_LESS_EQUAL;
        pipeline_desc.depth_stencil.depth_write_enabled = false;

        pipeline_desc.blend.color_format = .SG_PIXELFORMAT_BGRA8; // metal only for bgra? SG_PIXELFORMAT_RGBA8;
        // pipeline_desc.blend.depth_format = .SG_PIXELFORMAT_NONE;
        pipeline_desc.rasterizer.cull_mode = .SG_CULLMODE_NONE;

        return pipeline_desc;
    }

    // shaders
    /// returns a sg_shader_desc with the default frag texture and vert uniform block
    pub fn getDefaultShaderDesc() sg_shader_desc {
        var shader_desc = std.mem.zeroes(sg_shader_desc);
        shader_desc.fs.images[0].name = "MainTex";
        shader_desc.vs.uniform_blocks[0].size = @sizeOf(aya.math.Mat32);
        shader_desc.vs.uniform_blocks[0].uniforms[0].name = "TransformMatrix";
        shader_desc.vs.uniform_blocks[0].uniforms[0].type = .SG_UNIFORMTYPE_FLOAT3;
        shader_desc.vs.uniform_blocks[0].uniforms[0].array_count = 1;

        return shader_desc;
    }

    pub fn makeShader(comptime vert: []const u8, comptime frag: []const u8, shader_desc: *sg_shader_desc) sg_shader {
        shader_desc.vs.source = vs_metal ++ vert;
        shader_desc.fs.source = fs_metal ++ frag;
        return sg_make_shader(shader_desc);
    }
};

const vs_metal =
\\ #pragma clang diagnostic ignored "-Wmissing-prototypes"
\\ #pragma clang diagnostic ignored "-Wmissing-braces"
\\
\\ #include <metal_stdlib>
\\ #include <simd/simd.h>
\\
\\ using namespace metal;
\\
\\ struct vs_in
\\ {
\\     float2 VertPosition [[attribute(0)]];
\\     float2 VertTexCoord [[attribute(1)]];
\\     float4 VertColor [[attribute(2)]];
\\ };
\\
\\ struct vs_out
\\ {
\\     float2 VaryingTexCoord [[user(locn0)]];
\\     float4 VaryingColor [[user(locn1)]];
\\     float4 gl_Position [[position]];
\\ };
\\
\\ static inline __attribute__((always_inline))
\\ float4 position(thread const float3x2& transMat, thread const float2& localPosition)
\\ {
\\     // position = float4(mul(float3(position.xy, 1), TransformMatrix), 0, 1);
\\     return float4(localPosition, 0.0, 1.0);
\\     //return float4(transMat * float3(localPosition, 1.0), 0.0, 1.0);
\\ }
\\
\\ vertex vs_out _main(vs_in in [[stage_in]], constant array<float3, 2>& TransformMatrix [[buffer(0)]])
\\ {
\\     vs_out out = {};
\\     out.VaryingTexCoord = in.VertTexCoord;
\\     out.VaryingColor = in.VertColor;
\\     float3x2 matrix = float3x2(TransformMatrix[0].x, TransformMatrix[0].y, TransformMatrix[0].z, TransformMatrix[1].x, TransformMatrix[1].y, TransformMatrix[1].z);
\\     //out.gl_Position = position(matrix, in.VertPosition);
\\     out.gl_Position = float4(in.VertPosition, 0.0, 1.0);
\\     return out;
\\ }
;

const fs_metal =
\\ #pragma clang diagnostic ignored "-Wmissing-prototypes"
\\
\\ #include <metal_stdlib>
\\ #include <simd/simd.h>
\\
\\ using namespace metal;
\\
\\ struct main0_out
\\ {
\\     float4 frag_color [[color(0)]];
\\ };
\\
\\ struct main0_in
\\ {
\\     float2 VaryingTexCoord [[user(locn0)]];
\\     float4 VaryingColor [[user(locn1)]];
\\ };
\\
\\ static inline __attribute__((always_inline))
\\ float4 effect(thread const float4& vcolor, thread const texture2d<float> tex, thread const sampler texSmplr, thread const float2& texcoord)
\\ {
\\     return tex.sample(texSmplr, texcoord) * vcolor;
\\ }
\\
\\ fragment main0_out _main(main0_in in [[stage_in]], texture2d<float> MainTex [[texture(0)]], sampler MainTexSmplr [[sampler(0)]])
\\ {
\\     main0_out out = {};
\\     float4 param = in.VaryingColor;
\\     float2 param_1 = in.VaryingTexCoord;
\\     out.frag_color = effect(param, MainTex, MainTexSmplr, param_1);
\\     out.frag_color += float4(1, 1, 1, 1);
\\     return out;
\\ }
;