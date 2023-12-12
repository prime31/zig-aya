const std = @import("std");

// Injected
pub const SubmissionIndex = u64;

pub const InstanceBackend = enum(u32) {
    all = 0,
    vulkan = 1,
    gl = 2,
    metal = 4,
    dx12 = 8,
    dx11 = 16,
    browser_web_gpu = 32,
    primary = 45,
    secondary = 18,
};

pub fn createInstance() Instance {
    return wgpuCreateInstance(null);
}
extern fn wgpuCreateInstance(descriptor: [*c]const InstanceDescriptor) Instance;

// Descriptors
pub const InstanceEnumerateAdapterOptions = extern struct {
    next_in_chain: [*c]const ChainedStruct = @import("std").mem.zeroes([*c]const ChainedStruct),
    backends: InstanceBackend = @import("std").mem.zeroes(InstanceBackend),
};

pub const AdapterProperties = extern struct {
    next_in_chain: [*c]ChainedStructOut = @import("std").mem.zeroes([*c]ChainedStructOut),
    vendor_id: u32 = @import("std").mem.zeroes(u32),
    vendor_name: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
    architecture: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
    device_id: u32 = @import("std").mem.zeroes(u32),
    name: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
    driver_description: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
    adapter_type: AdapterType = @import("std").mem.zeroes(AdapterType),
    backend_type: BackendType = @import("std").mem.zeroes(BackendType),
};

pub const BindGroupEntry = extern struct {
    next_in_chain: [*c]const ChainedStruct = @import("std").mem.zeroes([*c]const ChainedStruct),
    binding: u32 = @import("std").mem.zeroes(u32),
    buffer: ?Buffer = @import("std").mem.zeroes(?Buffer),
    offset: u64 = @import("std").mem.zeroes(u64),
    size: u64 = @import("std").mem.zeroes(u64),
    sampler: ?Sampler = @import("std").mem.zeroes(?Sampler),
    texture_view: ?TextureView = @import("std").mem.zeroes(?TextureView),
};

pub const BufferBindingLayout = extern struct {
    next_in_chain: [*c]const ChainedStruct = @import("std").mem.zeroes([*c]const ChainedStruct),
    type: BufferBindingType = @import("std").mem.zeroes(BufferBindingType),
    has_dynamic_offset: bool = @import("std").mem.zeroes(bool),
    min_binding_size: u64 = @import("std").mem.zeroes(u64),
};

pub const BufferDescriptor = extern struct {
    next_in_chain: [*c]const ChainedStruct = @import("std").mem.zeroes([*c]const ChainedStruct),
    label: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
    usage: BufferUsage = @import("std").mem.zeroes(BufferUsage),
    size: u64 = @import("std").mem.zeroes(u64),
    mapped_at_creation: bool = @import("std").mem.zeroes(bool),
};

pub const CommandBufferDescriptor = extern struct {
    next_in_chain: [*c]const ChainedStruct = @import("std").mem.zeroes([*c]const ChainedStruct),
    label: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
};

pub const CommandEncoderDescriptor = extern struct {
    next_in_chain: [*c]const ChainedStruct = @import("std").mem.zeroes([*c]const ChainedStruct),
    label: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
};

pub const CompilationMessage = extern struct {
    next_in_chain: [*c]const ChainedStruct = @import("std").mem.zeroes([*c]const ChainedStruct),
    message: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
    type: CompilationMessageType = @import("std").mem.zeroes(CompilationMessageType),
    line_num: u64 = @import("std").mem.zeroes(u64),
    line_pos: u64 = @import("std").mem.zeroes(u64),
    offset: u64 = @import("std").mem.zeroes(u64),
    length: u64 = @import("std").mem.zeroes(u64),
    utf16_line_pos: u64 = @import("std").mem.zeroes(u64),
    utf16_offset: u64 = @import("std").mem.zeroes(u64),
    utf16_length: u64 = @import("std").mem.zeroes(u64),
};

pub const ConstantEntry = extern struct {
    next_in_chain: [*c]const ChainedStruct = @import("std").mem.zeroes([*c]const ChainedStruct),
    key: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
    value: f64 = @import("std").mem.zeroes(f64),
};

pub const InstanceDescriptor = extern struct {
    next_in_chain: [*c]const ChainedStruct = @import("std").mem.zeroes([*c]const ChainedStruct),
};

pub const MultisampleState = extern struct {
    next_in_chain: [*c]const ChainedStruct = @import("std").mem.zeroes([*c]const ChainedStruct),
    count: u32 = 1,
    mask: u32 = 0xffff_ffff,
    alpha_to_coverage_enabled: bool = @import("std").mem.zeroes(bool),
};

pub const PipelineLayoutDescriptor = extern struct {
    next_in_chain: [*c]const ChainedStruct = @import("std").mem.zeroes([*c]const ChainedStruct),
    label: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
    bind_group_layout_count: usize = @import("std").mem.zeroes(usize),
    bind_group_layouts: [*c]const BindGroupLayout = @import("std").mem.zeroes([*c]const BindGroupLayout),
};

pub const PrimitiveState = extern struct {
    next_in_chain: [*c]const ChainedStruct = @import("std").mem.zeroes([*c]const ChainedStruct),
    topology: PrimitiveTopology = .triangle_list,
    strip_index_format: IndexFormat = @import("std").mem.zeroes(IndexFormat),
    front_face: FrontFace = @import("std").mem.zeroes(FrontFace),
    cull_mode: CullMode = @import("std").mem.zeroes(CullMode),
};

pub const QuerySetDescriptor = extern struct {
    next_in_chain: [*c]const ChainedStruct = @import("std").mem.zeroes([*c]const ChainedStruct),
    label: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
    type: QueryType = @import("std").mem.zeroes(QueryType),
    count: u32 = @import("std").mem.zeroes(u32),
};

pub const QueueDescriptor = extern struct {
    next_in_chain: [*c]const ChainedStruct = @import("std").mem.zeroes([*c]const ChainedStruct),
    label: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
};

pub const RenderBundleDescriptor = extern struct {
    next_in_chain: [*c]const ChainedStruct = @import("std").mem.zeroes([*c]const ChainedStruct),
    label: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
};

pub const RenderBundleEncoderDescriptor = extern struct {
    next_in_chain: [*c]const ChainedStruct = @import("std").mem.zeroes([*c]const ChainedStruct),
    label: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
    color_format_count: usize = @import("std").mem.zeroes(usize),
    color_formats: [*c]const TextureFormat = @import("std").mem.zeroes([*c]const TextureFormat),
    depth_stencil_format: TextureFormat = @import("std").mem.zeroes(TextureFormat),
    sample_count: u32 = @import("std").mem.zeroes(u32),
    depth_read_only: bool = @import("std").mem.zeroes(bool),
    stencil_read_only: bool = @import("std").mem.zeroes(bool),
};

pub const RequestAdapterOptions = extern struct {
    next_in_chain: [*c]const ChainedStruct = @import("std").mem.zeroes([*c]const ChainedStruct),
    compatible_surface: ?Surface = @import("std").mem.zeroes(?Surface),
    power_preference: PowerPreference = @import("std").mem.zeroes(PowerPreference),
    backend_type: BackendType = @import("std").mem.zeroes(BackendType),
    force_fallback_adapter: bool = @import("std").mem.zeroes(bool),
};

pub const SamplerBindingLayout = extern struct {
    next_in_chain: [*c]const ChainedStruct = @import("std").mem.zeroes([*c]const ChainedStruct),
    type: SamplerBindingType = .filtering,
};

pub const SamplerDescriptor = extern struct {
    next_in_chain: [*c]const ChainedStruct = @import("std").mem.zeroes([*c]const ChainedStruct),
    label: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
    address_mode_u: AddressMode = .clamp_to_edge,
    address_mode_v: AddressMode = .clamp_to_edge,
    address_mode_w: AddressMode = .clamp_to_edge,
    mag_filter: FilterMode = @import("std").mem.zeroes(FilterMode),
    min_filter: FilterMode = @import("std").mem.zeroes(FilterMode),
    mipmap_filter: MipmapFilterMode = @import("std").mem.zeroes(MipmapFilterMode),
    lod_min_clamp: f32 = @import("std").mem.zeroes(f32),
    lod_max_clamp: f32 = 32.0,
    compare: CompareFunction = @import("std").mem.zeroes(CompareFunction),
    max_anisotropy: u16 = 1,
};

pub const ShaderModuleCompilationHint = extern struct {
    next_in_chain: [*c]const ChainedStruct = @import("std").mem.zeroes([*c]const ChainedStruct),
    entry_point: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
    layout: ?PipelineLayout = @import("std").mem.zeroes(?PipelineLayout),
};

pub const StorageTextureBindingLayout = extern struct {
    next_in_chain: [*c]const ChainedStruct = @import("std").mem.zeroes([*c]const ChainedStruct),
    access: StorageTextureAccess = @import("std").mem.zeroes(StorageTextureAccess),
    format: TextureFormat = @import("std").mem.zeroes(TextureFormat),
    view_dimension: TextureViewDimension = @import("std").mem.zeroes(TextureViewDimension),
};

pub const SurfaceCapabilities = extern struct {
    next_in_chain: [*c]ChainedStructOut = @import("std").mem.zeroes([*c]ChainedStructOut),
    format_count: usize = @import("std").mem.zeroes(usize),
    formats: [*c]TextureFormat = @import("std").mem.zeroes([*c]TextureFormat),
    present_mode_count: usize = @import("std").mem.zeroes(usize),
    present_modes: [*c]PresentMode = @import("std").mem.zeroes([*c]PresentMode),
    alpha_mode_count: usize = @import("std").mem.zeroes(usize),
    alpha_modes: [*c]CompositeAlphaMode = @import("std").mem.zeroes([*c]CompositeAlphaMode),
};

pub const SurfaceConfiguration = extern struct {
    next_in_chain: [*c]const ChainedStruct = @import("std").mem.zeroes([*c]const ChainedStruct),
    device: ?Device = @import("std").mem.zeroes(?Device),
    format: TextureFormat = @import("std").mem.zeroes(TextureFormat),
    usage: TextureUsage = @import("std").mem.zeroes(TextureUsage),
    view_format_count: usize = @import("std").mem.zeroes(usize),
    view_formats: [*c]const TextureFormat = @import("std").mem.zeroes([*c]const TextureFormat),
    alpha_mode: CompositeAlphaMode = @import("std").mem.zeroes(CompositeAlphaMode),
    width: u32 = @import("std").mem.zeroes(u32),
    height: u32 = @import("std").mem.zeroes(u32),
    present_mode: PresentMode = @import("std").mem.zeroes(PresentMode),
};

pub const SurfaceDescriptor = extern struct {
    next_in_chain: [*c]const ChainedStruct = @import("std").mem.zeroes([*c]const ChainedStruct),
    label: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
};

pub const TextureBindingLayout = extern struct {
    next_in_chain: [*c]const ChainedStruct = @import("std").mem.zeroes([*c]const ChainedStruct),
    sample_type: TextureSampleType = .float,
    view_dimension: TextureViewDimension = .dim_2d,
    multisampled: bool = false,
};

pub const TextureDataLayout = extern struct {
    next_in_chain: [*c]const ChainedStruct = @import("std").mem.zeroes([*c]const ChainedStruct),
    offset: u64 = @import("std").mem.zeroes(u64),
    bytes_per_row: u32 = @import("std").mem.zeroes(u32),
    rows_per_image: u32 = @import("std").mem.zeroes(u32),
};

pub const TextureViewDescriptor = extern struct {
    next_in_chain: [*c]const ChainedStruct = @import("std").mem.zeroes([*c]const ChainedStruct),
    label: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
    format: TextureFormat = @import("std").mem.zeroes(TextureFormat),
    dimension: TextureViewDimension = @import("std").mem.zeroes(TextureViewDimension),
    base_mip_level: u32 = @import("std").mem.zeroes(u32),
    mip_level_count: u32 = 0xffff_ffff,
    base_array_layer: u32 = @import("std").mem.zeroes(u32),
    array_layer_count: u32 = 0xffff_ffff,
    aspect: TextureAspect = @import("std").mem.zeroes(TextureAspect),
};

pub const BindGroupDescriptor = extern struct {
    next_in_chain: [*c]const ChainedStruct = @import("std").mem.zeroes([*c]const ChainedStruct),
    label: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
    layout: ?BindGroupLayout = @import("std").mem.zeroes(?BindGroupLayout),
    entry_count: usize = @import("std").mem.zeroes(usize),
    entries: [*c]const BindGroupEntry = @import("std").mem.zeroes([*c]const BindGroupEntry),
};

pub const BindGroupLayoutEntry = extern struct {
    next_in_chain: [*c]const ChainedStruct = @import("std").mem.zeroes([*c]const ChainedStruct),
    binding: u32 = @import("std").mem.zeroes(u32),
    visibility: ShaderStage = @import("std").mem.zeroes(ShaderStage),
    buffer: BufferBindingLayout = @import("std").mem.zeroes(BufferBindingLayout),
    sampler: SamplerBindingLayout = @import("std").mem.zeroes(SamplerBindingLayout),
    texture: TextureBindingLayout = @import("std").mem.zeroes(TextureBindingLayout),
    storage_texture: StorageTextureBindingLayout = @import("std").mem.zeroes(StorageTextureBindingLayout),
};

pub const CompilationInfo = extern struct {
    next_in_chain: [*c]const ChainedStruct = @import("std").mem.zeroes([*c]const ChainedStruct),
    message_count: usize = @import("std").mem.zeroes(usize),
    messages: [*c]const CompilationMessage = @import("std").mem.zeroes([*c]const CompilationMessage),
};

pub const ComputePassDescriptor = extern struct {
    next_in_chain: [*c]const ChainedStruct = @import("std").mem.zeroes([*c]const ChainedStruct),
    label: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
    timestamp_writes: [*c]const ComputePassTimestampWrites = @import("std").mem.zeroes([*c]const ComputePassTimestampWrites),
};

