const std = @import("std");
const aya = @import("../aya.zig");
const fs = aya.fs;
const gfx = aya.gfx;
const shaders = @import("shaders");
usingnamespace aya.sokol;

pub const Pipeline = struct {
    pip: sg_pipeline,
    shader: sg_shader,
    uniforms: []UniformBlock = &[_]UniformBlock{},

    pub const UniformBlock = struct {
        shader_stage: sg_shader_stage,
        index: c_int,
        size: c_int,
        data: []u8,
        dirty: bool = false,

        pub fn deinit(self: UniformBlock) void {
            aya.mem.allocator.free(self.data);
        }
    };

    pub fn init(shader_desc: *const sg_shader_desc) Pipeline {
        var pipeline_desc = getDefaultPipelineDesc();
        const shader = sg_make_shader(shader_desc);
        pipeline_desc.shader = shader;

        // dig out any uniforms. first we figure out how many we have then we allocate and set them up
        var total_uniforms: usize = 0;
        for (shader_desc.fs.uniform_blocks) |uni| {
            if (uni.size == 0) break;
            total_uniforms += 1;
        }

        for (shader_desc.vs.uniform_blocks) |uni| {
            if (uni.size == 0) break;
            total_uniforms += 1;
        }

        var uniforms = if (total_uniforms == 0) &[_]UniformBlock{} else aya.mem.allocator.alloc(UniformBlock, total_uniforms) catch unreachable;
        var index: usize = 0;
        for (shader_desc.vs.uniform_blocks) |uni, i| {
            if (uni.size == 0) break;
            uniforms[index] = .{
                .shader_stage = .SG_SHADERSTAGE_VS,
                .index = @intCast(c_int, i),
                .size = uni.size,
                .data = aya.mem.allocator.alloc(u8, @intCast(usize, uni.size)) catch unreachable,
            };
            index += 1;
        }

        for (shader_desc.fs.uniform_blocks) |uni, i| {
            if (uni.size == 0) break;
            uniforms[index] = .{
                .shader_stage = .SG_SHADERSTAGE_FS,
                .index = @intCast(c_int, i),
                .size = uni.size,
                .data = aya.mem.allocator.alloc(u8, @intCast(usize, uni.size)) catch unreachable,
            };
            index += 1;
        }

        return .{ .pip = sg_make_pipeline(&pipeline_desc), .shader = shader, .uniforms = uniforms };
    }

    pub fn initDefaultPipeline() Pipeline {
        return init(shaders.sprite_shader_desc());
    }

    pub fn deinit(self: Pipeline) void {
        sg_destroy_pipeline(self.pip);
        sg_destroy_shader(self.shader);
        for (self.uniforms) |uni| uni.deinit();
    }

    pub fn getUniformIndex(self: Pipeline, shader_stage: sg_shader_stage, index: usize) usize {
        for (self.uniforms) |uni, i| {
            if (uni.shader_stage == shader_stage and uni.index == index) return i;
        }
        unreachable;
    }

    pub fn setUniform(self: Pipeline, uniform_index: usize, data: []const u8) void {
        // only set and dirty the uniform if it changed
        if (aya.mem.eqlSub(u8, data, self.uniforms[uniform_index].data)) return;

        std.mem.copy(u8, self.uniforms[uniform_index].data, data);
        self.uniforms[uniform_index].dirty = true;
    }

    pub fn setTransformMatrixUniform(self: Pipeline, matrix: aya.math.Mat32) void {
        // transform matrix should always be the first uniform
        var bytes = std.mem.asBytes(&matrix);
        self.setUniform(0, bytes[0..]);
    }

    /// sets a frag uniform in the Pipeline. data should be a pointer to the struct.
    pub fn setFragUniform(self: Pipeline, index: usize, data: anytype) void {
        std.debug.assert(@typeInfo(@TypeOf(data)) == .Pointer);

        for (self.uniforms) |uni, i| {
            if (uni.shader_stage == .SG_SHADERSTAGE_FS and uni.index == index) {
                self.setUniform(i, std.mem.asBytes(data));
            }
        }
    }

    pub fn applyUniforms(self: Pipeline) void {
        for (self.uniforms) |*uni| {
            if (!uni.dirty) continue;
            sg_apply_uniforms(uni.shader_stage, uni.index, uni.data.ptr, uni.size);
            // TODO: why do we have to apply uniforms every frame?
            // uni.dirty = false;
        }
    }

    // static methods
    pub fn getDefaultPipelineDesc() sg_pipeline_desc {
        var pipeline_desc = std.mem.zeroes(sg_pipeline_desc);
        pipeline_desc.layout.attrs[0].format = .SG_VERTEXFORMAT_FLOAT2;
        pipeline_desc.layout.attrs[1].format = .SG_VERTEXFORMAT_FLOAT2;
        pipeline_desc.layout.attrs[2].format = .SG_VERTEXFORMAT_UBYTE4N;

        pipeline_desc.index_type = .SG_INDEXTYPE_UINT16;

        pipeline_desc.blend.enabled = true;
        pipeline_desc.blend.src_factor_rgb = .SG_BLENDFACTOR_SRC_ALPHA;
        pipeline_desc.blend.dst_factor_rgb = .SG_BLENDFACTOR_ONE_MINUS_SRC_ALPHA;
        pipeline_desc.blend.src_factor_alpha = .SG_BLENDFACTOR_ONE;
        pipeline_desc.blend.dst_factor_alpha = .SG_BLENDFACTOR_ONE_MINUS_SRC_ALPHA;

        pipeline_desc.depth_stencil.depth_compare_func = .SG_COMPAREFUNC_LESS_EQUAL;
        pipeline_desc.depth_stencil.depth_write_enabled = false;
        // pipeline_desc.blend.depth_format = .SG_PIXELFORMAT_NONE;
        pipeline_desc.rasterizer.cull_mode = .SG_CULLMODE_NONE;

        return pipeline_desc;
    }
};
