// pub usingnamespace @cImport({
//     @cInclude("metal_util.h");
// });

pub extern fn mu_create_metal_layer(window: ?*anyopaque) void;
pub extern fn mu_get_metal_device(?*const anyopaque) ?*const anyopaque;
pub extern fn mu_get_render_pass_descriptor() ?*const anyopaque;
pub extern fn mu_get_drawable() ?*const anyopaque;
pub extern fn mu_dpi_scale() f32;
pub extern fn mu_width() f32;
pub extern fn mu_height() f32;
pub extern fn mu_set_framebuffer_only(framebuffer_only: bool) void;
pub extern fn mu_set_drawable_size(width: c_int, height: c_int) void;
pub extern fn mu_set_display_sync_enabled(enabled: bool) void;