pub const DepthStencilState = extern struct {
    next_in_chain: [*c]const ChainedStruct = null,
    format: TextureFormat = @import("std").mem.zeroes(TextureFormat),
    depth_write_enabled: bool = false,
    depth_compare: CompareFunction = .always,
    stencil_front: StencilFaceState = .{},
    stencil_back: StencilFaceState = .{},
    stencil_read_mask: u32 = 0xffff_ffff,
    stencil_write_mask: u32 = 0xffff_ffff,
    depth_bias: i32 = 0,
    depth_bias_slope_scale: f32 = 0.0,
    depth_bias_clamp: f32 = 0.0,
};

pub const ImageCopyBuffer = extern struct {
    next_in_chain: [*c]const ChainedStruct = @import("std").mem.zeroes([*c]const ChainedStruct),
    layout: TextureDataLayout = @import("std").mem.zeroes(TextureDataLayout),
    buffer: Buffer = @import("std").mem.zeroes(Buffer),
};

pub const ImageCopyTexture = extern struct {
    next_in_chain: [*c]const ChainedStruct = @import("std").mem.zeroes([*c]const ChainedStruct),
    texture: ?Texture = @import("std").mem.zeroes(?Texture),
    mip_level: u32 = @import("std").mem.zeroes(u32),
    origin: Origin3D = @import("std").mem.zeroes(Origin3D),
    aspect: TextureAspect = @import("std").mem.zeroes(TextureAspect),
};

pub const ProgrammableStageDescriptor = extern struct {
    next_in_chain: [*c]const ChainedStruct = @import("std").mem.zeroes([*c]const ChainedStruct),
    module: ShaderModule = @import("std").mem.zeroes(ShaderModule),
    entry_point: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
    constant_count: usize = @import("std").mem.zeroes(usize),
    constants: [*c]const ConstantEntry = @import("std").mem.zeroes([*c]const ConstantEntry),
};

pub const RenderPassColorAttachment = extern struct {
    next_in_chain: [*c]const ChainedStruct = @import("std").mem.zeroes([*c]const ChainedStruct),
    view: ?TextureView = @import("std").mem.zeroes(?TextureView),
    resolve_target: ?TextureView = @import("std").mem.zeroes(?TextureView),
    load_op: LoadOp = @import("std").mem.zeroes(LoadOp),
    store_op: StoreOp = @import("std").mem.zeroes(StoreOp),
    clear_value: Color = @import("std").mem.zeroes(Color),
};

pub const RequiredLimits = extern struct {
    next_in_chain: [*c]const ChainedStruct = @import("std").mem.zeroes([*c]const ChainedStruct),
    limits: Limits = @import("std").mem.zeroes(Limits),
};

pub const ShaderModuleDescriptor = extern struct {
    next_in_chain: [*c]const ChainedStruct = @import("std").mem.zeroes([*c]const ChainedStruct),
    label: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
    hint_count: usize = @import("std").mem.zeroes(usize),
    hints: [*c]const ShaderModuleCompilationHint = @import("std").mem.zeroes([*c]const ShaderModuleCompilationHint),
};

pub const SupportedLimits = extern struct {
    next_in_chain: [*c]ChainedStructOut = @import("std").mem.zeroes([*c]ChainedStructOut),
    limits: Limits = @import("std").mem.zeroes(Limits),
};

pub const TextureDescriptor = extern struct {
    next_in_chain: [*c]const ChainedStruct = @import("std").mem.zeroes([*c]const ChainedStruct),
    label: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
    usage: TextureUsage = @import("std").mem.zeroes(TextureUsage),
    dimension: TextureDimension = .dim_2d,
    size: Extent3D = @import("std").mem.zeroes(Extent3D),
    format: TextureFormat = @import("std").mem.zeroes(TextureFormat),
    mip_level_count: u32 = 1,
    sample_count: u32 = 1,
    view_format_count: usize = @import("std").mem.zeroes(usize),
    view_formats: [*c]const TextureFormat = @import("std").mem.zeroes([*c]const TextureFormat),
};

pub const BindGroupLayoutDescriptor = extern struct {
    next_in_chain: [*c]const ChainedStruct = @import("std").mem.zeroes([*c]const ChainedStruct),
    label: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
    entry_count: usize = @import("std").mem.zeroes(usize),
    entries: [*c]const BindGroupLayoutEntry = @import("std").mem.zeroes([*c]const BindGroupLayoutEntry),
};

pub const ColorTargetState = extern struct {
    next_in_chain: [*c]const ChainedStruct = @import("std").mem.zeroes([*c]const ChainedStruct),
    format: TextureFormat,
    blend: [*c]const BlendState = @import("std").mem.zeroes([*c]const BlendState),
    write_mask: ColorWriteMask = ColorWriteMask.all,
};

pub const ComputePipelineDescriptor = extern struct {
    next_in_chain: [*c]const ChainedStruct = @import("std").mem.zeroes([*c]const ChainedStruct),
    label: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
    layout: PipelineLayout = @import("std").mem.zeroes(PipelineLayout),
    compute: ProgrammableStageDescriptor = @import("std").mem.zeroes(ProgrammableStageDescriptor),
};

pub const DeviceDescriptor = extern struct {
    next_in_chain: [*c]const ChainedStruct = @import("std").mem.zeroes([*c]const ChainedStruct),
    label: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
    required_feature_count: usize = @import("std").mem.zeroes(usize),
    required_features: [*c]const FeatureName = @import("std").mem.zeroes([*c]const FeatureName),
    required_limits: [*c]const RequiredLimits = @import("std").mem.zeroes([*c]const RequiredLimits),
    default_queue: QueueDescriptor = @import("std").mem.zeroes(QueueDescriptor),
    device_lost_callback: ?DeviceLostCallback = @import("std").mem.zeroes(?DeviceLostCallback),
    device_lost_userdata: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
};

pub const RenderPassDescriptor = extern struct {
    next_in_chain: [*c]const ChainedStruct = @import("std").mem.zeroes([*c]const ChainedStruct),
    label: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
    color_attachment_count: usize = @import("std").mem.zeroes(usize),
    color_attachments: [*c]const RenderPassColorAttachment = @import("std").mem.zeroes([*c]const RenderPassColorAttachment),
    depth_stencil_attachment: [*c]const RenderPassDepthStencilAttachment = @import("std").mem.zeroes([*c]const RenderPassDepthStencilAttachment),
    occlusion_query_set: ?QuerySet = @import("std").mem.zeroes(?QuerySet),
    timestamp_writes: [*c]const RenderPassTimestampWrites = @import("std").mem.zeroes([*c]const RenderPassTimestampWrites),
};

pub const VertexState = extern struct {
    next_in_chain: [*c]const ChainedStruct = @import("std").mem.zeroes([*c]const ChainedStruct),
    module: ?ShaderModule = @import("std").mem.zeroes(?ShaderModule),
    entry_point: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
    constant_count: usize = @import("std").mem.zeroes(usize),
    constants: [*c]const ConstantEntry = @import("std").mem.zeroes([*c]const ConstantEntry),
    buffer_count: usize = @import("std").mem.zeroes(usize),
    buffers: [*c]const VertexBufferLayout = @import("std").mem.zeroes([*c]const VertexBufferLayout),
};

pub const FragmentState = extern struct {
    next_in_chain: [*c]const ChainedStruct = @import("std").mem.zeroes([*c]const ChainedStruct),
    module: ?ShaderModule = @import("std").mem.zeroes(?ShaderModule),
    entry_point: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
    constant_count: usize = @import("std").mem.zeroes(usize),
    constants: [*c]const ConstantEntry = @import("std").mem.zeroes([*c]const ConstantEntry),
    target_count: usize = @import("std").mem.zeroes(usize),
    targets: [*c]const ColorTargetState = @import("std").mem.zeroes([*c]const ColorTargetState),
};

pub const RenderPipelineDescriptor = extern struct {
    next_in_chain: [*c]const ChainedStruct = @import("std").mem.zeroes([*c]const ChainedStruct),
    label: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
    layout: ?PipelineLayout = @import("std").mem.zeroes(?PipelineLayout),
    vertex: VertexState = @import("std").mem.zeroes(VertexState),
    primitive: PrimitiveState = .{},
    depth_stencil: [*c]const DepthStencilState = null,
    multisample: MultisampleState = .{},
    fragment: [*c]const FragmentState = @import("std").mem.zeroes([*c]const FragmentState),
};

// Structs
pub const InstanceExtras = extern struct {
    chain: ChainedStruct = @import("std").mem.zeroes(ChainedStruct),
    backends: InstanceBackend = @import("std").mem.zeroes(InstanceBackend),
    flags: Instance = @import("std").mem.zeroes(Instance),
    dx12_shader_compiler: Dx12Compiler = @import("std").mem.zeroes(Dx12Compiler),
    gles3_minor_version: Gles3MinorVersion = @import("std").mem.zeroes(Gles3MinorVersion),
    dxil_path: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
    dxc_path: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
};

pub const DeviceExtras = extern struct {
    chain: ChainedStruct = @import("std").mem.zeroes(ChainedStruct),
    trace_path: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
};

pub const NativeLimits = extern struct {
    max_push_constant_size: u32 = @import("std").mem.zeroes(u32),
    max_non_sampler_bindings: u32 = @import("std").mem.zeroes(u32),
};

pub const RequiredLimitsExtras = extern struct {
    chain: ChainedStruct = @import("std").mem.zeroes(ChainedStruct),
    limits: NativeLimits = @import("std").mem.zeroes(NativeLimits),
};

pub const SupportedLimitsExtras = extern struct {
    chain: ChainedStructOut = @import("std").mem.zeroes(ChainedStructOut),
    limits: NativeLimits = @import("std").mem.zeroes(NativeLimits),
};

pub const PushConstantRange = extern struct {
    stages: ShaderStage = @import("std").mem.zeroes(ShaderStage),
    start: u32 = @import("std").mem.zeroes(u32),
    end: u32 = @import("std").mem.zeroes(u32),
};

pub const PipelineLayoutExtras = extern struct {
    chain: ChainedStruct = @import("std").mem.zeroes(ChainedStruct),
    push_constant_range_count: u32 = @import("std").mem.zeroes(u32),
    push_constant_ranges: [*c]PushConstantRange = @import("std").mem.zeroes([*c]PushConstantRange),
};

pub const WrappedSubmissionIndex = extern struct {
    queue: ?Queue = @import("std").mem.zeroes(?Queue),
    submission_index: SubmissionIndex = @import("std").mem.zeroes(SubmissionIndex),
};

pub const ShaderDefine = extern struct {
    name: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
    value: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
};

pub const ShaderModuleGLSLDescriptor = extern struct {
    chain: ChainedStruct = @import("std").mem.zeroes(ChainedStruct),
    stage: ShaderStage = @import("std").mem.zeroes(ShaderStage),
    code: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
    define_count: u32 = @import("std").mem.zeroes(u32),
    defines: [*c]ShaderDefine = @import("std").mem.zeroes([*c]ShaderDefine),
};

pub const StorageReport = extern struct {
    num_occupied: usize = @import("std").mem.zeroes(usize),
    num_vacant: usize = @import("std").mem.zeroes(usize),
    num_error: usize = @import("std").mem.zeroes(usize),
    element_size: usize = @import("std").mem.zeroes(usize),
};

pub const HubReport = extern struct {
    adapters: StorageReport = @import("std").mem.zeroes(StorageReport),
    devices: StorageReport = @import("std").mem.zeroes(StorageReport),
    pipeline_layouts: StorageReport = @import("std").mem.zeroes(StorageReport),
    shader_modules: StorageReport = @import("std").mem.zeroes(StorageReport),
    bind_group_layouts: StorageReport = @import("std").mem.zeroes(StorageReport),
    bind_groups: StorageReport = @import("std").mem.zeroes(StorageReport),
    command_buffers: StorageReport = @import("std").mem.zeroes(StorageReport),
    render_bundles: StorageReport = @import("std").mem.zeroes(StorageReport),
    render_pipelines: StorageReport = @import("std").mem.zeroes(StorageReport),
    compute_pipelines: StorageReport = @import("std").mem.zeroes(StorageReport),
    query_sets: StorageReport = @import("std").mem.zeroes(StorageReport),
    buffers: StorageReport = @import("std").mem.zeroes(StorageReport),
    textures: StorageReport = @import("std").mem.zeroes(StorageReport),
    texture_views: StorageReport = @import("std").mem.zeroes(StorageReport),
    samplers: StorageReport = @import("std").mem.zeroes(StorageReport),
};

pub const GlobalReport = extern struct {
    surfaces: StorageReport = @import("std").mem.zeroes(StorageReport),
    backend_type: BackendType = @import("std").mem.zeroes(BackendType),
    vulkan: HubReport = @import("std").mem.zeroes(HubReport),
    metal: HubReport = @import("std").mem.zeroes(HubReport),
    dx12: HubReport = @import("std").mem.zeroes(HubReport),
    dx11: HubReport = @import("std").mem.zeroes(HubReport),
    gl: HubReport = @import("std").mem.zeroes(HubReport),
};

pub const BindGroupEntryExtras = extern struct {
    chain: ChainedStruct = @import("std").mem.zeroes(ChainedStruct),
    buffers: [*c]const Buffer = @import("std").mem.zeroes([*c]const Buffer),
    buffer_count: usize = @import("std").mem.zeroes(usize),
    samplers: [*c]const Sampler = @import("std").mem.zeroes([*c]const Sampler),
    sampler_count: usize = @import("std").mem.zeroes(usize),
    texture_views: [*c]const TextureView = @import("std").mem.zeroes([*c]const TextureView),
    texture_view_count: usize = @import("std").mem.zeroes(usize),
};

pub const BindGroupLayoutEntryExtras = extern struct {
    chain: ChainedStruct = @import("std").mem.zeroes(ChainedStruct),
    count: u32 = @import("std").mem.zeroes(u32),
};

pub const QuerySetDescriptorExtras = extern struct {
    chain: ChainedStruct = @import("std").mem.zeroes(ChainedStruct),
    pipeline_statistics: [*c]const PipelineStatisticName = @import("std").mem.zeroes([*c]const PipelineStatisticName),
    pipeline_statistic_count: usize = @import("std").mem.zeroes(usize),
};

