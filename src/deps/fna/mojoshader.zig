pub const Effect = extern struct {
    error_count: c_int,
    errors: [*c]Error,
    param_count: c_int,
    params: [*c]EffectParam,
    technique_count: c_int,
    techniques: [*c]EffectTechnique,
    object_count: c_int,
    objects: [*c]EffectObject,
    current_technique: [*c]const EffectTechnique,
    current_pass: c_int,
    restore_shader_state: c_int,
    state_changes: [*c]EffectStateChanges,
    current_vert_raw: [*c]EffectShader,
    current_pixl_raw: [*c]EffectShader,
    current_vert: ?*c_void,
    current_pixl: ?*c_void,
    prev_vertex_shader: ?*c_void,
    prev_pixel_shader: ?*c_void,
    ctx: EffectShaderContext,
};

pub const EffectTechnique = extern struct {
    name: [*c]const u8,
    pass_count: c_uint,
    passes: [*c]EffectPass,
    annotation_count: c_uint,
    annotations: [*c]EffectAnnotation,
};

pub const EffectShader = extern struct {
    type: SymbolType,
    technique: c_uint,
    pass: c_uint,
    is_preshader: c_uint,
    preshader_param_count: c_uint,
    preshader_params: [*c]c_uint,
    param_count: c_uint,
    params: [*c]c_uint,
    sampler_count: c_uint,
    samplers: [*c]SamplerStateRegister,
    unnamed_0: union_unnamed_13,
};

const union_unnamed_13 = extern union {
    shader: ?*c_void,
    preshader: [*c]const MOJOSHADER_preshader,
};

pub const EffectParam = extern struct {
    value: EffectValue,
    annotation_count: c_uint,
    annotations: [*c]EffectAnnotation,
};

pub const EffectValue = extern struct {
    name: [*c]const u8,
    semantic: [*c]const u8,
    type: SymbolTypeInfo,
    value_count: c_uint,
    value: extern union {
        values: ?*c_void,
        int: [*c]c_int,
        float: [*c]f32,
        // valuesZBT: [*c]MOJOSHADER_zBufferType,
        // valuesFiM: [*c]MOJOSHADER_fillMode,
        // valuesSM: [*c]MOJOSHADER_shadeMode,
        // valuesBM: [*c]MOJOSHADER_blendMode,
        // valuesCM: [*c]MOJOSHADER_cullMode,
        // valuesCF: [*c]MOJOSHADER_compareFunc,
        // valuesFoM: [*c]MOJOSHADER_fogMode,
        // valuesSO: [*c]MOJOSHADER_stencilOp,
        // valuesMCS: [*c]MOJOSHADER_materialColorSource,
        // valuesVBF: [*c]MOJOSHADER_vertexBlendFlags,
        // valuesPES: [*c]MOJOSHADER_patchedEdgeStyle,
        // valuesDMT: [*c]MOJOSHADER_debugMonitorTokens,
        // valuesBO: [*c]MOJOSHADER_blendOp,
        // valuesDT: [*c]MOJOSHADER_degreeType,
        // valuesTA: [*c]MOJOSHADER_textureAddress,
        // valuesTFT: [*c]MOJOSHADER_textureFilterType,
        // valuesSS: [*c]MOJOSHADER_effectSamplerState,
    },
};

pub const SymbolTypeInfo = extern struct {
    parameter_class: SymbolClass,
    parameter_type: SymbolType,
    rows: c_uint,
    columns: c_uint,
    elements: c_uint,
    member_count: c_uint,
    members: [*c]MOJOSHADER_symbolStructMember,
};

pub const EffectObject = extern union {
    type: SymbolType,
    unnamed_union: extern union {
        shader: EffectShader,
        mapping: MOJOSHADER_effectSamplerMap,
        string: MOJOSHADER_effectString,
        texture: MOJOSHADER_effectTexture,
    },
};

pub const EffectShaderContext = extern struct {
    compileShader: MOJOSHADER_compileShaderFunc,
    shaderAddRef: MOJOSHADER_shaderAddRefFunc,
    deleteShader: MOJOSHADER_deleteShaderFunc,
    getParseData: MOJOSHADER_getParseDataFunc,
    bindShaders: MOJOSHADER_bindShadersFunc,
    getBoundShaders: MOJOSHADER_getBoundShadersFunc,
    mapUniformBufferMemory: MOJOSHADER_mapUniformBufferMemoryFunc,
    unmapUniformBufferMemory: MOJOSHADER_unmapUniformBufferMemoryFunc,
    m: MOJOSHADER_malloc,
    f: MOJOSHADER_free,
    malloc_data: ?*c_void,
};

pub const EffectPass = extern struct {
    name: [*c]const u8,
    state_count: c_uint,
    states: [*c]MOJOSHADER_effectState,
    annotation_count: c_uint,
    annotations: [*c]EffectAnnotation,
};

pub const SamplerStateRegister = extern struct {
    sampler_name: [*c]const u8,
    sampler_register: c_uint,
    sampler_state_count: c_uint,
    sampler_states: [*c]const MOJOSHADER_effectSamplerState,
};

pub const Error = extern struct {
    @"error": [*c]const u8,
    filename: [*c]const u8,
    error_position: c_int,
};

const SymbolType = extern enum(c_int) {
    void = 0,
    bool = 1,
    int = 2,
    float = 3,
    string = 4,
    texture = 5,
    texture1d = 6,
    texture2d = 7,
    texture3d = 8,
    texture_cube = 9,
    sampler = 10,
    sampler1d = 11,
    sampler2d = 12,
    sampler3d = 13,
    sampler_cube = 14,
    pixel_shader = 15,
    vertex_shader = 16,
    pixel_fragment = 17,
    vertex_fragment = 18,
    unsupported = 19,
    total = 20,
};

pub const EffectAnnotation = EffectValue;

pub const EffectStateChanges = extern struct {
    render_state_change_count: c_uint,
    render_state_changes: [*c]const MOJOSHADER_effectState,
    sampler_state_change_count: c_uint,
    sampler_state_changes: [*c]const SamplerStateRegister,
    vertex_sampler_state_change_count: c_uint,
    vertex_sampler_state_changes: [*c]const SamplerStateRegister,
};

pub const MOJOSHADER_malloc = ?fn (c_int, ?*c_void) callconv(.C) ?*c_void;
pub const MOJOSHADER_free = ?fn (?*c_void, ?*c_void) callconv(.C) void;

const enum_unnamed_1 = extern enum(c_int) {
    MOJOSHADER_TYPE_UNKNOWN = 0,
    MOJOSHADER_TYPE_PIXEL = 1,
    MOJOSHADER_TYPE_VERTEX = 2,
    MOJOSHADER_TYPE_GEOMETRY = 4,
    MOJOSHADER_TYPE_ANY = 2147483647,
    _,
};
pub const MOJOSHADER_shaderType = enum_unnamed_1;

const enum_unnamed_2 = extern enum(c_int) {
    MOJOSHADER_ATTRIBUTE_UNKNOWN = -1,
    MOJOSHADER_ATTRIBUTE_BYTE = 0,
    MOJOSHADER_ATTRIBUTE_UBYTE = 1,
    MOJOSHADER_ATTRIBUTE_SHORT = 2,
    MOJOSHADER_ATTRIBUTE_USHORT = 3,
    MOJOSHADER_ATTRIBUTE_INT = 4,
    MOJOSHADER_ATTRIBUTE_UINT = 5,
    MOJOSHADER_ATTRIBUTE_FLOAT = 6,
    MOJOSHADER_ATTRIBUTE_DOUBLE = 7,
    MOJOSHADER_ATTRIBUTE_HALF_FLOAT = 8,
    _,
};

const enum_unnamed_3 = extern enum(c_int) {
    MOJOSHADER_UNIFORM_UNKNOWN = -1,
    MOJOSHADER_UNIFORM_FLOAT = 0,
    MOJOSHADER_UNIFORM_INT = 1,
    MOJOSHADER_UNIFORM_BOOL = 2,
    _,
};
pub const MOJOSHADER_uniformType = enum_unnamed_3;
pub const struct_MOJOSHADER_uniform = extern struct {
    type: MOJOSHADER_uniformType,
    index: c_int,
    array_count: c_int,
    constant: c_int,
    name: [*c]const u8,
};
pub const MOJOSHADER_uniform = struct_MOJOSHADER_uniform;
const union_unnamed_4 = extern union {
    f: [4]f32,
    i: [4]c_int,
    b: c_int,
};
pub const struct_MOJOSHADER_constant = extern struct {
    type: MOJOSHADER_uniformType,
    index: c_int,
    value: union_unnamed_4,
};
pub const MOJOSHADER_constant = struct_MOJOSHADER_constant;

