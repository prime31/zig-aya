const std = @import("std");
const aya = @import("aya");
const stb = @import("stb");
const ig = @import("imgui");
const zgpu = @import("zgpu");
const wgpu = zgpu.wgpu;

pub const GPUInterface = wgpu.dawn.Interface;

const App = aya.App;
const ResMut = aya.ResMut;

pub fn main() !void {
    std.debug.print("\n", .{});

    App.init()
        .addPlugins(aya.DefaultPlugins)
        .addSystems(aya.Startup, StartupSystem)
        .addSystems(aya.PreUpdate, ImguiSystem)
        .addSystems(aya.Update, UpdateSystem)
        .run();
}

var state: struct {
    pipeline: *wgpu.RenderPipeline,
    texture: *wgpu.Texture,
    bind_group: *wgpu.BindGroup,
} = undefined;

const StartupSystem = struct {
    pub fn run(gctx_res: ResMut(zgpu.GraphicsContext)) void {
        const gctx = gctx_res.getAssertExists();

        // Load our shader that will render a fullscreen textured quad using two triangles
        const shader_module = zgpu.createWgslShaderModule(gctx.device, @embedFile("fullscreen.wgsl"), null);
        defer shader_module.release();

        // bind group layout
        const bind_group_layout_entries = [_]wgpu.BindGroupLayout.Entry{
            wgpu.BindGroupLayout.Entry.sampler(0, .{ .fragment = true }, .filtering),
            wgpu.BindGroupLayout.Entry.texture(1, .{ .fragment = true }, .float, .dimension_2d, false),
        };
        const bind_group_layout = gctx.device.createBindGroupLayout(&.{
            .entries = &bind_group_layout_entries,
            .entry_count = bind_group_layout_entries.len,
        });

        // Create our render pipeline
        const pipeline_layout = gctx.device.createPipelineLayout(&.{
            .bind_group_layout_count = 1,
            .bind_group_layouts = &[_]*wgpu.BindGroupLayout{bind_group_layout},
        });
        defer pipeline_layout.release();

        const color_target = wgpu.ColorTargetState{
            .format = zgpu.GraphicsContext.swapchain_format,
            .blend = &.{},
        };
        const fragment_state = wgpu.FragmentState.init(.{
            .module = shader_module,
            .entry_point = "frag_main",
            .targets = &.{color_target},
        });
        const pipeline_descriptor = wgpu.RenderPipeline.Descriptor{
            .layout = pipeline_layout,
            .fragment = &fragment_state,
            .vertex = .{
                .module = shader_module,
                .entry_point = "fullscreen_vertex_shader",
            },
        };
        const pipeline = gctx.device.createRenderPipeline(&pipeline_descriptor);

        // Create a texture.
        const image = stb.Image.init("examples/assets/sword_dude.png") catch unreachable;
        defer image.deinit();

        const texture = gctx.device.createTexture(&.{
            .usage = .{ .texture_binding = true, .copy_dst = true },
            .size = .{
                .width = image.w,
                .height = image.h,
                .depth_or_array_layers = 1,
            },
            .format = zgpu.imageInfoToTextureFormat(image.channels, image.bytes_per_component, image.is_hdr),
        });

        const texture_view = texture.createView(&.{});
        defer texture_view.release();

        gctx.queue.writeTexture(
            &.{ .texture = texture },
            &.{
                .bytes_per_row = image.bytesPerRow(),
                .rows_per_image = image.h,
            },
            &.{ .width = image.w, .height = image.h },
            image.getImageData(),
        );

        const sampler = gctx.device.createSampler(&.{});
        defer sampler.release();

        // Describe which data we will pass to our shader (GPU program)
        const bind_group = gctx.device.createBindGroup(&wgpu.BindGroup.Descriptor.init(.{
            .layout = bind_group_layout,
            .entries = &.{
                wgpu.BindGroup.Entry.sampler(0, sampler),
                wgpu.BindGroup.Entry.textureView(1, texture_view),
            },
        }));

        state.pipeline = pipeline;
        state.bind_group = bind_group;
        state.texture = texture;
    }
};

const UpdateSystem = struct {
    pub fn run(gctx_res: ResMut(zgpu.GraphicsContext), clear_color_res: ResMut(aya.ClearColor)) void {
        const gctx = gctx_res.getAssertExists();
        const color = clear_color_res.getAssertExists();

        const back_buffer_view = gctx.swapchain.getCurrentTextureView() orelse return;
        defer back_buffer_view.release();

        const commands = commands: {
            const encoder = gctx.device.createCommandEncoder(null);
            defer encoder.release();

            {
                const c = zgpu.wgpu.Color{ .r = @floatCast(color.r), .g = @floatCast(color.g), .b = @floatCast(color.b), .a = @floatCast(color.a) };
                const pass = zgpu.beginRenderPassSimple(encoder, .clear, back_buffer_view, c, null, null);
                defer zgpu.endReleasePass(pass);

                // Render using our pipeline
                pass.setPipeline(state.pipeline);
                pass.setBindGroup(0, state.bind_group, &.{});
                pass.draw(3, 1, 0, 0);
            }

            break :commands encoder.finish(null);
        };
        defer commands.release();

        gctx.submit(&.{commands});
    }
};

const ImguiSystem = struct {
    pub fn run(gctx_res: ResMut(zgpu.GraphicsContext)) void {
        const gctx = gctx_res.getAssertExists();

        ig.igSetNextWindowPos(.{ .x = 20, .y = 20 }, ig.ImGuiCond_Always, .{ .x = 0, .y = 0 });
        if (ig.igBegin("Demo", null, ig.ImGuiWindowFlags_None)) {
            defer ig.igEnd();

            ig.igBulletText("Average: %f ms/frame\nFPS: %f\nDelta time: %f", gctx.stats.average_cpu_time, gctx.stats.fps, gctx.stats.delta_time);
            ig.igSpacing();
        }
    }
};