pub const ChainedStruct = extern struct {
    next: [*c]const ChainedStruct = @import("std").mem.zeroes([*c]const ChainedStruct),
    s_type: SType = @import("std").mem.zeroes(SType),
};

pub const ChainedStructOut = extern struct {
    next: [*c]ChainedStructOut = @import("std").mem.zeroes([*c]ChainedStructOut),
    s_type: SType = @import("std").mem.zeroes(SType),
};

pub const BlendComponent = extern struct {
    operation: BlendOperation = @import("std").mem.zeroes(BlendOperation),
    src_factor: BlendFactor = @import("std").mem.zeroes(BlendFactor),
    dst_factor: BlendFactor = @import("std").mem.zeroes(BlendFactor),
};

pub const Color = extern struct {
    r: f64 = @import("std").mem.zeroes(f64),
    g: f64 = @import("std").mem.zeroes(f64),
    b: f64 = @import("std").mem.zeroes(f64),
    a: f64 = @import("std").mem.zeroes(f64),
};

pub const ComputePassTimestampWrites = extern struct {
    query_set: QuerySet = @import("std").mem.zeroes(QuerySet),
    beginning_of_pass_write_index: u32 = @import("std").mem.zeroes(u32),
    end_of_pass_write_index: u32 = @import("std").mem.zeroes(u32),
};

pub const Extent3D = extern struct {
    width: u32 = @import("std").mem.zeroes(u32),
    height: u32 = @import("std").mem.zeroes(u32),
    depth_or_array_layers: u32 = 1,
};

pub const Limits = extern struct {
    max_texture_dimension1_d: u32 = @import("std").mem.zeroes(u32),
    max_texture_dimension2_d: u32 = @import("std").mem.zeroes(u32),
    max_texture_dimension3_d: u32 = @import("std").mem.zeroes(u32),
    max_texture_array_layers: u32 = @import("std").mem.zeroes(u32),
    max_bind_groups: u32 = @import("std").mem.zeroes(u32),
    max_bind_groups_plus_vertex_buffers: u32 = @import("std").mem.zeroes(u32),
    max_bindings_per_bind_group: u32 = @import("std").mem.zeroes(u32),
    max_dynamic_uniform_buffers_per_pipeline_layout: u32 = @import("std").mem.zeroes(u32),
    max_dynamic_storage_buffers_per_pipeline_layout: u32 = @import("std").mem.zeroes(u32),
    max_sampled_textures_per_shader_stage: u32 = @import("std").mem.zeroes(u32),
    max_samplers_per_shader_stage: u32 = @import("std").mem.zeroes(u32),
    max_storage_buffers_per_shader_stage: u32 = @import("std").mem.zeroes(u32),
    max_storage_textures_per_shader_stage: u32 = @import("std").mem.zeroes(u32),
    max_uniform_buffers_per_shader_stage: u32 = @import("std").mem.zeroes(u32),
    max_uniform_buffer_binding_size: u64 = @import("std").mem.zeroes(u64),
    max_storage_buffer_binding_size: u64 = @import("std").mem.zeroes(u64),
    min_uniform_buffer_offset_alignment: u32 = @import("std").mem.zeroes(u32),
    min_storage_buffer_offset_alignment: u32 = @import("std").mem.zeroes(u32),
    max_vertex_buffers: u32 = @import("std").mem.zeroes(u32),
    max_buffer_size: u64 = @import("std").mem.zeroes(u64),
    max_vertex_attributes: u32 = @import("std").mem.zeroes(u32),
    max_vertex_buffer_array_stride: u32 = @import("std").mem.zeroes(u32),
    max_inter_stage_shader_components: u32 = @import("std").mem.zeroes(u32),
    max_inter_stage_shader_variables: u32 = @import("std").mem.zeroes(u32),
    max_color_attachments: u32 = @import("std").mem.zeroes(u32),
    max_color_attachment_bytes_per_sample: u32 = @import("std").mem.zeroes(u32),
    max_compute_workgroup_storage_size: u32 = @import("std").mem.zeroes(u32),
    max_compute_invocations_per_workgroup: u32 = @import("std").mem.zeroes(u32),
    max_compute_workgroup_size_x: u32 = @import("std").mem.zeroes(u32),
    max_compute_workgroup_size_y: u32 = @import("std").mem.zeroes(u32),
    max_compute_workgroup_size_z: u32 = @import("std").mem.zeroes(u32),
    max_compute_workgroups_per_dimension: u32 = @import("std").mem.zeroes(u32),
};

pub const Origin3D = extern struct {
    x: u32 = @import("std").mem.zeroes(u32),
    y: u32 = @import("std").mem.zeroes(u32),
    z: u32 = @import("std").mem.zeroes(u32),
};

pub const PrimitiveDepthClipControl = extern struct {
    chain: ChainedStruct = @import("std").mem.zeroes(ChainedStruct),
    unclipped_depth: bool = @import("std").mem.zeroes(bool),
};

pub const RenderPassDepthStencilAttachment = extern struct {
    view: ?TextureView = @import("std").mem.zeroes(?TextureView),
    depth_load_op: LoadOp = .undefined,
    depth_store_op: StoreOp = .undefined,
    depth_clear_value: f32 = 0.0,
    depth_read_only: bool = false,
    stencil_load_op: LoadOp = .undefined,
    stencil_store_op: StoreOp = .undefined,
    stencil_clear_value: u32 = 0,
    stencil_read_only: bool = false,
};

pub const RenderPassDescriptorMaxDrawCount = extern struct {
    chain: ChainedStruct = @import("std").mem.zeroes(ChainedStruct),
    max_draw_count: u64 = @import("std").mem.zeroes(u64),
};

pub const RenderPassTimestampWrites = extern struct {
    query_set: ?QuerySet = @import("std").mem.zeroes(?QuerySet),
    beginning_of_pass_write_index: u32 = @import("std").mem.zeroes(u32),
    end_of_pass_write_index: u32 = @import("std").mem.zeroes(u32),
};

pub const ShaderModuleSPIRVDescriptor = extern struct {
    chain: ChainedStruct = @import("std").mem.zeroes(ChainedStruct),
    code_size: u32 = @import("std").mem.zeroes(u32),
    code: [*c]const u32 = @import("std").mem.zeroes([*c]const u32),
};

pub const ShaderModuleWGSLDescriptor = extern struct {
    chain: ChainedStruct = @import("std").mem.zeroes(ChainedStruct),
    code: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
};

pub const StencilFaceState = extern struct {
    compare: CompareFunction = .always,
    fail_op: StencilOperation = .keep,
    depth_fail_op: StencilOperation = .keep,
    pass_op: StencilOperation = .keep,
};

pub const SurfaceDescriptorFromAndroidNativeWindow = extern struct {
    chain: ChainedStruct = @import("std").mem.zeroes(ChainedStruct),
    window: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
};

pub const SurfaceDescriptorFromCanvasHTMLSelector = extern struct {
    chain: ChainedStruct = @import("std").mem.zeroes(ChainedStruct),
    selector: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
};

pub const SurfaceDescriptorFromMetalLayer = extern struct {
    chain: ChainedStruct = @import("std").mem.zeroes(ChainedStruct),
    layer: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
};

pub const SurfaceDescriptorFromWaylandSurface = extern struct {
    chain: ChainedStruct = @import("std").mem.zeroes(ChainedStruct),
    display: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
    surface: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
};

pub const SurfaceDescriptorFromWindowsHWND = extern struct {
    chain: ChainedStruct = @import("std").mem.zeroes(ChainedStruct),
    hinstance: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
    hwnd: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
};

pub const SurfaceDescriptorFromXcbWindow = extern struct {
    chain: ChainedStruct = @import("std").mem.zeroes(ChainedStruct),
    connection: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
    window: u32 = @import("std").mem.zeroes(u32),
};

pub const SurfaceDescriptorFromXlibWindow = extern struct {
    chain: ChainedStruct = @import("std").mem.zeroes(ChainedStruct),
    display: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
    window: u32 = @import("std").mem.zeroes(u32),
};

pub const SurfaceTexture = extern struct {
    texture: ?Texture = @import("std").mem.zeroes(?Texture),
    suboptimal: bool = @import("std").mem.zeroes(bool),
    status: SurfaceGetCurrentTextureStatus = @import("std").mem.zeroes(SurfaceGetCurrentTextureStatus),
};

pub const VertexAttribute = extern struct {
    format: VertexFormat = @import("std").mem.zeroes(VertexFormat),
    offset: u64 = @import("std").mem.zeroes(u64),
    shader_location: u32 = @import("std").mem.zeroes(u32),
};

pub const BlendState = extern struct {
    pub const alpha_blending = .{
        .color = .{
            .src_factor = .src_alpha,
            .dst_factor = .one_minus_src_alpha,
            .operation = .add,
        },
        .alpha = .{
            .src_factor = .one,
            .dst_factor = .one_minus_src_alpha,
            .operation = .add,
        },
    };

    color: BlendComponent = @import("std").mem.zeroes(BlendComponent),
    alpha: BlendComponent = @import("std").mem.zeroes(BlendComponent),
};

pub const VertexBufferLayout = extern struct {
    array_stride: u64 = @import("std").mem.zeroes(u64),
    step_mode: VertexStepMode = @import("std").mem.zeroes(VertexStepMode),
    attribute_count: usize = @import("std").mem.zeroes(usize),
    attributes: [*c]const VertexAttribute = @import("std").mem.zeroes([*c]const VertexAttribute),
};

// Enumerations
pub const NativeSType = enum(u32) {
    device_extras = 196609,
    required_limits_extras = 196610,
    pipeline_layout_extras = 196611,
    shader_module_glsl_descriptor = 196612,
    supported_limits_extras = 196613,
    instance_extras = 196614,
    bind_group_entry_extras = 196615,
    bind_group_layout_entry_extras = 196616,
    query_set_descriptor_extras = 196617,
};

pub const NativeFeature = enum(u32) {
    push_constants = 196609,
    texture_adapter_specific_format_features = 196610,
    multi_draw_indirect = 196611,
    multi_draw_indirect_count = 196612,
    vertex_writable_storage = 196613,
    texture_binding_array = 196614,
    sampled_texture_and_storage_buffer_array_non_uniform_indexing = 196615,
    pipeline_statistics_query = 196616,
};

pub const LogLevel = enum(u32) {
    off = 0,
    err = 1,
    warn = 2,
    info = 3,
    debug = 4,
    trace = 5,
};

pub const InstanceFlag = enum(u32) {
    default = 0,
    debug = 1,
    validation = 1,
    discard_hal_labels = 1,
};

pub const Dx12Compiler = enum(u32) {
    undefined = 0,
    fxc = 1,
    dxc = 2,
};

pub const Gles3MinorVersion = enum(u32) {
    automatic = 0,
    version0 = 1,
    version1 = 2,
    version2 = 3,
};

pub const PipelineStatisticName = enum(u32) {
    vertex_shader_invocations = 0,
    clipper_invocations = 1,
    clipper_primitives_out = 2,
    fragment_shader_invocations = 3,
    compute_shader_invocations = 4,
};

pub const NativeQueryType = enum(u32) {
    pipeline_statistics = 196608,
};

pub const AdapterType = enum(u32) {
    discrete_gpu = 0,
    integrated_gpu = 1,
    cpu = 2,
    unknown = 3,
};

pub const AddressMode = enum(u32) {
    repeat = 0,
    mirror_repeat = 1,
    clamp_to_edge = 2,
};

pub const BackendType = enum(u32) {
    undefined = 0,
    null = 1,
    web_gpu = 2,
    d3_d11 = 3,
    d3_d12 = 4,
    metal = 5,
    vulkan = 6,
    open_gl = 7,
    open_gles = 8,
};

pub const BlendFactor = enum(u32) {
    zero = 0,
    one = 1,
    src = 2,
    one_minus_src = 3,
    src_alpha = 4,
    one_minus_src_alpha = 5,
    dst = 6,
    one_minus_dst = 7,
    dst_alpha = 8,
    one_minus_dst_alpha = 9,
    src_alpha_saturated = 10,
    constant = 11,
    one_minus_constant = 12,
};

pub const BlendOperation = enum(u32) {
    add = 0,
    subtract = 1,
    reverse_subtract = 2,
    min = 3,
    max = 4,
};

pub const BufferBindingType = enum(u32) {
    undefined = 0,
    uniform = 1,
    storage = 2,
    read_only_storage = 3,
};

pub const BufferMapAsyncStatus = enum(u32) {
    success = 0,
    validation_error = 1,
    unknown = 2,
    device_lost = 3,
    destroyed_before_callback = 4,
    unmapped_before_callback = 5,
    mapping_already_pending = 6,
    offset_out_of_range = 7,
    size_out_of_range = 8,
};

pub const BufferMapState = enum(u32) {
    unmapped = 0,
    pending = 1,
    mapped = 2,
};

pub const CompareFunction = enum(u32) {
    undefined = 0,
    never = 1,
    less = 2,
    less_equal = 3,
    greater = 4,
    greater_equal = 5,
    equal = 6,
    not_equal = 7,
    always = 8,
};

pub const CompilationInfoRequestStatus = enum(u32) {
    success = 0,
    err = 1,
    device_lost = 2,
    unknown = 3,
};

pub const CompilationMessageType = enum(u32) {
    err = 0,
    warning = 1,
    info = 2,
};

pub const CompositeAlphaMode = enum(u32) {
    auto = 0,
    opaq = 1,
    premultiplied = 2,
    unpremultiplied = 3,
    inherit = 4,
};

pub const CreatePipelineAsyncStatus = enum(u32) {
    success = 0,
    validation_error = 1,
    internal_error = 2,
    device_lost = 3,
    device_destroyed = 4,
    unknown = 5,
};

pub const CullMode = enum(u32) {
    none = 0,
    front = 1,
    back = 2,
};

pub const DeviceLostReason = enum(u32) {
    undefined = 0,
    destroyed = 1,
};

pub const ErrorFilter = enum(u32) {
    validation = 0,
    out_of_memory = 1,
    internal = 2,
};

pub const ErrorType = enum(u32) {
    no_error = 0,
    validation = 1,
    out_of_memory = 2,
    internal = 3,
    unknown = 4,
    device_lost = 5,
};