const enum_unnamed_5 = extern enum(c_int) {
    MOJOSHADER_SAMPLER_UNKNOWN = -1,
    MOJOSHADER_SAMPLER_2D = 0,
    MOJOSHADER_SAMPLER_CUBE = 1,
    MOJOSHADER_SAMPLER_VOLUME = 2,
    _,
};
pub const MOJOSHADER_samplerType = enum_unnamed_5;
pub const struct_MOJOSHADER_sampler = extern struct {
    type: MOJOSHADER_samplerType,
    index: c_int,
    name: [*c]const u8,
    texbem: c_int,
};
pub const MOJOSHADER_sampler = struct_MOJOSHADER_sampler;
pub const struct_MOJOSHADER_samplerMap = extern struct {
    index: c_int,
    type: MOJOSHADER_samplerType,
};
pub const MOJOSHADER_samplerMap = struct_MOJOSHADER_samplerMap;

const enum_unnamed_6 = extern enum(c_int) {
    MOJOSHADER_USAGE_UNKNOWN = -1,
    MOJOSHADER_USAGE_POSITION = 0,
    MOJOSHADER_USAGE_BLENDWEIGHT = 1,
    MOJOSHADER_USAGE_BLENDINDICES = 2,
    MOJOSHADER_USAGE_NORMAL = 3,
    MOJOSHADER_USAGE_POINTSIZE = 4,
    MOJOSHADER_USAGE_TEXCOORD = 5,
    MOJOSHADER_USAGE_TANGENT = 6,
    MOJOSHADER_USAGE_BINORMAL = 7,
    MOJOSHADER_USAGE_TESSFACTOR = 8,
    MOJOSHADER_USAGE_POSITIONT = 9,
    MOJOSHADER_USAGE_COLOR = 10,
    MOJOSHADER_USAGE_FOG = 11,
    MOJOSHADER_USAGE_DEPTH = 12,
    MOJOSHADER_USAGE_SAMPLE = 13,
    MOJOSHADER_USAGE_TOTAL = 14,
    _,
};
pub const MOJOSHADER_usage = enum_unnamed_6;
pub const struct_MOJOSHADER_attribute = extern struct {
    usage: MOJOSHADER_usage,
    index: c_int,
    name: [*c]const u8,
};
pub const MOJOSHADER_attribute = struct_MOJOSHADER_attribute;
pub const struct_MOJOSHADER_swizzle = extern struct {
    usage: MOJOSHADER_usage,
    index: c_uint,
    swizzles: [4]u8,
};
pub const MOJOSHADER_swizzle = struct_MOJOSHADER_swizzle;

const SymbolRegisterSet = extern enum(c_int) {
    bool = 0,
    int4 = 1,
    float4 = 2,
    sampler = 3,
    total = 4,
};

const SymbolClass = extern enum(c_int) {
    scalar = 0,
    vector = 1,
    matrix_ros = 2,
    matrix_columns = 3,
    object = 4,
    struct_ = 5,
    total = 6,
};

pub const struct_MOJOSHADER_symbolStructMember = extern struct {
    name: [*c]const u8,
    info: SymbolTypeInfo,
};
pub const MOJOSHADER_symbolStructMember = struct_MOJOSHADER_symbolStructMember;

pub const struct_MOJOSHADER_symbol = extern struct {
    name: [*c]const u8,
    register_set: SymbolRegisterSet,
    register_index: c_uint,
    register_count: c_uint,
    info: SymbolTypeInfo,
};
pub const MOJOSHADER_symbol = struct_MOJOSHADER_symbol;

