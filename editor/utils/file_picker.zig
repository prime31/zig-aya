const std = @import("std");
const fs = std.fs;
const path = std.fs.path;
const known_folders = @import("known-folders.zig");
const aya = @import("aya");
const imgui = @import("imgui");

var only_dirs = false;
var hide_hidden_dirs = true;
var picker_description: [:0]const u8 = undefined;

pub var selected_dir: ?[]const u8 = undefined;
pub var selected_file: ?[]const u8 = undefined;

var dir: fs.IterableDir = undefined;
var buffer: [25:0]u8 = undefined;

var files = std.ArrayList([]const u8).init(aya.mem.allocator);
var directories = std.ArrayList([]const u8).init(aya.mem.allocator);

// usage:
//  if (open_picker) { utils.file_picker.setup(..);imgui.ogOpenPopup("File Picker");

// if (igBeginPopupModal("File Picker", null, ImGuiWindowFlags_AlwaysAutoResize)) {
//     defer imgui.igEndPopup();
//     if (utils.file_picker.draw()) |res| {
//          std.debug.print("done with true\n", .{});
//          imgui.igCloseCurrentPopup();
//     }
// }

pub fn setup(description: [:0]const u8, dont_show_hidden_dirs: bool, only_display_directories: bool) void {
    picker_description = description;
    hide_hidden_dirs = dont_show_hidden_dirs;
    only_dirs = only_display_directories;

    if (selected_dir) |directory| aya.mem.allocator.free(directory);
    selected_dir = null;
    selected_file = null;
}

pub fn cleanup() void {
    if (selected_dir) |directory| aya.mem.allocator.free(directory);
    selected_dir = null;
    selected_file = null;
    dir.close();
}

/// when draw returns true selected_file and selected_dir are valid and should be copied if needed.
/// if false is returned cancel was pressed
pub fn draw() ?bool {
    // if we dont have a selected_dir, get one started
    if (selected_dir == null) {
        const tmp_dir = std.process.getCwdAlloc(aya.mem.tmp_allocator) catch unreachable;
        selected_dir = aya.mem.allocator.dupeZ(u8, tmp_dir) catch unreachable;
        dir = fs.cwd().openIterableDir(selected_dir.?, .{ .access_sub_paths = true }) catch unreachable;
        changeDir(".");
    }

    imgui.ogColoredText(0.2, 0.8, 0.2, picker_description);
    imgui.ogDummy(.{ .y = 5 });

    if (imgui.ogButton("Home")) changeDirToKnownFolder(.home);
    imgui.igSameLine(0, 15);
    if (imgui.ogButton("Desktop")) changeDirToKnownFolder(.desktop);
    imgui.igSameLine(0, 15);
    if (imgui.ogButton("Documents")) changeDirToKnownFolder(.documents);
    imgui.igSameLine(imgui.igGetWindowContentRegionWidth() - 120, 0);
    if (imgui.ogButton("Create Directory")) imgui.ogOpenPopup("##create-directory");

    imgui.igText(selected_dir.?.ptr);

    if (imgui.ogBeginChildFrame(1, .{ .x = 400, .y = 300 }, imgui.ImGuiWindowFlags_AlwaysAutoResize)) {
        defer imgui.igEndChildFrame();

        if (dir.dir.access("..", .{})) {
            imgui.igPushStyleColorU32(imgui.ImGuiCol_Text, aya.math.Color.yellow.value);
            if (imgui.ogSelectableBool("..", false, imgui.ImGuiSelectableFlags_DontClosePopups, .{})) {
                changeDir("..");
            }
            imgui.igPopStyleColor(1);
        } else |_| {}

        imgui.igPushStyleColorU32(imgui.ImGuiCol_Text, aya.math.Color.yellow.value);
        for (directories.items) |entry_name| {
            if (imgui.ogSelectableBool(entry_name.ptr, false, imgui.ImGuiSelectableFlags_DontClosePopups, .{}))
                changeDir(entry_name);
        }
        imgui.igPopStyleColor(1);

        if (!only_dirs) {
            for (files.items) |entry_name| {
                const is_selected = selected_file != null and std.mem.eql(u8, entry_name, selected_file.?);
                if (imgui.ogSelectableBool(entry_name.ptr, is_selected, imgui.ImGuiSelectableFlags_DontClosePopups, .{}))
                    selected_file = entry_name;
            }
        }
    }

    if (imgui.ogButton("Cancel")) return false;

    if (only_dirs) {
        imgui.igSameLine(imgui.igGetWindowContentRegionWidth() - 30, 0);
        if (imgui.ogButton("Open")) return true;
    }

    if (selected_file != null) {
        imgui.igSameLine(imgui.igGetWindowContentRegionWidth() - 30, 0);
        if (imgui.ogButton("Open")) return true;
    }

    imgui.ogSetNextWindowPos(imgui.igGetIO().MousePos, imgui.ImGuiCond_Appearing, .{ .x = 0.5 });
    if (imgui.igBeginPopup("##create-directory", imgui.ImGuiWindowFlags_None)) {
        defer imgui.igEndPopup();
        _ = imgui.igInputText("", &buffer, buffer.len, imgui.ImGuiInputTextFlags_CharsNoBlank, null, null);
        if (imgui.ogButton("Cancel")) imgui.igCloseCurrentPopup();
        imgui.igSameLine(imgui.igGetWindowContentRegionWidth() - 45, 0);

        const label_sentinel_index = std.mem.indexOfScalar(u8, &buffer, 0).?;
        const disabled = label_sentinel_index == 0;
        imgui.ogPushDisabled(disabled);
        if (imgui.ogButtonEx("Create", .{})) {
            if (dir.dir.makeDir(buffer[0..label_sentinel_index])) {
                changeDir(buffer[0..label_sentinel_index]);
                imgui.igCloseCurrentPopup();
            } else |err| {
                std.debug.print("error creating dir: {any}\n", .{err});
            }
        }
        imgui.ogPopDisabled(disabled);
    }

    return null;
}

