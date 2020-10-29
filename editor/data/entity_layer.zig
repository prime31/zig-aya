const std = @import("std");
const root = @import("../main.zig");
const aya = @import("aya");
const math = aya.math;
usingnamespace @import("imgui");

const editor = @import("../editor.zig");
const data = @import("data.zig");

const AppState = data.AppState;
const Size = data.Size;
const Camera = @import("../camera.zig").Camera;

pub const EntityLayer = struct {
    name: [:0]const u8,

    pub fn init(name: []const u8, size: Size) EntityLayer {
        return .{ .name = aya.mem.allocator.dupeZ(u8, name) catch unreachable };
    }

    pub fn deinit(self: @This()) void {
        aya.mem.allocator.free(self.name);
    }

    pub fn draw(self: @This(), state: *AppState, is_selected: bool) void {
        defer igEnd();
        if (!igBegin("Inspector", null, ImGuiWindowFlags_None)) return;

        igText("saldkfjklasdfjkdlsjf");
        ogColoredText(1, 0, 0, "red text");
        ogColoredText(0, 1, 0, "green text");
        ogColoredText(0, 0, 1, "blue text");
        _ = ogColoredButton(root.colors.rgbToU32(135, 55, 123), "i have a color");
    }

    pub fn handleSceneInput(self: @This(), state: *AppState, camera: Camera, mouse_world: ImVec2) void {
        aya.draw.text(self.name, 100, 0, null);
    }
};