pub const enum_MOJOSHADER_preshaderOpcode = extern enum(c_int) {
    MOJOSHADER_PRESHADEROP_NOP = 0,
    MOJOSHADER_PRESHADEROP_MOV = 1,
    MOJOSHADER_PRESHADEROP_NEG = 2,
    MOJOSHADER_PRESHADEROP_RCP = 3,
    MOJOSHADER_PRESHADEROP_FRC = 4,
    MOJOSHADER_PRESHADEROP_EXP = 5,
    MOJOSHADER_PRESHADEROP_LOG = 6,
    MOJOSHADER_PRESHADEROP_RSQ = 7,
    MOJOSHADER_PRESHADEROP_SIN = 8,
    MOJOSHADER_PRESHADEROP_COS = 9,
    MOJOSHADER_PRESHADEROP_ASIN = 10,
    MOJOSHADER_PRESHADEROP_ACOS = 11,
    MOJOSHADER_PRESHADEROP_ATAN = 12,
    MOJOSHADER_PRESHADEROP_MIN = 13,
    MOJOSHADER_PRESHADEROP_MAX = 14,
    MOJOSHADER_PRESHADEROP_LT = 15,
    MOJOSHADER_PRESHADEROP_GE = 16,
    MOJOSHADER_PRESHADEROP_ADD = 17,
    MOJOSHADER_PRESHADEROP_MUL = 18,
    MOJOSHADER_PRESHADEROP_ATAN2 = 19,
    MOJOSHADER_PRESHADEROP_DIV = 20,
    MOJOSHADER_PRESHADEROP_CMP = 21,
    MOJOSHADER_PRESHADEROP_MOVC = 22,
    MOJOSHADER_PRESHADEROP_DOT = 23,
    MOJOSHADER_PRESHADEROP_NOISE = 24,
    MOJOSHADER_PRESHADEROP_SCALAR_OPS = 25,
    MOJOSHADER_PRESHADEROP_MIN_SCALAR = 25,
    MOJOSHADER_PRESHADEROP_MAX_SCALAR = 26,
    MOJOSHADER_PRESHADEROP_LT_SCALAR = 27,
    MOJOSHADER_PRESHADEROP_GE_SCALAR = 28,
    MOJOSHADER_PRESHADEROP_ADD_SCALAR = 29,
    MOJOSHADER_PRESHADEROP_MUL_SCALAR = 30,
    MOJOSHADER_PRESHADEROP_ATAN2_SCALAR = 31,
    MOJOSHADER_PRESHADEROP_DIV_SCALAR = 32,
    MOJOSHADER_PRESHADEROP_DOT_SCALAR = 33,
    MOJOSHADER_PRESHADEROP_NOISE_SCALAR = 34,
    _,
};
pub const MOJOSHADER_preshaderOpcode = enum_MOJOSHADER_preshaderOpcode;
pub const MOJOSHADER_PRESHADEROPERAND_INPUT = @enumToInt(enum_MOJOSHADER_preshaderOperandType.MOJOSHADER_PRESHADEROPERAND_INPUT);
pub const MOJOSHADER_PRESHADEROPERAND_OUTPUT = @enumToInt(enum_MOJOSHADER_preshaderOperandType.MOJOSHADER_PRESHADEROPERAND_OUTPUT);
pub const MOJOSHADER_PRESHADEROPERAND_LITERAL = @enumToInt(enum_MOJOSHADER_preshaderOperandType.MOJOSHADER_PRESHADEROPERAND_LITERAL);
pub const MOJOSHADER_PRESHADEROPERAND_TEMP = @enumToInt(enum_MOJOSHADER_preshaderOperandType.MOJOSHADER_PRESHADEROPERAND_TEMP);
pub const enum_MOJOSHADER_preshaderOperandType = extern enum(c_int) {
    MOJOSHADER_PRESHADEROPERAND_INPUT,
    MOJOSHADER_PRESHADEROPERAND_OUTPUT,
    MOJOSHADER_PRESHADEROPERAND_LITERAL,
    MOJOSHADER_PRESHADEROPERAND_TEMP,
    _,
};
pub const MOJOSHADER_preshaderOperandType = enum_MOJOSHADER_preshaderOperandType;
pub const struct_MOJOSHADER_preshaderOperand = extern struct {
    type: MOJOSHADER_preshaderOperandType,
    index: c_uint,
    array_register_count: c_uint,
    array_registers: [*c]c_uint,
};
pub const MOJOSHADER_preshaderOperand = struct_MOJOSHADER_preshaderOperand;
pub const struct_MOJOSHADER_preshaderInstruction = extern struct {
    opcode: MOJOSHADER_preshaderOpcode,
    element_count: c_uint,
    operand_count: c_uint,
    operands: [4]MOJOSHADER_preshaderOperand,
};
pub const MOJOSHADER_preshaderInstruction = struct_MOJOSHADER_preshaderInstruction;
pub const struct_MOJOSHADER_preshader = extern struct {
    literal_count: c_uint,
    literals: [*c]f64,
    temp_count: c_uint,
    symbol_count: c_uint,
    symbols: [*c]MOJOSHADER_symbol,
    instruction_count: c_uint,
    instructions: [*c]MOJOSHADER_preshaderInstruction,
    register_count: c_uint,
    registers: [*c]f32,
    malloc: MOJOSHADER_malloc,
    free: MOJOSHADER_free,
    malloc_data: ?*c_void,
};
pub const MOJOSHADER_preshader = struct_MOJOSHADER_preshader;
pub const struct_MOJOSHADER_parseData = extern struct {
    error_count: c_int,
    errors: [*c]Error,
    profile: [*c]const u8,
    output: [*c]const u8,
    output_len: c_int,
    instruction_count: c_int,
    shader_type: MOJOSHADER_shaderType,
    major_ver: c_int,
    minor_ver: c_int,
    mainfn: [*c]const u8,
    uniform_count: c_int,
    uniforms: [*c]MOJOSHADER_uniform,
    constant_count: c_int,
    constants: [*c]MOJOSHADER_constant,
    sampler_count: c_int,
    samplers: [*c]MOJOSHADER_sampler,
    attribute_count: c_int,
    attributes: [*c]MOJOSHADER_attribute,
    output_count: c_int,
    outputs: [*c]MOJOSHADER_attribute,
    swizzle_count: c_int,
    swizzles: [*c]MOJOSHADER_swizzle,
    symbol_count: c_int,
    symbols: [*c]MOJOSHADER_symbol,
    preshader: [*c]MOJOSHADER_preshader,
    malloc: MOJOSHADER_malloc,
    free: MOJOSHADER_free,
    malloc_data: ?*c_void,
};
pub const MOJOSHADER_parseData = struct_MOJOSHADER_parseData;
pub extern fn MOJOSHADER_maxShaderModel(profile: [*c]const u8) c_int;
pub extern fn MOJOSHADER_parse(profile: [*c]const u8, mainfn: [*c]const u8, tokenbuf: [*c]const u8, bufsize: c_uint, swiz: [*c]const MOJOSHADER_swizzle, swizcount: c_uint, smap: [*c]const MOJOSHADER_samplerMap, smapcount: c_uint, m: MOJOSHADER_malloc, f: MOJOSHADER_free, d: ?*c_void) [*c]const MOJOSHADER_parseData;
pub extern fn MOJOSHADER_freeParseData(data: [*c]const MOJOSHADER_parseData) void;
pub extern fn MOJOSHADER_parsePreshader(buf: [*c]const u8, len: c_uint, m: MOJOSHADER_malloc, f: MOJOSHADER_free, d: ?*c_void) [*c]const MOJOSHADER_preshader;
pub extern fn MOJOSHADER_freePreshader(preshader: [*c]const MOJOSHADER_preshader) void;
pub const struct_MOJOSHADER_preprocessorDefine = extern struct {
    identifier: [*c]const u8,
    definition: [*c]const u8,
};
pub const MOJOSHADER_preprocessorDefine = struct_MOJOSHADER_preprocessorDefine;
pub const MOJOSHADER_INCLUDETYPE_LOCAL = @enumToInt(enum_unnamed_10.MOJOSHADER_INCLUDETYPE_LOCAL);
pub const MOJOSHADER_INCLUDETYPE_SYSTEM = @enumToInt(enum_unnamed_10.MOJOSHADER_INCLUDETYPE_SYSTEM);
const enum_unnamed_10 = extern enum(c_int) {
    MOJOSHADER_INCLUDETYPE_LOCAL,
    MOJOSHADER_INCLUDETYPE_SYSTEM,
    _,
};
pub const MOJOSHADER_includeType = enum_unnamed_10;
pub const struct_MOJOSHADER_preprocessData = extern struct {
    error_count: c_int,
    errors: [*c]Error,
    output: [*c]const u8,
    output_len: c_int,
    malloc: MOJOSHADER_malloc,
    free: MOJOSHADER_free,
    malloc_data: ?*c_void,
};
pub const MOJOSHADER_preprocessData = struct_MOJOSHADER_preprocessData;
pub const MOJOSHADER_includeOpen = ?fn (MOJOSHADER_includeType, [*c]const u8, [*c]const u8, [*c][*c]const u8, [*c]c_uint, MOJOSHADER_malloc, MOJOSHADER_free, ?*c_void) callconv(.C) c_int;
pub const MOJOSHADER_includeClose = ?fn ([*c]const u8, MOJOSHADER_malloc, MOJOSHADER_free, ?*c_void) callconv(.C) void;
pub extern fn MOJOSHADER_preprocess(filename: [*c]const u8, source: [*c]const u8, sourcelen: c_uint, defines: [*c]const MOJOSHADER_preprocessorDefine, define_count: c_uint, include_open: MOJOSHADER_includeOpen, include_close: MOJOSHADER_includeClose, m: MOJOSHADER_malloc, f: MOJOSHADER_free, d: ?*c_void) [*c]const MOJOSHADER_preprocessData;
pub extern fn MOJOSHADER_freePreprocessData(data: [*c]const MOJOSHADER_preprocessData) void;
pub extern fn MOJOSHADER_assemble(filename: [*c]const u8, source: [*c]const u8, sourcelen: c_uint, comments: [*c][*c]const u8, comment_count: c_uint, symbols: [*c]const MOJOSHADER_symbol, symbol_count: c_uint, defines: [*c]const MOJOSHADER_preprocessorDefine, define_count: c_uint, include_open: MOJOSHADER_includeOpen, include_close: MOJOSHADER_includeClose, m: MOJOSHADER_malloc, f: MOJOSHADER_free, d: ?*c_void) [*c]const MOJOSHADER_parseData;