pub const FeatureName = enum(u32) {
    undefined = 0,
    depth_clip_control = 1,
    depth32_float_stencil8 = 2,
    timestamp_query = 3,
    texture_compression_bc = 4,
    texture_compression_etc2 = 5,
    texture_compression_astc = 6,
    indirect_first_instance = 7,
    shader_f16 = 8,
    rg11_b10_ufloat_renderable = 9,
    bgra8_unorm_storage = 10,
    float32_filterable = 11,
};

pub const FilterMode = enum(u32) {
    nearest = 0,
    linear = 1,
};

pub const FrontFace = enum(u32) {
    ccw = 0,
    cw = 1,
};

pub const IndexFormat = enum(u32) {
    undefined = 0,
    uint16 = 1,
    uint32 = 2,
};

pub const LoadOp = enum(u32) {
    undefined = 0,
    clear = 1,
    load = 2,
};

pub const MipmapFilterMode = enum(u32) {
    nearest = 0,
    linear = 1,
};

pub const PowerPreference = enum(u32) {
    undefined = 0,
    low_power = 1,
    high_performance = 2,
};

pub const PresentMode = enum(u32) {
    fifo = 0,
    fifo_relaxed = 1,
    immediate = 2,
    mailbox = 3,
};

pub const PrimitiveTopology = enum(u32) {
    point_list = 0,
    line_list = 1,
    line_strip = 2,
    triangle_list = 3,
    triangle_strip = 4,
};

pub const QueryType = enum(u32) {
    occlusion = 0,
    timestamp = 1,
};

pub const QueueWorkDoneStatus = enum(u32) {
    success = 0,
    err = 1,
    unknown = 2,
    device_lost = 3,
};

pub const RequestAdapterStatus = enum(u32) {
    success = 0,
    unavailable = 1,
    err = 2,
    unknown = 3,
};

pub const RequestDeviceStatus = enum(u32) {
    success = 0,
    err = 1,
    unknown = 2,
};

pub const SType = enum(u32) {
    invalid = 0,
    surface_descriptor_from_metal_layer = 1,
    surface_descriptor_from_windows_hwnd = 2,
    surface_descriptor_from_xlib_window = 3,
    surface_descriptor_from_canvas_html_selector = 4,
    shader_module_spirv_descriptor = 5,
    shader_module_wgsl_descriptor = 6,
    primitive_depth_clip_control = 7,
    surface_descriptor_from_wayland_surface = 8,
    surface_descriptor_from_android_native_window = 9,
    surface_descriptor_from_xcb_window = 10,
    render_pass_descriptor_max_draw_count = 15,
};

pub const SamplerBindingType = enum(u32) {
    undefined = 0,
    filtering = 1,
    non_filtering = 2,
    comparison = 3,
};

pub const StencilOperation = enum(u32) {
    keep = 0,
    zero = 1,
    replace = 2,
    invert = 3,
    increment_clamp = 4,
    decrement_clamp = 5,
    increment_wrap = 6,
    decrement_wrap = 7,
};

pub const StorageTextureAccess = enum(u32) {
    undefined = 0,
    write_only = 1,
};

pub const StoreOp = enum(u32) {
    undefined = 0,
    store = 1,
    discard = 2,
};

pub const SurfaceGetCurrentTextureStatus = enum(u32) {
    success = 0,
    timeout = 1,
    outdated = 2,
    lost = 3,
    out_of_memory = 4,
    device_lost = 5,
};

pub const TextureAspect = enum(u32) {
    all = 0,
    stencil_only = 1,
    depth_only = 2,
};

pub const TextureDimension = enum(u32) {
    dim_1d = 0,
    dim_2d = 1,
    dim_3d = 2,
};

pub const TextureFormat = enum(u32) {
    undefined = 0,
    r8_unorm = 1,
    r8_snorm = 2,
    r8_uint = 3,
    r8_sint = 4,
    r16_uint = 5,
    r16_sint = 6,
    r16_float = 7,
    rg8_unorm = 8,
    rg8_snorm = 9,
    rg8_uint = 10,
    rg8_sint = 11,
    r32_float = 12,
    r32_uint = 13,
    r32_sint = 14,
    rg16_uint = 15,
    rg16_sint = 16,
    rg16_float = 17,
    rgba8_unorm = 18,
    rgba8_unorm_srgb = 19,
    rgba8_snorm = 20,
    rgba8_uint = 21,
    rgba8_sint = 22,
    bgra8_unorm = 23,
    bgra8_unorm_srgb = 24,
    rgb10_a2_unorm = 25,
    rg11_b10_ufloat = 26,
    rgb9_e5_ufloat = 27,
    rg32_float = 28,
    rg32_uint = 29,
    rg32_sint = 30,
    rgba16_uint = 31,
    rgba16_sint = 32,
    rgba16_float = 33,
    rgba32_float = 34,
    rgba32_uint = 35,
    rgba32_sint = 36,
    stencil8 = 37,
    depth16_unorm = 38,
    depth24_plus = 39,
    depth24_plus_stencil8 = 40,
    depth32_float = 41,
    depth32_float_stencil8 = 42,
    bc1_rgba_unorm = 43,
    bc1_rgba_unorm_srgb = 44,
    bc2_rgba_unorm = 45,
    bc2_rgba_unorm_srgb = 46,
    bc3_rgba_unorm = 47,
    bc3_rgba_unorm_srgb = 48,
    bc4_r_unorm = 49,
    bc4_r_snorm = 50,
    bc5_rg_unorm = 51,
    bc5_rg_snorm = 52,
    bc6_hrgb_ufloat = 53,
    bc6_hrgb_float = 54,
    bc7_rgba_unorm = 55,
    bc7_rgba_unorm_srgb = 56,
    etc2_rgb8_unorm = 57,
    etc2_rgb8_unorm_srgb = 58,
    etc2_rgb8_a1_unorm = 59,
    etc2_rgb8_a1_unorm_srgb = 60,
    etc2_rgba8_unorm = 61,
    etc2_rgba8_unorm_srgb = 62,
    eacr11_unorm = 63,
    eacr11_snorm = 64,
    eacrg11_unorm = 65,
    eacrg11_snorm = 66,
    astc4x4_unorm = 67,
    astc4x4_unorm_srgb = 68,
    astc5x4_unorm = 69,
    astc5x4_unorm_srgb = 70,
    astc5x5_unorm = 71,
    astc5x5_unorm_srgb = 72,
    astc6x5_unorm = 73,
    astc6x5_unorm_srgb = 74,
    astc6x6_unorm = 75,
    astc6x6_unorm_srgb = 76,
    astc8x5_unorm = 77,
    astc8x5_unorm_srgb = 78,
    astc8x6_unorm = 79,
    astc8x6_unorm_srgb = 80,
    astc8x8_unorm = 81,
    astc8x8_unorm_srgb = 82,
    astc10x5_unorm = 83,
    astc10x5_unorm_srgb = 84,
    astc10x6_unorm = 85,
    astc10x6_unorm_srgb = 86,
    astc10x8_unorm = 87,
    astc10x8_unorm_srgb = 88,
    astc10x10_unorm = 89,
    astc10x10_unorm_srgb = 90,
    astc12x10_unorm = 91,
    astc12x10_unorm_srgb = 92,
    astc12x12_unorm = 93,
    astc12x12_unorm_srgb = 94,
};

pub const TextureSampleType = enum(u32) {
    undefined = 0,
    float = 1,
    unfilterable_float = 2,
    depth = 3,
    sint = 4,
    uint = 5,
};

pub const TextureViewDimension = enum(u32) {
    undefined = 0,
    dim_1d = 1,
    dim_2d = 2,
    dim_2darray = 3,
    cube = 4,
    cube_array = 5,
    dim_3d = 6,
};

pub const VertexFormat = enum(u32) {
    undefined = 0,
    uint8x2 = 1,
    uint8x4 = 2,
    sint8x2 = 3,
    sint8x4 = 4,
    unorm8x2 = 5,
    unorm8x4 = 6,
    snorm8x2 = 7,
    snorm8x4 = 8,
    uint16x2 = 9,
    uint16x4 = 10,
    sint16x2 = 11,
    sint16x4 = 12,
    unorm16x2 = 13,
    unorm16x4 = 14,
    snorm16x2 = 15,
    snorm16x4 = 16,
    float16x2 = 17,
    float16x4 = 18,
    float32 = 19,
    float32x2 = 20,
    float32x3 = 21,
    float32x4 = 22,
    uint32 = 23,
    uint32x2 = 24,
    uint32x3 = 25,
    uint32x4 = 26,
    sint32 = 27,
    sint32x2 = 28,
    sint32x3 = 29,
    sint32x4 = 30,
};

pub const VertexStepMode = enum(u32) {
    vertex = 0,
    instance = 1,
    vertex_buffer_not_used = 2,
};

pub const BufferUsage = packed struct(u32) {
    map_read: bool = false,
    map_write: bool = false,
    copy_src: bool = false,
    copy_dst: bool = false,
    index: bool = false,
    vertex: bool = false,
    uniform: bool = false,
    storage: bool = false,
    indirect: bool = false,
    query_resolve: bool = false,
    _padding: u22 = 0,
};

pub const ColorWriteMask = packed struct(u32) {
    red: bool = false,
    green: bool = false,
    blue: bool = false,
    alpha: bool = false,
    all: bool = false,
    _padding: u27 = 0,

    pub const all = ColorWriteMask{ .red = true, .green = true, .blue = true, .alpha = true };
};

pub const MapMode = packed struct(u32) {
    read: bool = false,
    write: bool = false,
    _padding: u30 = 0,
};

pub const ShaderStage = packed struct(u32) {
    vertex: bool = false,
    fragment: bool = false,
    compute: bool = false,
    _padding: u29 = 0,
};

pub const TextureUsage = packed struct(u32) {
    copy_src: bool = false,
    copy_dst: bool = false,
    texture_binding: bool = false,
    storage_binding: bool = false,
    render_attachment: bool = false,
    _padding: u27 = 0,
};

// Callback types
pub const LogCallback = *const fn (level: LogLevel, message: ?[*:0]const u8, userdata: ?*anyopaque) callconv(.C) void;
pub const BufferMapCallback = *const fn (status: BufferMapAsyncStatus, userdata: ?*anyopaque) callconv(.C) void;
pub const CompilationInfoCallback = *const fn (status: CompilationInfoRequestStatus, compilation_info: *const CompilationInfo, userdata: ?*anyopaque) callconv(.C) void;
pub const CreateComputePipelineAsyncCallback = *const fn (status: CreatePipelineAsyncStatus, pipeline: ComputePipeline, message: ?[*:0]const u8, userdata: ?*anyopaque) callconv(.C) void;
pub const CreateRenderPipelineAsyncCallback = *const fn (status: CreatePipelineAsyncStatus, pipeline: RenderPipeline, message: ?[*:0]const u8, userdata: ?*anyopaque) callconv(.C) void;
pub const DeviceLostCallback = *const fn (reason: DeviceLostReason, message: ?[*:0]const u8, userdata: ?*anyopaque) callconv(.C) void;
pub const ErrorCallback = *const fn (type: ErrorType, message: ?[*:0]const u8, userdata: ?*anyopaque) callconv(.C) void;
pub const QueueWorkDoneCallback = *const fn (status: QueueWorkDoneStatus, userdata: ?*anyopaque) callconv(.C) void;
pub const RequestAdapterCallback = *const fn (status: RequestAdapterStatus, adapter: Adapter, message: ?[*:0]const u8, userdata: ?*anyopaque) callconv(.C) void;
pub const RequestDeviceCallback = *const fn (status: RequestDeviceStatus, device: Device, message: ?[*:0]const u8, userdata: ?*anyopaque) callconv(.C) void;
pub const ProcDeviceSetUncapturedErrorCallback = *const fn (device: Device, callback: ErrorCallback, userdata: ?*anyopaque) callconv(.C) void;

// Handles
pub const Adapter = *opaque {
    const Self = @This();

    pub inline fn enumerateFeatures(self: *Self, features: ?[*]FeatureName) usize {
        return wgpuAdapterEnumerateFeatures(self, features);
    }
    extern fn wgpuAdapterEnumerateFeatures(adapter: Adapter, features: [*c]FeatureName) usize;

    pub inline fn getLimits(self: *Self, limits: *SupportedLimits) bool {
        return wgpuAdapterGetLimits(self, limits);
    }
    extern fn wgpuAdapterGetLimits(adapter: Adapter, limits: [*c]SupportedLimits) bool;

    pub inline fn getProperties(self: *Self, properties: *AdapterProperties) void {
        return wgpuAdapterGetProperties(self, properties);
    }
    extern fn wgpuAdapterGetProperties(adapter: Adapter, properties: [*c]AdapterProperties) void;

    pub inline fn hasFeature(self: *Self, feature: FeatureName) bool {
        return wgpuAdapterHasFeature(self, feature);
    }
    extern fn wgpuAdapterHasFeature(adapter: Adapter, feature: FeatureName) bool;

    pub inline fn requestDevice(self: *Self, descriptor: ?*const DeviceDescriptor, callback: RequestDeviceCallback, userdata: ?*anyopaque) void {
        return wgpuAdapterRequestDevice(self, descriptor, callback, userdata);
    }
    extern fn wgpuAdapterRequestDevice(adapter: Adapter, descriptor: [*c]const DeviceDescriptor, callback: RequestDeviceCallback, userdata: ?*anyopaque) void;

    pub inline fn reference(self: *Self) void {
        return wgpuAdapterReference(self);
    }
    extern fn wgpuAdapterReference(adapter: Adapter) void;

    pub inline fn release(self: *Self) void {
        return wgpuAdapterRelease(self);
    }
    extern fn wgpuAdapterRelease(adapter: Adapter) void;
};

