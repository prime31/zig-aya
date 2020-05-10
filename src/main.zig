const std = @import("std");
const fna = @import("fna");
const mojo = fna.mojo;

const png = @embedFile("../assets/font.png");
const Allocator = std.mem.Allocator;

pub const Shader = extern struct {
    effect: ?*fna.Effect = null,
    mojoEffect: ?*mojo.Effect = null,
};

const Vertex = struct {
    pos: Vec2,
    uv: Vec2,
    col: u32 = 0xFFFFFFFF,
};

const Vec2 = struct {
    x: f32 = 0,
    y: f32 = 0,
};

var vertDecl: fna.VertexDeclaration = undefined;
var vertBindings: fna.VertexBufferBinding = undefined;
var vertBuffer: ?*fna.Buffer = undefined;
var vertElems: [3]fna.VertexElement = undefined;

pub fn main() anyerror!void {
    var attrs = @bitCast(c_int, fna.FNA3D_PrepareWindowAttributes());
    attrs |= c.SDL_WINDOW_RESIZABLE;

    if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
        c.SDL_Log("Unable to initialize SDL: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    }
    defer c.SDL_Quit();

    // read file with SDL_RWops
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = &arena.allocator;

    var rw = c.SDL_RWFromFile("assets/font.png", "rb");
    const file_size = c.SDL_RWsize(rw);
    const bytes = try allocator.alloc(u8, @intCast(usize, file_size));
    const read = c.SDL_RWread(rw, @ptrCast(*c_void, bytes), 1, @intCast(usize, file_size));
    _ = c.SDL_RWclose(rw);
    std.debug.warn("rw: {}, size: {}, read: {}\n", .{ rw, file_size, read });

    const window = c.SDL_CreateWindow("Zig FNA3D", c.SDL_WINDOWPOS_UNDEFINED, c.SDL_WINDOWPOS_UNDEFINED, 640, 480, @bitCast(u32, attrs)) orelse {
        c.SDL_Log("Unable to create window: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer c.SDL_DestroyWindow(window);

    var params = fna.PresentationParameters{
        .backBufferWidth = 640,
        .backBufferHeight = 480,
        .backBufferFormat = .color,
        .multiSampleCount = 480,
        .deviceWindowHandle = window,
        .isFullScreen = 0,
        .depthStencilFormat = .none,
        .presentationInterval = .default,
        .displayOrientation = .default,
        .renderTargetUsage = .platform_contents,
    };
    const device = fna.FNA3D_CreateDevice(&params, 1);

    const tex = fna.img.load(device, "assets/font.png");
    std.debug.warn("loaded tex: {}\n", .{tex});

    // device setup
    var viewport = fna.Viewport{ .x = 0, .y = 0, .w = 640, .h = 480, .minDepth = 0, .maxDepth = 1 };
    fna.FNA3D_SetViewport(device, &viewport);

    var rasterizer = std.mem.zeroes(fna.RasterizerState);
    fna.FNA3D_ApplyRasterizerState(device, &rasterizer);

    var blend = fna.BlendState{
        .colorSourceBlend = .source_alpha,
        .colorDestinationBlend = .inverse_source_alpha,
        .colorBlendFunction = .add,
        .alphaSourceBlend = .source_alpha,
        .alphaDestinationBlend = .inverse_source_alpha,
        .alphaBlendFunction = .add,
        .colorWriteEnable = .all,
        .colorWriteEnable1 = .all,
        .colorWriteEnable2 = .all,
        .colorWriteEnable3 = .all,
        .blendFactor = .{ .r = 255, .g = 255, .b = 255, .a = 255 },
        .multiSampleMask = -1,
    };
    fna.FNA3D_SetBlendState(device, &blend);

    var depthStencil = std.mem.zeroes(fna.DepthStencilState);
    fna.FNA3D_SetDepthStencilState(device, &depthStencil);

    const shader = createShader(device);
    createMesh(device);

    var quit = false;
    while (!quit) {
        var event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.@"type") {
                c.SDL_QUIT => {
                    quit = true;
                },
                else => {},
            }
        }

        var clear_color = fna.Vec4{ .x = 0.8, .y = 0.2, .z = 0.3, .w = 1 };
        fna.FNA3D_BeginFrame(device);
        fna.FNA3D_Clear(device, .target, &clear_color, 0, 0);

        fna.FNA3D_ApplyVertexBufferBindings(device, &vertBindings, 1, 0, 0);
        fna.FNA3D_DrawPrimitives(device, .triangle_list, 0, 2);

        fna.FNA3D_SwapBuffers(device, null, null, window);

        c.SDL_Delay(17);
    }
}

fn createMesh(device: ?*fna.Device) void {
    vertElems[0] = fna.VertexElement{
        .offset = 0,
        .vertexElementFormat = .vector2,
        .vertexElementUsage = .position,
        .usageIndex = 0,
    };
    vertElems[1] = fna.VertexElement{
        .offset = 8,
        .vertexElementFormat = .vector2,
        .vertexElementUsage = .texture_coordinate,
        .usageIndex = 0,
    };
    vertElems[2] = fna.VertexElement{
        .offset = 16,
        .vertexElementFormat = .color,
        .vertexElementUsage = .color,
        .usageIndex = 0,
    };
    vertDecl = fna.VertexDeclaration{
        .vertexStride = 20,
        .elementCount = 3,
        .elements = &vertElems,
    };

    //@sizeOf(Vec2)
    var vertices = [_]Vertex{
        .{ .pos = .{ .x = 0.5, .y = 0.5 }, .uv = .{ .x = 1, .y = 1 }, .col = 0xFFFFFFFF },
        .{ .pos = .{ .x = 0.5, .y = -0.5 }, .uv = .{ .x = 1, .y = 0 }, .col = 0x00FF0FFF },
        .{ .pos = .{ .x = -0.5, .y = -0.5 }, .uv = .{ .x = 0, .y = 0 }, .col = 0xFF00FFFF },
        .{ .pos = .{ .x = -0.5, .y = -0.5 }, .uv = .{ .x = 0, .y = 0 }, .col = 0xFF00FFFF },
        .{ .pos = .{ .x = -0.5, .y = 0.5 }, .uv = .{ .x = 0, .y = 1 }, .col = 0x00FFFFFF },
        .{ .pos = .{ .x = 0.5, .y = 0.5 }, .uv = .{ .x = 1, .y = 1 }, .col = 0xFFFFFFFF },
    };

    vertBuffer = fna.FNA3D_GenVertexBuffer(device, 0, .write_only, vertices.len, 20);
    fna.FNA3D_SetVertexBufferData(device, vertBuffer, 0, &vertices[0], @intCast(c_int, @sizeOf(Vertex) * vertices.len), 1, 1, .none);

    const indices = [_]u16{
        0, 1, 2, 0, 2, 3,
    };

    vertBindings = fna.VertexBufferBinding{
        .vertexBuffer = vertBuffer,
        .vertexDeclaration = vertDecl,
        .vertexOffset = 0,
        .instanceFrequency = 0,
    };
}

fn createShader(device: ?*fna.Device) Shader {
    var vertColor = @embedFile("../assets/VertexColor.fxb");

    // hack until i figure out how to get around const
    var slice: [vertColor.len]u8 = undefined;
    for (vertColor) |s, i|
        slice[i] = s;

    var shader = Shader{};
    fna.FNA3D_CreateEffect(device, &slice[0], vertColor.len, &shader.effect, &shader.mojoEffect);

    var effect_changes = std.mem.zeroes(mojo.EffectStateChanges);
    fna.FNA3D_ApplyEffect(device, shader.effect, 0, &effect_changes);

    return shader;
}

fn create(compressed_bytes: []const u8) void {
    var width: c_int = undefined;
    var height: c_int = undefined;

    if (c.stbi_info_from_memory(compressed_bytes.ptr, @intCast(c_int, compressed_bytes.len), &width, &height, null) == 0) {
        std.debug.warn("oh shit\n", .{});
    } else {
        std.debug.warn("loaded, {} x {}\n", .{ width, height });
    }

    const bits_per_channel = 8;
    const channel_count = 4;
    const image_data = c.stbi_load_from_memory(compressed_bytes.ptr, @intCast(c_int, compressed_bytes.len), &width, &height, null, channel_count);

    const raw = image_data[0 .. @intCast(u32, width) * @intCast(u32, height) * 8];
    std.debug.warn("image_data, {}\n", .{image_data});
}