pub extern fn MOJOSHADER_compile(srcprofile: [*c]const u8, filename: [*c]const u8, source: [*c]const u8, sourcelen: c_uint, defs: [*c]const MOJOSHADER_preprocessorDefine, define_count: c_uint, include_open: MOJOSHADER_includeOpen, include_close: MOJOSHADER_includeClose, m: MOJOSHADER_malloc, f: MOJOSHADER_free, d: ?*c_void) [*c]const MOJOSHADER_compileData;
pub extern fn MOJOSHADER_freeCompileData(data: [*c]const MOJOSHADER_compileData) void;
pub const MOJOSHADER_glGetProcAddress = ?fn ([*c]const u8, ?*c_void) callconv(.C) ?*c_void;
pub const struct_MOJOSHADER_glContext = @Type(.Opaque);
pub const MOJOSHADER_glContext = struct_MOJOSHADER_glContext;
pub const struct_MOJOSHADER_glShader = @Type(.Opaque);
pub const MOJOSHADER_glShader = struct_MOJOSHADER_glShader;
pub const struct_MOJOSHADER_glProgram = @Type(.Opaque);
pub const MOJOSHADER_glProgram = struct_MOJOSHADER_glProgram;
pub extern fn MOJOSHADER_glAvailableProfiles(lookup: MOJOSHADER_glGetProcAddress, lookup_d: ?*c_void, profs: [*c][*c]const u8, size: c_int, m: MOJOSHADER_malloc, f: MOJOSHADER_free, malloc_d: ?*c_void) c_int;
pub extern fn MOJOSHADER_glBestProfile(lookup: MOJOSHADER_glGetProcAddress, lookup_d: ?*c_void, m: MOJOSHADER_malloc, f: MOJOSHADER_free, malloc_d: ?*c_void) [*c]const u8;
pub extern fn MOJOSHADER_glCreateContext(profile: [*c]const u8, lookup: MOJOSHADER_glGetProcAddress, lookup_d: ?*c_void, m: MOJOSHADER_malloc, f: MOJOSHADER_free, malloc_d: ?*c_void) ?*MOJOSHADER_glContext;
pub extern fn MOJOSHADER_glMakeContextCurrent(ctx: ?*MOJOSHADER_glContext) void;
pub extern fn MOJOSHADER_glGetError() [*c]const u8;
pub extern fn MOJOSHADER_glMaxUniforms(shader_type: MOJOSHADER_shaderType) c_int;
pub extern fn MOJOSHADER_glCompileShader(tokenbuf: [*c]const u8, bufsize: c_uint, swiz: [*c]const MOJOSHADER_swizzle, swizcount: c_uint, smap: [*c]const MOJOSHADER_samplerMap, smapcount: c_uint) ?*MOJOSHADER_glShader;
pub extern fn MOJOSHADER_glShaderAddRef(shader: ?*MOJOSHADER_glShader) void;
pub extern fn MOJOSHADER_glGetShaderParseData(shader: ?*MOJOSHADER_glShader) [*c]const MOJOSHADER_parseData;
pub extern fn MOJOSHADER_glLinkProgram(vshader: ?*MOJOSHADER_glShader, pshader: ?*MOJOSHADER_glShader) ?*MOJOSHADER_glProgram;
pub extern fn MOJOSHADER_glBindProgram(program: ?*MOJOSHADER_glProgram) void;
pub extern fn MOJOSHADER_glBindShaders(vshader: ?*MOJOSHADER_glShader, pshader: ?*MOJOSHADER_glShader) void;
pub extern fn MOJOSHADER_glGetBoundShaders(vshader: [*c]?*MOJOSHADER_glShader, pshader: [*c]?*MOJOSHADER_glShader) void;
pub extern fn MOJOSHADER_glSetVertexShaderUniformF(idx: c_uint, data: [*c]const f32, vec4count: c_uint) void;
pub extern fn MOJOSHADER_glGetVertexShaderUniformF(idx: c_uint, data: [*c]f32, vec4count: c_uint) void;
pub extern fn MOJOSHADER_glSetVertexShaderUniformI(idx: c_uint, data: [*c]const c_int, ivec4count: c_uint) void;
pub extern fn MOJOSHADER_glGetVertexShaderUniformI(idx: c_uint, data: [*c]c_int, ivec4count: c_uint) void;
pub extern fn MOJOSHADER_glSetVertexShaderUniformB(idx: c_uint, data: [*c]const c_int, bcount: c_uint) void;
pub extern fn MOJOSHADER_glGetVertexShaderUniformB(idx: c_uint, data: [*c]c_int, bcount: c_uint) void;
pub extern fn MOJOSHADER_glSetPixelShaderUniformF(idx: c_uint, data: [*c]const f32, vec4count: c_uint) void;
pub extern fn MOJOSHADER_glGetPixelShaderUniformF(idx: c_uint, data: [*c]f32, vec4count: c_uint) void;
pub extern fn MOJOSHADER_glSetPixelShaderUniformI(idx: c_uint, data: [*c]const c_int, ivec4count: c_uint) void;
pub extern fn MOJOSHADER_glGetPixelShaderUniformI(idx: c_uint, data: [*c]c_int, ivec4count: c_uint) void;
pub extern fn MOJOSHADER_glSetPixelShaderUniformB(idx: c_uint, data: [*c]const c_int, bcount: c_uint) void;
pub extern fn MOJOSHADER_glGetPixelShaderUniformB(idx: c_uint, data: [*c]c_int, bcount: c_uint) void;
pub extern fn MOJOSHADER_glMapUniformBufferMemory(vsf: [*c][*c]f32, vsi: [*c][*c]c_int, vsb: [*c][*c]u8, psf: [*c][*c]f32, psi: [*c][*c]c_int, psb: [*c][*c]u8) void;
pub extern fn MOJOSHADER_glUnmapUniformBufferMemory(...) void;
pub extern fn MOJOSHADER_glSetLegacyBumpMapEnv(sampler: c_uint, mat00: f32, mat01: f32, mat10: f32, mat11: f32, lscale: f32, loffset: f32) void;
pub extern fn MOJOSHADER_glGetVertexAttribLocation(usage: MOJOSHADER_usage, index: c_int) c_int;
pub extern fn MOJOSHADER_glSetVertexAttribute(usage: MOJOSHADER_usage, index: c_int, size: c_uint, type: MOJOSHADER_attributeType, normalized: c_int, stride: c_uint, ptr: ?*const c_void) void;
pub extern fn MOJOSHADER_glSetVertexAttribDivisor(usage: MOJOSHADER_usage, index: c_int, divisor: c_uint) void;
pub extern fn MOJOSHADER_glProgramReady() void;
pub extern fn MOJOSHADER_glProgramViewportInfo(viewportW: c_int, viewportH: c_int, backbufferW: c_int, backbufferH: c_int, renderTargetBound: c_int) void;
pub extern fn MOJOSHADER_glDeleteProgram(program: ?*MOJOSHADER_glProgram) void;
pub extern fn MOJOSHADER_glDeleteShader(shader: ?*MOJOSHADER_glShader) void;
pub extern fn MOJOSHADER_glDestroyContext(ctx: ?*MOJOSHADER_glContext) void;
pub const struct_MOJOSHADER_mtlShader = @Type(.Opaque);
pub const MOJOSHADER_mtlShader = struct_MOJOSHADER_mtlShader;
pub extern fn MOJOSHADER_mtlCreateContext(mtlDevice: ?*c_void, framesInFlight: c_int, m: MOJOSHADER_malloc, f: MOJOSHADER_free, malloc_d: ?*c_void) c_int;
pub extern fn MOJOSHADER_mtlGetError() [*c]const u8;
pub extern fn MOJOSHADER_mtlCompileShader(mainfn: [*c]const u8, tokenbuf: [*c]const u8, bufsize: c_uint, swiz: [*c]const MOJOSHADER_swizzle, swizcount: c_uint, smap: [*c]const MOJOSHADER_samplerMap, smapcount: c_uint) ?*MOJOSHADER_mtlShader;
pub extern fn MOJOSHADER_mtlShaderAddRef(shader: ?*MOJOSHADER_mtlShader) void;
pub extern fn MOJOSHADER_mtlGetShaderParseData(shader: ?*MOJOSHADER_mtlShader) [*c]const MOJOSHADER_parseData;
pub extern fn MOJOSHADER_mtlBindShaders(vshader: ?*MOJOSHADER_mtlShader, pshader: ?*MOJOSHADER_mtlShader) void;
pub extern fn MOJOSHADER_mtlGetBoundShaders(vshader: [*c]?*MOJOSHADER_mtlShader, pshader: [*c]?*MOJOSHADER_mtlShader) void;
pub extern fn MOJOSHADER_mtlGetUniformBuffers(vbuf: [*c]?*c_void, voff: [*c]c_int, pbuf: [*c]?*c_void, poff: [*c]c_int) void;
pub extern fn MOJOSHADER_mtlMapUniformBufferMemory(vsf: [*c][*c]f32, vsi: [*c][*c]c_int, vsb: [*c][*c]u8, psf: [*c][*c]f32, psi: [*c][*c]c_int, psb: [*c][*c]u8) void;
pub extern fn MOJOSHADER_mtlUnmapUniformBufferMemory(...) void;
pub extern fn MOJOSHADER_mtlGetVertexAttribLocation(vert: ?*MOJOSHADER_mtlShader, usage: MOJOSHADER_usage, index: c_int) c_int;
pub extern fn MOJOSHADER_mtlDeleteShader(shader: ?*MOJOSHADER_mtlShader) void;
pub extern fn MOJOSHADER_mtlGetFunctionHandle(shader: ?*MOJOSHADER_mtlShader) ?*c_void;
pub extern fn MOJOSHADER_mtlEndFrame() void;
pub extern fn MOJOSHADER_mtlDestroyContext() void;
pub const MOJOSHADER_RS_ZENABLE = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_ZENABLE);
pub const MOJOSHADER_RS_FILLMODE = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_FILLMODE);
pub const MOJOSHADER_RS_SHADEMODE = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_SHADEMODE);
pub const MOJOSHADER_RS_ZWRITEENABLE = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_ZWRITEENABLE);
pub const MOJOSHADER_RS_ALPHATESTENABLE = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_ALPHATESTENABLE);
pub const MOJOSHADER_RS_LASTPIXEL = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_LASTPIXEL);
pub const MOJOSHADER_RS_SRCBLEND = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_SRCBLEND);
pub const MOJOSHADER_RS_DESTBLEND = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_DESTBLEND);
pub const MOJOSHADER_RS_CULLMODE = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_CULLMODE);
pub const MOJOSHADER_RS_ZFUNC = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_ZFUNC);
pub const MOJOSHADER_RS_ALPHAREF = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_ALPHAREF);
pub const MOJOSHADER_RS_ALPHAFUNC = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_ALPHAFUNC);
pub const MOJOSHADER_RS_DITHERENABLE = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_DITHERENABLE);
pub const MOJOSHADER_RS_ALPHABLENDENABLE = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_ALPHABLENDENABLE);
pub const MOJOSHADER_RS_FOGENABLE = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_FOGENABLE);
pub const MOJOSHADER_RS_SPECULARENABLE = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_SPECULARENABLE);
pub const MOJOSHADER_RS_FOGCOLOR = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_FOGCOLOR);
pub const MOJOSHADER_RS_FOGTABLEMODE = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_FOGTABLEMODE);
pub const MOJOSHADER_RS_FOGSTART = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_FOGSTART);
pub const MOJOSHADER_RS_FOGEND = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_FOGEND);
pub const MOJOSHADER_RS_FOGDENSITY = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_FOGDENSITY);
pub const MOJOSHADER_RS_RANGEFOGENABLE = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_RANGEFOGENABLE);
pub const MOJOSHADER_RS_STENCILENABLE = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_STENCILENABLE);
pub const MOJOSHADER_RS_STENCILFAIL = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_STENCILFAIL);
pub const MOJOSHADER_RS_STENCILZFAIL = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_STENCILZFAIL);
pub const MOJOSHADER_RS_STENCILPASS = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_STENCILPASS);
pub const MOJOSHADER_RS_STENCILFUNC = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_STENCILFUNC);
pub const MOJOSHADER_RS_STENCILREF = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_STENCILREF);
pub const MOJOSHADER_RS_STENCILMASK = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_STENCILMASK);
pub const MOJOSHADER_RS_STENCILWRITEMASK = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_STENCILWRITEMASK);
pub const MOJOSHADER_RS_TEXTUREFACTOR = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_TEXTUREFACTOR);
pub const MOJOSHADER_RS_WRAP0 = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_WRAP0);
pub const MOJOSHADER_RS_WRAP1 = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_WRAP1);
pub const MOJOSHADER_RS_WRAP2 = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_WRAP2);
pub const MOJOSHADER_RS_WRAP3 = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_WRAP3);
pub const MOJOSHADER_RS_WRAP4 = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_WRAP4);
pub const MOJOSHADER_RS_WRAP5 = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_WRAP5);
pub const MOJOSHADER_RS_WRAP6 = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_WRAP6);
pub const MOJOSHADER_RS_WRAP7 = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_WRAP7);
pub const MOJOSHADER_RS_WRAP8 = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_WRAP8);
pub const MOJOSHADER_RS_WRAP9 = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_WRAP9);
pub const MOJOSHADER_RS_WRAP10 = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_WRAP10);
pub const MOJOSHADER_RS_WRAP11 = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_WRAP11);
pub const MOJOSHADER_RS_WRAP12 = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_WRAP12);
pub const MOJOSHADER_RS_WRAP13 = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_WRAP13);
pub const MOJOSHADER_RS_WRAP14 = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_WRAP14);
pub const MOJOSHADER_RS_WRAP15 = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_WRAP15);
pub const MOJOSHADER_RS_CLIPPING = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_CLIPPING);
pub const MOJOSHADER_RS_LIGHTING = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_LIGHTING);
pub const MOJOSHADER_RS_AMBIENT = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_AMBIENT);
pub const MOJOSHADER_RS_FOGVERTEXMODE = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_FOGVERTEXMODE);
pub const MOJOSHADER_RS_COLORVERTEX = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_COLORVERTEX);
pub const MOJOSHADER_RS_LOCALVIEWER = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_LOCALVIEWER);
pub const MOJOSHADER_RS_NORMALIZENORMALS = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_NORMALIZENORMALS);
pub const MOJOSHADER_RS_DIFFUSEMATERIALSOURCE = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_DIFFUSEMATERIALSOURCE);
pub const MOJOSHADER_RS_SPECULARMATERIALSOURCE = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_SPECULARMATERIALSOURCE);
pub const MOJOSHADER_RS_AMBIENTMATERIALSOURCE = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_AMBIENTMATERIALSOURCE);
pub const MOJOSHADER_RS_EMISSIVEMATERIALSOURCE = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_EMISSIVEMATERIALSOURCE);
pub const MOJOSHADER_RS_VERTEXBLEND = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_VERTEXBLEND);
pub const MOJOSHADER_RS_CLIPPLANEENABLE = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_CLIPPLANEENABLE);
pub const MOJOSHADER_RS_POINTSIZE = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_POINTSIZE);
pub const MOJOSHADER_RS_POINTSIZE_MIN = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_POINTSIZE_MIN);
pub const MOJOSHADER_RS_POINTSPRITEENABLE = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_POINTSPRITEENABLE);
pub const MOJOSHADER_RS_POINTSCALEENABLE = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_POINTSCALEENABLE);
pub const MOJOSHADER_RS_POINTSCALE_A = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_POINTSCALE_A);
pub const MOJOSHADER_RS_POINTSCALE_B = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_POINTSCALE_B);
pub const MOJOSHADER_RS_POINTSCALE_C = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_POINTSCALE_C);
pub const MOJOSHADER_RS_MULTISAMPLEANTIALIAS = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_MULTISAMPLEANTIALIAS);
pub const MOJOSHADER_RS_MULTISAMPLEMASK = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_MULTISAMPLEMASK);
pub const MOJOSHADER_RS_PATCHEDGESTYLE = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_PATCHEDGESTYLE);
pub const MOJOSHADER_RS_DEBUGMONITORTOKEN = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_DEBUGMONITORTOKEN);
pub const MOJOSHADER_RS_POINTSIZE_MAX = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_POINTSIZE_MAX);
pub const MOJOSHADER_RS_INDEXEDVERTEXBLENDENABLE = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_INDEXEDVERTEXBLENDENABLE);
pub const MOJOSHADER_RS_COLORWRITEENABLE = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_COLORWRITEENABLE);
pub const MOJOSHADER_RS_TWEENFACTOR = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_TWEENFACTOR);
pub const MOJOSHADER_RS_BLENDOP = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_BLENDOP);
pub const MOJOSHADER_RS_POSITIONDEGREE = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_POSITIONDEGREE);
pub const MOJOSHADER_RS_NORMALDEGREE = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_NORMALDEGREE);
pub const MOJOSHADER_RS_SCISSORTESTENABLE = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_SCISSORTESTENABLE);
pub const MOJOSHADER_RS_SLOPESCALEDEPTHBIAS = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_SLOPESCALEDEPTHBIAS);
pub const MOJOSHADER_RS_ANTIALIASEDLINEENABLE = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_ANTIALIASEDLINEENABLE);
pub const MOJOSHADER_RS_MINTESSELLATIONLEVEL = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_MINTESSELLATIONLEVEL);
pub const MOJOSHADER_RS_MAXTESSELLATIONLEVEL = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_MAXTESSELLATIONLEVEL);
pub const MOJOSHADER_RS_ADAPTIVETESS_X = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_ADAPTIVETESS_X);
pub const MOJOSHADER_RS_ADAPTIVETESS_Y = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_ADAPTIVETESS_Y);
pub const MOJOSHADER_RS_ADAPTIVETESS_Z = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_ADAPTIVETESS_Z);
pub const MOJOSHADER_RS_ADAPTIVETESS_W = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_ADAPTIVETESS_W);
pub const MOJOSHADER_RS_ENABLEADAPTIVETESSELLATION = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_ENABLEADAPTIVETESSELLATION);
pub const MOJOSHADER_RS_TWOSIDEDSTENCILMODE = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_TWOSIDEDSTENCILMODE);
pub const MOJOSHADER_RS_CCW_STENCILFAIL = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_CCW_STENCILFAIL);
pub const MOJOSHADER_RS_CCW_STENCILZFAIL = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_CCW_STENCILZFAIL);
pub const MOJOSHADER_RS_CCW_STENCILPASS = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_CCW_STENCILPASS);
pub const MOJOSHADER_RS_CCW_STENCILFUNC = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_CCW_STENCILFUNC);
pub const MOJOSHADER_RS_COLORWRITEENABLE1 = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_COLORWRITEENABLE1);
pub const MOJOSHADER_RS_COLORWRITEENABLE2 = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_COLORWRITEENABLE2);
pub const MOJOSHADER_RS_COLORWRITEENABLE3 = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_COLORWRITEENABLE3);
pub const MOJOSHADER_RS_BLENDFACTOR = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_BLENDFACTOR);
pub const MOJOSHADER_RS_SRGBWRITEENABLE = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_SRGBWRITEENABLE);
pub const MOJOSHADER_RS_DEPTHBIAS = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_DEPTHBIAS);
pub const MOJOSHADER_RS_SEPARATEALPHABLENDENABLE = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_SEPARATEALPHABLENDENABLE);
pub const MOJOSHADER_RS_SRCBLENDALPHA = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_SRCBLENDALPHA);
pub const MOJOSHADER_RS_DESTBLENDALPHA = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_DESTBLENDALPHA);
pub const MOJOSHADER_RS_BLENDOPALPHA = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_BLENDOPALPHA);
pub const MOJOSHADER_RS_VERTEXSHADER = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_VERTEXSHADER);
pub const MOJOSHADER_RS_PIXELSHADER = @enumToInt(enum_MOJOSHADER_renderStateType.MOJOSHADER_RS_PIXELSHADER);
pub const enum_MOJOSHADER_renderStateType = extern enum(c_int) {
    MOJOSHADER_RS_ZENABLE = 0,
    MOJOSHADER_RS_FILLMODE = 1,
    MOJOSHADER_RS_SHADEMODE = 2,
    MOJOSHADER_RS_ZWRITEENABLE = 3,
    MOJOSHADER_RS_ALPHATESTENABLE = 4,
    MOJOSHADER_RS_LASTPIXEL = 5,
    MOJOSHADER_RS_SRCBLEND = 6,
    MOJOSHADER_RS_DESTBLEND = 7,
    MOJOSHADER_RS_CULLMODE = 8,
    MOJOSHADER_RS_ZFUNC = 9,
    MOJOSHADER_RS_ALPHAREF = 10,
    MOJOSHADER_RS_ALPHAFUNC = 11,
    MOJOSHADER_RS_DITHERENABLE = 12,
    MOJOSHADER_RS_ALPHABLENDENABLE = 13,
    MOJOSHADER_RS_FOGENABLE = 14,
    MOJOSHADER_RS_SPECULARENABLE = 15,
    MOJOSHADER_RS_FOGCOLOR = 16,
    MOJOSHADER_RS_FOGTABLEMODE = 17,
    MOJOSHADER_RS_FOGSTART = 18,
    MOJOSHADER_RS_FOGEND = 19,
    MOJOSHADER_RS_FOGDENSITY = 20,
    MOJOSHADER_RS_RANGEFOGENABLE = 21,
    MOJOSHADER_RS_STENCILENABLE = 22,
    MOJOSHADER_RS_STENCILFAIL = 23,
    MOJOSHADER_RS_STENCILZFAIL = 24,
    MOJOSHADER_RS_STENCILPASS = 25,
    MOJOSHADER_RS_STENCILFUNC = 26,
    MOJOSHADER_RS_STENCILREF = 27,
    MOJOSHADER_RS_STENCILMASK = 28,
    MOJOSHADER_RS_STENCILWRITEMASK = 29,
    MOJOSHADER_RS_TEXTUREFACTOR = 30,
    MOJOSHADER_RS_WRAP0 = 31,
    MOJOSHADER_RS_WRAP1 = 32,
    MOJOSHADER_RS_WRAP2 = 33,
    MOJOSHADER_RS_WRAP3 = 34,
    MOJOSHADER_RS_WRAP4 = 35,
    MOJOSHADER_RS_WRAP5 = 36,
    MOJOSHADER_RS_WRAP6 = 37,
    MOJOSHADER_RS_WRAP7 = 38,
    MOJOSHADER_RS_WRAP8 = 39,
    MOJOSHADER_RS_WRAP9 = 40,
    MOJOSHADER_RS_WRAP10 = 41,
    MOJOSHADER_RS_WRAP11 = 42,
    MOJOSHADER_RS_WRAP12 = 43,
    MOJOSHADER_RS_WRAP13 = 44,
    MOJOSHADER_RS_WRAP14 = 45,
    MOJOSHADER_RS_WRAP15 = 46,
    MOJOSHADER_RS_CLIPPING = 47,
    MOJOSHADER_RS_LIGHTING = 48,
    MOJOSHADER_RS_AMBIENT = 49,
    MOJOSHADER_RS_FOGVERTEXMODE = 50,
    MOJOSHADER_RS_COLORVERTEX = 51,
    MOJOSHADER_RS_LOCALVIEWER = 52,
    MOJOSHADER_RS_NORMALIZENORMALS = 53,
    MOJOSHADER_RS_DIFFUSEMATERIALSOURCE = 54,
    MOJOSHADER_RS_SPECULARMATERIALSOURCE = 55,
    MOJOSHADER_RS_AMBIENTMATERIALSOURCE = 56,
    MOJOSHADER_RS_EMISSIVEMATERIALSOURCE = 57,
    MOJOSHADER_RS_VERTEXBLEND = 58,
    MOJOSHADER_RS_CLIPPLANEENABLE = 59,
    MOJOSHADER_RS_POINTSIZE = 60,
    MOJOSHADER_RS_POINTSIZE_MIN = 61,
    MOJOSHADER_RS_POINTSPRITEENABLE = 62,
    MOJOSHADER_RS_POINTSCALEENABLE = 63,
    MOJOSHADER_RS_POINTSCALE_A = 64,
    MOJOSHADER_RS_POINTSCALE_B = 65,
    MOJOSHADER_RS_POINTSCALE_C = 66,
    MOJOSHADER_RS_MULTISAMPLEANTIALIAS = 67,
    MOJOSHADER_RS_MULTISAMPLEMASK = 68,
    MOJOSHADER_RS_PATCHEDGESTYLE = 69,
    MOJOSHADER_RS_DEBUGMONITORTOKEN = 70,
    MOJOSHADER_RS_POINTSIZE_MAX = 71,
    MOJOSHADER_RS_INDEXEDVERTEXBLENDENABLE = 72,
    MOJOSHADER_RS_COLORWRITEENABLE = 73,
    MOJOSHADER_RS_TWEENFACTOR = 74,
    MOJOSHADER_RS_BLENDOP = 75,
    MOJOSHADER_RS_POSITIONDEGREE = 76,
    MOJOSHADER_RS_NORMALDEGREE = 77,
    MOJOSHADER_RS_SCISSORTESTENABLE = 78,
    MOJOSHADER_RS_SLOPESCALEDEPTHBIAS = 79,
    MOJOSHADER_RS_ANTIALIASEDLINEENABLE = 80,
    MOJOSHADER_RS_MINTESSELLATIONLEVEL = 81,
    MOJOSHADER_RS_MAXTESSELLATIONLEVEL = 82,
    MOJOSHADER_RS_ADAPTIVETESS_X = 83,
    MOJOSHADER_RS_ADAPTIVETESS_Y = 84,
    MOJOSHADER_RS_ADAPTIVETESS_Z = 85,
    MOJOSHADER_RS_ADAPTIVETESS_W = 86,
    MOJOSHADER_RS_ENABLEADAPTIVETESSELLATION = 87,
    MOJOSHADER_RS_TWOSIDEDSTENCILMODE = 88,
    MOJOSHADER_RS_CCW_STENCILFAIL = 89,
    MOJOSHADER_RS_CCW_STENCILZFAIL = 90,
    MOJOSHADER_RS_CCW_STENCILPASS = 91,
    MOJOSHADER_RS_CCW_STENCILFUNC = 92,
    MOJOSHADER_RS_COLORWRITEENABLE1 = 93,
    MOJOSHADER_RS_COLORWRITEENABLE2 = 94,
    MOJOSHADER_RS_COLORWRITEENABLE3 = 95,
    MOJOSHADER_RS_BLENDFACTOR = 96,
    MOJOSHADER_RS_SRGBWRITEENABLE = 97,
    MOJOSHADER_RS_DEPTHBIAS = 98,
    MOJOSHADER_RS_SEPARATEALPHABLENDENABLE = 99,
    MOJOSHADER_RS_SRCBLENDALPHA = 100,
    MOJOSHADER_RS_DESTBLENDALPHA = 101,
    MOJOSHADER_RS_BLENDOPALPHA = 102,
    MOJOSHADER_RS_VERTEXSHADER = 146,
    MOJOSHADER_RS_PIXELSHADER = 147,
    _,
};
pub const MOJOSHADER_renderStateType = enum_MOJOSHADER_renderStateType;
pub const MOJOSHADER_ZB_FALSE = @enumToInt(enum_MOJOSHADER_zBufferType.MOJOSHADER_ZB_FALSE);
pub const MOJOSHADER_ZB_TRUE = @enumToInt(enum_MOJOSHADER_zBufferType.MOJOSHADER_ZB_TRUE);
pub const MOJOSHADER_ZB_USEW = @enumToInt(enum_MOJOSHADER_zBufferType.MOJOSHADER_ZB_USEW);
pub const enum_MOJOSHADER_zBufferType = extern enum(c_int) {
    MOJOSHADER_ZB_FALSE,
    MOJOSHADER_ZB_TRUE,
    MOJOSHADER_ZB_USEW,
    _,
};
pub const MOJOSHADER_zBufferType = enum_MOJOSHADER_zBufferType;
pub const MOJOSHADER_FILL_POINT = @enumToInt(enum_MOJOSHADER_fillMode.MOJOSHADER_FILL_POINT);
pub const MOJOSHADER_FILL_WIREFRAME = @enumToInt(enum_MOJOSHADER_fillMode.MOJOSHADER_FILL_WIREFRAME);
pub const MOJOSHADER_FILL_SOLID = @enumToInt(enum_MOJOSHADER_fillMode.MOJOSHADER_FILL_SOLID);
pub const enum_MOJOSHADER_fillMode = extern enum(c_int) {
    MOJOSHADER_FILL_POINT = 1,
    MOJOSHADER_FILL_WIREFRAME = 2,
    MOJOSHADER_FILL_SOLID = 3,
    _,
};
pub const MOJOSHADER_fillMode = enum_MOJOSHADER_fillMode;
pub const MOJOSHADER_SHADE_FLAT = @enumToInt(enum_MOJOSHADER_shadeMode.MOJOSHADER_SHADE_FLAT);
pub const MOJOSHADER_SHADE_GOURAUD = @enumToInt(enum_MOJOSHADER_shadeMode.MOJOSHADER_SHADE_GOURAUD);
pub const MOJOSHADER_SHADE_PHONG = @enumToInt(enum_MOJOSHADER_shadeMode.MOJOSHADER_SHADE_PHONG);
pub const enum_MOJOSHADER_shadeMode = extern enum(c_int) {
    MOJOSHADER_SHADE_FLAT = 1,
    MOJOSHADER_SHADE_GOURAUD = 2,
    MOJOSHADER_SHADE_PHONG = 3,
    _,
};
pub const MOJOSHADER_shadeMode = enum_MOJOSHADER_shadeMode;
pub const MOJOSHADER_BLEND_ZERO = @enumToInt(enum_MOJOSHADER_blendMode.MOJOSHADER_BLEND_ZERO);
pub const MOJOSHADER_BLEND_ONE = @enumToInt(enum_MOJOSHADER_blendMode.MOJOSHADER_BLEND_ONE);
pub const MOJOSHADER_BLEND_SRCCOLOR = @enumToInt(enum_MOJOSHADER_blendMode.MOJOSHADER_BLEND_SRCCOLOR);
pub const MOJOSHADER_BLEND_INVSRCCOLOR = @enumToInt(enum_MOJOSHADER_blendMode.MOJOSHADER_BLEND_INVSRCCOLOR);
pub const MOJOSHADER_BLEND_SRCALPHA = @enumToInt(enum_MOJOSHADER_blendMode.MOJOSHADER_BLEND_SRCALPHA);
pub const MOJOSHADER_BLEND_INVSRCALPHA = @enumToInt(enum_MOJOSHADER_blendMode.MOJOSHADER_BLEND_INVSRCALPHA);
pub const MOJOSHADER_BLEND_DESTALPHA = @enumToInt(enum_MOJOSHADER_blendMode.MOJOSHADER_BLEND_DESTALPHA);
pub const MOJOSHADER_BLEND_INVDESTALPHA = @enumToInt(enum_MOJOSHADER_blendMode.MOJOSHADER_BLEND_INVDESTALPHA);
pub const MOJOSHADER_BLEND_DESTCOLOR = @enumToInt(enum_MOJOSHADER_blendMode.MOJOSHADER_BLEND_DESTCOLOR);
pub const MOJOSHADER_BLEND_INVDESTCOLOR = @enumToInt(enum_MOJOSHADER_blendMode.MOJOSHADER_BLEND_INVDESTCOLOR);
pub const MOJOSHADER_BLEND_SRCALPHASAT = @enumToInt(enum_MOJOSHADER_blendMode.MOJOSHADER_BLEND_SRCALPHASAT);
pub const MOJOSHADER_BLEND_BOTHSRCALPHA = @enumToInt(enum_MOJOSHADER_blendMode.MOJOSHADER_BLEND_BOTHSRCALPHA);
pub const MOJOSHADER_BLEND_BOTHINVSRCALPHA = @enumToInt(enum_MOJOSHADER_blendMode.MOJOSHADER_BLEND_BOTHINVSRCALPHA);
pub const MOJOSHADER_BLEND_BLENDFACTOR = @enumToInt(enum_MOJOSHADER_blendMode.MOJOSHADER_BLEND_BLENDFACTOR);
pub const MOJOSHADER_BLEND_INVBLENDFACTOR = @enumToInt(enum_MOJOSHADER_blendMode.MOJOSHADER_BLEND_INVBLENDFACTOR);
pub const MOJOSHADER_BLEND_SRCCOLOR2 = @enumToInt(enum_MOJOSHADER_blendMode.MOJOSHADER_BLEND_SRCCOLOR2);
pub const MOJOSHADER_BLEND_INVSRCCOLOR2 = @enumToInt(enum_MOJOSHADER_blendMode.MOJOSHADER_BLEND_INVSRCCOLOR2);
pub const enum_MOJOSHADER_blendMode = extern enum(c_int) {
    MOJOSHADER_BLEND_ZERO = 1,
    MOJOSHADER_BLEND_ONE = 2,
    MOJOSHADER_BLEND_SRCCOLOR = 3,
    MOJOSHADER_BLEND_INVSRCCOLOR = 4,
    MOJOSHADER_BLEND_SRCALPHA = 5,
    MOJOSHADER_BLEND_INVSRCALPHA = 6,
    MOJOSHADER_BLEND_DESTALPHA = 7,
    MOJOSHADER_BLEND_INVDESTALPHA = 8,
    MOJOSHADER_BLEND_DESTCOLOR = 9,
    MOJOSHADER_BLEND_INVDESTCOLOR = 10,
    MOJOSHADER_BLEND_SRCALPHASAT = 11,
    MOJOSHADER_BLEND_BOTHSRCALPHA = 12,
    MOJOSHADER_BLEND_BOTHINVSRCALPHA = 13,
    MOJOSHADER_BLEND_BLENDFACTOR = 14,
    MOJOSHADER_BLEND_INVBLENDFACTOR = 15,
    MOJOSHADER_BLEND_SRCCOLOR2 = 16,
    MOJOSHADER_BLEND_INVSRCCOLOR2 = 17,
    _,
};
pub const MOJOSHADER_blendMode = enum_MOJOSHADER_blendMode;
pub const MOJOSHADER_CULL_NONE = @enumToInt(enum_MOJOSHADER_cullMode.MOJOSHADER_CULL_NONE);
pub const MOJOSHADER_CULL_CW = @enumToInt(enum_MOJOSHADER_cullMode.MOJOSHADER_CULL_CW);
pub const MOJOSHADER_CULL_CCW = @enumToInt(enum_MOJOSHADER_cullMode.MOJOSHADER_CULL_CCW);
pub const enum_MOJOSHADER_cullMode = extern enum(c_int) {
    MOJOSHADER_CULL_NONE = 1,
    MOJOSHADER_CULL_CW = 2,
    MOJOSHADER_CULL_CCW = 3,
    _,
};
pub const MOJOSHADER_cullMode = enum_MOJOSHADER_cullMode;
pub const MOJOSHADER_CMP_NEVER = @enumToInt(enum_MOJOSHADER_compareFunc.MOJOSHADER_CMP_NEVER);
pub const MOJOSHADER_CMP_LESS = @enumToInt(enum_MOJOSHADER_compareFunc.MOJOSHADER_CMP_LESS);
pub const MOJOSHADER_CMP_EQUAL = @enumToInt(enum_MOJOSHADER_compareFunc.MOJOSHADER_CMP_EQUAL);
pub const MOJOSHADER_CMP_LESSEQUAL = @enumToInt(enum_MOJOSHADER_compareFunc.MOJOSHADER_CMP_LESSEQUAL);
pub const MOJOSHADER_CMP_GREATER = @enumToInt(enum_MOJOSHADER_compareFunc.MOJOSHADER_CMP_GREATER);
pub const MOJOSHADER_CMP_NOTEQUAL = @enumToInt(enum_MOJOSHADER_compareFunc.MOJOSHADER_CMP_NOTEQUAL);
pub const MOJOSHADER_CMP_GREATEREQUAL = @enumToInt(enum_MOJOSHADER_compareFunc.MOJOSHADER_CMP_GREATEREQUAL);
pub const MOJOSHADER_CMP_ALWAYS = @enumToInt(enum_MOJOSHADER_compareFunc.MOJOSHADER_CMP_ALWAYS);
pub const enum_MOJOSHADER_compareFunc = extern enum(c_int) {
    MOJOSHADER_CMP_NEVER = 1,
    MOJOSHADER_CMP_LESS = 2,
    MOJOSHADER_CMP_EQUAL = 3,
    MOJOSHADER_CMP_LESSEQUAL = 4,
    MOJOSHADER_CMP_GREATER = 5,
    MOJOSHADER_CMP_NOTEQUAL = 6,
    MOJOSHADER_CMP_GREATEREQUAL = 7,
    MOJOSHADER_CMP_ALWAYS = 8,
    _,
};
pub const MOJOSHADER_compareFunc = enum_MOJOSHADER_compareFunc;

