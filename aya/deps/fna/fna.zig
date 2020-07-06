pub const mojo = @import("mojoshader.zig");
pub const img = @import("fna_image.zig");

pub const Device = struct {
    device: *c_void,

    pub fn init(presentation_params: [*c]PresentationParameters, debug_mode: bool) *Device {
        const debug: u8 = if (debug_mode) 1 else 0;
        return FNA3D_CreateDevice(presentation_params, debug).?;
    }

    pub fn deinit(self: *Device) void {
        FNA3D_DestroyDevice(self);
    }

    pub fn resetBackbuffer(self: *Device, width: i32, height: i32, window: ?*c_void) void {
        var params = PresentationParameters{
            .backBufferWidth = width,
            .backBufferHeight = height,
            .deviceWindowHandle = window,
        };
        FNA3D_ResetBackbuffer(self, &params);
    }

    pub fn applyRasterizerState(self: *Device, rasterizer_state: [*c]RasterizerState) void {
        FNA3D_ApplyRasterizerState(self, rasterizer_state);
    }

    pub fn setBlendState(self: *Device, blend_state: [*c]BlendState) void {
        FNA3D_SetBlendState(self, blend_state);
    }

    pub fn setDepthStencilState(self: *Device, depth_stencil: [*c]DepthStencilState) void {
        FNA3D_SetDepthStencilState(self, depth_stencil);
    }

    pub fn clear(self: *Device, color: *Vec4) void {
        self.clearWithOptions(.all, color, 0, 1);
    }

    pub fn clearWithOptions(self: *Device, options: ClearOptions, color: *Vec4, depth: f32, stencil: i32) void {
        FNA3D_Clear(self, options, color, depth, stencil);
    }

    pub fn setViewport(self: *Device, viewport: [*c]Viewport) void {
        FNA3D_SetViewport(self, viewport);
    }

    pub fn setScissorRect(self: *Device, scissor: *Rect) void {
        FNA3D_SetScissorRect(self, scissor);
    }

    pub fn unSetRenderTarget(self: *Device) void {
        FNA3D_SetRenderTargets(self, null, 0, null, .none);
    }

    pub fn setRenderTarget(self: *Device, render_targets: *RenderTargetBinding, depth_stencil_buffer: ?*Renderbuffer, depth_format: DepthFormat) void {
        FNA3D_SetRenderTargets(self, render_targets, 1, depth_stencil_buffer, depth_format);
    }

    pub fn setRenderTargets(self: *Device, render_targets: [*c]RenderTargetBinding, num_render_targets: i32, depth_stencil_buffer: ?*Renderbuffer, depth_format: DepthFormat) void {
        FNA3D_SetRenderTargets(self, render_targets, num_render_targets, depth_stencil_buffer, depth_format);
    }

    pub fn getBackbufferSize(self: *Device, w: *i32, h: *i32) void {
        FNA3D_GetBackbufferSize(self, w, h);
    }

    pub fn createEffect(self: *Device, effect_code: []const u8, effect: *?*Effect, mojo_effect: *?*mojo.Effect) void {
        FNA3D_CreateEffect(self, &effect_code[0], @intCast(u32, effect_code.len), effect, mojo_effect);
    }

    pub fn setEffectTechnique(self: *Device, effect: ?*Effect, technique: ?*mojo.EffectTechnique) void {
        FNA3D_SetEffectTechnique(self, effect, technique);
    }

    pub fn addDisposeEffect(self: *Device, effect: ?*Effect) void {
        FNA3D_AddDisposeEffect(self, effect);
    }

    pub fn applyEffect(self: *Device, effect: ?*Effect, pass: u32, state_changes: ?*mojo.EffectStateChanges) void {
        FNA3D_ApplyEffect(self, effect, pass, state_changes);
    }

    pub fn supportsNoOverwrite(self: *Device) bool {
        return FNA3D_SupportsNoOverwrite(self) == 1;
    }

    pub fn swapBuffers(self: *Device, override_window_handle: ?*c_void) void {
        FNA3D_SwapBuffers(self, null, null, override_window_handle);
    }

    pub fn genVertexBuffer(self: *Device, dynamic: bool, usage: BufferUsage, vertex_count: i32, vertex_stride: i32) ?*Buffer {
        const is_dynamic: u8 = if (dynamic) 1 else 0;
        return FNA3D_GenVertexBuffer(self, is_dynamic, usage, vertex_count * vertex_stride);
    }

    pub fn addDisposeVertexBuffer(self: *Device, buffer: ?*Buffer) void {
        FNA3D_AddDisposeVertexBuffer(self, buffer);
    }

    pub fn setVertexBufferData(self: *Device, comptime T: type, buffer: ?*Buffer, data: []T, offset_in_bytes: i32, options: SetDataOptions) void {
        FNA3D_SetVertexBufferData(self, buffer, offset_in_bytes, &data[0], @intCast(c_int, @sizeOf(T) * data.len), 1, 1, options);
    }

    pub fn genIndexBuffer(self: *Device, dynamic: bool, usage: BufferUsage, index_count: i32, index_element_size: IndexElementSize) ?*Buffer {
        const is_dynamic: u8 = if (dynamic) 1 else 0;
        const size: i32 = if (index_element_size == .sixteen_bit) @sizeOf(i16) else @sizeOf(i32);
        return FNA3D_GenIndexBuffer(self, is_dynamic, usage, index_count * size);
    }

    pub fn addDisposeIndexBuffer(self: *Device, buffer: ?*Buffer) void {
        FNA3D_AddDisposeIndexBuffer(self, buffer);
    }

    pub fn setIndexBufferData(self: *Device, buffer: ?*Buffer, offset_in_bytes: i32, data: ?*c_void, data_length: i32, options: SetDataOptions) void {
        FNA3D_SetIndexBufferData(self, buffer, offset_in_bytes, data, data_length, options);
    }

    pub fn beginFrame(self: *Device) void {
        FNA3D_BeginFrame(self);
    }

    pub fn applyVertexBufferBindings(self: *Device, bindings: [*c]VertexBufferBinding, num_bindings: i32, bindings_updated: bool, base_vertex: i32) void {
        const updated: u8 = if (bindings_updated) 1 else 0;
        FNA3D_ApplyVertexBufferBindings(self, bindings, num_bindings, updated, base_vertex);
    }

    pub fn drawIndexedPrimitives(self: *Device, primitive_type: PrimitiveType, base_vertex: i32, min_vertex_index: i32, num_vertices: i32, start_index: i32, primitive_count: i32, indices: ?*Buffer, index_element_size: IndexElementSize) void {
        FNA3D_DrawIndexedPrimitives(self, primitive_type, base_vertex, min_vertex_index, num_vertices, start_index, primitive_count, indices, index_element_size);
    }

    pub fn createTexture2D(self: *Device, format: SurfaceFormat, width: i32, height: i32, level_count: i32, is_render_target: bool) ?*Texture {
        const render_target: u8 = if (is_render_target) 1 else 0;
        return FNA3D_CreateTexture2D(self, format, width, height, level_count, render_target);
    }

    pub fn addDisposeTexture(self: *Device, texture: ?*Texture) void {
        FNA3D_AddDisposeTexture(self, texture);
    }

    pub fn setTextureData2D(self: *Device, texture: ?*Texture, format: SurfaceFormat, x: i32, y: i32, w: i32, h: i32, level: i32, data: ?*c_void, data_length: i32) void {
        FNA3D_SetTextureData2D(self, texture, format, x, y, w, h, level, data, data_length);
    }

    pub fn verifySampler(self: *Device, index: i32, texture: ?*Texture, sampler: *SamplerState) void {
        FNA3D_VerifySampler(self, index, texture, sampler);
    }

    pub fn genDepthStencilRenderbuffer(self: *Device, width: i32, height: i32, format: DepthFormat, multi_sample_count: i32) ?*Renderbuffer {
        return FNA3D_GenDepthStencilRenderbuffer(self, width, height, format, multi_sample_count);
    }

    pub fn addDisposeRenderbuffer(self: *Device, renderbuffer: ?*Renderbuffer) void {
        FNA3D_AddDisposeRenderbuffer(self, renderbuffer);
    }
};

