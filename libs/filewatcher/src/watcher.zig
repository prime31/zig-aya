const std = @import("std");
const builtin = @import("builtin");

pub fn watchPath(path: [*c]const u8, cb: ?*const fn (path: [*c]const u8) callconv(.C) void) void {
    if (builtin.target.os.tag == .macos) {
        file_watcher_watch_path(path, cb);
    } else {
        std.debug.print("FileWatcher only works on macos for now...\n", .{});
    }
}

extern fn file_watcher_watch_path(path: [*c]const u8, cb: ?*const fn (path: [*c]const u8) callconv(.C) void) void;