pub const enum_MOJOSHADER_fogMode = extern enum(c_int) {
    MOJOSHADER_FOG_NONE,
    MOJOSHADER_FOG_EXP,
    MOJOSHADER_FOG_EXP2,
    MOJOSHADER_FOG_LINEAR,
    _,
};
pub const MOJOSHADER_fogMode = enum_MOJOSHADER_fogMode;

pub const enum_MOJOSHADER_stencilOp = extern enum(c_int) {
    MOJOSHADER_STENCILOP_KEEP = 1,
    MOJOSHADER_STENCILOP_ZERO = 2,
    MOJOSHADER_STENCILOP_REPLACE = 3,
    MOJOSHADER_STENCILOP_INCRSAT = 4,
    MOJOSHADER_STENCILOP_DECRSAT = 5,
    MOJOSHADER_STENCILOP_INVERT = 6,
    MOJOSHADER_STENCILOP_INCR = 7,
    MOJOSHADER_STENCILOP_DECR = 8,
    _,
};
pub const MOJOSHADER_stencilOp = enum_MOJOSHADER_stencilOp;

pub const enum_MOJOSHADER_materialColorSource = extern enum(c_int) {
    MOJOSHADER_MCS_MATERIAL,
    MOJOSHADER_MCS_COLOR1,
    MOJOSHADER_MCS_COLOR2,
    _,
};
pub const MOJOSHADER_materialColorSource = enum_MOJOSHADER_materialColorSource;

