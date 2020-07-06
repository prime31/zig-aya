const std = @import("std");
const imgui = @import("imgui");
const fna = @import("fna");
const aya = @import("../aya.zig");
const gfx = aya.gfx;

pub const Renderer = struct {
    font_texture: gfx.Texture,
    vert_buffer_size: i32,
    vert_buffer: gfx.VertexBuffer,
    index_buffer_size: i32,
    index_buffer: gfx.IndexBuffer,
    shader: gfx.Shader,

    const font_awesome_range: [3]imgui.ImWchar = [_]imgui.ImWchar {imgui.icons.icon_range_min, imgui.icons.icon_range_max, 0};

    pub fn init(docking: bool, viewports: bool, icon_font: bool) Renderer {
        var vert_buffer = gfx.VertexBuffer.init(gfx.Vertex, 0, true);

        _ = imgui.igCreateContext(null);
        var io = imgui.igGetIO();
        if (docking) io.ConfigFlags |= imgui.ImGuiConfigFlags_DockingEnable;
        if (viewports) io.ConfigFlags |= imgui.ImGuiConfigFlags_ViewportsEnable;
        io.ConfigDockingWithShift = true;

        imgui.igStyleColorsDark(imgui.igGetStyle());
        imgui.igGetStyle().FrameRounding = 0;
        imgui.igGetStyle().WindowRounding = 0;

        _ = imgui.ImFontAtlas_AddFontDefault(io.Fonts, null);

        // add FontAwesome optionally
        if (icon_font) {
            var icons_config = imgui.ImFontConfig_ImFontConfig();
            icons_config[0].MergeMode = true;
            icons_config[0].PixelSnapH = true;

            var data = @embedFile("assets/" ++ imgui.icons.font_icon_filename_fas);
            _ = imgui.ImFontAtlas_AddFontFromMemoryTTF(io.Fonts, data, data.len, 14, icons_config, &font_awesome_range[0]);
        }

        var w: i32 = undefined;
        var h: i32 = undefined;
        var bytes_per_pixel: i32 = undefined;
        var pixels: [*c]u8 = undefined;
        imgui.ImFontAtlas_GetTexDataAsRGBA32(io.Fonts, &pixels, &w, &h, &bytes_per_pixel);

        const font_tex = gfx.Texture.initFromData(pixels[0..@intCast(usize, w * h * bytes_per_pixel)], w, h) catch unreachable;
        imgui.ImFontAtlas_SetTexID(io.Fonts, font_tex.tex);

        return .{
            .font_texture = font_tex,
            .vert_buffer_size = 0,
            .vert_buffer = vert_buffer,
            .index_buffer_size = 0,
            .index_buffer = gfx.IndexBuffer.init(0, true),
            .shader = gfx.Shader.initFromBytes(@embedFile("assets/VertexColorTexture.fxb")) catch unreachable,
        };
    }

    pub fn deinit(self: Renderer) void {
        self.font_texture.deinit();
        self.vert_buffer.deinit();
        self.index_buffer.deinit();
    }

    pub fn render(self: *Renderer) void {
        imgui.igEndFrame();
        imgui.igRender();

        const io = imgui.igGetIO();
        const draw_data = imgui.igGetDrawData();
        if (draw_data.TotalVtxCount == 0) return;

        self.updateBuffers(draw_data);

        imgui.ImDrawData_ScaleClipRects(draw_data, io.DisplayFramebufferScale);
        const width = @floatToInt(i32, draw_data.DisplaySize.x * io.DisplayFramebufferScale.x);
        const height = @floatToInt(i32, draw_data.DisplaySize.y * io.DisplayFramebufferScale.y);

        const transform = aya.math.Mat32.initOrtho(@intToFloat(f32, width), @intToFloat(f32, height));
        self.shader.setParamByIndex(aya.math.Mat32, self.shader.transform_matrix_index, transform);
        self.shader.apply();

        var bindings_updated = true;
        var vert_buffer_binding = fna.VertexBufferBinding{
            .vertexBuffer = self.vert_buffer.buffer,
            .vertexDeclaration = gfx.VertexBuffer.vertexDeclarationForType(gfx.Vertex) catch unreachable,
        };

        var state = fna.RasterizerState{ .scissorTestEnable = 1 };
        gfx.setRasterizerState(&state);

        for (draw_data.CmdLists[0..@intCast(usize, draw_data.CmdListsCount)]) |list, i| {
            fna.FNA3D_SetVertexBufferData(gfx.device, self.vert_buffer.buffer, 0, list.VtxBuffer.Data, list.VtxBuffer.Size, @sizeOf(imgui.ImDrawVert), @sizeOf(imgui.ImDrawVert), .none);
            fna.FNA3D_SetIndexBufferData(gfx.device, self.index_buffer.buffer, 0, list.IdxBuffer.Data, list.IdxBuffer.Size * @sizeOf(imgui.ImDrawIdx), .none);

            for (list.CmdBuffer.Data[0..@intCast(usize, list.CmdBuffer.Size)]) |cmd| {
                if (cmd.UserCallback) |cb| {
                    cb(list, &cmd);
                } else {
                    var clip_rect = fna.Rect{
                        .x = @floatToInt(i32, cmd.ClipRect.x - draw_data.DisplayPos.x),
                        .y = @floatToInt(i32, cmd.ClipRect.y - draw_data.DisplayPos.y),
                        .w = @floatToInt(i32, cmd.ClipRect.z - cmd.ClipRect.x),
                        .h = @floatToInt(i32, cmd.ClipRect.w - cmd.ClipRect.y),
                    };

                    if (clip_rect.x < width and clip_rect.y < height and clip_rect.h >= 0 and clip_rect.w >= 0) {
                        gfx.device.setScissorRect(&clip_rect);
                        gfx.Texture.bindTexture(@ptrCast(*fna.Texture, cmd.TextureId), 0);

                        gfx.device.applyVertexBufferBindings(&vert_buffer_binding, 1, bindings_updated, @intCast(i32, cmd.VtxOffset));
                        gfx.device.drawIndexedPrimitives(.triangle_list, @intCast(i32, cmd.VtxOffset), 0, list.VtxBuffer.Size, @intCast(i32, cmd.IdxOffset), @intCast(i32, cmd.ElemCount / 3), self.index_buffer.buffer, .sixteen_bit);
                        bindings_updated = false;
                    }
                }
            }
        }

        // reset the scissor
        gfx.setScissor(.{ .w = width, .h = height });
    }

    pub fn updateBuffers(self: *Renderer, draw_data: *imgui.ImDrawData) void {
        // Expand buffers if we need more room
        if (draw_data.TotalVtxCount > self.vert_buffer_size) {
            self.vert_buffer.deinit();
            const vert_decl = gfx.VertexBuffer.vertexDeclarationForType(gfx.Vertex) catch unreachable;
            self.vert_buffer_size = @floatToInt(i32, @intToFloat(f32, draw_data.TotalVtxCount) * 1.5);
            self.vert_buffer = gfx.VertexBuffer.init(gfx.Vertex, self.vert_buffer_size, false);
        }

        if (draw_data.TotalIdxCount > self.index_buffer_size) {
            self.index_buffer.deinit();
            self.index_buffer_size = @floatToInt(i32, @intToFloat(f32, draw_data.TotalIdxCount) * 1.5);
            self.index_buffer = gfx.IndexBuffer.init(self.index_buffer_size, false);
        }
    }
};