pub fn prepareWindowAttributes() c_int {
    return @intCast(c_int, FNA3D_PrepareWindowAttributes());
}

pub fn getDrawableSize(window: ?*c_void, w: *i32, h: *i32) void {
    FNA3D_GetDrawableSize(window, w, h);
}

pub const Texture = @OpaqueType();
pub const Buffer = @OpaqueType();
pub const Renderbuffer = @OpaqueType();
pub const Effect = @OpaqueType();
pub const Query = @OpaqueType();

pub const PresentInterval = extern enum(c_int) {
    default,
    one,
    two,
    immediate,
};

pub const DisplayOrientation = extern enum(c_int) {
    default,
    landscape_left,
    landscape_right,
    portrait,
};

pub const RenderTargetUsage = extern enum(c_int) {
    discard_contents,
    preserve_contents,
    platform_contents,
};

pub const ClearOptions = extern enum(c_int) {
    target = 1,
    depth_buffer = 2,
    stencil = 4,
    all = 1 | 2 | 4,
};

pub const PrimitiveType = extern enum(c_int) {
    triangle_list,
    triangle_strip,
    line_list,
    line_strip,
    point_list_ext,
};

pub const IndexElementSize = extern enum(c_int) {
    sixteen_bit,
    thirty_two_bit,
};