pub const enum_MOJOSHADER_vertexBlendFlags = extern enum(c_int) {
    MOJOSHADER_VBF_DISABLE = 0,
    MOJOSHADER_VBF_1WEIGHTS = 1,
    MOJOSHADER_VBF_2WEIGHTS = 2,
    MOJOSHADER_VBF_3WEIGHTS = 3,
    MOJOSHADER_VBF_TWEENING = 255,
    MOJOSHADER_VBF_0WEIGHTS = 256,
    _,
};
pub const MOJOSHADER_vertexBlendFlags = enum_MOJOSHADER_vertexBlendFlags;

pub const enum_MOJOSHADER_patchedEdgeStyle = extern enum(c_int) {
    MOJOSHADER_PATCHEDGE_DISCRETE,
    MOJOSHADER_PATCHEDGE_CONTINUOUS,
    _,
};
pub const MOJOSHADER_patchedEdgeStyle = enum_MOJOSHADER_patchedEdgeStyle;

pub const enum_MOJOSHADER_debugMonitorTokens = extern enum(c_int) {
    MOJOSHADER_DMT_ENABLE,
    MOJOSHADER_DMT_DISABLE,
    _,
};
pub const MOJOSHADER_debugMonitorTokens = enum_MOJOSHADER_debugMonitorTokens;