pub const BindGroup = *opaque {
    const Self = @This();

    pub inline fn setLabel(self: *Self, label: ?[*:0]const u8) void {
        return wgpuBindGroupSetLabel(self, label);
    }
    extern fn wgpuBindGroupSetLabel(bindGroup: BindGroup, label: [*c]const u8) void;

    pub inline fn reference(self: *Self) void {
        return wgpuBindGroupReference(self);
    }
    extern fn wgpuBindGroupReference(bindGroup: BindGroup) void;

    pub inline fn release(self: *Self) void {
        return wgpuBindGroupRelease(self);
    }
    extern fn wgpuBindGroupRelease(bindGroup: BindGroup) void;
};

pub const BindGroupLayout = *opaque {
    const Self = @This();

    pub inline fn setLabel(self: *Self, label: ?[*:0]const u8) void {
        return wgpuBindGroupLayoutSetLabel(self, label);
    }
    extern fn wgpuBindGroupLayoutSetLabel(bindGroupLayout: BindGroupLayout, label: [*c]const u8) void;

    pub inline fn reference(self: *Self) void {
        return wgpuBindGroupLayoutReference(self);
    }
    extern fn wgpuBindGroupLayoutReference(bindGroupLayout: BindGroupLayout) void;

    pub inline fn release(self: *Self) void {
        return wgpuBindGroupLayoutRelease(self);
    }
    extern fn wgpuBindGroupLayoutRelease(bindGroupLayout: BindGroupLayout) void;
};

pub const Buffer = *opaque {
    const Self = @This();

    pub inline fn destroy(self: *Self) void {
        return wgpuBufferDestroy(self);
    }
    extern fn wgpuBufferDestroy(buffer: Buffer) void;

    pub inline fn getConstMappedRange(self: *Self, offset: usize, size: usize) ?*const anyopaque {
        return wgpuBufferGetConstMappedRange(self, offset, size);
    }
    extern fn wgpuBufferGetConstMappedRange(buffer: Buffer, offset: usize, size: usize) ?*const anyopaque;

    pub inline fn getMapState(self: *Self) BufferMapState {
        return wgpuBufferGetMapState(self);
    }
    extern fn wgpuBufferGetMapState(buffer: Buffer) BufferMapState;

    // `offset` has to be a multiple of 8 (otherwise `null` will be returned).
    // `@sizeOf(T) * len` has to be a multiple of 4 (otherwise `null` will be returned).
    pub inline fn getMappedRange(buffer: Buffer, comptime T: type, offset: usize, len: usize) ?[]T {
        if (len == 0) return null;
        const ptr = wgpuBufferGetMappedRange(buffer, offset, @sizeOf(T) * len);
        if (ptr == null) return null;
        return @as([*]T, @ptrCast(@alignCast(ptr)))[0..len];
    }
    extern fn wgpuBufferGetMappedRange(buffer: Buffer, offset: usize, size: usize) ?*anyopaque;

    pub inline fn getSize(self: *Self) u64 {
        return wgpuBufferGetSize(self);
    }
    extern fn wgpuBufferGetSize(buffer: Buffer) u64;

    pub inline fn getUsage(self: *Self) BufferUsage {
        return wgpuBufferGetUsage(self);
    }
    extern fn wgpuBufferGetUsage(buffer: Buffer) BufferUsage;

    pub inline fn mapAsync(self: *Self, mode: MapMode, offset: usize, size: usize, callback: BufferMapCallback, userdata: ?*anyopaque) void {
        return wgpuBufferMapAsync(self, mode, offset, size, callback, userdata);
    }
    extern fn wgpuBufferMapAsync(buffer: Buffer, mode: MapMode, offset: usize, size: usize, callback: BufferMapCallback, userdata: ?*anyopaque) void;

    pub inline fn setLabel(self: *Self, label: ?[*:0]const u8) void {
        return wgpuBufferSetLabel(self, label);
    }
    extern fn wgpuBufferSetLabel(buffer: Buffer, label: [*c]const u8) void;

    pub inline fn unmap(self: *Self) void {
        return wgpuBufferUnmap(self);
    }
    extern fn wgpuBufferUnmap(buffer: Buffer) void;

    pub inline fn reference(self: *Self) void {
        return wgpuBufferReference(self);
    }
    extern fn wgpuBufferReference(buffer: Buffer) void;

    pub inline fn release(self: *Self) void {
        return wgpuBufferRelease(self);
    }
    extern fn wgpuBufferRelease(buffer: Buffer) void;
};

pub const CommandBuffer = *opaque {
    const Self = @This();

    pub inline fn setLabel(self: *Self, label: ?[*:0]const u8) void {
        return wgpuCommandBufferSetLabel(self, label);
    }
    extern fn wgpuCommandBufferSetLabel(commandBuffer: CommandBuffer, label: [*c]const u8) void;

    pub inline fn reference(self: *Self) void {
        return wgpuCommandBufferReference(self);
    }
    extern fn wgpuCommandBufferReference(commandBuffer: CommandBuffer) void;

    pub inline fn release(self: *Self) void {
        return wgpuCommandBufferRelease(self);
    }
    extern fn wgpuCommandBufferRelease(commandBuffer: CommandBuffer) void;
};

pub const CommandEncoder = *opaque {
    const Self = @This();

    pub inline fn beginComputePass(self: *Self, descriptor: ?*const ComputePassDescriptor) ComputePassEncoder {
        return wgpuCommandEncoderBeginComputePass(self, descriptor);
    }
    extern fn wgpuCommandEncoderBeginComputePass(commandEncoder: CommandEncoder, descriptor: [*c]const ComputePassDescriptor) ComputePassEncoder;

    pub inline fn beginRenderPass(self: *Self, descriptor: *const RenderPassDescriptor) RenderPassEncoder {
        return wgpuCommandEncoderBeginRenderPass(self, descriptor);
    }
    extern fn wgpuCommandEncoderBeginRenderPass(commandEncoder: CommandEncoder, descriptor: [*c]const RenderPassDescriptor) RenderPassEncoder;

    pub inline fn clearBuffer(self: *Self, buffer: Buffer, offset: u64, size: u64) void {
        return wgpuCommandEncoderClearBuffer(self, buffer, offset, size);
    }
    extern fn wgpuCommandEncoderClearBuffer(commandEncoder: CommandEncoder, buffer: Buffer, offset: u64, size: u64) void;

    pub inline fn copyBufferToBuffer(self: *Self, source: Buffer, source_offset: u64, destination: Buffer, destination_offset: u64, size: u64) void {
        return wgpuCommandEncoderCopyBufferToBuffer(self, source, source_offset, destination, destination_offset, size);
    }
    extern fn wgpuCommandEncoderCopyBufferToBuffer(commandEncoder: CommandEncoder, source: Buffer, sourceOffset: u64, destination: Buffer, destinationOffset: u64, size: u64) void;

    pub inline fn copyBufferToTexture(self: *Self, source: *const ImageCopyBuffer, destination: *const ImageCopyTexture, copy_size: *const Extent3D) void {
        return wgpuCommandEncoderCopyBufferToTexture(self, source, destination, copy_size);
    }
    extern fn wgpuCommandEncoderCopyBufferToTexture(commandEncoder: CommandEncoder, source: [*c]const ImageCopyBuffer, destination: [*c]const ImageCopyTexture, copySize: [*c]const Extent3D) void;

    pub inline fn copyTextureToBuffer(self: *Self, source: *const ImageCopyTexture, destination: *const ImageCopyBuffer, copy_size: *const Extent3D) void {
        return wgpuCommandEncoderCopyTextureToBuffer(self, source, destination, copy_size);
    }
    extern fn wgpuCommandEncoderCopyTextureToBuffer(commandEncoder: CommandEncoder, source: [*c]const ImageCopyTexture, destination: [*c]const ImageCopyBuffer, copySize: [*c]const Extent3D) void;

    pub inline fn copyTextureToTexture(self: *Self, source: *const ImageCopyTexture, destination: *const ImageCopyTexture, copy_size: *const Extent3D) void {
        return wgpuCommandEncoderCopyTextureToTexture(self, source, destination, copy_size);
    }
    extern fn wgpuCommandEncoderCopyTextureToTexture(commandEncoder: CommandEncoder, source: [*c]const ImageCopyTexture, destination: [*c]const ImageCopyTexture, copySize: [*c]const Extent3D) void;

    pub inline fn finish(self: *Self, descriptor: ?*const CommandBufferDescriptor) CommandBuffer {
        return wgpuCommandEncoderFinish(self, descriptor);
    }
    extern fn wgpuCommandEncoderFinish(commandEncoder: CommandEncoder, descriptor: [*c]const CommandBufferDescriptor) CommandBuffer;

    pub inline fn insertDebugMarker(self: *Self, marker_label: ?[*:0]const u8) void {
        return wgpuCommandEncoderInsertDebugMarker(self, marker_label);
    }
    extern fn wgpuCommandEncoderInsertDebugMarker(commandEncoder: CommandEncoder, markerLabel: [*c]const u8) void;

    pub inline fn popDebugGroup(self: *Self) void {
        return wgpuCommandEncoderPopDebugGroup(self);
    }
    extern fn wgpuCommandEncoderPopDebugGroup(commandEncoder: CommandEncoder) void;

    pub inline fn pushDebugGroup(self: *Self, group_label: ?[*:0]const u8) void {
        return wgpuCommandEncoderPushDebugGroup(self, group_label);
    }
    extern fn wgpuCommandEncoderPushDebugGroup(commandEncoder: CommandEncoder, groupLabel: [*c]const u8) void;

    pub inline fn resolveQuerySet(self: *Self, query_set: QuerySet, first_query: u32, query_count: u32, destination: Buffer, destination_offset: u64) void {
        return wgpuCommandEncoderResolveQuerySet(self, query_set, first_query, query_count, destination, destination_offset);
    }
    extern fn wgpuCommandEncoderResolveQuerySet(commandEncoder: CommandEncoder, querySet: QuerySet, firstQuery: u32, queryCount: u32, destination: Buffer, destinationOffset: u64) void;

    pub inline fn setLabel(self: *Self, label: ?[*:0]const u8) void {
        return wgpuCommandEncoderSetLabel(self, label);
    }
    extern fn wgpuCommandEncoderSetLabel(commandEncoder: CommandEncoder, label: [*c]const u8) void;

    pub inline fn writeTimestamp(self: *Self, query_set: QuerySet, query_index: u32) void {
        return wgpuCommandEncoderWriteTimestamp(self, query_set, query_index);
    }
    extern fn wgpuCommandEncoderWriteTimestamp(commandEncoder: CommandEncoder, querySet: QuerySet, queryIndex: u32) void;

    pub inline fn reference(self: *Self) void {
        return wgpuCommandEncoderReference(self);
    }
    extern fn wgpuCommandEncoderReference(commandEncoder: CommandEncoder) void;

    pub inline fn release(self: *Self) void {
        return wgpuCommandEncoderRelease(self);
    }
    extern fn wgpuCommandEncoderRelease(commandEncoder: CommandEncoder) void;
};

pub const ComputePassEncoder = *opaque {
    const Self = @This();

    pub inline fn beginPipelineStatisticsQuery(self: *Self, query_set: QuerySet, query_index: u32) void {
        return wgpuComputePassEncoderBeginPipelineStatisticsQuery(self, query_set, query_index);
    }
    extern fn wgpuComputePassEncoderBeginPipelineStatisticsQuery(computePassEncoder: ComputePassEncoder, querySet: QuerySet, queryIndex: u32) void;

    pub inline fn endPipelineStatisticsQuery(self: *Self) void {
        return wgpuComputePassEncoderEndPipelineStatisticsQuery(self);
    }
    extern fn wgpuComputePassEncoderEndPipelineStatisticsQuery(computePassEncoder: ComputePassEncoder) void;

    pub inline fn dispatchWorkgroups(self: *Self, workgroup_count_x: u32, workgroup_count_y: u32, workgroup_count_z: u32) void {
        return wgpuComputePassEncoderDispatchWorkgroups(self, workgroup_count_x, workgroup_count_y, workgroup_count_z);
    }
    extern fn wgpuComputePassEncoderDispatchWorkgroups(computePassEncoder: ComputePassEncoder, workgroupCountX: u32, workgroupCountY: u32, workgroupCountZ: u32) void;

    pub inline fn dispatchWorkgroupsIndirect(self: *Self, indirect_buffer: Buffer, indirect_offset: u64) void {
        return wgpuComputePassEncoderDispatchWorkgroupsIndirect(self, indirect_buffer, indirect_offset);
    }
    extern fn wgpuComputePassEncoderDispatchWorkgroupsIndirect(computePassEncoder: ComputePassEncoder, indirectBuffer: Buffer, indirectOffset: u64) void;

    pub inline fn end(self: *Self) void {
        return wgpuComputePassEncoderEnd(self);
    }
    extern fn wgpuComputePassEncoderEnd(computePassEncoder: ComputePassEncoder) void;

    pub inline fn insertDebugMarker(self: *Self, marker_label: ?[*:0]const u8) void {
        return wgpuComputePassEncoderInsertDebugMarker(self, marker_label);
    }
    extern fn wgpuComputePassEncoderInsertDebugMarker(computePassEncoder: ComputePassEncoder, markerLabel: [*c]const u8) void;

    pub inline fn popDebugGroup(self: *Self) void {
        return wgpuComputePassEncoderPopDebugGroup(self);
    }
    extern fn wgpuComputePassEncoderPopDebugGroup(computePassEncoder: ComputePassEncoder) void;

    pub inline fn pushDebugGroup(self: *Self, group_label: ?[*:0]const u8) void {
        return wgpuComputePassEncoderPushDebugGroup(self, group_label);
    }
    extern fn wgpuComputePassEncoderPushDebugGroup(computePassEncoder: ComputePassEncoder, groupLabel: [*c]const u8) void;

    pub inline fn setBindGroup(self: *Self, group_index: u32, group: BindGroup, dynamic_offset_count: usize, dynamic_offsets: ?[*]const u32) void {
        return wgpuComputePassEncoderSetBindGroup(self, group_index, group, dynamic_offset_count, dynamic_offsets);
    }
    extern fn wgpuComputePassEncoderSetBindGroup(computePassEncoder: ComputePassEncoder, groupIndex: u32, group: BindGroup, dynamicOffsetCount: usize, dynamicOffsets: [*c]const u32) void;

    pub inline fn setLabel(self: *Self, label: ?[*:0]const u8) void {
        return wgpuComputePassEncoderSetLabel(self, label);
    }
    extern fn wgpuComputePassEncoderSetLabel(computePassEncoder: ComputePassEncoder, label: [*c]const u8) void;

    pub inline fn setPipeline(self: *Self, pipeline: ComputePipeline) void {
        return wgpuComputePassEncoderSetPipeline(self, pipeline);
    }
    extern fn wgpuComputePassEncoderSetPipeline(computePassEncoder: ComputePassEncoder, pipeline: ComputePipeline) void;

    pub inline fn reference(self: *Self) void {
        return wgpuComputePassEncoderReference(self);
    }
    extern fn wgpuComputePassEncoderReference(computePassEncoder: ComputePassEncoder) void;

    pub inline fn release(self: *Self) void {
        return wgpuComputePassEncoderRelease(self);
    }
    extern fn wgpuComputePassEncoderRelease(computePassEncoder: ComputePassEncoder) void;
};

