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
    pipeline: zgpu.RenderPipelineHandle,
    texture: zgpu.TextureHandle,
    bind_group: zgpu.BindGroupHandle,
} = undefined;

const StartupSystem = struct {
    pub fn run(gctx_res: ResMut(zgpu.GraphicsContext)) void {
        const gctx = gctx_res.getAssertExists();

        // Create a texture.
        const image = stb.Image.init("examples/assets/sword_dude.png") catch unreachable;
        defer image.deinit();

        const texture = gctx.createTexture(.{
            .usage = .{ .texture_binding = true, .copy_dst = true },
            .size = .{
                .width = image.w,
                .height = image.h,
                .depth_or_array_layers = 1,
            },
            .format = zgpu.imageInfoToTextureFormat(image.channels, image.bytes_per_component, image.is_hdr),
        });
        const texture_view = gctx.createTextureView(texture, .{});

        gctx.queue.writeTexture(
            &.{ .texture = gctx.lookupResource(texture).? },
            &.{
                .bytes_per_row = image.bytesPerRow(),
                .rows_per_image = image.h,
            },
            &.{ .width = image.w, .height = image.h },
            image.getImageData(),
        );

        // Create a sampler.
        const sampler = gctx.createSampler(.{});

        const bind_group_layout = gctx.createBindGroupLayout(&.{
            // zgpu.bufferEntry(0, .{ .vertex = true, .fragment = true }, .uniform, .true, 0),
            zgpu.samplerEntry(0, .{ .fragment = true }, .filtering),
            zgpu.textureEntry(1, .{ .fragment = true }, .float, .dimension_2d, .false),
        });
        defer gctx.releaseResource(bind_group_layout);

        const bind_group = gctx.createBindGroup(bind_group_layout, &.{
            // .{ .binding = 0, .buffer_handle = gctx.uniforms.buffer, .offset = 0, .size = 256 },
            .{ .binding = 0, .sampler_handle = sampler },
            .{ .binding = 1, .texture_view_handle = texture_view },
        });

        // (Async) Create a render pipeline.
        {
            const pipeline_layout = gctx.createPipelineLayout(&.{
                bind_group_layout,
            });
            defer gctx.releaseResource(pipeline_layout);

            const shader_module = zgpu.createWgslShaderModule(gctx.device, @embedFile("fullscreen.wgsl"), null);
            defer shader_module.release();

            const color_targets = [_]wgpu.ColorTargetState{.{
                .format = zgpu.GraphicsContext.swapchain_format,
            }};

            // Create a render pipeline.
            const pipeline_descriptor = wgpu.RenderPipeline.Descriptor{
                .vertex = .{
                    .module = shader_module,
                    .entry_point = "fullscreen_vertex_shader",
                },
                .fragment = &.{
                    .module = shader_module,
                    .entry_point = "frag_main",
                    .target_count = color_targets.len,
                    .targets = &color_targets,
                },
            };
            gctx.createRenderPipelineAsync(pipeline_layout, pipeline_descriptor, &state.pipeline);
        }

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

            pass: {
                const pipeline = gctx.lookupResource(state.pipeline) orelse break :pass;
                const bind_group = gctx.lookupResource(state.bind_group) orelse break :pass;

                const c = zgpu.wgpu.Color{ .r = @floatCast(color.r), .g = @floatCast(color.g), .b = @floatCast(color.b), .a = @floatCast(color.a) };
                const pass = zgpu.beginRenderPassSimple(encoder, .clear, back_buffer_view, c, null, null);
                defer zgpu.endReleasePass(pass);

                // Render using our pipeline
                pass.setPipeline(pipeline);
                pass.setBindGroup(0, bind_group, &.{});
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
