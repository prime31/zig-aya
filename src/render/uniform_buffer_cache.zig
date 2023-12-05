const std = @import("std");
const aya = @import("../aya.zig");
const wgpu = aya.wgpu;

const GraphicsContext = aya.render.GraphicsContext;

pub const UniformBufferCache = struct {
    const UniformsStagingBuffer = struct {
        slice: ?[]u8 = null,
        buffer: wgpu.Buffer = undefined,
    };

    const uniforms_buffer_size = 4 * 1024 * 1024;
    const uniforms_staging_buffer_len = 8;
    const uniforms_alloc_alignment: u32 = 256;

    offset: u32 = 0,
    buffer: aya.render.BufferHandle = .{},
    stage: struct {
        num: u32 = 0,
        current: u32 = 0,
        buffers: [uniforms_staging_buffer_len]UniformsStagingBuffer = [_]UniformsStagingBuffer{.{}} ** uniforms_staging_buffer_len,
    } = .{},

    pub fn init(gctx: *GraphicsContext) UniformBufferCache {
        var self = UniformBufferCache{
            .buffer = gctx.createBuffer(&.{
                .usage = .{ .copy_dst = true, .uniform = true },
                .size = uniforms_buffer_size,
            }),
        };
        self.nextStagingBuffer(gctx);
        return self;
    }

    pub fn deinit(self: *UniformBufferCache) void {
        // Wait for all outstanding mapAsync() calls to complete.
        wait_loop: while (true) {
            _ = aya.gctx.device.poll(true, null);
            var i: u32 = 0;
            while (i < self.stage.num) : (i += 1) {
                if (self.stage.buffers[i].slice == null) {
                    continue :wait_loop;
                }
            }
            break;
        }
    }

    pub fn allocate(self: *UniformBufferCache, comptime T: type, num_elements: u32) struct { slice: []T, offset: u32 } {
        std.debug.assert(num_elements > 0);
        const size = num_elements * @sizeOf(T);

        const offset = self.offset;
        const aligned_size = (size + (uniforms_alloc_alignment - 1)) & ~(uniforms_alloc_alignment - 1);
        if ((offset + aligned_size) >= uniforms_buffer_size) {
            std.log.err("[gpu] Uniforms buffer size is too small. Consider increasing 'uniforms_buffer_size' constant.", .{});
            return .{ .slice = @as([*]T, undefined)[0..0], .offset = 0 };
        }

        const current = self.stage.current;
        const slice = (self.stage.buffers[current].slice.?.ptr + offset)[0..size];

        self.offset += aligned_size;
        return .{
            .slice = std.mem.bytesAsSlice(T, @as([]align(@alignOf(T)) u8, @alignCast(slice))),
            .offset = offset,
        };
    }

    fn uniformsMappedCallback(status: wgpu.BufferMapAsyncStatus, userdata: ?*anyopaque) callconv(.C) void {
        const usb = @as(*UniformsStagingBuffer, @ptrCast(@alignCast(userdata)));
        std.debug.assert(usb.slice == null);
        if (status == .success) {
            usb.slice = usb.buffer.getMappedRange(u8, 0, uniforms_buffer_size).?;
        } else {
            std.log.err("[gpu] Failed to map buffer (status: {s}).", .{@tagName(status)});
        }
    }

    pub fn nextStagingBuffer(self: *UniformBufferCache, gctx: *GraphicsContext) void {
        if (gctx.cpu_frame_number > 0) {
            // map staging buffer which was used this frame
            const current = self.stage.current;
            std.debug.assert(self.stage.buffers[current].slice == null);
            self.stage.buffers[current].buffer.mapAsync(
                .{ .write = true },
                0,
                uniforms_buffer_size,
                uniformsMappedCallback,
                @ptrCast(&self.stage.buffers[current]),
            );
        }

        self.offset = 0;

        var i: u32 = 0;
        while (i < self.stage.num) : (i += 1) {
            if (self.stage.buffers[i].slice != null) {
                self.stage.current = i;
                return;
            }
        }

        if (self.stage.num >= uniforms_staging_buffer_len) {
            // Wait until one of the buffers is mapped and ready to use
            while (true) {
                _ = gctx.device.poll(true, null);

                i = 0;
                while (i < self.stage.num) : (i += 1) {
                    if (self.stage.buffers[i].slice != null) {
                        self.stage.current = i;
                        return;
                    }
                }
            }
        }

        std.debug.assert(self.stage.num < uniforms_staging_buffer_len);

        const current = self.stage.num;
        self.stage.current = current;
        self.stage.num += 1;

        // Create new staging buffer
        const buffer_handle = gctx.createBuffer(&.{
            .usage = .{ .copy_src = true, .map_write = true },
            .size = uniforms_buffer_size,
            .mapped_at_creation = true,
        });

        // Add new (mapped) staging buffer to the buffer list
        self.stage.buffers[current] = .{
            .slice = gctx.lookupResource(buffer_handle).?.getMappedRange(u8, 0, uniforms_buffer_size).?,
            .buffer = gctx.lookupResource(buffer_handle).?,
        };
    }
};