pub const SurfaceFormat = extern enum(c_int) {
    color,
    bgr565,
    bgra5551,
    bgra4444,
    dxt1,
    dxt3,
    dxt5,
    normalized_byte_2,
    normalized_byte_4,
    rgba1010102,
    rg32,
    rgba64,
    alpha8,
    single,
    vector2,
    vector4,
    half_single,
    half_vector2,
    half_vector4,
    hdr_blendable,
    color_rgba_ext,
};

pub const DepthFormat = extern enum(c_int) {
    none,
    d16,
    d24,
    d24s8,
};

pub const CubeMapFace = extern enum(c_int) {
    positive_x,
    netative_x,
    positive_y,
    netative_y,
    positive_z,
    netative_z,
};

pub const BufferUsage = extern enum(c_int) {
    none,
    write_only,
};

pub const SetDataOptions = extern enum(c_int) {
    none, // The SetData can overwrite the portions of existing data
    discard, // The SetData will discard the entire buffer. A pointer to a new memory area is returned and rendering from the previous area do not stall.
    no_overwrite, // The SetData operation will not overwrite existing data. This allows the driver to return immediately from a SetData operation and continue rendering.
};

pub const Blend = extern enum(c_int) {
    one,
    zero,
    source_color,
    inverse_source_color,
    source_alpha,
    inverse_source_alpha,
    destination_color,
    inverse_destination_color,
    destination_alpha,
    inverse_destination_alpha,
    blend_factor,
    inverse_blend_factor,
    source_alpha_saturation,
};

pub const BlendFunction = extern enum(c_int) {
    add,
    subtract,
    reverse_subtract,
    max,
    min,
};

pub const ColorWriteChannels = extern enum(c_int) {
    one = 0,
    red = 1,
    green = 2,
    blue = 4,
    alpha = 8,
    all = 15,
};

pub const StencilOperation = extern enum(c_int) {
    keep,
    zero,
    replace,
    increment,
    decrement,
    increment_saturation,
    decrement_saturation,
    invert,
};

pub const CompareFunction = extern enum(c_int) {
    always,
    never,
    less,
    less_equal,
    equal,
    greater_equal,
    greater,
    not_equal,
};

pub const CullMode = extern enum(c_int) {
    none,
    cull_clockwise,
    cull_counter_clockwise,
};

pub const FillMode = extern enum(c_int) {
    solid,
    wireframe,
};

pub const TextureAddressMode = extern enum(c_int) {
    wrap,
    clamp,
    mirror,
};

pub const TextureFilter = extern enum(c_int) {
    linear,
    point,
    anisotropic,
    linear_mippoint,
    point_miplinear,
    minlinear_magpoint_miplinear,
    minlinear_magpoint_mippoint,
    minpoint_maglinear_miplinear,
    minpoint_maglinear_mippoint,
};