pub const enum_MOJOSHADER_blendOp = extern enum(c_int) {
    MOJOSHADER_BLENDOP_ADD = 1,
    MOJOSHADER_BLENDOP_SUBTRACT = 2,
    MOJOSHADER_BLENDOP_REVSUBTRACT = 3,
    MOJOSHADER_BLENDOP_MIN = 4,
    MOJOSHADER_BLENDOP_MAX = 5,
    _,
};
pub const MOJOSHADER_blendOp = enum_MOJOSHADER_blendOp;

pub const enum_MOJOSHADER_degreeType = extern enum(c_int) {
    MOJOSHADER_DEGREE_LINEAR = 1,
    MOJOSHADER_DEGREE_QUADRATIC = 2,
    MOJOSHADER_DEGREE_CUBIC = 3,
    MOJOSHADER_DEGREE_QUINTIC = 5,
    _,
};
pub const MOJOSHADER_degreeType = enum_MOJOSHADER_degreeType;

pub const enum_MOJOSHADER_samplerStateType = extern enum(c_int) {
    MOJOSHADER_SAMP_UNKNOWN0 = 0,
    MOJOSHADER_SAMP_UNKNOWN1 = 1,
    MOJOSHADER_SAMP_UNKNOWN2 = 2,
    MOJOSHADER_SAMP_UNKNOWN3 = 3,
    MOJOSHADER_SAMP_TEXTURE = 4,
    MOJOSHADER_SAMP_ADDRESSU = 5,
    MOJOSHADER_SAMP_ADDRESSV = 6,
    MOJOSHADER_SAMP_ADDRESSW = 7,
    MOJOSHADER_SAMP_BORDERCOLOR = 8,
    MOJOSHADER_SAMP_MAGFILTER = 9,
    MOJOSHADER_SAMP_MINFILTER = 10,
    MOJOSHADER_SAMP_MIPFILTER = 11,
    MOJOSHADER_SAMP_MIPMAPLODBIAS = 12,
    MOJOSHADER_SAMP_MAXMIPLEVEL = 13,
    MOJOSHADER_SAMP_MAXANISOTROPY = 14,
    MOJOSHADER_SAMP_SRGBTEXTURE = 15,
    MOJOSHADER_SAMP_ELEMENTINDEX = 16,
    MOJOSHADER_SAMP_DMAPOFFSET = 17,
    _,
};
pub const MOJOSHADER_samplerStateType = enum_MOJOSHADER_samplerStateType;