pub const ComputePipeline = *opaque {
    const Self = @This();

    pub inline fn getBindGroupLayout(self: *Self, group_index: u32) BindGroupLayout {
        return wgpuComputePipelineGetBindGroupLayout(self, group_index);
    }
    extern fn wgpuComputePipelineGetBindGroupLayout(computePipeline: ComputePipeline, groupIndex: u32) BindGroupLayout;

    pub inline fn setLabel(self: *Self, label: ?[*:0]const u8) void {
        return wgpuComputePipelineSetLabel(self, label);
    }
    extern fn wgpuComputePipelineSetLabel(computePipeline: ComputePipeline, label: [*c]const u8) void;

    pub inline fn reference(self: *Self) void {
        return wgpuComputePipelineReference(self);
    }
    extern fn wgpuComputePipelineReference(computePipeline: ComputePipeline) void;

    pub inline fn release(self: *Self) void {
        return wgpuComputePipelineRelease(self);
    }
    extern fn wgpuComputePipelineRelease(computePipeline: ComputePipeline) void;
};

pub const Device = *opaque {
    const Self = @This();

    pub inline fn poll(self: *Self, wait: bool, wrapped_submission_index: ?*const WrappedSubmissionIndex) bool {
        return wgpuDevicePoll(self, wait, wrapped_submission_index);
    }
    extern fn wgpuDevicePoll(device: Device, wait: bool, wrappedSubmissionIndex: [*c]const WrappedSubmissionIndex) bool;

    pub inline fn createBindGroup(self: *Self, descriptor: *const BindGroupDescriptor) BindGroup {
        return wgpuDeviceCreateBindGroup(self, descriptor);
    }
    extern fn wgpuDeviceCreateBindGroup(device: Device, descriptor: [*c]const BindGroupDescriptor) BindGroup;

    pub inline fn createBindGroupLayout(self: *Self, descriptor: *const BindGroupLayoutDescriptor) BindGroupLayout {
        return wgpuDeviceCreateBindGroupLayout(self, descriptor);
    }
    extern fn wgpuDeviceCreateBindGroupLayout(device: Device, descriptor: [*c]const BindGroupLayoutDescriptor) BindGroupLayout;

    pub inline fn createBuffer(self: *Self, descriptor: *const BufferDescriptor) Buffer {
        return wgpuDeviceCreateBuffer(self, descriptor);
    }
    extern fn wgpuDeviceCreateBuffer(device: Device, descriptor: [*c]const BufferDescriptor) Buffer;

    pub inline fn createCommandEncoder(self: *Self, descriptor: ?*const CommandEncoderDescriptor) CommandEncoder {
        return wgpuDeviceCreateCommandEncoder(self, descriptor);
    }
    extern fn wgpuDeviceCreateCommandEncoder(device: Device, descriptor: [*c]const CommandEncoderDescriptor) CommandEncoder;

    pub inline fn createComputePipeline(self: *Self, descriptor: *const ComputePipelineDescriptor) ComputePipeline {
        return wgpuDeviceCreateComputePipeline(self, descriptor);
    }
    extern fn wgpuDeviceCreateComputePipeline(device: Device, descriptor: [*c]const ComputePipelineDescriptor) ComputePipeline;

    pub inline fn createComputePipelineAsync(self: *Self, descriptor: *const ComputePipelineDescriptor, callback: CreateComputePipelineAsyncCallback, userdata: ?*anyopaque) void {
        return wgpuDeviceCreateComputePipelineAsync(self, descriptor, callback, userdata);
    }
    extern fn wgpuDeviceCreateComputePipelineAsync(device: Device, descriptor: [*c]const ComputePipelineDescriptor, callback: CreateComputePipelineAsyncCallback, userdata: ?*anyopaque) void;

    pub inline fn createPipelineLayout(self: *Self, descriptor: *const PipelineLayoutDescriptor) PipelineLayout {
        return wgpuDeviceCreatePipelineLayout(self, descriptor);
    }
    extern fn wgpuDeviceCreatePipelineLayout(device: Device, descriptor: [*c]const PipelineLayoutDescriptor) PipelineLayout;

    pub inline fn createQuerySet(self: *Self, descriptor: *const QuerySetDescriptor) QuerySet {
        return wgpuDeviceCreateQuerySet(self, descriptor);
    }
    extern fn wgpuDeviceCreateQuerySet(device: Device, descriptor: [*c]const QuerySetDescriptor) QuerySet;

    pub inline fn createRenderBundleEncoder(self: *Self, descriptor: *const RenderBundleEncoderDescriptor) RenderBundleEncoder {
        return wgpuDeviceCreateRenderBundleEncoder(self, descriptor);
    }
    extern fn wgpuDeviceCreateRenderBundleEncoder(device: Device, descriptor: [*c]const RenderBundleEncoderDescriptor) RenderBundleEncoder;

    pub inline fn createRenderPipeline(self: *Self, descriptor: *const RenderPipelineDescriptor) RenderPipeline {
        return wgpuDeviceCreateRenderPipeline(self, descriptor);
    }
    extern fn wgpuDeviceCreateRenderPipeline(device: Device, descriptor: [*c]const RenderPipelineDescriptor) RenderPipeline;

    pub inline fn createRenderPipelineAsync(self: *Self, descriptor: *const RenderPipelineDescriptor, callback: CreateRenderPipelineAsyncCallback, userdata: ?*anyopaque) void {
        return wgpuDeviceCreateRenderPipelineAsync(self, descriptor, callback, userdata);
    }
    extern fn wgpuDeviceCreateRenderPipelineAsync(device: Device, descriptor: [*c]const RenderPipelineDescriptor, callback: CreateRenderPipelineAsyncCallback, userdata: ?*anyopaque) void;

    pub inline fn createSampler(self: *Self, descriptor: ?*const SamplerDescriptor) Sampler {
        return wgpuDeviceCreateSampler(self, descriptor);
    }
    extern fn wgpuDeviceCreateSampler(device: Device, descriptor: [*c]const SamplerDescriptor) Sampler;

    pub inline fn createShaderModule(self: *Self, descriptor: *const ShaderModuleDescriptor) ShaderModule {
        return wgpuDeviceCreateShaderModule(self, descriptor);
    }
    extern fn wgpuDeviceCreateShaderModule(device: Device, descriptor: [*c]const ShaderModuleDescriptor) ShaderModule;

    pub inline fn createTexture(self: *Self, descriptor: *const TextureDescriptor) Texture {
        return wgpuDeviceCreateTexture(self, descriptor);
    }
    extern fn wgpuDeviceCreateTexture(device: Device, descriptor: [*c]const TextureDescriptor) Texture;

    pub inline fn destroy(self: *Self) void {
        return wgpuDeviceDestroy(self);
    }
    extern fn wgpuDeviceDestroy(device: Device) void;

    pub inline fn enumerateFeatures(self: *Self, features: ?[*]FeatureName) usize {
        return wgpuDeviceEnumerateFeatures(self, features);
    }
    extern fn wgpuDeviceEnumerateFeatures(device: Device, features: [*c]FeatureName) usize;

    pub inline fn getLimits(self: *Self, limits: *SupportedLimits) bool {
        return wgpuDeviceGetLimits(self, limits);
    }
    extern fn wgpuDeviceGetLimits(device: Device, limits: [*c]SupportedLimits) bool;

    pub inline fn getQueue(self: *Self) Queue {
        return wgpuDeviceGetQueue(self);
    }
    extern fn wgpuDeviceGetQueue(device: Device) Queue;

    pub inline fn hasFeature(self: *Self, feature: FeatureName) bool {
        return wgpuDeviceHasFeature(self, feature);
    }
    extern fn wgpuDeviceHasFeature(device: Device, feature: FeatureName) bool;

    pub inline fn popErrorScope(self: *Self, callback: ErrorCallback, userdata: ?*anyopaque) void {
        return wgpuDevicePopErrorScope(self, callback, userdata);
    }
    extern fn wgpuDevicePopErrorScope(device: Device, callback: ErrorCallback, userdata: ?*anyopaque) void;

    pub inline fn pushErrorScope(self: *Self, filter: ErrorFilter) void {
        return wgpuDevicePushErrorScope(self, filter);
    }
    extern fn wgpuDevicePushErrorScope(device: Device, filter: ErrorFilter) void;

    pub inline fn setLabel(self: *Self, label: ?[*:0]const u8) void {
        return wgpuDeviceSetLabel(self, label);
    }
    extern fn wgpuDeviceSetLabel(device: Device, label: [*c]const u8) void;

    pub inline fn setUncapturedErrorCallback(self: *Self, callback: ErrorCallback, userdata: ?*anyopaque) void {
        return wgpuDeviceSetUncapturedErrorCallback(self, callback, userdata);
    }
    extern fn wgpuDeviceSetUncapturedErrorCallback(device: Device, callback: ErrorCallback, userdata: ?*anyopaque) void;

    pub inline fn reference(self: *Self) void {
        return wgpuDeviceReference(self);
    }
    extern fn wgpuDeviceReference(device: Device) void;

    pub inline fn release(self: *Self) void {
        return wgpuDeviceRelease(self);
    }
    extern fn wgpuDeviceRelease(device: Device) void;
};

pub const Instance = *opaque {
    const Self = @This();

    pub inline fn enumerateAdapters(self: *Self, options: *const InstanceEnumerateAdapterOptions, adapters: *Adapter) usize {
        return wgpuInstanceEnumerateAdapters(self, options, adapters);
    }
    extern fn wgpuInstanceEnumerateAdapters(instance: Instance, options: [*c]const InstanceEnumerateAdapterOptions, adapters: [*c]Adapter) usize;

    pub inline fn createSurface(self: *Self, descriptor: *const SurfaceDescriptor) Surface {
        return wgpuInstanceCreateSurface(self, descriptor);
    }
    extern fn wgpuInstanceCreateSurface(instance: Instance, descriptor: [*c]const SurfaceDescriptor) Surface;

    pub inline fn processEvents(self: *Self) void {
        return wgpuInstanceProcessEvents(self);
    }
    extern fn wgpuInstanceProcessEvents(instance: Instance) void;

    pub inline fn requestAdapter(self: *Self, options: *const RequestAdapterOptions, callback: RequestAdapterCallback, userdata: ?*anyopaque) void {
        return wgpuInstanceRequestAdapter(self, options, callback, userdata);
    }
    extern fn wgpuInstanceRequestAdapter(instance: Instance, options: [*c]const RequestAdapterOptions, callback: RequestAdapterCallback, userdata: ?*anyopaque) void;

    pub inline fn reference(self: *Self) void {
        return wgpuInstanceReference(self);
    }
    extern fn wgpuInstanceReference(instance: Instance) void;

    pub inline fn release(self: *Self) void {
        return wgpuInstanceRelease(self);
    }
    extern fn wgpuInstanceRelease(instance: Instance) void;
};

pub const PipelineLayout = *opaque {
    const Self = @This();

    pub inline fn setLabel(self: *Self, label: ?[*:0]const u8) void {
        return wgpuPipelineLayoutSetLabel(self, label);
    }
    extern fn wgpuPipelineLayoutSetLabel(pipelineLayout: PipelineLayout, label: [*c]const u8) void;

    pub inline fn reference(self: *Self) void {
        return wgpuPipelineLayoutReference(self);
    }
    extern fn wgpuPipelineLayoutReference(pipelineLayout: PipelineLayout) void;

    pub inline fn release(self: *Self) void {
        return wgpuPipelineLayoutRelease(self);
    }
    extern fn wgpuPipelineLayoutRelease(pipelineLayout: PipelineLayout) void;
};

pub const QuerySet = *opaque {
    const Self = @This();

    pub inline fn destroy(self: *Self) void {
        return wgpuQuerySetDestroy(self);
    }
    extern fn wgpuQuerySetDestroy(querySet: QuerySet) void;

    pub inline fn getCount(self: *Self) u32 {
        return wgpuQuerySetGetCount(self);
    }
    extern fn wgpuQuerySetGetCount(querySet: QuerySet) u32;

    pub inline fn getType(self: *Self) QueryType {
        return wgpuQuerySetGetType(self);
    }
    extern fn wgpuQuerySetGetType(querySet: QuerySet) QueryType;

    pub inline fn setLabel(self: *Self, label: ?[*:0]const u8) void {
        return wgpuQuerySetSetLabel(self, label);
    }
    extern fn wgpuQuerySetSetLabel(querySet: QuerySet, label: [*c]const u8) void;

    pub inline fn reference(self: *Self) void {
        return wgpuQuerySetReference(self);
    }
    extern fn wgpuQuerySetReference(querySet: QuerySet) void;

    pub inline fn release(self: *Self) void {
        return wgpuQuerySetRelease(self);
    }
    extern fn wgpuQuerySetRelease(querySet: QuerySet) void;
};

