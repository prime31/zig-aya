const std = @import("std");
const aya = @import("aya");
const stb = @import("stb");
const ig = @import("imgui");
const zgpu = @import("zgpu");
const wgpu = zgpu.wgpu;

pub const GPUInterface = @import("zgpu").wgpu.dawn.Interface;

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

        // Create our render pipeline
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

        // Describe which data we will pass to our shader (GPU program)
        const bind_group_layout = pipeline.getBindGroupLayout(0);
        defer bind_group_layout.release();

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

        // const bind_group = gctx.createBindGroup(bind_group_layout, &.{
        //     .{ .binding = 0, .buffer_handle = gctx.uniforms.buffer, .offset = 0, .size = 256 },
        //     .{ .binding = 1, .texture_view_handle = texture_view },
        //     .{ .binding = 2, .sampler_handle = sampler },
        // });

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

            // _ = zgui.sliderInt("Mipmap Level", .{
            //     .v = &demo.mip_level,
            //     .min = 0,
            //     .max = @as(i32, @intCast(demo.gctx.lookupResourceInfo(demo.texture).?.mip_level_count - 1)),
            // });
        }
    }
};
