const std = @import("std");
const zgui = @import("gui.zig");
const core = @import("mach-core");

const c = @cImport({
    @cInclude("imgui_c_keys.h");
});

pub usingnamespace zgui;

const enable_imgui = @import("options").enable_imgui;

pub const backend = struct {
    var last_width: u32 = 0;
    var last_height: u32 = 0;

    fn machKeyToImgui(key: core.Key) u32 {
        return switch (key) {
            .tab => c.ImGuiKey_Tab,
            .backspace => c.ImGuiKey_Backspace,
            .delete => c.ImGuiKey_Delete,
            .page_up => c.ImGuiKey_PageUp,
            .page_down => c.ImGuiKey_PageDown,
            .home => c.ImGuiKey_Home,
            .insert => c.ImGuiKey_Insert,
            .space => c.ImGuiKey_Space,

            .left => c.ImGuiKey_LeftArrow,
            .right => c.ImGuiKey_RightArrow,
            .up => c.ImGuiKey_UpArrow,
            .down => c.ImGuiKey_DownArrow,

            .a => c.ImGuiKey_A,
            .b => c.ImGuiKey_B,
            .c => c.ImGuiKey_C,
            .d => c.ImGuiKey_D,
            .e => c.ImGuiKey_E,
            .f => c.ImGuiKey_F,
            .g => c.ImGuiKey_G,
            .h => c.ImGuiKey_H,
            .i => c.ImGuiKey_I,
            .j => c.ImGuiKey_J,
            .k => c.ImGuiKey_K,
            .l => c.ImGuiKey_L,
            .m => c.ImGuiKey_M,
            .n => c.ImGuiKey_N,
            .o => c.ImGuiKey_O,
            .p => c.ImGuiKey_P,
            .q => c.ImGuiKey_Q,
            .r => c.ImGuiKey_R,
            .s => c.ImGuiKey_S,
            .t => c.ImGuiKey_T,
            .u => c.ImGuiKey_U,
            .v => c.ImGuiKey_V,
            .w => c.ImGuiKey_W,
            .x => c.ImGuiKey_X,
            .y => c.ImGuiKey_Y,
            .z => c.ImGuiKey_Z,

            else => c.ImGuiKey_None,
        };
    }

    pub fn init() void {
        if (!enable_imgui) return;

        _ = zgui.zguiCreateContext(null);
        _ = zgui.io.addFontFromFile("examples/assets/Roboto-Medium.ttf", std.math.floor(12.0 * 2.0));

        if (!ImGui_ImplWGPU_Init(core.device, 1, @intFromEnum(core.descriptor.format), &.{})) unreachable;
        if (!ImGui_ImplWGPU_CreateDeviceObjects()) unreachable;
    }

    pub fn deinit() void {
        if (!enable_imgui) return;
        ImGui_ImplWGPU_Shutdown();
        zgui.zguiDestroyContext(null);
    }

    pub fn newFrame() void {
        if (!enable_imgui) return;

        const desc = core.descriptor;
        if (desc.width != last_width or desc.height != last_height) {
            last_width = desc.width;
            last_height = desc.height;
            zgui.io.setDisplaySize(@as(f32, @floatFromInt(desc.width)), @as(f32, @floatFromInt(desc.height)));
        }

        zgui.newFrame();
    }

    fn drawImpl(wgpu_render_pass: *const anyopaque) void {
        if (!enable_imgui) return;
        zgui.render();
        ImGui_ImplWGPU_RenderDrawData(zgui.getDrawData(), wgpu_render_pass);
    }

    pub fn draw() void {
        if (!enable_imgui) return;
        if (core.swap_chain.getCurrentTextureView()) |back_buffer_view| {
            defer back_buffer_view.release();

            const zgui_commands = commands: {
                const encoder = core.device.createCommandEncoder(null);
                defer encoder.release();

                // Gui pass.
                {
                    const color_attachment = core.gpu.RenderPassColorAttachment{
                        .view = back_buffer_view,
                        .clear_value = .{ .r = 0.2, .g = 0.4, .b = 0.2, .a = 1.0 },
                        .load_op = .load,
                        .store_op = .store,
                    };

                    const render_pass_info = core.gpu.RenderPassDescriptor.init(.{
                        .color_attachments = &.{color_attachment},
                    });
                    const pass = encoder.beginRenderPass(&render_pass_info);

                    backend.drawImpl(pass);
                    pass.end();
                    pass.release();
                }

                break :commands encoder.finish(null);
            };
            defer zgui_commands.release();

            core.queue.submit(&.{zgui_commands});
        }
    }

    pub fn passEvent(event: core.Event) void {
        if (!enable_imgui) return;

        switch (event) {
            .mouse_motion => {
                const descriptor = core.descriptor;
                const window_size: [2]f32 = .{ @floatFromInt(core.size().width), @floatFromInt(core.size().height) };
                const framebuffer_size: [2]f32 = .{ @floatFromInt(descriptor.width), @floatFromInt(descriptor.height) };
                const content_scale: [2]f32 = .{
                    framebuffer_size[0] / window_size[0],
                    framebuffer_size[1] / window_size[1],
                };

                const pos = event.mouse_motion.pos;
                zgui.io.addMousePositionEvent(@floatCast(pos.x * content_scale[0]), @floatCast(pos.y * content_scale[1]));
            },
            .mouse_press => |mouse_press| {
                zgui.io.addMouseButtonEvent(@enumFromInt(@intFromEnum(mouse_press.button)), true);
            },
            .mouse_release => |mouse_release| {
                zgui.io.addMouseButtonEvent(@enumFromInt(@intFromEnum(mouse_release.button)), false);
            },
            .mouse_scroll => {
                const offsets = event.mouse_scroll;
                zgui.io.addMouseWheelEvent(offsets.xoffset, offsets.yoffset);
            },
            .key_press => {
                const key = event.key_press.key;
                const keycode = machKeyToImgui(key);
                zgui.io.addKeyEvent(@enumFromInt(keycode), true);
                zgui.io.setKeyEventNativeData(@enumFromInt(keycode), 0, 1);
            },
            .key_release => {
                const key = event.key_release.key;
                const keycode = machKeyToImgui(key);
                zgui.io.addKeyEvent(@enumFromInt(keycode), false);
                zgui.io.setKeyEventNativeData(@enumFromInt(keycode), 0, 0);
            },
            .char_input => {
                zgui.io.addCharacterEvent(event.char_input.codepoint);
            },
            else => {},
        }
    }
};

// Rendering
const Config = extern struct {
    pipeline_multisample_count: c_uint = 1,
    texture_filter_mode: c_uint = 0, // gpu.FilterMode.nearest
    depth_stencil_format: c_uint = 0,
};

extern fn ImGui_ImplWGPU_Init(device: *const anyopaque, num_frames_in_flight: c_int, rt_format: u32, config: *const Config) bool;
extern fn ImGui_ImplWGPU_Shutdown() void;
extern fn ImGui_ImplWGPU_CreateDeviceObjects() bool;
extern fn ImGui_ImplWGPU_RenderDrawData(draw_data: *const anyopaque, pass_encoder: *const anyopaque) void;
