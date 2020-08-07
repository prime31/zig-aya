const std = @import("std");

/// writes out the "shaders.zig" file based on the shaders present in basics.h
pub fn main() !void {
    // TODO: run the shader builder
    //try std.os.execveZ("aya/shaders/sokol-shdc --input shd.glsl --output ../basics.h --slang glsl330:metal_macos --format sokol_impl", "", "");

    try buildShader("aya/shaders/basics.h", "aya/shaders/shaders.zig");
    try buildShader("aya/shaders/basics3d.h", "aya/shaders/shaders3d.zig");
}

fn buildShader(src_header: []const u8, dst: []const u8) !void {
    std.debug.print("---- start parsing shader header file\n", .{});
    var buffer: [std.fs.MAX_PATH_BYTES]u8 = undefined;

    const file = try std.fs.cwd().openFile(src_header, .{});
    defer file.close();
    const reader = file.reader();

    const out_file = try std.fs.cwd().createFile(dst, .{});
    defer out_file.close();
    const writer = out_file.writer();

    _ = try writer.write("usingnamespace @import(\"sokol\");\n");
    _ = try writer.write("\n");

    while (try reader.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        if (std.mem.indexOf(u8, line, "Shader program '")) |index| {
            const first_index = std.mem.indexOfScalar(u8, line, '\'').? + 1;
            const last_index = std.mem.lastIndexOfScalar(u8, line, '\'').?;
            const shader_name = line[first_index..last_index];

            const written = try std.fmt.bufPrint(&buffer, "pub extern fn {}_shader_desc() [*c]const sg_shader_desc;\n", .{shader_name});
            _ = try writer.write(written);
            std.debug.print("{}", .{written});
        }
    }

    _ = try writer.write("\n");
    _ = try writer.write(file_footer);

    std.debug.print("---- {} written\n", .{dst});
}



const file_footer =
\\// for generating the cimport.zig file uncomment this
\\// const std = @import("std");
\\// pub usingnamespace @cImport({
\\//     if (std.Target.current.os.tag == .macosx) {
\\//         @cDefine("SOKOL_METAL", "");
\\//     } else {
\\//         @cDefine("SOKOL_GLCORE33", "");
\\//     }
\\//     @cInclude("sokol/sokol_gfx.h");
\\//     @cInclude("basics.h");
\\// });
;