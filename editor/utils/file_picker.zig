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

var buffer: [25:0]u8 = undefined;

var files = std.ArrayList([]const u8).init(aya.mem.allocator);
var directories = std.ArrayList([]const u8).init(aya.mem.allocator);

// usage:
//  if (open_picker) ogOpenPopup("File Picker");

// if (igBeginPopupModal("File Picker", null, ImGuiWindowFlags_AlwaysAutoResize)) {
//     defer igEndPopup();
//     if (utils.file_picker.draw()) std.debug.print("done with true\n", .{});
// }

/// when draw returns true selected_file and current_dir are valid and should be copied if needed
pub fn draw() bool {
    if (current_dir == null)
        changeDir(fs.cwd().openDir(".", .{ .iterate = true }) catch unreachable);

    if (ogButton("Home")) changeDirToKnownFolder(.home);
    igSameLine(0, 15);
    if (ogButton("Desktop")) changeDirToKnownFolder(.desktop);
    igSameLine(0, 15);
    if (ogButton("Documents")) changeDirToKnownFolder(.documents);
    igSameLine(igGetWindowContentRegionWidth() - 120, 0);
    if (ogButton("Create Directory")) ogOpenPopup("##create-directory");

    igText(current_dir.?.ptr);

    if (ogBeginChildFrame(1, .{ .x = 400, .y = 300 }, ImGuiWindowFlags_None)) {
        defer igEndChildFrame();

        if (dir.access("../", .{})) {
            igPushStyleColorU32(ImGuiCol_Text, aya.math.Color.yellow.value);
            if (ogSelectableBool("../", false, ImGuiSelectableFlags_DontClosePopups, .{})) {
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
            if (ogSelectableBool(entry_name.ptr, false, ImGuiSelectableFlags_DontClosePopups, .{}))
                changeDir(fs.cwd().openDir(entry_name, .{ .iterate = true }) catch unreachable);
        }
        igPopStyleColor(1);

        if (!only_dirs) {
            for (files.items) |entry_name| {
                const is_selected = selected_file != null and std.mem.eql(u8, entry_name, selected_file.?);
                if (ogSelectableBool(entry_name.ptr, is_selected, ImGuiSelectableFlags_DontClosePopups, .{}))
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
            std.debug.print("current_dir: {}, selected_file: {}\n", .{ current_dir, selected_file });
            igCloseCurrentPopup();
            return true;
        }
    }

    if (selected_file != null) {
        igSameLine(igGetWindowContentRegionWidth() - 30, 0);
        if (ogButton("Open")) {
            std.debug.print("current_dir: {}, selected_file: {}\n", .{ current_dir, selected_file });
            igCloseCurrentPopup();
            return true;
        }
    }

    ogSetNextWindowPos(igGetIO().MousePos, ImGuiCond_Appearing, .{ .x = 0.5 });
    if (igBeginPopup("##create-directory", ImGuiWindowFlags_None)) {
        defer igEndPopup();
        _ = ogInputText("", &buffer, buffer.len);
        if (ogButton("Cancel")) igCloseCurrentPopup();
        igSameLine(igGetWindowContentRegionWidth() - 45, 0);

        const label_sentinel_index = std.mem.indexOfScalar(u8, &buffer, 0).?;
        const disabled = label_sentinel_index == 0;
        ogPushDisabled(disabled);
        if (ogButtonEx("Create", .{})) {
            if (dir.makeDir(buffer[0..label_sentinel_index])) {
                changeDir(fs.cwd().openDir(buffer[0..label_sentinel_index], .{ .iterate = true }) catch unreachable);
                igCloseCurrentPopup();
            } else |err| {
                std.debug.print("error creating dir: {}\n", .{err});
            }
        }
        ogPopDisabled(disabled);
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

    if (current_dir) |directory| aya.mem.allocator.free(directory);

    const tmp_dir = std.process.getCwdAlloc(aya.mem.tmp_allocator) catch unreachable;
    current_dir = aya.mem.allocator.dupeZ(u8, tmp_dir) catch unreachable;

    for (files.items) |file| aya.mem.allocator.free(file);
    for (directories.items) |file| aya.mem.allocator.free(file);

    files.items.len = 0;
    directories.items.len = 0;

    var iter = dir.iterate();
    while (iter.next() catch unreachable) |entry| {
        if (entry.kind == .File) {
            if (!std.mem.startsWith(u8, entry.name, "."))
                files.append(aya.mem.allocator.dupeZ(u8, entry.name) catch unreachable) catch unreachable;
        } else if (entry.kind == .Directory) {
            if (!hide_hidden_dirs or (hide_hidden_dirs and !std.mem.startsWith(u8, entry.name, ".")))
                directories.append(aya.mem.allocator.dupeZ(u8, entry.name) catch unreachable) catch unreachable;
        }
    }
}