pub const VertexElementFormat = extern enum(c_int) {
    single,
    vector2,
    vector3,
    vector4,
    color,
    byte4,
    short2,
    short4,
    normalized_short2,
    normalized_short4,
    half_vector2,
    half_vector4,
};

pub const VertexElementUsage = extern enum(c_int) {
    position,
    color,
    texture_coordinate,
    normal,
    binormal,
    tangent,
    blend_indices,
    blend_weight,
    depth,
    fog,
    point_size,
    sample,
    tesselate_factor,
};

pub const Color = extern struct {
    r: u8,
    g: u8,
    b: u8,
    a: u8,
};

pub const Rect = extern struct {
    x: i32 = 0,
    y: i32 = 0,
    w: i32,
    h: i32,
};

pub const Vec4 = extern struct {
    x: f32,
    y: f32,
    z: f32,
    w: f32,
};

pub const Viewport = extern struct {
    x: i32 = 0,
    y: i32 = 0,
    w: i32,
    h: i32,
    minDepth: f32 = 0,
    maxDepth: f32 = 1,
};

pub const PresentationParameters = extern struct {
    backBufferWidth: i32,
    backBufferHeight: i32,
    backBufferFormat: SurfaceFormat = .color,
    multiSampleCount: i32 = 0,
    deviceWindowHandle: ?*c_void,
    isFullScreen: u8 = 0,
    depthStencilFormat: DepthFormat = .d24s8,
    presentationInterval: PresentInterval = .default,
    displayOrientation: DisplayOrientation = .default,
    renderTargetUsage: RenderTargetUsage = .platform_contents,
};

// default BlendState is alpha blend
pub const BlendState = extern struct {
    colorSourceBlend: Blend = .source_alpha,
    colorDestinationBlend: Blend = .inverse_source_alpha,
    colorBlendFunction: BlendFunction = .add,
    alphaSourceBlend: Blend = .source_alpha,
    alphaDestinationBlend: Blend = .inverse_source_alpha,
    alphaBlendFunction: BlendFunction = .add,
    colorWriteEnable: ColorWriteChannels = .all,
    colorWriteEnable1: ColorWriteChannels = .all,
    colorWriteEnable2: ColorWriteChannels = .all,
    colorWriteEnable3: ColorWriteChannels = .all,
    blendFactor: Color = Color{ .r = 255, .g = 255, .b = 255, .a = 255 },
    multiSampleMask: i32 = -1,
};

pub const DepthStencilState = extern struct {
    depthBufferEnable: u8 = 0,
    depthBufferWriteEnable: u8 = 0,
    depthBufferFunction: CompareFunction = .always,
    stencilEnable: u8 = 0,
    stencilMask: i32 = 0,
    stencilWriteMask: i32 = 0,
    twoSidedStencilMode: u8 = 0,
    stencilFail: StencilOperation = .keep,
    stencilDepthBufferFail: StencilOperation = .keep,
    stencilPass: StencilOperation = .keep,
    stencilFunction: CompareFunction = .equal,
    ccwStencilFail: StencilOperation = .keep,
    ccwStencilDepthBufferFail: StencilOperation = .keep,
    ccwStencilPass: StencilOperation = .keep,
    ccwStencilFunction: CompareFunction = .always,
    referenceStencil: i32 = 1,
};

pub const RasterizerState = extern struct {
    fillMode: FillMode = .solid,
    cullMode: CullMode = .none,
    depthBias: f32 = 0,
    slopeScaleDepthBias: f32 = 0,
    scissorTestEnable: u8 = 0,
    multiSampleAntiAlias: u8 = 0,
};

pub const SamplerState = extern struct {
    filter: TextureFilter = .point,
    addressU: TextureAddressMode = .clamp,
    addressV: TextureAddressMode = .clamp,
    addressW: TextureAddressMode = .clamp,
    mipMapLevelOfDetailBias: f32 = 0,
    maxAnisotropy: i32 = 4,
    maxMipLevel: i32 = 0,
};

pub const VertexElement = extern struct {
    offset: i32,
    vertexElementFormat: VertexElementFormat,
    vertexElementUsage: VertexElementUsage,
    usageIndex: i32,
};

pub const VertexDeclaration = extern struct {
    vertexStride: i32,
    elementCount: i32,
    elements: [*c]VertexElement,
};

