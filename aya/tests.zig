const std = @import("std");
const tilemap = @import("src/tilemap/tilemap.zig");

// include all files with tests
comptime {
    _ = @import("src/fs.zig");
    // _ = @import("src/input.zig"); // Zig bug: TODO buf_read_value_bytes union type

    _ = @import("src/mem/sdl_allocator.zig");
    _ = @import("src/mem/scratch_allocator.zig");
    _ = @import("src/mem/sdl_stream.zig");

    _ = @import("src/math/math.zig");
    _ = @import("src/math/vec2.zig");
    _ = @import("src/math/color.zig");
    // _ = @import("src/math/mat32.zig");

    // _ = @import("src/gfx/textures.zig"); // requires firing up a Window and sets up a Device in its test
    // _ = @import("src/gfx/gfx.zig"); // Zig bug: anything that imports aya fails due to debug.zig
    // _ = @import("src/gfx/shader.zig");
    // _ = @import("src/gfx/buffers.zig");
    // _ = @import("src/gfx/mesh.zig");
    // _ = @import("src/gfx/batcher.zig");
    // _ = @import("src/gfx/triangle_batcher.zig");
    // _ = @import("src/gfx/atlas_batch.zig");
    // _ = @import("src/gfx/offscreen_pass.zig"); // Zig bug: TODO buf_read_value_bytes union type

    _ = @import("src/utils/utils.zig");
}
