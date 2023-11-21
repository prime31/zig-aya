const std = @import("std");
// const na = @cImport({
//     @cInclude("naga_oil.h");
// });
// const wgpu = @cImport({
//     @cInclude("wgpu.h");
// });

pub const Composer = struct {
    composer: na.NagaOilComposer,

    pub fn init() Composer {
        return .{ .composer = na.composer_create() };
    }

    pub fn deinit(self: Composer) void {
        na.composer_destroy(self.composer);
    }

    pub fn addComposableModule(self: Composer, desc: na.ComposableModuleDescriptor) error{AddComposableModuleFailed}!void {
        if (na.composer_add_composable_module(self.composer, desc) < 0) return error.AddComposableModuleFailed;
    }

    pub fn makeNagaModule(self: Composer, desc: na.NagaOilModuleDescriptor) error{NagaModuleNotCreated}!Module {
        const module = na.composer_make_naga_module(self.composer, desc);
        if (module == null) return error.NagaModuleNotCreated;
        return .{ .module = module };
    }
};

pub const Module = struct {
    module: na.NagaOilModule,

    pub fn toSource(self: Module) Source {
        return .{ .source = na.module_to_source(self.module) };
    }
};

pub const Source = struct {
    source: [*c]u8,

    pub fn deinit(self: Source) void {
        na.source_destroy(self.source);
    }
};

/// When used the called function owns the memory so deinit is omitted
pub const ShaderDefs = struct {
    defs: na.NagaOilShaderDefs,

    pub fn init() ShaderDefs {
        return .{ .defs = na.shader_defs_create() };
    }

    pub fn insertI32(self: ShaderDefs, key: []const u8, value: i32) void {
        na.shader_defs_insert_sint(self.defs, key.ptr, value);
    }

    pub fn insertU32(self: ShaderDefs, key: []const u8, value: u32) void {
        na.shader_defs_insert_uint(self.defs, key.ptr, value);
    }

    pub fn insertBool(self: ShaderDefs, key: []const u8, value: bool) void {
        na.shader_defs_insert_bool(self.defs, key.ptr, value);
    }

    pub fn debugPrint(self: ShaderDefs) void {
        na.shader_defs_debug_print(self.defs);
    }
};

pub const ImportDefinitions = struct {
    imports: na.NagaOilImportDefinitions,

    pub fn init() ImportDefinitions {
        return .{ .imports = na.import_definitions_create() };
    }

    pub fn deinit(self: ImportDefinitions) void {
        na.import_definitions_destroy(self.imports);
    }

    pub fn push(self: ImportDefinitions, import: []const u8) void {
        na.import_definitions_push(self.imports, import.ptr);
    }

    pub fn pushWithItems(self: ImportDefinitions, import: []const u8, items: []const u8) void {
        const vec = StringVec.init();
        vec.push(items);
        na.import_definitions_push_with_items(self.imports, import.ptr, vec);
    }
};

/// When used the called function owns the memory so deinit is omitted
const StringVec = struct {
    defs: na.NagaOilStringVec,

    pub fn init() StringVec {
        return .{ .defs = na.string_vec_create() };
    }

    pub fn push(self: StringVec, item: []const u8) void {
        na.string_vec_push(self.defs, item.ptr);
    }
};

const na = struct {
    pub const NagaOilComposer = ?*anyopaque;
    pub const NagaOilImportDefinitions = ?*anyopaque;
    pub const NagaOilShaderDefs = ?*anyopaque;
    pub const struct_ComposableModuleDescriptor = extern struct {
        source: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
        file_path: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
        as_name: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
        additional_imports: NagaOilImportDefinitions = @import("std").mem.zeroes(NagaOilImportDefinitions),
        shader_defs: NagaOilShaderDefs = @import("std").mem.zeroes(NagaOilShaderDefs),
    };
    pub const ComposableModuleDescriptor = struct_ComposableModuleDescriptor;
    pub const NagaOilModule = ?*anyopaque;
    pub const struct_ModuleDescriptor = extern struct {
        source: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
        file_path: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
        shader_defs: NagaOilShaderDefs = @import("std").mem.zeroes(NagaOilShaderDefs),
        additional_imports: NagaOilImportDefinitions = @import("std").mem.zeroes(NagaOilImportDefinitions),
    };
    pub const NagaOilModuleDescriptor = struct_ModuleDescriptor;
    pub const NagaOilStringVec = ?*anyopaque;
    pub extern fn composer_create() NagaOilComposer;
    pub extern fn composer_destroy(composer: NagaOilComposer) void;
    pub extern fn composer_add_composable_module(composer: NagaOilComposer, desc: struct_ComposableModuleDescriptor) i32;
    pub extern fn composer_make_naga_module(composer: NagaOilComposer, desc: struct_ModuleDescriptor) NagaOilModule;
    pub extern fn module_to_source(module: NagaOilModule) [*c]u8;
    pub extern fn source_destroy(src: [*c]u8) void;
    pub extern fn string_vec_create() NagaOilStringVec;
    pub extern fn string_vec_push(vec: NagaOilStringVec, item: [*c]const u8) void;
    pub extern fn import_definitions_create() NagaOilImportDefinitions;
    pub extern fn import_definitions_destroy(vec: NagaOilImportDefinitions) void;
    pub extern fn import_definitions_push(vec: NagaOilImportDefinitions, import: [*c]const u8) void;
    pub extern fn import_definitions_push_with_items(vec: NagaOilImportDefinitions, import: [*c]const u8, items: NagaOilStringVec) void;
    pub extern fn shader_defs_create() NagaOilShaderDefs;
    pub extern fn shader_defs_insert_sint(map: NagaOilShaderDefs, key: [*c]const u8, value: i32) void;
    pub extern fn shader_defs_insert_uint(map: NagaOilShaderDefs, key: [*c]const u8, value: u32) void;
    pub extern fn shader_defs_insert_bool(map: NagaOilShaderDefs, key: [*c]const u8, value: bool) void;
    pub extern fn shader_defs_debug_print(map: NagaOilShaderDefs) void;
};
