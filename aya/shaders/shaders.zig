usingnamespace @import("sokol");

pub extern fn dissolve_shader_desc() [*c]const sg_shader_desc;
pub extern fn lines_shader_desc() [*c]const sg_shader_desc;
pub extern fn mode7_shader_desc() [*c]const sg_shader_desc;
pub extern fn noise_shader_desc() [*c]const sg_shader_desc;
pub extern fn pixel_glitch_shader_desc() [*c]const sg_shader_desc;
pub extern fn rgb_shift_shader_desc() [*c]const sg_shader_desc;
pub extern fn sepia_shader_desc() [*c]const sg_shader_desc;
pub extern fn sprite_shader_desc() [*c]const sg_shader_desc;
pub extern fn vignette_shader_desc() [*c]const sg_shader_desc;

// for generating the cimport.zig file uncomment this
// const std = @import("std");
// pub usingnamespace @cImport({
//     if (std.Target.current.os.tag == .macosx) {
//         @cDefine("SOKOL_METAL", "");
//     } else {
//         @cDefine("SOKOL_GLCORE33", "");
//     }
//     @cInclude("sokol/sokol_gfx.h");
//     @cInclude("basics.h");
// });