fn changeDirToKnownFolder(known: known_folders.KnownFolder) void {
    if (known_folders.getPath(aya.mem.tmp_allocator, known)) |maybe_folder| {
        if (maybe_folder) |folder| {
            changeDir(folder);
        }
    } else |err| {
        std.debug.print("couldnt get folder {any}: {any}\n", .{ known, err });
    }
}

fn changeDir(new_dir: []const u8) void {
    dir.close();

    const tmp_dir = path.resolve(aya.mem.allocator, &[_][]const u8{ selected_dir.?, new_dir }) catch unreachable;

    aya.mem.allocator.free(selected_dir.?);
    selected_dir = tmp_dir;

    if (fs.cwd().openIterableDir(selected_dir.?, .{ .access_sub_paths = true })) |next_dir| {
        dir = next_dir;
    } else |err| {
        std.debug.print("couldnt open dir ../: {any}\n", .{err});
        return;
    }

    for (files.items) |file| aya.mem.allocator.free(file);
    for (directories.items) |file| aya.mem.allocator.free(file);

    files.items.len = 0;
    directories.items.len = 0;

    var iter = dir.iterate();
    while (iter.next() catch unreachable) |entry| {
        if (entry.kind == .file) {
            if (!std.mem.startsWith(u8, entry.name, "."))
                files.append(aya.mem.allocator.dupeZ(u8, entry.name) catch unreachable) catch unreachable;
        } else if (entry.kind == .directory) {
            if (!hide_hidden_dirs or (hide_hidden_dirs and !std.mem.startsWith(u8, entry.name, ".")))
                directories.append(aya.mem.allocator.dupeZ(u8, entry.name) catch unreachable) catch unreachable;
        }
    }
}
