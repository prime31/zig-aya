const std = @import("std");
const fs = std.fs;
const path = std.fs.path;
const known_folders = @import("known-folders.zig");
const aya = @import("aya");
usingnamespace @import("imgui");

var only_dirs = false;
var hide_hidden_dirs = true;

var root_dir: ?[]const u8 = undefined;
var dir: fs.Dir = undefined;
var current_dir: ?[]const u8 = undefined;
var selected_file: ?[]const u8 = undefined;

var files = std.ArrayList([]const u8).init(aya.mem.allocator);
var directories = std.ArrayList([]const u8).init(aya.mem.allocator);

pub fn draw() bool {
    if (current_dir == null)
        changeDir(fs.cwd().openDir(".", .{ .iterate = true }) catch unreachable);

    if (ogButton("Home")) changeDirToKnownFolder(.home);
    igSameLine(0, 15);
    if (ogButton("Desktop")) changeDirToKnownFolder(.desktop);
    igSameLine(0, 15);
    if (ogButton("Documents")) changeDirToKnownFolder(.documents);

    igText(current_dir.?.ptr);

    if (ogBeginChildFrame(1, .{ .x = 400, .y = 300 }, ImGuiWindowFlags_None)) {
        defer igEndChildFrame();

        if (dir.access("../", .{})) {
            igPushStyleColorU32(ImGuiCol_Text, aya.math.Color.yellow.value);
            if (igSelectableBool("../", false, ImGuiSelectableFlags_DontClosePopups, .{})) {
                if (fs.cwd().openDir("../", .{ .iterate = true })) |new_dir| {
                    changeDir(new_dir);
                } else |err| {
                    std.debug.print("couldnt open dir ../: {}\n", .{err});
                }
            }
            igPopStyleColor(1);
        } else |err| {}

        igPushStyleColorU32(ImGuiCol_Text, aya.math.Color.yellow.value);
        for (directories.items) |entry_name| {
            if (igSelectableBool(entry_name.ptr, false, ImGuiSelectableFlags_DontClosePopups, .{}))
                changeDir(fs.cwd().openDir(entry_name, .{ .iterate = true }) catch unreachable);
        }
        igPopStyleColor(1);

        if (!only_dirs) {
            for (files.items) |entry_name| {
                const is_selected = selected_file != null and std.mem.eql(u8, entry_name, selected_file.?);
                if (igSelectableBool(entry_name.ptr, is_selected, ImGuiSelectableFlags_DontClosePopups, .{}))
                    selected_file = entry_name;
            }
        }
    }

    if (ogButton("Cancel")) {
        igCloseCurrentPopup();
        return false;
    }

    if (only_dirs) {
        igSameLine(igGetWindowContentRegionWidth() - 30, 0);
        if (ogButton("Open")) {
            std.debug.print("current_dir: {}, selected_file: {}\n", .{current_dir, selected_file});
            igCloseCurrentPopup();
            return true;
        }
    }

    if (selected_file != null) {
        igSameLine(igGetWindowContentRegionWidth() - 30, 0);
        if (ogButton("Open")) {
            std.debug.print("current_dir: {}, selected_file: {}\n", .{current_dir, selected_file});
            igCloseCurrentPopup();
            return true;
        }
    }

    return false;
}

pub fn setup(dont_show_hidden_dirs: bool, only_display_directories: bool) void {
    hide_hidden_dirs = dont_show_hidden_dirs;
    only_dirs = only_display_directories;

    current_dir = null;
    selected_file = null;
}

fn changeDirToKnownFolder(known: known_folders.KnownFolder) void {
    if (known_folders.getPath(aya.mem.tmp_allocator, known)) |maybe_folder| {
        if (maybe_folder) |folder| {
            changeDir(fs.cwd().openDir(folder, .{ .iterate = true }) catch unreachable);
        }
    } else |err| {
        std.debug.print("couldnt get folder {}: {}\n", .{ known, err });
    }
}

fn changeDir(new_dir: fs.Dir) void {
    selected_file = null;
    dir = new_dir;
    dir.setAsCwd() catch unreachable;
    const tmp_dir = std.process.getCwdAlloc(aya.mem.tmp_allocator) catch unreachable;
    current_dir = aya.mem.allocator.dupeZ(u8, tmp_dir) catch unreachable;

    files.items.len = 0;
    directories.items.len = 0;

    var iter = dir.iterate();
    while (iter.next() catch unreachable) |entry| {
        if (entry.kind == .File) {
            files.append(aya.mem.allocator.dupeZ(u8, entry.name) catch unreachable) catch unreachable;
        } else if (entry.kind == .Directory) {
            if (!hide_hidden_dirs or (hide_hidden_dirs and !std.mem.startsWith(u8, entry.name, ".")))
                directories.append(aya.mem.allocator.dupeZ(u8, entry.name) catch unreachable) catch unreachable;
        }
    }
}