pub const VertexBufferBinding = extern struct {
    vertexBuffer: ?*Buffer,
    vertexDeclaration: VertexDeclaration,
    vertexOffset: i32 = 0,
    instanceFrequency: i32 = 0,
};

pub const RenderTargetBinding = extern struct {
    type: u8 = 0, // 2d = 0, cube = 1
    unnamed: extern union {
        twod: extern struct {
            width: i32,
            height: i32,
        },
        cube: extern struct {
            size: i32,
            face: CubeMapFace,
        },
    },
    levelCount: i32 = 1,
    multiSampleCount: i32 = 0,
    texture: ?*Texture = null,
    colorBuffer: ?*Renderbuffer = null,
};

pub const LogFunc = ?fn ([*c]const u8) callconv(.C) void;

pub extern fn FNA3D_LinkedVersion() u32;
pub extern fn FNA3D_HookLogFunctions(info: LogFunc, warn: LogFunc, @"error": LogFunc) void;
pub extern fn FNA3D_PrepareWindowAttributes() u32;
pub extern fn FNA3D_GetDrawableSize(window: ?*c_void, x: [*c]i32, y: [*c]i32) void;
pub extern fn FNA3D_CreateDevice(presentationParameters: [*c]PresentationParameters, debugMode: u8) ?*Device;
pub extern fn FNA3D_DestroyDevice(device: ?*Device) void;
pub extern fn FNA3D_BeginFrame(device: ?*Device) void;
pub extern fn FNA3D_SwapBuffers(device: ?*Device, sourceRectangle: [*c]Rect, destinationRectangle: [*c]Rect, overrideWindowHandle: ?*c_void) void;
pub extern fn FNA3D_Clear(device: ?*Device, options: ClearOptions, color: [*c]const Vec4, depth: f32, stencil: i32) void;
pub extern fn FNA3D_DrawIndexedPrimitives(device: ?*Device, primitiveType: PrimitiveType, baseVertex: i32, minVertexIndex: i32, numVertices: i32, startIndex: i32, primitiveCount: i32, indices: ?*Buffer, indexElementSize: IndexElementSize) void;
pub extern fn FNA3D_DrawInstancedPrimitives(device: ?*Device, primitiveType: PrimitiveType, baseVertex: i32, minVertexIndex: i32, numVertices: i32, startIndex: i32, primitiveCount: i32, instanceCount: i32, indices: ?*Buffer, indexElementSize: IndexElementSize) void;
pub extern fn FNA3D_DrawPrimitives(device: ?*Device, primitiveType: PrimitiveType, vertexStart: i32, primitiveCount: i32) void;
pub extern fn FNA3D_SetViewport(device: ?*Device, viewport: [*c]Viewport) void;
pub extern fn FNA3D_SetScissorRect(device: ?*Device, scissor: [*c]const Rect) void;
pub extern fn FNA3D_GetBlendFactor(device: ?*Device, blendFactor: [*c]Color) void;
pub extern fn FNA3D_SetBlendFactor(device: ?*Device, blendFactor: [*c]Color) void;
pub extern fn FNA3D_GetMultiSampleMask(device: ?*Device) i32;
pub extern fn FNA3D_SetMultiSampleMask(device: ?*Device, mask: i32) void;
pub extern fn FNA3D_GetReferenceStencil(device: ?*Device) i32;
pub extern fn FNA3D_SetReferenceStencil(device: ?*Device, ref: i32) void;
pub extern fn FNA3D_SetBlendState(device: ?*Device, blendState: [*c]BlendState) void;
pub extern fn FNA3D_SetDepthStencilState(device: ?*Device, depthStencilState: [*c]DepthStencilState) void;
pub extern fn FNA3D_ApplyRasterizerState(device: ?*Device, rasterizerState: [*c]RasterizerState) void;
pub extern fn FNA3D_VerifySampler(device: ?*Device, index: i32, texture: ?*Texture, sampler: [*c]SamplerState) void;
pub extern fn FNA3D_VerifyVertexSampler(device: ?*Device, index: i32, texture: ?*Texture, sampler: [*c]SamplerState) void;
pub extern fn FNA3D_ApplyVertexBufferBindings(device: ?*Device, bindings: [*c]VertexBufferBinding, numBindings: i32, bindingsUpdated: u8, baseVertex: i32) void;
pub extern fn FNA3D_SetRenderTargets(device: ?*Device, renderTargets: [*c]RenderTargetBinding, numRenderTargets: i32, depthStencilBuffer: ?*Renderbuffer, depthFormat: DepthFormat) void;
pub extern fn FNA3D_ResolveTarget(device: ?*Device, target: [*c]RenderTargetBinding) void;
pub extern fn FNA3D_ResetBackbuffer(device: ?*Device, presentationParameters: [*c]PresentationParameters) void;
pub extern fn FNA3D_ReadBackbuffer(device: ?*Device, x: i32, y: i32, w: i32, h: i32, data: ?*c_void, dataLength: i32) void;
pub extern fn FNA3D_GetBackbufferSize(device: ?*Device, w: [*c]i32, h: [*c]i32) void;
pub extern fn FNA3D_GetBackbufferSurfaceFormat(device: ?*Device) SurfaceFormat;
pub extern fn FNA3D_GetBackbufferDepthFormat(device: ?*Device) DepthFormat;
pub extern fn FNA3D_GetBackbufferMultiSampleCount(device: ?*Device) i32;
pub extern fn FNA3D_CreateTexture2D(device: ?*Device, format: SurfaceFormat, width: i32, height: i32, levelCount: i32, isRenderTarget: u8) ?*Texture;
pub extern fn FNA3D_CreateTexture3D(device: ?*Device, format: SurfaceFormat, width: i32, height: i32, depth: i32, levelCount: i32) ?*Texture;
pub extern fn FNA3D_CreateTextureCube(device: ?*Device, format: SurfaceFormat, size: i32, levelCount: i32, isRenderTarget: u8) ?*Texture;
pub extern fn FNA3D_AddDisposeTexture(device: ?*Device, texture: ?*Texture) void;
pub extern fn FNA3D_SetTextureData2D(device: ?*Device, texture: ?*Texture, format: SurfaceFormat, x: i32, y: i32, w: i32, h: i32, level: i32, data: ?*c_void, dataLength: i32) void;
pub extern fn FNA3D_SetTextureData3D(device: ?*Device, texture: ?*Texture, format: SurfaceFormat, x: i32, y: i32, z: i32, w: i32, h: i32, d: i32, level: i32, data: ?*c_void, dataLength: i32) void;
pub extern fn FNA3D_SetTextureDataCube(device: ?*Device, texture: ?*Texture, format: SurfaceFormat, x: i32, y: i32, w: i32, h: i32, cubeMapFace: CubeMapFace, level: i32, data: ?*c_void, dataLength: i32) void;
pub extern fn FNA3D_SetTextureDataYUV(device: ?*Device, y: ?*Texture, u: ?*Texture, v: ?*Texture, yWidth: i32, yHeight: i32, uvWidth: i32, uvHeight: i32, data: ?*c_void, dataLength: i32) void;
pub extern fn FNA3D_GetTextureData2D(device: ?*Device, texture: ?*Texture, format: SurfaceFormat, x: i32, y: i32, w: i32, h: i32, level: i32, data: ?*c_void, dataLength: i32) void;
pub extern fn FNA3D_GetTextureData3D(device: ?*Device, texture: ?*Texture, format: SurfaceFormat, x: i32, y: i32, z: i32, w: i32, h: i32, d: i32, level: i32, data: ?*c_void, dataLength: i32) void;
pub extern fn FNA3D_GetTextureDataCube(device: ?*Device, texture: ?*Texture, format: SurfaceFormat, x: i32, y: i32, w: i32, h: i32, cubeMapFace: CubeMapFace, level: i32, data: ?*c_void, dataLength: i32) void;
pub extern fn FNA3D_GenColorRenderbuffer(device: ?*Device, width: i32, height: i32, format: SurfaceFormat, multiSampleCount: i32, texture: ?*Texture) ?*Renderbuffer;
pub extern fn FNA3D_GenDepthStencilRenderbuffer(device: ?*Device, width: i32, height: i32, format: DepthFormat, multiSampleCount: i32) ?*Renderbuffer;
pub extern fn FNA3D_AddDisposeRenderbuffer(device: ?*Device, renderbuffer: ?*Renderbuffer) void;
pub extern fn FNA3D_GenVertexBuffer(device: ?*Device, dynamic: u8, usage: BufferUsage, size_in_bytes: i32) ?*Buffer;
pub extern fn FNA3D_AddDisposeVertexBuffer(device: ?*Device, buffer: ?*Buffer) void;
pub extern fn FNA3D_SetVertexBufferData(device: ?*Device, buffer: ?*Buffer, offsetInBytes: i32, data: ?*c_void, elementCount: i32, elementSizeInBytes: i32, vertexStride: i32, options: SetDataOptions) void;
pub extern fn FNA3D_GetVertexBufferData(device: ?*Device, buffer: ?*Buffer, offsetInBytes: i32, data: ?*c_void, elementCount: i32, elementSizeInBytes: i32, vertexStride: i32) void;
pub extern fn FNA3D_GenIndexBuffer(device: ?*Device, dynamic: u8, usage: BufferUsage, size_in_bytes: i32) ?*Buffer;
pub extern fn FNA3D_AddDisposeIndexBuffer(device: ?*Device, buffer: ?*Buffer) void;
pub extern fn FNA3D_SetIndexBufferData(device: ?*Device, buffer: ?*Buffer, offsetInBytes: i32, data: ?*c_void, dataLength: i32, options: SetDataOptions) void;
pub extern fn FNA3D_GetIndexBufferData(device: ?*Device, buffer: ?*Buffer, offsetInBytes: i32, data: ?*c_void, dataLength: i32) void;
pub extern fn FNA3D_CreateEffect(device: ?*Device, effectCode: [*c]const u8, effectCodeLength: u32, effect: *?*Effect, effectData: *?*mojo.Effect) void;
pub extern fn FNA3D_CloneEffect(device: ?*Device, cloneSource: ?*Effect, effect: [*c]?*Effect, effectData: [*c]?*mojo.Effect) void;
pub extern fn FNA3D_AddDisposeEffect(device: ?*Device, effect: ?*Effect) void;
pub extern fn FNA3D_SetEffectTechnique(device: ?*Device, effect: ?*Effect, technique: ?*mojo.EffectTechnique) void;
pub extern fn FNA3D_ApplyEffect(device: ?*Device, effect: ?*Effect, pass: u32, stateChanges: ?*mojo.EffectStateChanges) void;
pub extern fn FNA3D_BeginPassRestore(device: ?*Device, effect: ?*Effect, stateChanges: ?*mojo.EffectStateChanges) void;
pub extern fn FNA3D_EndPassRestore(device: ?*Device, effect: ?*Effect) void;
pub extern fn FNA3D_CreateQuery(device: ?*Device) ?*Query;
pub extern fn FNA3D_AddDisposeQuery(device: ?*Device, query: ?*Query) void;
pub extern fn FNA3D_QueryBegin(device: ?*Device, query: ?*Query) void;
pub extern fn FNA3D_QueryEnd(device: ?*Device, query: ?*Query) void;
pub extern fn FNA3D_QueryComplete(device: ?*Device, query: ?*Query) u8;
pub extern fn FNA3D_QueryPixelCount(device: ?*Device, query: ?*Query) i32;
pub extern fn FNA3D_SupportsDXT1(device: ?*Device) u8;
pub extern fn FNA3D_SupportsS3TC(device: ?*Device) u8;
pub extern fn FNA3D_SupportsHardwareInstancing(device: ?*Device) u8;
pub extern fn FNA3D_SupportsNoOverwrite(device: ?*Device) u8;
pub extern fn FNA3D_GetMaxTextureSlots(device: ?*Device, textures: [*c]i32, vertexTextures: [*c]i32) void;
pub extern fn FNA3D_GetMaxMultiSampleCount(device: ?*Device, SurfaceFormat: format, multi_sample_count: i32) i32;
pub extern fn FNA3D_SetStringMarker(device: ?*Device, text: [*c]const u8) void;