pub const Queue = *opaque {
    const Self = @This();

    pub inline fn submitForIndex(self: *Self, command_count: usize, commands: *const CommandBuffer) SubmissionIndex {
        return wgpuQueueSubmitForIndex(self, command_count, commands);
    }
    extern fn wgpuQueueSubmitForIndex(queue: Queue, commandCount: usize, commands: [*c]const CommandBuffer) SubmissionIndex;

    pub inline fn onSubmittedWorkDone(self: *Self, callback: QueueWorkDoneCallback, userdata: ?*anyopaque) void {
        return wgpuQueueOnSubmittedWorkDone(self, callback, userdata);
    }
    extern fn wgpuQueueOnSubmittedWorkDone(queue: Queue, callback: QueueWorkDoneCallback, userdata: ?*anyopaque) void;

    pub inline fn setLabel(self: *Self, label: ?[*:0]const u8) void {
        return wgpuQueueSetLabel(self, label);
    }
    extern fn wgpuQueueSetLabel(queue: Queue, label: [*c]const u8) void;

    pub inline fn submit(self: *Self, command_count: usize, commands: [*c]const CommandBuffer) void {
        return wgpuQueueSubmit(self, command_count, commands);
    }
    extern fn wgpuQueueSubmit(queue: Queue, commandCount: usize, commands: [*c]const CommandBuffer) void;

    pub inline fn writeBuffer(self: *Self, buffer: Buffer, buffer_offset: u64, data: ?*const anyopaque, size: usize) void {
        return wgpuQueueWriteBuffer(self, buffer, buffer_offset, data, size);
    }
    extern fn wgpuQueueWriteBuffer(queue: Queue, buffer: Buffer, bufferOffset: u64, data: ?*const anyopaque, size: usize) void;

    pub inline fn writeTexture(self: *Self, destination: *const ImageCopyTexture, data: ?*const anyopaque, data_size: usize, data_layout: *const TextureDataLayout, write_size: *const Extent3D) void {
        return wgpuQueueWriteTexture(self, destination, data, data_size, data_layout, write_size);
    }
    extern fn wgpuQueueWriteTexture(queue: Queue, destination: [*c]const ImageCopyTexture, data: ?*const anyopaque, dataSize: usize, dataLayout: [*c]const TextureDataLayout, writeSize: [*c]const Extent3D) void;

    pub inline fn reference(self: *Self) void {
        return wgpuQueueReference(self);
    }
    extern fn wgpuQueueReference(queue: Queue) void;

    pub inline fn release(self: *Self) void {
        return wgpuQueueRelease(self);
    }
    extern fn wgpuQueueRelease(queue: Queue) void;
};

pub const RenderBundle = *opaque {
    const Self = @This();

    pub inline fn setLabel(self: *Self, label: ?[*:0]const u8) void {
        return wgpuRenderBundleSetLabel(self, label);
    }
    extern fn wgpuRenderBundleSetLabel(renderBundle: RenderBundle, label: [*c]const u8) void;

    pub inline fn reference(self: *Self) void {
        return wgpuRenderBundleReference(self);
    }
    extern fn wgpuRenderBundleReference(renderBundle: RenderBundle) void;

    pub inline fn release(self: *Self) void {
        return wgpuRenderBundleRelease(self);
    }
    extern fn wgpuRenderBundleRelease(renderBundle: RenderBundle) void;
};

pub const RenderBundleEncoder = *opaque {
    const Self = @This();

    pub inline fn draw(self: *Self, vertex_count: u32, instance_count: u32, first_vertex: u32, first_instance: u32) void {
        return wgpuRenderBundleEncoderDraw(self, vertex_count, instance_count, first_vertex, first_instance);
    }
    extern fn wgpuRenderBundleEncoderDraw(renderBundleEncoder: RenderBundleEncoder, vertexCount: u32, instanceCount: u32, firstVertex: u32, firstInstance: u32) void;

    pub inline fn drawIndexed(self: *Self, index_count: u32, instance_count: u32, first_index: u32, base_vertex: i32, first_instance: u32) void {
        return wgpuRenderBundleEncoderDrawIndexed(self, index_count, instance_count, first_index, base_vertex, first_instance);
    }
    extern fn wgpuRenderBundleEncoderDrawIndexed(renderBundleEncoder: RenderBundleEncoder, indexCount: u32, instanceCount: u32, firstIndex: u32, baseVertex: i32, firstInstance: u32) void;

    pub inline fn drawIndexedIndirect(self: *Self, indirect_buffer: Buffer, indirect_offset: u64) void {
        return wgpuRenderBundleEncoderDrawIndexedIndirect(self, indirect_buffer, indirect_offset);
    }
    extern fn wgpuRenderBundleEncoderDrawIndexedIndirect(renderBundleEncoder: RenderBundleEncoder, indirectBuffer: Buffer, indirectOffset: u64) void;

    pub inline fn drawIndirect(self: *Self, indirect_buffer: Buffer, indirect_offset: u64) void {
        return wgpuRenderBundleEncoderDrawIndirect(self, indirect_buffer, indirect_offset);
    }
    extern fn wgpuRenderBundleEncoderDrawIndirect(renderBundleEncoder: RenderBundleEncoder, indirectBuffer: Buffer, indirectOffset: u64) void;

    pub inline fn finish(self: *Self, descriptor: ?*const RenderBundleDescriptor) RenderBundle {
        return wgpuRenderBundleEncoderFinish(self, descriptor);
    }
    extern fn wgpuRenderBundleEncoderFinish(renderBundleEncoder: RenderBundleEncoder, descriptor: [*c]const RenderBundleDescriptor) RenderBundle;

    pub inline fn insertDebugMarker(self: *Self, marker_label: ?[*:0]const u8) void {
        return wgpuRenderBundleEncoderInsertDebugMarker(self, marker_label);
    }
    extern fn wgpuRenderBundleEncoderInsertDebugMarker(renderBundleEncoder: RenderBundleEncoder, markerLabel: [*c]const u8) void;

    pub inline fn popDebugGroup(self: *Self) void {
        return wgpuRenderBundleEncoderPopDebugGroup(self);
    }
    extern fn wgpuRenderBundleEncoderPopDebugGroup(renderBundleEncoder: RenderBundleEncoder) void;

    pub inline fn pushDebugGroup(self: *Self, group_label: ?[*:0]const u8) void {
        return wgpuRenderBundleEncoderPushDebugGroup(self, group_label);
    }
    extern fn wgpuRenderBundleEncoderPushDebugGroup(renderBundleEncoder: RenderBundleEncoder, groupLabel: [*c]const u8) void;

    pub inline fn setBindGroup(self: *Self, group_index: u32, group: BindGroup, dynamic_offset_count: usize, dynamic_offsets: ?[*]const u32) void {
        return wgpuRenderBundleEncoderSetBindGroup(self, group_index, group, dynamic_offset_count, dynamic_offsets);
    }
    extern fn wgpuRenderBundleEncoderSetBindGroup(renderBundleEncoder: RenderBundleEncoder, groupIndex: u32, group: BindGroup, dynamicOffsetCount: usize, dynamicOffsets: [*c]const u32) void;

    pub inline fn setIndexBuffer(self: *Self, buffer: Buffer, format: IndexFormat, offset: u64, size: u64) void {
        return wgpuRenderBundleEncoderSetIndexBuffer(self, buffer, format, offset, size);
    }
    extern fn wgpuRenderBundleEncoderSetIndexBuffer(renderBundleEncoder: RenderBundleEncoder, buffer: Buffer, format: IndexFormat, offset: u64, size: u64) void;

    pub inline fn setLabel(self: *Self, label: ?[*:0]const u8) void {
        return wgpuRenderBundleEncoderSetLabel(self, label);
    }
    extern fn wgpuRenderBundleEncoderSetLabel(renderBundleEncoder: RenderBundleEncoder, label: [*c]const u8) void;

    pub inline fn setPipeline(self: *Self, pipeline: RenderPipeline) void {
        return wgpuRenderBundleEncoderSetPipeline(self, pipeline);
    }
    extern fn wgpuRenderBundleEncoderSetPipeline(renderBundleEncoder: RenderBundleEncoder, pipeline: RenderPipeline) void;

    pub inline fn setVertexBuffer(self: *Self, slot: u32, buffer: Buffer, offset: u64, size: u64) void {
        return wgpuRenderBundleEncoderSetVertexBuffer(self, slot, buffer, offset, size);
    }
    extern fn wgpuRenderBundleEncoderSetVertexBuffer(renderBundleEncoder: RenderBundleEncoder, slot: u32, buffer: Buffer, offset: u64, size: u64) void;

    pub inline fn reference(self: *Self) void {
        return wgpuRenderBundleEncoderReference(self);
    }
    extern fn wgpuRenderBundleEncoderReference(renderBundleEncoder: RenderBundleEncoder) void;

    pub inline fn release(self: *Self) void {
        return wgpuRenderBundleEncoderRelease(self);
    }
    extern fn wgpuRenderBundleEncoderRelease(renderBundleEncoder: RenderBundleEncoder) void;
};

