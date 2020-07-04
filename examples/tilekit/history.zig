const std = @import("std");
const aya = @import("aya");

const Item = struct {
    data: []u8 = undefined, /// copy of the data before it was modified
    ptr: usize = undefined, /// pointer to data
    size: usize = undefined, /// size in bytes
};

var history = struct {
    undo: std.ArrayList(Item) = undefined,
    redo: std.ArrayList(Item) = undefined,
    temp: std.ArrayList(Item) = undefined,

    pub fn init(self: *@This()) void {
        self.undo = std.ArrayList(Item).init(aya.mem.allocator);
        self.redo = std.ArrayList(Item).init(aya.mem.allocator);
        self.temp = std.ArrayList(Item).init(aya.mem.allocator);
    }

    pub fn deinit(self: @This()) void {
        self.undo.deinit();
        self.redo.deinit();
        self.temp.deinit();
    }
}{};

pub fn init() void {
    history.init();
}

pub fn deinit() void {
    history.undo.deinit();
    history.redo.deinit();
    history.temp.deinit();
}

pub fn push(slice: []u8) void {
    // see if we already have this pointer on our temp stack
    for (history.temp.items) |temp| {
        if (temp.ptr == @ptrToInt(slice.ptr)) return;
    }

    const data = std.mem.dupe(aya.mem.allocator, u8, slice) catch unreachable;

    history.temp.append(.{
        .data = data,
        .ptr = @ptrToInt(slice.ptr),
        .size = slice.len,
    }) catch unreachable;
}

pub fn commit() void {
    while (history.temp.popOrNull()) |item| {
        // var src = std.mem.bytesAsSlice(u8, @intToPtr([*]u8, item.ptr)[0..item.size]);
        var src = @intToPtr([*]u8, item.ptr);
        if (std.mem.eql(u8, src[0..item.size], item.data)) {
            aya.mem.allocator.free(item.data);
        } else {
            std.debug.print("changed. src: {}, item.data: {}\n", .{src[0], item.data[0]});
            history.undo.append(item) catch unreachable;
        }
    }
}

pub fn undo() void {
    var last_ptr: usize = 0;
    while (history.undo.popOrNull()) |item| {
        if (last_ptr != 0 and last_ptr != item.ptr) {
            history.undo.appendAssumeCapacity(item);
            return;
        }
        last_ptr = item.ptr;

        var dst = @intToPtr([*]u8, item.ptr);

        // dupe the data currently in the pointer and copy it to our Item so that we can use it for a redo later
        const tmp = std.mem.dupe(aya.mem.tmp_allocator, u8, dst[0..item.size]) catch unreachable;
        std.mem.copy(u8, dst[0..item.size], item.data);
        std.mem.copy(u8, item.data, tmp);

        history.redo.append(item) catch unreachable;
    }
}

pub fn redo() void {
    var last_ptr: usize = 0;
    while (history.redo.popOrNull()) |item| {
        if (last_ptr != 0 and last_ptr != item.ptr) {
            history.redo.appendAssumeCapacity(item);
            return;
        }
        last_ptr = item.ptr;

        var dst = @intToPtr([*]u8, item.ptr);

        // dupe the data currently in the pointer and copy it to our Item so that we can use it for a undo later
        const tmp = std.mem.dupe(aya.mem.tmp_allocator, u8, dst[0..item.size]) catch unreachable;
        std.mem.copy(u8, dst[0..item.size], item.data);
        std.mem.copy(u8, item.data, tmp);

        history.undo.append(item) catch unreachable;
    }
}
