const sg = @import("sokol").gfx;
pub const enabled = @import("options").enable_imgui;

const sg_pixel_format = sg.PixelFormat;

pub const struct_simgui_image_t = extern struct {
    id: u32 = @import("std").mem.zeroes(u32),
};
pub const simgui_image_t = struct_simgui_image_t;
pub const struct_simgui_image_desc_t = extern struct {
    image: @import("sokol").gfx.Image = @import("std").mem.zeroes(@import("sokol").gfx.Image),
    sampler: @import("sokol").gfx.Sampler = @import("std").mem.zeroes(@import("sokol").gfx.Sampler),
};
pub const simgui_image_desc_t = struct_simgui_image_desc_t;
pub const SIMGUI_LOGITEM_OK: c_int = 0;
pub const SIMGUI_LOGITEM_MALLOC_FAILED: c_int = 1;
pub const SIMGUI_LOGITEM_IMAGE_POOL_EXHAUSTED: c_int = 2;
pub const enum_simgui_log_item_t = c_uint;
pub const simgui_log_item_t = enum_simgui_log_item_t;
pub const struct_simgui_allocator_t = extern struct {
    alloc_fn: ?*const fn (usize, ?*anyopaque) callconv(.C) ?*anyopaque = @import("std").mem.zeroes(?*const fn (usize, ?*anyopaque) callconv(.C) ?*anyopaque),
    free_fn: ?*const fn (?*anyopaque, ?*anyopaque) callconv(.C) void = @import("std").mem.zeroes(?*const fn (?*anyopaque, ?*anyopaque) callconv(.C) void),
    user_data: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
};
pub const simgui_allocator_t = struct_simgui_allocator_t;
pub const struct_simgui_logger_t = extern struct {
    func: ?*const fn ([*c]const u8, u32, u32, [*c]const u8, u32, [*c]const u8, ?*anyopaque) callconv(.C) void = @import("std").mem.zeroes(?*const fn ([*c]const u8, u32, u32, [*c]const u8, u32, [*c]const u8, ?*anyopaque) callconv(.C) void),
    user_data: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
};
pub const simgui_logger_t = struct_simgui_logger_t;
pub const struct_simgui_desc_t = extern struct {
    max_vertices: c_int = @import("std").mem.zeroes(c_int),
    image_pool_size: c_int = @import("std").mem.zeroes(c_int),
    color_format: sg_pixel_format = @import("std").mem.zeroes(sg_pixel_format),
    depth_format: sg_pixel_format = @import("std").mem.zeroes(sg_pixel_format),
    sample_count: c_int = @import("std").mem.zeroes(c_int),
    ini_filename: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
    no_default_font: bool = @import("std").mem.zeroes(bool),
    disable_paste_override: bool = @import("std").mem.zeroes(bool),
    disable_set_mouse_cursor: bool = @import("std").mem.zeroes(bool),
    disable_windows_resize_from_edges: bool = @import("std").mem.zeroes(bool),
    write_alpha_channel: bool = @import("std").mem.zeroes(bool),
    allocator: simgui_allocator_t = @import("std").mem.zeroes(simgui_allocator_t),
    logger: simgui_logger_t = @import("std").mem.zeroes(simgui_logger_t),
};
pub const simgui_desc_t = struct_simgui_desc_t;
pub const struct_simgui_frame_desc_t = extern struct {
    width: c_int = @import("std").mem.zeroes(c_int),
    height: c_int = @import("std").mem.zeroes(c_int),
    delta_time: f64 = @import("std").mem.zeroes(f64),
    dpi_scale: f32 = @import("std").mem.zeroes(f32),
};
pub const simgui_frame_desc_t = struct_simgui_frame_desc_t;
pub extern fn simgui_setup(desc: [*c]const simgui_desc_t) void;
pub extern fn simgui_new_frame(desc: [*c]const simgui_frame_desc_t) void;
pub extern fn simgui_render() void;
pub extern fn simgui_make_image(desc: [*c]const simgui_image_desc_t) simgui_image_t;
pub extern fn simgui_destroy_image(img: simgui_image_t) void;
pub extern fn simgui_query_image_desc(img: simgui_image_t) simgui_image_desc_t;
pub extern fn simgui_imtextureid(img: simgui_image_t) ?*anyopaque;
pub extern fn simgui_image_from_imtextureid(imtextureid: ?*anyopaque) simgui_image_t;
pub extern fn simgui_add_focus_event(focus: bool) void;
pub extern fn simgui_add_mouse_pos_event(x: f32, y: f32) void;
pub extern fn simgui_add_touch_pos_event(x: f32, y: f32) void;
pub extern fn simgui_add_mouse_button_event(mouse_button: c_int, down: bool) void;
pub extern fn simgui_add_mouse_wheel_event(wheel_x: f32, wheel_y: f32) void;
pub extern fn simgui_add_key_event(map_keycode: ?*const fn (c_int) callconv(.C) c_int, keycode: c_int, down: bool) void;
pub extern fn simgui_add_input_character(c: u32) void;
pub extern fn simgui_add_input_characters_utf8(c: [*c]const u8) void;
pub extern fn simgui_add_touch_button_event(mouse_button: c_int, down: bool) void;
pub extern fn simgui_shutdown() void;