pub const RenderPassEncoder = *opaque {
    const Self = @This();

    pub inline fn setPushConstants(self: *Self, stages: ShaderStage, offset: u32, size_bytes: u32, data: ?*const anyopaque) void {
        return wgpuRenderPassEncoderSetPushConstants(self, stages, offset, size_bytes, data);
    }
    extern fn wgpuRenderPassEncoderSetPushConstants(encoder: RenderPassEncoder, stages: ShaderStage, offset: u32, sizeBytes: u32, data: ?*anyopaque) void;

    pub inline fn multiDrawIndirect(self: *Self, buffer: Buffer, offset: u64, count: u32) void {
        return wgpuRenderPassEncoderMultiDrawIndirect(self, buffer, offset, count);
    }
    extern fn wgpuRenderPassEncoderMultiDrawIndirect(encoder: RenderPassEncoder, buffer: Buffer, offset: u64, count: u32) void;

    pub inline fn multiDrawIndexedIndirect(self: *Self, buffer: Buffer, offset: u64, count: u32) void {
        return wgpuRenderPassEncoderMultiDrawIndexedIndirect(self, buffer, offset, count);
    }
    extern fn wgpuRenderPassEncoderMultiDrawIndexedIndirect(encoder: RenderPassEncoder, buffer: Buffer, offset: u64, count: u32) void;

    pub inline fn multiDrawIndirectCount(self: *Self, buffer: Buffer, offset: u64, count_buffer: Buffer, count_buffer_offset: u64, max_count: u32) void {
        return wgpuRenderPassEncoderMultiDrawIndirectCount(self, buffer, offset, count_buffer, count_buffer_offset, max_count);
    }
    extern fn wgpuRenderPassEncoderMultiDrawIndirectCount(encoder: RenderPassEncoder, buffer: Buffer, offset: u64, count_buffer: Buffer, count_buffer_offset: u64, max_count: u32) void;

    pub inline fn multiDrawIndexedIndirectCount(self: *Self, buffer: Buffer, offset: u64, count_buffer: Buffer, count_buffer_offset: u64, max_count: u32) void {
        return wgpuRenderPassEncoderMultiDrawIndexedIndirectCount(self, buffer, offset, count_buffer, count_buffer_offset, max_count);
    }
    extern fn wgpuRenderPassEncoderMultiDrawIndexedIndirectCount(encoder: RenderPassEncoder, buffer: Buffer, offset: u64, count_buffer: Buffer, count_buffer_offset: u64, max_count: u32) void;

    pub inline fn beginPipelineStatisticsQuery(self: *Self, query_set: QuerySet, query_index: u32) void {
        return wgpuRenderPassEncoderBeginPipelineStatisticsQuery(self, query_set, query_index);
    }
    extern fn wgpuRenderPassEncoderBeginPipelineStatisticsQuery(renderPassEncoder: RenderPassEncoder, querySet: QuerySet, queryIndex: u32) void;

    pub inline fn endPipelineStatisticsQuery(self: *Self) void {
        return wgpuRenderPassEncoderEndPipelineStatisticsQuery(self);
    }
    extern fn wgpuRenderPassEncoderEndPipelineStatisticsQuery(renderPassEncoder: RenderPassEncoder) void;

    pub inline fn beginOcclusionQuery(self: *Self, query_index: u32) void {
        return wgpuRenderPassEncoderBeginOcclusionQuery(self, query_index);
    }
    extern fn wgpuRenderPassEncoderBeginOcclusionQuery(renderPassEncoder: RenderPassEncoder, queryIndex: u32) void;

    pub inline fn draw(self: *Self, vertex_count: u32, instance_count: u32, first_vertex: u32, first_instance: u32) void {
        return wgpuRenderPassEncoderDraw(self, vertex_count, instance_count, first_vertex, first_instance);
    }
    extern fn wgpuRenderPassEncoderDraw(renderPassEncoder: RenderPassEncoder, vertexCount: u32, instanceCount: u32, firstVertex: u32, firstInstance: u32) void;

    pub inline fn drawIndexed(self: *Self, index_count: u32, instance_count: u32, first_index: u32, base_vertex: i32, first_instance: u32) void {
        return wgpuRenderPassEncoderDrawIndexed(self, index_count, instance_count, first_index, base_vertex, first_instance);
    }
    extern fn wgpuRenderPassEncoderDrawIndexed(renderPassEncoder: RenderPassEncoder, indexCount: u32, instanceCount: u32, firstIndex: u32, baseVertex: i32, firstInstance: u32) void;

    pub inline fn drawIndexedIndirect(self: *Self, indirect_buffer: Buffer, indirect_offset: u64) void {
        return wgpuRenderPassEncoderDrawIndexedIndirect(self, indirect_buffer, indirect_offset);
    }
    extern fn wgpuRenderPassEncoderDrawIndexedIndirect(renderPassEncoder: RenderPassEncoder, indirectBuffer: Buffer, indirectOffset: u64) void;

    pub inline fn drawIndirect(self: *Self, indirect_buffer: Buffer, indirect_offset: u64) void {
        return wgpuRenderPassEncoderDrawIndirect(self, indirect_buffer, indirect_offset);
    }
    extern fn wgpuRenderPassEncoderDrawIndirect(renderPassEncoder: RenderPassEncoder, indirectBuffer: Buffer, indirectOffset: u64) void;

    pub inline fn end(self: *Self) void {
        return wgpuRenderPassEncoderEnd(self);
    }
    extern fn wgpuRenderPassEncoderEnd(renderPassEncoder: RenderPassEncoder) void;

    pub inline fn endOcclusionQuery(self: *Self) void {
        return wgpuRenderPassEncoderEndOcclusionQuery(self);
    }
    extern fn wgpuRenderPassEncoderEndOcclusionQuery(renderPassEncoder: RenderPassEncoder) void;

    pub inline fn executeBundles(self: *Self, bundle_count: usize, bundles: *const RenderBundle) void {
        return wgpuRenderPassEncoderExecuteBundles(self, bundle_count, bundles);
    }
    extern fn wgpuRenderPassEncoderExecuteBundles(renderPassEncoder: RenderPassEncoder, bundleCount: usize, bundles: [*c]const RenderBundle) void;

    pub inline fn insertDebugMarker(self: *Self, marker_label: ?[*:0]const u8) void {
        return wgpuRenderPassEncoderInsertDebugMarker(self, marker_label);
    }
    extern fn wgpuRenderPassEncoderInsertDebugMarker(renderPassEncoder: RenderPassEncoder, markerLabel: [*c]const u8) void;

    pub inline fn popDebugGroup(self: *Self) void {
        return wgpuRenderPassEncoderPopDebugGroup(self);
    }
    extern fn wgpuRenderPassEncoderPopDebugGroup(renderPassEncoder: RenderPassEncoder) void;

    pub inline fn pushDebugGroup(self: *Self, group_label: ?[*:0]const u8) void {
        return wgpuRenderPassEncoderPushDebugGroup(self, group_label);
    }
    extern fn wgpuRenderPassEncoderPushDebugGroup(renderPassEncoder: RenderPassEncoder, groupLabel: [*c]const u8) void;

    pub inline fn setBindGroupWgpu(self: *Self, group_index: u32, group: BindGroup, dynamic_offset_count: usize, dynamic_offsets: ?[*]const u32) void {
        return wgpuRenderPassEncoderSetBindGroup(self, group_index, group, dynamic_offset_count, dynamic_offsets);
    }
    pub inline fn setBindGroup(render_pass_encoder: RenderPassEncoder, group_index: u32, group: BindGroup, dynamic_offsets: ?[]const u32) void {
        wgpuRenderPassEncoderSetBindGroup(
            render_pass_encoder,
            group_index,
            group,
            if (dynamic_offsets) |dynoff| @as(u32, @intCast(dynoff.len)) else 0,
            if (dynamic_offsets) |dynoff| dynoff.ptr else null,
        );
    }
    extern fn wgpuRenderPassEncoderSetBindGroup(renderPassEncoder: RenderPassEncoder, groupIndex: u32, group: BindGroup, dynamicOffsetCount: usize, dynamicOffsets: [*c]const u32) void;

    pub inline fn setBlendConstant(self: *Self, color: *const Color) void {
        return wgpuRenderPassEncoderSetBlendConstant(self, color);
    }
    extern fn wgpuRenderPassEncoderSetBlendConstant(renderPassEncoder: RenderPassEncoder, color: [*c]const Color) void;

    pub inline fn setIndexBuffer(self: *Self, buffer: Buffer, format: IndexFormat, offset: u64, size: u64) void {
        return wgpuRenderPassEncoderSetIndexBuffer(self, buffer, format, offset, size);
    }
    extern fn wgpuRenderPassEncoderSetIndexBuffer(renderPassEncoder: RenderPassEncoder, buffer: Buffer, format: IndexFormat, offset: u64, size: u64) void;

    pub inline fn setLabel(self: *Self, label: ?[*:0]const u8) void {
        return wgpuRenderPassEncoderSetLabel(self, label);
    }
    extern fn wgpuRenderPassEncoderSetLabel(renderPassEncoder: RenderPassEncoder, label: [*c]const u8) void;

    pub inline fn setPipeline(self: *@This(), pipeline: RenderPipeline) void {
        return wgpuRenderPassEncoderSetPipeline(self, pipeline);
    }
    extern fn wgpuRenderPassEncoderSetPipeline(renderPassEncoder: RenderPassEncoder, pipeline: RenderPipeline) void;

    pub inline fn setScissorRect(self: *Self, x: u32, y: u32, width: u32, height: u32) void {
        return wgpuRenderPassEncoderSetScissorRect(self, x, y, width, height);
    }
    extern fn wgpuRenderPassEncoderSetScissorRect(renderPassEncoder: RenderPassEncoder, x: u32, y: u32, width: u32, height: u32) void;

    pub inline fn setStencilReference(self: *Self, ref: u32) void {
        return wgpuRenderPassEncoderSetStencilReference(self, ref);
    }
    extern fn wgpuRenderPassEncoderSetStencilReference(renderPassEncoder: RenderPassEncoder, reference: u32) void;

    pub inline fn setVertexBuffer(self: *Self, slot: u32, buffer: Buffer, offset: u64, size: u64) void {
        return wgpuRenderPassEncoderSetVertexBuffer(self, slot, buffer, offset, size);
    }
    extern fn wgpuRenderPassEncoderSetVertexBuffer(renderPassEncoder: RenderPassEncoder, slot: u32, buffer: Buffer, offset: u64, size: u64) void;

    pub inline fn setViewport(self: *Self, x: f32, y: f32, width: f32, height: f32, min_depth: f32, max_depth: f32) void {
        return wgpuRenderPassEncoderSetViewport(self, x, y, width, height, min_depth, max_depth);
    }
    extern fn wgpuRenderPassEncoderSetViewport(renderPassEncoder: RenderPassEncoder, x: f32, y: f32, width: f32, height: f32, minDepth: f32, maxDepth: f32) void;

    pub inline fn reference(self: *Self) void {
        return wgpuRenderPassEncoderReference(self);
    }
    extern fn wgpuRenderPassEncoderReference(renderPassEncoder: RenderPassEncoder) void;

    pub inline fn release(self: *Self) void {
        return wgpuRenderPassEncoderRelease(self);
    }
    extern fn wgpuRenderPassEncoderRelease(renderPassEncoder: RenderPassEncoder) void;
};

pub const RenderPipeline = *opaque {
    const Self = @This();

    pub inline fn getBindGroupLayout(self: *Self, group_index: u32) BindGroupLayout {
        return wgpuRenderPipelineGetBindGroupLayout(self, group_index);
    }
    extern fn wgpuRenderPipelineGetBindGroupLayout(renderPipeline: RenderPipeline, groupIndex: u32) BindGroupLayout;

    pub inline fn setLabel(self: *Self, label: ?[*:0]const u8) void {
        return wgpuRenderPipelineSetLabel(self, label);
    }
    extern fn wgpuRenderPipelineSetLabel(renderPipeline: RenderPipeline, label: [*c]const u8) void;

    pub inline fn reference(self: *Self) void {
        return wgpuRenderPipelineReference(self);
    }
    extern fn wgpuRenderPipelineReference(renderPipeline: RenderPipeline) void;

    pub inline fn release(self: *Self) void {
        return wgpuRenderPipelineRelease(self);
    }
    extern fn wgpuRenderPipelineRelease(renderPipeline: RenderPipeline) void;
};

pub const Sampler = *opaque {
    const Self = @This();

    pub inline fn setLabel(self: *Self, label: ?[*:0]const u8) void {
        return wgpuSamplerSetLabel(self, label);
    }
    extern fn wgpuSamplerSetLabel(sampler: Sampler, label: [*c]const u8) void;

    pub inline fn reference(self: *Self) void {
        return wgpuSamplerReference(self);
    }
    extern fn wgpuSamplerReference(sampler: Sampler) void;

    pub inline fn release(self: *Self) void {
        return wgpuSamplerRelease(self);
    }
    extern fn wgpuSamplerRelease(sampler: Sampler) void;
};

pub const ShaderModule = *opaque {
    const Self = @This();

    pub inline fn getCompilationInfo(self: *Self, callback: CompilationInfoCallback, userdata: ?*anyopaque) void {
        return wgpuShaderModuleGetCompilationInfo(self, callback, userdata);
    }
    extern fn wgpuShaderModuleGetCompilationInfo(shaderModule: ShaderModule, callback: CompilationInfoCallback, userdata: ?*anyopaque) void;

    pub inline fn setLabel(self: *Self, label: ?[*:0]const u8) void {
        return wgpuShaderModuleSetLabel(self, label);
    }
    extern fn wgpuShaderModuleSetLabel(shaderModule: ShaderModule, label: [*c]const u8) void;

    pub inline fn reference(self: *Self) void {
        return wgpuShaderModuleReference(self);
    }
    extern fn wgpuShaderModuleReference(shaderModule: ShaderModule) void;

    pub inline fn release(self: *Self) void {
        return wgpuShaderModuleRelease(self);
    }
    extern fn wgpuShaderModuleRelease(shaderModule: ShaderModule) void;
};

pub const Surface = *opaque {
    const Self = @This();

    pub inline fn configure(self: *Self, config: *const SurfaceConfiguration) void {
        return wgpuSurfaceConfigure(self, config);
    }
    extern fn wgpuSurfaceConfigure(surface: Surface, config: [*c]const SurfaceConfiguration) void;

    pub inline fn getCapabilities(self: *Self, adapter: Adapter, capabilities: *SurfaceCapabilities) void {
        return wgpuSurfaceGetCapabilities(self, adapter, capabilities);
    }
    extern fn wgpuSurfaceGetCapabilities(surface: Surface, adapter: Adapter, capabilities: [*c]SurfaceCapabilities) void;

    pub inline fn getCurrentTexture(self: *Self, surface_texture: *SurfaceTexture) void {
        return wgpuSurfaceGetCurrentTexture(self, surface_texture);
    }
    extern fn wgpuSurfaceGetCurrentTexture(surface: Surface, surfaceTexture: [*c]SurfaceTexture) void;

    pub inline fn getPreferredFormat(self: *Self, adapter: Adapter) TextureFormat {
        return wgpuSurfaceGetPreferredFormat(self, adapter);
    }
    extern fn wgpuSurfaceGetPreferredFormat(surface: Surface, adapter: Adapter) TextureFormat;

    pub inline fn present(self: *Self) void {
        return wgpuSurfacePresent(self);
    }
    extern fn wgpuSurfacePresent(surface: Surface) void;

    pub inline fn unconfigure(self: *Self) void {
        return wgpuSurfaceUnconfigure(self);
    }
    extern fn wgpuSurfaceUnconfigure(surface: Surface) void;

    pub inline fn reference(self: *Self) void {
        return wgpuSurfaceReference(self);
    }
    extern fn wgpuSurfaceReference(surface: Surface) void;

    pub inline fn release(self: *Self) void {
        return wgpuSurfaceRelease(self);
    }
    extern fn wgpuSurfaceRelease(surface: Surface) void;

    pub inline fn capabilitiesFreeMembers(self: *Self) void {
        return wgpuSurfaceCapabilitiesFreeMembers(self);
    }
    extern fn wgpuSurfaceCapabilitiesFreeMembers(capabilities: SurfaceCapabilities) void;
};

pub const Texture = *opaque {
    const Self = @This();

    pub inline fn createView(self: *Self, descriptor: ?*const TextureViewDescriptor) TextureView {
        return wgpuTextureCreateView(self, descriptor);
    }
    extern fn wgpuTextureCreateView(texture: Texture, descriptor: [*c]const TextureViewDescriptor) TextureView;

    pub inline fn destroy(self: *Self) void {
        return wgpuTextureDestroy(self);
    }
    extern fn wgpuTextureDestroy(texture: Texture) void;

    pub inline fn getDepthOrArrayLayers(self: *Self) u32 {
        return wgpuTextureGetDepthOrArrayLayers(self);
    }
    extern fn wgpuTextureGetDepthOrArrayLayers(texture: Texture) u32;

    pub inline fn getDimension(self: *Self) TextureDimension {
        return wgpuTextureGetDimension(self);
    }
    extern fn wgpuTextureGetDimension(texture: Texture) TextureDimension;

    pub inline fn getFormat(self: *Self) TextureFormat {
        return wgpuTextureGetFormat(self);
    }
    extern fn wgpuTextureGetFormat(texture: Texture) TextureFormat;

    pub inline fn getHeight(self: *Self) u32 {
        return wgpuTextureGetHeight(self);
    }
    extern fn wgpuTextureGetHeight(texture: Texture) u32;

    pub inline fn getMipLevelCount(self: *Self) u32 {
        return wgpuTextureGetMipLevelCount(self);
    }
    extern fn wgpuTextureGetMipLevelCount(texture: Texture) u32;

    pub inline fn getSampleCount(self: *Self) u32 {
        return wgpuTextureGetSampleCount(self);
    }
    extern fn wgpuTextureGetSampleCount(texture: Texture) u32;

    pub inline fn getUsage(self: *Self) TextureUsage {
        return wgpuTextureGetUsage(self);
    }
    extern fn wgpuTextureGetUsage(texture: Texture) TextureUsage;

    pub inline fn getWidth(self: *Self) u32 {
        return wgpuTextureGetWidth(self);
    }
    extern fn wgpuTextureGetWidth(texture: Texture) u32;

    pub inline fn setLabel(self: *Self, label: ?[*:0]const u8) void {
        return wgpuTextureSetLabel(self, label);
    }
    extern fn wgpuTextureSetLabel(texture: Texture, label: [*c]const u8) void;

    pub inline fn reference(self: *Self) void {
        return wgpuTextureReference(self);
    }
    extern fn wgpuTextureReference(texture: Texture) void;

    pub inline fn release(self: *Self) void {
        return wgpuTextureRelease(self);
    }
    extern fn wgpuTextureRelease(texture: Texture) void;
};

pub const TextureView = *opaque {
    const Self = @This();

    pub inline fn setLabel(self: *Self, label: ?[*:0]const u8) void {
        return wgpuTextureViewSetLabel(self, label);
    }
    extern fn wgpuTextureViewSetLabel(textureView: TextureView, label: [*c]const u8) void;

    pub inline fn reference(self: *Self) void {
        return wgpuTextureViewReference(self);
    }
    extern fn wgpuTextureViewReference(textureView: TextureView) void;

    pub inline fn release(self: *Self) void {
        return wgpuTextureViewRelease(self);
    }
    extern fn wgpuTextureViewRelease(textureView: TextureView) void;
};
