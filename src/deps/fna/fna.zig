pub const mojo = @import("mojoshader.zig");
pub const img = @import("fna_image.zig");

pub const Device = @OpaqueType();
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
    none,
    discard,
    no_overwrite,
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
    _,
};

pub const ColorWriteChannels = extern enum(c_int) {
    one = 0,
    red = 1,
    green = 2,
    blue = 4,
    alpha = 8,
    all = 15,
    _,
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
    _,
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
    _,
};

pub const CullMode = extern enum(c_int) {
    none,
    cull_clockwise,
    cull_counter_clockwise,
    _,
};

pub const FillMode = extern enum(c_int) {
    solid,
    wireframe,
    _,
};

pub const TextureAddressMode = extern enum(c_int) {
    wrap,
    clamp,
    mirror,
    _,
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
pub extern fn FNA3D_SetPresentationInterval(device: ?*Device, presentInterval: PresentInterval) void;
pub extern fn FNA3D_Clear(device: ?*Device, options: ClearOptions, color: [*c]Vec4, depth: f32, stencil: i32) void;
pub extern fn FNA3D_DrawIndexedPrimitives(device: ?*Device, primitiveType: PrimitiveType, baseVertex: i32, minVertexIndex: i32, numVertices: i32, startIndex: i32, primitiveCount: i32, indices: ?*Buffer, indexElementSize: IndexElementSize) void;
pub extern fn FNA3D_DrawInstancedPrimitives(device: ?*Device, primitiveType: PrimitiveType, baseVertex: i32, minVertexIndex: i32, numVertices: i32, startIndex: i32, primitiveCount: i32, instanceCount: i32, indices: ?*Buffer, indexElementSize: IndexElementSize) void;
pub extern fn FNA3D_DrawPrimitives(device: ?*Device, primitiveType: PrimitiveType, vertexStart: i32, primitiveCount: i32) void;
pub extern fn FNA3D_DrawUserIndexedPrimitives(device: ?*Device, primitiveType: PrimitiveType, vertexData: ?*c_void, vertexOffset: i32, numVertices: i32, indexData: ?*c_void, indexOffset: i32, indexElementSize: IndexElementSize, primitiveCount: i32) void;
pub extern fn FNA3D_DrawUserPrimitives(device: ?*Device, primitiveType: PrimitiveType, vertexData: ?*c_void, vertexOffset: i32, primitiveCount: i32) void;
pub extern fn FNA3D_SetViewport(device: ?*Device, viewport: [*c]Viewport) void;
pub extern fn FNA3D_SetScissorRect(device: ?*Device, scissor: [*c]Rect) void;
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
pub extern fn FNA3D_ApplyVertexDeclaration(device: ?*Device, vertexDeclaration: [*c]VertexDeclaration, vertexData: ?*c_void, vertexOffset: i32) void;
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
pub extern fn FNA3D_GenVertexBuffer(device: ?*Device, dynamic: u8, usage: BufferUsage, vertexCount: i32, vertexStride: i32) ?*Buffer;
pub extern fn FNA3D_AddDisposeVertexBuffer(device: ?*Device, buffer: ?*Buffer) void;
pub extern fn FNA3D_SetVertexBufferData(device: ?*Device, buffer: ?*Buffer, offsetInBytes: i32, data: ?*c_void, elementCount: i32, elementSizeInBytes: i32, vertexStride: i32, options: SetDataOptions) void;
pub extern fn FNA3D_GetVertexBufferData(device: ?*Device, buffer: ?*Buffer, offsetInBytes: i32, data: ?*c_void, elementCount: i32, elementSizeInBytes: i32, vertexStride: i32) void;
pub extern fn FNA3D_GenIndexBuffer(device: ?*Device, dynamic: u8, usage: BufferUsage, indexCount: i32, indexElementSize: IndexElementSize) ?*Buffer;
pub extern fn FNA3D_AddDisposeIndexBuffer(device: ?*Device, buffer: ?*Buffer) void;
pub extern fn FNA3D_SetIndexBufferData(device: ?*Device, buffer: ?*Buffer, offsetInBytes: i32, data: ?*c_void, dataLength: i32, options: SetDataOptions) void;
pub extern fn FNA3D_GetIndexBufferData(device: ?*Device, buffer: ?*Buffer, offsetInBytes: i32, data: ?*c_void, dataLength: i32) void;
pub extern fn FNA3D_CreateEffect(device: ?*Device, effectCode: [*c]u8, effectCodeLength: u32, effect: [*c]?*Effect, effectData: [*c]?*mojo.Effect) void;
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
pub extern fn FNA3D_GetMaxMultiSampleCount(device: ?*Device) i32;
pub extern fn FNA3D_SetStringMarker(device: ?*Device, text: [*c]const u8) void;