pub const enum_MOJOSHADER_textureAddress = extern enum(c_int) {
    MOJOSHADER_TADDRESS_WRAP = 1,
    MOJOSHADER_TADDRESS_MIRROR = 2,
    MOJOSHADER_TADDRESS_CLAMP = 3,
    MOJOSHADER_TADDRESS_BORDER = 4,
    MOJOSHADER_TADDRESS_MIRRORONCE = 5,
    _,
};
pub const MOJOSHADER_textureAddress = enum_MOJOSHADER_textureAddress;

pub const enum_MOJOSHADER_textureFilterType = extern enum(c_int) {
    MOJOSHADER_TEXTUREFILTER_NONE,
    MOJOSHADER_TEXTUREFILTER_POINT,
    MOJOSHADER_TEXTUREFILTER_LINEAR,
    MOJOSHADER_TEXTUREFILTER_ANISOTROPIC,
    MOJOSHADER_TEXTUREFILTER_PYRAMIDALQUAD,
    MOJOSHADER_TEXTUREFILTER_GAUSSIANQUAD,
    MOJOSHADER_TEXTUREFILTER_CONVOLUTIONMONO,
    _,
};
pub const MOJOSHADER_textureFilterType = enum_MOJOSHADER_textureFilterType;
pub const MOJOSHADER_effectSamplerState = extern struct {
    type: MOJOSHADER_samplerStateType,
    value: EffectValue,
};

pub const struct_MOJOSHADER_effectState = extern struct {
    type: MOJOSHADER_renderStateType,
    value: EffectValue,
};
pub const MOJOSHADER_effectState = struct_MOJOSHADER_effectState;

pub const struct_MOJOSHADER_effectSamplerMap = extern struct {
    type: SymbolType,
    name: [*c]const u8,
};
pub const MOJOSHADER_effectSamplerMap = struct_MOJOSHADER_effectSamplerMap;
pub const struct_MOJOSHADER_effectString = extern struct {
    type: SymbolType,
    string: [*c]const u8,
};
pub const MOJOSHADER_effectString = struct_MOJOSHADER_effectString;
pub const struct_MOJOSHADER_effectTexture = extern struct {
    type: SymbolType,
};
pub const MOJOSHADER_effectTexture = struct_MOJOSHADER_effectTexture;

pub const MOJOSHADER_compileShaderFunc = ?fn ([*c]const u8, [*c]const u8, c_uint, [*c]const MOJOSHADER_swizzle, c_uint, [*c]const MOJOSHADER_samplerMap, c_uint) callconv(.C) ?*c_void;
pub const MOJOSHADER_shaderAddRefFunc = ?fn (?*c_void) callconv(.C) void;
pub const MOJOSHADER_deleteShaderFunc = ?fn (?*c_void) callconv(.C) void;
pub const MOJOSHADER_getParseDataFunc = ?fn (?*c_void) callconv(.C) [*c]MOJOSHADER_parseData;
pub const MOJOSHADER_bindShadersFunc = ?fn (?*c_void, ?*c_void) callconv(.C) void;
pub const MOJOSHADER_getBoundShadersFunc = ?fn ([*c]?*c_void, [*c]?*c_void) callconv(.C) void;
pub const MOJOSHADER_mapUniformBufferMemoryFunc = ?fn ([*c][*c]f32, [*c][*c]c_int, [*c][*c]u8, [*c][*c]f32, [*c][*c]c_int, [*c][*c]u8) callconv(.C) void;
pub const MOJOSHADER_unmapUniformBufferMemoryFunc = ?fn (...) callconv(.C) void;
