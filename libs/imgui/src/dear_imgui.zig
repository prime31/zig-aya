pub const __builtin_bswap16 = @import("std").zig.c_builtins.__builtin_bswap16;
pub const __builtin_bswap32 = @import("std").zig.c_builtins.__builtin_bswap32;
pub const __builtin_bswap64 = @import("std").zig.c_builtins.__builtin_bswap64;
pub const __builtin_signbit = @import("std").zig.c_builtins.__builtin_signbit;
pub const __builtin_signbitf = @import("std").zig.c_builtins.__builtin_signbitf;
pub const __builtin_popcount = @import("std").zig.c_builtins.__builtin_popcount;
pub const __builtin_ctz = @import("std").zig.c_builtins.__builtin_ctz;
pub const __builtin_clz = @import("std").zig.c_builtins.__builtin_clz;
pub const __builtin_sqrt = @import("std").zig.c_builtins.__builtin_sqrt;
pub const __builtin_sqrtf = @import("std").zig.c_builtins.__builtin_sqrtf;
pub const __builtin_sin = @import("std").zig.c_builtins.__builtin_sin;
pub const __builtin_sinf = @import("std").zig.c_builtins.__builtin_sinf;
pub const __builtin_cos = @import("std").zig.c_builtins.__builtin_cos;
pub const __builtin_cosf = @import("std").zig.c_builtins.__builtin_cosf;
pub const __builtin_exp = @import("std").zig.c_builtins.__builtin_exp;
pub const __builtin_expf = @import("std").zig.c_builtins.__builtin_expf;
pub const __builtin_exp2 = @import("std").zig.c_builtins.__builtin_exp2;
pub const __builtin_exp2f = @import("std").zig.c_builtins.__builtin_exp2f;
pub const __builtin_log = @import("std").zig.c_builtins.__builtin_log;
pub const __builtin_logf = @import("std").zig.c_builtins.__builtin_logf;
pub const __builtin_log2 = @import("std").zig.c_builtins.__builtin_log2;
pub const __builtin_log2f = @import("std").zig.c_builtins.__builtin_log2f;
pub const __builtin_log10 = @import("std").zig.c_builtins.__builtin_log10;
pub const __builtin_log10f = @import("std").zig.c_builtins.__builtin_log10f;
pub const __builtin_abs = @import("std").zig.c_builtins.__builtin_abs;
pub const __builtin_fabs = @import("std").zig.c_builtins.__builtin_fabs;
pub const __builtin_fabsf = @import("std").zig.c_builtins.__builtin_fabsf;
pub const __builtin_floor = @import("std").zig.c_builtins.__builtin_floor;
pub const __builtin_floorf = @import("std").zig.c_builtins.__builtin_floorf;
pub const __builtin_ceil = @import("std").zig.c_builtins.__builtin_ceil;
pub const __builtin_ceilf = @import("std").zig.c_builtins.__builtin_ceilf;
pub const __builtin_trunc = @import("std").zig.c_builtins.__builtin_trunc;
pub const __builtin_truncf = @import("std").zig.c_builtins.__builtin_truncf;
pub const __builtin_round = @import("std").zig.c_builtins.__builtin_round;
pub const __builtin_roundf = @import("std").zig.c_builtins.__builtin_roundf;
pub const __builtin_strlen = @import("std").zig.c_builtins.__builtin_strlen;
pub const __builtin_strcmp = @import("std").zig.c_builtins.__builtin_strcmp;
pub const __builtin_object_size = @import("std").zig.c_builtins.__builtin_object_size;
pub const __builtin___memset_chk = @import("std").zig.c_builtins.__builtin___memset_chk;
pub const __builtin_memset = @import("std").zig.c_builtins.__builtin_memset;
pub const __builtin___memcpy_chk = @import("std").zig.c_builtins.__builtin___memcpy_chk;
pub const __builtin_memcpy = @import("std").zig.c_builtins.__builtin_memcpy;
pub const __builtin_expect = @import("std").zig.c_builtins.__builtin_expect;
pub const __builtin_nanf = @import("std").zig.c_builtins.__builtin_nanf;
pub const __builtin_huge_valf = @import("std").zig.c_builtins.__builtin_huge_valf;
pub const __builtin_inff = @import("std").zig.c_builtins.__builtin_inff;
pub const __builtin_isnan = @import("std").zig.c_builtins.__builtin_isnan;
pub const __builtin_isinf = @import("std").zig.c_builtins.__builtin_isinf;
pub const __builtin_isinf_sign = @import("std").zig.c_builtins.__builtin_isinf_sign;
pub const __has_builtin = @import("std").zig.c_builtins.__has_builtin;
pub const __builtin_assume = @import("std").zig.c_builtins.__builtin_assume;
pub const __builtin_unreachable = @import("std").zig.c_builtins.__builtin_unreachable;
pub const __builtin_constant_p = @import("std").zig.c_builtins.__builtin_constant_p;
pub const __builtin_mul_overflow = @import("std").zig.c_builtins.__builtin_mul_overflow;
pub const __int8_t = i8;
pub const __uint8_t = u8;
pub const __int16_t = c_short;
pub const __uint16_t = c_ushort;
pub const __int32_t = c_int;
pub const __uint32_t = c_uint;
pub const __int64_t = c_longlong;
pub const __uint64_t = c_ulonglong;
pub const __darwin_intptr_t = c_long;
pub const __darwin_natural_t = c_uint;
pub const __darwin_ct_rune_t = c_int;
pub const __mbstate_t = extern union {
    __mbstate8: [128]u8,
    _mbstateL: c_longlong,
};
pub const __darwin_mbstate_t = __mbstate_t;
pub const __darwin_ptrdiff_t = c_long;
pub const __darwin_size_t = c_ulong;
pub const __builtin_va_list = [*c]u8;
pub const __darwin_va_list = __builtin_va_list;
pub const __darwin_wchar_t = c_int;
pub const __darwin_rune_t = __darwin_wchar_t;
pub const __darwin_wint_t = c_int;
pub const __darwin_clock_t = c_ulong;
pub const __darwin_socklen_t = __uint32_t;
pub const __darwin_ssize_t = c_long;
pub const __darwin_time_t = c_long;
pub const __darwin_blkcnt_t = __int64_t;
pub const __darwin_blksize_t = __int32_t;
pub const __darwin_dev_t = __int32_t;
pub const __darwin_fsblkcnt_t = c_uint;
pub const __darwin_fsfilcnt_t = c_uint;
pub const __darwin_gid_t = __uint32_t;
pub const __darwin_id_t = __uint32_t;
pub const __darwin_ino64_t = __uint64_t;
pub const __darwin_ino_t = __darwin_ino64_t;
pub const __darwin_mach_port_name_t = __darwin_natural_t;
pub const __darwin_mach_port_t = __darwin_mach_port_name_t;
pub const __darwin_mode_t = __uint16_t;
pub const __darwin_off_t = __int64_t;
pub const __darwin_pid_t = __int32_t;
pub const __darwin_sigset_t = __uint32_t;
pub const __darwin_suseconds_t = __int32_t;
pub const __darwin_uid_t = __uint32_t;
pub const __darwin_useconds_t = __uint32_t;
pub const __darwin_uuid_t = [16]u8;
pub const __darwin_uuid_string_t = [37]u8;
pub const struct___darwin_pthread_handler_rec = extern struct {
    __routine: ?*const fn (?*anyopaque) callconv(.C) void,
    __arg: ?*anyopaque,
    __next: [*c]struct___darwin_pthread_handler_rec,
};
pub const struct__opaque_pthread_attr_t = extern struct {
    __sig: c_long,
    __opaque: [56]u8,
};
pub const struct__opaque_pthread_cond_t = extern struct {
    __sig: c_long,
    __opaque: [40]u8,
};
pub const struct__opaque_pthread_condattr_t = extern struct {
    __sig: c_long,
    __opaque: [8]u8,
};
pub const struct__opaque_pthread_mutex_t = extern struct {
    __sig: c_long,
    __opaque: [56]u8,
};
pub const struct__opaque_pthread_mutexattr_t = extern struct {
    __sig: c_long,
    __opaque: [8]u8,
};
pub const struct__opaque_pthread_once_t = extern struct {
    __sig: c_long,
    __opaque: [8]u8,
};
pub const struct__opaque_pthread_rwlock_t = extern struct {
    __sig: c_long,
    __opaque: [192]u8,
};
pub const struct__opaque_pthread_rwlockattr_t = extern struct {
    __sig: c_long,
    __opaque: [16]u8,
};
pub const struct__opaque_pthread_t = extern struct {
    __sig: c_long,
    __cleanup_stack: [*c]struct___darwin_pthread_handler_rec,
    __opaque: [8176]u8,
};
pub const __darwin_pthread_attr_t = struct__opaque_pthread_attr_t;
pub const __darwin_pthread_cond_t = struct__opaque_pthread_cond_t;
pub const __darwin_pthread_condattr_t = struct__opaque_pthread_condattr_t;
pub const __darwin_pthread_key_t = c_ulong;
pub const __darwin_pthread_mutex_t = struct__opaque_pthread_mutex_t;
pub const __darwin_pthread_mutexattr_t = struct__opaque_pthread_mutexattr_t;
pub const __darwin_pthread_once_t = struct__opaque_pthread_once_t;
pub const __darwin_pthread_rwlock_t = struct__opaque_pthread_rwlock_t;
pub const __darwin_pthread_rwlockattr_t = struct__opaque_pthread_rwlockattr_t;
pub const __darwin_pthread_t = [*c]struct__opaque_pthread_t;
pub const __darwin_nl_item = c_int;
pub const __darwin_wctrans_t = c_int;
pub const __darwin_wctype_t = __uint32_t;
pub const u_int8_t = u8;
pub const u_int16_t = c_ushort;
pub const u_int32_t = c_uint;
pub const u_int64_t = c_ulonglong;
pub const register_t = i64;
pub const user_addr_t = u_int64_t;
pub const user_size_t = u_int64_t;
pub const user_ssize_t = i64;
pub const user_long_t = i64;
pub const user_ulong_t = u_int64_t;
pub const user_time_t = i64;
pub const user_off_t = i64;
pub const syscall_arg_t = u_int64_t;
pub const va_list = __darwin_va_list;
pub extern fn renameat(c_int, [*c]const u8, c_int, [*c]const u8) c_int;
pub extern fn renamex_np([*c]const u8, [*c]const u8, c_uint) c_int;
pub extern fn renameatx_np(c_int, [*c]const u8, c_int, [*c]const u8, c_uint) c_int;
pub const fpos_t = __darwin_off_t;
pub const struct___sbuf = extern struct {
    _base: [*c]u8,
    _size: c_int,
};
pub const struct___sFILEX = opaque {};
pub const struct___sFILE = extern struct {
    _p: [*c]u8,
    _r: c_int,
    _w: c_int,
    _flags: c_short,
    _file: c_short,
    _bf: struct___sbuf,
    _lbfsize: c_int,
    _cookie: ?*anyopaque,
    _close: ?*const fn (?*anyopaque) callconv(.C) c_int,
    _read: ?*const fn (?*anyopaque, [*c]u8, c_int) callconv(.C) c_int,
    _seek: ?*const fn (?*anyopaque, fpos_t, c_int) callconv(.C) fpos_t,
    _write: ?*const fn (?*anyopaque, [*c]const u8, c_int) callconv(.C) c_int,
    _ub: struct___sbuf,
    _extra: ?*struct___sFILEX,
    _ur: c_int,
    _ubuf: [3]u8,
    _nbuf: [1]u8,
    _lb: struct___sbuf,
    _blksize: c_int,
    _offset: fpos_t,
};
pub const FILE = struct___sFILE;
pub extern var __stdinp: [*c]FILE;
pub extern var __stdoutp: [*c]FILE;
pub extern var __stderrp: [*c]FILE;
pub extern fn clearerr([*c]FILE) void;
pub extern fn fclose([*c]FILE) c_int;
pub extern fn feof([*c]FILE) c_int;
pub extern fn ferror([*c]FILE) c_int;
pub extern fn fflush([*c]FILE) c_int;
pub extern fn fgetc([*c]FILE) c_int;
pub extern fn fgetpos(noalias [*c]FILE, [*c]fpos_t) c_int;
pub extern fn fgets(noalias [*c]u8, c_int, [*c]FILE) [*c]u8;
pub extern fn fopen(__filename: [*c]const u8, __mode: [*c]const u8) [*c]FILE;
pub extern fn fprintf([*c]FILE, [*c]const u8, ...) c_int;
pub extern fn fputc(c_int, [*c]FILE) c_int;
pub extern fn fputs(noalias [*c]const u8, noalias [*c]FILE) c_int;
pub extern fn fread(__ptr: ?*anyopaque, __size: c_ulong, __nitems: c_ulong, __stream: [*c]FILE) c_ulong;
pub extern fn freopen(noalias [*c]const u8, noalias [*c]const u8, noalias [*c]FILE) [*c]FILE;
pub extern fn fscanf(noalias [*c]FILE, noalias [*c]const u8, ...) c_int;
pub extern fn fseek([*c]FILE, c_long, c_int) c_int;
pub extern fn fsetpos([*c]FILE, [*c]const fpos_t) c_int;
pub extern fn ftell([*c]FILE) c_long;
pub extern fn fwrite(__ptr: ?*const anyopaque, __size: c_ulong, __nitems: c_ulong, __stream: [*c]FILE) c_ulong;
pub extern fn getc([*c]FILE) c_int;
pub extern fn getchar() c_int;
pub extern fn gets([*c]u8) [*c]u8;
pub extern fn perror([*c]const u8) void;
pub extern fn printf([*c]const u8, ...) c_int;
pub extern fn putc(c_int, [*c]FILE) c_int;
pub extern fn putchar(c_int) c_int;
pub extern fn puts([*c]const u8) c_int;
pub extern fn remove([*c]const u8) c_int;
pub extern fn rename(__old: [*c]const u8, __new: [*c]const u8) c_int;
pub extern fn rewind([*c]FILE) void;
pub extern fn scanf(noalias [*c]const u8, ...) c_int;
pub extern fn setbuf(noalias [*c]FILE, noalias [*c]u8) void;
pub extern fn setvbuf(noalias [*c]FILE, noalias [*c]u8, c_int, usize) c_int;
pub extern fn sprintf([*c]u8, [*c]const u8, ...) c_int;
pub extern fn sscanf(noalias [*c]const u8, noalias [*c]const u8, ...) c_int;
pub extern fn tmpfile() [*c]FILE;
pub extern fn tmpnam([*c]u8) [*c]u8;
pub extern fn ungetc(c_int, [*c]FILE) c_int;
pub extern fn vfprintf([*c]FILE, [*c]const u8, __builtin_va_list) c_int;
pub extern fn vprintf([*c]const u8, __builtin_va_list) c_int;
pub extern fn vsprintf([*c]u8, [*c]const u8, __builtin_va_list) c_int;
pub extern fn ctermid([*c]u8) [*c]u8;
pub extern fn fdopen(c_int, [*c]const u8) [*c]FILE;
pub extern fn fileno([*c]FILE) c_int;
pub extern fn pclose([*c]FILE) c_int;
pub extern fn popen([*c]const u8, [*c]const u8) [*c]FILE;
pub extern fn __srget([*c]FILE) c_int;
pub extern fn __svfscanf([*c]FILE, [*c]const u8, va_list) c_int;
pub extern fn __swbuf(c_int, [*c]FILE) c_int;
pub inline fn __sputc(arg__c: c_int, arg__p: [*c]FILE) c_int {
    var _c = arg__c;
    var _p = arg__p;
    if (((blk: {
        const ref = &_p.*._w;
        ref.* -= 1;
        break :blk ref.*;
    }) >= @as(c_int, 0)) or ((_p.*._w >= _p.*._lbfsize) and (@as(c_int, @bitCast(@as(c_uint, @as(u8, @bitCast(@as(i8, @truncate(_c))))))) != @as(c_int, '\n')))) return @as(c_int, @bitCast(@as(c_uint, blk: {
        const tmp = @as(u8, @bitCast(@as(i8, @truncate(_c))));
        (blk_1: {
            const ref = &_p.*._p;
            const tmp_2 = ref.*;
            ref.* += 1;
            break :blk_1 tmp_2;
        }).* = tmp;
        break :blk tmp;
    }))) else return __swbuf(_c, _p);
    return 0;
}
pub extern fn flockfile([*c]FILE) void;
pub extern fn ftrylockfile([*c]FILE) c_int;
pub extern fn funlockfile([*c]FILE) void;
pub extern fn getc_unlocked([*c]FILE) c_int;
pub extern fn getchar_unlocked() c_int;
pub extern fn putc_unlocked(c_int, [*c]FILE) c_int;
pub extern fn putchar_unlocked(c_int) c_int;
pub extern fn getw([*c]FILE) c_int;
pub extern fn putw(c_int, [*c]FILE) c_int;
pub extern fn tempnam(__dir: [*c]const u8, __prefix: [*c]const u8) [*c]u8;
pub const off_t = __darwin_off_t;
pub extern fn fseeko(__stream: [*c]FILE, __offset: off_t, __whence: c_int) c_int;
pub extern fn ftello(__stream: [*c]FILE) off_t;
pub extern fn snprintf(__str: [*c]u8, __size: c_ulong, __format: [*c]const u8, ...) c_int;
pub extern fn vfscanf(noalias __stream: [*c]FILE, noalias __format: [*c]const u8, __builtin_va_list) c_int;
pub extern fn vscanf(noalias __format: [*c]const u8, __builtin_va_list) c_int;
pub extern fn vsnprintf(__str: [*c]u8, __size: c_ulong, __format: [*c]const u8, __builtin_va_list) c_int;
pub extern fn vsscanf(noalias __str: [*c]const u8, noalias __format: [*c]const u8, __builtin_va_list) c_int;
pub extern fn dprintf(c_int, noalias [*c]const u8, ...) c_int;
pub extern fn vdprintf(c_int, noalias [*c]const u8, va_list) c_int;
pub extern fn getdelim(noalias __linep: [*c][*c]u8, noalias __linecapp: [*c]usize, __delimiter: c_int, noalias __stream: [*c]FILE) isize;
pub extern fn getline(noalias __linep: [*c][*c]u8, noalias __linecapp: [*c]usize, noalias __stream: [*c]FILE) isize;
pub extern fn fmemopen(noalias __buf: ?*anyopaque, __size: usize, noalias __mode: [*c]const u8) [*c]FILE;
pub extern fn open_memstream(__bufp: [*c][*c]u8, __sizep: [*c]usize) [*c]FILE;
pub extern const sys_nerr: c_int;
pub const sys_errlist: [*c]const [*c]const u8 = @extern([*c]const [*c]const u8, .{
    .name = "sys_errlist",
});
pub extern fn asprintf(noalias [*c][*c]u8, noalias [*c]const u8, ...) c_int;
pub extern fn ctermid_r([*c]u8) [*c]u8;
pub extern fn fgetln([*c]FILE, [*c]usize) [*c]u8;
pub extern fn fmtcheck([*c]const u8, [*c]const u8) [*c]const u8;
pub extern fn fpurge([*c]FILE) c_int;
pub extern fn setbuffer([*c]FILE, [*c]u8, c_int) void;
pub extern fn setlinebuf([*c]FILE) c_int;
pub extern fn vasprintf(noalias [*c][*c]u8, noalias [*c]const u8, va_list) c_int;
pub extern fn funopen(?*const anyopaque, ?*const fn (?*anyopaque, [*c]u8, c_int) callconv(.C) c_int, ?*const fn (?*anyopaque, [*c]const u8, c_int) callconv(.C) c_int, ?*const fn (?*anyopaque, fpos_t, c_int) callconv(.C) fpos_t, ?*const fn (?*anyopaque) callconv(.C) c_int) [*c]FILE;
pub extern fn __sprintf_chk(noalias [*c]u8, c_int, usize, noalias [*c]const u8, ...) c_int;
pub extern fn __snprintf_chk(noalias [*c]u8, usize, c_int, usize, noalias [*c]const u8, ...) c_int;
pub extern fn __vsprintf_chk(noalias [*c]u8, c_int, usize, noalias [*c]const u8, va_list) c_int;
pub extern fn __vsnprintf_chk(noalias [*c]u8, usize, c_int, usize, noalias [*c]const u8, va_list) c_int;
pub const int_least8_t = i8;
pub const int_least16_t = i16;
pub const int_least32_t = i32;
pub const int_least64_t = i64;
pub const uint_least8_t = u8;
pub const uint_least16_t = u16;
pub const uint_least32_t = u32;
pub const uint_least64_t = u64;
pub const int_fast8_t = i8;
pub const int_fast16_t = i16;
pub const int_fast32_t = i32;
pub const int_fast64_t = i64;
pub const uint_fast8_t = u8;
pub const uint_fast16_t = u16;
pub const uint_fast32_t = u32;
pub const uint_fast64_t = u64;
pub const intmax_t = c_long;
pub const uintmax_t = c_ulong;
pub const __gnuc_va_list = __builtin_va_list;
pub const struct_ImVec4 = extern struct {
    x: f32,
    y: f32,
    z: f32,
    w: f32,
};
pub const ImVec4 = struct_ImVec4;
pub const ImTextureID = ?*anyopaque;
pub const ImDrawIdx = c_ushort;
pub const struct_ImVector_ImDrawIdx = extern struct {
    Size: c_int,
    Capacity: c_int,
    Data: [*c]ImDrawIdx,
};
pub const ImVector_ImDrawIdx = struct_ImVector_ImDrawIdx;
pub const struct_ImVec2 = extern struct {
    x: f32,
    y: f32,
};
pub const ImVec2 = struct_ImVec2;
pub const ImU32 = c_uint;
pub const struct_ImDrawVert = extern struct {
    pos: ImVec2,
    uv: ImVec2,
    col: ImU32,
};
pub const ImDrawVert = struct_ImDrawVert;
pub const struct_ImVector_ImDrawVert = extern struct {
    Size: c_int,
    Capacity: c_int,
    Data: [*c]ImDrawVert,
};
pub const ImVector_ImDrawVert = struct_ImVector_ImDrawVert;
pub const ImDrawListFlags = c_int;
pub const struct_ImVector_float = extern struct {
    Size: c_int,
    Capacity: c_int,
    Data: [*c]f32,
};
pub const ImVector_float = struct_ImVector_float;
pub const ImWchar16 = c_ushort;
pub const ImWchar = ImWchar16;
pub const struct_ImVector_ImWchar = extern struct {
    Size: c_int,
    Capacity: c_int,
    Data: [*c]ImWchar,
};
pub const ImVector_ImWchar = struct_ImVector_ImWchar; // cimgui.h:1265:18: warning: struct demoted to opaque type - has bitfield
pub const struct_ImFontGlyph = opaque {};
pub const ImFontGlyph = struct_ImFontGlyph;
pub const struct_ImVector_ImFontGlyph = extern struct {
    Size: c_int,
    Capacity: c_int,
    Data: ?*ImFontGlyph,
};
pub const ImVector_ImFontGlyph = struct_ImVector_ImFontGlyph;
pub const ImFontAtlasFlags = c_int;
pub const struct_ImVector_ImFontPtr = extern struct {
    Size: c_int,
    Capacity: c_int,
    Data: [*c][*c]ImFont,
};
pub const ImVector_ImFontPtr = struct_ImVector_ImFontPtr;
pub const struct_ImFontAtlasCustomRect = extern struct {
    Width: c_ushort,
    Height: c_ushort,
    X: c_ushort,
    Y: c_ushort,
    GlyphID: c_uint,
    GlyphAdvanceX: f32,
    GlyphOffset: ImVec2,
    Font: [*c]ImFont,
};
pub const ImFontAtlasCustomRect = struct_ImFontAtlasCustomRect;
pub const struct_ImVector_ImFontAtlasCustomRect = extern struct {
    Size: c_int,
    Capacity: c_int,
    Data: [*c]ImFontAtlasCustomRect,
};
pub const ImVector_ImFontAtlasCustomRect = struct_ImVector_ImFontAtlasCustomRect;
pub const struct_ImFontConfig = extern struct {
    FontData: ?*anyopaque,
    FontDataSize: c_int,
    FontDataOwnedByAtlas: bool,
    FontNo: c_int,
    SizePixels: f32,
    OversampleH: c_int,
    OversampleV: c_int,
    PixelSnapH: bool,
    GlyphExtraSpacing: ImVec2,
    GlyphOffset: ImVec2,
    GlyphRanges: [*c]const ImWchar,
    GlyphMinAdvanceX: f32,
    GlyphMaxAdvanceX: f32,
    MergeMode: bool,
    FontBuilderFlags: c_uint,
    RasterizerMultiply: f32,
    EllipsisChar: ImWchar,
    Name: [40]u8,
    DstFont: [*c]ImFont,
};
pub const ImFontConfig = struct_ImFontConfig;
pub const struct_ImVector_ImFontConfig = extern struct {
    Size: c_int,
    Capacity: c_int,
    Data: [*c]ImFontConfig,
};
pub const ImVector_ImFontConfig = struct_ImVector_ImFontConfig;
pub const struct_ImFontBuilderIO = extern struct {
    FontBuilder_Build: ?*const fn ([*c]ImFontAtlas) callconv(.C) bool,
};
pub const ImFontBuilderIO = struct_ImFontBuilderIO;
pub const struct_ImFontAtlas = extern struct {
    Flags: ImFontAtlasFlags,
    TexID: ImTextureID,
    TexDesiredWidth: c_int,
    TexGlyphPadding: c_int,
    Locked: bool,
    UserData: ?*anyopaque,
    TexReady: bool,
    TexPixelsUseColors: bool,
    TexPixelsAlpha8: [*c]u8,
    TexPixelsRGBA32: [*c]c_uint,
    TexWidth: c_int,
    TexHeight: c_int,
    TexUvScale: ImVec2,
    TexUvWhitePixel: ImVec2,
    Fonts: ImVector_ImFontPtr,
    CustomRects: ImVector_ImFontAtlasCustomRect,
    ConfigData: ImVector_ImFontConfig,
    TexUvLines: [64]ImVec4,
    FontBuilderIO: [*c]const ImFontBuilderIO,
    FontBuilderFlags: c_uint,
    PackIdMouseCursors: c_int,
    PackIdLines: c_int,
};
pub const ImFontAtlas = struct_ImFontAtlas;
pub const ImU8 = u8;
pub const struct_ImFont = extern struct {
    IndexAdvanceX: ImVector_float,
    FallbackAdvanceX: f32,
    FontSize: f32,
    IndexLookup: ImVector_ImWchar,
    Glyphs: ImVector_ImFontGlyph,
    FallbackGlyph: ?*const ImFontGlyph,
    ContainerAtlas: [*c]ImFontAtlas,
    ConfigData: [*c]const ImFontConfig,
    ConfigDataCount: c_short,
    FallbackChar: ImWchar,
    EllipsisChar: ImWchar,
    EllipsisCharCount: c_short,
    EllipsisWidth: f32,
    EllipsisCharStep: f32,
    DirtyLookupTables: bool,
    Scale: f32,
    Ascent: f32,
    Descent: f32,
    MetricsTotalSurface: c_int,
    Used4kPagesMap: [2]ImU8,
};
pub const ImFont = struct_ImFont;
pub const struct_ImVector_ImVec2 = extern struct {
    Size: c_int,
    Capacity: c_int,
    Data: [*c]ImVec2,
};
pub const ImVector_ImVec2 = struct_ImVector_ImVec2;
pub const struct_ImDrawListSharedData = extern struct {
    TexUvWhitePixel: ImVec2,
    Font: [*c]ImFont,
    FontSize: f32,
    CurveTessellationTol: f32,
    CircleSegmentMaxError: f32,
    ClipRectFullscreen: ImVec4,
    InitialFlags: ImDrawListFlags,
    TempBuffer: ImVector_ImVec2,
    ArcFastVtx: [48]ImVec2,
    ArcFastRadiusCutoff: f32,
    CircleSegmentCounts: [64]ImU8,
    TexUvLines: [*c]const ImVec4,
};
pub const ImDrawListSharedData = struct_ImDrawListSharedData;
pub const struct_ImVector_ImVec4 = extern struct {
    Size: c_int,
    Capacity: c_int,
    Data: [*c]ImVec4,
};
pub const ImVector_ImVec4 = struct_ImVector_ImVec4;
pub const struct_ImVector_ImTextureID = extern struct {
    Size: c_int,
    Capacity: c_int,
    Data: [*c]ImTextureID,
};
pub const ImVector_ImTextureID = struct_ImVector_ImTextureID;
pub const struct_ImDrawCmdHeader = extern struct {
    ClipRect: ImVec4,
    TextureId: ImTextureID,
    VtxOffset: c_uint,
};
pub const ImDrawCmdHeader = struct_ImDrawCmdHeader;
pub const ImDrawChannel = struct_ImDrawChannel;
pub const struct_ImVector_ImDrawChannel = extern struct {
    Size: c_int,
    Capacity: c_int,
    Data: [*c]ImDrawChannel,
};
pub const ImVector_ImDrawChannel = struct_ImVector_ImDrawChannel;
pub const struct_ImDrawListSplitter = extern struct {
    _Current: c_int,
    _Count: c_int,
    _Channels: ImVector_ImDrawChannel,
};
pub const ImDrawListSplitter = struct_ImDrawListSplitter;
pub const struct_ImDrawList = extern struct {
    CmdBuffer: ImVector_ImDrawCmd,
    IdxBuffer: ImVector_ImDrawIdx,
    VtxBuffer: ImVector_ImDrawVert,
    Flags: ImDrawListFlags,
    _VtxCurrentIdx: c_uint,
    _Data: [*c]ImDrawListSharedData,
    _OwnerName: [*c]const u8,
    _VtxWritePtr: [*c]ImDrawVert,
    _IdxWritePtr: [*c]ImDrawIdx,
    _ClipRectStack: ImVector_ImVec4,
    _TextureIdStack: ImVector_ImTextureID,
    _Path: ImVector_ImVec2,
    _CmdHeader: ImDrawCmdHeader,
    _Splitter: ImDrawListSplitter,
    _FringeScale: f32,
};
pub const ImDrawList = struct_ImDrawList;
pub const ImDrawCallback = ?*const fn ([*c]const ImDrawList, [*c]const ImDrawCmd) callconv(.C) void;
pub const struct_ImDrawCmd = extern struct {
    ClipRect: ImVec4,
    TextureId: ImTextureID,
    VtxOffset: c_uint,
    IdxOffset: c_uint,
    ElemCount: c_uint,
    UserCallback: ImDrawCallback,
    UserCallbackData: ?*anyopaque,
};
pub const ImDrawCmd = struct_ImDrawCmd;
pub const struct_ImVector_ImDrawCmd = extern struct {
    Size: c_int,
    Capacity: c_int,
    Data: [*c]ImDrawCmd,
};
pub const ImVector_ImDrawCmd = struct_ImVector_ImDrawCmd;
pub const struct_ImDrawChannel = extern struct {
    _CmdBuffer: ImVector_ImDrawCmd,
    _IdxBuffer: ImVector_ImDrawIdx,
};
pub const struct_ImVector_ImDrawListPtr = extern struct {
    Size: c_int,
    Capacity: c_int,
    Data: [*c][*c]ImDrawList,
};
pub const ImVector_ImDrawListPtr = struct_ImVector_ImDrawListPtr;
pub const ImGuiID = c_uint;
pub const ImGuiViewportFlags = c_int;
pub const ImDrawData = struct_ImDrawData;
pub const struct_ImGuiViewport = extern struct {
    ID: ImGuiID,
    Flags: ImGuiViewportFlags,
    Pos: ImVec2,
    Size: ImVec2,
    WorkPos: ImVec2,
    WorkSize: ImVec2,
    DpiScale: f32,
    ParentViewportId: ImGuiID,
    DrawData: [*c]ImDrawData,
    RendererUserData: ?*anyopaque,
    PlatformUserData: ?*anyopaque,
    PlatformHandle: ?*anyopaque,
    PlatformHandleRaw: ?*anyopaque,
    PlatformWindowCreated: bool,
    PlatformRequestMove: bool,
    PlatformRequestResize: bool,
    PlatformRequestClose: bool,
};
pub const ImGuiViewport = struct_ImGuiViewport;
pub const struct_ImDrawData = extern struct {
    Valid: bool,
    CmdListsCount: c_int,
    TotalIdxCount: c_int,
    TotalVtxCount: c_int,
    CmdLists: ImVector_ImDrawListPtr,
    DisplayPos: ImVec2,
    DisplaySize: ImVec2,
    FramebufferScale: ImVec2,
    OwnerViewport: [*c]ImGuiViewport,
};
pub const struct_ImVector_ImU32 = extern struct {
    Size: c_int,
    Capacity: c_int,
    Data: [*c]ImU32,
};
pub const ImVector_ImU32 = struct_ImVector_ImU32;
pub const struct_ImFontGlyphRangesBuilder = extern struct {
    UsedChars: ImVector_ImU32,
};
pub const ImFontGlyphRangesBuilder = struct_ImFontGlyphRangesBuilder;
pub const struct_ImColor = extern struct {
    Value: ImVec4,
};
pub const ImColor = struct_ImColor;
pub const ImGuiConfigFlags = c_int;
pub const ImGuiBackendFlags = c_int;
pub const struct_ImGuiPlatformImeData = extern struct {
    WantVisible: bool,
    InputPos: ImVec2,
    InputLineHeight: f32,
};
pub const ImGuiPlatformImeData = struct_ImGuiPlatformImeData;
pub const ImGuiContext = struct_ImGuiContext;
pub const ImGuiKeyChord = c_int;
pub const struct_ImGuiKeyData = extern struct {
    Down: bool,
    DownDuration: f32,
    DownDurationPrev: f32,
    AnalogValue: f32,
};
pub const ImGuiKeyData = struct_ImGuiKeyData;
pub const ImU16 = c_ushort;
pub const ImS8 = i8;
pub const struct_ImGuiIO = extern struct {
    ConfigFlags: ImGuiConfigFlags,
    BackendFlags: ImGuiBackendFlags,
    DisplaySize: ImVec2,
    DeltaTime: f32,
    IniSavingRate: f32,
    IniFilename: [*c]const u8,
    LogFilename: [*c]const u8,
    UserData: ?*anyopaque,
    Fonts: [*c]ImFontAtlas,
    FontGlobalScale: f32,
    FontAllowUserScaling: bool,
    FontDefault: [*c]ImFont,
    DisplayFramebufferScale: ImVec2,
    ConfigDockingNoSplit: bool,
    ConfigDockingWithShift: bool,
    ConfigDockingAlwaysTabBar: bool,
    ConfigDockingTransparentPayload: bool,
    ConfigViewportsNoAutoMerge: bool,
    ConfigViewportsNoTaskBarIcon: bool,
    ConfigViewportsNoDecoration: bool,
    ConfigViewportsNoDefaultParent: bool,
    MouseDrawCursor: bool,
    ConfigMacOSXBehaviors: bool,
    ConfigInputTrickleEventQueue: bool,
    ConfigInputTextCursorBlink: bool,
    ConfigInputTextEnterKeepActive: bool,
    ConfigDragClickToInputText: bool,
    ConfigWindowsResizeFromEdges: bool,
    ConfigWindowsMoveFromTitleBarOnly: bool,
    ConfigMemoryCompactTimer: f32,
    MouseDoubleClickTime: f32,
    MouseDoubleClickMaxDist: f32,
    MouseDragThreshold: f32,
    KeyRepeatDelay: f32,
    KeyRepeatRate: f32,
    ConfigDebugBeginReturnValueOnce: bool,
    ConfigDebugBeginReturnValueLoop: bool,
    ConfigDebugIgnoreFocusLoss: bool,
    ConfigDebugIniSettings: bool,
    BackendPlatformName: [*c]const u8,
    BackendRendererName: [*c]const u8,
    BackendPlatformUserData: ?*anyopaque,
    BackendRendererUserData: ?*anyopaque,
    BackendLanguageUserData: ?*anyopaque,
    GetClipboardTextFn: ?*const fn (?*anyopaque) callconv(.C) [*c]const u8,
    SetClipboardTextFn: ?*const fn (?*anyopaque, [*c]const u8) callconv(.C) void,
    ClipboardUserData: ?*anyopaque,
    SetPlatformImeDataFn: ?*const fn ([*c]ImGuiViewport, [*c]ImGuiPlatformImeData) callconv(.C) void,
    _UnusedPadding: ?*anyopaque,
    PlatformLocaleDecimalPoint: ImWchar,
    WantCaptureMouse: bool,
    WantCaptureKeyboard: bool,
    WantTextInput: bool,
    WantSetMousePos: bool,
    WantSaveIniSettings: bool,
    NavActive: bool,
    NavVisible: bool,
    Framerate: f32,
    MetricsRenderVertices: c_int,
    MetricsRenderIndices: c_int,
    MetricsRenderWindows: c_int,
    MetricsActiveWindows: c_int,
    MetricsActiveAllocations: c_int,
    MouseDelta: ImVec2,
    KeyMap: [652]c_int,
    KeysDown: [652]bool,
    NavInputs: [16]f32,
    Ctx: [*c]ImGuiContext,
    MousePos: ImVec2,
    MouseDown: [5]bool,
    MouseWheel: f32,
    MouseWheelH: f32,
    MouseSource: ImGuiMouseSource,
    MouseHoveredViewport: ImGuiID,
    KeyCtrl: bool,
    KeyShift: bool,
    KeyAlt: bool,
    KeySuper: bool,
    KeyMods: ImGuiKeyChord,
    KeysData: [652]ImGuiKeyData,
    WantCaptureMouseUnlessPopupClose: bool,
    MousePosPrev: ImVec2,
    MouseClickedPos: [5]ImVec2,
    MouseClickedTime: [5]f64,
    MouseClicked: [5]bool,
    MouseDoubleClicked: [5]bool,
    MouseClickedCount: [5]ImU16,
    MouseClickedLastCount: [5]ImU16,
    MouseReleased: [5]bool,
    MouseDownOwned: [5]bool,
    MouseDownOwnedUnlessPopupClose: [5]bool,
    MouseWheelRequestAxisSwap: bool,
    MouseDownDuration: [5]f32,
    MouseDownDurationPrev: [5]f32,
    MouseDragMaxDistanceAbs: [5]ImVec2,
    MouseDragMaxDistanceSqr: [5]f32,
    PenPressure: f32,
    AppFocusLost: bool,
    AppAcceptingEvents: bool,
    BackendUsingLegacyKeyArrays: ImS8,
    BackendUsingLegacyNavInputArray: bool,
    InputQueueSurrogate: ImWchar16,
    InputQueueCharacters: ImVector_ImWchar,
};
pub const ImGuiIO = struct_ImGuiIO;
pub const ImU64 = c_ulonglong;
pub const struct_ImGuiPlatformMonitor = extern struct {
    MainPos: ImVec2,
    MainSize: ImVec2,
    WorkPos: ImVec2,
    WorkSize: ImVec2,
    DpiScale: f32,
    PlatformHandle: ?*anyopaque,
};
pub const ImGuiPlatformMonitor = struct_ImGuiPlatformMonitor;
pub const struct_ImVector_ImGuiPlatformMonitor = extern struct {
    Size: c_int,
    Capacity: c_int,
    Data: [*c]ImGuiPlatformMonitor,
};
pub const ImVector_ImGuiPlatformMonitor = struct_ImVector_ImGuiPlatformMonitor;
pub const struct_ImVector_ImGuiViewportPtr = extern struct {
    Size: c_int,
    Capacity: c_int,
    Data: [*c][*c]ImGuiViewport,
};
pub const ImVector_ImGuiViewportPtr = struct_ImVector_ImGuiViewportPtr;
pub const struct_ImGuiPlatformIO = extern struct {
    Platform_CreateWindow: ?*const fn ([*c]ImGuiViewport) callconv(.C) void,
    Platform_DestroyWindow: ?*const fn ([*c]ImGuiViewport) callconv(.C) void,
    Platform_ShowWindow: ?*const fn ([*c]ImGuiViewport) callconv(.C) void,
    Platform_SetWindowPos: ?*const fn ([*c]ImGuiViewport, ImVec2) callconv(.C) void,
    Platform_GetWindowPos: ?*const fn ([*c]ImGuiViewport) callconv(.C) ImVec2,
    Platform_SetWindowSize: ?*const fn ([*c]ImGuiViewport, ImVec2) callconv(.C) void,
    Platform_GetWindowSize: ?*const fn ([*c]ImGuiViewport) callconv(.C) ImVec2,
    Platform_SetWindowFocus: ?*const fn ([*c]ImGuiViewport) callconv(.C) void,
    Platform_GetWindowFocus: ?*const fn ([*c]ImGuiViewport) callconv(.C) bool,
    Platform_GetWindowMinimized: ?*const fn ([*c]ImGuiViewport) callconv(.C) bool,
    Platform_SetWindowTitle: ?*const fn ([*c]ImGuiViewport, [*c]const u8) callconv(.C) void,
    Platform_SetWindowAlpha: ?*const fn ([*c]ImGuiViewport, f32) callconv(.C) void,
    Platform_UpdateWindow: ?*const fn ([*c]ImGuiViewport) callconv(.C) void,
    Platform_RenderWindow: ?*const fn ([*c]ImGuiViewport, ?*anyopaque) callconv(.C) void,
    Platform_SwapBuffers: ?*const fn ([*c]ImGuiViewport, ?*anyopaque) callconv(.C) void,
    Platform_GetWindowDpiScale: ?*const fn ([*c]ImGuiViewport) callconv(.C) f32,
    Platform_OnChangedViewport: ?*const fn ([*c]ImGuiViewport) callconv(.C) void,
    Platform_CreateVkSurface: ?*const fn ([*c]ImGuiViewport, ImU64, ?*const anyopaque, [*c]ImU64) callconv(.C) c_int,
    Renderer_CreateWindow: ?*const fn ([*c]ImGuiViewport) callconv(.C) void,
    Renderer_DestroyWindow: ?*const fn ([*c]ImGuiViewport) callconv(.C) void,
    Renderer_SetWindowSize: ?*const fn ([*c]ImGuiViewport, ImVec2) callconv(.C) void,
    Renderer_RenderWindow: ?*const fn ([*c]ImGuiViewport, ?*anyopaque) callconv(.C) void,
    Renderer_SwapBuffers: ?*const fn ([*c]ImGuiViewport, ?*anyopaque) callconv(.C) void,
    Monitors: ImVector_ImGuiPlatformMonitor,
    Viewports: ImVector_ImGuiViewportPtr,
};
pub const ImGuiPlatformIO = struct_ImGuiPlatformIO;
pub const ImGuiDir = c_int;
pub const ImGuiHoveredFlags = c_int;
pub const struct_ImGuiStyle = extern struct {
    Alpha: f32,
    DisabledAlpha: f32,
    WindowPadding: ImVec2,
    WindowRounding: f32,
    WindowBorderSize: f32,
    WindowMinSize: ImVec2,
    WindowTitleAlign: ImVec2,
    WindowMenuButtonPosition: ImGuiDir,
    ChildRounding: f32,
    ChildBorderSize: f32,
    PopupRounding: f32,
    PopupBorderSize: f32,
    FramePadding: ImVec2,
    FrameRounding: f32,
    FrameBorderSize: f32,
    ItemSpacing: ImVec2,
    ItemInnerSpacing: ImVec2,
    CellPadding: ImVec2,
    TouchExtraPadding: ImVec2,
    IndentSpacing: f32,
    ColumnsMinSpacing: f32,
    ScrollbarSize: f32,
    ScrollbarRounding: f32,
    GrabMinSize: f32,
    GrabRounding: f32,
    LogSliderDeadzone: f32,
    TabRounding: f32,
    TabBorderSize: f32,
    TabMinWidthForCloseButton: f32,
    ColorButtonPosition: ImGuiDir,
    ButtonTextAlign: ImVec2,
    SelectableTextAlign: ImVec2,
    SeparatorTextBorderSize: f32,
    SeparatorTextAlign: ImVec2,
    SeparatorTextPadding: ImVec2,
    DisplayWindowPadding: ImVec2,
    DisplaySafeAreaPadding: ImVec2,
    DockingSeparatorSize: f32,
    MouseCursorScale: f32,
    AntiAliasedLines: bool,
    AntiAliasedLinesUseTex: bool,
    AntiAliasedFill: bool,
    CurveTessellationTol: f32,
    CircleTessellationMaxError: f32,
    Colors: [55]ImVec4,
    HoverStationaryDelay: f32,
    HoverDelayShort: f32,
    HoverDelayNormal: f32,
    HoverFlagsForTooltipMouse: ImGuiHoveredFlags,
    HoverFlagsForTooltipNav: ImGuiHoveredFlags,
};
pub const ImGuiStyle = struct_ImGuiStyle;
pub const struct_ImGuiInputEventMousePos = extern struct {
    PosX: f32,
    PosY: f32,
    MouseSource: ImGuiMouseSource,
};
pub const ImGuiInputEventMousePos = struct_ImGuiInputEventMousePos;
pub const struct_ImGuiInputEventMouseWheel = extern struct {
    WheelX: f32,
    WheelY: f32,
    MouseSource: ImGuiMouseSource,
};
pub const ImGuiInputEventMouseWheel = struct_ImGuiInputEventMouseWheel;
pub const struct_ImGuiInputEventMouseButton = extern struct {
    Button: c_int,
    Down: bool,
    MouseSource: ImGuiMouseSource,
};
pub const ImGuiInputEventMouseButton = struct_ImGuiInputEventMouseButton;
pub const struct_ImGuiInputEventMouseViewport = extern struct {
    HoveredViewportID: ImGuiID,
};
pub const ImGuiInputEventMouseViewport = struct_ImGuiInputEventMouseViewport;
pub const struct_ImGuiInputEventKey = extern struct {
    Key: ImGuiKey,
    Down: bool,
    AnalogValue: f32,
};
pub const ImGuiInputEventKey = struct_ImGuiInputEventKey;
pub const struct_ImGuiInputEventText = extern struct {
    Char: c_uint,
};
pub const ImGuiInputEventText = struct_ImGuiInputEventText;
pub const struct_ImGuiInputEventAppFocused = extern struct {
    Focused: bool,
};
pub const ImGuiInputEventAppFocused = struct_ImGuiInputEventAppFocused;
const union_unnamed_1 = extern union {
    MousePos: ImGuiInputEventMousePos,
    MouseWheel: ImGuiInputEventMouseWheel,
    MouseButton: ImGuiInputEventMouseButton,
    MouseViewport: ImGuiInputEventMouseViewport,
    Key: ImGuiInputEventKey,
    Text: ImGuiInputEventText,
    AppFocused: ImGuiInputEventAppFocused,
};
pub const struct_ImGuiInputEvent = extern struct {
    Type: ImGuiInputEventType,
    Source: ImGuiInputSource,
    EventId: ImU32,
    unnamed_0: union_unnamed_1,
    AddedByTestEngine: bool,
};
pub const ImGuiInputEvent = struct_ImGuiInputEvent;
pub const struct_ImVector_ImGuiInputEvent = extern struct {
    Size: c_int,
    Capacity: c_int,
    Data: [*c]ImGuiInputEvent,
};
pub const ImVector_ImGuiInputEvent = struct_ImVector_ImGuiInputEvent;
pub const ImGuiWindowFlags = c_int;
pub const ImGuiTabItemFlags = c_int;
pub const ImGuiDockNodeFlags = c_int;
pub const struct_ImGuiWindowClass = extern struct {
    ClassId: ImGuiID,
    ParentViewportId: ImGuiID,
    ViewportFlagsOverrideSet: ImGuiViewportFlags,
    ViewportFlagsOverrideClear: ImGuiViewportFlags,
    TabItemFlagsOverrideSet: ImGuiTabItemFlags,
    DockNodeFlagsOverrideSet: ImGuiDockNodeFlags,
    DockingAlwaysTabBar: bool,
    DockingAllowUnclassed: bool,
};
pub const ImGuiWindowClass = struct_ImGuiWindowClass;
pub const struct_ImDrawDataBuilder = extern struct {
    Layers: [2][*c]ImVector_ImDrawListPtr,
    LayerData1: ImVector_ImDrawListPtr,
};
pub const ImDrawDataBuilder = struct_ImDrawDataBuilder;
pub const struct_ImGuiViewportP = extern struct {
    _ImGuiViewport: ImGuiViewport,
    Window: ?*ImGuiWindow,
    Idx: c_int,
    LastFrameActive: c_int,
    LastFocusedStampCount: c_int,
    LastNameHash: ImGuiID,
    LastPos: ImVec2,
    Alpha: f32,
    LastAlpha: f32,
    LastFocusedHadNavWindow: bool,
    PlatformMonitor: c_short,
    BgFgDrawListsLastFrame: [2]c_int,
    BgFgDrawLists: [2][*c]ImDrawList,
    DrawDataP: ImDrawData,
    DrawDataBuilder: ImDrawDataBuilder,
    LastPlatformPos: ImVec2,
    LastPlatformSize: ImVec2,
    LastRendererSize: ImVec2,
    WorkOffsetMin: ImVec2,
    WorkOffsetMax: ImVec2,
    BuildWorkOffsetMin: ImVec2,
    BuildWorkOffsetMax: ImVec2,
};
pub const ImGuiViewportP = struct_ImGuiViewportP; // cimgui.h:2786:15: warning: struct demoted to opaque type - has bitfield
pub const struct_ImGuiWindow = opaque {};
pub const ImGuiWindow = struct_ImGuiWindow;
pub const struct_ImVector_ImGuiWindowPtr = extern struct {
    Size: c_int,
    Capacity: c_int,
    Data: [*c]?*ImGuiWindow,
};
pub const ImVector_ImGuiWindowPtr = struct_ImVector_ImGuiWindowPtr;
pub const ImGuiItemFlags = c_int;
pub const ImGuiItemStatusFlags = c_int;
pub const struct_ImRect = extern struct {
    Min: ImVec2,
    Max: ImVec2,
};
pub const ImRect = struct_ImRect;
pub const struct_ImGuiLastItemData = extern struct {
    ID: ImGuiID,
    InFlags: ImGuiItemFlags,
    StatusFlags: ImGuiItemStatusFlags,
    Rect: ImRect,
    NavRect: ImRect,
    DisplayRect: ImRect,
};
pub const ImGuiLastItemData = struct_ImGuiLastItemData;
pub const struct_ImGuiStackSizes = extern struct {
    SizeOfIDStack: c_short,
    SizeOfColorStack: c_short,
    SizeOfStyleVarStack: c_short,
    SizeOfFontStack: c_short,
    SizeOfFocusScopeStack: c_short,
    SizeOfGroupStack: c_short,
    SizeOfItemFlagsStack: c_short,
    SizeOfBeginPopupStack: c_short,
    SizeOfDisabledStack: c_short,
};
pub const ImGuiStackSizes = struct_ImGuiStackSizes;
pub const struct_ImGuiWindowStackData = extern struct {
    Window: ?*ImGuiWindow,
    ParentLastItemDataBackup: ImGuiLastItemData,
    StackSizesOnBegin: ImGuiStackSizes,
};
pub const ImGuiWindowStackData = struct_ImGuiWindowStackData;
pub const struct_ImVector_ImGuiWindowStackData = extern struct {
    Size: c_int,
    Capacity: c_int,
    Data: [*c]ImGuiWindowStackData,
};
pub const ImVector_ImGuiWindowStackData = struct_ImVector_ImGuiWindowStackData;
const union_unnamed_2 = extern union {
    val_i: c_int,
    val_f: f32,
    val_p: ?*anyopaque,
};
pub const struct_ImGuiStoragePair = extern struct {
    key: ImGuiID,
    unnamed_0: union_unnamed_2,
};
pub const ImGuiStoragePair = struct_ImGuiStoragePair;
pub const struct_ImVector_ImGuiStoragePair = extern struct {
    Size: c_int,
    Capacity: c_int,
    Data: [*c]ImGuiStoragePair,
};
pub const ImVector_ImGuiStoragePair = struct_ImVector_ImGuiStoragePair;
pub const struct_ImGuiStorage = extern struct {
    Data: ImVector_ImGuiStoragePair,
};
pub const ImGuiStorage = struct_ImGuiStorage;
pub const struct_ImGuiKeyOwnerData = extern struct {
    OwnerCurr: ImGuiID,
    OwnerNext: ImGuiID,
    LockThisFrame: bool,
    LockUntilRelease: bool,
};
pub const ImGuiKeyOwnerData = struct_ImGuiKeyOwnerData;
pub const ImS16 = c_short;
pub const ImGuiKeyRoutingIndex = ImS16;
pub const struct_ImGuiKeyRoutingData = extern struct {
    NextEntryIndex: ImGuiKeyRoutingIndex,
    Mods: ImU16,
    RoutingNextScore: ImU8,
    RoutingCurr: ImGuiID,
    RoutingNext: ImGuiID,
};
pub const ImGuiKeyRoutingData = struct_ImGuiKeyRoutingData;
pub const struct_ImVector_ImGuiKeyRoutingData = extern struct {
    Size: c_int,
    Capacity: c_int,
    Data: [*c]ImGuiKeyRoutingData,
};
pub const ImVector_ImGuiKeyRoutingData = struct_ImVector_ImGuiKeyRoutingData;
pub const struct_ImGuiKeyRoutingTable = extern struct {
    Index: [140]ImGuiKeyRoutingIndex,
    Entries: ImVector_ImGuiKeyRoutingData,
    EntriesNext: ImVector_ImGuiKeyRoutingData,
};
pub const ImGuiKeyRoutingTable = struct_ImGuiKeyRoutingTable;
pub const ImGuiNextItemDataFlags = c_int;
pub const ImGuiCond = c_int;
pub const struct_ImGuiNextItemData = extern struct {
    Flags: ImGuiNextItemDataFlags,
    ItemFlags: ImGuiItemFlags,
    Width: f32,
    FocusScopeId: ImGuiID,
    OpenCond: ImGuiCond,
    OpenVal: bool,
};
pub const ImGuiNextItemData = struct_ImGuiNextItemData;
pub const ImGuiNextWindowDataFlags = c_int;
pub const struct_ImGuiSizeCallbackData = extern struct {
    UserData: ?*anyopaque,
    Pos: ImVec2,
    CurrentSize: ImVec2,
    DesiredSize: ImVec2,
};
pub const ImGuiSizeCallbackData = struct_ImGuiSizeCallbackData;
pub const ImGuiSizeCallback = ?*const fn ([*c]ImGuiSizeCallbackData) callconv(.C) void;
pub const struct_ImGuiNextWindowData = extern struct {
    Flags: ImGuiNextWindowDataFlags,
    PosCond: ImGuiCond,
    SizeCond: ImGuiCond,
    CollapsedCond: ImGuiCond,
    DockCond: ImGuiCond,
    PosVal: ImVec2,
    PosPivotVal: ImVec2,
    SizeVal: ImVec2,
    ContentSizeVal: ImVec2,
    ScrollVal: ImVec2,
    PosUndock: bool,
    CollapsedVal: bool,
    SizeConstraintRect: ImRect,
    SizeCallback: ImGuiSizeCallback,
    SizeCallbackUserData: ?*anyopaque,
    BgAlphaVal: f32,
    ViewportId: ImGuiID,
    DockId: ImGuiID,
    WindowClass: ImGuiWindowClass,
    MenuBarOffsetMinVal: ImVec2,
};
pub const ImGuiNextWindowData = struct_ImGuiNextWindowData;
pub const ImGuiCol = c_int;
pub const struct_ImGuiColorMod = extern struct {
    Col: ImGuiCol,
    BackupValue: ImVec4,
};
pub const ImGuiColorMod = struct_ImGuiColorMod;
pub const struct_ImVector_ImGuiColorMod = extern struct {
    Size: c_int,
    Capacity: c_int,
    Data: [*c]ImGuiColorMod,
};
pub const ImVector_ImGuiColorMod = struct_ImVector_ImGuiColorMod;
pub const ImGuiStyleVar = c_int;
const union_unnamed_3 = extern union {
    BackupInt: [2]c_int,
    BackupFloat: [2]f32,
};
pub const struct_ImGuiStyleMod = extern struct {
    VarIdx: ImGuiStyleVar,
    unnamed_0: union_unnamed_3,
};
pub const ImGuiStyleMod = struct_ImGuiStyleMod;
pub const struct_ImVector_ImGuiStyleMod = extern struct {
    Size: c_int,
    Capacity: c_int,
    Data: [*c]ImGuiStyleMod,
};
pub const ImVector_ImGuiStyleMod = struct_ImVector_ImGuiStyleMod;
pub const struct_ImVector_ImGuiID = extern struct {
    Size: c_int,
    Capacity: c_int,
    Data: [*c]ImGuiID,
};
pub const ImVector_ImGuiID = struct_ImVector_ImGuiID;
pub const struct_ImVector_ImGuiItemFlags = extern struct {
    Size: c_int,
    Capacity: c_int,
    Data: [*c]ImGuiItemFlags,
};
pub const ImVector_ImGuiItemFlags = struct_ImVector_ImGuiItemFlags;
pub const struct_ImVec1 = extern struct {
    x: f32,
};
pub const ImVec1 = struct_ImVec1;
pub const struct_ImGuiGroupData = extern struct {
    WindowID: ImGuiID,
    BackupCursorPos: ImVec2,
    BackupCursorMaxPos: ImVec2,
    BackupIndent: ImVec1,
    BackupGroupOffset: ImVec1,
    BackupCurrLineSize: ImVec2,
    BackupCurrLineTextBaseOffset: f32,
    BackupActiveIdIsAlive: ImGuiID,
    BackupActiveIdPreviousFrameIsAlive: bool,
    BackupHoveredIdIsAlive: bool,
    EmitItem: bool,
};
pub const ImGuiGroupData = struct_ImGuiGroupData;
pub const struct_ImVector_ImGuiGroupData = extern struct {
    Size: c_int,
    Capacity: c_int,
    Data: [*c]ImGuiGroupData,
};
pub const ImVector_ImGuiGroupData = struct_ImVector_ImGuiGroupData;
pub const struct_ImGuiPopupData = extern struct {
    PopupId: ImGuiID,
    Window: ?*ImGuiWindow,
    BackupNavWindow: ?*ImGuiWindow,
    ParentNavLayer: c_int,
    OpenFrameCount: c_int,
    OpenParentId: ImGuiID,
    OpenPopupPos: ImVec2,
    OpenMousePos: ImVec2,
};
pub const ImGuiPopupData = struct_ImGuiPopupData;
pub const struct_ImVector_ImGuiPopupData = extern struct {
    Size: c_int,
    Capacity: c_int,
    Data: [*c]ImGuiPopupData,
};
pub const ImVector_ImGuiPopupData = struct_ImVector_ImGuiPopupData;
pub const struct_ImGuiNavTreeNodeData = extern struct {
    ID: ImGuiID,
    InFlags: ImGuiItemFlags,
    NavRect: ImRect,
};
pub const ImGuiNavTreeNodeData = struct_ImGuiNavTreeNodeData;
pub const struct_ImVector_ImGuiNavTreeNodeData = extern struct {
    Size: c_int,
    Capacity: c_int,
    Data: [*c]ImGuiNavTreeNodeData,
};
pub const ImVector_ImGuiNavTreeNodeData = struct_ImVector_ImGuiNavTreeNodeData;
pub const struct_ImVector_ImGuiViewportPPtr = extern struct {
    Size: c_int,
    Capacity: c_int,
    Data: [*c][*c]ImGuiViewportP,
};
pub const ImVector_ImGuiViewportPPtr = struct_ImVector_ImGuiViewportPPtr;
pub const ImGuiActivateFlags = c_int;
pub const struct_ImGuiNavItemData = extern struct {
    Window: ?*ImGuiWindow,
    ID: ImGuiID,
    FocusScopeId: ImGuiID,
    RectRel: ImRect,
    InFlags: ImGuiItemFlags,
    DistBox: f32,
    DistCenter: f32,
    DistAxial: f32,
};
pub const ImGuiNavItemData = struct_ImGuiNavItemData;
pub const ImGuiNavMoveFlags = c_int;
pub const ImGuiScrollFlags = c_int;
pub const ImGuiDragDropFlags = c_int;
pub const struct_ImGuiPayload = extern struct {
    Data: ?*anyopaque,
    DataSize: c_int,
    SourceId: ImGuiID,
    SourceParentId: ImGuiID,
    DataFrameCount: c_int,
    DataType: [33]u8,
    Preview: bool,
    Delivery: bool,
};
pub const ImGuiPayload = struct_ImGuiPayload;
pub const struct_ImVector_unsigned_char = extern struct {
    Size: c_int,
    Capacity: c_int,
    Data: [*c]u8,
};
pub const ImVector_unsigned_char = struct_ImVector_unsigned_char;
pub const struct_ImGuiListClipper = extern struct {
    Ctx: [*c]ImGuiContext,
    DisplayStart: c_int,
    DisplayEnd: c_int,
    ItemsCount: c_int,
    ItemsHeight: f32,
    StartPosY: f32,
    TempData: ?*anyopaque,
};
pub const ImGuiListClipper = struct_ImGuiListClipper;
pub const struct_ImGuiListClipperRange = extern struct {
    Min: c_int,
    Max: c_int,
    PosToIndexConvert: bool,
    PosToIndexOffsetMin: ImS8,
    PosToIndexOffsetMax: ImS8,
};
pub const ImGuiListClipperRange = struct_ImGuiListClipperRange;
pub const struct_ImVector_ImGuiListClipperRange = extern struct {
    Size: c_int,
    Capacity: c_int,
    Data: [*c]ImGuiListClipperRange,
};
pub const ImVector_ImGuiListClipperRange = struct_ImVector_ImGuiListClipperRange;
pub const struct_ImGuiListClipperData = extern struct {
    ListClipper: [*c]ImGuiListClipper,
    LossynessOffset: f32,
    StepNo: c_int,
    ItemsFrozen: c_int,
    Ranges: ImVector_ImGuiListClipperRange,
};
pub const ImGuiListClipperData = struct_ImGuiListClipperData;
pub const struct_ImVector_ImGuiListClipperData = extern struct {
    Size: c_int,
    Capacity: c_int,
    Data: [*c]ImGuiListClipperData,
};
pub const ImVector_ImGuiListClipperData = struct_ImVector_ImGuiListClipperData;
pub const ImGuiTableFlags = c_int;
pub const struct_ImGuiTableTempData = extern struct {
    TableIndex: c_int,
    LastTimeActive: f32,
    UserOuterSize: ImVec2,
    DrawSplitter: ImDrawListSplitter,
    HostBackupWorkRect: ImRect,
    HostBackupParentWorkRect: ImRect,
    HostBackupPrevLineSize: ImVec2,
    HostBackupCurrLineSize: ImVec2,
    HostBackupCursorMaxPos: ImVec2,
    HostBackupColumnsOffset: ImVec1,
    HostBackupItemWidth: f32,
    HostBackupItemWidthStackSize: c_int,
};
pub const ImGuiTableTempData = struct_ImGuiTableTempData;
pub const ImGuiTableColumnFlags = c_int;
pub const ImGuiTableColumnIdx = ImS16;
pub const ImGuiTableDrawChannelIdx = ImU16; // cimgui.h:2946:10: warning: struct demoted to opaque type - has bitfield
pub const struct_ImGuiTableColumn = opaque {};
pub const ImGuiTableColumn = struct_ImGuiTableColumn;
pub const struct_ImSpan_ImGuiTableColumn = extern struct {
    Data: ?*ImGuiTableColumn,
    DataEnd: ?*ImGuiTableColumn,
};
pub const ImSpan_ImGuiTableColumn = struct_ImSpan_ImGuiTableColumn;
pub const struct_ImSpan_ImGuiTableColumnIdx = extern struct {
    Data: [*c]ImGuiTableColumnIdx,
    DataEnd: [*c]ImGuiTableColumnIdx,
};
pub const ImSpan_ImGuiTableColumnIdx = struct_ImSpan_ImGuiTableColumnIdx;
pub const struct_ImGuiTableCellData = extern struct {
    BgColor: ImU32,
    Column: ImGuiTableColumnIdx,
};
pub const ImGuiTableCellData = struct_ImGuiTableCellData;
pub const struct_ImSpan_ImGuiTableCellData = extern struct {
    Data: [*c]ImGuiTableCellData,
    DataEnd: [*c]ImGuiTableCellData,
};
pub const ImSpan_ImGuiTableCellData = struct_ImSpan_ImGuiTableCellData;
pub const ImBitArrayPtr = [*c]ImU32; // cimgui.h:3002:24: warning: struct demoted to opaque type - has bitfield
pub const struct_ImGuiTable = opaque {};
pub const ImGuiTable = struct_ImGuiTable;
pub const struct_ImVector_ImGuiTableTempData = extern struct {
    Size: c_int,
    Capacity: c_int,
    Data: [*c]ImGuiTableTempData,
};
pub const ImVector_ImGuiTableTempData = struct_ImVector_ImGuiTableTempData;
pub const struct_ImVector_ImGuiTable = extern struct {
    Size: c_int,
    Capacity: c_int,
    Data: ?*ImGuiTable,
};
pub const ImVector_ImGuiTable = struct_ImVector_ImGuiTable;
pub const ImPoolIdx = c_int;
pub const struct_ImPool_ImGuiTable = extern struct {
    Buf: ImVector_ImGuiTable,
    Map: ImGuiStorage,
    FreeIdx: ImPoolIdx,
    AliveCount: ImPoolIdx,
};
pub const ImPool_ImGuiTable = struct_ImPool_ImGuiTable;
pub const ImS32 = c_int;
pub const struct_ImGuiTabItem = extern struct {
    ID: ImGuiID,
    Flags: ImGuiTabItemFlags,
    Window: ?*ImGuiWindow,
    LastFrameVisible: c_int,
    LastFrameSelected: c_int,
    Offset: f32,
    Width: f32,
    ContentWidth: f32,
    RequestedWidth: f32,
    NameOffset: ImS32,
    BeginOrder: ImS16,
    IndexDuringLayout: ImS16,
    WantClose: bool,
};
pub const ImGuiTabItem = struct_ImGuiTabItem;
pub const struct_ImVector_ImGuiTabItem = extern struct {
    Size: c_int,
    Capacity: c_int,
    Data: [*c]ImGuiTabItem,
};
pub const ImVector_ImGuiTabItem = struct_ImVector_ImGuiTabItem;
pub const ImGuiTabBarFlags = c_int;
pub const struct_ImVector_char = extern struct {
    Size: c_int,
    Capacity: c_int,
    Data: [*c]u8,
};
pub const ImVector_char = struct_ImVector_char;
pub const struct_ImGuiTextBuffer = extern struct {
    Buf: ImVector_char,
};
pub const ImGuiTextBuffer = struct_ImGuiTextBuffer;
pub const struct_ImGuiTabBar = extern struct {
    Tabs: ImVector_ImGuiTabItem,
    Flags: ImGuiTabBarFlags,
    ID: ImGuiID,
    SelectedTabId: ImGuiID,
    NextSelectedTabId: ImGuiID,
    VisibleTabId: ImGuiID,
    CurrFrameVisible: c_int,
    PrevFrameVisible: c_int,
    BarRect: ImRect,
    CurrTabsContentsHeight: f32,
    PrevTabsContentsHeight: f32,
    WidthAllTabs: f32,
    WidthAllTabsIdeal: f32,
    ScrollingAnim: f32,
    ScrollingTarget: f32,
    ScrollingTargetDistToVisibility: f32,
    ScrollingSpeed: f32,
    ScrollingRectMinX: f32,
    ScrollingRectMaxX: f32,
    ReorderRequestTabId: ImGuiID,
    ReorderRequestOffset: ImS16,
    BeginCount: ImS8,
    WantLayout: bool,
    VisibleTabWasSubmitted: bool,
    TabsAddedNew: bool,
    TabsActiveCount: ImS16,
    LastTabItemIdx: ImS16,
    ItemSpacingY: f32,
    FramePadding: ImVec2,
    BackupCursorPos: ImVec2,
    TabsNames: ImGuiTextBuffer,
};
pub const ImGuiTabBar = struct_ImGuiTabBar;
pub const struct_ImVector_ImGuiTabBar = extern struct {
    Size: c_int,
    Capacity: c_int,
    Data: [*c]ImGuiTabBar,
};
pub const ImVector_ImGuiTabBar = struct_ImVector_ImGuiTabBar;
pub const struct_ImPool_ImGuiTabBar = extern struct {
    Buf: ImVector_ImGuiTabBar,
    Map: ImGuiStorage,
    FreeIdx: ImPoolIdx,
    AliveCount: ImPoolIdx,
};
pub const ImPool_ImGuiTabBar = struct_ImPool_ImGuiTabBar;
pub const struct_ImGuiPtrOrIndex = extern struct {
    Ptr: ?*anyopaque,
    Index: c_int,
};
pub const ImGuiPtrOrIndex = struct_ImGuiPtrOrIndex;
pub const struct_ImVector_ImGuiPtrOrIndex = extern struct {
    Size: c_int,
    Capacity: c_int,
    Data: [*c]ImGuiPtrOrIndex,
};
pub const ImVector_ImGuiPtrOrIndex = struct_ImVector_ImGuiPtrOrIndex;
pub const struct_ImGuiShrinkWidthItem = extern struct {
    Index: c_int,
    Width: f32,
    InitialWidth: f32,
};
pub const ImGuiShrinkWidthItem = struct_ImGuiShrinkWidthItem;
pub const struct_ImVector_ImGuiShrinkWidthItem = extern struct {
    Size: c_int,
    Capacity: c_int,
    Data: [*c]ImGuiShrinkWidthItem,
};
pub const ImVector_ImGuiShrinkWidthItem = struct_ImVector_ImGuiShrinkWidthItem;
pub const ImGuiMouseCursor = c_int;
pub const struct_StbUndoRecord = extern struct {
    where: c_int,
    insert_length: c_int,
    delete_length: c_int,
    char_storage: c_int,
};
pub const StbUndoRecord = struct_StbUndoRecord;
pub const struct_StbUndoState = extern struct {
    undo_rec: [99]StbUndoRecord,
    undo_char: [999]ImWchar,
    undo_point: c_short,
    redo_point: c_short,
    undo_char_point: c_int,
    redo_char_point: c_int,
};
pub const StbUndoState = struct_StbUndoState;
pub const struct_STB_TexteditState = extern struct {
    cursor: c_int,
    select_start: c_int,
    select_end: c_int,
    insert_mode: u8,
    row_count_per_page: c_int,
    cursor_at_end_of_line: u8,
    initialized: u8,
    has_preferred_x: u8,
    single_line: u8,
    padding1: u8,
    padding2: u8,
    padding3: u8,
    preferred_x: f32,
    undostate: StbUndoState,
};
pub const STB_TexteditState = struct_STB_TexteditState;
pub const ImGuiInputTextFlags = c_int;
pub const struct_ImGuiInputTextState = extern struct {
    Ctx: [*c]ImGuiContext,
    ID: ImGuiID,
    CurLenW: c_int,
    CurLenA: c_int,
    TextW: ImVector_ImWchar,
    TextA: ImVector_char,
    InitialTextA: ImVector_char,
    TextAIsValid: bool,
    BufCapacityA: c_int,
    ScrollX: f32,
    Stb: STB_TexteditState,
    CursorAnim: f32,
    CursorFollow: bool,
    SelectedAllMouseLock: bool,
    Edited: bool,
    Flags: ImGuiInputTextFlags,
};
pub const ImGuiInputTextState = struct_ImGuiInputTextState;
pub const struct_ImGuiInputTextDeactivatedState = extern struct {
    ID: ImGuiID,
    TextA: ImVector_char,
};
pub const ImGuiInputTextDeactivatedState = struct_ImGuiInputTextDeactivatedState;
pub const ImGuiColorEditFlags = c_int;
pub const ImGuiLayoutType = c_int;
pub const struct_ImGuiComboPreviewData = extern struct {
    PreviewRect: ImRect,
    BackupCursorPos: ImVec2,
    BackupCursorMaxPos: ImVec2,
    BackupCursorPosPrevLine: ImVec2,
    BackupPrevLineTextBaseOffset: f32,
    BackupLayout: ImGuiLayoutType,
};
pub const ImGuiComboPreviewData = struct_ImGuiComboPreviewData;
pub const struct_ImGuiDockRequest = opaque {};
pub const ImGuiDockRequest = struct_ImGuiDockRequest;
pub const struct_ImVector_ImGuiDockRequest = extern struct {
    Size: c_int,
    Capacity: c_int,
    Data: ?*ImGuiDockRequest,
};
pub const ImVector_ImGuiDockRequest = struct_ImVector_ImGuiDockRequest;
pub const struct_ImGuiDockNodeSettings = opaque {};
pub const ImGuiDockNodeSettings = struct_ImGuiDockNodeSettings;
pub const struct_ImVector_ImGuiDockNodeSettings = extern struct {
    Size: c_int,
    Capacity: c_int,
    Data: ?*ImGuiDockNodeSettings,
};
pub const ImVector_ImGuiDockNodeSettings = struct_ImVector_ImGuiDockNodeSettings;
pub const struct_ImGuiDockContext = extern struct {
    Nodes: ImGuiStorage,
    Requests: ImVector_ImGuiDockRequest,
    NodesSettings: ImVector_ImGuiDockNodeSettings,
    WantFullRebuild: bool,
};
pub const ImGuiDockContext = struct_ImGuiDockContext; // cimgui.h:2207:24: warning: struct demoted to opaque type - has bitfield
pub const struct_ImGuiDockNode = opaque {};
pub const ImGuiDockNode = struct_ImGuiDockNode;
pub const struct_ImGuiSettingsHandler = extern struct {
    TypeName: [*c]const u8,
    TypeHash: ImGuiID,
    ClearAllFn: ?*const fn ([*c]ImGuiContext, [*c]ImGuiSettingsHandler) callconv(.C) void,
    ReadInitFn: ?*const fn ([*c]ImGuiContext, [*c]ImGuiSettingsHandler) callconv(.C) void,
    ReadOpenFn: ?*const fn ([*c]ImGuiContext, [*c]ImGuiSettingsHandler, [*c]const u8) callconv(.C) ?*anyopaque,
    ReadLineFn: ?*const fn ([*c]ImGuiContext, [*c]ImGuiSettingsHandler, ?*anyopaque, [*c]const u8) callconv(.C) void,
    ApplyAllFn: ?*const fn ([*c]ImGuiContext, [*c]ImGuiSettingsHandler) callconv(.C) void,
    WriteAllFn: ?*const fn ([*c]ImGuiContext, [*c]ImGuiSettingsHandler, [*c]ImGuiTextBuffer) callconv(.C) void,
    UserData: ?*anyopaque,
};
pub const ImGuiSettingsHandler = struct_ImGuiSettingsHandler;
pub const struct_ImVector_ImGuiSettingsHandler = extern struct {
    Size: c_int,
    Capacity: c_int,
    Data: [*c]ImGuiSettingsHandler,
};
pub const ImVector_ImGuiSettingsHandler = struct_ImVector_ImGuiSettingsHandler;
pub const struct_ImChunkStream_ImGuiWindowSettings = extern struct {
    Buf: ImVector_char,
};
pub const ImChunkStream_ImGuiWindowSettings = struct_ImChunkStream_ImGuiWindowSettings;
pub const struct_ImChunkStream_ImGuiTableSettings = extern struct {
    Buf: ImVector_char,
};
pub const ImChunkStream_ImGuiTableSettings = struct_ImChunkStream_ImGuiTableSettings;
pub const ImGuiContextHookCallback = ?*const fn ([*c]ImGuiContext, [*c]ImGuiContextHook) callconv(.C) void;
pub const struct_ImGuiContextHook = extern struct {
    HookId: ImGuiID,
    Type: ImGuiContextHookType,
    Owner: ImGuiID,
    Callback: ImGuiContextHookCallback,
    UserData: ?*anyopaque,
};
pub const ImGuiContextHook = struct_ImGuiContextHook;
pub const struct_ImVector_ImGuiContextHook = extern struct {
    Size: c_int,
    Capacity: c_int,
    Data: [*c]ImGuiContextHook,
};
pub const ImVector_ImGuiContextHook = struct_ImVector_ImGuiContextHook;
pub const ImFileHandle = [*c]FILE;
pub const ImGuiDebugLogFlags = c_int;
pub const struct_ImVector_int = extern struct {
    Size: c_int,
    Capacity: c_int,
    Data: [*c]c_int,
};
pub const ImVector_int = struct_ImVector_int;
pub const struct_ImGuiTextIndex = extern struct {
    LineOffsets: ImVector_int,
    EndOffset: c_int,
};
pub const ImGuiTextIndex = struct_ImGuiTextIndex;
pub const struct_ImGuiMetricsConfig = extern struct {
    ShowDebugLog: bool,
    ShowStackTool: bool,
    ShowWindowsRects: bool,
    ShowWindowsBeginOrder: bool,
    ShowTablesRects: bool,
    ShowDrawCmdMesh: bool,
    ShowDrawCmdBoundingBoxes: bool,
    ShowAtlasTintedWithTextColor: bool,
    ShowDockingNodes: bool,
    ShowWindowsRectsType: c_int,
    ShowTablesRectsType: c_int,
};
pub const ImGuiMetricsConfig = struct_ImGuiMetricsConfig; // cimgui.h:2351:19: warning: struct demoted to opaque type - has bitfield
pub const struct_ImGuiStackLevelInfo = opaque {};
pub const ImGuiStackLevelInfo = struct_ImGuiStackLevelInfo;
pub const struct_ImVector_ImGuiStackLevelInfo = extern struct {
    Size: c_int,
    Capacity: c_int,
    Data: ?*ImGuiStackLevelInfo,
};
pub const ImVector_ImGuiStackLevelInfo = struct_ImVector_ImGuiStackLevelInfo;
pub const struct_ImGuiStackTool = extern struct {
    LastActiveFrame: c_int,
    StackLevel: c_int,
    QueryId: ImGuiID,
    Results: ImVector_ImGuiStackLevelInfo,
    CopyToClipboardOnCtrlC: bool,
    CopyToClipboardLastTime: f32,
};
pub const ImGuiStackTool = struct_ImGuiStackTool;
pub const struct_ImGuiContext = extern struct {
    Initialized: bool,
    FontAtlasOwnedByContext: bool,
    IO: ImGuiIO,
    PlatformIO: ImGuiPlatformIO,
    Style: ImGuiStyle,
    ConfigFlagsCurrFrame: ImGuiConfigFlags,
    ConfigFlagsLastFrame: ImGuiConfigFlags,
    Font: [*c]ImFont,
    FontSize: f32,
    FontBaseSize: f32,
    DrawListSharedData: ImDrawListSharedData,
    Time: f64,
    FrameCount: c_int,
    FrameCountEnded: c_int,
    FrameCountPlatformEnded: c_int,
    FrameCountRendered: c_int,
    WithinFrameScope: bool,
    WithinFrameScopeWithImplicitWindow: bool,
    WithinEndChild: bool,
    GcCompactAll: bool,
    TestEngineHookItems: bool,
    TestEngine: ?*anyopaque,
    InputEventsQueue: ImVector_ImGuiInputEvent,
    InputEventsTrail: ImVector_ImGuiInputEvent,
    InputEventsNextMouseSource: ImGuiMouseSource,
    InputEventsNextEventId: ImU32,
    Windows: ImVector_ImGuiWindowPtr,
    WindowsFocusOrder: ImVector_ImGuiWindowPtr,
    WindowsTempSortBuffer: ImVector_ImGuiWindowPtr,
    CurrentWindowStack: ImVector_ImGuiWindowStackData,
    WindowsById: ImGuiStorage,
    WindowsActiveCount: c_int,
    WindowsHoverPadding: ImVec2,
    CurrentWindow: ?*ImGuiWindow,
    HoveredWindow: ?*ImGuiWindow,
    HoveredWindowUnderMovingWindow: ?*ImGuiWindow,
    MovingWindow: ?*ImGuiWindow,
    WheelingWindow: ?*ImGuiWindow,
    WheelingWindowRefMousePos: ImVec2,
    WheelingWindowStartFrame: c_int,
    WheelingWindowReleaseTimer: f32,
    WheelingWindowWheelRemainder: ImVec2,
    WheelingAxisAvg: ImVec2,
    DebugHookIdInfo: ImGuiID,
    HoveredId: ImGuiID,
    HoveredIdPreviousFrame: ImGuiID,
    HoveredIdAllowOverlap: bool,
    HoveredIdDisabled: bool,
    HoveredIdTimer: f32,
    HoveredIdNotActiveTimer: f32,
    ActiveId: ImGuiID,
    ActiveIdIsAlive: ImGuiID,
    ActiveIdTimer: f32,
    ActiveIdIsJustActivated: bool,
    ActiveIdAllowOverlap: bool,
    ActiveIdNoClearOnFocusLoss: bool,
    ActiveIdHasBeenPressedBefore: bool,
    ActiveIdHasBeenEditedBefore: bool,
    ActiveIdHasBeenEditedThisFrame: bool,
    ActiveIdClickOffset: ImVec2,
    ActiveIdWindow: ?*ImGuiWindow,
    ActiveIdSource: ImGuiInputSource,
    ActiveIdMouseButton: c_int,
    ActiveIdPreviousFrame: ImGuiID,
    ActiveIdPreviousFrameIsAlive: bool,
    ActiveIdPreviousFrameHasBeenEditedBefore: bool,
    ActiveIdPreviousFrameWindow: ?*ImGuiWindow,
    LastActiveId: ImGuiID,
    LastActiveIdTimer: f32,
    KeysOwnerData: [140]ImGuiKeyOwnerData,
    KeysRoutingTable: ImGuiKeyRoutingTable,
    ActiveIdUsingNavDirMask: ImU32,
    ActiveIdUsingAllKeyboardKeys: bool,
    ActiveIdUsingNavInputMask: ImU32,
    CurrentFocusScopeId: ImGuiID,
    CurrentItemFlags: ImGuiItemFlags,
    DebugLocateId: ImGuiID,
    NextItemData: ImGuiNextItemData,
    LastItemData: ImGuiLastItemData,
    NextWindowData: ImGuiNextWindowData,
    ColorStack: ImVector_ImGuiColorMod,
    StyleVarStack: ImVector_ImGuiStyleMod,
    FontStack: ImVector_ImFontPtr,
    FocusScopeStack: ImVector_ImGuiID,
    ItemFlagsStack: ImVector_ImGuiItemFlags,
    GroupStack: ImVector_ImGuiGroupData,
    OpenPopupStack: ImVector_ImGuiPopupData,
    BeginPopupStack: ImVector_ImGuiPopupData,
    NavTreeNodeStack: ImVector_ImGuiNavTreeNodeData,
    BeginMenuCount: c_int,
    Viewports: ImVector_ImGuiViewportPPtr,
    CurrentDpiScale: f32,
    CurrentViewport: [*c]ImGuiViewportP,
    MouseViewport: [*c]ImGuiViewportP,
    MouseLastHoveredViewport: [*c]ImGuiViewportP,
    PlatformLastFocusedViewportId: ImGuiID,
    FallbackMonitor: ImGuiPlatformMonitor,
    ViewportCreatedCount: c_int,
    PlatformWindowsCreatedCount: c_int,
    ViewportFocusedStampCount: c_int,
    NavWindow: ?*ImGuiWindow,
    NavId: ImGuiID,
    NavFocusScopeId: ImGuiID,
    NavActivateId: ImGuiID,
    NavActivateDownId: ImGuiID,
    NavActivatePressedId: ImGuiID,
    NavActivateFlags: ImGuiActivateFlags,
    NavJustMovedToId: ImGuiID,
    NavJustMovedToFocusScopeId: ImGuiID,
    NavJustMovedToKeyMods: ImGuiKeyChord,
    NavNextActivateId: ImGuiID,
    NavNextActivateFlags: ImGuiActivateFlags,
    NavInputSource: ImGuiInputSource,
    NavLayer: ImGuiNavLayer,
    NavIdIsAlive: bool,
    NavMousePosDirty: bool,
    NavDisableHighlight: bool,
    NavDisableMouseHover: bool,
    NavAnyRequest: bool,
    NavInitRequest: bool,
    NavInitRequestFromMove: bool,
    NavInitResult: ImGuiNavItemData,
    NavMoveSubmitted: bool,
    NavMoveScoringItems: bool,
    NavMoveForwardToNextFrame: bool,
    NavMoveFlags: ImGuiNavMoveFlags,
    NavMoveScrollFlags: ImGuiScrollFlags,
    NavMoveKeyMods: ImGuiKeyChord,
    NavMoveDir: ImGuiDir,
    NavMoveDirForDebug: ImGuiDir,
    NavMoveClipDir: ImGuiDir,
    NavScoringRect: ImRect,
    NavScoringNoClipRect: ImRect,
    NavScoringDebugCount: c_int,
    NavTabbingDir: c_int,
    NavTabbingCounter: c_int,
    NavMoveResultLocal: ImGuiNavItemData,
    NavMoveResultLocalVisible: ImGuiNavItemData,
    NavMoveResultOther: ImGuiNavItemData,
    NavTabbingResultFirst: ImGuiNavItemData,
    ConfigNavWindowingKeyNext: ImGuiKeyChord,
    ConfigNavWindowingKeyPrev: ImGuiKeyChord,
    NavWindowingTarget: ?*ImGuiWindow,
    NavWindowingTargetAnim: ?*ImGuiWindow,
    NavWindowingListWindow: ?*ImGuiWindow,
    NavWindowingTimer: f32,
    NavWindowingHighlightAlpha: f32,
    NavWindowingToggleLayer: bool,
    NavWindowingAccumDeltaPos: ImVec2,
    NavWindowingAccumDeltaSize: ImVec2,
    DimBgRatio: f32,
    DragDropActive: bool,
    DragDropWithinSource: bool,
    DragDropWithinTarget: bool,
    DragDropSourceFlags: ImGuiDragDropFlags,
    DragDropSourceFrameCount: c_int,
    DragDropMouseButton: c_int,
    DragDropPayload: ImGuiPayload,
    DragDropTargetRect: ImRect,
    DragDropTargetId: ImGuiID,
    DragDropAcceptFlags: ImGuiDragDropFlags,
    DragDropAcceptIdCurrRectSurface: f32,
    DragDropAcceptIdCurr: ImGuiID,
    DragDropAcceptIdPrev: ImGuiID,
    DragDropAcceptFrameCount: c_int,
    DragDropHoldJustPressedId: ImGuiID,
    DragDropPayloadBufHeap: ImVector_unsigned_char,
    DragDropPayloadBufLocal: [16]u8,
    ClipperTempDataStacked: c_int,
    ClipperTempData: ImVector_ImGuiListClipperData,
    CurrentTable: ?*ImGuiTable,
    TablesTempDataStacked: c_int,
    TablesTempData: ImVector_ImGuiTableTempData,
    Tables: ImPool_ImGuiTable,
    TablesLastTimeActive: ImVector_float,
    DrawChannelsTempMergeBuffer: ImVector_ImDrawChannel,
    CurrentTabBar: [*c]ImGuiTabBar,
    TabBars: ImPool_ImGuiTabBar,
    CurrentTabBarStack: ImVector_ImGuiPtrOrIndex,
    ShrinkWidthBuffer: ImVector_ImGuiShrinkWidthItem,
    HoverItemDelayId: ImGuiID,
    HoverItemDelayIdPreviousFrame: ImGuiID,
    HoverItemDelayTimer: f32,
    HoverItemDelayClearTimer: f32,
    HoverItemUnlockedStationaryId: ImGuiID,
    HoverWindowUnlockedStationaryId: ImGuiID,
    MouseCursor: ImGuiMouseCursor,
    MouseStationaryTimer: f32,
    MouseLastValidPos: ImVec2,
    InputTextState: ImGuiInputTextState,
    InputTextDeactivatedState: ImGuiInputTextDeactivatedState,
    InputTextPasswordFont: ImFont,
    TempInputId: ImGuiID,
    ColorEditOptions: ImGuiColorEditFlags,
    ColorEditCurrentID: ImGuiID,
    ColorEditSavedID: ImGuiID,
    ColorEditSavedHue: f32,
    ColorEditSavedSat: f32,
    ColorEditSavedColor: ImU32,
    ColorPickerRef: ImVec4,
    ComboPreviewData: ImGuiComboPreviewData,
    SliderGrabClickOffset: f32,
    SliderCurrentAccum: f32,
    SliderCurrentAccumDirty: bool,
    DragCurrentAccumDirty: bool,
    DragCurrentAccum: f32,
    DragSpeedDefaultRatio: f32,
    ScrollbarClickDeltaToGrabCenter: f32,
    DisabledAlphaBackup: f32,
    DisabledStackSize: c_short,
    LockMarkEdited: c_short,
    TooltipOverrideCount: c_short,
    ClipboardHandlerData: ImVector_char,
    MenusIdSubmittedThisFrame: ImVector_ImGuiID,
    PlatformImeData: ImGuiPlatformImeData,
    PlatformImeDataPrev: ImGuiPlatformImeData,
    PlatformImeViewport: ImGuiID,
    DockContext: ImGuiDockContext,
    DockNodeWindowMenuHandler: ?*const fn ([*c]ImGuiContext, ?*ImGuiDockNode, [*c]ImGuiTabBar) callconv(.C) void,
    SettingsLoaded: bool,
    SettingsDirtyTimer: f32,
    SettingsIniData: ImGuiTextBuffer,
    SettingsHandlers: ImVector_ImGuiSettingsHandler,
    SettingsWindows: ImChunkStream_ImGuiWindowSettings,
    SettingsTables: ImChunkStream_ImGuiTableSettings,
    Hooks: ImVector_ImGuiContextHook,
    HookIdNext: ImGuiID,
    LocalizationTable: [10][*c]const u8,
    LogEnabled: bool,
    LogType: ImGuiLogType,
    LogFile: ImFileHandle,
    LogBuffer: ImGuiTextBuffer,
    LogNextPrefix: [*c]const u8,
    LogNextSuffix: [*c]const u8,
    LogLinePosY: f32,
    LogLineFirstItem: bool,
    LogDepthRef: c_int,
    LogDepthToExpand: c_int,
    LogDepthToExpandDefault: c_int,
    DebugLogFlags: ImGuiDebugLogFlags,
    DebugLogBuf: ImGuiTextBuffer,
    DebugLogIndex: ImGuiTextIndex,
    DebugLogClipperAutoDisableFrames: ImU8,
    DebugLocateFrames: ImU8,
    DebugBeginReturnValueCullDepth: ImS8,
    DebugItemPickerActive: bool,
    DebugItemPickerMouseButton: ImU8,
    DebugItemPickerBreakId: ImGuiID,
    DebugMetricsConfig: ImGuiMetricsConfig,
    DebugStackTool: ImGuiStackTool,
    DebugHoveredDockNode: ?*ImGuiDockNode,
    FramerateSecPerFrame: [60]f32,
    FramerateSecPerFrameIdx: c_int,
    FramerateSecPerFrameCount: c_int,
    FramerateSecPerFrameAccum: f32,
    WantCaptureMouseNextFrame: c_int,
    WantCaptureKeyboardNextFrame: c_int,
    WantTextInputNextFrame: c_int,
    TempBuffer: ImVector_char,
};
pub const struct_ImGuiInputTextCallbackData = extern struct {
    Ctx: [*c]ImGuiContext,
    EventFlag: ImGuiInputTextFlags,
    Flags: ImGuiInputTextFlags,
    UserData: ?*anyopaque,
    EventChar: ImWchar,
    EventKey: ImGuiKey,
    Buf: [*c]u8,
    BufTextLen: c_int,
    BufSize: c_int,
    BufDirty: bool,
    CursorPos: c_int,
    SelectionStart: c_int,
    SelectionEnd: c_int,
};
pub const ImGuiInputTextCallbackData = struct_ImGuiInputTextCallbackData;
pub const struct_ImGuiOnceUponAFrame = extern struct {
    RefFrame: c_int,
};
pub const ImGuiOnceUponAFrame = struct_ImGuiOnceUponAFrame; // cimgui.h:1075:24: warning: struct demoted to opaque type - has bitfield
pub const struct_ImGuiTableColumnSortSpecs = opaque {};
pub const ImGuiTableColumnSortSpecs = struct_ImGuiTableColumnSortSpecs;
pub const struct_ImGuiTableSortSpecs = extern struct {
    Specs: ?*const ImGuiTableColumnSortSpecs,
    SpecsCount: c_int,
    SpecsDirty: bool,
};
pub const ImGuiTableSortSpecs = struct_ImGuiTableSortSpecs;
pub const struct_ImGuiTextRange = extern struct {
    b: [*c]const u8,
    e: [*c]const u8,
};
pub const ImGuiTextRange = struct_ImGuiTextRange;
pub const struct_ImVector_ImGuiTextRange = extern struct {
    Size: c_int,
    Capacity: c_int,
    Data: [*c]ImGuiTextRange,
};
pub const ImVector_ImGuiTextRange = struct_ImVector_ImGuiTextRange;
pub const struct_ImGuiTextFilter = extern struct {
    InputBuf: [256]u8,
    Filters: ImVector_ImGuiTextRange,
    CountGrep: c_int,
};
pub const ImGuiTextFilter = struct_ImGuiTextFilter;
pub const struct_ImBitVector = extern struct {
    Storage: ImVector_ImU32,
};
pub const ImBitVector = struct_ImBitVector;
pub const ImGuiDataType = c_int;
pub const struct_ImGuiDataVarInfo = extern struct {
    Type: ImGuiDataType,
    Count: ImU32,
    Offset: ImU32,
};
pub const ImGuiDataVarInfo = struct_ImGuiDataVarInfo;
pub const struct_ImGuiDataTypeInfo = extern struct {
    Size: usize,
    Name: [*c]const u8,
    PrintFmt: [*c]const u8,
    ScanFmt: [*c]const u8,
};
pub const ImGuiDataTypeInfo = struct_ImGuiDataTypeInfo;
pub const struct_ImGuiInputTextDeactivateData = opaque {};
pub const ImGuiInputTextDeactivateData = struct_ImGuiInputTextDeactivateData;
pub const struct_ImGuiLocEntry = extern struct {
    Key: ImGuiLocKey,
    Text: [*c]const u8,
};
pub const ImGuiLocEntry = struct_ImGuiLocEntry;
pub const struct_ImGuiMenuColumns = extern struct {
    TotalWidth: ImU32,
    NextTotalWidth: ImU32,
    Spacing: ImU16,
    OffsetIcon: ImU16,
    OffsetLabel: ImU16,
    OffsetShortcut: ImU16,
    OffsetMark: ImU16,
    Widths: [4]ImU16,
};
pub const ImGuiMenuColumns = struct_ImGuiMenuColumns;
pub const ImGuiOldColumnFlags = c_int;
pub const struct_ImGuiOldColumnData = extern struct {
    OffsetNorm: f32,
    OffsetNormBeforeResize: f32,
    Flags: ImGuiOldColumnFlags,
    ClipRect: ImRect,
};
pub const ImGuiOldColumnData = struct_ImGuiOldColumnData;
pub const struct_ImVector_ImGuiOldColumnData = extern struct {
    Size: c_int,
    Capacity: c_int,
    Data: [*c]ImGuiOldColumnData,
};
pub const ImVector_ImGuiOldColumnData = struct_ImVector_ImGuiOldColumnData;
pub const struct_ImGuiOldColumns = extern struct {
    ID: ImGuiID,
    Flags: ImGuiOldColumnFlags,
    IsFirstFrame: bool,
    IsBeingResized: bool,
    Current: c_int,
    Count: c_int,
    OffMinX: f32,
    OffMaxX: f32,
    LineMinY: f32,
    LineMaxY: f32,
    HostCursorPosY: f32,
    HostCursorMaxPosX: f32,
    HostInitialClipRect: ImRect,
    HostBackupClipRect: ImRect,
    HostBackupParentWorkRect: ImRect,
    Columns: ImVector_ImGuiOldColumnData,
    Splitter: ImDrawListSplitter,
};
pub const ImGuiOldColumns = struct_ImGuiOldColumns;
pub const struct_ImGuiTableInstanceData = extern struct {
    TableInstanceID: ImGuiID,
    LastOuterHeight: f32,
    LastFirstRowHeight: f32,
    LastFrozenHeight: f32,
    HoveredRowLast: c_int,
    HoveredRowNext: c_int,
};
pub const ImGuiTableInstanceData = struct_ImGuiTableInstanceData;
pub const struct_ImGuiTableSettings = extern struct {
    ID: ImGuiID,
    SaveFlags: ImGuiTableFlags,
    RefScale: f32,
    ColumnsCount: ImGuiTableColumnIdx,
    ColumnsCountMax: ImGuiTableColumnIdx,
    WantApply: bool,
};
pub const ImGuiTableSettings = struct_ImGuiTableSettings;
pub const struct_ImGuiTableColumnsSettings = opaque {};
pub const ImGuiTableColumnsSettings = struct_ImGuiTableColumnsSettings;
pub const struct_ImGuiWindowTempData = extern struct {
    CursorPos: ImVec2,
    CursorPosPrevLine: ImVec2,
    CursorStartPos: ImVec2,
    CursorMaxPos: ImVec2,
    IdealMaxPos: ImVec2,
    CurrLineSize: ImVec2,
    PrevLineSize: ImVec2,
    CurrLineTextBaseOffset: f32,
    PrevLineTextBaseOffset: f32,
    IsSameLine: bool,
    IsSetPos: bool,
    Indent: ImVec1,
    ColumnsOffset: ImVec1,
    GroupOffset: ImVec1,
    CursorStartPosLossyness: ImVec2,
    NavLayerCurrent: ImGuiNavLayer,
    NavLayersActiveMask: c_short,
    NavLayersActiveMaskNext: c_short,
    NavIsScrollPushableX: bool,
    NavHideHighlightOneFrame: bool,
    NavWindowHasScrollY: bool,
    MenuBarAppending: bool,
    MenuBarOffset: ImVec2,
    MenuColumns: ImGuiMenuColumns,
    TreeDepth: c_int,
    TreeJumpToParentOnPopMask: ImU32,
    ChildWindows: ImVector_ImGuiWindowPtr,
    StateStorage: [*c]ImGuiStorage,
    CurrentColumns: [*c]ImGuiOldColumns,
    CurrentTableIdx: c_int,
    LayoutType: ImGuiLayoutType,
    ParentLayoutType: ImGuiLayoutType,
    ItemWidth: f32,
    TextWrapPos: f32,
    ItemWidthStack: ImVector_float,
    TextWrapPosStack: ImVector_float,
};
pub const ImGuiWindowTempData = struct_ImGuiWindowTempData;
pub const struct_ImVec2ih = extern struct {
    x: c_short,
    y: c_short,
};
pub const ImVec2ih = struct_ImVec2ih;
pub const struct_ImGuiWindowSettings = extern struct {
    ID: ImGuiID,
    Pos: ImVec2ih,
    Size: ImVec2ih,
    ViewportPos: ImVec2ih,
    ViewportId: ImGuiID,
    DockId: ImGuiID,
    ClassId: ImGuiID,
    DockOrder: c_short,
    Collapsed: bool,
    WantApply: bool,
    WantDelete: bool,
};
pub const ImGuiWindowSettings = struct_ImGuiWindowSettings;
pub const struct_ImVector_const_charPtr = extern struct {
    Size: c_int,
    Capacity: c_int,
    Data: [*c][*c]const u8,
};
pub const ImVector_const_charPtr = struct_ImVector_const_charPtr;
pub const ImGuiMouseButton = c_int;
pub const ImGuiSortDirection = c_int;
pub const ImGuiTableBgTarget = c_int;
pub const ImDrawFlags = c_int;
pub const ImGuiButtonFlags = c_int;
pub const ImGuiComboFlags = c_int;
pub const ImGuiFocusedFlags = c_int;
pub const ImGuiPopupFlags = c_int;
pub const ImGuiSelectableFlags = c_int;
pub const ImGuiSliderFlags = c_int;
pub const ImGuiTableRowFlags = c_int;
pub const ImGuiTreeNodeFlags = c_int;
pub const ImS64 = c_longlong;
pub const ImWchar32 = c_uint;
pub const ImGuiInputTextCallback = ?*const fn ([*c]ImGuiInputTextCallbackData) callconv(.C) c_int;
pub const ImGuiMemAllocFunc = ?*const fn (usize, ?*anyopaque) callconv(.C) ?*anyopaque;
pub const ImGuiMemFreeFunc = ?*const fn (?*anyopaque, ?*anyopaque) callconv(.C) void;
pub const ImGuiWindowFlags_None: c_int = 0;
pub const ImGuiWindowFlags_NoTitleBar: c_int = 1;
pub const ImGuiWindowFlags_NoResize: c_int = 2;
pub const ImGuiWindowFlags_NoMove: c_int = 4;
pub const ImGuiWindowFlags_NoScrollbar: c_int = 8;
pub const ImGuiWindowFlags_NoScrollWithMouse: c_int = 16;
pub const ImGuiWindowFlags_NoCollapse: c_int = 32;
pub const ImGuiWindowFlags_AlwaysAutoResize: c_int = 64;
pub const ImGuiWindowFlags_NoBackground: c_int = 128;
pub const ImGuiWindowFlags_NoSavedSettings: c_int = 256;
pub const ImGuiWindowFlags_NoMouseInputs: c_int = 512;
pub const ImGuiWindowFlags_MenuBar: c_int = 1024;
pub const ImGuiWindowFlags_HorizontalScrollbar: c_int = 2048;
pub const ImGuiWindowFlags_NoFocusOnAppearing: c_int = 4096;
pub const ImGuiWindowFlags_NoBringToFrontOnFocus: c_int = 8192;
pub const ImGuiWindowFlags_AlwaysVerticalScrollbar: c_int = 16384;
pub const ImGuiWindowFlags_AlwaysHorizontalScrollbar: c_int = 32768;
pub const ImGuiWindowFlags_AlwaysUseWindowPadding: c_int = 65536;
pub const ImGuiWindowFlags_NoNavInputs: c_int = 262144;
pub const ImGuiWindowFlags_NoNavFocus: c_int = 524288;
pub const ImGuiWindowFlags_UnsavedDocument: c_int = 1048576;
pub const ImGuiWindowFlags_NoDocking: c_int = 2097152;
pub const ImGuiWindowFlags_NoNav: c_int = 786432;
pub const ImGuiWindowFlags_NoDecoration: c_int = 43;
pub const ImGuiWindowFlags_NoInputs: c_int = 786944;
pub const ImGuiWindowFlags_NavFlattened: c_int = 8388608;
pub const ImGuiWindowFlags_ChildWindow: c_int = 16777216;
pub const ImGuiWindowFlags_Tooltip: c_int = 33554432;
pub const ImGuiWindowFlags_Popup: c_int = 67108864;
pub const ImGuiWindowFlags_Modal: c_int = 134217728;
pub const ImGuiWindowFlags_ChildMenu: c_int = 268435456;
pub const ImGuiWindowFlags_DockNodeHost: c_int = 536870912;
pub const ImGuiWindowFlags_ = c_uint;
pub const ImGuiInputTextFlags_None: c_int = 0;
pub const ImGuiInputTextFlags_CharsDecimal: c_int = 1;
pub const ImGuiInputTextFlags_CharsHexadecimal: c_int = 2;
pub const ImGuiInputTextFlags_CharsUppercase: c_int = 4;
pub const ImGuiInputTextFlags_CharsNoBlank: c_int = 8;
pub const ImGuiInputTextFlags_AutoSelectAll: c_int = 16;
pub const ImGuiInputTextFlags_EnterReturnsTrue: c_int = 32;
pub const ImGuiInputTextFlags_CallbackCompletion: c_int = 64;
pub const ImGuiInputTextFlags_CallbackHistory: c_int = 128;
pub const ImGuiInputTextFlags_CallbackAlways: c_int = 256;
pub const ImGuiInputTextFlags_CallbackCharFilter: c_int = 512;
pub const ImGuiInputTextFlags_AllowTabInput: c_int = 1024;
pub const ImGuiInputTextFlags_CtrlEnterForNewLine: c_int = 2048;
pub const ImGuiInputTextFlags_NoHorizontalScroll: c_int = 4096;
pub const ImGuiInputTextFlags_AlwaysOverwrite: c_int = 8192;
pub const ImGuiInputTextFlags_ReadOnly: c_int = 16384;
pub const ImGuiInputTextFlags_Password: c_int = 32768;
pub const ImGuiInputTextFlags_NoUndoRedo: c_int = 65536;
pub const ImGuiInputTextFlags_CharsScientific: c_int = 131072;
pub const ImGuiInputTextFlags_CallbackResize: c_int = 262144;
pub const ImGuiInputTextFlags_CallbackEdit: c_int = 524288;
pub const ImGuiInputTextFlags_EscapeClearsAll: c_int = 1048576;
pub const ImGuiInputTextFlags_ = c_uint;
pub const ImGuiTreeNodeFlags_None: c_int = 0;
pub const ImGuiTreeNodeFlags_Selected: c_int = 1;
pub const ImGuiTreeNodeFlags_Framed: c_int = 2;
pub const ImGuiTreeNodeFlags_AllowOverlap: c_int = 4;
pub const ImGuiTreeNodeFlags_NoTreePushOnOpen: c_int = 8;
pub const ImGuiTreeNodeFlags_NoAutoOpenOnLog: c_int = 16;
pub const ImGuiTreeNodeFlags_DefaultOpen: c_int = 32;
pub const ImGuiTreeNodeFlags_OpenOnDoubleClick: c_int = 64;
pub const ImGuiTreeNodeFlags_OpenOnArrow: c_int = 128;
pub const ImGuiTreeNodeFlags_Leaf: c_int = 256;
pub const ImGuiTreeNodeFlags_Bullet: c_int = 512;
pub const ImGuiTreeNodeFlags_FramePadding: c_int = 1024;
pub const ImGuiTreeNodeFlags_SpanAvailWidth: c_int = 2048;
pub const ImGuiTreeNodeFlags_SpanFullWidth: c_int = 4096;
pub const ImGuiTreeNodeFlags_NavLeftJumpsBackHere: c_int = 8192;
pub const ImGuiTreeNodeFlags_CollapsingHeader: c_int = 26;
pub const ImGuiTreeNodeFlags_ = c_uint;
pub const ImGuiPopupFlags_None: c_int = 0;
pub const ImGuiPopupFlags_MouseButtonLeft: c_int = 0;
pub const ImGuiPopupFlags_MouseButtonRight: c_int = 1;
pub const ImGuiPopupFlags_MouseButtonMiddle: c_int = 2;
pub const ImGuiPopupFlags_MouseButtonMask_: c_int = 31;
pub const ImGuiPopupFlags_MouseButtonDefault_: c_int = 1;
pub const ImGuiPopupFlags_NoOpenOverExistingPopup: c_int = 32;
pub const ImGuiPopupFlags_NoOpenOverItems: c_int = 64;
pub const ImGuiPopupFlags_AnyPopupId: c_int = 128;
pub const ImGuiPopupFlags_AnyPopupLevel: c_int = 256;
pub const ImGuiPopupFlags_AnyPopup: c_int = 384;
pub const ImGuiPopupFlags_ = c_uint;
pub const ImGuiSelectableFlags_None: c_int = 0;
pub const ImGuiSelectableFlags_DontClosePopups: c_int = 1;
pub const ImGuiSelectableFlags_SpanAllColumns: c_int = 2;
pub const ImGuiSelectableFlags_AllowDoubleClick: c_int = 4;
pub const ImGuiSelectableFlags_Disabled: c_int = 8;
pub const ImGuiSelectableFlags_AllowOverlap: c_int = 16;
pub const ImGuiSelectableFlags_ = c_uint;
pub const ImGuiComboFlags_None: c_int = 0;
pub const ImGuiComboFlags_PopupAlignLeft: c_int = 1;
pub const ImGuiComboFlags_HeightSmall: c_int = 2;
pub const ImGuiComboFlags_HeightRegular: c_int = 4;
pub const ImGuiComboFlags_HeightLarge: c_int = 8;
pub const ImGuiComboFlags_HeightLargest: c_int = 16;
pub const ImGuiComboFlags_NoArrowButton: c_int = 32;
pub const ImGuiComboFlags_NoPreview: c_int = 64;
pub const ImGuiComboFlags_HeightMask_: c_int = 30;
pub const ImGuiComboFlags_ = c_uint;
pub const ImGuiTabBarFlags_None: c_int = 0;
pub const ImGuiTabBarFlags_Reorderable: c_int = 1;
pub const ImGuiTabBarFlags_AutoSelectNewTabs: c_int = 2;
pub const ImGuiTabBarFlags_TabListPopupButton: c_int = 4;
pub const ImGuiTabBarFlags_NoCloseWithMiddleMouseButton: c_int = 8;
pub const ImGuiTabBarFlags_NoTabListScrollingButtons: c_int = 16;
pub const ImGuiTabBarFlags_NoTooltip: c_int = 32;
pub const ImGuiTabBarFlags_FittingPolicyResizeDown: c_int = 64;
pub const ImGuiTabBarFlags_FittingPolicyScroll: c_int = 128;
pub const ImGuiTabBarFlags_FittingPolicyMask_: c_int = 192;
pub const ImGuiTabBarFlags_FittingPolicyDefault_: c_int = 64;
pub const ImGuiTabBarFlags_ = c_uint;
pub const ImGuiTabItemFlags_None: c_int = 0;
pub const ImGuiTabItemFlags_UnsavedDocument: c_int = 1;
pub const ImGuiTabItemFlags_SetSelected: c_int = 2;
pub const ImGuiTabItemFlags_NoCloseWithMiddleMouseButton: c_int = 4;
pub const ImGuiTabItemFlags_NoPushId: c_int = 8;
pub const ImGuiTabItemFlags_NoTooltip: c_int = 16;
pub const ImGuiTabItemFlags_NoReorder: c_int = 32;
pub const ImGuiTabItemFlags_Leading: c_int = 64;
pub const ImGuiTabItemFlags_Trailing: c_int = 128;
pub const ImGuiTabItemFlags_ = c_uint;
pub const ImGuiTableFlags_None: c_int = 0;
pub const ImGuiTableFlags_Resizable: c_int = 1;
pub const ImGuiTableFlags_Reorderable: c_int = 2;
pub const ImGuiTableFlags_Hideable: c_int = 4;
pub const ImGuiTableFlags_Sortable: c_int = 8;
pub const ImGuiTableFlags_NoSavedSettings: c_int = 16;
pub const ImGuiTableFlags_ContextMenuInBody: c_int = 32;
pub const ImGuiTableFlags_RowBg: c_int = 64;
pub const ImGuiTableFlags_BordersInnerH: c_int = 128;
pub const ImGuiTableFlags_BordersOuterH: c_int = 256;
pub const ImGuiTableFlags_BordersInnerV: c_int = 512;
pub const ImGuiTableFlags_BordersOuterV: c_int = 1024;
pub const ImGuiTableFlags_BordersH: c_int = 384;
pub const ImGuiTableFlags_BordersV: c_int = 1536;
pub const ImGuiTableFlags_BordersInner: c_int = 640;
pub const ImGuiTableFlags_BordersOuter: c_int = 1280;
pub const ImGuiTableFlags_Borders: c_int = 1920;
pub const ImGuiTableFlags_NoBordersInBody: c_int = 2048;
pub const ImGuiTableFlags_NoBordersInBodyUntilResize: c_int = 4096;
pub const ImGuiTableFlags_SizingFixedFit: c_int = 8192;
pub const ImGuiTableFlags_SizingFixedSame: c_int = 16384;
pub const ImGuiTableFlags_SizingStretchProp: c_int = 24576;
pub const ImGuiTableFlags_SizingStretchSame: c_int = 32768;
pub const ImGuiTableFlags_NoHostExtendX: c_int = 65536;
pub const ImGuiTableFlags_NoHostExtendY: c_int = 131072;
pub const ImGuiTableFlags_NoKeepColumnsVisible: c_int = 262144;
pub const ImGuiTableFlags_PreciseWidths: c_int = 524288;
pub const ImGuiTableFlags_NoClip: c_int = 1048576;
pub const ImGuiTableFlags_PadOuterX: c_int = 2097152;
pub const ImGuiTableFlags_NoPadOuterX: c_int = 4194304;
pub const ImGuiTableFlags_NoPadInnerX: c_int = 8388608;
pub const ImGuiTableFlags_ScrollX: c_int = 16777216;
pub const ImGuiTableFlags_ScrollY: c_int = 33554432;
pub const ImGuiTableFlags_SortMulti: c_int = 67108864;
pub const ImGuiTableFlags_SortTristate: c_int = 134217728;
pub const ImGuiTableFlags_SizingMask_: c_int = 57344;
pub const ImGuiTableFlags_ = c_uint;
pub const ImGuiTableColumnFlags_None: c_int = 0;
pub const ImGuiTableColumnFlags_Disabled: c_int = 1;
pub const ImGuiTableColumnFlags_DefaultHide: c_int = 2;
pub const ImGuiTableColumnFlags_DefaultSort: c_int = 4;
pub const ImGuiTableColumnFlags_WidthStretch: c_int = 8;
pub const ImGuiTableColumnFlags_WidthFixed: c_int = 16;
pub const ImGuiTableColumnFlags_NoResize: c_int = 32;
pub const ImGuiTableColumnFlags_NoReorder: c_int = 64;
pub const ImGuiTableColumnFlags_NoHide: c_int = 128;
pub const ImGuiTableColumnFlags_NoClip: c_int = 256;
pub const ImGuiTableColumnFlags_NoSort: c_int = 512;
pub const ImGuiTableColumnFlags_NoSortAscending: c_int = 1024;
pub const ImGuiTableColumnFlags_NoSortDescending: c_int = 2048;
pub const ImGuiTableColumnFlags_NoHeaderLabel: c_int = 4096;
pub const ImGuiTableColumnFlags_NoHeaderWidth: c_int = 8192;
pub const ImGuiTableColumnFlags_PreferSortAscending: c_int = 16384;
pub const ImGuiTableColumnFlags_PreferSortDescending: c_int = 32768;
pub const ImGuiTableColumnFlags_IndentEnable: c_int = 65536;
pub const ImGuiTableColumnFlags_IndentDisable: c_int = 131072;
pub const ImGuiTableColumnFlags_IsEnabled: c_int = 16777216;
pub const ImGuiTableColumnFlags_IsVisible: c_int = 33554432;
pub const ImGuiTableColumnFlags_IsSorted: c_int = 67108864;
pub const ImGuiTableColumnFlags_IsHovered: c_int = 134217728;
pub const ImGuiTableColumnFlags_WidthMask_: c_int = 24;
pub const ImGuiTableColumnFlags_IndentMask_: c_int = 196608;
pub const ImGuiTableColumnFlags_StatusMask_: c_int = 251658240;
pub const ImGuiTableColumnFlags_NoDirectResize_: c_int = 1073741824;
pub const ImGuiTableColumnFlags_ = c_uint;
pub const ImGuiTableRowFlags_None: c_int = 0;
pub const ImGuiTableRowFlags_Headers: c_int = 1;
pub const ImGuiTableRowFlags_ = c_uint;
pub const ImGuiTableBgTarget_None: c_int = 0;
pub const ImGuiTableBgTarget_RowBg0: c_int = 1;
pub const ImGuiTableBgTarget_RowBg1: c_int = 2;
pub const ImGuiTableBgTarget_CellBg: c_int = 3;
pub const ImGuiTableBgTarget_ = c_uint;
pub const ImGuiFocusedFlags_None: c_int = 0;
pub const ImGuiFocusedFlags_ChildWindows: c_int = 1;
pub const ImGuiFocusedFlags_RootWindow: c_int = 2;
pub const ImGuiFocusedFlags_AnyWindow: c_int = 4;
pub const ImGuiFocusedFlags_NoPopupHierarchy: c_int = 8;
pub const ImGuiFocusedFlags_DockHierarchy: c_int = 16;
pub const ImGuiFocusedFlags_RootAndChildWindows: c_int = 3;
pub const ImGuiFocusedFlags_ = c_uint;
pub const ImGuiHoveredFlags_None: c_int = 0;
pub const ImGuiHoveredFlags_ChildWindows: c_int = 1;
pub const ImGuiHoveredFlags_RootWindow: c_int = 2;
pub const ImGuiHoveredFlags_AnyWindow: c_int = 4;
pub const ImGuiHoveredFlags_NoPopupHierarchy: c_int = 8;
pub const ImGuiHoveredFlags_DockHierarchy: c_int = 16;
pub const ImGuiHoveredFlags_AllowWhenBlockedByPopup: c_int = 32;
pub const ImGuiHoveredFlags_AllowWhenBlockedByActiveItem: c_int = 128;
pub const ImGuiHoveredFlags_AllowWhenOverlappedByItem: c_int = 256;
pub const ImGuiHoveredFlags_AllowWhenOverlappedByWindow: c_int = 512;
pub const ImGuiHoveredFlags_AllowWhenDisabled: c_int = 1024;
pub const ImGuiHoveredFlags_NoNavOverride: c_int = 2048;
pub const ImGuiHoveredFlags_AllowWhenOverlapped: c_int = 768;
pub const ImGuiHoveredFlags_RectOnly: c_int = 928;
pub const ImGuiHoveredFlags_RootAndChildWindows: c_int = 3;
pub const ImGuiHoveredFlags_ForTooltip: c_int = 4096;
pub const ImGuiHoveredFlags_Stationary: c_int = 8192;
pub const ImGuiHoveredFlags_DelayNone: c_int = 16384;
pub const ImGuiHoveredFlags_DelayShort: c_int = 32768;
pub const ImGuiHoveredFlags_DelayNormal: c_int = 65536;
pub const ImGuiHoveredFlags_NoSharedDelay: c_int = 131072;
pub const ImGuiHoveredFlags_ = c_uint;
pub const ImGuiDockNodeFlags_None: c_int = 0;
pub const ImGuiDockNodeFlags_KeepAliveOnly: c_int = 1;
pub const ImGuiDockNodeFlags_NoDockingInCentralNode: c_int = 4;
pub const ImGuiDockNodeFlags_PassthruCentralNode: c_int = 8;
pub const ImGuiDockNodeFlags_NoSplit: c_int = 16;
pub const ImGuiDockNodeFlags_NoResize: c_int = 32;
pub const ImGuiDockNodeFlags_AutoHideTabBar: c_int = 64;
pub const ImGuiDockNodeFlags_ = c_uint;
pub const ImGuiDragDropFlags_None: c_int = 0;
pub const ImGuiDragDropFlags_SourceNoPreviewTooltip: c_int = 1;
pub const ImGuiDragDropFlags_SourceNoDisableHover: c_int = 2;
pub const ImGuiDragDropFlags_SourceNoHoldToOpenOthers: c_int = 4;
pub const ImGuiDragDropFlags_SourceAllowNullID: c_int = 8;
pub const ImGuiDragDropFlags_SourceExtern: c_int = 16;
pub const ImGuiDragDropFlags_SourceAutoExpirePayload: c_int = 32;
pub const ImGuiDragDropFlags_AcceptBeforeDelivery: c_int = 1024;
pub const ImGuiDragDropFlags_AcceptNoDrawDefaultRect: c_int = 2048;
pub const ImGuiDragDropFlags_AcceptNoPreviewTooltip: c_int = 4096;
pub const ImGuiDragDropFlags_AcceptPeekOnly: c_int = 3072;
pub const ImGuiDragDropFlags_ = c_uint;
pub const ImGuiDataType_S8: c_int = 0;
pub const ImGuiDataType_U8: c_int = 1;
pub const ImGuiDataType_S16: c_int = 2;
pub const ImGuiDataType_U16: c_int = 3;
pub const ImGuiDataType_S32: c_int = 4;
pub const ImGuiDataType_U32: c_int = 5;
pub const ImGuiDataType_S64: c_int = 6;
pub const ImGuiDataType_U64: c_int = 7;
pub const ImGuiDataType_Float: c_int = 8;
pub const ImGuiDataType_Double: c_int = 9;
pub const ImGuiDataType_COUNT: c_int = 10;
pub const ImGuiDataType_ = c_uint;
pub const ImGuiDir_None: c_int = -1;
pub const ImGuiDir_Left: c_int = 0;
pub const ImGuiDir_Right: c_int = 1;
pub const ImGuiDir_Up: c_int = 2;
pub const ImGuiDir_Down: c_int = 3;
pub const ImGuiDir_COUNT: c_int = 4;
pub const ImGuiDir_ = c_int;
pub const ImGuiSortDirection_None: c_int = 0;
pub const ImGuiSortDirection_Ascending: c_int = 1;
pub const ImGuiSortDirection_Descending: c_int = 2;
pub const ImGuiSortDirection_ = c_uint;
pub const ImGuiKey_None: c_int = 0;
pub const ImGuiKey_Tab: c_int = 512;
pub const ImGuiKey_LeftArrow: c_int = 513;
pub const ImGuiKey_RightArrow: c_int = 514;
pub const ImGuiKey_UpArrow: c_int = 515;
pub const ImGuiKey_DownArrow: c_int = 516;
pub const ImGuiKey_PageUp: c_int = 517;
pub const ImGuiKey_PageDown: c_int = 518;
pub const ImGuiKey_Home: c_int = 519;
pub const ImGuiKey_End: c_int = 520;
pub const ImGuiKey_Insert: c_int = 521;
pub const ImGuiKey_Delete: c_int = 522;
pub const ImGuiKey_Backspace: c_int = 523;
pub const ImGuiKey_Space: c_int = 524;
pub const ImGuiKey_Enter: c_int = 525;
pub const ImGuiKey_Escape: c_int = 526;
pub const ImGuiKey_LeftCtrl: c_int = 527;
pub const ImGuiKey_LeftShift: c_int = 528;
pub const ImGuiKey_LeftAlt: c_int = 529;
pub const ImGuiKey_LeftSuper: c_int = 530;
pub const ImGuiKey_RightCtrl: c_int = 531;
pub const ImGuiKey_RightShift: c_int = 532;
pub const ImGuiKey_RightAlt: c_int = 533;
pub const ImGuiKey_RightSuper: c_int = 534;
pub const ImGuiKey_Menu: c_int = 535;
pub const ImGuiKey_0: c_int = 536;
pub const ImGuiKey_1: c_int = 537;
pub const ImGuiKey_2: c_int = 538;
pub const ImGuiKey_3: c_int = 539;
pub const ImGuiKey_4: c_int = 540;
pub const ImGuiKey_5: c_int = 541;
pub const ImGuiKey_6: c_int = 542;
pub const ImGuiKey_7: c_int = 543;
pub const ImGuiKey_8: c_int = 544;
pub const ImGuiKey_9: c_int = 545;
pub const ImGuiKey_A: c_int = 546;
pub const ImGuiKey_B: c_int = 547;
pub const ImGuiKey_C: c_int = 548;
pub const ImGuiKey_D: c_int = 549;
pub const ImGuiKey_E: c_int = 550;
pub const ImGuiKey_F: c_int = 551;
pub const ImGuiKey_G: c_int = 552;
pub const ImGuiKey_H: c_int = 553;
pub const ImGuiKey_I: c_int = 554;
pub const ImGuiKey_J: c_int = 555;
pub const ImGuiKey_K: c_int = 556;
pub const ImGuiKey_L: c_int = 557;
pub const ImGuiKey_M: c_int = 558;
pub const ImGuiKey_N: c_int = 559;
pub const ImGuiKey_O: c_int = 560;
pub const ImGuiKey_P: c_int = 561;
pub const ImGuiKey_Q: c_int = 562;
pub const ImGuiKey_R: c_int = 563;
pub const ImGuiKey_S: c_int = 564;
pub const ImGuiKey_T: c_int = 565;
pub const ImGuiKey_U: c_int = 566;
pub const ImGuiKey_V: c_int = 567;
pub const ImGuiKey_W: c_int = 568;
pub const ImGuiKey_X: c_int = 569;
pub const ImGuiKey_Y: c_int = 570;
pub const ImGuiKey_Z: c_int = 571;
pub const ImGuiKey_F1: c_int = 572;
pub const ImGuiKey_F2: c_int = 573;
pub const ImGuiKey_F3: c_int = 574;
pub const ImGuiKey_F4: c_int = 575;
pub const ImGuiKey_F5: c_int = 576;
pub const ImGuiKey_F6: c_int = 577;
pub const ImGuiKey_F7: c_int = 578;
pub const ImGuiKey_F8: c_int = 579;
pub const ImGuiKey_F9: c_int = 580;
pub const ImGuiKey_F10: c_int = 581;
pub const ImGuiKey_F11: c_int = 582;
pub const ImGuiKey_F12: c_int = 583;
pub const ImGuiKey_Apostrophe: c_int = 584;
pub const ImGuiKey_Comma: c_int = 585;
pub const ImGuiKey_Minus: c_int = 586;
pub const ImGuiKey_Period: c_int = 587;
pub const ImGuiKey_Slash: c_int = 588;
pub const ImGuiKey_Semicolon: c_int = 589;
pub const ImGuiKey_Equal: c_int = 590;
pub const ImGuiKey_LeftBracket: c_int = 591;
pub const ImGuiKey_Backslash: c_int = 592;
pub const ImGuiKey_RightBracket: c_int = 593;
pub const ImGuiKey_GraveAccent: c_int = 594;
pub const ImGuiKey_CapsLock: c_int = 595;
pub const ImGuiKey_ScrollLock: c_int = 596;
pub const ImGuiKey_NumLock: c_int = 597;
pub const ImGuiKey_PrintScreen: c_int = 598;
pub const ImGuiKey_Pause: c_int = 599;
pub const ImGuiKey_Keypad0: c_int = 600;
pub const ImGuiKey_Keypad1: c_int = 601;
pub const ImGuiKey_Keypad2: c_int = 602;
pub const ImGuiKey_Keypad3: c_int = 603;
pub const ImGuiKey_Keypad4: c_int = 604;
pub const ImGuiKey_Keypad5: c_int = 605;
pub const ImGuiKey_Keypad6: c_int = 606;
pub const ImGuiKey_Keypad7: c_int = 607;
pub const ImGuiKey_Keypad8: c_int = 608;
pub const ImGuiKey_Keypad9: c_int = 609;
pub const ImGuiKey_KeypadDecimal: c_int = 610;
pub const ImGuiKey_KeypadDivide: c_int = 611;
pub const ImGuiKey_KeypadMultiply: c_int = 612;
pub const ImGuiKey_KeypadSubtract: c_int = 613;
pub const ImGuiKey_KeypadAdd: c_int = 614;
pub const ImGuiKey_KeypadEnter: c_int = 615;
pub const ImGuiKey_KeypadEqual: c_int = 616;
pub const ImGuiKey_GamepadStart: c_int = 617;
pub const ImGuiKey_GamepadBack: c_int = 618;
pub const ImGuiKey_GamepadFaceLeft: c_int = 619;
pub const ImGuiKey_GamepadFaceRight: c_int = 620;
pub const ImGuiKey_GamepadFaceUp: c_int = 621;
pub const ImGuiKey_GamepadFaceDown: c_int = 622;
pub const ImGuiKey_GamepadDpadLeft: c_int = 623;
pub const ImGuiKey_GamepadDpadRight: c_int = 624;
pub const ImGuiKey_GamepadDpadUp: c_int = 625;
pub const ImGuiKey_GamepadDpadDown: c_int = 626;
pub const ImGuiKey_GamepadL1: c_int = 627;
pub const ImGuiKey_GamepadR1: c_int = 628;
pub const ImGuiKey_GamepadL2: c_int = 629;
pub const ImGuiKey_GamepadR2: c_int = 630;
pub const ImGuiKey_GamepadL3: c_int = 631;
pub const ImGuiKey_GamepadR3: c_int = 632;
pub const ImGuiKey_GamepadLStickLeft: c_int = 633;
pub const ImGuiKey_GamepadLStickRight: c_int = 634;
pub const ImGuiKey_GamepadLStickUp: c_int = 635;
pub const ImGuiKey_GamepadLStickDown: c_int = 636;
pub const ImGuiKey_GamepadRStickLeft: c_int = 637;
pub const ImGuiKey_GamepadRStickRight: c_int = 638;
pub const ImGuiKey_GamepadRStickUp: c_int = 639;
pub const ImGuiKey_GamepadRStickDown: c_int = 640;
pub const ImGuiKey_MouseLeft: c_int = 641;
pub const ImGuiKey_MouseRight: c_int = 642;
pub const ImGuiKey_MouseMiddle: c_int = 643;
pub const ImGuiKey_MouseX1: c_int = 644;
pub const ImGuiKey_MouseX2: c_int = 645;
pub const ImGuiKey_MouseWheelX: c_int = 646;
pub const ImGuiKey_MouseWheelY: c_int = 647;
pub const ImGuiKey_ReservedForModCtrl: c_int = 648;
pub const ImGuiKey_ReservedForModShift: c_int = 649;
pub const ImGuiKey_ReservedForModAlt: c_int = 650;
pub const ImGuiKey_ReservedForModSuper: c_int = 651;
pub const ImGuiKey_COUNT: c_int = 652;
pub const ImGuiMod_None: c_int = 0;
pub const ImGuiMod_Ctrl: c_int = 4096;
pub const ImGuiMod_Shift: c_int = 8192;
pub const ImGuiMod_Alt: c_int = 16384;
pub const ImGuiMod_Super: c_int = 32768;
pub const ImGuiMod_Shortcut: c_int = 2048;
pub const ImGuiMod_Mask_: c_int = 63488;
pub const ImGuiKey_NamedKey_BEGIN: c_int = 512;
pub const ImGuiKey_NamedKey_END: c_int = 652;
pub const ImGuiKey_NamedKey_COUNT: c_int = 140;
pub const ImGuiKey_KeysData_SIZE: c_int = 652;
pub const ImGuiKey_KeysData_OFFSET: c_int = 0;
pub const ImGuiKey = c_uint;
pub const ImGuiNavInput_Activate: c_int = 0;
pub const ImGuiNavInput_Cancel: c_int = 1;
pub const ImGuiNavInput_Input: c_int = 2;
pub const ImGuiNavInput_Menu: c_int = 3;
pub const ImGuiNavInput_DpadLeft: c_int = 4;
pub const ImGuiNavInput_DpadRight: c_int = 5;
pub const ImGuiNavInput_DpadUp: c_int = 6;
pub const ImGuiNavInput_DpadDown: c_int = 7;
pub const ImGuiNavInput_LStickLeft: c_int = 8;
pub const ImGuiNavInput_LStickRight: c_int = 9;
pub const ImGuiNavInput_LStickUp: c_int = 10;
pub const ImGuiNavInput_LStickDown: c_int = 11;
pub const ImGuiNavInput_FocusPrev: c_int = 12;
pub const ImGuiNavInput_FocusNext: c_int = 13;
pub const ImGuiNavInput_TweakSlow: c_int = 14;
pub const ImGuiNavInput_TweakFast: c_int = 15;
pub const ImGuiNavInput_COUNT: c_int = 16;
pub const ImGuiNavInput = c_uint;
pub const ImGuiConfigFlags_None: c_int = 0;
pub const ImGuiConfigFlags_NavEnableKeyboard: c_int = 1;
pub const ImGuiConfigFlags_NavEnableGamepad: c_int = 2;
pub const ImGuiConfigFlags_NavEnableSetMousePos: c_int = 4;
pub const ImGuiConfigFlags_NavNoCaptureKeyboard: c_int = 8;
pub const ImGuiConfigFlags_NoMouse: c_int = 16;
pub const ImGuiConfigFlags_NoMouseCursorChange: c_int = 32;
pub const ImGuiConfigFlags_DockingEnable: c_int = 64;
pub const ImGuiConfigFlags_ViewportsEnable: c_int = 1024;
pub const ImGuiConfigFlags_DpiEnableScaleViewports: c_int = 16384;
pub const ImGuiConfigFlags_DpiEnableScaleFonts: c_int = 32768;
pub const ImGuiConfigFlags_IsSRGB: c_int = 1048576;
pub const ImGuiConfigFlags_IsTouchScreen: c_int = 2097152;
pub const ImGuiConfigFlags_ = c_uint;
pub const ImGuiBackendFlags_None: c_int = 0;
pub const ImGuiBackendFlags_HasGamepad: c_int = 1;
pub const ImGuiBackendFlags_HasMouseCursors: c_int = 2;
pub const ImGuiBackendFlags_HasSetMousePos: c_int = 4;
pub const ImGuiBackendFlags_RendererHasVtxOffset: c_int = 8;
pub const ImGuiBackendFlags_PlatformHasViewports: c_int = 1024;
pub const ImGuiBackendFlags_HasMouseHoveredViewport: c_int = 2048;
pub const ImGuiBackendFlags_RendererHasViewports: c_int = 4096;
pub const ImGuiBackendFlags_ = c_uint;
pub const ImGuiCol_Text: c_int = 0;
pub const ImGuiCol_TextDisabled: c_int = 1;
pub const ImGuiCol_WindowBg: c_int = 2;
pub const ImGuiCol_ChildBg: c_int = 3;
pub const ImGuiCol_PopupBg: c_int = 4;
pub const ImGuiCol_Border: c_int = 5;
pub const ImGuiCol_BorderShadow: c_int = 6;
pub const ImGuiCol_FrameBg: c_int = 7;
pub const ImGuiCol_FrameBgHovered: c_int = 8;
pub const ImGuiCol_FrameBgActive: c_int = 9;
pub const ImGuiCol_TitleBg: c_int = 10;
pub const ImGuiCol_TitleBgActive: c_int = 11;
pub const ImGuiCol_TitleBgCollapsed: c_int = 12;
pub const ImGuiCol_MenuBarBg: c_int = 13;
pub const ImGuiCol_ScrollbarBg: c_int = 14;
pub const ImGuiCol_ScrollbarGrab: c_int = 15;
pub const ImGuiCol_ScrollbarGrabHovered: c_int = 16;
pub const ImGuiCol_ScrollbarGrabActive: c_int = 17;
pub const ImGuiCol_CheckMark: c_int = 18;
pub const ImGuiCol_SliderGrab: c_int = 19;
pub const ImGuiCol_SliderGrabActive: c_int = 20;
pub const ImGuiCol_Button: c_int = 21;
pub const ImGuiCol_ButtonHovered: c_int = 22;
pub const ImGuiCol_ButtonActive: c_int = 23;
pub const ImGuiCol_Header: c_int = 24;
pub const ImGuiCol_HeaderHovered: c_int = 25;
pub const ImGuiCol_HeaderActive: c_int = 26;
pub const ImGuiCol_Separator: c_int = 27;
pub const ImGuiCol_SeparatorHovered: c_int = 28;
pub const ImGuiCol_SeparatorActive: c_int = 29;
pub const ImGuiCol_ResizeGrip: c_int = 30;
pub const ImGuiCol_ResizeGripHovered: c_int = 31;
pub const ImGuiCol_ResizeGripActive: c_int = 32;
pub const ImGuiCol_Tab: c_int = 33;
pub const ImGuiCol_TabHovered: c_int = 34;
pub const ImGuiCol_TabActive: c_int = 35;
pub const ImGuiCol_TabUnfocused: c_int = 36;
pub const ImGuiCol_TabUnfocusedActive: c_int = 37;
pub const ImGuiCol_DockingPreview: c_int = 38;
pub const ImGuiCol_DockingEmptyBg: c_int = 39;
pub const ImGuiCol_PlotLines: c_int = 40;
pub const ImGuiCol_PlotLinesHovered: c_int = 41;
pub const ImGuiCol_PlotHistogram: c_int = 42;
pub const ImGuiCol_PlotHistogramHovered: c_int = 43;
pub const ImGuiCol_TableHeaderBg: c_int = 44;
pub const ImGuiCol_TableBorderStrong: c_int = 45;
pub const ImGuiCol_TableBorderLight: c_int = 46;
pub const ImGuiCol_TableRowBg: c_int = 47;
pub const ImGuiCol_TableRowBgAlt: c_int = 48;
pub const ImGuiCol_TextSelectedBg: c_int = 49;
pub const ImGuiCol_DragDropTarget: c_int = 50;
pub const ImGuiCol_NavHighlight: c_int = 51;
pub const ImGuiCol_NavWindowingHighlight: c_int = 52;
pub const ImGuiCol_NavWindowingDimBg: c_int = 53;
pub const ImGuiCol_ModalWindowDimBg: c_int = 54;
pub const ImGuiCol_COUNT: c_int = 55;
pub const ImGuiCol_ = c_uint;
pub const ImGuiStyleVar_Alpha: c_int = 0;
pub const ImGuiStyleVar_DisabledAlpha: c_int = 1;
pub const ImGuiStyleVar_WindowPadding: c_int = 2;
pub const ImGuiStyleVar_WindowRounding: c_int = 3;
pub const ImGuiStyleVar_WindowBorderSize: c_int = 4;
pub const ImGuiStyleVar_WindowMinSize: c_int = 5;
pub const ImGuiStyleVar_WindowTitleAlign: c_int = 6;
pub const ImGuiStyleVar_ChildRounding: c_int = 7;
pub const ImGuiStyleVar_ChildBorderSize: c_int = 8;
pub const ImGuiStyleVar_PopupRounding: c_int = 9;
pub const ImGuiStyleVar_PopupBorderSize: c_int = 10;
pub const ImGuiStyleVar_FramePadding: c_int = 11;
pub const ImGuiStyleVar_FrameRounding: c_int = 12;
pub const ImGuiStyleVar_FrameBorderSize: c_int = 13;
pub const ImGuiStyleVar_ItemSpacing: c_int = 14;
pub const ImGuiStyleVar_ItemInnerSpacing: c_int = 15;
pub const ImGuiStyleVar_IndentSpacing: c_int = 16;
pub const ImGuiStyleVar_CellPadding: c_int = 17;
pub const ImGuiStyleVar_ScrollbarSize: c_int = 18;
pub const ImGuiStyleVar_ScrollbarRounding: c_int = 19;
pub const ImGuiStyleVar_GrabMinSize: c_int = 20;
pub const ImGuiStyleVar_GrabRounding: c_int = 21;
pub const ImGuiStyleVar_TabRounding: c_int = 22;
pub const ImGuiStyleVar_ButtonTextAlign: c_int = 23;
pub const ImGuiStyleVar_SelectableTextAlign: c_int = 24;
pub const ImGuiStyleVar_SeparatorTextBorderSize: c_int = 25;
pub const ImGuiStyleVar_SeparatorTextAlign: c_int = 26;
pub const ImGuiStyleVar_SeparatorTextPadding: c_int = 27;
pub const ImGuiStyleVar_DockingSeparatorSize: c_int = 28;
pub const ImGuiStyleVar_COUNT: c_int = 29;
pub const ImGuiStyleVar_ = c_uint;
pub const ImGuiButtonFlags_None: c_int = 0;
pub const ImGuiButtonFlags_MouseButtonLeft: c_int = 1;
pub const ImGuiButtonFlags_MouseButtonRight: c_int = 2;
pub const ImGuiButtonFlags_MouseButtonMiddle: c_int = 4;
pub const ImGuiButtonFlags_MouseButtonMask_: c_int = 7;
pub const ImGuiButtonFlags_MouseButtonDefault_: c_int = 1;
pub const ImGuiButtonFlags_ = c_uint;
pub const ImGuiColorEditFlags_None: c_int = 0;
pub const ImGuiColorEditFlags_NoAlpha: c_int = 2;
pub const ImGuiColorEditFlags_NoPicker: c_int = 4;
pub const ImGuiColorEditFlags_NoOptions: c_int = 8;
pub const ImGuiColorEditFlags_NoSmallPreview: c_int = 16;
pub const ImGuiColorEditFlags_NoInputs: c_int = 32;
pub const ImGuiColorEditFlags_NoTooltip: c_int = 64;
pub const ImGuiColorEditFlags_NoLabel: c_int = 128;
pub const ImGuiColorEditFlags_NoSidePreview: c_int = 256;
pub const ImGuiColorEditFlags_NoDragDrop: c_int = 512;
pub const ImGuiColorEditFlags_NoBorder: c_int = 1024;
pub const ImGuiColorEditFlags_AlphaBar: c_int = 65536;
pub const ImGuiColorEditFlags_AlphaPreview: c_int = 131072;
pub const ImGuiColorEditFlags_AlphaPreviewHalf: c_int = 262144;
pub const ImGuiColorEditFlags_HDR: c_int = 524288;
pub const ImGuiColorEditFlags_DisplayRGB: c_int = 1048576;
pub const ImGuiColorEditFlags_DisplayHSV: c_int = 2097152;
pub const ImGuiColorEditFlags_DisplayHex: c_int = 4194304;
pub const ImGuiColorEditFlags_Uint8: c_int = 8388608;
pub const ImGuiColorEditFlags_Float: c_int = 16777216;
pub const ImGuiColorEditFlags_PickerHueBar: c_int = 33554432;
pub const ImGuiColorEditFlags_PickerHueWheel: c_int = 67108864;
pub const ImGuiColorEditFlags_InputRGB: c_int = 134217728;
pub const ImGuiColorEditFlags_InputHSV: c_int = 268435456;
pub const ImGuiColorEditFlags_DefaultOptions_: c_int = 177209344;
pub const ImGuiColorEditFlags_DisplayMask_: c_int = 7340032;
pub const ImGuiColorEditFlags_DataTypeMask_: c_int = 25165824;
pub const ImGuiColorEditFlags_PickerMask_: c_int = 100663296;
pub const ImGuiColorEditFlags_InputMask_: c_int = 402653184;
pub const ImGuiColorEditFlags_ = c_uint;
pub const ImGuiSliderFlags_None: c_int = 0;
pub const ImGuiSliderFlags_AlwaysClamp: c_int = 16;
pub const ImGuiSliderFlags_Logarithmic: c_int = 32;
pub const ImGuiSliderFlags_NoRoundToFormat: c_int = 64;
pub const ImGuiSliderFlags_NoInput: c_int = 128;
pub const ImGuiSliderFlags_InvalidMask_: c_int = 1879048207;
pub const ImGuiSliderFlags_ = c_uint;
pub const ImGuiMouseButton_Left: c_int = 0;
pub const ImGuiMouseButton_Right: c_int = 1;
pub const ImGuiMouseButton_Middle: c_int = 2;
pub const ImGuiMouseButton_COUNT: c_int = 5;
pub const ImGuiMouseButton_ = c_uint;
pub const ImGuiMouseCursor_None: c_int = -1;
pub const ImGuiMouseCursor_Arrow: c_int = 0;
pub const ImGuiMouseCursor_TextInput: c_int = 1;
pub const ImGuiMouseCursor_ResizeAll: c_int = 2;
pub const ImGuiMouseCursor_ResizeNS: c_int = 3;
pub const ImGuiMouseCursor_ResizeEW: c_int = 4;
pub const ImGuiMouseCursor_ResizeNESW: c_int = 5;
pub const ImGuiMouseCursor_ResizeNWSE: c_int = 6;
pub const ImGuiMouseCursor_Hand: c_int = 7;
pub const ImGuiMouseCursor_NotAllowed: c_int = 8;
pub const ImGuiMouseCursor_COUNT: c_int = 9;
pub const ImGuiMouseCursor_ = c_int;
pub const ImGuiMouseSource_Mouse: c_int = 0;
pub const ImGuiMouseSource_TouchScreen: c_int = 1;
pub const ImGuiMouseSource_Pen: c_int = 2;
pub const ImGuiMouseSource_COUNT: c_int = 3;
pub const ImGuiMouseSource = c_uint;
pub const ImGuiCond_None: c_int = 0;
pub const ImGuiCond_Always: c_int = 1;
pub const ImGuiCond_Once: c_int = 2;
pub const ImGuiCond_FirstUseEver: c_int = 4;
pub const ImGuiCond_Appearing: c_int = 8;
pub const ImGuiCond_ = c_uint;
pub const ImDrawFlags_None: c_int = 0;
pub const ImDrawFlags_Closed: c_int = 1;
pub const ImDrawFlags_RoundCornersTopLeft: c_int = 16;
pub const ImDrawFlags_RoundCornersTopRight: c_int = 32;
pub const ImDrawFlags_RoundCornersBottomLeft: c_int = 64;
pub const ImDrawFlags_RoundCornersBottomRight: c_int = 128;
pub const ImDrawFlags_RoundCornersNone: c_int = 256;
pub const ImDrawFlags_RoundCornersTop: c_int = 48;
pub const ImDrawFlags_RoundCornersBottom: c_int = 192;
pub const ImDrawFlags_RoundCornersLeft: c_int = 80;
pub const ImDrawFlags_RoundCornersRight: c_int = 160;
pub const ImDrawFlags_RoundCornersAll: c_int = 240;
pub const ImDrawFlags_RoundCornersDefault_: c_int = 240;
pub const ImDrawFlags_RoundCornersMask_: c_int = 496;
pub const ImDrawFlags_ = c_uint;
pub const ImDrawListFlags_None: c_int = 0;
pub const ImDrawListFlags_AntiAliasedLines: c_int = 1;
pub const ImDrawListFlags_AntiAliasedLinesUseTex: c_int = 2;
pub const ImDrawListFlags_AntiAliasedFill: c_int = 4;
pub const ImDrawListFlags_AllowVtxOffset: c_int = 8;
pub const ImDrawListFlags_ = c_uint;
pub const ImFontAtlasFlags_None: c_int = 0;
pub const ImFontAtlasFlags_NoPowerOfTwoHeight: c_int = 1;
pub const ImFontAtlasFlags_NoMouseCursors: c_int = 2;
pub const ImFontAtlasFlags_NoBakedLines: c_int = 4;
pub const ImFontAtlasFlags_ = c_uint;
pub const ImGuiViewportFlags_None: c_int = 0;
pub const ImGuiViewportFlags_IsPlatformWindow: c_int = 1;
pub const ImGuiViewportFlags_IsPlatformMonitor: c_int = 2;
pub const ImGuiViewportFlags_OwnedByApp: c_int = 4;
pub const ImGuiViewportFlags_NoDecoration: c_int = 8;
pub const ImGuiViewportFlags_NoTaskBarIcon: c_int = 16;
pub const ImGuiViewportFlags_NoFocusOnAppearing: c_int = 32;
pub const ImGuiViewportFlags_NoFocusOnClick: c_int = 64;
pub const ImGuiViewportFlags_NoInputs: c_int = 128;
pub const ImGuiViewportFlags_NoRendererClear: c_int = 256;
pub const ImGuiViewportFlags_NoAutoMerge: c_int = 512;
pub const ImGuiViewportFlags_TopMost: c_int = 1024;
pub const ImGuiViewportFlags_CanHostOtherWindows: c_int = 2048;
pub const ImGuiViewportFlags_IsMinimized: c_int = 4096;
pub const ImGuiViewportFlags_IsFocused: c_int = 8192;
pub const ImGuiViewportFlags_ = c_uint;
pub const ImGuiDataAuthority = c_int;
pub const ImGuiFocusRequestFlags = c_int;
pub const ImGuiInputFlags = c_int;
pub const ImGuiNavHighlightFlags = c_int;
pub const ImGuiSeparatorFlags = c_int;
pub const ImGuiTextFlags = c_int;
pub const ImGuiTooltipFlags = c_int;
pub const ImGuiErrorLogCallback = ?*const fn (?*anyopaque, [*c]const u8, ...) callconv(.C) void;
pub extern var GImGui: [*c]ImGuiContext;
pub const struct_StbTexteditRow = extern struct {
    x0: f32,
    x1: f32,
    baseline_y_delta: f32,
    ymin: f32,
    ymax: f32,
    num_chars: c_int,
};
pub const StbTexteditRow = struct_StbTexteditRow;
pub const ImGuiItemFlags_None: c_int = 0;
pub const ImGuiItemFlags_NoTabStop: c_int = 1;
pub const ImGuiItemFlags_ButtonRepeat: c_int = 2;
pub const ImGuiItemFlags_Disabled: c_int = 4;
pub const ImGuiItemFlags_NoNav: c_int = 8;
pub const ImGuiItemFlags_NoNavDefaultFocus: c_int = 16;
pub const ImGuiItemFlags_SelectableDontClosePopup: c_int = 32;
pub const ImGuiItemFlags_MixedValue: c_int = 64;
pub const ImGuiItemFlags_ReadOnly: c_int = 128;
pub const ImGuiItemFlags_NoWindowHoverableCheck: c_int = 256;
pub const ImGuiItemFlags_AllowOverlap: c_int = 512;
pub const ImGuiItemFlags_Inputable: c_int = 1024;
pub const ImGuiItemFlags_ = c_uint;
pub const ImGuiItemStatusFlags_None: c_int = 0;
pub const ImGuiItemStatusFlags_HoveredRect: c_int = 1;
pub const ImGuiItemStatusFlags_HasDisplayRect: c_int = 2;
pub const ImGuiItemStatusFlags_Edited: c_int = 4;
pub const ImGuiItemStatusFlags_ToggledSelection: c_int = 8;
pub const ImGuiItemStatusFlags_ToggledOpen: c_int = 16;
pub const ImGuiItemStatusFlags_HasDeactivated: c_int = 32;
pub const ImGuiItemStatusFlags_Deactivated: c_int = 64;
pub const ImGuiItemStatusFlags_HoveredWindow: c_int = 128;
pub const ImGuiItemStatusFlags_FocusedByTabbing: c_int = 256;
pub const ImGuiItemStatusFlags_Visible: c_int = 512;
pub const ImGuiItemStatusFlags_ = c_uint;
pub const ImGuiHoveredFlags_DelayMask_: c_int = 245760;
pub const ImGuiHoveredFlags_AllowedMaskForIsWindowHovered: c_int = 12479;
pub const ImGuiHoveredFlags_AllowedMaskForIsItemHovered: c_int = 262048;
pub const ImGuiHoveredFlagsPrivate_ = c_uint;
pub const ImGuiInputTextFlags_Multiline: c_int = 67108864;
pub const ImGuiInputTextFlags_NoMarkEdited: c_int = 134217728;
pub const ImGuiInputTextFlags_MergedItem: c_int = 268435456;
pub const ImGuiInputTextFlagsPrivate_ = c_uint;
pub const ImGuiButtonFlags_PressedOnClick: c_int = 16;
pub const ImGuiButtonFlags_PressedOnClickRelease: c_int = 32;
pub const ImGuiButtonFlags_PressedOnClickReleaseAnywhere: c_int = 64;
pub const ImGuiButtonFlags_PressedOnRelease: c_int = 128;
pub const ImGuiButtonFlags_PressedOnDoubleClick: c_int = 256;
pub const ImGuiButtonFlags_PressedOnDragDropHold: c_int = 512;
pub const ImGuiButtonFlags_Repeat: c_int = 1024;
pub const ImGuiButtonFlags_FlattenChildren: c_int = 2048;
pub const ImGuiButtonFlags_AllowOverlap: c_int = 4096;
pub const ImGuiButtonFlags_DontClosePopups: c_int = 8192;
pub const ImGuiButtonFlags_AlignTextBaseLine: c_int = 32768;
pub const ImGuiButtonFlags_NoKeyModifiers: c_int = 65536;
pub const ImGuiButtonFlags_NoHoldingActiveId: c_int = 131072;
pub const ImGuiButtonFlags_NoNavFocus: c_int = 262144;
pub const ImGuiButtonFlags_NoHoveredOnFocus: c_int = 524288;
pub const ImGuiButtonFlags_NoSetKeyOwner: c_int = 1048576;
pub const ImGuiButtonFlags_NoTestKeyOwner: c_int = 2097152;
pub const ImGuiButtonFlags_PressedOnMask_: c_int = 1008;
pub const ImGuiButtonFlags_PressedOnDefault_: c_int = 32;
pub const ImGuiButtonFlagsPrivate_ = c_uint;
pub const ImGuiComboFlags_CustomPreview: c_int = 1048576;
pub const ImGuiComboFlagsPrivate_ = c_uint;
pub const ImGuiSliderFlags_Vertical: c_int = 1048576;
pub const ImGuiSliderFlags_ReadOnly: c_int = 2097152;
pub const ImGuiSliderFlagsPrivate_ = c_uint;
pub const ImGuiSelectableFlags_NoHoldingActiveID: c_int = 1048576;
pub const ImGuiSelectableFlags_SelectOnNav: c_int = 2097152;
pub const ImGuiSelectableFlags_SelectOnClick: c_int = 4194304;
pub const ImGuiSelectableFlags_SelectOnRelease: c_int = 8388608;
pub const ImGuiSelectableFlags_SpanAvailWidth: c_int = 16777216;
pub const ImGuiSelectableFlags_SetNavIdOnHover: c_int = 33554432;
pub const ImGuiSelectableFlags_NoPadWithHalfSpacing: c_int = 67108864;
pub const ImGuiSelectableFlags_NoSetKeyOwner: c_int = 134217728;
pub const ImGuiSelectableFlagsPrivate_ = c_uint;
pub const ImGuiTreeNodeFlags_ClipLabelForTrailingButton: c_int = 1048576;
pub const ImGuiTreeNodeFlags_UpsideDownArrow: c_int = 2097152;
pub const ImGuiTreeNodeFlagsPrivate_ = c_uint;
pub const ImGuiSeparatorFlags_None: c_int = 0;
pub const ImGuiSeparatorFlags_Horizontal: c_int = 1;
pub const ImGuiSeparatorFlags_Vertical: c_int = 2;
pub const ImGuiSeparatorFlags_SpanAllColumns: c_int = 4;
pub const ImGuiSeparatorFlags_ = c_uint;
pub const ImGuiFocusRequestFlags_None: c_int = 0;
pub const ImGuiFocusRequestFlags_RestoreFocusedChild: c_int = 1;
pub const ImGuiFocusRequestFlags_UnlessBelowModal: c_int = 2;
pub const ImGuiFocusRequestFlags_ = c_uint;
pub const ImGuiTextFlags_None: c_int = 0;
pub const ImGuiTextFlags_NoWidthForLargeClippedText: c_int = 1;
pub const ImGuiTextFlags_ = c_uint;
pub const ImGuiTooltipFlags_None: c_int = 0;
pub const ImGuiTooltipFlags_OverridePrevious: c_int = 2;
pub const ImGuiTooltipFlags_ = c_uint;
pub const ImGuiLayoutType_Horizontal: c_int = 0;
pub const ImGuiLayoutType_Vertical: c_int = 1;
pub const ImGuiLayoutType_ = c_uint;
pub const ImGuiLogType_None: c_int = 0;
pub const ImGuiLogType_TTY: c_int = 1;
pub const ImGuiLogType_File: c_int = 2;
pub const ImGuiLogType_Buffer: c_int = 3;
pub const ImGuiLogType_Clipboard: c_int = 4;
pub const ImGuiLogType = c_uint;
pub const ImGuiAxis_None: c_int = -1;
pub const ImGuiAxis_X: c_int = 0;
pub const ImGuiAxis_Y: c_int = 1;
pub const ImGuiAxis = c_int;
pub const ImGuiPlotType_Lines: c_int = 0;
pub const ImGuiPlotType_Histogram: c_int = 1;
pub const ImGuiPlotType = c_uint;
pub const ImGuiPopupPositionPolicy_Default: c_int = 0;
pub const ImGuiPopupPositionPolicy_ComboBox: c_int = 1;
pub const ImGuiPopupPositionPolicy_Tooltip: c_int = 2;
pub const ImGuiPopupPositionPolicy = c_uint;
pub const struct_ImGuiDataTypeTempStorage = extern struct {
    Data: [8]ImU8,
};
pub const ImGuiDataTypeTempStorage = struct_ImGuiDataTypeTempStorage;
pub const ImGuiDataType_String: c_int = 11;
pub const ImGuiDataType_Pointer: c_int = 12;
pub const ImGuiDataType_ID: c_int = 13;
pub const ImGuiDataTypePrivate_ = c_uint;
pub const ImGuiNextWindowDataFlags_None: c_int = 0;
pub const ImGuiNextWindowDataFlags_HasPos: c_int = 1;
pub const ImGuiNextWindowDataFlags_HasSize: c_int = 2;
pub const ImGuiNextWindowDataFlags_HasContentSize: c_int = 4;
pub const ImGuiNextWindowDataFlags_HasCollapsed: c_int = 8;
pub const ImGuiNextWindowDataFlags_HasSizeConstraint: c_int = 16;
pub const ImGuiNextWindowDataFlags_HasFocus: c_int = 32;
pub const ImGuiNextWindowDataFlags_HasBgAlpha: c_int = 64;
pub const ImGuiNextWindowDataFlags_HasScroll: c_int = 128;
pub const ImGuiNextWindowDataFlags_HasViewport: c_int = 256;
pub const ImGuiNextWindowDataFlags_HasDock: c_int = 512;
pub const ImGuiNextWindowDataFlags_HasWindowClass: c_int = 1024;
pub const ImGuiNextWindowDataFlags_ = c_uint;
pub const ImGuiNextItemDataFlags_None: c_int = 0;
pub const ImGuiNextItemDataFlags_HasWidth: c_int = 1;
pub const ImGuiNextItemDataFlags_HasOpen: c_int = 2;
pub const ImGuiNextItemDataFlags_ = c_uint;
pub const struct_ImBitArray_ImGuiKey_NamedKey_COUNT__lessImGuiKey_NamedKey_BEGIN = extern struct {
    Storage: [5]ImU32,
};
pub const ImBitArray_ImGuiKey_NamedKey_COUNT__lessImGuiKey_NamedKey_BEGIN = struct_ImBitArray_ImGuiKey_NamedKey_COUNT__lessImGuiKey_NamedKey_BEGIN;
pub const ImBitArrayForNamedKeys = ImBitArray_ImGuiKey_NamedKey_COUNT__lessImGuiKey_NamedKey_BEGIN;
pub const ImGuiInputEventType_None: c_int = 0;
pub const ImGuiInputEventType_MousePos: c_int = 1;
pub const ImGuiInputEventType_MouseWheel: c_int = 2;
pub const ImGuiInputEventType_MouseButton: c_int = 3;
pub const ImGuiInputEventType_MouseViewport: c_int = 4;
pub const ImGuiInputEventType_Key: c_int = 5;
pub const ImGuiInputEventType_Text: c_int = 6;
pub const ImGuiInputEventType_Focus: c_int = 7;
pub const ImGuiInputEventType_COUNT: c_int = 8;
pub const ImGuiInputEventType = c_uint;
pub const ImGuiInputSource_None: c_int = 0;
pub const ImGuiInputSource_Mouse: c_int = 1;
pub const ImGuiInputSource_Keyboard: c_int = 2;
pub const ImGuiInputSource_Gamepad: c_int = 3;
pub const ImGuiInputSource_Clipboard: c_int = 4;
pub const ImGuiInputSource_COUNT: c_int = 5;
pub const ImGuiInputSource = c_uint;
pub const ImGuiInputFlags_None: c_int = 0;
pub const ImGuiInputFlags_Repeat: c_int = 1;
pub const ImGuiInputFlags_RepeatRateDefault: c_int = 2;
pub const ImGuiInputFlags_RepeatRateNavMove: c_int = 4;
pub const ImGuiInputFlags_RepeatRateNavTweak: c_int = 8;
pub const ImGuiInputFlags_RepeatRateMask_: c_int = 14;
pub const ImGuiInputFlags_CondHovered: c_int = 16;
pub const ImGuiInputFlags_CondActive: c_int = 32;
pub const ImGuiInputFlags_CondDefault_: c_int = 48;
pub const ImGuiInputFlags_CondMask_: c_int = 48;
pub const ImGuiInputFlags_LockThisFrame: c_int = 64;
pub const ImGuiInputFlags_LockUntilRelease: c_int = 128;
pub const ImGuiInputFlags_RouteFocused: c_int = 256;
pub const ImGuiInputFlags_RouteGlobalLow: c_int = 512;
pub const ImGuiInputFlags_RouteGlobal: c_int = 1024;
pub const ImGuiInputFlags_RouteGlobalHigh: c_int = 2048;
pub const ImGuiInputFlags_RouteMask_: c_int = 3840;
pub const ImGuiInputFlags_RouteAlways: c_int = 4096;
pub const ImGuiInputFlags_RouteUnlessBgFocused: c_int = 8192;
pub const ImGuiInputFlags_RouteExtraMask_: c_int = 12288;
pub const ImGuiInputFlags_SupportedByIsKeyPressed: c_int = 15;
pub const ImGuiInputFlags_SupportedByShortcut: c_int = 16143;
pub const ImGuiInputFlags_SupportedBySetKeyOwner: c_int = 192;
pub const ImGuiInputFlags_SupportedBySetItemKeyOwner: c_int = 240;
pub const ImGuiInputFlags_ = c_uint;
pub const ImGuiActivateFlags_None: c_int = 0;
pub const ImGuiActivateFlags_PreferInput: c_int = 1;
pub const ImGuiActivateFlags_PreferTweak: c_int = 2;
pub const ImGuiActivateFlags_TryToPreserveState: c_int = 4;
pub const ImGuiActivateFlags_ = c_uint;
pub const ImGuiScrollFlags_None: c_int = 0;
pub const ImGuiScrollFlags_KeepVisibleEdgeX: c_int = 1;
pub const ImGuiScrollFlags_KeepVisibleEdgeY: c_int = 2;
pub const ImGuiScrollFlags_KeepVisibleCenterX: c_int = 4;
pub const ImGuiScrollFlags_KeepVisibleCenterY: c_int = 8;
pub const ImGuiScrollFlags_AlwaysCenterX: c_int = 16;
pub const ImGuiScrollFlags_AlwaysCenterY: c_int = 32;
pub const ImGuiScrollFlags_NoScrollParent: c_int = 64;
pub const ImGuiScrollFlags_MaskX_: c_int = 21;
pub const ImGuiScrollFlags_MaskY_: c_int = 42;
pub const ImGuiScrollFlags_ = c_uint;
pub const ImGuiNavHighlightFlags_None: c_int = 0;
pub const ImGuiNavHighlightFlags_TypeDefault: c_int = 1;
pub const ImGuiNavHighlightFlags_TypeThin: c_int = 2;
pub const ImGuiNavHighlightFlags_AlwaysDraw: c_int = 4;
pub const ImGuiNavHighlightFlags_NoRounding: c_int = 8;
pub const ImGuiNavHighlightFlags_ = c_uint;
pub const ImGuiNavMoveFlags_None: c_int = 0;
pub const ImGuiNavMoveFlags_LoopX: c_int = 1;
pub const ImGuiNavMoveFlags_LoopY: c_int = 2;
pub const ImGuiNavMoveFlags_WrapX: c_int = 4;
pub const ImGuiNavMoveFlags_WrapY: c_int = 8;
pub const ImGuiNavMoveFlags_WrapMask_: c_int = 15;
pub const ImGuiNavMoveFlags_AllowCurrentNavId: c_int = 16;
pub const ImGuiNavMoveFlags_AlsoScoreVisibleSet: c_int = 32;
pub const ImGuiNavMoveFlags_ScrollToEdgeY: c_int = 64;
pub const ImGuiNavMoveFlags_Forwarded: c_int = 128;
pub const ImGuiNavMoveFlags_DebugNoResult: c_int = 256;
pub const ImGuiNavMoveFlags_FocusApi: c_int = 512;
pub const ImGuiNavMoveFlags_IsTabbing: c_int = 1024;
pub const ImGuiNavMoveFlags_IsPageMove: c_int = 2048;
pub const ImGuiNavMoveFlags_Activate: c_int = 4096;
pub const ImGuiNavMoveFlags_NoSelect: c_int = 8192;
pub const ImGuiNavMoveFlags_NoSetNavHighlight: c_int = 16384;
pub const ImGuiNavMoveFlags_ = c_uint;
pub const ImGuiNavLayer_Main: c_int = 0;
pub const ImGuiNavLayer_Menu: c_int = 1;
pub const ImGuiNavLayer_COUNT: c_int = 2;
pub const ImGuiNavLayer = c_uint;
pub const ImGuiOldColumnFlags_None: c_int = 0;
pub const ImGuiOldColumnFlags_NoBorder: c_int = 1;
pub const ImGuiOldColumnFlags_NoResize: c_int = 2;
pub const ImGuiOldColumnFlags_NoPreserveWidths: c_int = 4;
pub const ImGuiOldColumnFlags_NoForceWithinWindow: c_int = 8;
pub const ImGuiOldColumnFlags_GrowParentContentsSize: c_int = 16;
pub const ImGuiOldColumnFlags_ = c_uint;
pub const ImGuiDockNodeFlags_DockSpace: c_int = 1024;
pub const ImGuiDockNodeFlags_CentralNode: c_int = 2048;
pub const ImGuiDockNodeFlags_NoTabBar: c_int = 4096;
pub const ImGuiDockNodeFlags_HiddenTabBar: c_int = 8192;
pub const ImGuiDockNodeFlags_NoWindowMenuButton: c_int = 16384;
pub const ImGuiDockNodeFlags_NoCloseButton: c_int = 32768;
pub const ImGuiDockNodeFlags_NoDocking: c_int = 65536;
pub const ImGuiDockNodeFlags_NoDockingSplitMe: c_int = 131072;
pub const ImGuiDockNodeFlags_NoDockingSplitOther: c_int = 262144;
pub const ImGuiDockNodeFlags_NoDockingOverMe: c_int = 524288;
pub const ImGuiDockNodeFlags_NoDockingOverOther: c_int = 1048576;
pub const ImGuiDockNodeFlags_NoDockingOverEmpty: c_int = 2097152;
pub const ImGuiDockNodeFlags_NoResizeX: c_int = 4194304;
pub const ImGuiDockNodeFlags_NoResizeY: c_int = 8388608;
pub const ImGuiDockNodeFlags_SharedFlagsInheritMask_: c_int = -1;
pub const ImGuiDockNodeFlags_NoResizeFlagsMask_: c_int = 12582944;
pub const ImGuiDockNodeFlags_LocalFlagsMask_: c_int = 12713072;
pub const ImGuiDockNodeFlags_LocalFlagsTransferMask_: c_int = 12712048;
pub const ImGuiDockNodeFlags_SavedFlagsMask_: c_int = 12712992;
pub const ImGuiDockNodeFlagsPrivate_ = c_int;
pub const ImGuiDataAuthority_Auto: c_int = 0;
pub const ImGuiDataAuthority_DockNode: c_int = 1;
pub const ImGuiDataAuthority_Window: c_int = 2;
pub const ImGuiDataAuthority_ = c_uint;
pub const ImGuiDockNodeState_Unknown: c_int = 0;
pub const ImGuiDockNodeState_HostWindowHiddenBecauseSingleWindow: c_int = 1;
pub const ImGuiDockNodeState_HostWindowHiddenBecauseWindowsAreResizing: c_int = 2;
pub const ImGuiDockNodeState_HostWindowVisible: c_int = 3;
pub const ImGuiDockNodeState = c_uint;
pub const ImGuiWindowDockStyleCol_Text: c_int = 0;
pub const ImGuiWindowDockStyleCol_Tab: c_int = 1;
pub const ImGuiWindowDockStyleCol_TabHovered: c_int = 2;
pub const ImGuiWindowDockStyleCol_TabActive: c_int = 3;
pub const ImGuiWindowDockStyleCol_TabUnfocused: c_int = 4;
pub const ImGuiWindowDockStyleCol_TabUnfocusedActive: c_int = 5;
pub const ImGuiWindowDockStyleCol_COUNT: c_int = 6;
pub const ImGuiWindowDockStyleCol = c_uint;
pub const struct_ImGuiWindowDockStyle = extern struct {
    Colors: [6]ImU32,
};
pub const ImGuiWindowDockStyle = struct_ImGuiWindowDockStyle;
pub const ImGuiLocKey_VersionStr: c_int = 0;
pub const ImGuiLocKey_TableSizeOne: c_int = 1;
pub const ImGuiLocKey_TableSizeAllFit: c_int = 2;
pub const ImGuiLocKey_TableSizeAllDefault: c_int = 3;
pub const ImGuiLocKey_TableResetOrder: c_int = 4;
pub const ImGuiLocKey_WindowingMainMenuBar: c_int = 5;
pub const ImGuiLocKey_WindowingPopup: c_int = 6;
pub const ImGuiLocKey_WindowingUntitled: c_int = 7;
pub const ImGuiLocKey_DockingHideTabBar: c_int = 8;
pub const ImGuiLocKey_DockingHoldShiftToDock: c_int = 9;
pub const ImGuiLocKey_COUNT: c_int = 10;
pub const ImGuiLocKey = c_uint;
pub const ImGuiDebugLogFlags_None: c_int = 0;
pub const ImGuiDebugLogFlags_EventActiveId: c_int = 1;
pub const ImGuiDebugLogFlags_EventFocus: c_int = 2;
pub const ImGuiDebugLogFlags_EventPopup: c_int = 4;
pub const ImGuiDebugLogFlags_EventNav: c_int = 8;
pub const ImGuiDebugLogFlags_EventClipper: c_int = 16;
pub const ImGuiDebugLogFlags_EventSelection: c_int = 32;
pub const ImGuiDebugLogFlags_EventIO: c_int = 64;
pub const ImGuiDebugLogFlags_EventDocking: c_int = 128;
pub const ImGuiDebugLogFlags_EventViewport: c_int = 256;
pub const ImGuiDebugLogFlags_EventMask_: c_int = 511;
pub const ImGuiDebugLogFlags_OutputToTTY: c_int = 1024;
pub const ImGuiDebugLogFlags_ = c_uint;
pub const ImGuiContextHookType_NewFramePre: c_int = 0;
pub const ImGuiContextHookType_NewFramePost: c_int = 1;
pub const ImGuiContextHookType_EndFramePre: c_int = 2;
pub const ImGuiContextHookType_EndFramePost: c_int = 3;
pub const ImGuiContextHookType_RenderPre: c_int = 4;
pub const ImGuiContextHookType_RenderPost: c_int = 5;
pub const ImGuiContextHookType_Shutdown: c_int = 6;
pub const ImGuiContextHookType_PendingRemoval_: c_int = 7;
pub const ImGuiContextHookType = c_uint;
pub const struct_ImVector_ImGuiOldColumns = extern struct {
    Size: c_int,
    Capacity: c_int,
    Data: [*c]ImGuiOldColumns,
};
pub const ImVector_ImGuiOldColumns = struct_ImVector_ImGuiOldColumns;
pub const ImGuiTabBarFlags_DockNode: c_int = 1048576;
pub const ImGuiTabBarFlags_IsFocused: c_int = 2097152;
pub const ImGuiTabBarFlags_SaveSettings: c_int = 4194304;
pub const ImGuiTabBarFlagsPrivate_ = c_uint;
pub const ImGuiTabItemFlags_SectionMask_: c_int = 192;
pub const ImGuiTabItemFlags_NoCloseButton: c_int = 1048576;
pub const ImGuiTabItemFlags_Button: c_int = 2097152;
pub const ImGuiTabItemFlags_Unsorted: c_int = 4194304;
pub const ImGuiTabItemFlags_Preview: c_int = 8388608;
pub const ImGuiTabItemFlagsPrivate_ = c_uint;
pub const struct_ImVector_ImGuiTableInstanceData = extern struct {
    Size: c_int,
    Capacity: c_int,
    Data: [*c]ImGuiTableInstanceData,
};
pub const ImVector_ImGuiTableInstanceData = struct_ImVector_ImGuiTableInstanceData;
pub const struct_ImVector_ImGuiTableColumnSortSpecs = extern struct {
    Size: c_int,
    Capacity: c_int,
    Data: ?*ImGuiTableColumnSortSpecs,
};
pub const ImVector_ImGuiTableColumnSortSpecs = struct_ImVector_ImGuiTableColumnSortSpecs; // cimgui.h:3107:10: warning: struct demoted to opaque type - has bitfield
pub const struct_ImGuiTableColumnSettings = opaque {};
pub const ImGuiTableColumnSettings = struct_ImGuiTableColumnSettings;
pub extern fn ImVec2_ImVec2_Nil() [*c]ImVec2;
pub extern fn ImVec2_destroy(self: [*c]ImVec2) void;
pub extern fn ImVec2_ImVec2_Float(_x: f32, _y: f32) [*c]ImVec2;
pub extern fn ImVec4_ImVec4_Nil() [*c]ImVec4;
pub extern fn ImVec4_destroy(self: [*c]ImVec4) void;
pub extern fn ImVec4_ImVec4_Float(_x: f32, _y: f32, _z: f32, _w: f32) [*c]ImVec4;
pub extern fn igCreateContext(shared_font_atlas: [*c]ImFontAtlas) [*c]ImGuiContext;
pub extern fn igDestroyContext(ctx: [*c]ImGuiContext) void;
pub extern fn igGetCurrentContext() [*c]ImGuiContext;
pub extern fn igSetCurrentContext(ctx: [*c]ImGuiContext) void;
pub extern fn igGetIO() [*c]ImGuiIO;
pub extern fn igGetStyle() [*c]ImGuiStyle;
pub extern fn igNewFrame() void;
pub extern fn igEndFrame() void;
pub extern fn igRender() void;
pub extern fn igGetDrawData() [*c]ImDrawData;
pub extern fn igShowDemoWindow(p_open: [*c]bool) void;
pub extern fn igShowMetricsWindow(p_open: [*c]bool) void;
pub extern fn igShowDebugLogWindow(p_open: [*c]bool) void;
pub extern fn igShowStackToolWindow(p_open: [*c]bool) void;
pub extern fn igShowAboutWindow(p_open: [*c]bool) void;
pub extern fn igShowStyleEditor(ref: [*c]ImGuiStyle) void;
pub extern fn igShowStyleSelector(label: [*c]const u8) bool;
pub extern fn igShowFontSelector(label: [*c]const u8) void;
pub extern fn igShowUserGuide() void;
pub extern fn igGetVersion() [*c]const u8;
pub extern fn igStyleColorsDark(dst: [*c]ImGuiStyle) void;
pub extern fn igStyleColorsLight(dst: [*c]ImGuiStyle) void;
pub extern fn igStyleColorsClassic(dst: [*c]ImGuiStyle) void;
pub extern fn igBegin(name: [*c]const u8, p_open: [*c]bool, flags: ImGuiWindowFlags) bool;
pub extern fn igEnd() void;
pub extern fn igBeginChild_Str(str_id: [*c]const u8, size: ImVec2, border: bool, flags: ImGuiWindowFlags) bool;
pub extern fn igBeginChild_ID(id: ImGuiID, size: ImVec2, border: bool, flags: ImGuiWindowFlags) bool;
pub extern fn igEndChild() void;
pub extern fn igIsWindowAppearing() bool;
pub extern fn igIsWindowCollapsed() bool;
pub extern fn igIsWindowFocused(flags: ImGuiFocusedFlags) bool;
pub extern fn igIsWindowHovered(flags: ImGuiHoveredFlags) bool;
pub extern fn igGetWindowDrawList() [*c]ImDrawList;
pub extern fn igGetWindowDpiScale() f32;
pub extern fn igGetWindowPos(pOut: [*c]ImVec2) void;
pub extern fn igGetWindowSize(pOut: [*c]ImVec2) void;
pub extern fn igGetWindowWidth() f32;
pub extern fn igGetWindowHeight() f32;
pub extern fn igGetWindowViewport() [*c]ImGuiViewport;
pub extern fn igSetNextWindowPos(pos: ImVec2, cond: ImGuiCond, pivot: ImVec2) void;
pub extern fn igSetNextWindowSize(size: ImVec2, cond: ImGuiCond) void;
pub extern fn igSetNextWindowSizeConstraints(size_min: ImVec2, size_max: ImVec2, custom_callback: ImGuiSizeCallback, custom_callback_data: ?*anyopaque) void;
pub extern fn igSetNextWindowContentSize(size: ImVec2) void;
pub extern fn igSetNextWindowCollapsed(collapsed: bool, cond: ImGuiCond) void;
pub extern fn igSetNextWindowFocus() void;
pub extern fn igSetNextWindowScroll(scroll: ImVec2) void;
pub extern fn igSetNextWindowBgAlpha(alpha: f32) void;
pub extern fn igSetNextWindowViewport(viewport_id: ImGuiID) void;
pub extern fn igSetWindowPos_Vec2(pos: ImVec2, cond: ImGuiCond) void;
pub extern fn igSetWindowSize_Vec2(size: ImVec2, cond: ImGuiCond) void;
pub extern fn igSetWindowCollapsed_Bool(collapsed: bool, cond: ImGuiCond) void;
pub extern fn igSetWindowFocus_Nil() void;
pub extern fn igSetWindowFontScale(scale: f32) void;
pub extern fn igSetWindowPos_Str(name: [*c]const u8, pos: ImVec2, cond: ImGuiCond) void;
pub extern fn igSetWindowSize_Str(name: [*c]const u8, size: ImVec2, cond: ImGuiCond) void;
pub extern fn igSetWindowCollapsed_Str(name: [*c]const u8, collapsed: bool, cond: ImGuiCond) void;
pub extern fn igSetWindowFocus_Str(name: [*c]const u8) void;
pub extern fn igGetContentRegionAvail(pOut: [*c]ImVec2) void;
pub extern fn igGetContentRegionMax(pOut: [*c]ImVec2) void;
pub extern fn igGetWindowContentRegionMin(pOut: [*c]ImVec2) void;
pub extern fn igGetWindowContentRegionMax(pOut: [*c]ImVec2) void;
pub extern fn igGetScrollX() f32;
pub extern fn igGetScrollY() f32;
pub extern fn igSetScrollX_Float(scroll_x: f32) void;
pub extern fn igSetScrollY_Float(scroll_y: f32) void;
pub extern fn igGetScrollMaxX() f32;
pub extern fn igGetScrollMaxY() f32;
pub extern fn igSetScrollHereX(center_x_ratio: f32) void;
pub extern fn igSetScrollHereY(center_y_ratio: f32) void;
pub extern fn igSetScrollFromPosX_Float(local_x: f32, center_x_ratio: f32) void;
pub extern fn igSetScrollFromPosY_Float(local_y: f32, center_y_ratio: f32) void;
pub extern fn igPushFont(font: [*c]ImFont) void;
pub extern fn igPopFont() void;
pub extern fn igPushStyleColor_U32(idx: ImGuiCol, col: ImU32) void;
pub extern fn igPushStyleColor_Vec4(idx: ImGuiCol, col: ImVec4) void;
pub extern fn igPopStyleColor(count: c_int) void;
pub extern fn igPushStyleVar_Float(idx: ImGuiStyleVar, val: f32) void;
pub extern fn igPushStyleVar_Vec2(idx: ImGuiStyleVar, val: ImVec2) void;
pub extern fn igPopStyleVar(count: c_int) void;
pub extern fn igPushTabStop(tab_stop: bool) void;
pub extern fn igPopTabStop() void;
pub extern fn igPushButtonRepeat(repeat: bool) void;
pub extern fn igPopButtonRepeat() void;
pub extern fn igPushItemWidth(item_width: f32) void;
pub extern fn igPopItemWidth() void;
pub extern fn igSetNextItemWidth(item_width: f32) void;
pub extern fn igCalcItemWidth() f32;
pub extern fn igPushTextWrapPos(wrap_local_pos_x: f32) void;
pub extern fn igPopTextWrapPos() void;
pub extern fn igGetFont() [*c]ImFont;
pub extern fn igGetFontSize() f32;
pub extern fn igGetFontTexUvWhitePixel(pOut: [*c]ImVec2) void;
pub extern fn igGetColorU32_Col(idx: ImGuiCol, alpha_mul: f32) ImU32;
pub extern fn igGetColorU32_Vec4(col: ImVec4) ImU32;
pub extern fn igGetColorU32_U32(col: ImU32) ImU32;
pub extern fn igGetStyleColorVec4(idx: ImGuiCol) [*c]const ImVec4;
pub extern fn igSeparator() void;
pub extern fn igSameLine(offset_from_start_x: f32, spacing: f32) void;
pub extern fn igNewLine() void;
pub extern fn igSpacing() void;
pub extern fn igDummy(size: ImVec2) void;
pub extern fn igIndent(indent_w: f32) void;
pub extern fn igUnindent(indent_w: f32) void;
pub extern fn igBeginGroup() void;
pub extern fn igEndGroup() void;
pub extern fn igGetCursorPos(pOut: [*c]ImVec2) void;
pub extern fn igGetCursorPosX() f32;
pub extern fn igGetCursorPosY() f32;
pub extern fn igSetCursorPos(local_pos: ImVec2) void;
pub extern fn igSetCursorPosX(local_x: f32) void;
pub extern fn igSetCursorPosY(local_y: f32) void;
pub extern fn igGetCursorStartPos(pOut: [*c]ImVec2) void;
pub extern fn igGetCursorScreenPos(pOut: [*c]ImVec2) void;
pub extern fn igSetCursorScreenPos(pos: ImVec2) void;
pub extern fn igAlignTextToFramePadding() void;
pub extern fn igGetTextLineHeight() f32;
pub extern fn igGetTextLineHeightWithSpacing() f32;
pub extern fn igGetFrameHeight() f32;
pub extern fn igGetFrameHeightWithSpacing() f32;
pub extern fn igPushID_Str(str_id: [*c]const u8) void;
pub extern fn igPushID_StrStr(str_id_begin: [*c]const u8, str_id_end: [*c]const u8) void;
pub extern fn igPushID_Ptr(ptr_id: ?*const anyopaque) void;
pub extern fn igPushID_Int(int_id: c_int) void;
pub extern fn igPopID() void;
pub extern fn igGetID_Str(str_id: [*c]const u8) ImGuiID;
pub extern fn igGetID_StrStr(str_id_begin: [*c]const u8, str_id_end: [*c]const u8) ImGuiID;
pub extern fn igGetID_Ptr(ptr_id: ?*const anyopaque) ImGuiID;
pub extern fn igTextUnformatted(text: [*c]const u8, text_end: [*c]const u8) void;
pub extern fn igText(fmt: [*c]const u8, ...) void;
pub extern fn igTextV(fmt: [*c]const u8, args: va_list) void;
pub extern fn igTextColored(col: ImVec4, fmt: [*c]const u8, ...) void;
pub extern fn igTextColoredV(col: ImVec4, fmt: [*c]const u8, args: va_list) void;
pub extern fn igTextDisabled(fmt: [*c]const u8, ...) void;
pub extern fn igTextDisabledV(fmt: [*c]const u8, args: va_list) void;
pub extern fn igTextWrapped(fmt: [*c]const u8, ...) void;
pub extern fn igTextWrappedV(fmt: [*c]const u8, args: va_list) void;
pub extern fn igLabelText(label: [*c]const u8, fmt: [*c]const u8, ...) void;
pub extern fn igLabelTextV(label: [*c]const u8, fmt: [*c]const u8, args: va_list) void;
pub extern fn igBulletText(fmt: [*c]const u8, ...) void;
pub extern fn igBulletTextV(fmt: [*c]const u8, args: va_list) void;
pub extern fn igSeparatorText(label: [*c]const u8) void;
pub extern fn igButton(label: [*c]const u8, size: ImVec2) bool;
pub extern fn igSmallButton(label: [*c]const u8) bool;
pub extern fn igInvisibleButton(str_id: [*c]const u8, size: ImVec2, flags: ImGuiButtonFlags) bool;
pub extern fn igArrowButton(str_id: [*c]const u8, dir: ImGuiDir) bool;
pub extern fn igCheckbox(label: [*c]const u8, v: [*c]bool) bool;
pub extern fn igCheckboxFlags_IntPtr(label: [*c]const u8, flags: [*c]c_int, flags_value: c_int) bool;
pub extern fn igCheckboxFlags_UintPtr(label: [*c]const u8, flags: [*c]c_uint, flags_value: c_uint) bool;
pub extern fn igRadioButton_Bool(label: [*c]const u8, active: bool) bool;
pub extern fn igRadioButton_IntPtr(label: [*c]const u8, v: [*c]c_int, v_button: c_int) bool;
pub extern fn igProgressBar(fraction: f32, size_arg: ImVec2, overlay: [*c]const u8) void;
pub extern fn igBullet() void;
pub extern fn igImage(user_texture_id: ImTextureID, size: ImVec2, uv0: ImVec2, uv1: ImVec2, tint_col: ImVec4, border_col: ImVec4) void;
pub extern fn igImageButton(str_id: [*c]const u8, user_texture_id: ImTextureID, size: ImVec2, uv0: ImVec2, uv1: ImVec2, bg_col: ImVec4, tint_col: ImVec4) bool;
pub extern fn igBeginCombo(label: [*c]const u8, preview_value: [*c]const u8, flags: ImGuiComboFlags) bool;
pub extern fn igEndCombo() void;
pub extern fn igCombo_Str_arr(label: [*c]const u8, current_item: [*c]c_int, items: [*c]const [*c]const u8, items_count: c_int, popup_max_height_in_items: c_int) bool;
pub extern fn igCombo_Str(label: [*c]const u8, current_item: [*c]c_int, items_separated_by_zeros: [*c]const u8, popup_max_height_in_items: c_int) bool;
pub extern fn igCombo_FnBoolPtr(label: [*c]const u8, current_item: [*c]c_int, items_getter: ?*const fn (?*anyopaque, c_int, [*c][*c]const u8) callconv(.C) bool, data: ?*anyopaque, items_count: c_int, popup_max_height_in_items: c_int) bool;
pub extern fn igDragFloat(label: [*c]const u8, v: [*c]f32, v_speed: f32, v_min: f32, v_max: f32, format: [*c]const u8, flags: ImGuiSliderFlags) bool;
pub extern fn igDragFloat2(label: [*c]const u8, v: [*c]f32, v_speed: f32, v_min: f32, v_max: f32, format: [*c]const u8, flags: ImGuiSliderFlags) bool;
pub extern fn igDragFloat3(label: [*c]const u8, v: [*c]f32, v_speed: f32, v_min: f32, v_max: f32, format: [*c]const u8, flags: ImGuiSliderFlags) bool;
pub extern fn igDragFloat4(label: [*c]const u8, v: [*c]f32, v_speed: f32, v_min: f32, v_max: f32, format: [*c]const u8, flags: ImGuiSliderFlags) bool;
pub extern fn igDragFloatRange2(label: [*c]const u8, v_current_min: [*c]f32, v_current_max: [*c]f32, v_speed: f32, v_min: f32, v_max: f32, format: [*c]const u8, format_max: [*c]const u8, flags: ImGuiSliderFlags) bool;
pub extern fn igDragInt(label: [*c]const u8, v: [*c]c_int, v_speed: f32, v_min: c_int, v_max: c_int, format: [*c]const u8, flags: ImGuiSliderFlags) bool;
pub extern fn igDragInt2(label: [*c]const u8, v: [*c]c_int, v_speed: f32, v_min: c_int, v_max: c_int, format: [*c]const u8, flags: ImGuiSliderFlags) bool;
pub extern fn igDragInt3(label: [*c]const u8, v: [*c]c_int, v_speed: f32, v_min: c_int, v_max: c_int, format: [*c]const u8, flags: ImGuiSliderFlags) bool;
pub extern fn igDragInt4(label: [*c]const u8, v: [*c]c_int, v_speed: f32, v_min: c_int, v_max: c_int, format: [*c]const u8, flags: ImGuiSliderFlags) bool;
pub extern fn igDragIntRange2(label: [*c]const u8, v_current_min: [*c]c_int, v_current_max: [*c]c_int, v_speed: f32, v_min: c_int, v_max: c_int, format: [*c]const u8, format_max: [*c]const u8, flags: ImGuiSliderFlags) bool;
pub extern fn igDragScalar(label: [*c]const u8, data_type: ImGuiDataType, p_data: ?*anyopaque, v_speed: f32, p_min: ?*const anyopaque, p_max: ?*const anyopaque, format: [*c]const u8, flags: ImGuiSliderFlags) bool;
pub extern fn igDragScalarN(label: [*c]const u8, data_type: ImGuiDataType, p_data: ?*anyopaque, components: c_int, v_speed: f32, p_min: ?*const anyopaque, p_max: ?*const anyopaque, format: [*c]const u8, flags: ImGuiSliderFlags) bool;
pub extern fn igSliderFloat(label: [*c]const u8, v: [*c]f32, v_min: f32, v_max: f32, format: [*c]const u8, flags: ImGuiSliderFlags) bool;
pub extern fn igSliderFloat2(label: [*c]const u8, v: [*c]f32, v_min: f32, v_max: f32, format: [*c]const u8, flags: ImGuiSliderFlags) bool;
pub extern fn igSliderFloat3(label: [*c]const u8, v: [*c]f32, v_min: f32, v_max: f32, format: [*c]const u8, flags: ImGuiSliderFlags) bool;
pub extern fn igSliderFloat4(label: [*c]const u8, v: [*c]f32, v_min: f32, v_max: f32, format: [*c]const u8, flags: ImGuiSliderFlags) bool;
pub extern fn igSliderAngle(label: [*c]const u8, v_rad: [*c]f32, v_degrees_min: f32, v_degrees_max: f32, format: [*c]const u8, flags: ImGuiSliderFlags) bool;
pub extern fn igSliderInt(label: [*c]const u8, v: [*c]c_int, v_min: c_int, v_max: c_int, format: [*c]const u8, flags: ImGuiSliderFlags) bool;
pub extern fn igSliderInt2(label: [*c]const u8, v: [*c]c_int, v_min: c_int, v_max: c_int, format: [*c]const u8, flags: ImGuiSliderFlags) bool;
pub extern fn igSliderInt3(label: [*c]const u8, v: [*c]c_int, v_min: c_int, v_max: c_int, format: [*c]const u8, flags: ImGuiSliderFlags) bool;
pub extern fn igSliderInt4(label: [*c]const u8, v: [*c]c_int, v_min: c_int, v_max: c_int, format: [*c]const u8, flags: ImGuiSliderFlags) bool;
pub extern fn igSliderScalar(label: [*c]const u8, data_type: ImGuiDataType, p_data: ?*anyopaque, p_min: ?*const anyopaque, p_max: ?*const anyopaque, format: [*c]const u8, flags: ImGuiSliderFlags) bool;
pub extern fn igSliderScalarN(label: [*c]const u8, data_type: ImGuiDataType, p_data: ?*anyopaque, components: c_int, p_min: ?*const anyopaque, p_max: ?*const anyopaque, format: [*c]const u8, flags: ImGuiSliderFlags) bool;
pub extern fn igVSliderFloat(label: [*c]const u8, size: ImVec2, v: [*c]f32, v_min: f32, v_max: f32, format: [*c]const u8, flags: ImGuiSliderFlags) bool;
pub extern fn igVSliderInt(label: [*c]const u8, size: ImVec2, v: [*c]c_int, v_min: c_int, v_max: c_int, format: [*c]const u8, flags: ImGuiSliderFlags) bool;
pub extern fn igVSliderScalar(label: [*c]const u8, size: ImVec2, data_type: ImGuiDataType, p_data: ?*anyopaque, p_min: ?*const anyopaque, p_max: ?*const anyopaque, format: [*c]const u8, flags: ImGuiSliderFlags) bool;
pub extern fn igInputText(label: [*c]const u8, buf: [*c]u8, buf_size: usize, flags: ImGuiInputTextFlags, callback: ImGuiInputTextCallback, user_data: ?*anyopaque) bool;
pub extern fn igInputTextMultiline(label: [*c]const u8, buf: [*c]u8, buf_size: usize, size: ImVec2, flags: ImGuiInputTextFlags, callback: ImGuiInputTextCallback, user_data: ?*anyopaque) bool;
pub extern fn igInputTextWithHint(label: [*c]const u8, hint: [*c]const u8, buf: [*c]u8, buf_size: usize, flags: ImGuiInputTextFlags, callback: ImGuiInputTextCallback, user_data: ?*anyopaque) bool;
pub extern fn igInputFloat(label: [*c]const u8, v: [*c]f32, step: f32, step_fast: f32, format: [*c]const u8, flags: ImGuiInputTextFlags) bool;
pub extern fn igInputFloat2(label: [*c]const u8, v: [*c]f32, format: [*c]const u8, flags: ImGuiInputTextFlags) bool;
pub extern fn igInputFloat3(label: [*c]const u8, v: [*c]f32, format: [*c]const u8, flags: ImGuiInputTextFlags) bool;
pub extern fn igInputFloat4(label: [*c]const u8, v: [*c]f32, format: [*c]const u8, flags: ImGuiInputTextFlags) bool;
pub extern fn igInputInt(label: [*c]const u8, v: [*c]c_int, step: c_int, step_fast: c_int, flags: ImGuiInputTextFlags) bool;
pub extern fn igInputInt2(label: [*c]const u8, v: [*c]c_int, flags: ImGuiInputTextFlags) bool;
pub extern fn igInputInt3(label: [*c]const u8, v: [*c]c_int, flags: ImGuiInputTextFlags) bool;
pub extern fn igInputInt4(label: [*c]const u8, v: [*c]c_int, flags: ImGuiInputTextFlags) bool;
pub extern fn igInputDouble(label: [*c]const u8, v: [*c]f64, step: f64, step_fast: f64, format: [*c]const u8, flags: ImGuiInputTextFlags) bool;
pub extern fn igInputScalar(label: [*c]const u8, data_type: ImGuiDataType, p_data: ?*anyopaque, p_step: ?*const anyopaque, p_step_fast: ?*const anyopaque, format: [*c]const u8, flags: ImGuiInputTextFlags) bool;
pub extern fn igInputScalarN(label: [*c]const u8, data_type: ImGuiDataType, p_data: ?*anyopaque, components: c_int, p_step: ?*const anyopaque, p_step_fast: ?*const anyopaque, format: [*c]const u8, flags: ImGuiInputTextFlags) bool;
pub extern fn igColorEdit3(label: [*c]const u8, col: [*c]f32, flags: ImGuiColorEditFlags) bool;
pub extern fn igColorEdit4(label: [*c]const u8, col: [*c]f32, flags: ImGuiColorEditFlags) bool;
pub extern fn igColorPicker3(label: [*c]const u8, col: [*c]f32, flags: ImGuiColorEditFlags) bool;
pub extern fn igColorPicker4(label: [*c]const u8, col: [*c]f32, flags: ImGuiColorEditFlags, ref_col: [*c]const f32) bool;
pub extern fn igColorButton(desc_id: [*c]const u8, col: ImVec4, flags: ImGuiColorEditFlags, size: ImVec2) bool;
pub extern fn igSetColorEditOptions(flags: ImGuiColorEditFlags) void;
pub extern fn igTreeNode_Str(label: [*c]const u8) bool;
pub extern fn igTreeNode_StrStr(str_id: [*c]const u8, fmt: [*c]const u8, ...) bool;
pub extern fn igTreeNode_Ptr(ptr_id: ?*const anyopaque, fmt: [*c]const u8, ...) bool;
pub extern fn igTreeNodeV_Str(str_id: [*c]const u8, fmt: [*c]const u8, args: va_list) bool;
pub extern fn igTreeNodeV_Ptr(ptr_id: ?*const anyopaque, fmt: [*c]const u8, args: va_list) bool;
pub extern fn igTreeNodeEx_Str(label: [*c]const u8, flags: ImGuiTreeNodeFlags) bool;
pub extern fn igTreeNodeEx_StrStr(str_id: [*c]const u8, flags: ImGuiTreeNodeFlags, fmt: [*c]const u8, ...) bool;
pub extern fn igTreeNodeEx_Ptr(ptr_id: ?*const anyopaque, flags: ImGuiTreeNodeFlags, fmt: [*c]const u8, ...) bool;
pub extern fn igTreeNodeExV_Str(str_id: [*c]const u8, flags: ImGuiTreeNodeFlags, fmt: [*c]const u8, args: va_list) bool;
pub extern fn igTreeNodeExV_Ptr(ptr_id: ?*const anyopaque, flags: ImGuiTreeNodeFlags, fmt: [*c]const u8, args: va_list) bool;
pub extern fn igTreePush_Str(str_id: [*c]const u8) void;
pub extern fn igTreePush_Ptr(ptr_id: ?*const anyopaque) void;
pub extern fn igTreePop() void;
pub extern fn igGetTreeNodeToLabelSpacing() f32;
pub extern fn igCollapsingHeader_TreeNodeFlags(label: [*c]const u8, flags: ImGuiTreeNodeFlags) bool;
pub extern fn igCollapsingHeader_BoolPtr(label: [*c]const u8, p_visible: [*c]bool, flags: ImGuiTreeNodeFlags) bool;
pub extern fn igSetNextItemOpen(is_open: bool, cond: ImGuiCond) void;
pub extern fn igSelectable_Bool(label: [*c]const u8, selected: bool, flags: ImGuiSelectableFlags, size: ImVec2) bool;
pub extern fn igSelectable_BoolPtr(label: [*c]const u8, p_selected: [*c]bool, flags: ImGuiSelectableFlags, size: ImVec2) bool;
pub extern fn igBeginListBox(label: [*c]const u8, size: ImVec2) bool;
pub extern fn igEndListBox() void;
pub extern fn igListBox_Str_arr(label: [*c]const u8, current_item: [*c]c_int, items: [*c]const [*c]const u8, items_count: c_int, height_in_items: c_int) bool;
pub extern fn igListBox_FnBoolPtr(label: [*c]const u8, current_item: [*c]c_int, items_getter: ?*const fn (?*anyopaque, c_int, [*c][*c]const u8) callconv(.C) bool, data: ?*anyopaque, items_count: c_int, height_in_items: c_int) bool;
pub extern fn igPlotLines_FloatPtr(label: [*c]const u8, values: [*c]const f32, values_count: c_int, values_offset: c_int, overlay_text: [*c]const u8, scale_min: f32, scale_max: f32, graph_size: ImVec2, stride: c_int) void;
pub extern fn igPlotLines_FnFloatPtr(label: [*c]const u8, values_getter: ?*const fn (?*anyopaque, c_int) callconv(.C) f32, data: ?*anyopaque, values_count: c_int, values_offset: c_int, overlay_text: [*c]const u8, scale_min: f32, scale_max: f32, graph_size: ImVec2) void;
pub extern fn igPlotHistogram_FloatPtr(label: [*c]const u8, values: [*c]const f32, values_count: c_int, values_offset: c_int, overlay_text: [*c]const u8, scale_min: f32, scale_max: f32, graph_size: ImVec2, stride: c_int) void;
pub extern fn igPlotHistogram_FnFloatPtr(label: [*c]const u8, values_getter: ?*const fn (?*anyopaque, c_int) callconv(.C) f32, data: ?*anyopaque, values_count: c_int, values_offset: c_int, overlay_text: [*c]const u8, scale_min: f32, scale_max: f32, graph_size: ImVec2) void;
pub extern fn igValue_Bool(prefix: [*c]const u8, b: bool) void;
pub extern fn igValue_Int(prefix: [*c]const u8, v: c_int) void;
pub extern fn igValue_Uint(prefix: [*c]const u8, v: c_uint) void;
pub extern fn igValue_Float(prefix: [*c]const u8, v: f32, float_format: [*c]const u8) void;
pub extern fn igBeginMenuBar() bool;
pub extern fn igEndMenuBar() void;
pub extern fn igBeginMainMenuBar() bool;
pub extern fn igEndMainMenuBar() void;
pub extern fn igBeginMenu(label: [*c]const u8, enabled: bool) bool;
pub extern fn igEndMenu() void;
pub extern fn igMenuItem_Bool(label: [*c]const u8, shortcut: [*c]const u8, selected: bool, enabled: bool) bool;
pub extern fn igMenuItem_BoolPtr(label: [*c]const u8, shortcut: [*c]const u8, p_selected: [*c]bool, enabled: bool) bool;
pub extern fn igBeginTooltip() bool;
pub extern fn igEndTooltip() void;
pub extern fn igSetTooltip(fmt: [*c]const u8, ...) void;
pub extern fn igSetTooltipV(fmt: [*c]const u8, args: va_list) void;
pub extern fn igBeginItemTooltip() bool;
pub extern fn igSetItemTooltip(fmt: [*c]const u8, ...) void;
pub extern fn igSetItemTooltipV(fmt: [*c]const u8, args: va_list) void;
pub extern fn igBeginPopup(str_id: [*c]const u8, flags: ImGuiWindowFlags) bool;
pub extern fn igBeginPopupModal(name: [*c]const u8, p_open: [*c]bool, flags: ImGuiWindowFlags) bool;
pub extern fn igEndPopup() void;
pub extern fn igOpenPopup_Str(str_id: [*c]const u8, popup_flags: ImGuiPopupFlags) void;
pub extern fn igOpenPopup_ID(id: ImGuiID, popup_flags: ImGuiPopupFlags) void;
pub extern fn igOpenPopupOnItemClick(str_id: [*c]const u8, popup_flags: ImGuiPopupFlags) void;
pub extern fn igCloseCurrentPopup() void;
pub extern fn igBeginPopupContextItem(str_id: [*c]const u8, popup_flags: ImGuiPopupFlags) bool;
pub extern fn igBeginPopupContextWindow(str_id: [*c]const u8, popup_flags: ImGuiPopupFlags) bool;
pub extern fn igBeginPopupContextVoid(str_id: [*c]const u8, popup_flags: ImGuiPopupFlags) bool;
pub extern fn igIsPopupOpen_Str(str_id: [*c]const u8, flags: ImGuiPopupFlags) bool;
pub extern fn igBeginTable(str_id: [*c]const u8, column: c_int, flags: ImGuiTableFlags, outer_size: ImVec2, inner_width: f32) bool;
pub extern fn igEndTable() void;
pub extern fn igTableNextRow(row_flags: ImGuiTableRowFlags, min_row_height: f32) void;
pub extern fn igTableNextColumn() bool;
pub extern fn igTableSetColumnIndex(column_n: c_int) bool;
pub extern fn igTableSetupColumn(label: [*c]const u8, flags: ImGuiTableColumnFlags, init_width_or_weight: f32, user_id: ImGuiID) void;
pub extern fn igTableSetupScrollFreeze(cols: c_int, rows: c_int) void;
pub extern fn igTableHeadersRow() void;
pub extern fn igTableHeader(label: [*c]const u8) void;
pub extern fn igTableGetSortSpecs() [*c]ImGuiTableSortSpecs;
pub extern fn igTableGetColumnCount() c_int;
pub extern fn igTableGetColumnIndex() c_int;
pub extern fn igTableGetRowIndex() c_int;
pub extern fn igTableGetColumnName_Int(column_n: c_int) [*c]const u8;
pub extern fn igTableGetColumnFlags(column_n: c_int) ImGuiTableColumnFlags;
pub extern fn igTableSetColumnEnabled(column_n: c_int, v: bool) void;
pub extern fn igTableSetBgColor(target: ImGuiTableBgTarget, color: ImU32, column_n: c_int) void;
pub extern fn igColumns(count: c_int, id: [*c]const u8, border: bool) void;
pub extern fn igNextColumn() void;
pub extern fn igGetColumnIndex() c_int;
pub extern fn igGetColumnWidth(column_index: c_int) f32;
pub extern fn igSetColumnWidth(column_index: c_int, width: f32) void;
pub extern fn igGetColumnOffset(column_index: c_int) f32;
pub extern fn igSetColumnOffset(column_index: c_int, offset_x: f32) void;
pub extern fn igGetColumnsCount() c_int;
pub extern fn igBeginTabBar(str_id: [*c]const u8, flags: ImGuiTabBarFlags) bool;
pub extern fn igEndTabBar() void;
pub extern fn igBeginTabItem(label: [*c]const u8, p_open: [*c]bool, flags: ImGuiTabItemFlags) bool;
pub extern fn igEndTabItem() void;
pub extern fn igTabItemButton(label: [*c]const u8, flags: ImGuiTabItemFlags) bool;
pub extern fn igSetTabItemClosed(tab_or_docked_window_label: [*c]const u8) void;
pub extern fn igDockSpace(id: ImGuiID, size: ImVec2, flags: ImGuiDockNodeFlags, window_class: [*c]const ImGuiWindowClass) ImGuiID;
pub extern fn igDockSpaceOverViewport(viewport: [*c]const ImGuiViewport, flags: ImGuiDockNodeFlags, window_class: [*c]const ImGuiWindowClass) ImGuiID;
pub extern fn igSetNextWindowDockID(dock_id: ImGuiID, cond: ImGuiCond) void;
pub extern fn igSetNextWindowClass(window_class: [*c]const ImGuiWindowClass) void;
pub extern fn igGetWindowDockID() ImGuiID;
pub extern fn igIsWindowDocked() bool;
pub extern fn igLogToTTY(auto_open_depth: c_int) void;
pub extern fn igLogToFile(auto_open_depth: c_int, filename: [*c]const u8) void;
pub extern fn igLogToClipboard(auto_open_depth: c_int) void;
pub extern fn igLogFinish() void;
pub extern fn igLogButtons() void;
pub extern fn igLogTextV(fmt: [*c]const u8, args: va_list) void;
pub extern fn igBeginDragDropSource(flags: ImGuiDragDropFlags) bool;
pub extern fn igSetDragDropPayload(@"type": [*c]const u8, data: ?*const anyopaque, sz: usize, cond: ImGuiCond) bool;
pub extern fn igEndDragDropSource() void;
pub extern fn igBeginDragDropTarget() bool;
pub extern fn igAcceptDragDropPayload(@"type": [*c]const u8, flags: ImGuiDragDropFlags) [*c]const ImGuiPayload;
pub extern fn igEndDragDropTarget() void;
pub extern fn igGetDragDropPayload() [*c]const ImGuiPayload;
pub extern fn igBeginDisabled(disabled: bool) void;
pub extern fn igEndDisabled() void;
pub extern fn igPushClipRect(clip_rect_min: ImVec2, clip_rect_max: ImVec2, intersect_with_current_clip_rect: bool) void;
pub extern fn igPopClipRect() void;
pub extern fn igSetItemDefaultFocus() void;
pub extern fn igSetKeyboardFocusHere(offset: c_int) void;
pub extern fn igSetNextItemAllowOverlap() void;
pub extern fn igIsItemHovered(flags: ImGuiHoveredFlags) bool;
pub extern fn igIsItemActive() bool;
pub extern fn igIsItemFocused() bool;
pub extern fn igIsItemClicked(mouse_button: ImGuiMouseButton) bool;
pub extern fn igIsItemVisible() bool;
pub extern fn igIsItemEdited() bool;
pub extern fn igIsItemActivated() bool;
pub extern fn igIsItemDeactivated() bool;
pub extern fn igIsItemDeactivatedAfterEdit() bool;
pub extern fn igIsItemToggledOpen() bool;
pub extern fn igIsAnyItemHovered() bool;
pub extern fn igIsAnyItemActive() bool;
pub extern fn igIsAnyItemFocused() bool;
pub extern fn igGetItemID() ImGuiID;
pub extern fn igGetItemRectMin(pOut: [*c]ImVec2) void;
pub extern fn igGetItemRectMax(pOut: [*c]ImVec2) void;
pub extern fn igGetItemRectSize(pOut: [*c]ImVec2) void;
pub extern fn igGetMainViewport() [*c]ImGuiViewport;
pub extern fn igGetBackgroundDrawList_Nil() [*c]ImDrawList;
pub extern fn igGetForegroundDrawList_Nil() [*c]ImDrawList;
pub extern fn igGetBackgroundDrawList_ViewportPtr(viewport: [*c]ImGuiViewport) [*c]ImDrawList;
pub extern fn igGetForegroundDrawList_ViewportPtr(viewport: [*c]ImGuiViewport) [*c]ImDrawList;
pub extern fn igIsRectVisible_Nil(size: ImVec2) bool;
pub extern fn igIsRectVisible_Vec2(rect_min: ImVec2, rect_max: ImVec2) bool;
pub extern fn igGetTime() f64;
pub extern fn igGetFrameCount() c_int;
pub extern fn igGetDrawListSharedData() [*c]ImDrawListSharedData;
pub extern fn igGetStyleColorName(idx: ImGuiCol) [*c]const u8;
pub extern fn igSetStateStorage(storage: [*c]ImGuiStorage) void;
pub extern fn igGetStateStorage() [*c]ImGuiStorage;
pub extern fn igBeginChildFrame(id: ImGuiID, size: ImVec2, flags: ImGuiWindowFlags) bool;
pub extern fn igEndChildFrame() void;
pub extern fn igCalcTextSize(pOut: [*c]ImVec2, text: [*c]const u8, text_end: [*c]const u8, hide_text_after_double_hash: bool, wrap_width: f32) void;
pub extern fn igColorConvertU32ToFloat4(pOut: [*c]ImVec4, in: ImU32) void;
pub extern fn igColorConvertFloat4ToU32(in: ImVec4) ImU32;
pub extern fn igColorConvertRGBtoHSV(r: f32, g: f32, b: f32, out_h: [*c]f32, out_s: [*c]f32, out_v: [*c]f32) void;
pub extern fn igColorConvertHSVtoRGB(h: f32, s: f32, v: f32, out_r: [*c]f32, out_g: [*c]f32, out_b: [*c]f32) void;
pub extern fn igIsKeyDown_Nil(key: ImGuiKey) bool;
pub extern fn igIsKeyPressed_Bool(key: ImGuiKey, repeat: bool) bool;
pub extern fn igIsKeyReleased_Nil(key: ImGuiKey) bool;
pub extern fn igGetKeyPressedAmount(key: ImGuiKey, repeat_delay: f32, rate: f32) c_int;
pub extern fn igGetKeyName(key: ImGuiKey) [*c]const u8;
pub extern fn igSetNextFrameWantCaptureKeyboard(want_capture_keyboard: bool) void;
pub extern fn igIsMouseDown_Nil(button: ImGuiMouseButton) bool;
pub extern fn igIsMouseClicked_Bool(button: ImGuiMouseButton, repeat: bool) bool;
pub extern fn igIsMouseReleased_Nil(button: ImGuiMouseButton) bool;
pub extern fn igIsMouseDoubleClicked(button: ImGuiMouseButton) bool;
pub extern fn igGetMouseClickedCount(button: ImGuiMouseButton) c_int;
pub extern fn igIsMouseHoveringRect(r_min: ImVec2, r_max: ImVec2, clip: bool) bool;
pub extern fn igIsMousePosValid(mouse_pos: [*c]const ImVec2) bool;
pub extern fn igIsAnyMouseDown() bool;
pub extern fn igGetMousePos(pOut: [*c]ImVec2) void;
pub extern fn igGetMousePosOnOpeningCurrentPopup(pOut: [*c]ImVec2) void;
pub extern fn igIsMouseDragging(button: ImGuiMouseButton, lock_threshold: f32) bool;
pub extern fn igGetMouseDragDelta(pOut: [*c]ImVec2, button: ImGuiMouseButton, lock_threshold: f32) void;
pub extern fn igResetMouseDragDelta(button: ImGuiMouseButton) void;
pub extern fn igGetMouseCursor() ImGuiMouseCursor;
pub extern fn igSetMouseCursor(cursor_type: ImGuiMouseCursor) void;
pub extern fn igSetNextFrameWantCaptureMouse(want_capture_mouse: bool) void;
pub extern fn igGetClipboardText() [*c]const u8;
pub extern fn igSetClipboardText(text: [*c]const u8) void;
pub extern fn igLoadIniSettingsFromDisk(ini_filename: [*c]const u8) void;
pub extern fn igLoadIniSettingsFromMemory(ini_data: [*c]const u8, ini_size: usize) void;
pub extern fn igSaveIniSettingsToDisk(ini_filename: [*c]const u8) void;
pub extern fn igSaveIniSettingsToMemory(out_ini_size: [*c]usize) [*c]const u8;
pub extern fn igDebugTextEncoding(text: [*c]const u8) void;
pub extern fn igDebugCheckVersionAndDataLayout(version_str: [*c]const u8, sz_io: usize, sz_style: usize, sz_vec2: usize, sz_vec4: usize, sz_drawvert: usize, sz_drawidx: usize) bool;
pub extern fn igSetAllocatorFunctions(alloc_func: ImGuiMemAllocFunc, free_func: ImGuiMemFreeFunc, user_data: ?*anyopaque) void;
pub extern fn igGetAllocatorFunctions(p_alloc_func: [*c]ImGuiMemAllocFunc, p_free_func: [*c]ImGuiMemFreeFunc, p_user_data: [*c]?*anyopaque) void;
pub extern fn igMemAlloc(size: usize) ?*anyopaque;
pub extern fn igMemFree(ptr: ?*anyopaque) void;
pub extern fn igGetPlatformIO() [*c]ImGuiPlatformIO;
pub extern fn igUpdatePlatformWindows() void;
pub extern fn igRenderPlatformWindowsDefault(platform_render_arg: ?*anyopaque, renderer_render_arg: ?*anyopaque) void;
pub extern fn igDestroyPlatformWindows() void;
pub extern fn igFindViewportByID(id: ImGuiID) [*c]ImGuiViewport;
pub extern fn igFindViewportByPlatformHandle(platform_handle: ?*anyopaque) [*c]ImGuiViewport;
pub extern fn ImGuiStyle_ImGuiStyle() [*c]ImGuiStyle;
pub extern fn ImGuiStyle_destroy(self: [*c]ImGuiStyle) void;
pub extern fn ImGuiStyle_ScaleAllSizes(self: [*c]ImGuiStyle, scale_factor: f32) void;
pub extern fn ImGuiIO_AddKeyEvent(self: [*c]ImGuiIO, key: ImGuiKey, down: bool) void;
pub extern fn ImGuiIO_AddKeyAnalogEvent(self: [*c]ImGuiIO, key: ImGuiKey, down: bool, v: f32) void;
pub extern fn ImGuiIO_AddMousePosEvent(self: [*c]ImGuiIO, x: f32, y: f32) void;
pub extern fn ImGuiIO_AddMouseButtonEvent(self: [*c]ImGuiIO, button: c_int, down: bool) void;
pub extern fn ImGuiIO_AddMouseWheelEvent(self: [*c]ImGuiIO, wheel_x: f32, wheel_y: f32) void;
pub extern fn ImGuiIO_AddMouseSourceEvent(self: [*c]ImGuiIO, source: ImGuiMouseSource) void;
pub extern fn ImGuiIO_AddMouseViewportEvent(self: [*c]ImGuiIO, id: ImGuiID) void;
pub extern fn ImGuiIO_AddFocusEvent(self: [*c]ImGuiIO, focused: bool) void;
pub extern fn ImGuiIO_AddInputCharacter(self: [*c]ImGuiIO, c: c_uint) void;
pub extern fn ImGuiIO_AddInputCharacterUTF16(self: [*c]ImGuiIO, c: ImWchar16) void;
pub extern fn ImGuiIO_AddInputCharactersUTF8(self: [*c]ImGuiIO, str: [*c]const u8) void;
pub extern fn ImGuiIO_SetKeyEventNativeData(self: [*c]ImGuiIO, key: ImGuiKey, native_keycode: c_int, native_scancode: c_int, native_legacy_index: c_int) void;
pub extern fn ImGuiIO_SetAppAcceptingEvents(self: [*c]ImGuiIO, accepting_events: bool) void;
pub extern fn ImGuiIO_ClearEventsQueue(self: [*c]ImGuiIO) void;
pub extern fn ImGuiIO_ClearInputKeys(self: [*c]ImGuiIO) void;
pub extern fn ImGuiIO_ImGuiIO() [*c]ImGuiIO;
pub extern fn ImGuiIO_destroy(self: [*c]ImGuiIO) void;
pub extern fn ImGuiInputTextCallbackData_ImGuiInputTextCallbackData() [*c]ImGuiInputTextCallbackData;
pub extern fn ImGuiInputTextCallbackData_destroy(self: [*c]ImGuiInputTextCallbackData) void;
pub extern fn ImGuiInputTextCallbackData_DeleteChars(self: [*c]ImGuiInputTextCallbackData, pos: c_int, bytes_count: c_int) void;
pub extern fn ImGuiInputTextCallbackData_InsertChars(self: [*c]ImGuiInputTextCallbackData, pos: c_int, text: [*c]const u8, text_end: [*c]const u8) void;
pub extern fn ImGuiInputTextCallbackData_SelectAll(self: [*c]ImGuiInputTextCallbackData) void;
pub extern fn ImGuiInputTextCallbackData_ClearSelection(self: [*c]ImGuiInputTextCallbackData) void;
pub extern fn ImGuiInputTextCallbackData_HasSelection(self: [*c]ImGuiInputTextCallbackData) bool;
pub extern fn ImGuiWindowClass_ImGuiWindowClass() [*c]ImGuiWindowClass;
pub extern fn ImGuiWindowClass_destroy(self: [*c]ImGuiWindowClass) void;
pub extern fn ImGuiPayload_ImGuiPayload() [*c]ImGuiPayload;
pub extern fn ImGuiPayload_destroy(self: [*c]ImGuiPayload) void;
pub extern fn ImGuiPayload_Clear(self: [*c]ImGuiPayload) void;
pub extern fn ImGuiPayload_IsDataType(self: [*c]ImGuiPayload, @"type": [*c]const u8) bool;
pub extern fn ImGuiPayload_IsPreview(self: [*c]ImGuiPayload) bool;
pub extern fn ImGuiPayload_IsDelivery(self: [*c]ImGuiPayload) bool;
pub extern fn ImGuiTableColumnSortSpecs_ImGuiTableColumnSortSpecs() ?*ImGuiTableColumnSortSpecs;
pub extern fn ImGuiTableColumnSortSpecs_destroy(self: ?*ImGuiTableColumnSortSpecs) void;
pub extern fn ImGuiTableSortSpecs_ImGuiTableSortSpecs() [*c]ImGuiTableSortSpecs;
pub extern fn ImGuiTableSortSpecs_destroy(self: [*c]ImGuiTableSortSpecs) void;
pub extern fn ImGuiOnceUponAFrame_ImGuiOnceUponAFrame() [*c]ImGuiOnceUponAFrame;
pub extern fn ImGuiOnceUponAFrame_destroy(self: [*c]ImGuiOnceUponAFrame) void;
pub extern fn ImGuiTextFilter_ImGuiTextFilter(default_filter: [*c]const u8) [*c]ImGuiTextFilter;
pub extern fn ImGuiTextFilter_destroy(self: [*c]ImGuiTextFilter) void;
pub extern fn ImGuiTextFilter_Draw(self: [*c]ImGuiTextFilter, label: [*c]const u8, width: f32) bool;
pub extern fn ImGuiTextFilter_PassFilter(self: [*c]ImGuiTextFilter, text: [*c]const u8, text_end: [*c]const u8) bool;
pub extern fn ImGuiTextFilter_Build(self: [*c]ImGuiTextFilter) void;
pub extern fn ImGuiTextFilter_Clear(self: [*c]ImGuiTextFilter) void;
pub extern fn ImGuiTextFilter_IsActive(self: [*c]ImGuiTextFilter) bool;
pub extern fn ImGuiTextRange_ImGuiTextRange_Nil() [*c]ImGuiTextRange;
pub extern fn ImGuiTextRange_destroy(self: [*c]ImGuiTextRange) void;
pub extern fn ImGuiTextRange_ImGuiTextRange_Str(_b: [*c]const u8, _e: [*c]const u8) [*c]ImGuiTextRange;
pub extern fn ImGuiTextRange_empty(self: [*c]ImGuiTextRange) bool;
pub extern fn ImGuiTextRange_split(self: [*c]ImGuiTextRange, separator: u8, out: [*c]ImVector_ImGuiTextRange) void;
pub extern fn ImGuiTextBuffer_ImGuiTextBuffer() [*c]ImGuiTextBuffer;
pub extern fn ImGuiTextBuffer_destroy(self: [*c]ImGuiTextBuffer) void;
pub extern fn ImGuiTextBuffer_begin(self: [*c]ImGuiTextBuffer) [*c]const u8;
pub extern fn ImGuiTextBuffer_end(self: [*c]ImGuiTextBuffer) [*c]const u8;
pub extern fn ImGuiTextBuffer_size(self: [*c]ImGuiTextBuffer) c_int;
pub extern fn ImGuiTextBuffer_empty(self: [*c]ImGuiTextBuffer) bool;
pub extern fn ImGuiTextBuffer_clear(self: [*c]ImGuiTextBuffer) void;
pub extern fn ImGuiTextBuffer_reserve(self: [*c]ImGuiTextBuffer, capacity: c_int) void;
pub extern fn ImGuiTextBuffer_c_str(self: [*c]ImGuiTextBuffer) [*c]const u8;
pub extern fn ImGuiTextBuffer_append(self: [*c]ImGuiTextBuffer, str: [*c]const u8, str_end: [*c]const u8) void;
pub extern fn ImGuiTextBuffer_appendfv(self: [*c]ImGuiTextBuffer, fmt: [*c]const u8, args: va_list) void;
pub extern fn ImGuiStoragePair_ImGuiStoragePair_Int(_key: ImGuiID, _val_i: c_int) [*c]ImGuiStoragePair;
pub extern fn ImGuiStoragePair_destroy(self: [*c]ImGuiStoragePair) void;
pub extern fn ImGuiStoragePair_ImGuiStoragePair_Float(_key: ImGuiID, _val_f: f32) [*c]ImGuiStoragePair;
pub extern fn ImGuiStoragePair_ImGuiStoragePair_Ptr(_key: ImGuiID, _val_p: ?*anyopaque) [*c]ImGuiStoragePair;
pub extern fn ImGuiStorage_Clear(self: [*c]ImGuiStorage) void;
pub extern fn ImGuiStorage_GetInt(self: [*c]ImGuiStorage, key: ImGuiID, default_val: c_int) c_int;
pub extern fn ImGuiStorage_SetInt(self: [*c]ImGuiStorage, key: ImGuiID, val: c_int) void;
pub extern fn ImGuiStorage_GetBool(self: [*c]ImGuiStorage, key: ImGuiID, default_val: bool) bool;
pub extern fn ImGuiStorage_SetBool(self: [*c]ImGuiStorage, key: ImGuiID, val: bool) void;
pub extern fn ImGuiStorage_GetFloat(self: [*c]ImGuiStorage, key: ImGuiID, default_val: f32) f32;
pub extern fn ImGuiStorage_SetFloat(self: [*c]ImGuiStorage, key: ImGuiID, val: f32) void;
pub extern fn ImGuiStorage_GetVoidPtr(self: [*c]ImGuiStorage, key: ImGuiID) ?*anyopaque;
pub extern fn ImGuiStorage_SetVoidPtr(self: [*c]ImGuiStorage, key: ImGuiID, val: ?*anyopaque) void;
pub extern fn ImGuiStorage_GetIntRef(self: [*c]ImGuiStorage, key: ImGuiID, default_val: c_int) [*c]c_int;
pub extern fn ImGuiStorage_GetBoolRef(self: [*c]ImGuiStorage, key: ImGuiID, default_val: bool) [*c]bool;
pub extern fn ImGuiStorage_GetFloatRef(self: [*c]ImGuiStorage, key: ImGuiID, default_val: f32) [*c]f32;
pub extern fn ImGuiStorage_GetVoidPtrRef(self: [*c]ImGuiStorage, key: ImGuiID, default_val: ?*anyopaque) [*c]?*anyopaque;
pub extern fn ImGuiStorage_SetAllInt(self: [*c]ImGuiStorage, val: c_int) void;
pub extern fn ImGuiStorage_BuildSortByKey(self: [*c]ImGuiStorage) void;
pub extern fn ImGuiListClipper_ImGuiListClipper() [*c]ImGuiListClipper;
pub extern fn ImGuiListClipper_destroy(self: [*c]ImGuiListClipper) void;
pub extern fn ImGuiListClipper_Begin(self: [*c]ImGuiListClipper, items_count: c_int, items_height: f32) void;
pub extern fn ImGuiListClipper_End(self: [*c]ImGuiListClipper) void;
pub extern fn ImGuiListClipper_Step(self: [*c]ImGuiListClipper) bool;
pub extern fn ImGuiListClipper_IncludeItemByIndex(self: [*c]ImGuiListClipper, item_index: c_int) void;
pub extern fn ImGuiListClipper_IncludeItemsByIndex(self: [*c]ImGuiListClipper, item_begin: c_int, item_end: c_int) void;
pub extern fn ImColor_ImColor_Nil() [*c]ImColor;
pub extern fn ImColor_destroy(self: [*c]ImColor) void;
pub extern fn ImColor_ImColor_Float(r: f32, g: f32, b: f32, a: f32) [*c]ImColor;
pub extern fn ImColor_ImColor_Vec4(col: ImVec4) [*c]ImColor;
pub extern fn ImColor_ImColor_Int(r: c_int, g: c_int, b: c_int, a: c_int) [*c]ImColor;
pub extern fn ImColor_ImColor_U32(rgba: ImU32) [*c]ImColor;
pub extern fn ImColor_SetHSV(self: [*c]ImColor, h: f32, s: f32, v: f32, a: f32) void;
pub extern fn ImColor_HSV(pOut: [*c]ImColor, h: f32, s: f32, v: f32, a: f32) void;
pub extern fn ImDrawCmd_ImDrawCmd() [*c]ImDrawCmd;
pub extern fn ImDrawCmd_destroy(self: [*c]ImDrawCmd) void;
pub extern fn ImDrawCmd_GetTexID(self: [*c]ImDrawCmd) ImTextureID;
pub extern fn ImDrawListSplitter_ImDrawListSplitter() [*c]ImDrawListSplitter;
pub extern fn ImDrawListSplitter_destroy(self: [*c]ImDrawListSplitter) void;
pub extern fn ImDrawListSplitter_Clear(self: [*c]ImDrawListSplitter) void;
pub extern fn ImDrawListSplitter_ClearFreeMemory(self: [*c]ImDrawListSplitter) void;
pub extern fn ImDrawListSplitter_Split(self: [*c]ImDrawListSplitter, draw_list: [*c]ImDrawList, count: c_int) void;
pub extern fn ImDrawListSplitter_Merge(self: [*c]ImDrawListSplitter, draw_list: [*c]ImDrawList) void;
pub extern fn ImDrawListSplitter_SetCurrentChannel(self: [*c]ImDrawListSplitter, draw_list: [*c]ImDrawList, channel_idx: c_int) void;
pub extern fn ImDrawList_ImDrawList(shared_data: [*c]ImDrawListSharedData) [*c]ImDrawList;
pub extern fn ImDrawList_destroy(self: [*c]ImDrawList) void;
pub extern fn ImDrawList_PushClipRect(self: [*c]ImDrawList, clip_rect_min: ImVec2, clip_rect_max: ImVec2, intersect_with_current_clip_rect: bool) void;
pub extern fn ImDrawList_PushClipRectFullScreen(self: [*c]ImDrawList) void;
pub extern fn ImDrawList_PopClipRect(self: [*c]ImDrawList) void;
pub extern fn ImDrawList_PushTextureID(self: [*c]ImDrawList, texture_id: ImTextureID) void;
pub extern fn ImDrawList_PopTextureID(self: [*c]ImDrawList) void;
pub extern fn ImDrawList_GetClipRectMin(pOut: [*c]ImVec2, self: [*c]ImDrawList) void;
pub extern fn ImDrawList_GetClipRectMax(pOut: [*c]ImVec2, self: [*c]ImDrawList) void;
pub extern fn ImDrawList_AddLine(self: [*c]ImDrawList, p1: ImVec2, p2: ImVec2, col: ImU32, thickness: f32) void;
pub extern fn ImDrawList_AddRect(self: [*c]ImDrawList, p_min: ImVec2, p_max: ImVec2, col: ImU32, rounding: f32, flags: ImDrawFlags, thickness: f32) void;
pub extern fn ImDrawList_AddRectFilled(self: [*c]ImDrawList, p_min: ImVec2, p_max: ImVec2, col: ImU32, rounding: f32, flags: ImDrawFlags) void;
pub extern fn ImDrawList_AddRectFilledMultiColor(self: [*c]ImDrawList, p_min: ImVec2, p_max: ImVec2, col_upr_left: ImU32, col_upr_right: ImU32, col_bot_right: ImU32, col_bot_left: ImU32) void;
pub extern fn ImDrawList_AddQuad(self: [*c]ImDrawList, p1: ImVec2, p2: ImVec2, p3: ImVec2, p4: ImVec2, col: ImU32, thickness: f32) void;
pub extern fn ImDrawList_AddQuadFilled(self: [*c]ImDrawList, p1: ImVec2, p2: ImVec2, p3: ImVec2, p4: ImVec2, col: ImU32) void;
pub extern fn ImDrawList_AddTriangle(self: [*c]ImDrawList, p1: ImVec2, p2: ImVec2, p3: ImVec2, col: ImU32, thickness: f32) void;
pub extern fn ImDrawList_AddTriangleFilled(self: [*c]ImDrawList, p1: ImVec2, p2: ImVec2, p3: ImVec2, col: ImU32) void;
pub extern fn ImDrawList_AddCircle(self: [*c]ImDrawList, center: ImVec2, radius: f32, col: ImU32, num_segments: c_int, thickness: f32) void;
pub extern fn ImDrawList_AddCircleFilled(self: [*c]ImDrawList, center: ImVec2, radius: f32, col: ImU32, num_segments: c_int) void;
pub extern fn ImDrawList_AddNgon(self: [*c]ImDrawList, center: ImVec2, radius: f32, col: ImU32, num_segments: c_int, thickness: f32) void;
pub extern fn ImDrawList_AddNgonFilled(self: [*c]ImDrawList, center: ImVec2, radius: f32, col: ImU32, num_segments: c_int) void;
pub extern fn ImDrawList_AddText_Vec2(self: [*c]ImDrawList, pos: ImVec2, col: ImU32, text_begin: [*c]const u8, text_end: [*c]const u8) void;
pub extern fn ImDrawList_AddText_FontPtr(self: [*c]ImDrawList, font: [*c]const ImFont, font_size: f32, pos: ImVec2, col: ImU32, text_begin: [*c]const u8, text_end: [*c]const u8, wrap_width: f32, cpu_fine_clip_rect: [*c]const ImVec4) void;
pub extern fn ImDrawList_AddPolyline(self: [*c]ImDrawList, points: [*c]const ImVec2, num_points: c_int, col: ImU32, flags: ImDrawFlags, thickness: f32) void;
pub extern fn ImDrawList_AddConvexPolyFilled(self: [*c]ImDrawList, points: [*c]const ImVec2, num_points: c_int, col: ImU32) void;
pub extern fn ImDrawList_AddBezierCubic(self: [*c]ImDrawList, p1: ImVec2, p2: ImVec2, p3: ImVec2, p4: ImVec2, col: ImU32, thickness: f32, num_segments: c_int) void;
pub extern fn ImDrawList_AddBezierQuadratic(self: [*c]ImDrawList, p1: ImVec2, p2: ImVec2, p3: ImVec2, col: ImU32, thickness: f32, num_segments: c_int) void;
pub extern fn ImDrawList_AddImage(self: [*c]ImDrawList, user_texture_id: ImTextureID, p_min: ImVec2, p_max: ImVec2, uv_min: ImVec2, uv_max: ImVec2, col: ImU32) void;
pub extern fn ImDrawList_AddImageQuad(self: [*c]ImDrawList, user_texture_id: ImTextureID, p1: ImVec2, p2: ImVec2, p3: ImVec2, p4: ImVec2, uv1: ImVec2, uv2: ImVec2, uv3: ImVec2, uv4: ImVec2, col: ImU32) void;
pub extern fn ImDrawList_AddImageRounded(self: [*c]ImDrawList, user_texture_id: ImTextureID, p_min: ImVec2, p_max: ImVec2, uv_min: ImVec2, uv_max: ImVec2, col: ImU32, rounding: f32, flags: ImDrawFlags) void;
pub extern fn ImDrawList_PathClear(self: [*c]ImDrawList) void;
pub extern fn ImDrawList_PathLineTo(self: [*c]ImDrawList, pos: ImVec2) void;
pub extern fn ImDrawList_PathLineToMergeDuplicate(self: [*c]ImDrawList, pos: ImVec2) void;
pub extern fn ImDrawList_PathFillConvex(self: [*c]ImDrawList, col: ImU32) void;
pub extern fn ImDrawList_PathStroke(self: [*c]ImDrawList, col: ImU32, flags: ImDrawFlags, thickness: f32) void;
pub extern fn ImDrawList_PathArcTo(self: [*c]ImDrawList, center: ImVec2, radius: f32, a_min: f32, a_max: f32, num_segments: c_int) void;
pub extern fn ImDrawList_PathArcToFast(self: [*c]ImDrawList, center: ImVec2, radius: f32, a_min_of_12: c_int, a_max_of_12: c_int) void;
pub extern fn ImDrawList_PathBezierCubicCurveTo(self: [*c]ImDrawList, p2: ImVec2, p3: ImVec2, p4: ImVec2, num_segments: c_int) void;
pub extern fn ImDrawList_PathBezierQuadraticCurveTo(self: [*c]ImDrawList, p2: ImVec2, p3: ImVec2, num_segments: c_int) void;
pub extern fn ImDrawList_PathRect(self: [*c]ImDrawList, rect_min: ImVec2, rect_max: ImVec2, rounding: f32, flags: ImDrawFlags) void;
pub extern fn ImDrawList_AddCallback(self: [*c]ImDrawList, callback: ImDrawCallback, callback_data: ?*anyopaque) void;
pub extern fn ImDrawList_AddDrawCmd(self: [*c]ImDrawList) void;
pub extern fn ImDrawList_CloneOutput(self: [*c]ImDrawList) [*c]ImDrawList;
pub extern fn ImDrawList_ChannelsSplit(self: [*c]ImDrawList, count: c_int) void;
pub extern fn ImDrawList_ChannelsMerge(self: [*c]ImDrawList) void;
pub extern fn ImDrawList_ChannelsSetCurrent(self: [*c]ImDrawList, n: c_int) void;
pub extern fn ImDrawList_PrimReserve(self: [*c]ImDrawList, idx_count: c_int, vtx_count: c_int) void;
pub extern fn ImDrawList_PrimUnreserve(self: [*c]ImDrawList, idx_count: c_int, vtx_count: c_int) void;
pub extern fn ImDrawList_PrimRect(self: [*c]ImDrawList, a: ImVec2, b: ImVec2, col: ImU32) void;
pub extern fn ImDrawList_PrimRectUV(self: [*c]ImDrawList, a: ImVec2, b: ImVec2, uv_a: ImVec2, uv_b: ImVec2, col: ImU32) void;
pub extern fn ImDrawList_PrimQuadUV(self: [*c]ImDrawList, a: ImVec2, b: ImVec2, c: ImVec2, d: ImVec2, uv_a: ImVec2, uv_b: ImVec2, uv_c: ImVec2, uv_d: ImVec2, col: ImU32) void;
pub extern fn ImDrawList_PrimWriteVtx(self: [*c]ImDrawList, pos: ImVec2, uv: ImVec2, col: ImU32) void;
pub extern fn ImDrawList_PrimWriteIdx(self: [*c]ImDrawList, idx: ImDrawIdx) void;
pub extern fn ImDrawList_PrimVtx(self: [*c]ImDrawList, pos: ImVec2, uv: ImVec2, col: ImU32) void;
pub extern fn ImDrawList__ResetForNewFrame(self: [*c]ImDrawList) void;
pub extern fn ImDrawList__ClearFreeMemory(self: [*c]ImDrawList) void;
pub extern fn ImDrawList__PopUnusedDrawCmd(self: [*c]ImDrawList) void;
pub extern fn ImDrawList__TryMergeDrawCmds(self: [*c]ImDrawList) void;
pub extern fn ImDrawList__OnChangedClipRect(self: [*c]ImDrawList) void;
pub extern fn ImDrawList__OnChangedTextureID(self: [*c]ImDrawList) void;
pub extern fn ImDrawList__OnChangedVtxOffset(self: [*c]ImDrawList) void;
pub extern fn ImDrawList__CalcCircleAutoSegmentCount(self: [*c]ImDrawList, radius: f32) c_int;
pub extern fn ImDrawList__PathArcToFastEx(self: [*c]ImDrawList, center: ImVec2, radius: f32, a_min_sample: c_int, a_max_sample: c_int, a_step: c_int) void;
pub extern fn ImDrawList__PathArcToN(self: [*c]ImDrawList, center: ImVec2, radius: f32, a_min: f32, a_max: f32, num_segments: c_int) void;
pub extern fn ImDrawData_ImDrawData() [*c]ImDrawData;
pub extern fn ImDrawData_destroy(self: [*c]ImDrawData) void;
pub extern fn ImDrawData_Clear(self: [*c]ImDrawData) void;
pub extern fn ImDrawData_AddDrawList(self: [*c]ImDrawData, draw_list: [*c]ImDrawList) void;
pub extern fn ImDrawData_DeIndexAllBuffers(self: [*c]ImDrawData) void;
pub extern fn ImDrawData_ScaleClipRects(self: [*c]ImDrawData, fb_scale: ImVec2) void;
pub extern fn ImFontConfig_ImFontConfig() [*c]ImFontConfig;
pub extern fn ImFontConfig_destroy(self: [*c]ImFontConfig) void;
pub extern fn ImFontGlyphRangesBuilder_ImFontGlyphRangesBuilder() [*c]ImFontGlyphRangesBuilder;
pub extern fn ImFontGlyphRangesBuilder_destroy(self: [*c]ImFontGlyphRangesBuilder) void;
pub extern fn ImFontGlyphRangesBuilder_Clear(self: [*c]ImFontGlyphRangesBuilder) void;
pub extern fn ImFontGlyphRangesBuilder_GetBit(self: [*c]ImFontGlyphRangesBuilder, n: usize) bool;
pub extern fn ImFontGlyphRangesBuilder_SetBit(self: [*c]ImFontGlyphRangesBuilder, n: usize) void;
pub extern fn ImFontGlyphRangesBuilder_AddChar(self: [*c]ImFontGlyphRangesBuilder, c: ImWchar) void;
pub extern fn ImFontGlyphRangesBuilder_AddText(self: [*c]ImFontGlyphRangesBuilder, text: [*c]const u8, text_end: [*c]const u8) void;
pub extern fn ImFontGlyphRangesBuilder_AddRanges(self: [*c]ImFontGlyphRangesBuilder, ranges: [*c]const ImWchar) void;
pub extern fn ImFontGlyphRangesBuilder_BuildRanges(self: [*c]ImFontGlyphRangesBuilder, out_ranges: [*c]ImVector_ImWchar) void;
pub extern fn ImFontAtlasCustomRect_ImFontAtlasCustomRect() [*c]ImFontAtlasCustomRect;
pub extern fn ImFontAtlasCustomRect_destroy(self: [*c]ImFontAtlasCustomRect) void;
pub extern fn ImFontAtlasCustomRect_IsPacked(self: [*c]ImFontAtlasCustomRect) bool;
pub extern fn ImFontAtlas_ImFontAtlas() [*c]ImFontAtlas;
pub extern fn ImFontAtlas_destroy(self: [*c]ImFontAtlas) void;
pub extern fn ImFontAtlas_AddFont(self: [*c]ImFontAtlas, font_cfg: [*c]const ImFontConfig) [*c]ImFont;
pub extern fn ImFontAtlas_AddFontDefault(self: [*c]ImFontAtlas, font_cfg: [*c]const ImFontConfig) [*c]ImFont;
pub extern fn ImFontAtlas_AddFontFromFileTTF(self: [*c]ImFontAtlas, filename: [*c]const u8, size_pixels: f32, font_cfg: [*c]const ImFontConfig, glyph_ranges: [*c]const ImWchar) [*c]ImFont;
pub extern fn ImFontAtlas_AddFontFromMemoryTTF(self: [*c]ImFontAtlas, font_data: ?*anyopaque, font_size: c_int, size_pixels: f32, font_cfg: [*c]const ImFontConfig, glyph_ranges: [*c]const ImWchar) [*c]ImFont;
pub extern fn ImFontAtlas_AddFontFromMemoryCompressedTTF(self: [*c]ImFontAtlas, compressed_font_data: ?*const anyopaque, compressed_font_size: c_int, size_pixels: f32, font_cfg: [*c]const ImFontConfig, glyph_ranges: [*c]const ImWchar) [*c]ImFont;
pub extern fn ImFontAtlas_AddFontFromMemoryCompressedBase85TTF(self: [*c]ImFontAtlas, compressed_font_data_base85: [*c]const u8, size_pixels: f32, font_cfg: [*c]const ImFontConfig, glyph_ranges: [*c]const ImWchar) [*c]ImFont;
pub extern fn ImFontAtlas_ClearInputData(self: [*c]ImFontAtlas) void;
pub extern fn ImFontAtlas_ClearTexData(self: [*c]ImFontAtlas) void;
pub extern fn ImFontAtlas_ClearFonts(self: [*c]ImFontAtlas) void;
pub extern fn ImFontAtlas_Clear(self: [*c]ImFontAtlas) void;
pub extern fn ImFontAtlas_Build(self: [*c]ImFontAtlas) bool;
pub extern fn ImFontAtlas_GetTexDataAsAlpha8(self: [*c]ImFontAtlas, out_pixels: [*c][*c]u8, out_width: [*c]c_int, out_height: [*c]c_int, out_bytes_per_pixel: [*c]c_int) void;
pub extern fn ImFontAtlas_GetTexDataAsRGBA32(self: [*c]ImFontAtlas, out_pixels: [*c][*c]u8, out_width: [*c]c_int, out_height: [*c]c_int, out_bytes_per_pixel: [*c]c_int) void;
pub extern fn ImFontAtlas_IsBuilt(self: [*c]ImFontAtlas) bool;
pub extern fn ImFontAtlas_SetTexID(self: [*c]ImFontAtlas, id: ImTextureID) void;
pub extern fn ImFontAtlas_GetGlyphRangesDefault(self: [*c]ImFontAtlas) [*c]const ImWchar;
pub extern fn ImFontAtlas_GetGlyphRangesGreek(self: [*c]ImFontAtlas) [*c]const ImWchar;
pub extern fn ImFontAtlas_GetGlyphRangesKorean(self: [*c]ImFontAtlas) [*c]const ImWchar;
pub extern fn ImFontAtlas_GetGlyphRangesJapanese(self: [*c]ImFontAtlas) [*c]const ImWchar;
pub extern fn ImFontAtlas_GetGlyphRangesChineseFull(self: [*c]ImFontAtlas) [*c]const ImWchar;
pub extern fn ImFontAtlas_GetGlyphRangesChineseSimplifiedCommon(self: [*c]ImFontAtlas) [*c]const ImWchar;
pub extern fn ImFontAtlas_GetGlyphRangesCyrillic(self: [*c]ImFontAtlas) [*c]const ImWchar;
pub extern fn ImFontAtlas_GetGlyphRangesThai(self: [*c]ImFontAtlas) [*c]const ImWchar;
pub extern fn ImFontAtlas_GetGlyphRangesVietnamese(self: [*c]ImFontAtlas) [*c]const ImWchar;
pub extern fn ImFontAtlas_AddCustomRectRegular(self: [*c]ImFontAtlas, width: c_int, height: c_int) c_int;
pub extern fn ImFontAtlas_AddCustomRectFontGlyph(self: [*c]ImFontAtlas, font: [*c]ImFont, id: ImWchar, width: c_int, height: c_int, advance_x: f32, offset: ImVec2) c_int;
pub extern fn ImFontAtlas_GetCustomRectByIndex(self: [*c]ImFontAtlas, index: c_int) [*c]ImFontAtlasCustomRect;
pub extern fn ImFontAtlas_CalcCustomRectUV(self: [*c]ImFontAtlas, rect: [*c]const ImFontAtlasCustomRect, out_uv_min: [*c]ImVec2, out_uv_max: [*c]ImVec2) void;
pub extern fn ImFontAtlas_GetMouseCursorTexData(self: [*c]ImFontAtlas, cursor: ImGuiMouseCursor, out_offset: [*c]ImVec2, out_size: [*c]ImVec2, out_uv_border: [*c]ImVec2, out_uv_fill: [*c]ImVec2) bool;
pub extern fn ImFont_ImFont() [*c]ImFont;
pub extern fn ImFont_destroy(self: [*c]ImFont) void;
pub extern fn ImFont_FindGlyph(self: [*c]ImFont, c: ImWchar) ?*const ImFontGlyph;
pub extern fn ImFont_FindGlyphNoFallback(self: [*c]ImFont, c: ImWchar) ?*const ImFontGlyph;
pub extern fn ImFont_GetCharAdvance(self: [*c]ImFont, c: ImWchar) f32;
pub extern fn ImFont_IsLoaded(self: [*c]ImFont) bool;
pub extern fn ImFont_GetDebugName(self: [*c]ImFont) [*c]const u8;
pub extern fn ImFont_CalcTextSizeA(pOut: [*c]ImVec2, self: [*c]ImFont, size: f32, max_width: f32, wrap_width: f32, text_begin: [*c]const u8, text_end: [*c]const u8, remaining: [*c][*c]const u8) void;
pub extern fn ImFont_CalcWordWrapPositionA(self: [*c]ImFont, scale: f32, text: [*c]const u8, text_end: [*c]const u8, wrap_width: f32) [*c]const u8;
pub extern fn ImFont_RenderChar(self: [*c]ImFont, draw_list: [*c]ImDrawList, size: f32, pos: ImVec2, col: ImU32, c: ImWchar) void;
pub extern fn ImFont_RenderText(self: [*c]ImFont, draw_list: [*c]ImDrawList, size: f32, pos: ImVec2, col: ImU32, clip_rect: ImVec4, text_begin: [*c]const u8, text_end: [*c]const u8, wrap_width: f32, cpu_fine_clip: bool) void;
pub extern fn ImFont_BuildLookupTable(self: [*c]ImFont) void;
pub extern fn ImFont_ClearOutputData(self: [*c]ImFont) void;
pub extern fn ImFont_GrowIndex(self: [*c]ImFont, new_size: c_int) void;
pub extern fn ImFont_AddGlyph(self: [*c]ImFont, src_cfg: [*c]const ImFontConfig, c: ImWchar, x0: f32, y0: f32, x1: f32, y1: f32, @"u0": f32, v0: f32, @"u1": f32, v1: f32, advance_x: f32) void;
pub extern fn ImFont_AddRemapChar(self: [*c]ImFont, dst: ImWchar, src: ImWchar, overwrite_dst: bool) void;
pub extern fn ImFont_SetGlyphVisible(self: [*c]ImFont, c: ImWchar, visible: bool) void;
pub extern fn ImFont_IsGlyphRangeUnused(self: [*c]ImFont, c_begin: c_uint, c_last: c_uint) bool;
pub extern fn ImGuiViewport_ImGuiViewport() [*c]ImGuiViewport;
pub extern fn ImGuiViewport_destroy(self: [*c]ImGuiViewport) void;
pub extern fn ImGuiViewport_GetCenter(pOut: [*c]ImVec2, self: [*c]ImGuiViewport) void;
pub extern fn ImGuiViewport_GetWorkCenter(pOut: [*c]ImVec2, self: [*c]ImGuiViewport) void;
pub extern fn ImGuiPlatformIO_ImGuiPlatformIO() [*c]ImGuiPlatformIO;
pub extern fn ImGuiPlatformIO_destroy(self: [*c]ImGuiPlatformIO) void;
pub extern fn ImGuiPlatformMonitor_ImGuiPlatformMonitor() [*c]ImGuiPlatformMonitor;
pub extern fn ImGuiPlatformMonitor_destroy(self: [*c]ImGuiPlatformMonitor) void;
pub extern fn ImGuiPlatformImeData_ImGuiPlatformImeData() [*c]ImGuiPlatformImeData;
pub extern fn ImGuiPlatformImeData_destroy(self: [*c]ImGuiPlatformImeData) void;
pub extern fn igGetKeyIndex(key: ImGuiKey) ImGuiKey;
pub extern fn igImHashData(data: ?*const anyopaque, data_size: usize, seed: ImGuiID) ImGuiID;
pub extern fn igImHashStr(data: [*c]const u8, data_size: usize, seed: ImGuiID) ImGuiID;
pub extern fn igImQsort(base: ?*anyopaque, count: usize, size_of_element: usize, compare_func: ?*const fn (?*const anyopaque, ?*const anyopaque) callconv(.C) c_int) void;
pub extern fn igImAlphaBlendColors(col_a: ImU32, col_b: ImU32) ImU32;
pub extern fn igImIsPowerOfTwo_Int(v: c_int) bool;
pub extern fn igImIsPowerOfTwo_U64(v: ImU64) bool;
pub extern fn igImUpperPowerOfTwo(v: c_int) c_int;
pub extern fn igImStricmp(str1: [*c]const u8, str2: [*c]const u8) c_int;
pub extern fn igImStrnicmp(str1: [*c]const u8, str2: [*c]const u8, count: usize) c_int;
pub extern fn igImStrncpy(dst: [*c]u8, src: [*c]const u8, count: usize) void;
pub extern fn igImStrdup(str: [*c]const u8) [*c]u8;
pub extern fn igImStrdupcpy(dst: [*c]u8, p_dst_size: [*c]usize, str: [*c]const u8) [*c]u8;
pub extern fn igImStrchrRange(str_begin: [*c]const u8, str_end: [*c]const u8, c: u8) [*c]const u8;
pub extern fn igImStrlenW(str: [*c]const ImWchar) c_int;
pub extern fn igImStreolRange(str: [*c]const u8, str_end: [*c]const u8) [*c]const u8;
pub extern fn igImStrbolW(buf_mid_line: [*c]const ImWchar, buf_begin: [*c]const ImWchar) [*c]const ImWchar;
pub extern fn igImStristr(haystack: [*c]const u8, haystack_end: [*c]const u8, needle: [*c]const u8, needle_end: [*c]const u8) [*c]const u8;
pub extern fn igImStrTrimBlanks(str: [*c]u8) void;
pub extern fn igImStrSkipBlank(str: [*c]const u8) [*c]const u8;
pub extern fn igImToUpper(c: u8) u8;
pub extern fn igImCharIsBlankA(c: u8) bool;
pub extern fn igImCharIsBlankW(c: c_uint) bool;
pub extern fn igImFormatString(buf: [*c]u8, buf_size: usize, fmt: [*c]const u8, ...) c_int;
pub extern fn igImFormatStringV(buf: [*c]u8, buf_size: usize, fmt: [*c]const u8, args: va_list) c_int;
pub extern fn igImFormatStringToTempBuffer(out_buf: [*c][*c]const u8, out_buf_end: [*c][*c]const u8, fmt: [*c]const u8, ...) void;
pub extern fn igImFormatStringToTempBufferV(out_buf: [*c][*c]const u8, out_buf_end: [*c][*c]const u8, fmt: [*c]const u8, args: va_list) void;
pub extern fn igImParseFormatFindStart(format: [*c]const u8) [*c]const u8;
pub extern fn igImParseFormatFindEnd(format: [*c]const u8) [*c]const u8;
pub extern fn igImParseFormatTrimDecorations(format: [*c]const u8, buf: [*c]u8, buf_size: usize) [*c]const u8;
pub extern fn igImParseFormatSanitizeForPrinting(fmt_in: [*c]const u8, fmt_out: [*c]u8, fmt_out_size: usize) void;
pub extern fn igImParseFormatSanitizeForScanning(fmt_in: [*c]const u8, fmt_out: [*c]u8, fmt_out_size: usize) [*c]const u8;
pub extern fn igImParseFormatPrecision(format: [*c]const u8, default_value: c_int) c_int;
pub extern fn igImTextCharToUtf8(out_buf: [*c]u8, c: c_uint) [*c]const u8;
pub extern fn igImTextStrToUtf8(out_buf: [*c]u8, out_buf_size: c_int, in_text: [*c]const ImWchar, in_text_end: [*c]const ImWchar) c_int;
pub extern fn igImTextCharFromUtf8(out_char: [*c]c_uint, in_text: [*c]const u8, in_text_end: [*c]const u8) c_int;
pub extern fn igImTextStrFromUtf8(out_buf: [*c]ImWchar, out_buf_size: c_int, in_text: [*c]const u8, in_text_end: [*c]const u8, in_remaining: [*c][*c]const u8) c_int;
pub extern fn igImTextCountCharsFromUtf8(in_text: [*c]const u8, in_text_end: [*c]const u8) c_int;
pub extern fn igImTextCountUtf8BytesFromChar(in_text: [*c]const u8, in_text_end: [*c]const u8) c_int;
pub extern fn igImTextCountUtf8BytesFromStr(in_text: [*c]const ImWchar, in_text_end: [*c]const ImWchar) c_int;
pub extern fn igImFileOpen(filename: [*c]const u8, mode: [*c]const u8) ImFileHandle;
pub extern fn igImFileClose(file: ImFileHandle) bool;
pub extern fn igImFileGetSize(file: ImFileHandle) ImU64;
pub extern fn igImFileRead(data: ?*anyopaque, size: ImU64, count: ImU64, file: ImFileHandle) ImU64;
pub extern fn igImFileWrite(data: ?*const anyopaque, size: ImU64, count: ImU64, file: ImFileHandle) ImU64;
pub extern fn igImFileLoadToMemory(filename: [*c]const u8, mode: [*c]const u8, out_file_size: [*c]usize, padding_bytes: c_int) ?*anyopaque;
pub extern fn igImPow_Float(x: f32, y: f32) f32;
pub extern fn igImPow_double(x: f64, y: f64) f64;
pub extern fn igImLog_Float(x: f32) f32;
pub extern fn igImLog_double(x: f64) f64;
pub extern fn igImAbs_Int(x: c_int) c_int;
pub extern fn igImAbs_Float(x: f32) f32;
pub extern fn igImAbs_double(x: f64) f64;
pub extern fn igImSign_Float(x: f32) f32;
pub extern fn igImSign_double(x: f64) f64;
pub extern fn igImRsqrt_Float(x: f32) f32;
pub extern fn igImRsqrt_double(x: f64) f64;
pub extern fn igImMin(pOut: [*c]ImVec2, lhs: ImVec2, rhs: ImVec2) void;
pub extern fn igImMax(pOut: [*c]ImVec2, lhs: ImVec2, rhs: ImVec2) void;
pub extern fn igImClamp(pOut: [*c]ImVec2, v: ImVec2, mn: ImVec2, mx: ImVec2) void;
pub extern fn igImLerp_Vec2Float(pOut: [*c]ImVec2, a: ImVec2, b: ImVec2, t: f32) void;
pub extern fn igImLerp_Vec2Vec2(pOut: [*c]ImVec2, a: ImVec2, b: ImVec2, t: ImVec2) void;
pub extern fn igImLerp_Vec4(pOut: [*c]ImVec4, a: ImVec4, b: ImVec4, t: f32) void;
pub extern fn igImSaturate(f: f32) f32;
pub extern fn igImLengthSqr_Vec2(lhs: ImVec2) f32;
pub extern fn igImLengthSqr_Vec4(lhs: ImVec4) f32;
pub extern fn igImInvLength(lhs: ImVec2, fail_value: f32) f32;
pub extern fn igImFloor_Float(f: f32) f32;
pub extern fn igImFloorSigned_Float(f: f32) f32;
pub extern fn igImFloor_Vec2(pOut: [*c]ImVec2, v: ImVec2) void;
pub extern fn igImFloorSigned_Vec2(pOut: [*c]ImVec2, v: ImVec2) void;
pub extern fn igImModPositive(a: c_int, b: c_int) c_int;
pub extern fn igImDot(a: ImVec2, b: ImVec2) f32;
pub extern fn igImRotate(pOut: [*c]ImVec2, v: ImVec2, cos_a: f32, sin_a: f32) void;
pub extern fn igImLinearSweep(current: f32, target: f32, speed: f32) f32;
pub extern fn igImMul(pOut: [*c]ImVec2, lhs: ImVec2, rhs: ImVec2) void;
pub extern fn igImIsFloatAboveGuaranteedIntegerPrecision(f: f32) bool;
pub extern fn igImExponentialMovingAverage(avg: f32, sample: f32, n: c_int) f32;
pub extern fn igImBezierCubicCalc(pOut: [*c]ImVec2, p1: ImVec2, p2: ImVec2, p3: ImVec2, p4: ImVec2, t: f32) void;
pub extern fn igImBezierCubicClosestPoint(pOut: [*c]ImVec2, p1: ImVec2, p2: ImVec2, p3: ImVec2, p4: ImVec2, p: ImVec2, num_segments: c_int) void;
pub extern fn igImBezierCubicClosestPointCasteljau(pOut: [*c]ImVec2, p1: ImVec2, p2: ImVec2, p3: ImVec2, p4: ImVec2, p: ImVec2, tess_tol: f32) void;
pub extern fn igImBezierQuadraticCalc(pOut: [*c]ImVec2, p1: ImVec2, p2: ImVec2, p3: ImVec2, t: f32) void;
pub extern fn igImLineClosestPoint(pOut: [*c]ImVec2, a: ImVec2, b: ImVec2, p: ImVec2) void;
pub extern fn igImTriangleContainsPoint(a: ImVec2, b: ImVec2, c: ImVec2, p: ImVec2) bool;
pub extern fn igImTriangleClosestPoint(pOut: [*c]ImVec2, a: ImVec2, b: ImVec2, c: ImVec2, p: ImVec2) void;
pub extern fn igImTriangleBarycentricCoords(a: ImVec2, b: ImVec2, c: ImVec2, p: ImVec2, out_u: [*c]f32, out_v: [*c]f32, out_w: [*c]f32) void;
pub extern fn igImTriangleArea(a: ImVec2, b: ImVec2, c: ImVec2) f32;
pub extern fn ImVec1_ImVec1_Nil() [*c]ImVec1;
pub extern fn ImVec1_destroy(self: [*c]ImVec1) void;
pub extern fn ImVec1_ImVec1_Float(_x: f32) [*c]ImVec1;
pub extern fn ImVec2ih_ImVec2ih_Nil() [*c]ImVec2ih;
pub extern fn ImVec2ih_destroy(self: [*c]ImVec2ih) void;
pub extern fn ImVec2ih_ImVec2ih_short(_x: c_short, _y: c_short) [*c]ImVec2ih;
pub extern fn ImVec2ih_ImVec2ih_Vec2(rhs: ImVec2) [*c]ImVec2ih;
pub extern fn ImRect_ImRect_Nil() [*c]ImRect;
pub extern fn ImRect_destroy(self: [*c]ImRect) void;
pub extern fn ImRect_ImRect_Vec2(min: ImVec2, max: ImVec2) [*c]ImRect;
pub extern fn ImRect_ImRect_Vec4(v: ImVec4) [*c]ImRect;
pub extern fn ImRect_ImRect_Float(x1: f32, y1: f32, x2: f32, y2: f32) [*c]ImRect;
pub extern fn ImRect_GetCenter(pOut: [*c]ImVec2, self: [*c]ImRect) void;
pub extern fn ImRect_GetSize(pOut: [*c]ImVec2, self: [*c]ImRect) void;
pub extern fn ImRect_GetWidth(self: [*c]ImRect) f32;
pub extern fn ImRect_GetHeight(self: [*c]ImRect) f32;
pub extern fn ImRect_GetArea(self: [*c]ImRect) f32;
pub extern fn ImRect_GetTL(pOut: [*c]ImVec2, self: [*c]ImRect) void;
pub extern fn ImRect_GetTR(pOut: [*c]ImVec2, self: [*c]ImRect) void;
pub extern fn ImRect_GetBL(pOut: [*c]ImVec2, self: [*c]ImRect) void;
pub extern fn ImRect_GetBR(pOut: [*c]ImVec2, self: [*c]ImRect) void;
pub extern fn ImRect_Contains_Vec2(self: [*c]ImRect, p: ImVec2) bool;
pub extern fn ImRect_Contains_Rect(self: [*c]ImRect, r: ImRect) bool;
pub extern fn ImRect_Overlaps(self: [*c]ImRect, r: ImRect) bool;
pub extern fn ImRect_Add_Vec2(self: [*c]ImRect, p: ImVec2) void;
pub extern fn ImRect_Add_Rect(self: [*c]ImRect, r: ImRect) void;
pub extern fn ImRect_Expand_Float(self: [*c]ImRect, amount: f32) void;
pub extern fn ImRect_Expand_Vec2(self: [*c]ImRect, amount: ImVec2) void;
pub extern fn ImRect_Translate(self: [*c]ImRect, d: ImVec2) void;
pub extern fn ImRect_TranslateX(self: [*c]ImRect, dx: f32) void;
pub extern fn ImRect_TranslateY(self: [*c]ImRect, dy: f32) void;
pub extern fn ImRect_ClipWith(self: [*c]ImRect, r: ImRect) void;
pub extern fn ImRect_ClipWithFull(self: [*c]ImRect, r: ImRect) void;
pub extern fn ImRect_Floor(self: [*c]ImRect) void;
pub extern fn ImRect_IsInverted(self: [*c]ImRect) bool;
pub extern fn ImRect_ToVec4(pOut: [*c]ImVec4, self: [*c]ImRect) void;
pub extern fn igImBitArrayGetStorageSizeInBytes(bitcount: c_int) usize;
pub extern fn igImBitArrayClearAllBits(arr: [*c]ImU32, bitcount: c_int) void;
pub extern fn igImBitArrayTestBit(arr: [*c]const ImU32, n: c_int) bool;
pub extern fn igImBitArrayClearBit(arr: [*c]ImU32, n: c_int) void;
pub extern fn igImBitArraySetBit(arr: [*c]ImU32, n: c_int) void;
pub extern fn igImBitArraySetBitRange(arr: [*c]ImU32, n: c_int, n2: c_int) void;
pub extern fn ImBitVector_Create(self: [*c]ImBitVector, sz: c_int) void;
pub extern fn ImBitVector_Clear(self: [*c]ImBitVector) void;
pub extern fn ImBitVector_TestBit(self: [*c]ImBitVector, n: c_int) bool;
pub extern fn ImBitVector_SetBit(self: [*c]ImBitVector, n: c_int) void;
pub extern fn ImBitVector_ClearBit(self: [*c]ImBitVector, n: c_int) void;
pub extern fn ImGuiTextIndex_clear(self: [*c]ImGuiTextIndex) void;
pub extern fn ImGuiTextIndex_size(self: [*c]ImGuiTextIndex) c_int;
pub extern fn ImGuiTextIndex_get_line_begin(self: [*c]ImGuiTextIndex, base: [*c]const u8, n: c_int) [*c]const u8;
pub extern fn ImGuiTextIndex_get_line_end(self: [*c]ImGuiTextIndex, base: [*c]const u8, n: c_int) [*c]const u8;
pub extern fn ImGuiTextIndex_append(self: [*c]ImGuiTextIndex, base: [*c]const u8, old_size: c_int, new_size: c_int) void;
pub extern fn ImDrawListSharedData_ImDrawListSharedData() [*c]ImDrawListSharedData;
pub extern fn ImDrawListSharedData_destroy(self: [*c]ImDrawListSharedData) void;
pub extern fn ImDrawListSharedData_SetCircleTessellationMaxError(self: [*c]ImDrawListSharedData, max_error: f32) void;
pub extern fn ImDrawDataBuilder_ImDrawDataBuilder() [*c]ImDrawDataBuilder;
pub extern fn ImDrawDataBuilder_destroy(self: [*c]ImDrawDataBuilder) void;
pub extern fn ImGuiDataVarInfo_GetVarPtr(self: [*c]ImGuiDataVarInfo, parent: ?*anyopaque) ?*anyopaque;
pub extern fn ImGuiStyleMod_ImGuiStyleMod_Int(idx: ImGuiStyleVar, v: c_int) [*c]ImGuiStyleMod;
pub extern fn ImGuiStyleMod_destroy(self: [*c]ImGuiStyleMod) void;
pub extern fn ImGuiStyleMod_ImGuiStyleMod_Float(idx: ImGuiStyleVar, v: f32) [*c]ImGuiStyleMod;
pub extern fn ImGuiStyleMod_ImGuiStyleMod_Vec2(idx: ImGuiStyleVar, v: ImVec2) [*c]ImGuiStyleMod;
pub extern fn ImGuiComboPreviewData_ImGuiComboPreviewData() [*c]ImGuiComboPreviewData;
pub extern fn ImGuiComboPreviewData_destroy(self: [*c]ImGuiComboPreviewData) void;
pub extern fn ImGuiMenuColumns_ImGuiMenuColumns() [*c]ImGuiMenuColumns;
pub extern fn ImGuiMenuColumns_destroy(self: [*c]ImGuiMenuColumns) void;
pub extern fn ImGuiMenuColumns_Update(self: [*c]ImGuiMenuColumns, spacing: f32, window_reappearing: bool) void;
pub extern fn ImGuiMenuColumns_DeclColumns(self: [*c]ImGuiMenuColumns, w_icon: f32, w_label: f32, w_shortcut: f32, w_mark: f32) f32;
pub extern fn ImGuiMenuColumns_CalcNextTotalWidth(self: [*c]ImGuiMenuColumns, update_offsets: bool) void;
pub extern fn ImGuiInputTextDeactivatedState_ImGuiInputTextDeactivatedState() [*c]ImGuiInputTextDeactivatedState;
pub extern fn ImGuiInputTextDeactivatedState_destroy(self: [*c]ImGuiInputTextDeactivatedState) void;
pub extern fn ImGuiInputTextDeactivatedState_ClearFreeMemory(self: [*c]ImGuiInputTextDeactivatedState) void;
pub extern fn ImGuiInputTextState_ImGuiInputTextState() [*c]ImGuiInputTextState;
pub extern fn ImGuiInputTextState_destroy(self: [*c]ImGuiInputTextState) void;
pub extern fn ImGuiInputTextState_ClearText(self: [*c]ImGuiInputTextState) void;
pub extern fn ImGuiInputTextState_ClearFreeMemory(self: [*c]ImGuiInputTextState) void;
pub extern fn ImGuiInputTextState_GetUndoAvailCount(self: [*c]ImGuiInputTextState) c_int;
pub extern fn ImGuiInputTextState_GetRedoAvailCount(self: [*c]ImGuiInputTextState) c_int;
pub extern fn ImGuiInputTextState_OnKeyPressed(self: [*c]ImGuiInputTextState, key: c_int) void;
pub extern fn ImGuiInputTextState_CursorAnimReset(self: [*c]ImGuiInputTextState) void;
pub extern fn ImGuiInputTextState_CursorClamp(self: [*c]ImGuiInputTextState) void;
pub extern fn ImGuiInputTextState_HasSelection(self: [*c]ImGuiInputTextState) bool;
pub extern fn ImGuiInputTextState_ClearSelection(self: [*c]ImGuiInputTextState) void;
pub extern fn ImGuiInputTextState_GetCursorPos(self: [*c]ImGuiInputTextState) c_int;
pub extern fn ImGuiInputTextState_GetSelectionStart(self: [*c]ImGuiInputTextState) c_int;
pub extern fn ImGuiInputTextState_GetSelectionEnd(self: [*c]ImGuiInputTextState) c_int;
pub extern fn ImGuiInputTextState_SelectAll(self: [*c]ImGuiInputTextState) void;
pub extern fn ImGuiPopupData_ImGuiPopupData() [*c]ImGuiPopupData;
pub extern fn ImGuiPopupData_destroy(self: [*c]ImGuiPopupData) void;
pub extern fn ImGuiNextWindowData_ImGuiNextWindowData() [*c]ImGuiNextWindowData;
pub extern fn ImGuiNextWindowData_destroy(self: [*c]ImGuiNextWindowData) void;
pub extern fn ImGuiNextWindowData_ClearFlags(self: [*c]ImGuiNextWindowData) void;
pub extern fn ImGuiNextItemData_ImGuiNextItemData() [*c]ImGuiNextItemData;
pub extern fn ImGuiNextItemData_destroy(self: [*c]ImGuiNextItemData) void;
pub extern fn ImGuiNextItemData_ClearFlags(self: [*c]ImGuiNextItemData) void;
pub extern fn ImGuiLastItemData_ImGuiLastItemData() [*c]ImGuiLastItemData;
pub extern fn ImGuiLastItemData_destroy(self: [*c]ImGuiLastItemData) void;
pub extern fn ImGuiStackSizes_ImGuiStackSizes() [*c]ImGuiStackSizes;
pub extern fn ImGuiStackSizes_destroy(self: [*c]ImGuiStackSizes) void;
pub extern fn ImGuiStackSizes_SetToContextState(self: [*c]ImGuiStackSizes, ctx: [*c]ImGuiContext) void;
pub extern fn ImGuiStackSizes_CompareWithContextState(self: [*c]ImGuiStackSizes, ctx: [*c]ImGuiContext) void;
pub extern fn ImGuiPtrOrIndex_ImGuiPtrOrIndex_Ptr(ptr: ?*anyopaque) [*c]ImGuiPtrOrIndex;
pub extern fn ImGuiPtrOrIndex_destroy(self: [*c]ImGuiPtrOrIndex) void;
pub extern fn ImGuiPtrOrIndex_ImGuiPtrOrIndex_Int(index: c_int) [*c]ImGuiPtrOrIndex;
pub extern fn ImGuiInputEvent_ImGuiInputEvent() [*c]ImGuiInputEvent;
pub extern fn ImGuiInputEvent_destroy(self: [*c]ImGuiInputEvent) void;
pub extern fn ImGuiKeyRoutingData_ImGuiKeyRoutingData() [*c]ImGuiKeyRoutingData;
pub extern fn ImGuiKeyRoutingData_destroy(self: [*c]ImGuiKeyRoutingData) void;
pub extern fn ImGuiKeyRoutingTable_ImGuiKeyRoutingTable() [*c]ImGuiKeyRoutingTable;
pub extern fn ImGuiKeyRoutingTable_destroy(self: [*c]ImGuiKeyRoutingTable) void;
pub extern fn ImGuiKeyRoutingTable_Clear(self: [*c]ImGuiKeyRoutingTable) void;
pub extern fn ImGuiKeyOwnerData_ImGuiKeyOwnerData() [*c]ImGuiKeyOwnerData;
pub extern fn ImGuiKeyOwnerData_destroy(self: [*c]ImGuiKeyOwnerData) void;
pub extern fn ImGuiListClipperRange_FromIndices(min: c_int, max: c_int) ImGuiListClipperRange;
pub extern fn ImGuiListClipperRange_FromPositions(y1: f32, y2: f32, off_min: c_int, off_max: c_int) ImGuiListClipperRange;
pub extern fn ImGuiListClipperData_ImGuiListClipperData() [*c]ImGuiListClipperData;
pub extern fn ImGuiListClipperData_destroy(self: [*c]ImGuiListClipperData) void;
pub extern fn ImGuiListClipperData_Reset(self: [*c]ImGuiListClipperData, clipper: [*c]ImGuiListClipper) void;
pub extern fn ImGuiNavItemData_ImGuiNavItemData() [*c]ImGuiNavItemData;
pub extern fn ImGuiNavItemData_destroy(self: [*c]ImGuiNavItemData) void;
pub extern fn ImGuiNavItemData_Clear(self: [*c]ImGuiNavItemData) void;
pub extern fn ImGuiOldColumnData_ImGuiOldColumnData() [*c]ImGuiOldColumnData;
pub extern fn ImGuiOldColumnData_destroy(self: [*c]ImGuiOldColumnData) void;
pub extern fn ImGuiOldColumns_ImGuiOldColumns() [*c]ImGuiOldColumns;
pub extern fn ImGuiOldColumns_destroy(self: [*c]ImGuiOldColumns) void;
pub extern fn ImGuiDockNode_ImGuiDockNode(id: ImGuiID) ?*ImGuiDockNode;
pub extern fn ImGuiDockNode_destroy(self: ?*ImGuiDockNode) void;
pub extern fn ImGuiDockNode_IsRootNode(self: ?*ImGuiDockNode) bool;
pub extern fn ImGuiDockNode_IsDockSpace(self: ?*ImGuiDockNode) bool;
pub extern fn ImGuiDockNode_IsFloatingNode(self: ?*ImGuiDockNode) bool;
pub extern fn ImGuiDockNode_IsCentralNode(self: ?*ImGuiDockNode) bool;
pub extern fn ImGuiDockNode_IsHiddenTabBar(self: ?*ImGuiDockNode) bool;
pub extern fn ImGuiDockNode_IsNoTabBar(self: ?*ImGuiDockNode) bool;
pub extern fn ImGuiDockNode_IsSplitNode(self: ?*ImGuiDockNode) bool;
pub extern fn ImGuiDockNode_IsLeafNode(self: ?*ImGuiDockNode) bool;
pub extern fn ImGuiDockNode_IsEmpty(self: ?*ImGuiDockNode) bool;
pub extern fn ImGuiDockNode_Rect(pOut: [*c]ImRect, self: ?*ImGuiDockNode) void;
pub extern fn ImGuiDockNode_SetLocalFlags(self: ?*ImGuiDockNode, flags: ImGuiDockNodeFlags) void;
pub extern fn ImGuiDockNode_UpdateMergedFlags(self: ?*ImGuiDockNode) void;
pub extern fn ImGuiDockContext_ImGuiDockContext() [*c]ImGuiDockContext;
pub extern fn ImGuiDockContext_destroy(self: [*c]ImGuiDockContext) void;
pub extern fn ImGuiViewportP_ImGuiViewportP() [*c]ImGuiViewportP;
pub extern fn ImGuiViewportP_destroy(self: [*c]ImGuiViewportP) void;
pub extern fn ImGuiViewportP_ClearRequestFlags(self: [*c]ImGuiViewportP) void;
pub extern fn ImGuiViewportP_CalcWorkRectPos(pOut: [*c]ImVec2, self: [*c]ImGuiViewportP, off_min: ImVec2) void;
pub extern fn ImGuiViewportP_CalcWorkRectSize(pOut: [*c]ImVec2, self: [*c]ImGuiViewportP, off_min: ImVec2, off_max: ImVec2) void;
pub extern fn ImGuiViewportP_UpdateWorkRect(self: [*c]ImGuiViewportP) void;
pub extern fn ImGuiViewportP_GetMainRect(pOut: [*c]ImRect, self: [*c]ImGuiViewportP) void;
pub extern fn ImGuiViewportP_GetWorkRect(pOut: [*c]ImRect, self: [*c]ImGuiViewportP) void;
pub extern fn ImGuiViewportP_GetBuildWorkRect(pOut: [*c]ImRect, self: [*c]ImGuiViewportP) void;
pub extern fn ImGuiWindowSettings_ImGuiWindowSettings() [*c]ImGuiWindowSettings;
pub extern fn ImGuiWindowSettings_destroy(self: [*c]ImGuiWindowSettings) void;
pub extern fn ImGuiWindowSettings_GetName(self: [*c]ImGuiWindowSettings) [*c]u8;
pub extern fn ImGuiSettingsHandler_ImGuiSettingsHandler() [*c]ImGuiSettingsHandler;
pub extern fn ImGuiSettingsHandler_destroy(self: [*c]ImGuiSettingsHandler) void;
pub extern fn ImGuiStackLevelInfo_ImGuiStackLevelInfo() ?*ImGuiStackLevelInfo;
pub extern fn ImGuiStackLevelInfo_destroy(self: ?*ImGuiStackLevelInfo) void;
pub extern fn ImGuiStackTool_ImGuiStackTool() [*c]ImGuiStackTool;
pub extern fn ImGuiStackTool_destroy(self: [*c]ImGuiStackTool) void;
pub extern fn ImGuiContextHook_ImGuiContextHook() [*c]ImGuiContextHook;
pub extern fn ImGuiContextHook_destroy(self: [*c]ImGuiContextHook) void;
pub extern fn ImGuiContext_ImGuiContext(shared_font_atlas: [*c]ImFontAtlas) [*c]ImGuiContext;
pub extern fn ImGuiContext_destroy(self: [*c]ImGuiContext) void;
pub extern fn ImGuiWindow_ImGuiWindow(context: [*c]ImGuiContext, name: [*c]const u8) ?*ImGuiWindow;
pub extern fn ImGuiWindow_destroy(self: ?*ImGuiWindow) void;
pub extern fn ImGuiWindow_GetID_Str(self: ?*ImGuiWindow, str: [*c]const u8, str_end: [*c]const u8) ImGuiID;
pub extern fn ImGuiWindow_GetID_Ptr(self: ?*ImGuiWindow, ptr: ?*const anyopaque) ImGuiID;
pub extern fn ImGuiWindow_GetID_Int(self: ?*ImGuiWindow, n: c_int) ImGuiID;
pub extern fn ImGuiWindow_GetIDFromRectangle(self: ?*ImGuiWindow, r_abs: ImRect) ImGuiID;
pub extern fn ImGuiWindow_Rect(pOut: [*c]ImRect, self: ?*ImGuiWindow) void;
pub extern fn ImGuiWindow_CalcFontSize(self: ?*ImGuiWindow) f32;
pub extern fn ImGuiWindow_TitleBarHeight(self: ?*ImGuiWindow) f32;
pub extern fn ImGuiWindow_TitleBarRect(pOut: [*c]ImRect, self: ?*ImGuiWindow) void;
pub extern fn ImGuiWindow_MenuBarHeight(self: ?*ImGuiWindow) f32;
pub extern fn ImGuiWindow_MenuBarRect(pOut: [*c]ImRect, self: ?*ImGuiWindow) void;
pub extern fn ImGuiTabItem_ImGuiTabItem() [*c]ImGuiTabItem;
pub extern fn ImGuiTabItem_destroy(self: [*c]ImGuiTabItem) void;
pub extern fn ImGuiTabBar_ImGuiTabBar() [*c]ImGuiTabBar;
pub extern fn ImGuiTabBar_destroy(self: [*c]ImGuiTabBar) void;
pub extern fn ImGuiTableColumn_ImGuiTableColumn() ?*ImGuiTableColumn;
pub extern fn ImGuiTableColumn_destroy(self: ?*ImGuiTableColumn) void;
pub extern fn ImGuiTableInstanceData_ImGuiTableInstanceData() [*c]ImGuiTableInstanceData;
pub extern fn ImGuiTableInstanceData_destroy(self: [*c]ImGuiTableInstanceData) void;
pub extern fn ImGuiTable_ImGuiTable() ?*ImGuiTable;
pub extern fn ImGuiTable_destroy(self: ?*ImGuiTable) void;
pub extern fn ImGuiTableTempData_ImGuiTableTempData() [*c]ImGuiTableTempData;
pub extern fn ImGuiTableTempData_destroy(self: [*c]ImGuiTableTempData) void;
pub extern fn ImGuiTableColumnSettings_ImGuiTableColumnSettings() ?*ImGuiTableColumnSettings;
pub extern fn ImGuiTableColumnSettings_destroy(self: ?*ImGuiTableColumnSettings) void;
pub extern fn ImGuiTableSettings_ImGuiTableSettings() [*c]ImGuiTableSettings;
pub extern fn ImGuiTableSettings_destroy(self: [*c]ImGuiTableSettings) void;
pub extern fn ImGuiTableSettings_GetColumnSettings(self: [*c]ImGuiTableSettings) ?*ImGuiTableColumnSettings;
pub extern fn igGetCurrentWindowRead() ?*ImGuiWindow;
pub extern fn igGetCurrentWindow() ?*ImGuiWindow;
pub extern fn igFindWindowByID(id: ImGuiID) ?*ImGuiWindow;
pub extern fn igFindWindowByName(name: [*c]const u8) ?*ImGuiWindow;
pub extern fn igUpdateWindowParentAndRootLinks(window: ?*ImGuiWindow, flags: ImGuiWindowFlags, parent_window: ?*ImGuiWindow) void;
pub extern fn igCalcWindowNextAutoFitSize(pOut: [*c]ImVec2, window: ?*ImGuiWindow) void;
pub extern fn igIsWindowChildOf(window: ?*ImGuiWindow, potential_parent: ?*ImGuiWindow, popup_hierarchy: bool, dock_hierarchy: bool) bool;
pub extern fn igIsWindowWithinBeginStackOf(window: ?*ImGuiWindow, potential_parent: ?*ImGuiWindow) bool;
pub extern fn igIsWindowAbove(potential_above: ?*ImGuiWindow, potential_below: ?*ImGuiWindow) bool;
pub extern fn igIsWindowNavFocusable(window: ?*ImGuiWindow) bool;
pub extern fn igSetWindowPos_WindowPtr(window: ?*ImGuiWindow, pos: ImVec2, cond: ImGuiCond) void;
pub extern fn igSetWindowSize_WindowPtr(window: ?*ImGuiWindow, size: ImVec2, cond: ImGuiCond) void;
pub extern fn igSetWindowCollapsed_WindowPtr(window: ?*ImGuiWindow, collapsed: bool, cond: ImGuiCond) void;
pub extern fn igSetWindowHitTestHole(window: ?*ImGuiWindow, pos: ImVec2, size: ImVec2) void;
pub extern fn igSetWindowHiddendAndSkipItemsForCurrentFrame(window: ?*ImGuiWindow) void;
pub extern fn igWindowRectAbsToRel(pOut: [*c]ImRect, window: ?*ImGuiWindow, r: ImRect) void;
pub extern fn igWindowRectRelToAbs(pOut: [*c]ImRect, window: ?*ImGuiWindow, r: ImRect) void;
pub extern fn igWindowPosRelToAbs(pOut: [*c]ImVec2, window: ?*ImGuiWindow, p: ImVec2) void;
pub extern fn igFocusWindow(window: ?*ImGuiWindow, flags: ImGuiFocusRequestFlags) void;
pub extern fn igFocusTopMostWindowUnderOne(under_this_window: ?*ImGuiWindow, ignore_window: ?*ImGuiWindow, filter_viewport: [*c]ImGuiViewport, flags: ImGuiFocusRequestFlags) void;
pub extern fn igBringWindowToFocusFront(window: ?*ImGuiWindow) void;
pub extern fn igBringWindowToDisplayFront(window: ?*ImGuiWindow) void;
pub extern fn igBringWindowToDisplayBack(window: ?*ImGuiWindow) void;
pub extern fn igBringWindowToDisplayBehind(window: ?*ImGuiWindow, above_window: ?*ImGuiWindow) void;
pub extern fn igFindWindowDisplayIndex(window: ?*ImGuiWindow) c_int;
pub extern fn igFindBottomMostVisibleWindowWithinBeginStack(window: ?*ImGuiWindow) ?*ImGuiWindow;
pub extern fn igSetCurrentFont(font: [*c]ImFont) void;
pub extern fn igGetDefaultFont() [*c]ImFont;
pub extern fn igGetForegroundDrawList_WindowPtr(window: ?*ImGuiWindow) [*c]ImDrawList;
pub extern fn igAddDrawListToDrawDataEx(draw_data: [*c]ImDrawData, out_list: [*c]ImVector_ImDrawListPtr, draw_list: [*c]ImDrawList) void;
pub extern fn igInitialize() void;
pub extern fn igShutdown() void;
pub extern fn igUpdateInputEvents(trickle_fast_inputs: bool) void;
pub extern fn igUpdateHoveredWindowAndCaptureFlags() void;
pub extern fn igStartMouseMovingWindow(window: ?*ImGuiWindow) void;
pub extern fn igStartMouseMovingWindowOrNode(window: ?*ImGuiWindow, node: ?*ImGuiDockNode, undock_floating_node: bool) void;
pub extern fn igUpdateMouseMovingWindowNewFrame() void;
pub extern fn igUpdateMouseMovingWindowEndFrame() void;
pub extern fn igAddContextHook(context: [*c]ImGuiContext, hook: [*c]const ImGuiContextHook) ImGuiID;
pub extern fn igRemoveContextHook(context: [*c]ImGuiContext, hook_to_remove: ImGuiID) void;
pub extern fn igCallContextHooks(context: [*c]ImGuiContext, @"type": ImGuiContextHookType) void;
pub extern fn igTranslateWindowsInViewport(viewport: [*c]ImGuiViewportP, old_pos: ImVec2, new_pos: ImVec2) void;
pub extern fn igScaleWindowsInViewport(viewport: [*c]ImGuiViewportP, scale: f32) void;
pub extern fn igDestroyPlatformWindow(viewport: [*c]ImGuiViewportP) void;
pub extern fn igSetWindowViewport(window: ?*ImGuiWindow, viewport: [*c]ImGuiViewportP) void;
pub extern fn igSetCurrentViewport(window: ?*ImGuiWindow, viewport: [*c]ImGuiViewportP) void;
pub extern fn igGetViewportPlatformMonitor(viewport: [*c]ImGuiViewport) [*c]const ImGuiPlatformMonitor;
pub extern fn igFindHoveredViewportFromPlatformWindowStack(mouse_platform_pos: ImVec2) [*c]ImGuiViewportP;
pub extern fn igMarkIniSettingsDirty_Nil() void;
pub extern fn igMarkIniSettingsDirty_WindowPtr(window: ?*ImGuiWindow) void;
pub extern fn igClearIniSettings() void;
pub extern fn igAddSettingsHandler(handler: [*c]const ImGuiSettingsHandler) void;
pub extern fn igRemoveSettingsHandler(type_name: [*c]const u8) void;
pub extern fn igFindSettingsHandler(type_name: [*c]const u8) [*c]ImGuiSettingsHandler;
pub extern fn igCreateNewWindowSettings(name: [*c]const u8) [*c]ImGuiWindowSettings;
pub extern fn igFindWindowSettingsByID(id: ImGuiID) [*c]ImGuiWindowSettings;
pub extern fn igFindWindowSettingsByWindow(window: ?*ImGuiWindow) [*c]ImGuiWindowSettings;
pub extern fn igClearWindowSettings(name: [*c]const u8) void;
pub extern fn igLocalizeRegisterEntries(entries: [*c]const ImGuiLocEntry, count: c_int) void;
pub extern fn igLocalizeGetMsg(key: ImGuiLocKey) [*c]const u8;
pub extern fn igSetScrollX_WindowPtr(window: ?*ImGuiWindow, scroll_x: f32) void;
pub extern fn igSetScrollY_WindowPtr(window: ?*ImGuiWindow, scroll_y: f32) void;
pub extern fn igSetScrollFromPosX_WindowPtr(window: ?*ImGuiWindow, local_x: f32, center_x_ratio: f32) void;
pub extern fn igSetScrollFromPosY_WindowPtr(window: ?*ImGuiWindow, local_y: f32, center_y_ratio: f32) void;
pub extern fn igScrollToItem(flags: ImGuiScrollFlags) void;
pub extern fn igScrollToRect(window: ?*ImGuiWindow, rect: ImRect, flags: ImGuiScrollFlags) void;
pub extern fn igScrollToRectEx(pOut: [*c]ImVec2, window: ?*ImGuiWindow, rect: ImRect, flags: ImGuiScrollFlags) void;
pub extern fn igScrollToBringRectIntoView(window: ?*ImGuiWindow, rect: ImRect) void;
pub extern fn igGetItemStatusFlags() ImGuiItemStatusFlags;
pub extern fn igGetItemFlags() ImGuiItemFlags;
pub extern fn igGetActiveID() ImGuiID;
pub extern fn igGetFocusID() ImGuiID;
pub extern fn igSetActiveID(id: ImGuiID, window: ?*ImGuiWindow) void;
pub extern fn igSetFocusID(id: ImGuiID, window: ?*ImGuiWindow) void;
pub extern fn igClearActiveID() void;
pub extern fn igGetHoveredID() ImGuiID;
pub extern fn igSetHoveredID(id: ImGuiID) void;
pub extern fn igKeepAliveID(id: ImGuiID) void;
pub extern fn igMarkItemEdited(id: ImGuiID) void;
pub extern fn igPushOverrideID(id: ImGuiID) void;
pub extern fn igGetIDWithSeed_Str(str_id_begin: [*c]const u8, str_id_end: [*c]const u8, seed: ImGuiID) ImGuiID;
pub extern fn igGetIDWithSeed_Int(n: c_int, seed: ImGuiID) ImGuiID;
pub extern fn igItemSize_Vec2(size: ImVec2, text_baseline_y: f32) void;
pub extern fn igItemSize_Rect(bb: ImRect, text_baseline_y: f32) void;
pub extern fn igItemAdd(bb: ImRect, id: ImGuiID, nav_bb: [*c]const ImRect, extra_flags: ImGuiItemFlags) bool;
pub extern fn igItemHoverable(bb: ImRect, id: ImGuiID, item_flags: ImGuiItemFlags) bool;
pub extern fn igIsWindowContentHoverable(window: ?*ImGuiWindow, flags: ImGuiHoveredFlags) bool;
pub extern fn igIsClippedEx(bb: ImRect, id: ImGuiID) bool;
pub extern fn igSetLastItemData(item_id: ImGuiID, in_flags: ImGuiItemFlags, status_flags: ImGuiItemStatusFlags, item_rect: ImRect) void;
pub extern fn igCalcItemSize(pOut: [*c]ImVec2, size: ImVec2, default_w: f32, default_h: f32) void;
pub extern fn igCalcWrapWidthForPos(pos: ImVec2, wrap_pos_x: f32) f32;
pub extern fn igPushMultiItemsWidths(components: c_int, width_full: f32) void;
pub extern fn igIsItemToggledSelection() bool;
pub extern fn igGetContentRegionMaxAbs(pOut: [*c]ImVec2) void;
pub extern fn igShrinkWidths(items: [*c]ImGuiShrinkWidthItem, count: c_int, width_excess: f32) void;
pub extern fn igPushItemFlag(option: ImGuiItemFlags, enabled: bool) void;
pub extern fn igPopItemFlag() void;
pub extern fn igGetStyleVarInfo(idx: ImGuiStyleVar) [*c]const ImGuiDataVarInfo;
pub extern fn igLogBegin(@"type": ImGuiLogType, auto_open_depth: c_int) void;
pub extern fn igLogToBuffer(auto_open_depth: c_int) void;
pub extern fn igLogRenderedText(ref_pos: [*c]const ImVec2, text: [*c]const u8, text_end: [*c]const u8) void;
pub extern fn igLogSetNextTextDecoration(prefix: [*c]const u8, suffix: [*c]const u8) void;
pub extern fn igBeginChildEx(name: [*c]const u8, id: ImGuiID, size_arg: ImVec2, border: bool, flags: ImGuiWindowFlags) bool;
pub extern fn igOpenPopupEx(id: ImGuiID, popup_flags: ImGuiPopupFlags) void;
pub extern fn igClosePopupToLevel(remaining: c_int, restore_focus_to_window_under_popup: bool) void;
pub extern fn igClosePopupsOverWindow(ref_window: ?*ImGuiWindow, restore_focus_to_window_under_popup: bool) void;
pub extern fn igClosePopupsExceptModals() void;
pub extern fn igIsPopupOpen_ID(id: ImGuiID, popup_flags: ImGuiPopupFlags) bool;
pub extern fn igBeginPopupEx(id: ImGuiID, extra_flags: ImGuiWindowFlags) bool;
pub extern fn igBeginTooltipEx(tooltip_flags: ImGuiTooltipFlags, extra_window_flags: ImGuiWindowFlags) bool;
pub extern fn igGetPopupAllowedExtentRect(pOut: [*c]ImRect, window: ?*ImGuiWindow) void;
pub extern fn igGetTopMostPopupModal() ?*ImGuiWindow;
pub extern fn igGetTopMostAndVisiblePopupModal() ?*ImGuiWindow;
pub extern fn igFindBlockingModal(window: ?*ImGuiWindow) ?*ImGuiWindow;
pub extern fn igFindBestWindowPosForPopup(pOut: [*c]ImVec2, window: ?*ImGuiWindow) void;
pub extern fn igFindBestWindowPosForPopupEx(pOut: [*c]ImVec2, ref_pos: ImVec2, size: ImVec2, last_dir: [*c]ImGuiDir, r_outer: ImRect, r_avoid: ImRect, policy: ImGuiPopupPositionPolicy) void;
pub extern fn igBeginViewportSideBar(name: [*c]const u8, viewport: [*c]ImGuiViewport, dir: ImGuiDir, size: f32, window_flags: ImGuiWindowFlags) bool;
pub extern fn igBeginMenuEx(label: [*c]const u8, icon: [*c]const u8, enabled: bool) bool;
pub extern fn igMenuItemEx(label: [*c]const u8, icon: [*c]const u8, shortcut: [*c]const u8, selected: bool, enabled: bool) bool;
pub extern fn igBeginComboPopup(popup_id: ImGuiID, bb: ImRect, flags: ImGuiComboFlags) bool;
pub extern fn igBeginComboPreview() bool;
pub extern fn igEndComboPreview() void;
pub extern fn igNavInitWindow(window: ?*ImGuiWindow, force_reinit: bool) void;
pub extern fn igNavInitRequestApplyResult() void;
pub extern fn igNavMoveRequestButNoResultYet() bool;
pub extern fn igNavMoveRequestSubmit(move_dir: ImGuiDir, clip_dir: ImGuiDir, move_flags: ImGuiNavMoveFlags, scroll_flags: ImGuiScrollFlags) void;
pub extern fn igNavMoveRequestForward(move_dir: ImGuiDir, clip_dir: ImGuiDir, move_flags: ImGuiNavMoveFlags, scroll_flags: ImGuiScrollFlags) void;
pub extern fn igNavMoveRequestResolveWithLastItem(result: [*c]ImGuiNavItemData) void;
pub extern fn igNavMoveRequestResolveWithPastTreeNode(result: [*c]ImGuiNavItemData, tree_node_data: [*c]ImGuiNavTreeNodeData) void;
pub extern fn igNavMoveRequestCancel() void;
pub extern fn igNavMoveRequestApplyResult() void;
pub extern fn igNavMoveRequestTryWrapping(window: ?*ImGuiWindow, move_flags: ImGuiNavMoveFlags) void;
pub extern fn igNavClearPreferredPosForAxis(axis: ImGuiAxis) void;
pub extern fn igNavUpdateCurrentWindowIsScrollPushableX() void;
pub extern fn igSetNavWindow(window: ?*ImGuiWindow) void;
pub extern fn igSetNavID(id: ImGuiID, nav_layer: ImGuiNavLayer, focus_scope_id: ImGuiID, rect_rel: ImRect) void;
pub extern fn igFocusItem() void;
pub extern fn igActivateItemByID(id: ImGuiID) void;
pub extern fn igIsNamedKey(key: ImGuiKey) bool;
pub extern fn igIsNamedKeyOrModKey(key: ImGuiKey) bool;
pub extern fn igIsLegacyKey(key: ImGuiKey) bool;
pub extern fn igIsKeyboardKey(key: ImGuiKey) bool;
pub extern fn igIsGamepadKey(key: ImGuiKey) bool;
pub extern fn igIsMouseKey(key: ImGuiKey) bool;
pub extern fn igIsAliasKey(key: ImGuiKey) bool;
pub extern fn igConvertShortcutMod(key_chord: ImGuiKeyChord) ImGuiKeyChord;
pub extern fn igConvertSingleModFlagToKey(ctx: [*c]ImGuiContext, key: ImGuiKey) ImGuiKey;
pub extern fn igGetKeyData_ContextPtr(ctx: [*c]ImGuiContext, key: ImGuiKey) [*c]ImGuiKeyData;
pub extern fn igGetKeyData_Key(key: ImGuiKey) [*c]ImGuiKeyData;
pub extern fn igGetKeyChordName(key_chord: ImGuiKeyChord, out_buf: [*c]u8, out_buf_size: c_int) void;
pub extern fn igMouseButtonToKey(button: ImGuiMouseButton) ImGuiKey;
pub extern fn igIsMouseDragPastThreshold(button: ImGuiMouseButton, lock_threshold: f32) bool;
pub extern fn igGetKeyMagnitude2d(pOut: [*c]ImVec2, key_left: ImGuiKey, key_right: ImGuiKey, key_up: ImGuiKey, key_down: ImGuiKey) void;
pub extern fn igGetNavTweakPressedAmount(axis: ImGuiAxis) f32;
pub extern fn igCalcTypematicRepeatAmount(t0: f32, t1: f32, repeat_delay: f32, repeat_rate: f32) c_int;
pub extern fn igGetTypematicRepeatRate(flags: ImGuiInputFlags, repeat_delay: [*c]f32, repeat_rate: [*c]f32) void;
pub extern fn igSetActiveIdUsingAllKeyboardKeys() void;
pub extern fn igIsActiveIdUsingNavDir(dir: ImGuiDir) bool;
pub extern fn igGetKeyOwner(key: ImGuiKey) ImGuiID;
pub extern fn igSetKeyOwner(key: ImGuiKey, owner_id: ImGuiID, flags: ImGuiInputFlags) void;
pub extern fn igSetKeyOwnersForKeyChord(key: ImGuiKeyChord, owner_id: ImGuiID, flags: ImGuiInputFlags) void;
pub extern fn igSetItemKeyOwner(key: ImGuiKey, flags: ImGuiInputFlags) void;
pub extern fn igTestKeyOwner(key: ImGuiKey, owner_id: ImGuiID) bool;
pub extern fn igGetKeyOwnerData(ctx: [*c]ImGuiContext, key: ImGuiKey) [*c]ImGuiKeyOwnerData;
pub extern fn igIsKeyDown_ID(key: ImGuiKey, owner_id: ImGuiID) bool;
pub extern fn igIsKeyPressed_ID(key: ImGuiKey, owner_id: ImGuiID, flags: ImGuiInputFlags) bool;
pub extern fn igIsKeyReleased_ID(key: ImGuiKey, owner_id: ImGuiID) bool;
pub extern fn igIsMouseDown_ID(button: ImGuiMouseButton, owner_id: ImGuiID) bool;
pub extern fn igIsMouseClicked_ID(button: ImGuiMouseButton, owner_id: ImGuiID, flags: ImGuiInputFlags) bool;
pub extern fn igIsMouseReleased_ID(button: ImGuiMouseButton, owner_id: ImGuiID) bool;
pub extern fn igShortcut(key_chord: ImGuiKeyChord, owner_id: ImGuiID, flags: ImGuiInputFlags) bool;
pub extern fn igSetShortcutRouting(key_chord: ImGuiKeyChord, owner_id: ImGuiID, flags: ImGuiInputFlags) bool;
pub extern fn igTestShortcutRouting(key_chord: ImGuiKeyChord, owner_id: ImGuiID) bool;
pub extern fn igGetShortcutRoutingData(key_chord: ImGuiKeyChord) [*c]ImGuiKeyRoutingData;
pub extern fn igDockContextInitialize(ctx: [*c]ImGuiContext) void;
pub extern fn igDockContextShutdown(ctx: [*c]ImGuiContext) void;
pub extern fn igDockContextClearNodes(ctx: [*c]ImGuiContext, root_id: ImGuiID, clear_settings_refs: bool) void;
pub extern fn igDockContextRebuildNodes(ctx: [*c]ImGuiContext) void;
pub extern fn igDockContextNewFrameUpdateUndocking(ctx: [*c]ImGuiContext) void;
pub extern fn igDockContextNewFrameUpdateDocking(ctx: [*c]ImGuiContext) void;
pub extern fn igDockContextEndFrame(ctx: [*c]ImGuiContext) void;
pub extern fn igDockContextGenNodeID(ctx: [*c]ImGuiContext) ImGuiID;
pub extern fn igDockContextQueueDock(ctx: [*c]ImGuiContext, target: ?*ImGuiWindow, target_node: ?*ImGuiDockNode, payload: ?*ImGuiWindow, split_dir: ImGuiDir, split_ratio: f32, split_outer: bool) void;
pub extern fn igDockContextQueueUndockWindow(ctx: [*c]ImGuiContext, window: ?*ImGuiWindow) void;
pub extern fn igDockContextQueueUndockNode(ctx: [*c]ImGuiContext, node: ?*ImGuiDockNode) void;
pub extern fn igDockContextProcessUndockWindow(ctx: [*c]ImGuiContext, window: ?*ImGuiWindow, clear_persistent_docking_ref: bool) void;
pub extern fn igDockContextProcessUndockNode(ctx: [*c]ImGuiContext, node: ?*ImGuiDockNode) void;
pub extern fn igDockContextCalcDropPosForDocking(target: ?*ImGuiWindow, target_node: ?*ImGuiDockNode, payload_window: ?*ImGuiWindow, payload_node: ?*ImGuiDockNode, split_dir: ImGuiDir, split_outer: bool, out_pos: [*c]ImVec2) bool;
pub extern fn igDockContextFindNodeByID(ctx: [*c]ImGuiContext, id: ImGuiID) ?*ImGuiDockNode;
pub extern fn igDockNodeWindowMenuHandler_Default(ctx: [*c]ImGuiContext, node: ?*ImGuiDockNode, tab_bar: [*c]ImGuiTabBar) void;
pub extern fn igDockNodeBeginAmendTabBar(node: ?*ImGuiDockNode) bool;
pub extern fn igDockNodeEndAmendTabBar() void;
pub extern fn igDockNodeGetRootNode(node: ?*ImGuiDockNode) ?*ImGuiDockNode;
pub extern fn igDockNodeIsInHierarchyOf(node: ?*ImGuiDockNode, parent: ?*ImGuiDockNode) bool;
pub extern fn igDockNodeGetDepth(node: ?*const ImGuiDockNode) c_int;
pub extern fn igDockNodeGetWindowMenuButtonId(node: ?*const ImGuiDockNode) ImGuiID;
pub extern fn igGetWindowDockNode() ?*ImGuiDockNode;
pub extern fn igGetWindowAlwaysWantOwnTabBar(window: ?*ImGuiWindow) bool;
pub extern fn igBeginDocked(window: ?*ImGuiWindow, p_open: [*c]bool) void;
pub extern fn igBeginDockableDragDropSource(window: ?*ImGuiWindow) void;
pub extern fn igBeginDockableDragDropTarget(window: ?*ImGuiWindow) void;
pub extern fn igSetWindowDock(window: ?*ImGuiWindow, dock_id: ImGuiID, cond: ImGuiCond) void;
pub extern fn igDockBuilderDockWindow(window_name: [*c]const u8, node_id: ImGuiID) void;
pub extern fn igDockBuilderGetNode(node_id: ImGuiID) ?*ImGuiDockNode;
pub extern fn igDockBuilderGetCentralNode(node_id: ImGuiID) ?*ImGuiDockNode;
pub extern fn igDockBuilderAddNode(node_id: ImGuiID, flags: ImGuiDockNodeFlags) ImGuiID;
pub extern fn igDockBuilderRemoveNode(node_id: ImGuiID) void;
pub extern fn igDockBuilderRemoveNodeDockedWindows(node_id: ImGuiID, clear_settings_refs: bool) void;
pub extern fn igDockBuilderRemoveNodeChildNodes(node_id: ImGuiID) void;
pub extern fn igDockBuilderSetNodePos(node_id: ImGuiID, pos: ImVec2) void;
pub extern fn igDockBuilderSetNodeSize(node_id: ImGuiID, size: ImVec2) void;
pub extern fn igDockBuilderSplitNode(node_id: ImGuiID, split_dir: ImGuiDir, size_ratio_for_node_at_dir: f32, out_id_at_dir: [*c]ImGuiID, out_id_at_opposite_dir: [*c]ImGuiID) ImGuiID;
pub extern fn igDockBuilderCopyDockSpace(src_dockspace_id: ImGuiID, dst_dockspace_id: ImGuiID, in_window_remap_pairs: [*c]ImVector_const_charPtr) void;
pub extern fn igDockBuilderCopyNode(src_node_id: ImGuiID, dst_node_id: ImGuiID, out_node_remap_pairs: [*c]ImVector_ImGuiID) void;
pub extern fn igDockBuilderCopyWindowSettings(src_name: [*c]const u8, dst_name: [*c]const u8) void;
pub extern fn igDockBuilderFinish(node_id: ImGuiID) void;
pub extern fn igPushFocusScope(id: ImGuiID) void;
pub extern fn igPopFocusScope() void;
pub extern fn igGetCurrentFocusScope() ImGuiID;
pub extern fn igIsDragDropActive() bool;
pub extern fn igBeginDragDropTargetCustom(bb: ImRect, id: ImGuiID) bool;
pub extern fn igClearDragDrop() void;
pub extern fn igIsDragDropPayloadBeingAccepted() bool;
pub extern fn igRenderDragDropTargetRect(bb: ImRect) void;
pub extern fn igSetWindowClipRectBeforeSetChannel(window: ?*ImGuiWindow, clip_rect: ImRect) void;
pub extern fn igBeginColumns(str_id: [*c]const u8, count: c_int, flags: ImGuiOldColumnFlags) void;
pub extern fn igEndColumns() void;
pub extern fn igPushColumnClipRect(column_index: c_int) void;
pub extern fn igPushColumnsBackground() void;
pub extern fn igPopColumnsBackground() void;
pub extern fn igGetColumnsID(str_id: [*c]const u8, count: c_int) ImGuiID;
pub extern fn igFindOrCreateColumns(window: ?*ImGuiWindow, id: ImGuiID) [*c]ImGuiOldColumns;
pub extern fn igGetColumnOffsetFromNorm(columns: [*c]const ImGuiOldColumns, offset_norm: f32) f32;
pub extern fn igGetColumnNormFromOffset(columns: [*c]const ImGuiOldColumns, offset: f32) f32;
pub extern fn igTableOpenContextMenu(column_n: c_int) void;
pub extern fn igTableSetColumnWidth(column_n: c_int, width: f32) void;
pub extern fn igTableSetColumnSortDirection(column_n: c_int, sort_direction: ImGuiSortDirection, append_to_sort_specs: bool) void;
pub extern fn igTableGetHoveredColumn() c_int;
pub extern fn igTableGetHoveredRow() c_int;
pub extern fn igTableGetHeaderRowHeight() f32;
pub extern fn igTablePushBackgroundChannel() void;
pub extern fn igTablePopBackgroundChannel() void;
pub extern fn igGetCurrentTable() ?*ImGuiTable;
pub extern fn igTableFindByID(id: ImGuiID) ?*ImGuiTable;
pub extern fn igBeginTableEx(name: [*c]const u8, id: ImGuiID, columns_count: c_int, flags: ImGuiTableFlags, outer_size: ImVec2, inner_width: f32) bool;
pub extern fn igTableBeginInitMemory(table: ?*ImGuiTable, columns_count: c_int) void;
pub extern fn igTableBeginApplyRequests(table: ?*ImGuiTable) void;
pub extern fn igTableSetupDrawChannels(table: ?*ImGuiTable) void;
pub extern fn igTableUpdateLayout(table: ?*ImGuiTable) void;
pub extern fn igTableUpdateBorders(table: ?*ImGuiTable) void;
pub extern fn igTableUpdateColumnsWeightFromWidth(table: ?*ImGuiTable) void;
pub extern fn igTableDrawBorders(table: ?*ImGuiTable) void;
pub extern fn igTableDrawContextMenu(table: ?*ImGuiTable) void;
pub extern fn igTableBeginContextMenuPopup(table: ?*ImGuiTable) bool;
pub extern fn igTableMergeDrawChannels(table: ?*ImGuiTable) void;
pub extern fn igTableGetInstanceData(table: ?*ImGuiTable, instance_no: c_int) [*c]ImGuiTableInstanceData;
pub extern fn igTableGetInstanceID(table: ?*ImGuiTable, instance_no: c_int) ImGuiID;
pub extern fn igTableSortSpecsSanitize(table: ?*ImGuiTable) void;
pub extern fn igTableSortSpecsBuild(table: ?*ImGuiTable) void;
pub extern fn igTableGetColumnNextSortDirection(column: ?*ImGuiTableColumn) ImGuiSortDirection;
pub extern fn igTableFixColumnSortDirection(table: ?*ImGuiTable, column: ?*ImGuiTableColumn) void;
pub extern fn igTableGetColumnWidthAuto(table: ?*ImGuiTable, column: ?*ImGuiTableColumn) f32;
pub extern fn igTableBeginRow(table: ?*ImGuiTable) void;
pub extern fn igTableEndRow(table: ?*ImGuiTable) void;
pub extern fn igTableBeginCell(table: ?*ImGuiTable, column_n: c_int) void;
pub extern fn igTableEndCell(table: ?*ImGuiTable) void;
pub extern fn igTableGetCellBgRect(pOut: [*c]ImRect, table: ?*const ImGuiTable, column_n: c_int) void;
pub extern fn igTableGetColumnName_TablePtr(table: ?*const ImGuiTable, column_n: c_int) [*c]const u8;
pub extern fn igTableGetColumnResizeID(table: ?*ImGuiTable, column_n: c_int, instance_no: c_int) ImGuiID;
pub extern fn igTableGetMaxColumnWidth(table: ?*const ImGuiTable, column_n: c_int) f32;
pub extern fn igTableSetColumnWidthAutoSingle(table: ?*ImGuiTable, column_n: c_int) void;
pub extern fn igTableSetColumnWidthAutoAll(table: ?*ImGuiTable) void;
pub extern fn igTableRemove(table: ?*ImGuiTable) void;
pub extern fn igTableGcCompactTransientBuffers_TablePtr(table: ?*ImGuiTable) void;
pub extern fn igTableGcCompactTransientBuffers_TableTempDataPtr(table: [*c]ImGuiTableTempData) void;
pub extern fn igTableGcCompactSettings() void;
pub extern fn igTableLoadSettings(table: ?*ImGuiTable) void;
pub extern fn igTableSaveSettings(table: ?*ImGuiTable) void;
pub extern fn igTableResetSettings(table: ?*ImGuiTable) void;
pub extern fn igTableGetBoundSettings(table: ?*ImGuiTable) [*c]ImGuiTableSettings;
pub extern fn igTableSettingsAddSettingsHandler() void;
pub extern fn igTableSettingsCreate(id: ImGuiID, columns_count: c_int) [*c]ImGuiTableSettings;
pub extern fn igTableSettingsFindByID(id: ImGuiID) [*c]ImGuiTableSettings;
pub extern fn igGetCurrentTabBar() [*c]ImGuiTabBar;
pub extern fn igBeginTabBarEx(tab_bar: [*c]ImGuiTabBar, bb: ImRect, flags: ImGuiTabBarFlags, dock_node: ?*ImGuiDockNode) bool;
pub extern fn igTabBarFindTabByID(tab_bar: [*c]ImGuiTabBar, tab_id: ImGuiID) [*c]ImGuiTabItem;
pub extern fn igTabBarFindTabByOrder(tab_bar: [*c]ImGuiTabBar, order: c_int) [*c]ImGuiTabItem;
pub extern fn igTabBarFindMostRecentlySelectedTabForActiveWindow(tab_bar: [*c]ImGuiTabBar) [*c]ImGuiTabItem;
pub extern fn igTabBarGetCurrentTab(tab_bar: [*c]ImGuiTabBar) [*c]ImGuiTabItem;
pub extern fn igTabBarGetTabOrder(tab_bar: [*c]ImGuiTabBar, tab: [*c]ImGuiTabItem) c_int;
pub extern fn igTabBarGetTabName(tab_bar: [*c]ImGuiTabBar, tab: [*c]ImGuiTabItem) [*c]const u8;
pub extern fn igTabBarAddTab(tab_bar: [*c]ImGuiTabBar, tab_flags: ImGuiTabItemFlags, window: ?*ImGuiWindow) void;
pub extern fn igTabBarRemoveTab(tab_bar: [*c]ImGuiTabBar, tab_id: ImGuiID) void;
pub extern fn igTabBarCloseTab(tab_bar: [*c]ImGuiTabBar, tab: [*c]ImGuiTabItem) void;
pub extern fn igTabBarQueueFocus(tab_bar: [*c]ImGuiTabBar, tab: [*c]ImGuiTabItem) void;
pub extern fn igTabBarQueueReorder(tab_bar: [*c]ImGuiTabBar, tab: [*c]ImGuiTabItem, offset: c_int) void;
pub extern fn igTabBarQueueReorderFromMousePos(tab_bar: [*c]ImGuiTabBar, tab: [*c]ImGuiTabItem, mouse_pos: ImVec2) void;
pub extern fn igTabBarProcessReorder(tab_bar: [*c]ImGuiTabBar) bool;
pub extern fn igTabItemEx(tab_bar: [*c]ImGuiTabBar, label: [*c]const u8, p_open: [*c]bool, flags: ImGuiTabItemFlags, docked_window: ?*ImGuiWindow) bool;
pub extern fn igTabItemCalcSize_Str(pOut: [*c]ImVec2, label: [*c]const u8, has_close_button_or_unsaved_marker: bool) void;
pub extern fn igTabItemCalcSize_WindowPtr(pOut: [*c]ImVec2, window: ?*ImGuiWindow) void;
pub extern fn igTabItemBackground(draw_list: [*c]ImDrawList, bb: ImRect, flags: ImGuiTabItemFlags, col: ImU32) void;
pub extern fn igTabItemLabelAndCloseButton(draw_list: [*c]ImDrawList, bb: ImRect, flags: ImGuiTabItemFlags, frame_padding: ImVec2, label: [*c]const u8, tab_id: ImGuiID, close_button_id: ImGuiID, is_contents_visible: bool, out_just_closed: [*c]bool, out_text_clipped: [*c]bool) void;
pub extern fn igRenderText(pos: ImVec2, text: [*c]const u8, text_end: [*c]const u8, hide_text_after_hash: bool) void;
pub extern fn igRenderTextWrapped(pos: ImVec2, text: [*c]const u8, text_end: [*c]const u8, wrap_width: f32) void;
pub extern fn igRenderTextClipped(pos_min: ImVec2, pos_max: ImVec2, text: [*c]const u8, text_end: [*c]const u8, text_size_if_known: [*c]const ImVec2, @"align": ImVec2, clip_rect: [*c]const ImRect) void;
pub extern fn igRenderTextClippedEx(draw_list: [*c]ImDrawList, pos_min: ImVec2, pos_max: ImVec2, text: [*c]const u8, text_end: [*c]const u8, text_size_if_known: [*c]const ImVec2, @"align": ImVec2, clip_rect: [*c]const ImRect) void;
pub extern fn igRenderTextEllipsis(draw_list: [*c]ImDrawList, pos_min: ImVec2, pos_max: ImVec2, clip_max_x: f32, ellipsis_max_x: f32, text: [*c]const u8, text_end: [*c]const u8, text_size_if_known: [*c]const ImVec2) void;
pub extern fn igRenderFrame(p_min: ImVec2, p_max: ImVec2, fill_col: ImU32, border: bool, rounding: f32) void;
pub extern fn igRenderFrameBorder(p_min: ImVec2, p_max: ImVec2, rounding: f32) void;
pub extern fn igRenderColorRectWithAlphaCheckerboard(draw_list: [*c]ImDrawList, p_min: ImVec2, p_max: ImVec2, fill_col: ImU32, grid_step: f32, grid_off: ImVec2, rounding: f32, flags: ImDrawFlags) void;
pub extern fn igRenderNavHighlight(bb: ImRect, id: ImGuiID, flags: ImGuiNavHighlightFlags) void;
pub extern fn igFindRenderedTextEnd(text: [*c]const u8, text_end: [*c]const u8) [*c]const u8;
pub extern fn igRenderMouseCursor(pos: ImVec2, scale: f32, mouse_cursor: ImGuiMouseCursor, col_fill: ImU32, col_border: ImU32, col_shadow: ImU32) void;
pub extern fn igRenderArrow(draw_list: [*c]ImDrawList, pos: ImVec2, col: ImU32, dir: ImGuiDir, scale: f32) void;
pub extern fn igRenderBullet(draw_list: [*c]ImDrawList, pos: ImVec2, col: ImU32) void;
pub extern fn igRenderCheckMark(draw_list: [*c]ImDrawList, pos: ImVec2, col: ImU32, sz: f32) void;
pub extern fn igRenderArrowPointingAt(draw_list: [*c]ImDrawList, pos: ImVec2, half_sz: ImVec2, direction: ImGuiDir, col: ImU32) void;
pub extern fn igRenderArrowDockMenu(draw_list: [*c]ImDrawList, p_min: ImVec2, sz: f32, col: ImU32) void;
pub extern fn igRenderRectFilledRangeH(draw_list: [*c]ImDrawList, rect: ImRect, col: ImU32, x_start_norm: f32, x_end_norm: f32, rounding: f32) void;
pub extern fn igRenderRectFilledWithHole(draw_list: [*c]ImDrawList, outer: ImRect, inner: ImRect, col: ImU32, rounding: f32) void;
pub extern fn igCalcRoundingFlagsForRectInRect(r_in: ImRect, r_outer: ImRect, threshold: f32) ImDrawFlags;
pub extern fn igTextEx(text: [*c]const u8, text_end: [*c]const u8, flags: ImGuiTextFlags) void;
pub extern fn igButtonEx(label: [*c]const u8, size_arg: ImVec2, flags: ImGuiButtonFlags) bool;
pub extern fn igArrowButtonEx(str_id: [*c]const u8, dir: ImGuiDir, size_arg: ImVec2, flags: ImGuiButtonFlags) bool;
pub extern fn igImageButtonEx(id: ImGuiID, texture_id: ImTextureID, size: ImVec2, uv0: ImVec2, uv1: ImVec2, bg_col: ImVec4, tint_col: ImVec4, flags: ImGuiButtonFlags) bool;
pub extern fn igSeparatorEx(flags: ImGuiSeparatorFlags, thickness: f32) void;
pub extern fn igSeparatorTextEx(id: ImGuiID, label: [*c]const u8, label_end: [*c]const u8, extra_width: f32) void;
pub extern fn igCheckboxFlags_S64Ptr(label: [*c]const u8, flags: [*c]ImS64, flags_value: ImS64) bool;
pub extern fn igCheckboxFlags_U64Ptr(label: [*c]const u8, flags: [*c]ImU64, flags_value: ImU64) bool;
pub extern fn igCloseButton(id: ImGuiID, pos: ImVec2) bool;
pub extern fn igCollapseButton(id: ImGuiID, pos: ImVec2, dock_node: ?*ImGuiDockNode) bool;
pub extern fn igScrollbar(axis: ImGuiAxis) void;
pub extern fn igScrollbarEx(bb: ImRect, id: ImGuiID, axis: ImGuiAxis, p_scroll_v: [*c]ImS64, avail_v: ImS64, contents_v: ImS64, flags: ImDrawFlags) bool;
pub extern fn igGetWindowScrollbarRect(pOut: [*c]ImRect, window: ?*ImGuiWindow, axis: ImGuiAxis) void;
pub extern fn igGetWindowScrollbarID(window: ?*ImGuiWindow, axis: ImGuiAxis) ImGuiID;
pub extern fn igGetWindowResizeCornerID(window: ?*ImGuiWindow, n: c_int) ImGuiID;
pub extern fn igGetWindowResizeBorderID(window: ?*ImGuiWindow, dir: ImGuiDir) ImGuiID;
pub extern fn igButtonBehavior(bb: ImRect, id: ImGuiID, out_hovered: [*c]bool, out_held: [*c]bool, flags: ImGuiButtonFlags) bool;
pub extern fn igDragBehavior(id: ImGuiID, data_type: ImGuiDataType, p_v: ?*anyopaque, v_speed: f32, p_min: ?*const anyopaque, p_max: ?*const anyopaque, format: [*c]const u8, flags: ImGuiSliderFlags) bool;
pub extern fn igSliderBehavior(bb: ImRect, id: ImGuiID, data_type: ImGuiDataType, p_v: ?*anyopaque, p_min: ?*const anyopaque, p_max: ?*const anyopaque, format: [*c]const u8, flags: ImGuiSliderFlags, out_grab_bb: [*c]ImRect) bool;
pub extern fn igSplitterBehavior(bb: ImRect, id: ImGuiID, axis: ImGuiAxis, size1: [*c]f32, size2: [*c]f32, min_size1: f32, min_size2: f32, hover_extend: f32, hover_visibility_delay: f32, bg_col: ImU32) bool;
pub extern fn igTreeNodeBehavior(id: ImGuiID, flags: ImGuiTreeNodeFlags, label: [*c]const u8, label_end: [*c]const u8) bool;
pub extern fn igTreePushOverrideID(id: ImGuiID) void;
pub extern fn igTreeNodeSetOpen(id: ImGuiID, open: bool) void;
pub extern fn igTreeNodeUpdateNextOpen(id: ImGuiID, flags: ImGuiTreeNodeFlags) bool;
pub extern fn igDataTypeGetInfo(data_type: ImGuiDataType) [*c]const ImGuiDataTypeInfo;
pub extern fn igDataTypeFormatString(buf: [*c]u8, buf_size: c_int, data_type: ImGuiDataType, p_data: ?*const anyopaque, format: [*c]const u8) c_int;
pub extern fn igDataTypeApplyOp(data_type: ImGuiDataType, op: c_int, output: ?*anyopaque, arg_1: ?*const anyopaque, arg_2: ?*const anyopaque) void;
pub extern fn igDataTypeApplyFromText(buf: [*c]const u8, data_type: ImGuiDataType, p_data: ?*anyopaque, format: [*c]const u8) bool;
pub extern fn igDataTypeCompare(data_type: ImGuiDataType, arg_1: ?*const anyopaque, arg_2: ?*const anyopaque) c_int;
pub extern fn igDataTypeClamp(data_type: ImGuiDataType, p_data: ?*anyopaque, p_min: ?*const anyopaque, p_max: ?*const anyopaque) bool;
pub extern fn igInputTextEx(label: [*c]const u8, hint: [*c]const u8, buf: [*c]u8, buf_size: c_int, size_arg: ImVec2, flags: ImGuiInputTextFlags, callback: ImGuiInputTextCallback, user_data: ?*anyopaque) bool;
pub extern fn igInputTextDeactivateHook(id: ImGuiID) void;
pub extern fn igTempInputText(bb: ImRect, id: ImGuiID, label: [*c]const u8, buf: [*c]u8, buf_size: c_int, flags: ImGuiInputTextFlags) bool;
pub extern fn igTempInputScalar(bb: ImRect, id: ImGuiID, label: [*c]const u8, data_type: ImGuiDataType, p_data: ?*anyopaque, format: [*c]const u8, p_clamp_min: ?*const anyopaque, p_clamp_max: ?*const anyopaque) bool;
pub extern fn igTempInputIsActive(id: ImGuiID) bool;
pub extern fn igGetInputTextState(id: ImGuiID) [*c]ImGuiInputTextState;
pub extern fn igColorTooltip(text: [*c]const u8, col: [*c]const f32, flags: ImGuiColorEditFlags) void;
pub extern fn igColorEditOptionsPopup(col: [*c]const f32, flags: ImGuiColorEditFlags) void;
pub extern fn igColorPickerOptionsPopup(ref_col: [*c]const f32, flags: ImGuiColorEditFlags) void;
pub extern fn igPlotEx(plot_type: ImGuiPlotType, label: [*c]const u8, values_getter: ?*const fn (?*anyopaque, c_int) callconv(.C) f32, data: ?*anyopaque, values_count: c_int, values_offset: c_int, overlay_text: [*c]const u8, scale_min: f32, scale_max: f32, size_arg: ImVec2) c_int;
pub extern fn igShadeVertsLinearColorGradientKeepAlpha(draw_list: [*c]ImDrawList, vert_start_idx: c_int, vert_end_idx: c_int, gradient_p0: ImVec2, gradient_p1: ImVec2, col0: ImU32, col1: ImU32) void;
pub extern fn igShadeVertsLinearUV(draw_list: [*c]ImDrawList, vert_start_idx: c_int, vert_end_idx: c_int, a: ImVec2, b: ImVec2, uv_a: ImVec2, uv_b: ImVec2, clamp: bool) void;
pub extern fn igGcCompactTransientMiscBuffers() void;
pub extern fn igGcCompactTransientWindowBuffers(window: ?*ImGuiWindow) void;
pub extern fn igGcAwakeTransientWindowBuffers(window: ?*ImGuiWindow) void;
pub extern fn igDebugLog(fmt: [*c]const u8, ...) void;
pub extern fn igDebugLogV(fmt: [*c]const u8, args: va_list) void;
pub extern fn igErrorCheckEndFrameRecover(log_callback: ImGuiErrorLogCallback, user_data: ?*anyopaque) void;
pub extern fn igErrorCheckEndWindowRecover(log_callback: ImGuiErrorLogCallback, user_data: ?*anyopaque) void;
pub extern fn igErrorCheckUsingSetCursorPosToExtendParentBoundaries() void;
pub extern fn igDebugDrawCursorPos(col: ImU32) void;
pub extern fn igDebugDrawLineExtents(col: ImU32) void;
pub extern fn igDebugDrawItemRect(col: ImU32) void;
pub extern fn igDebugLocateItem(target_id: ImGuiID) void;
pub extern fn igDebugLocateItemOnHover(target_id: ImGuiID) void;
pub extern fn igDebugLocateItemResolveWithLastItem() void;
pub extern fn igDebugStartItemPicker() void;
pub extern fn igShowFontAtlas(atlas: [*c]ImFontAtlas) void;
pub extern fn igDebugHookIdInfo(id: ImGuiID, data_type: ImGuiDataType, data_id: ?*const anyopaque, data_id_end: ?*const anyopaque) void;
pub extern fn igDebugNodeColumns(columns: [*c]ImGuiOldColumns) void;
pub extern fn igDebugNodeDockNode(node: ?*ImGuiDockNode, label: [*c]const u8) void;
pub extern fn igDebugNodeDrawList(window: ?*ImGuiWindow, viewport: [*c]ImGuiViewportP, draw_list: [*c]const ImDrawList, label: [*c]const u8) void;
pub extern fn igDebugNodeDrawCmdShowMeshAndBoundingBox(out_draw_list: [*c]ImDrawList, draw_list: [*c]const ImDrawList, draw_cmd: [*c]const ImDrawCmd, show_mesh: bool, show_aabb: bool) void;
pub extern fn igDebugNodeFont(font: [*c]ImFont) void;
pub extern fn igDebugNodeFontGlyph(font: [*c]ImFont, glyph: ?*const ImFontGlyph) void;
pub extern fn igDebugNodeStorage(storage: [*c]ImGuiStorage, label: [*c]const u8) void;
pub extern fn igDebugNodeTabBar(tab_bar: [*c]ImGuiTabBar, label: [*c]const u8) void;
pub extern fn igDebugNodeTable(table: ?*ImGuiTable) void;
pub extern fn igDebugNodeTableSettings(settings: [*c]ImGuiTableSettings) void;
pub extern fn igDebugNodeInputTextState(state: [*c]ImGuiInputTextState) void;
pub extern fn igDebugNodeWindow(window: ?*ImGuiWindow, label: [*c]const u8) void;
pub extern fn igDebugNodeWindowSettings(settings: [*c]ImGuiWindowSettings) void;
pub extern fn igDebugNodeWindowsList(windows: [*c]ImVector_ImGuiWindowPtr, label: [*c]const u8) void;
pub extern fn igDebugNodeWindowsListByBeginStackParent(windows: [*c]?*ImGuiWindow, windows_size: c_int, parent_in_begin_stack: ?*ImGuiWindow) void;
pub extern fn igDebugNodeViewport(viewport: [*c]ImGuiViewportP) void;
pub extern fn igDebugRenderKeyboardPreview(draw_list: [*c]ImDrawList) void;
pub extern fn igDebugRenderViewportThumbnail(draw_list: [*c]ImDrawList, viewport: [*c]ImGuiViewportP, bb: ImRect) void;
pub extern fn igIsKeyPressedMap(key: ImGuiKey, repeat: bool) bool;
pub extern fn igImFontAtlasGetBuilderForStbTruetype() [*c]const ImFontBuilderIO;
pub extern fn igImFontAtlasBuildInit(atlas: [*c]ImFontAtlas) void;
pub extern fn igImFontAtlasBuildSetupFont(atlas: [*c]ImFontAtlas, font: [*c]ImFont, font_config: [*c]ImFontConfig, ascent: f32, descent: f32) void;
pub extern fn igImFontAtlasBuildPackCustomRects(atlas: [*c]ImFontAtlas, stbrp_context_opaque: ?*anyopaque) void;
pub extern fn igImFontAtlasBuildFinish(atlas: [*c]ImFontAtlas) void;
pub extern fn igImFontAtlasBuildRender8bppRectFromString(atlas: [*c]ImFontAtlas, x: c_int, y: c_int, w: c_int, h: c_int, in_str: [*c]const u8, in_marker_char: u8, in_marker_pixel_value: u8) void;
pub extern fn igImFontAtlasBuildRender32bppRectFromString(atlas: [*c]ImFontAtlas, x: c_int, y: c_int, w: c_int, h: c_int, in_str: [*c]const u8, in_marker_char: u8, in_marker_pixel_value: c_uint) void;
pub extern fn igImFontAtlasBuildMultiplyCalcLookupTable(out_table: [*c]u8, in_multiply_factor: f32) void;
pub extern fn igImFontAtlasBuildMultiplyRectAlpha8(table: [*c]const u8, pixels: [*c]u8, x: c_int, y: c_int, w: c_int, h: c_int, stride: c_int) void;
pub extern fn igLogText(fmt: [*c]const u8, ...) void;
pub extern fn ImGuiTextBuffer_appendf(buffer: [*c]struct_ImGuiTextBuffer, fmt: [*c]const u8, ...) void;
pub extern fn igGET_FLT_MAX() f32;
pub extern fn igGET_FLT_MIN() f32;
pub extern fn ImVector_ImWchar_create() [*c]ImVector_ImWchar;
pub extern fn ImVector_ImWchar_destroy(self: [*c]ImVector_ImWchar) void;
pub extern fn ImVector_ImWchar_Init(p: [*c]ImVector_ImWchar) void;
pub extern fn ImVector_ImWchar_UnInit(p: [*c]ImVector_ImWchar) void;
pub const __block = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // (no file):27:9
pub const __INTMAX_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `L`"); // (no file):82:9
pub const __UINTMAX_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `UL`"); // (no file):88:9
pub const __FLT16_DENORM_MIN__ = @compileError("unable to translate C expr: unexpected token 'IntegerLiteral'"); // (no file):111:9
pub const __FLT16_EPSILON__ = @compileError("unable to translate C expr: unexpected token 'IntegerLiteral'"); // (no file):115:9
pub const __FLT16_MAX__ = @compileError("unable to translate C expr: unexpected token 'IntegerLiteral'"); // (no file):121:9
pub const __FLT16_MIN__ = @compileError("unable to translate C expr: unexpected token 'IntegerLiteral'"); // (no file):124:9
pub const __INT64_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `LL`"); // (no file):184:9
pub const __UINT32_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `U`"); // (no file):206:9
pub const __UINT64_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `ULL`"); // (no file):214:9
pub const __USER_LABEL_PREFIX__ = @compileError("unable to translate macro: undefined identifier `_`"); // (no file):305:9
pub const __nonnull = @compileError("unable to translate macro: undefined identifier `_Nonnull`"); // (no file):336:9
pub const __null_unspecified = @compileError("unable to translate macro: undefined identifier `_Null_unspecified`"); // (no file):337:9
pub const __nullable = @compileError("unable to translate macro: undefined identifier `_Nullable`"); // (no file):338:9
pub const __weak = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // (no file):382:9
pub const __CONCAT = @compileError("unable to translate C expr: unexpected token '##'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:113:9
pub const __STRING = @compileError("unable to translate C expr: unexpected token '#'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:114:9
pub const __const = @compileError("unable to translate C expr: unexpected token 'const'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:116:9
pub const __volatile = @compileError("unable to translate C expr: unexpected token 'volatile'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:118:9
pub const __dead2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:162:9
pub const __pure2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:163:9
pub const __stateful_pure = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:164:9
pub const __unused = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:169:9
pub const __used = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:174:9
pub const __cold = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:180:9
pub const __returns_nonnull = @compileError("unable to translate macro: undefined identifier `__attribute`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:187:9
pub const __exported = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:197:9
pub const __exported_push = @compileError("unable to translate macro: undefined identifier `_Pragma`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:198:9
pub const __exported_pop = @compileError("unable to translate macro: undefined identifier `_Pragma`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:199:9
pub const __deprecated = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:211:9
pub const __deprecated_msg = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:215:10
pub const __kpi_deprecated = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:226:9
pub const __unavailable = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:232:9
pub const __restrict = @compileError("unable to translate C expr: unexpected token 'restrict'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:254:9
pub const __disable_tail_calls = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:287:9
pub const __not_tail_called = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:299:9
pub const __result_use_check = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:310:9
pub const __swift_unavailable = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:320:9
pub const __header_inline = @compileError("unable to translate C expr: unexpected token 'inline'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:354:10
pub const __header_always_inline = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:367:10
pub const __unreachable_ok_push = @compileError("unable to translate macro: undefined identifier `_Pragma`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:380:10
pub const __unreachable_ok_pop = @compileError("unable to translate macro: undefined identifier `_Pragma`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:383:10
pub const __printflike = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:404:9
pub const __printf0like = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:406:9
pub const __scanflike = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:408:9
pub const __osloglike = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:410:9
pub const __IDSTRING = @compileError("unable to translate C expr: unexpected token 'static'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:413:9
pub const __COPYRIGHT = @compileError("unable to translate macro: undefined identifier `copyright`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:416:9
pub const __RCSID = @compileError("unable to translate macro: undefined identifier `rcsid`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:420:9
pub const __SCCSID = @compileError("unable to translate macro: undefined identifier `sccsid`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:424:9
pub const __PROJECT_VERSION = @compileError("unable to translate macro: undefined identifier `project_version`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:428:9
pub const __FBSDID = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:433:9
pub const __DECONST = @compileError("unable to translate C expr: unexpected token 'const'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:437:9
pub const __DEVOLATILE = @compileError("unable to translate C expr: unexpected token 'volatile'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:441:9
pub const __DEQUALIFY = @compileError("unable to translate C expr: unexpected token 'const'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:445:9
pub const __alloc_size = @compileError("unable to translate C expr: expected ')' instead got '...'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:463:9
pub const __DARWIN_ALIAS = @compileError("unable to translate macro: undefined identifier `__asm`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:648:9
pub const __DARWIN_ALIAS_C = @compileError("unable to translate macro: undefined identifier `__asm`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:649:9
pub const __DARWIN_ALIAS_I = @compileError("unable to translate macro: undefined identifier `__asm`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:650:9
pub const __DARWIN_NOCANCEL = @compileError("unable to translate macro: undefined identifier `__asm`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:651:9
pub const __DARWIN_INODE64 = @compileError("unable to translate macro: undefined identifier `__asm`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:652:9
pub const __DARWIN_1050 = @compileError("unable to translate macro: undefined identifier `__asm`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:654:9
pub const __DARWIN_1050ALIAS = @compileError("unable to translate macro: undefined identifier `__asm`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:655:9
pub const __DARWIN_1050ALIAS_C = @compileError("unable to translate macro: undefined identifier `__asm`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:656:9
pub const __DARWIN_1050ALIAS_I = @compileError("unable to translate macro: undefined identifier `__asm`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:657:9
pub const __DARWIN_1050INODE64 = @compileError("unable to translate macro: undefined identifier `__asm`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:658:9
pub const __DARWIN_EXTSN = @compileError("unable to translate macro: undefined identifier `__asm`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:660:9
pub const __DARWIN_EXTSN_C = @compileError("unable to translate macro: undefined identifier `__asm`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:661:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_2_0 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:35:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_2_1 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:41:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_2_2 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:47:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_3_0 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:53:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_3_1 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:59:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_3_2 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:65:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_4_0 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:71:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_4_1 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:77:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_4_2 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:83:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_4_3 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:89:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_5_0 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:95:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_5_1 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:101:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_6_0 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:107:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_6_1 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:113:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_7_0 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:119:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_7_1 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:125:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_8_0 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:131:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_8_1 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:137:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_8_2 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:143:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_8_3 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:149:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_8_4 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:155:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_9_0 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:161:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_9_1 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:167:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_9_2 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:173:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_9_3 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:179:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_10_0 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:185:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_10_1 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:191:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_10_2 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:197:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_10_3 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:203:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_11_0 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:209:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_11_1 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:215:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_11_2 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:221:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_11_3 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:227:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_11_4 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:233:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_12_0 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:239:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_12_1 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:245:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_12_2 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:251:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_12_3 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:257:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_12_4 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:263:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_13_0 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:269:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_13_1 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:275:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_13_2 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:281:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_13_3 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:287:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_13_4 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:293:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_13_5 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:299:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_13_6 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:305:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_13_7 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:311:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_14_0 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:317:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_14_1 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:323:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_14_2 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:329:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_14_3 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:335:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_14_5 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:341:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_15_0 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:347:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_15_1 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:353:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_15_2 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:359:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_15_3 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:365:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_15_4 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:371:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_16_0 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:377:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_16_1 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:383:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_16_2 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:389:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_16_3 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:395:9
pub const __DARWIN_ALIAS_STARTING_IPHONE___IPHONE_16_4 = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_symbol_aliasing.h:401:9
pub const __DARWIN_ALIAS_STARTING = @compileError("unable to translate macro: undefined identifier `__DARWIN_ALIAS_STARTING_MAC_`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:671:9
pub const __POSIX_C_DEPRECATED = @compileError("unable to translate macro: undefined identifier `___POSIX_C_DEPRECATED_STARTING_`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:734:9
pub const __CAST_AWAY_QUALIFIER = @compileError("unable to translate macro: undefined identifier `_Pragma`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:832:9
pub const __XNU_PRIVATE_EXTERN = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:846:9
pub const __counted_by = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:860:9
pub const __sized_by = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:861:9
pub const __ended_by = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:862:9
pub const __terminated_by = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:863:9
pub const __ptrcheck_abi_assume_single = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:873:9
pub const __ptrcheck_abi_assume_unsafe_indexable = @compileError("unable to translate C expr: unexpected token 'Eof'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:874:9
pub const __unsafe_terminated_by_from_indexable = @compileError("unable to translate C expr: expected ')' instead got '...'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:883:9
pub const __unsafe_null_terminated_from_indexable = @compileError("unable to translate C expr: expected ')' instead got '...'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:884:9
pub const __compiler_barrier = @compileError("unable to translate macro: undefined identifier `__asm__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:918:9
pub const __enum_open = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:921:9
pub const __enum_closed = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:922:9
pub const __enum_options = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:929:9
pub const __enum_decl = @compileError("unable to translate C expr: expected ')' instead got '...'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:942:9
pub const __enum_closed_decl = @compileError("unable to translate C expr: expected ')' instead got '...'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:944:9
pub const __options_decl = @compileError("unable to translate C expr: expected ')' instead got '...'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:946:9
pub const __options_closed_decl = @compileError("unable to translate C expr: expected ')' instead got '...'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/cdefs.h:948:9
pub const __AVAILABILITY_INTERNAL_DEPRECATED = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:109:9
pub const __AVAILABILITY_INTERNAL_DEPRECATED_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:112:17
pub const __AVAILABILITY_INTERNAL_UNAVAILABLE = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:121:9
pub const __AVAILABILITY_INTERNAL_WEAK_IMPORT = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:122:9
pub const __AVAILABILITY_INTERNAL__MAC_10_1_DEP__MAC_10_1 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:2922:21
pub const __AVAILABILITY_INTERNAL__MAC_10_1_DEP__MAC_10_10 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:2923:21
pub const __AVAILABILITY_INTERNAL__MAC_10_1_DEP__MAC_10_10_2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:2924:21
pub const __AVAILABILITY_INTERNAL__MAC_10_1_DEP__MAC_10_10_2_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:2926:25
pub const __AVAILABILITY_INTERNAL__MAC_10_1_DEP__MAC_10_10_3 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:2930:21
pub const __AVAILABILITY_INTERNAL__MAC_10_1_DEP__MAC_10_10_3_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:2932:25
pub const __AVAILABILITY_INTERNAL__MAC_10_1_DEP__MAC_10_10_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:2937:25
pub const __AVAILABILITY_INTERNAL__MAC_10_1_DEP__MAC_10_11 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:2941:21
pub const __AVAILABILITY_INTERNAL__MAC_10_1_DEP__MAC_10_11_2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:2942:21
pub const __AVAILABILITY_INTERNAL__MAC_10_1_DEP__MAC_10_11_2_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:2944:25
pub const __AVAILABILITY_INTERNAL__MAC_10_1_DEP__MAC_10_11_3 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:2948:21
pub const __AVAILABILITY_INTERNAL__MAC_10_1_DEP__MAC_10_11_3_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:2950:25
pub const __AVAILABILITY_INTERNAL__MAC_10_1_DEP__MAC_10_11_4 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:2954:21
pub const __AVAILABILITY_INTERNAL__MAC_10_1_DEP__MAC_10_11_4_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:2956:25
pub const __AVAILABILITY_INTERNAL__MAC_10_1_DEP__MAC_10_11_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:2961:25
pub const __AVAILABILITY_INTERNAL__MAC_10_1_DEP__MAC_10_12 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:2965:21
pub const __AVAILABILITY_INTERNAL__MAC_10_1_DEP__MAC_10_12_1 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:2966:21
pub const __AVAILABILITY_INTERNAL__MAC_10_1_DEP__MAC_10_12_1_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:2968:25
pub const __AVAILABILITY_INTERNAL__MAC_10_1_DEP__MAC_10_12_2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:2972:21
pub const __AVAILABILITY_INTERNAL__MAC_10_1_DEP__MAC_10_12_2_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:2974:25
pub const __AVAILABILITY_INTERNAL__MAC_10_1_DEP__MAC_10_12_4 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:2978:21
pub const __AVAILABILITY_INTERNAL__MAC_10_1_DEP__MAC_10_12_4_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:2980:25
pub const __AVAILABILITY_INTERNAL__MAC_10_1_DEP__MAC_10_12_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:2985:25
pub const __AVAILABILITY_INTERNAL__MAC_10_1_DEP__MAC_10_1_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:2990:25
pub const __AVAILABILITY_INTERNAL__MAC_10_1_DEP__MAC_10_2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:2994:21
pub const __AVAILABILITY_INTERNAL__MAC_10_1_DEP__MAC_10_2_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:2996:25
pub const __AVAILABILITY_INTERNAL__MAC_10_1_DEP__MAC_10_3 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3000:21
pub const __AVAILABILITY_INTERNAL__MAC_10_1_DEP__MAC_10_3_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3002:25
pub const __AVAILABILITY_INTERNAL__MAC_10_1_DEP__MAC_10_4 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3006:21
pub const __AVAILABILITY_INTERNAL__MAC_10_1_DEP__MAC_10_4_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3008:25
pub const __AVAILABILITY_INTERNAL__MAC_10_1_DEP__MAC_10_5 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3012:21
pub const __AVAILABILITY_INTERNAL__MAC_10_1_DEP__MAC_10_5_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3014:25
pub const __AVAILABILITY_INTERNAL__MAC_10_1_DEP__MAC_10_6 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3018:21
pub const __AVAILABILITY_INTERNAL__MAC_10_1_DEP__MAC_10_6_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3020:25
pub const __AVAILABILITY_INTERNAL__MAC_10_1_DEP__MAC_10_7 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3024:21
pub const __AVAILABILITY_INTERNAL__MAC_10_1_DEP__MAC_10_7_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3026:25
pub const __AVAILABILITY_INTERNAL__MAC_10_1_DEP__MAC_10_8 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3030:21
pub const __AVAILABILITY_INTERNAL__MAC_10_1_DEP__MAC_10_8_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3032:25
pub const __AVAILABILITY_INTERNAL__MAC_10_1_DEP__MAC_10_9 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3036:21
pub const __AVAILABILITY_INTERNAL__MAC_10_1_DEP__MAC_10_9_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3038:25
pub const __AVAILABILITY_INTERNAL__MAC_10_1_DEP__MAC_NA = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3042:21
pub const __AVAILABILITY_INTERNAL__MAC_10_1_DEP__MAC_NA_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3043:21
pub const __AVAILABILITY_INTERNAL__MAC_10_2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3044:21
pub const __AVAILABILITY_INTERNAL__MAC_10_2_DEP__MAC_10_1 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3045:21
pub const __AVAILABILITY_INTERNAL__MAC_10_2_DEP__MAC_10_10 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3046:21
pub const __AVAILABILITY_INTERNAL__MAC_10_2_DEP__MAC_10_10_2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3047:21
pub const __AVAILABILITY_INTERNAL__MAC_10_2_DEP__MAC_10_10_2_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3049:25
pub const __AVAILABILITY_INTERNAL__MAC_10_2_DEP__MAC_10_10_3 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3053:21
pub const __AVAILABILITY_INTERNAL__MAC_10_2_DEP__MAC_10_10_3_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3055:25
pub const __AVAILABILITY_INTERNAL__MAC_10_2_DEP__MAC_10_10_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3060:25
pub const __AVAILABILITY_INTERNAL__MAC_10_2_DEP__MAC_10_11 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3064:21
pub const __AVAILABILITY_INTERNAL__MAC_10_2_DEP__MAC_10_11_2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3065:21
pub const __AVAILABILITY_INTERNAL__MAC_10_2_DEP__MAC_10_11_2_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3067:25
pub const __AVAILABILITY_INTERNAL__MAC_10_2_DEP__MAC_10_11_3 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3071:21
pub const __AVAILABILITY_INTERNAL__MAC_10_2_DEP__MAC_10_11_3_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3073:25
pub const __AVAILABILITY_INTERNAL__MAC_10_2_DEP__MAC_10_11_4 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3077:21
pub const __AVAILABILITY_INTERNAL__MAC_10_2_DEP__MAC_10_11_4_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3079:25
pub const __AVAILABILITY_INTERNAL__MAC_10_2_DEP__MAC_10_11_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3084:25
pub const __AVAILABILITY_INTERNAL__MAC_10_2_DEP__MAC_10_12 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3088:21
pub const __AVAILABILITY_INTERNAL__MAC_10_2_DEP__MAC_10_12_1 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3089:21
pub const __AVAILABILITY_INTERNAL__MAC_10_2_DEP__MAC_10_12_1_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3091:25
pub const __AVAILABILITY_INTERNAL__MAC_10_2_DEP__MAC_10_12_2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3095:21
pub const __AVAILABILITY_INTERNAL__MAC_10_2_DEP__MAC_10_12_2_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3097:25
pub const __AVAILABILITY_INTERNAL__MAC_10_2_DEP__MAC_10_12_4 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3101:21
pub const __AVAILABILITY_INTERNAL__MAC_10_2_DEP__MAC_10_12_4_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3103:25
pub const __AVAILABILITY_INTERNAL__MAC_10_2_DEP__MAC_10_12_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3108:25
pub const __AVAILABILITY_INTERNAL__MAC_10_2_DEP__MAC_10_13 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3112:21
pub const __AVAILABILITY_INTERNAL__MAC_10_2_DEP__MAC_10_2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3113:21
pub const __AVAILABILITY_INTERNAL__MAC_10_2_DEP__MAC_10_2_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3115:25
pub const __AVAILABILITY_INTERNAL__MAC_10_2_DEP__MAC_10_3 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3119:21
pub const __AVAILABILITY_INTERNAL__MAC_10_2_DEP__MAC_10_3_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3121:25
pub const __AVAILABILITY_INTERNAL__MAC_10_2_DEP__MAC_10_4 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3125:21
pub const __AVAILABILITY_INTERNAL__MAC_10_2_DEP__MAC_10_4_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3127:25
pub const __AVAILABILITY_INTERNAL__MAC_10_2_DEP__MAC_10_5 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3131:21
pub const __AVAILABILITY_INTERNAL__MAC_10_2_DEP__MAC_10_5_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3133:25
pub const __AVAILABILITY_INTERNAL__MAC_10_2_DEP__MAC_10_6 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3137:21
pub const __AVAILABILITY_INTERNAL__MAC_10_2_DEP__MAC_10_6_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3139:25
pub const __AVAILABILITY_INTERNAL__MAC_10_2_DEP__MAC_10_7 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3143:21
pub const __AVAILABILITY_INTERNAL__MAC_10_2_DEP__MAC_10_7_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3145:25
pub const __AVAILABILITY_INTERNAL__MAC_10_2_DEP__MAC_10_8 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3149:21
pub const __AVAILABILITY_INTERNAL__MAC_10_2_DEP__MAC_10_8_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3151:25
pub const __AVAILABILITY_INTERNAL__MAC_10_2_DEP__MAC_10_9 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3155:21
pub const __AVAILABILITY_INTERNAL__MAC_10_2_DEP__MAC_10_9_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3157:25
pub const __AVAILABILITY_INTERNAL__MAC_10_2_DEP__MAC_NA = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3161:21
pub const __AVAILABILITY_INTERNAL__MAC_10_2_DEP__MAC_NA_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3162:21
pub const __AVAILABILITY_INTERNAL__MAC_10_3 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3163:21
pub const __AVAILABILITY_INTERNAL__MAC_10_3_DEP__MAC_10_1 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3164:21
pub const __AVAILABILITY_INTERNAL__MAC_10_3_DEP__MAC_10_10 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3165:21
pub const __AVAILABILITY_INTERNAL__MAC_10_3_DEP__MAC_10_10_2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3166:21
pub const __AVAILABILITY_INTERNAL__MAC_10_3_DEP__MAC_10_10_2_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3168:25
pub const __AVAILABILITY_INTERNAL__MAC_10_3_DEP__MAC_10_10_3 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3172:21
pub const __AVAILABILITY_INTERNAL__MAC_10_3_DEP__MAC_10_10_3_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3174:25
pub const __AVAILABILITY_INTERNAL__MAC_10_3_DEP__MAC_10_10_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3179:25
pub const __AVAILABILITY_INTERNAL__MAC_10_3_DEP__MAC_10_11 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3183:21
pub const __AVAILABILITY_INTERNAL__MAC_10_3_DEP__MAC_10_11_2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3184:21
pub const __AVAILABILITY_INTERNAL__MAC_10_3_DEP__MAC_10_11_2_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3186:25
pub const __AVAILABILITY_INTERNAL__MAC_10_3_DEP__MAC_10_11_3 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3190:21
pub const __AVAILABILITY_INTERNAL__MAC_10_3_DEP__MAC_10_11_3_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3192:25
pub const __AVAILABILITY_INTERNAL__MAC_10_3_DEP__MAC_10_11_4 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3196:21
pub const __AVAILABILITY_INTERNAL__MAC_10_3_DEP__MAC_10_11_4_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3198:25
pub const __AVAILABILITY_INTERNAL__MAC_10_3_DEP__MAC_10_11_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3203:25
pub const __AVAILABILITY_INTERNAL__MAC_10_3_DEP__MAC_10_12 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3207:21
pub const __AVAILABILITY_INTERNAL__MAC_10_3_DEP__MAC_10_12_1 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3208:21
pub const __AVAILABILITY_INTERNAL__MAC_10_3_DEP__MAC_10_12_1_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3210:25
pub const __AVAILABILITY_INTERNAL__MAC_10_3_DEP__MAC_10_12_2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3214:21
pub const __AVAILABILITY_INTERNAL__MAC_10_3_DEP__MAC_10_12_2_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3216:25
pub const __AVAILABILITY_INTERNAL__MAC_10_3_DEP__MAC_10_12_4 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3220:21
pub const __AVAILABILITY_INTERNAL__MAC_10_3_DEP__MAC_10_12_4_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3222:25
pub const __AVAILABILITY_INTERNAL__MAC_10_3_DEP__MAC_10_12_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3227:25
pub const __AVAILABILITY_INTERNAL__MAC_10_3_DEP__MAC_10_13 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3231:21
pub const __AVAILABILITY_INTERNAL__MAC_10_3_DEP__MAC_10_3 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3232:21
pub const __AVAILABILITY_INTERNAL__MAC_10_3_DEP__MAC_10_3_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3234:25
pub const __AVAILABILITY_INTERNAL__MAC_10_3_DEP__MAC_10_4 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3238:21
pub const __AVAILABILITY_INTERNAL__MAC_10_3_DEP__MAC_10_4_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3240:25
pub const __AVAILABILITY_INTERNAL__MAC_10_3_DEP__MAC_10_5 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3244:21
pub const __AVAILABILITY_INTERNAL__MAC_10_3_DEP__MAC_10_5_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3246:25
pub const __AVAILABILITY_INTERNAL__MAC_10_3_DEP__MAC_10_6 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3250:21
pub const __AVAILABILITY_INTERNAL__MAC_10_3_DEP__MAC_10_6_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3252:25
pub const __AVAILABILITY_INTERNAL__MAC_10_3_DEP__MAC_10_7 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3256:21
pub const __AVAILABILITY_INTERNAL__MAC_10_3_DEP__MAC_10_7_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3258:25
pub const __AVAILABILITY_INTERNAL__MAC_10_3_DEP__MAC_10_8 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3262:21
pub const __AVAILABILITY_INTERNAL__MAC_10_3_DEP__MAC_10_8_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3264:25
pub const __AVAILABILITY_INTERNAL__MAC_10_3_DEP__MAC_10_9 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3268:21
pub const __AVAILABILITY_INTERNAL__MAC_10_3_DEP__MAC_10_9_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3270:25
pub const __AVAILABILITY_INTERNAL__MAC_10_3_DEP__MAC_NA = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3274:21
pub const __AVAILABILITY_INTERNAL__MAC_10_3_DEP__MAC_NA_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3275:21
pub const __AVAILABILITY_INTERNAL__MAC_10_4 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3276:21
pub const __AVAILABILITY_INTERNAL__MAC_10_4_DEP__MAC_10_1 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3277:21
pub const __AVAILABILITY_INTERNAL__MAC_10_4_DEP__MAC_10_10 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3278:21
pub const __AVAILABILITY_INTERNAL__MAC_10_4_DEP__MAC_10_10_2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3279:21
pub const __AVAILABILITY_INTERNAL__MAC_10_4_DEP__MAC_10_10_2_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3281:25
pub const __AVAILABILITY_INTERNAL__MAC_10_4_DEP__MAC_10_10_3 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3285:21
pub const __AVAILABILITY_INTERNAL__MAC_10_4_DEP__MAC_10_10_3_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3287:25
pub const __AVAILABILITY_INTERNAL__MAC_10_4_DEP__MAC_10_10_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3292:25
pub const __AVAILABILITY_INTERNAL__MAC_10_4_DEP__MAC_10_11 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3296:21
pub const __AVAILABILITY_INTERNAL__MAC_10_4_DEP__MAC_10_11_2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3297:21
pub const __AVAILABILITY_INTERNAL__MAC_10_4_DEP__MAC_10_11_2_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3299:25
pub const __AVAILABILITY_INTERNAL__MAC_10_4_DEP__MAC_10_11_3 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3303:21
pub const __AVAILABILITY_INTERNAL__MAC_10_4_DEP__MAC_10_11_3_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3305:25
pub const __AVAILABILITY_INTERNAL__MAC_10_4_DEP__MAC_10_11_4 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3309:21
pub const __AVAILABILITY_INTERNAL__MAC_10_4_DEP__MAC_10_11_4_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3311:25
pub const __AVAILABILITY_INTERNAL__MAC_10_4_DEP__MAC_10_11_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3316:25
pub const __AVAILABILITY_INTERNAL__MAC_10_4_DEP__MAC_10_12 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3320:21
pub const __AVAILABILITY_INTERNAL__MAC_10_4_DEP__MAC_10_12_1 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3321:21
pub const __AVAILABILITY_INTERNAL__MAC_10_4_DEP__MAC_10_12_1_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3323:25
pub const __AVAILABILITY_INTERNAL__MAC_10_4_DEP__MAC_10_12_2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3327:21
pub const __AVAILABILITY_INTERNAL__MAC_10_4_DEP__MAC_10_12_2_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3329:25
pub const __AVAILABILITY_INTERNAL__MAC_10_4_DEP__MAC_10_12_4 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3333:21
pub const __AVAILABILITY_INTERNAL__MAC_10_4_DEP__MAC_10_12_4_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3335:25
pub const __AVAILABILITY_INTERNAL__MAC_10_4_DEP__MAC_10_12_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3340:25
pub const __AVAILABILITY_INTERNAL__MAC_10_4_DEP__MAC_10_13 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3344:21
pub const __AVAILABILITY_INTERNAL__MAC_10_4_DEP__MAC_10_4 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3345:21
pub const __AVAILABILITY_INTERNAL__MAC_10_4_DEP__MAC_10_4_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3347:25
pub const __AVAILABILITY_INTERNAL__MAC_10_4_DEP__MAC_10_5 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3351:21
pub const __AVAILABILITY_INTERNAL__MAC_10_4_DEP__MAC_10_5_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3353:25
pub const __AVAILABILITY_INTERNAL__MAC_10_4_DEP__MAC_10_6 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3357:21
pub const __AVAILABILITY_INTERNAL__MAC_10_4_DEP__MAC_10_6_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3359:25
pub const __AVAILABILITY_INTERNAL__MAC_10_4_DEP__MAC_10_7 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3363:21
pub const __AVAILABILITY_INTERNAL__MAC_10_4_DEP__MAC_10_7_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3365:25
pub const __AVAILABILITY_INTERNAL__MAC_10_4_DEP__MAC_10_8 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3369:21
pub const __AVAILABILITY_INTERNAL__MAC_10_4_DEP__MAC_10_8_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3371:25
pub const __AVAILABILITY_INTERNAL__MAC_10_4_DEP__MAC_10_9 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3375:21
pub const __AVAILABILITY_INTERNAL__MAC_10_4_DEP__MAC_10_9_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3377:25
pub const __AVAILABILITY_INTERNAL__MAC_10_4_DEP__MAC_NA = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3381:21
pub const __AVAILABILITY_INTERNAL__MAC_10_4_DEP__MAC_NA_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3382:21
pub const __AVAILABILITY_INTERNAL__MAC_10_5 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3383:21
pub const __AVAILABILITY_INTERNAL__MAC_10_5_DEPRECATED__MAC_10_7 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3384:21
pub const __AVAILABILITY_INTERNAL__MAC_10_5_DEP__MAC_10_1 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3385:21
pub const __AVAILABILITY_INTERNAL__MAC_10_5_DEP__MAC_10_10 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3386:21
pub const __AVAILABILITY_INTERNAL__MAC_10_5_DEP__MAC_10_10_2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3387:21
pub const __AVAILABILITY_INTERNAL__MAC_10_5_DEP__MAC_10_10_2_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3389:25
pub const __AVAILABILITY_INTERNAL__MAC_10_5_DEP__MAC_10_10_3 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3393:21
pub const __AVAILABILITY_INTERNAL__MAC_10_5_DEP__MAC_10_10_3_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3395:25
pub const __AVAILABILITY_INTERNAL__MAC_10_5_DEP__MAC_10_10_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3400:25
pub const __AVAILABILITY_INTERNAL__MAC_10_5_DEP__MAC_10_11 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3404:21
pub const __AVAILABILITY_INTERNAL__MAC_10_5_DEP__MAC_10_11_2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3405:21
pub const __AVAILABILITY_INTERNAL__MAC_10_5_DEP__MAC_10_11_2_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3407:25
pub const __AVAILABILITY_INTERNAL__MAC_10_5_DEP__MAC_10_11_3 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3411:21
pub const __AVAILABILITY_INTERNAL__MAC_10_5_DEP__MAC_10_11_3_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3413:25
pub const __AVAILABILITY_INTERNAL__MAC_10_5_DEP__MAC_10_11_4 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3417:21
pub const __AVAILABILITY_INTERNAL__MAC_10_5_DEP__MAC_10_11_4_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3419:25
pub const __AVAILABILITY_INTERNAL__MAC_10_5_DEP__MAC_10_11_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3424:25
pub const __AVAILABILITY_INTERNAL__MAC_10_5_DEP__MAC_10_12 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3428:21
pub const __AVAILABILITY_INTERNAL__MAC_10_5_DEP__MAC_10_12_1 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3429:21
pub const __AVAILABILITY_INTERNAL__MAC_10_5_DEP__MAC_10_12_1_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3431:25
pub const __AVAILABILITY_INTERNAL__MAC_10_5_DEP__MAC_10_12_2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3435:21
pub const __AVAILABILITY_INTERNAL__MAC_10_5_DEP__MAC_10_12_2_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3437:25
pub const __AVAILABILITY_INTERNAL__MAC_10_5_DEP__MAC_10_12_4 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3441:21
pub const __AVAILABILITY_INTERNAL__MAC_10_5_DEP__MAC_10_12_4_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3443:25
pub const __AVAILABILITY_INTERNAL__MAC_10_5_DEP__MAC_10_12_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3448:25
pub const __AVAILABILITY_INTERNAL__MAC_10_5_DEP__MAC_10_5 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3452:21
pub const __AVAILABILITY_INTERNAL__MAC_10_5_DEP__MAC_10_5_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3454:25
pub const __AVAILABILITY_INTERNAL__MAC_10_5_DEP__MAC_10_6 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3458:21
pub const __AVAILABILITY_INTERNAL__MAC_10_5_DEP__MAC_10_6_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3460:25
pub const __AVAILABILITY_INTERNAL__MAC_10_5_DEP__MAC_10_7 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3464:21
pub const __AVAILABILITY_INTERNAL__MAC_10_5_DEP__MAC_10_7_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3466:25
pub const __AVAILABILITY_INTERNAL__MAC_10_5_DEP__MAC_10_8 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3470:21
pub const __AVAILABILITY_INTERNAL__MAC_10_5_DEP__MAC_10_8_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3472:25
pub const __AVAILABILITY_INTERNAL__MAC_10_5_DEP__MAC_10_9 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3476:21
pub const __AVAILABILITY_INTERNAL__MAC_10_5_DEP__MAC_10_9_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3478:25
pub const __AVAILABILITY_INTERNAL__MAC_10_5_DEP__MAC_NA = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3482:21
pub const __AVAILABILITY_INTERNAL__MAC_10_5_DEP__MAC_NA_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3483:21
pub const __AVAILABILITY_INTERNAL__MAC_10_6 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3484:21
pub const __AVAILABILITY_INTERNAL__MAC_10_6_DEP__MAC_10_1 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3485:21
pub const __AVAILABILITY_INTERNAL__MAC_10_6_DEP__MAC_10_10 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3486:21
pub const __AVAILABILITY_INTERNAL__MAC_10_6_DEP__MAC_10_10_2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3487:21
pub const __AVAILABILITY_INTERNAL__MAC_10_6_DEP__MAC_10_10_2_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3489:25
pub const __AVAILABILITY_INTERNAL__MAC_10_6_DEP__MAC_10_10_3 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3493:21
pub const __AVAILABILITY_INTERNAL__MAC_10_6_DEP__MAC_10_10_3_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3495:25
pub const __AVAILABILITY_INTERNAL__MAC_10_6_DEP__MAC_10_10_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3500:25
pub const __AVAILABILITY_INTERNAL__MAC_10_6_DEP__MAC_10_11 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3504:21
pub const __AVAILABILITY_INTERNAL__MAC_10_6_DEP__MAC_10_11_2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3505:21
pub const __AVAILABILITY_INTERNAL__MAC_10_6_DEP__MAC_10_11_2_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3507:25
pub const __AVAILABILITY_INTERNAL__MAC_10_6_DEP__MAC_10_11_3 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3511:21
pub const __AVAILABILITY_INTERNAL__MAC_10_6_DEP__MAC_10_11_3_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3513:25
pub const __AVAILABILITY_INTERNAL__MAC_10_6_DEP__MAC_10_11_4 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3517:21
pub const __AVAILABILITY_INTERNAL__MAC_10_6_DEP__MAC_10_11_4_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3519:25
pub const __AVAILABILITY_INTERNAL__MAC_10_6_DEP__MAC_10_11_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3524:25
pub const __AVAILABILITY_INTERNAL__MAC_10_6_DEP__MAC_10_12 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3528:21
pub const __AVAILABILITY_INTERNAL__MAC_10_6_DEP__MAC_10_12_1 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3529:21
pub const __AVAILABILITY_INTERNAL__MAC_10_6_DEP__MAC_10_12_1_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3531:25
pub const __AVAILABILITY_INTERNAL__MAC_10_6_DEP__MAC_10_12_2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3535:21
pub const __AVAILABILITY_INTERNAL__MAC_10_6_DEP__MAC_10_12_2_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3537:25
pub const __AVAILABILITY_INTERNAL__MAC_10_6_DEP__MAC_10_12_4 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3541:21
pub const __AVAILABILITY_INTERNAL__MAC_10_6_DEP__MAC_10_12_4_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3543:25
pub const __AVAILABILITY_INTERNAL__MAC_10_6_DEP__MAC_10_12_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3548:25
pub const __AVAILABILITY_INTERNAL__MAC_10_6_DEP__MAC_10_13 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3552:21
pub const __AVAILABILITY_INTERNAL__MAC_10_6_DEP__MAC_10_6 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3553:21
pub const __AVAILABILITY_INTERNAL__MAC_10_6_DEP__MAC_10_6_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3555:25
pub const __AVAILABILITY_INTERNAL__MAC_10_6_DEP__MAC_10_7 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3559:21
pub const __AVAILABILITY_INTERNAL__MAC_10_6_DEP__MAC_10_7_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3561:25
pub const __AVAILABILITY_INTERNAL__MAC_10_6_DEP__MAC_10_8 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3565:21
pub const __AVAILABILITY_INTERNAL__MAC_10_6_DEP__MAC_10_8_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3567:25
pub const __AVAILABILITY_INTERNAL__MAC_10_6_DEP__MAC_10_9 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3571:21
pub const __AVAILABILITY_INTERNAL__MAC_10_6_DEP__MAC_10_9_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3573:25
pub const __AVAILABILITY_INTERNAL__MAC_10_6_DEP__MAC_NA = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3577:21
pub const __AVAILABILITY_INTERNAL__MAC_10_6_DEP__MAC_NA_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3578:21
pub const __AVAILABILITY_INTERNAL__MAC_10_7 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3579:21
pub const __AVAILABILITY_INTERNAL__MAC_10_7_DEP__MAC_10_1 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3580:21
pub const __AVAILABILITY_INTERNAL__MAC_10_7_DEP__MAC_10_10 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3581:21
pub const __AVAILABILITY_INTERNAL__MAC_10_7_DEP__MAC_10_10_2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3582:21
pub const __AVAILABILITY_INTERNAL__MAC_10_7_DEP__MAC_10_10_2_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3584:25
pub const __AVAILABILITY_INTERNAL__MAC_10_7_DEP__MAC_10_10_3 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3588:21
pub const __AVAILABILITY_INTERNAL__MAC_10_7_DEP__MAC_10_10_3_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3590:25
pub const __AVAILABILITY_INTERNAL__MAC_10_7_DEP__MAC_10_10_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3595:25
pub const __AVAILABILITY_INTERNAL__MAC_10_7_DEP__MAC_10_11 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3599:21
pub const __AVAILABILITY_INTERNAL__MAC_10_7_DEP__MAC_10_11_2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3600:21
pub const __AVAILABILITY_INTERNAL__MAC_10_7_DEP__MAC_10_11_2_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3602:25
pub const __AVAILABILITY_INTERNAL__MAC_10_7_DEP__MAC_10_11_3 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3606:21
pub const __AVAILABILITY_INTERNAL__MAC_10_7_DEP__MAC_10_11_3_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3608:25
pub const __AVAILABILITY_INTERNAL__MAC_10_7_DEP__MAC_10_11_4 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3612:21
pub const __AVAILABILITY_INTERNAL__MAC_10_7_DEP__MAC_10_11_4_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3614:25
pub const __AVAILABILITY_INTERNAL__MAC_10_7_DEP__MAC_10_11_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3619:25
pub const __AVAILABILITY_INTERNAL__MAC_10_7_DEP__MAC_10_12 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3623:21
pub const __AVAILABILITY_INTERNAL__MAC_10_7_DEP__MAC_10_12_1 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3624:21
pub const __AVAILABILITY_INTERNAL__MAC_10_7_DEP__MAC_10_12_1_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3626:25
pub const __AVAILABILITY_INTERNAL__MAC_10_7_DEP__MAC_10_12_2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3630:21
pub const __AVAILABILITY_INTERNAL__MAC_10_7_DEP__MAC_10_12_2_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3632:25
pub const __AVAILABILITY_INTERNAL__MAC_10_7_DEP__MAC_10_12_4 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3636:21
pub const __AVAILABILITY_INTERNAL__MAC_10_7_DEP__MAC_10_12_4_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3638:25
pub const __AVAILABILITY_INTERNAL__MAC_10_7_DEP__MAC_10_12_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3643:25
pub const __AVAILABILITY_INTERNAL__MAC_10_7_DEP__MAC_10_13_2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3647:21
pub const __AVAILABILITY_INTERNAL__MAC_10_7_DEP__MAC_10_7 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3648:21
pub const __AVAILABILITY_INTERNAL__MAC_10_7_DEP__MAC_10_7_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3650:25
pub const __AVAILABILITY_INTERNAL__MAC_10_7_DEP__MAC_10_8 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3654:21
pub const __AVAILABILITY_INTERNAL__MAC_10_7_DEP__MAC_10_8_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3656:25
pub const __AVAILABILITY_INTERNAL__MAC_10_7_DEP__MAC_10_9 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3660:21
pub const __AVAILABILITY_INTERNAL__MAC_10_7_DEP__MAC_10_9_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3662:25
pub const __AVAILABILITY_INTERNAL__MAC_10_7_DEP__MAC_NA = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3666:21
pub const __AVAILABILITY_INTERNAL__MAC_10_7_DEP__MAC_NA_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3667:21
pub const __AVAILABILITY_INTERNAL__MAC_10_8 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3668:21
pub const __AVAILABILITY_INTERNAL__MAC_10_8_DEP__MAC_10_1 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3669:21
pub const __AVAILABILITY_INTERNAL__MAC_10_8_DEP__MAC_10_10 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3670:21
pub const __AVAILABILITY_INTERNAL__MAC_10_8_DEP__MAC_10_10_2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3671:21
pub const __AVAILABILITY_INTERNAL__MAC_10_8_DEP__MAC_10_10_2_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3673:25
pub const __AVAILABILITY_INTERNAL__MAC_10_8_DEP__MAC_10_10_3 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3677:21
pub const __AVAILABILITY_INTERNAL__MAC_10_8_DEP__MAC_10_10_3_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3679:25
pub const __AVAILABILITY_INTERNAL__MAC_10_8_DEP__MAC_10_10_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3684:25
pub const __AVAILABILITY_INTERNAL__MAC_10_8_DEP__MAC_10_11 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3688:21
pub const __AVAILABILITY_INTERNAL__MAC_10_8_DEP__MAC_10_11_2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3689:21
pub const __AVAILABILITY_INTERNAL__MAC_10_8_DEP__MAC_10_11_2_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3691:25
pub const __AVAILABILITY_INTERNAL__MAC_10_8_DEP__MAC_10_11_3 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3695:21
pub const __AVAILABILITY_INTERNAL__MAC_10_8_DEP__MAC_10_11_3_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3697:25
pub const __AVAILABILITY_INTERNAL__MAC_10_8_DEP__MAC_10_11_4 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3701:21
pub const __AVAILABILITY_INTERNAL__MAC_10_8_DEP__MAC_10_11_4_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3703:25
pub const __AVAILABILITY_INTERNAL__MAC_10_8_DEP__MAC_10_11_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3708:25
pub const __AVAILABILITY_INTERNAL__MAC_10_8_DEP__MAC_10_12 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3712:21
pub const __AVAILABILITY_INTERNAL__MAC_10_8_DEP__MAC_10_12_1 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3713:21
pub const __AVAILABILITY_INTERNAL__MAC_10_8_DEP__MAC_10_12_1_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3715:25
pub const __AVAILABILITY_INTERNAL__MAC_10_8_DEP__MAC_10_12_2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3719:21
pub const __AVAILABILITY_INTERNAL__MAC_10_8_DEP__MAC_10_12_2_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3721:25
pub const __AVAILABILITY_INTERNAL__MAC_10_8_DEP__MAC_10_12_4 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3725:21
pub const __AVAILABILITY_INTERNAL__MAC_10_8_DEP__MAC_10_12_4_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3727:25
pub const __AVAILABILITY_INTERNAL__MAC_10_8_DEP__MAC_10_12_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3732:25
pub const __AVAILABILITY_INTERNAL__MAC_10_8_DEP__MAC_10_13 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3736:21
pub const __AVAILABILITY_INTERNAL__MAC_10_8_DEP__MAC_10_8 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3737:21
pub const __AVAILABILITY_INTERNAL__MAC_10_8_DEP__MAC_10_8_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3739:25
pub const __AVAILABILITY_INTERNAL__MAC_10_8_DEP__MAC_10_9 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3743:21
pub const __AVAILABILITY_INTERNAL__MAC_10_8_DEP__MAC_10_9_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3745:25
pub const __AVAILABILITY_INTERNAL__MAC_10_8_DEP__MAC_NA = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3749:21
pub const __AVAILABILITY_INTERNAL__MAC_10_8_DEP__MAC_NA_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3750:21
pub const __AVAILABILITY_INTERNAL__MAC_10_9 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3751:21
pub const __AVAILABILITY_INTERNAL__MAC_10_9_DEP__MAC_10_1 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3752:21
pub const __AVAILABILITY_INTERNAL__MAC_10_9_DEP__MAC_10_10 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3753:21
pub const __AVAILABILITY_INTERNAL__MAC_10_9_DEP__MAC_10_10_2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3754:21
pub const __AVAILABILITY_INTERNAL__MAC_10_9_DEP__MAC_10_10_2_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3756:25
pub const __AVAILABILITY_INTERNAL__MAC_10_9_DEP__MAC_10_10_3 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3760:21
pub const __AVAILABILITY_INTERNAL__MAC_10_9_DEP__MAC_10_10_3_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3762:25
pub const __AVAILABILITY_INTERNAL__MAC_10_9_DEP__MAC_10_10_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3767:25
pub const __AVAILABILITY_INTERNAL__MAC_10_9_DEP__MAC_10_11 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3771:21
pub const __AVAILABILITY_INTERNAL__MAC_10_9_DEP__MAC_10_11_2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3772:21
pub const __AVAILABILITY_INTERNAL__MAC_10_9_DEP__MAC_10_11_2_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3774:25
pub const __AVAILABILITY_INTERNAL__MAC_10_9_DEP__MAC_10_11_3 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3778:21
pub const __AVAILABILITY_INTERNAL__MAC_10_9_DEP__MAC_10_11_3_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3780:25
pub const __AVAILABILITY_INTERNAL__MAC_10_9_DEP__MAC_10_11_4 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3784:21
pub const __AVAILABILITY_INTERNAL__MAC_10_9_DEP__MAC_10_11_4_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3786:25
pub const __AVAILABILITY_INTERNAL__MAC_10_9_DEP__MAC_10_11_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3791:25
pub const __AVAILABILITY_INTERNAL__MAC_10_9_DEP__MAC_10_12 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3795:21
pub const __AVAILABILITY_INTERNAL__MAC_10_9_DEP__MAC_10_12_1 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3796:21
pub const __AVAILABILITY_INTERNAL__MAC_10_9_DEP__MAC_10_12_1_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3798:25
pub const __AVAILABILITY_INTERNAL__MAC_10_9_DEP__MAC_10_12_2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3802:21
pub const __AVAILABILITY_INTERNAL__MAC_10_9_DEP__MAC_10_12_2_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3804:25
pub const __AVAILABILITY_INTERNAL__MAC_10_9_DEP__MAC_10_12_4 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3808:21
pub const __AVAILABILITY_INTERNAL__MAC_10_9_DEP__MAC_10_12_4_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3810:25
pub const __AVAILABILITY_INTERNAL__MAC_10_9_DEP__MAC_10_12_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3815:25
pub const __AVAILABILITY_INTERNAL__MAC_10_9_DEP__MAC_10_13 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3819:21
pub const __AVAILABILITY_INTERNAL__MAC_10_9_DEP__MAC_10_14 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3820:21
pub const __AVAILABILITY_INTERNAL__MAC_10_9_DEP__MAC_10_9 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3821:21
pub const __AVAILABILITY_INTERNAL__MAC_10_9_DEP__MAC_10_9_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3823:25
pub const __AVAILABILITY_INTERNAL__MAC_10_9_DEP__MAC_NA = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3827:21
pub const __AVAILABILITY_INTERNAL__MAC_10_9_DEP__MAC_NA_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3828:21
pub const __AVAILABILITY_INTERNAL__MAC_10_0 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3829:21
pub const __AVAILABILITY_INTERNAL__MAC_10_0_DEP__MAC_10_0 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3830:21
pub const __AVAILABILITY_INTERNAL__MAC_10_0_DEP__MAC_10_0_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3832:25
pub const __AVAILABILITY_INTERNAL__MAC_10_0_DEP__MAC_10_1 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3836:21
pub const __AVAILABILITY_INTERNAL__MAC_10_0_DEP__MAC_10_10 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3837:21
pub const __AVAILABILITY_INTERNAL__MAC_10_0_DEP__MAC_10_10_2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3838:21
pub const __AVAILABILITY_INTERNAL__MAC_10_0_DEP__MAC_10_10_2_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3840:25
pub const __AVAILABILITY_INTERNAL__MAC_10_0_DEP__MAC_10_10_3 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3844:21
pub const __AVAILABILITY_INTERNAL__MAC_10_0_DEP__MAC_10_10_3_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3846:25
pub const __AVAILABILITY_INTERNAL__MAC_10_0_DEP__MAC_10_10_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3851:25
pub const __AVAILABILITY_INTERNAL__MAC_10_0_DEP__MAC_10_11 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3855:21
pub const __AVAILABILITY_INTERNAL__MAC_10_0_DEP__MAC_10_11_2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3856:21
pub const __AVAILABILITY_INTERNAL__MAC_10_0_DEP__MAC_10_11_2_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3858:25
pub const __AVAILABILITY_INTERNAL__MAC_10_0_DEP__MAC_10_11_3 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3862:21
pub const __AVAILABILITY_INTERNAL__MAC_10_0_DEP__MAC_10_11_3_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3864:25
pub const __AVAILABILITY_INTERNAL__MAC_10_0_DEP__MAC_10_11_4 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3868:21
pub const __AVAILABILITY_INTERNAL__MAC_10_0_DEP__MAC_10_11_4_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3870:25
pub const __AVAILABILITY_INTERNAL__MAC_10_0_DEP__MAC_10_11_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3875:25
pub const __AVAILABILITY_INTERNAL__MAC_10_0_DEP__MAC_10_12 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3879:21
pub const __AVAILABILITY_INTERNAL__MAC_10_0_DEP__MAC_10_12_1 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3880:21
pub const __AVAILABILITY_INTERNAL__MAC_10_0_DEP__MAC_10_12_1_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3882:25
pub const __AVAILABILITY_INTERNAL__MAC_10_0_DEP__MAC_10_12_2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3886:21
pub const __AVAILABILITY_INTERNAL__MAC_10_0_DEP__MAC_10_12_2_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3888:25
pub const __AVAILABILITY_INTERNAL__MAC_10_0_DEP__MAC_10_12_4 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3892:21
pub const __AVAILABILITY_INTERNAL__MAC_10_0_DEP__MAC_10_12_4_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3894:25
pub const __AVAILABILITY_INTERNAL__MAC_10_0_DEP__MAC_10_12_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3899:25
pub const __AVAILABILITY_INTERNAL__MAC_10_0_DEP__MAC_10_13 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3903:21
pub const __AVAILABILITY_INTERNAL__MAC_10_0_DEP__MAC_10_1_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3905:25
pub const __AVAILABILITY_INTERNAL__MAC_10_0_DEP__MAC_10_2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3909:21
pub const __AVAILABILITY_INTERNAL__MAC_10_0_DEP__MAC_10_2_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3911:25
pub const __AVAILABILITY_INTERNAL__MAC_10_0_DEP__MAC_10_3 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3915:21
pub const __AVAILABILITY_INTERNAL__MAC_10_0_DEP__MAC_10_3_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3917:25
pub const __AVAILABILITY_INTERNAL__MAC_10_0_DEP__MAC_10_4 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3921:21
pub const __AVAILABILITY_INTERNAL__MAC_10_0_DEP__MAC_10_4_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3923:25
pub const __AVAILABILITY_INTERNAL__MAC_10_0_DEP__MAC_10_5 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3927:21
pub const __AVAILABILITY_INTERNAL__MAC_10_0_DEP__MAC_10_5_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3929:25
pub const __AVAILABILITY_INTERNAL__MAC_10_0_DEP__MAC_10_6 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3933:21
pub const __AVAILABILITY_INTERNAL__MAC_10_0_DEP__MAC_10_6_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3935:25
pub const __AVAILABILITY_INTERNAL__MAC_10_0_DEP__MAC_10_7 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3939:21
pub const __AVAILABILITY_INTERNAL__MAC_10_0_DEP__MAC_10_7_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3941:25
pub const __AVAILABILITY_INTERNAL__MAC_10_0_DEP__MAC_10_8 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3945:21
pub const __AVAILABILITY_INTERNAL__MAC_10_0_DEP__MAC_10_8_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3947:25
pub const __AVAILABILITY_INTERNAL__MAC_10_0_DEP__MAC_10_9 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3951:21
pub const __AVAILABILITY_INTERNAL__MAC_10_0_DEP__MAC_10_9_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3953:25
pub const __AVAILABILITY_INTERNAL__MAC_10_0_DEP__MAC_10_13_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3958:25
pub const __AVAILABILITY_INTERNAL__MAC_10_0_DEP__MAC_NA = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3962:21
pub const __AVAILABILITY_INTERNAL__MAC_10_0_DEP__MAC_NA_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3963:21
pub const __AVAILABILITY_INTERNAL__MAC_10_1 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3964:21
pub const __AVAILABILITY_INTERNAL__MAC_10_10 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3965:21
pub const __AVAILABILITY_INTERNAL__MAC_10_10_2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3966:21
pub const __AVAILABILITY_INTERNAL__MAC_10_10_2_DEP__MAC_10_10_2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3967:21
pub const __AVAILABILITY_INTERNAL__MAC_10_10_2_DEP__MAC_10_10_2_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3969:25
pub const __AVAILABILITY_INTERNAL__MAC_10_10_2_DEP__MAC_10_10_3 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3973:21
pub const __AVAILABILITY_INTERNAL__MAC_10_10_2_DEP__MAC_10_10_3_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3975:25
pub const __AVAILABILITY_INTERNAL__MAC_10_10_2_DEP__MAC_10_11 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3979:21
pub const __AVAILABILITY_INTERNAL__MAC_10_10_2_DEP__MAC_10_11_2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3980:21
pub const __AVAILABILITY_INTERNAL__MAC_10_10_2_DEP__MAC_10_11_2_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3982:25
pub const __AVAILABILITY_INTERNAL__MAC_10_10_2_DEP__MAC_10_11_3 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3986:21
pub const __AVAILABILITY_INTERNAL__MAC_10_10_2_DEP__MAC_10_11_3_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3988:25
pub const __AVAILABILITY_INTERNAL__MAC_10_10_2_DEP__MAC_10_11_4 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3992:21
pub const __AVAILABILITY_INTERNAL__MAC_10_10_2_DEP__MAC_10_11_4_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3994:25
pub const __AVAILABILITY_INTERNAL__MAC_10_10_2_DEP__MAC_10_11_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:3999:25
pub const __AVAILABILITY_INTERNAL__MAC_10_10_2_DEP__MAC_10_12 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4003:21
pub const __AVAILABILITY_INTERNAL__MAC_10_10_2_DEP__MAC_10_12_1 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4004:21
pub const __AVAILABILITY_INTERNAL__MAC_10_10_2_DEP__MAC_10_12_1_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4006:25
pub const __AVAILABILITY_INTERNAL__MAC_10_10_2_DEP__MAC_10_12_2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4010:21
pub const __AVAILABILITY_INTERNAL__MAC_10_10_2_DEP__MAC_10_12_2_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4012:25
pub const __AVAILABILITY_INTERNAL__MAC_10_10_2_DEP__MAC_10_12_4 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4016:21
pub const __AVAILABILITY_INTERNAL__MAC_10_10_2_DEP__MAC_10_12_4_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4018:25
pub const __AVAILABILITY_INTERNAL__MAC_10_10_2_DEP__MAC_10_12_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4023:25
pub const __AVAILABILITY_INTERNAL__MAC_10_10_2_DEP__MAC_NA = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4027:21
pub const __AVAILABILITY_INTERNAL__MAC_10_10_2_DEP__MAC_NA_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4028:21
pub const __AVAILABILITY_INTERNAL__MAC_10_10_3 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4029:21
pub const __AVAILABILITY_INTERNAL__MAC_10_10_3_DEP__MAC_10_10_3 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4030:21
pub const __AVAILABILITY_INTERNAL__MAC_10_10_3_DEP__MAC_10_10_3_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4032:25
pub const __AVAILABILITY_INTERNAL__MAC_10_10_3_DEP__MAC_10_11 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4036:21
pub const __AVAILABILITY_INTERNAL__MAC_10_10_3_DEP__MAC_10_11_2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4037:21
pub const __AVAILABILITY_INTERNAL__MAC_10_10_3_DEP__MAC_10_11_2_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4039:25
pub const __AVAILABILITY_INTERNAL__MAC_10_10_3_DEP__MAC_10_11_3 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4043:21
pub const __AVAILABILITY_INTERNAL__MAC_10_10_3_DEP__MAC_10_11_3_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4045:25
pub const __AVAILABILITY_INTERNAL__MAC_10_10_3_DEP__MAC_10_11_4 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4049:21
pub const __AVAILABILITY_INTERNAL__MAC_10_10_3_DEP__MAC_10_11_4_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4051:25
pub const __AVAILABILITY_INTERNAL__MAC_10_10_3_DEP__MAC_10_11_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4056:25
pub const __AVAILABILITY_INTERNAL__MAC_10_10_3_DEP__MAC_10_12 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4060:21
pub const __AVAILABILITY_INTERNAL__MAC_10_10_3_DEP__MAC_10_12_1 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4061:21
pub const __AVAILABILITY_INTERNAL__MAC_10_10_3_DEP__MAC_10_12_1_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4063:25
pub const __AVAILABILITY_INTERNAL__MAC_10_10_3_DEP__MAC_10_12_2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4067:21
pub const __AVAILABILITY_INTERNAL__MAC_10_10_3_DEP__MAC_10_12_2_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4069:25
pub const __AVAILABILITY_INTERNAL__MAC_10_10_3_DEP__MAC_10_12_4 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4073:21
pub const __AVAILABILITY_INTERNAL__MAC_10_10_3_DEP__MAC_10_12_4_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4075:25
pub const __AVAILABILITY_INTERNAL__MAC_10_10_3_DEP__MAC_10_12_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4080:25
pub const __AVAILABILITY_INTERNAL__MAC_10_10_3_DEP__MAC_NA = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4084:21
pub const __AVAILABILITY_INTERNAL__MAC_10_10_3_DEP__MAC_NA_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4085:21
pub const __AVAILABILITY_INTERNAL__MAC_10_10_DEP__MAC_10_1 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4086:21
pub const __AVAILABILITY_INTERNAL__MAC_10_10_DEP__MAC_10_10 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4087:21
pub const __AVAILABILITY_INTERNAL__MAC_10_10_DEP__MAC_10_10_2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4088:21
pub const __AVAILABILITY_INTERNAL__MAC_10_10_DEP__MAC_10_10_2_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4090:25
pub const __AVAILABILITY_INTERNAL__MAC_10_10_DEP__MAC_10_10_3 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4094:21
pub const __AVAILABILITY_INTERNAL__MAC_10_10_DEP__MAC_10_10_3_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4096:25
pub const __AVAILABILITY_INTERNAL__MAC_10_10_DEP__MAC_10_10_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4101:25
pub const __AVAILABILITY_INTERNAL__MAC_10_10_DEP__MAC_10_11 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4105:21
pub const __AVAILABILITY_INTERNAL__MAC_10_10_DEP__MAC_10_11_2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4106:21
pub const __AVAILABILITY_INTERNAL__MAC_10_10_DEP__MAC_10_11_2_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4108:25
pub const __AVAILABILITY_INTERNAL__MAC_10_10_DEP__MAC_10_11_3 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4112:21
pub const __AVAILABILITY_INTERNAL__MAC_10_10_DEP__MAC_10_11_3_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4114:25
pub const __AVAILABILITY_INTERNAL__MAC_10_10_DEP__MAC_10_11_4 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4118:21
pub const __AVAILABILITY_INTERNAL__MAC_10_10_DEP__MAC_10_11_4_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4120:25
pub const __AVAILABILITY_INTERNAL__MAC_10_10_DEP__MAC_10_11_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4125:25
pub const __AVAILABILITY_INTERNAL__MAC_10_10_DEP__MAC_10_12 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4129:21
pub const __AVAILABILITY_INTERNAL__MAC_10_10_DEP__MAC_10_12_1 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4130:21
pub const __AVAILABILITY_INTERNAL__MAC_10_10_DEP__MAC_10_12_1_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4132:25
pub const __AVAILABILITY_INTERNAL__MAC_10_10_DEP__MAC_10_12_2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4136:21
pub const __AVAILABILITY_INTERNAL__MAC_10_10_DEP__MAC_10_12_2_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4138:25
pub const __AVAILABILITY_INTERNAL__MAC_10_10_DEP__MAC_10_12_4 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4142:21
pub const __AVAILABILITY_INTERNAL__MAC_10_10_DEP__MAC_10_12_4_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4144:25
pub const __AVAILABILITY_INTERNAL__MAC_10_10_DEP__MAC_10_12_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4149:25
pub const __AVAILABILITY_INTERNAL__MAC_10_10_DEP__MAC_10_13 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4153:21
pub const __AVAILABILITY_INTERNAL__MAC_10_10_DEP__MAC_10_13_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4155:25
pub const __AVAILABILITY_INTERNAL__MAC_10_10_DEP__MAC_10_13_4 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4159:21
pub const __AVAILABILITY_INTERNAL__MAC_10_10_DEP__MAC_NA = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4160:21
pub const __AVAILABILITY_INTERNAL__MAC_10_10_DEP__MAC_NA_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4161:21
pub const __AVAILABILITY_INTERNAL__MAC_10_11 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4162:21
pub const __AVAILABILITY_INTERNAL__MAC_10_11_2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4163:21
pub const __AVAILABILITY_INTERNAL__MAC_10_11_2_DEP__MAC_10_11_2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4164:21
pub const __AVAILABILITY_INTERNAL__MAC_10_11_2_DEP__MAC_10_11_2_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4166:25
pub const __AVAILABILITY_INTERNAL__MAC_10_11_2_DEP__MAC_10_11_3 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4170:21
pub const __AVAILABILITY_INTERNAL__MAC_10_11_2_DEP__MAC_10_11_3_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4172:25
pub const __AVAILABILITY_INTERNAL__MAC_10_11_2_DEP__MAC_10_11_4 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4176:21
pub const __AVAILABILITY_INTERNAL__MAC_10_11_2_DEP__MAC_10_11_4_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4178:25
pub const __AVAILABILITY_INTERNAL__MAC_10_11_2_DEP__MAC_10_12 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4182:21
pub const __AVAILABILITY_INTERNAL__MAC_10_11_2_DEP__MAC_10_12_1 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4183:21
pub const __AVAILABILITY_INTERNAL__MAC_10_11_2_DEP__MAC_10_12_1_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4185:25
pub const __AVAILABILITY_INTERNAL__MAC_10_11_2_DEP__MAC_10_12_2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4189:21
pub const __AVAILABILITY_INTERNAL__MAC_10_11_2_DEP__MAC_10_12_2_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4191:25
pub const __AVAILABILITY_INTERNAL__MAC_10_11_2_DEP__MAC_10_12_4 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4195:21
pub const __AVAILABILITY_INTERNAL__MAC_10_11_2_DEP__MAC_10_12_4_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4197:25
pub const __AVAILABILITY_INTERNAL__MAC_10_11_2_DEP__MAC_10_12_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4202:25
pub const __AVAILABILITY_INTERNAL__MAC_10_11_2_DEP__MAC_NA = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4206:21
pub const __AVAILABILITY_INTERNAL__MAC_10_11_2_DEP__MAC_NA_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4207:21
pub const __AVAILABILITY_INTERNAL__MAC_10_11_3 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4208:21
pub const __AVAILABILITY_INTERNAL__MAC_10_11_3_DEP__MAC_10_11_3 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4209:21
pub const __AVAILABILITY_INTERNAL__MAC_10_11_3_DEP__MAC_10_11_3_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4211:25
pub const __AVAILABILITY_INTERNAL__MAC_10_11_3_DEP__MAC_10_11_4 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4215:21
pub const __AVAILABILITY_INTERNAL__MAC_10_11_3_DEP__MAC_10_11_4_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4217:25
pub const __AVAILABILITY_INTERNAL__MAC_10_11_3_DEP__MAC_10_12 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4221:21
pub const __AVAILABILITY_INTERNAL__MAC_10_11_3_DEP__MAC_10_12_1 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4222:21
pub const __AVAILABILITY_INTERNAL__MAC_10_11_3_DEP__MAC_10_12_1_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4224:25
pub const __AVAILABILITY_INTERNAL__MAC_10_11_3_DEP__MAC_10_12_2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4228:21
pub const __AVAILABILITY_INTERNAL__MAC_10_11_3_DEP__MAC_10_12_2_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4230:25
pub const __AVAILABILITY_INTERNAL__MAC_10_11_3_DEP__MAC_10_12_4 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4234:21
pub const __AVAILABILITY_INTERNAL__MAC_10_11_3_DEP__MAC_10_12_4_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4236:25
pub const __AVAILABILITY_INTERNAL__MAC_10_11_3_DEP__MAC_10_12_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4241:25
pub const __AVAILABILITY_INTERNAL__MAC_10_11_3_DEP__MAC_NA = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4245:21
pub const __AVAILABILITY_INTERNAL__MAC_10_11_3_DEP__MAC_NA_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4246:21
pub const __AVAILABILITY_INTERNAL__MAC_10_11_4 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4247:21
pub const __AVAILABILITY_INTERNAL__MAC_10_11_4_DEP__MAC_10_11_4 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4248:21
pub const __AVAILABILITY_INTERNAL__MAC_10_11_4_DEP__MAC_10_11_4_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4250:25
pub const __AVAILABILITY_INTERNAL__MAC_10_11_4_DEP__MAC_10_12 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4254:21
pub const __AVAILABILITY_INTERNAL__MAC_10_11_4_DEP__MAC_10_12_1 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4255:21
pub const __AVAILABILITY_INTERNAL__MAC_10_11_4_DEP__MAC_10_12_1_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4257:25
pub const __AVAILABILITY_INTERNAL__MAC_10_11_4_DEP__MAC_10_12_2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4261:21
pub const __AVAILABILITY_INTERNAL__MAC_10_11_4_DEP__MAC_10_12_2_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4263:25
pub const __AVAILABILITY_INTERNAL__MAC_10_11_4_DEP__MAC_10_12_4 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4267:21
pub const __AVAILABILITY_INTERNAL__MAC_10_11_4_DEP__MAC_10_12_4_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4269:25
pub const __AVAILABILITY_INTERNAL__MAC_10_11_4_DEP__MAC_10_12_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4274:25
pub const __AVAILABILITY_INTERNAL__MAC_10_11_4_DEP__MAC_NA = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4278:21
pub const __AVAILABILITY_INTERNAL__MAC_10_11_4_DEP__MAC_NA_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4279:21
pub const __AVAILABILITY_INTERNAL__MAC_10_11_DEP__MAC_10_1 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4280:21
pub const __AVAILABILITY_INTERNAL__MAC_10_11_DEP__MAC_10_11 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4281:21
pub const __AVAILABILITY_INTERNAL__MAC_10_11_DEP__MAC_10_11_2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4282:21
pub const __AVAILABILITY_INTERNAL__MAC_10_11_DEP__MAC_10_11_2_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4284:25
pub const __AVAILABILITY_INTERNAL__MAC_10_11_DEP__MAC_10_11_3 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4288:21
pub const __AVAILABILITY_INTERNAL__MAC_10_11_DEP__MAC_10_11_3_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4290:25
pub const __AVAILABILITY_INTERNAL__MAC_10_11_DEP__MAC_10_11_4 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4294:21
pub const __AVAILABILITY_INTERNAL__MAC_10_11_DEP__MAC_10_11_4_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4296:25
pub const __AVAILABILITY_INTERNAL__MAC_10_11_DEP__MAC_10_11_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4301:25
pub const __AVAILABILITY_INTERNAL__MAC_10_11_DEP__MAC_10_12 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4305:21
pub const __AVAILABILITY_INTERNAL__MAC_10_11_DEP__MAC_10_12_1 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4306:21
pub const __AVAILABILITY_INTERNAL__MAC_10_11_DEP__MAC_10_12_1_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4308:25
pub const __AVAILABILITY_INTERNAL__MAC_10_11_DEP__MAC_10_12_2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4312:21
pub const __AVAILABILITY_INTERNAL__MAC_10_11_DEP__MAC_10_12_2_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4314:25
pub const __AVAILABILITY_INTERNAL__MAC_10_11_DEP__MAC_10_12_4 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4318:21
pub const __AVAILABILITY_INTERNAL__MAC_10_11_DEP__MAC_10_12_4_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4320:25
pub const __AVAILABILITY_INTERNAL__MAC_10_11_DEP__MAC_10_12_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4325:25
pub const __AVAILABILITY_INTERNAL__MAC_10_11_DEP__MAC_NA = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4329:21
pub const __AVAILABILITY_INTERNAL__MAC_10_11_DEP__MAC_NA_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4330:21
pub const __AVAILABILITY_INTERNAL__MAC_10_12 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4331:21
pub const __AVAILABILITY_INTERNAL__MAC_10_12_1 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4332:21
pub const __AVAILABILITY_INTERNAL__MAC_10_12_1_DEP__MAC_10_12_1 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4333:21
pub const __AVAILABILITY_INTERNAL__MAC_10_12_1_DEP__MAC_10_12_1_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4335:25
pub const __AVAILABILITY_INTERNAL__MAC_10_12_1_DEP__MAC_10_12_2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4339:21
pub const __AVAILABILITY_INTERNAL__MAC_10_12_1_DEP__MAC_10_12_2_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4341:25
pub const __AVAILABILITY_INTERNAL__MAC_10_12_1_DEP__MAC_10_12_4 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4345:21
pub const __AVAILABILITY_INTERNAL__MAC_10_12_1_DEP__MAC_10_12_4_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4347:25
pub const __AVAILABILITY_INTERNAL__MAC_10_12_1_DEP__MAC_NA = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4351:21
pub const __AVAILABILITY_INTERNAL__MAC_10_12_1_DEP__MAC_NA_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4352:21
pub const __AVAILABILITY_INTERNAL__MAC_10_12_2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4353:21
pub const __AVAILABILITY_INTERNAL__MAC_10_12_2_DEP__MAC_10_12_2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4354:21
pub const __AVAILABILITY_INTERNAL__MAC_10_12_2_DEP__MAC_10_12_2_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4356:25
pub const __AVAILABILITY_INTERNAL__MAC_10_12_2_DEP__MAC_10_12_4 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4360:21
pub const __AVAILABILITY_INTERNAL__MAC_10_12_2_DEP__MAC_10_12_4_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4362:25
pub const __AVAILABILITY_INTERNAL__MAC_10_12_2_DEP__MAC_NA = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4366:21
pub const __AVAILABILITY_INTERNAL__MAC_10_12_2_DEP__MAC_NA_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4367:21
pub const __AVAILABILITY_INTERNAL__MAC_10_12_4 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4368:21
pub const __AVAILABILITY_INTERNAL__MAC_10_12_4_DEP__MAC_10_12_4 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4369:21
pub const __AVAILABILITY_INTERNAL__MAC_10_12_4_DEP__MAC_10_12_4_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4371:25
pub const __AVAILABILITY_INTERNAL__MAC_10_12_4_DEP__MAC_NA = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4375:21
pub const __AVAILABILITY_INTERNAL__MAC_10_12_4_DEP__MAC_NA_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4376:21
pub const __AVAILABILITY_INTERNAL__MAC_10_12_DEP__MAC_10_12 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4377:21
pub const __AVAILABILITY_INTERNAL__MAC_10_12_DEP__MAC_10_12_1 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4378:21
pub const __AVAILABILITY_INTERNAL__MAC_10_12_DEP__MAC_10_12_1_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4380:25
pub const __AVAILABILITY_INTERNAL__MAC_10_12_DEP__MAC_10_12_2 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4384:21
pub const __AVAILABILITY_INTERNAL__MAC_10_12_DEP__MAC_10_12_2_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4386:25
pub const __AVAILABILITY_INTERNAL__MAC_10_12_DEP__MAC_10_12_4 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4390:21
pub const __AVAILABILITY_INTERNAL__MAC_10_12_DEP__MAC_10_12_4_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4392:25
pub const __AVAILABILITY_INTERNAL__MAC_10_12_DEP__MAC_10_12_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4397:25
pub const __AVAILABILITY_INTERNAL__MAC_10_12_DEP__MAC_10_13 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4401:21
pub const __AVAILABILITY_INTERNAL__MAC_10_12_DEP__MAC_10_13_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4403:25
pub const __AVAILABILITY_INTERNAL__MAC_10_12_DEP__MAC_10_13_4 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4407:21
pub const __AVAILABILITY_INTERNAL__MAC_10_12_DEP__MAC_10_14 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4408:21
pub const __AVAILABILITY_INTERNAL__MAC_10_12_DEP__MAC_NA = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4409:21
pub const __AVAILABILITY_INTERNAL__MAC_10_12_DEP__MAC_NA_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4410:21
pub const __AVAILABILITY_INTERNAL__MAC_10_13 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4411:21
pub const __AVAILABILITY_INTERNAL__MAC_10_13_4 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4412:21
pub const __AVAILABILITY_INTERNAL__MAC_10_14 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4413:21
pub const __AVAILABILITY_INTERNAL__MAC_10_14_DEP__MAC_10_14 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4414:21
pub const __AVAILABILITY_INTERNAL__MAC_10_15 = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4415:21
pub const __AVAILABILITY_INTERNAL__MAC_NA = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4417:21
pub const __AVAILABILITY_INTERNAL__MAC_NA_DEP__MAC_NA = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4418:21
pub const __AVAILABILITY_INTERNAL__MAC_NA_DEP__MAC_NA_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4419:21
pub const __AVAILABILITY_INTERNAL__IPHONE_NA = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4421:21
pub const __AVAILABILITY_INTERNAL__IPHONE_NA__IPHONE_NA = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4422:21
pub const __AVAILABILITY_INTERNAL__IPHONE_NA_DEP__IPHONE_NA = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4423:21
pub const __AVAILABILITY_INTERNAL__IPHONE_NA_DEP__IPHONE_NA_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4424:21
pub const __AVAILABILITY_INTERNAL__IPHONE_COMPAT_VERSION = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4427:22
pub const __AVAILABILITY_INTERNAL__IPHONE_COMPAT_VERSION_DEP__IPHONE_COMPAT_VERSION = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4428:22
pub const __AVAILABILITY_INTERNAL__IPHONE_COMPAT_VERSION_DEP__IPHONE_COMPAT_VERSION_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4429:22
pub const __API_AVAILABLE_PLATFORM_macos = @compileError("unable to translate macro: undefined identifier `macos`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4445:13
pub const __API_AVAILABLE_PLATFORM_macosx = @compileError("unable to translate macro: undefined identifier `macosx`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4446:13
pub const __API_AVAILABLE_PLATFORM_ios = @compileError("unable to translate macro: undefined identifier `ios`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4447:13
pub const __API_AVAILABLE_PLATFORM_watchos = @compileError("unable to translate macro: undefined identifier `watchos`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4448:13
pub const __API_AVAILABLE_PLATFORM_tvos = @compileError("unable to translate macro: undefined identifier `tvos`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4449:13
pub const __API_AVAILABLE_PLATFORM_macCatalyst = @compileError("unable to translate macro: undefined identifier `macCatalyst`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4451:13
pub const __API_AVAILABLE_PLATFORM_uikitformac = @compileError("unable to translate macro: undefined identifier `uikitformac`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4454:14
pub const __API_AVAILABLE_PLATFORM_driverkit = @compileError("unable to translate macro: undefined identifier `driverkit`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4456:13
pub const __API_A = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4461:17
pub const __API_AVAILABLE2 = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4470:13
pub const __API_AVAILABLE3 = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4471:13
pub const __API_AVAILABLE4 = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4472:13
pub const __API_AVAILABLE5 = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4473:13
pub const __API_AVAILABLE6 = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4474:13
pub const __API_AVAILABLE7 = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4475:13
pub const __API_AVAILABLE8 = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4476:13
pub const __API_AVAILABLE_GET_MACRO = @compileError("unable to translate C expr: expected ')' instead got '...'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4477:13
pub const __API_APPLY_TO = @compileError("unable to translate macro: undefined identifier `any`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4479:13
pub const __API_RANGE_STRINGIFY2 = @compileError("unable to translate C expr: unexpected token '#'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4481:13
pub const __API_A_BEGIN = @compileError("unable to translate macro: undefined identifier `_Pragma`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4483:13
pub const __API_AVAILABLE_BEGIN2 = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4486:13
pub const __API_AVAILABLE_BEGIN3 = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4487:13
pub const __API_AVAILABLE_BEGIN4 = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4488:13
pub const __API_AVAILABLE_BEGIN5 = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4489:13
pub const __API_AVAILABLE_BEGIN6 = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4490:13
pub const __API_AVAILABLE_BEGIN7 = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4491:13
pub const __API_AVAILABLE_BEGIN8 = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4492:13
pub const __API_AVAILABLE_BEGIN_GET_MACRO = @compileError("unable to translate C expr: expected ')' instead got '...'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4493:13
pub const __API_DEPRECATED_PLATFORM_macos = @compileError("unable to translate macro: undefined identifier `macos`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4496:13
pub const __API_DEPRECATED_PLATFORM_macosx = @compileError("unable to translate macro: undefined identifier `macosx`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4497:13
pub const __API_DEPRECATED_PLATFORM_ios = @compileError("unable to translate macro: undefined identifier `ios`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4498:13
pub const __API_DEPRECATED_PLATFORM_watchos = @compileError("unable to translate macro: undefined identifier `watchos`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4499:13
pub const __API_DEPRECATED_PLATFORM_tvos = @compileError("unable to translate macro: undefined identifier `tvos`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4500:13
pub const __API_DEPRECATED_PLATFORM_macCatalyst = @compileError("unable to translate macro: undefined identifier `macCatalyst`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4502:13
pub const __API_DEPRECATED_PLATFORM_uikitformac = @compileError("unable to translate macro: undefined identifier `uikitformac`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4505:14
pub const __API_DEPRECATED_PLATFORM_driverkit = @compileError("unable to translate macro: undefined identifier `driverkit`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4507:13
pub const __API_D = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4512:17
pub const __API_DEPRECATED_MSG3 = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4521:13
pub const __API_DEPRECATED_MSG4 = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4522:13
pub const __API_DEPRECATED_MSG5 = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4523:13
pub const __API_DEPRECATED_MSG6 = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4524:13
pub const __API_DEPRECATED_MSG7 = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4525:13
pub const __API_DEPRECATED_MSG8 = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4526:13
pub const __API_DEPRECATED_MSG9 = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4527:13
pub const __API_DEPRECATED_MSG_GET_MACRO = @compileError("unable to translate C expr: expected ')' instead got '...'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4528:13
pub const __API_D_BEGIN = @compileError("unable to translate macro: undefined identifier `_Pragma`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4530:13
pub const __API_DEPRECATED_BEGIN_MSG3 = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4533:13
pub const __API_DEPRECATED_BEGIN_MSG4 = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4534:13
pub const __API_DEPRECATED_BEGIN_MSG5 = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4535:13
pub const __API_DEPRECATED_BEGIN_MSG6 = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4536:13
pub const __API_DEPRECATED_BEGIN_MSG7 = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4537:13
pub const __API_DEPRECATED_BEGIN_MSG8 = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4538:13
pub const __API_DEPRECATED_BEGIN_MSG9 = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4539:13
pub const __API_DEPRECATED_BEGIN_MSG_GET_MACRO = @compileError("unable to translate C expr: expected ')' instead got '...'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4540:13
pub const __API_R = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4543:17
pub const __API_DEPRECATED_REP3 = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4549:13
pub const __API_DEPRECATED_REP4 = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4550:13
pub const __API_DEPRECATED_REP5 = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4551:13
pub const __API_DEPRECATED_REP6 = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4552:13
pub const __API_DEPRECATED_REP7 = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4553:13
pub const __API_DEPRECATED_REP8 = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4554:13
pub const __API_DEPRECATED_REP9 = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4555:13
pub const __API_DEPRECATED_REP_GET_MACRO = @compileError("unable to translate C expr: expected ')' instead got '...'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4556:13
pub const __API_R_BEGIN = @compileError("unable to translate macro: undefined identifier `_Pragma`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4559:17
pub const __API_DEPRECATED_BEGIN_REP3 = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4565:13
pub const __API_DEPRECATED_BEGIN_REP4 = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4566:13
pub const __API_DEPRECATED_BEGIN_REP5 = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4567:13
pub const __API_DEPRECATED_BEGIN_REP6 = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4568:13
pub const __API_DEPRECATED_BEGIN_REP7 = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4569:13
pub const __API_DEPRECATED_BEGIN_REP8 = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4570:13
pub const __API_DEPRECATED_BEGIN_REP9 = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4571:13
pub const __API_DEPRECATED_BEGIN_REP_GET_MACRO = @compileError("unable to translate C expr: expected ')' instead got '...'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4573:13
pub const __API_UNAVAILABLE_PLATFORM_macos = @compileError("unable to translate macro: undefined identifier `macos`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4583:13
pub const __API_UNAVAILABLE_PLATFORM_macosx = @compileError("unable to translate macro: undefined identifier `macosx`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4584:13
pub const __API_UNAVAILABLE_PLATFORM_ios = @compileError("unable to translate macro: undefined identifier `ios`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4585:13
pub const __API_UNAVAILABLE_PLATFORM_watchos = @compileError("unable to translate macro: undefined identifier `watchos`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4586:13
pub const __API_UNAVAILABLE_PLATFORM_tvos = @compileError("unable to translate macro: undefined identifier `tvos`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4587:13
pub const __API_UNAVAILABLE_PLATFORM_macCatalyst = @compileError("unable to translate macro: undefined identifier `macCatalyst`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4589:13
pub const __API_UNAVAILABLE_PLATFORM_uikitformac = @compileError("unable to translate macro: undefined identifier `uikitformac`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4592:14
pub const __API_UNAVAILABLE_PLATFORM_driverkit = @compileError("unable to translate macro: undefined identifier `driverkit`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4594:13
pub const __API_U = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4599:17
pub const __API_UNAVAILABLE2 = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4608:13
pub const __API_UNAVAILABLE3 = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4609:13
pub const __API_UNAVAILABLE4 = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4610:13
pub const __API_UNAVAILABLE5 = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4611:13
pub const __API_UNAVAILABLE6 = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4612:13
pub const __API_UNAVAILABLE7 = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4613:13
pub const __API_UNAVAILABLE8 = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4614:13
pub const __API_UNAVAILABLE_GET_MACRO = @compileError("unable to translate C expr: expected ')' instead got '...'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4615:13
pub const __API_U_BEGIN = @compileError("unable to translate macro: undefined identifier `_Pragma`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4617:13
pub const __API_UNAVAILABLE_BEGIN2 = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4620:13
pub const __API_UNAVAILABLE_BEGIN3 = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4621:13
pub const __API_UNAVAILABLE_BEGIN4 = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4622:13
pub const __API_UNAVAILABLE_BEGIN5 = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4623:13
pub const __API_UNAVAILABLE_BEGIN6 = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4624:13
pub const __API_UNAVAILABLE_BEGIN7 = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4625:13
pub const __API_UNAVAILABLE_BEGIN8 = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4626:13
pub const __API_UNAVAILABLE_BEGIN_GET_MACRO = @compileError("unable to translate C expr: expected ')' instead got '...'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4627:13
pub const __swift_compiler_version_at_least = @compileError("unable to translate C expr: expected ')' instead got '...'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4676:13
pub const __SPI_AVAILABLE = @compileError("unable to translate C expr: expected ')' instead got '...'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/AvailabilityInternal.h:4684:11
pub const __OSX_AVAILABLE_STARTING = @compileError("unable to translate macro: undefined identifier `__AVAILABILITY_INTERNAL`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/Availability.h:202:17
pub const __OSX_AVAILABLE_BUT_DEPRECATED = @compileError("unable to translate macro: undefined identifier `__AVAILABILITY_INTERNAL`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/Availability.h:203:17
pub const __OSX_AVAILABLE_BUT_DEPRECATED_MSG = @compileError("unable to translate macro: undefined identifier `__AVAILABILITY_INTERNAL`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/Availability.h:205:17
pub const __OS_AVAILABILITY = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/Availability.h:228:13
pub const __OS_AVAILABILITY_MSG = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/Availability.h:229:13
pub const __OSX_EXTENSION_UNAVAILABLE = @compileError("unable to translate macro: undefined identifier `macosx_app_extension`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/Availability.h:246:13
pub const __IOS_EXTENSION_UNAVAILABLE = @compileError("unable to translate macro: undefined identifier `ios_app_extension`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/Availability.h:247:13
pub const __OS_EXTENSION_UNAVAILABLE = @compileError("unable to translate C expr: unexpected token 'Identifier'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/Availability.h:257:9
pub const __OSX_UNAVAILABLE = @compileError("unable to translate macro: undefined identifier `macosx`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/Availability.h:264:13
pub const __OSX_AVAILABLE = @compileError("unable to translate macro: undefined identifier `macosx`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/Availability.h:265:13
pub const __OSX_DEPRECATED = @compileError("unable to translate macro: undefined identifier `macosx`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/Availability.h:266:13
pub const __IOS_UNAVAILABLE = @compileError("unable to translate macro: undefined identifier `ios`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/Availability.h:286:13
pub const __IOS_PROHIBITED = @compileError("unable to translate macro: undefined identifier `ios`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/Availability.h:287:13
pub const __IOS_AVAILABLE = @compileError("unable to translate macro: undefined identifier `ios`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/Availability.h:288:13
pub const __IOS_DEPRECATED = @compileError("unable to translate macro: undefined identifier `ios`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/Availability.h:289:13
pub const __TVOS_UNAVAILABLE = @compileError("unable to translate macro: undefined identifier `tvos`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/Availability.h:313:13
pub const __TVOS_PROHIBITED = @compileError("unable to translate macro: undefined identifier `tvos`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/Availability.h:314:13
pub const __TVOS_AVAILABLE = @compileError("unable to translate macro: undefined identifier `tvos`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/Availability.h:315:13
pub const __TVOS_DEPRECATED = @compileError("unable to translate macro: undefined identifier `tvos`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/Availability.h:316:13
pub const __WATCHOS_UNAVAILABLE = @compileError("unable to translate macro: undefined identifier `watchos`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/Availability.h:340:13
pub const __WATCHOS_PROHIBITED = @compileError("unable to translate macro: undefined identifier `watchos`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/Availability.h:341:13
pub const __WATCHOS_AVAILABLE = @compileError("unable to translate macro: undefined identifier `watchos`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/Availability.h:342:13
pub const __WATCHOS_DEPRECATED = @compileError("unable to translate macro: undefined identifier `watchos`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/Availability.h:343:13
pub const __SWIFT_UNAVAILABLE = @compileError("unable to translate macro: undefined identifier `swift`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/Availability.h:369:13
pub const __SWIFT_UNAVAILABLE_MSG = @compileError("unable to translate macro: undefined identifier `swift`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/Availability.h:370:13
pub const __API_AVAILABLE = @compileError("unable to translate C expr: expected ')' instead got '...'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/Availability.h:413:13
pub const __API_AVAILABLE_BEGIN = @compileError("unable to translate C expr: expected ')' instead got '...'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/Availability.h:415:13
pub const __API_AVAILABLE_END = @compileError("unable to translate macro: undefined identifier `_Pragma`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/Availability.h:416:13
pub const __API_DEPRECATED = @compileError("unable to translate C expr: expected ')' instead got '...'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/Availability.h:434:13
pub const __API_DEPRECATED_WITH_REPLACEMENT = @compileError("unable to translate C expr: expected ')' instead got '...'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/Availability.h:435:13
pub const __API_DEPRECATED_BEGIN = @compileError("unable to translate C expr: expected ')' instead got '...'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/Availability.h:437:13
pub const __API_DEPRECATED_END = @compileError("unable to translate macro: undefined identifier `_Pragma`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/Availability.h:438:13
pub const __API_DEPRECATED_WITH_REPLACEMENT_BEGIN = @compileError("unable to translate C expr: expected ')' instead got '...'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/Availability.h:440:13
pub const __API_DEPRECATED_WITH_REPLACEMENT_END = @compileError("unable to translate macro: undefined identifier `_Pragma`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/Availability.h:441:13
pub const __API_UNAVAILABLE = @compileError("unable to translate C expr: expected ')' instead got '...'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/Availability.h:451:13
pub const __API_UNAVAILABLE_BEGIN = @compileError("unable to translate C expr: expected ')' instead got '...'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/Availability.h:453:13
pub const __API_UNAVAILABLE_END = @compileError("unable to translate macro: undefined identifier `_Pragma`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/Availability.h:454:13
pub const __SPI_DEPRECATED = @compileError("unable to translate C expr: expected ')' instead got '...'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/Availability.h:507:11
pub const __SPI_DEPRECATED_WITH_REPLACEMENT = @compileError("unable to translate C expr: expected ')' instead got '...'"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/Availability.h:511:11
pub const __offsetof = @compileError("unable to translate macro: undefined identifier `__builtin_offsetof`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/sys/_types.h:83:9
pub const __strfmonlike = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/_types.h:31:9
pub const __strftimelike = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/_types.h:33:9
pub const __sgetc = @compileError("TODO unary inc/dec expr"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/stdio.h:268:9
pub const __sclearerr = @compileError("unable to translate C expr: expected ')' instead got '&='"); // /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk/usr/include/stdio.h:292:9
pub const API = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // cimgui.h:17:17
pub const va_start = @compileError("unable to translate macro: undefined identifier `__builtin_va_start`"); // /Users/mikedesaro/zig/lib/include/stdarg.h:33:9
pub const va_end = @compileError("unable to translate macro: undefined identifier `__builtin_va_end`"); // /Users/mikedesaro/zig/lib/include/stdarg.h:35:9
pub const va_arg = @compileError("unable to translate macro: undefined identifier `__builtin_va_arg`"); // /Users/mikedesaro/zig/lib/include/stdarg.h:36:9
pub const __va_copy = @compileError("unable to translate macro: undefined identifier `__builtin_va_copy`"); // /Users/mikedesaro/zig/lib/include/stdarg.h:41:9
pub const va_copy = @compileError("unable to translate macro: undefined identifier `__builtin_va_copy`"); // /Users/mikedesaro/zig/lib/include/stdarg.h:46:9
pub const EXTERN = @compileError("unable to translate C expr: unexpected token 'extern'"); // cimgui.h:28:13
pub const CONST = @compileError("unable to translate C expr: unexpected token 'const'"); // cimgui.h:32:9
pub const __llvm__ = @as(c_int, 1);
pub const __clang__ = @as(c_int, 1);
pub const __clang_major__ = @as(c_int, 16);
pub const __clang_minor__ = @as(c_int, 0);
pub const __clang_patchlevel__ = @as(c_int, 6);
pub const __clang_version__ = "16.0.6 (https://github.com/ziglang/zig-bootstrap 34644ad5032c58e39327d33d7f96d63d7c330003)";
pub const __GNUC__ = @as(c_int, 4);
pub const __GNUC_MINOR__ = @as(c_int, 2);
pub const __GNUC_PATCHLEVEL__ = @as(c_int, 1);
pub const __GXX_ABI_VERSION = @as(c_int, 1002);
pub const __ATOMIC_RELAXED = @as(c_int, 0);
pub const __ATOMIC_CONSUME = @as(c_int, 1);
pub const __ATOMIC_ACQUIRE = @as(c_int, 2);
pub const __ATOMIC_RELEASE = @as(c_int, 3);
pub const __ATOMIC_ACQ_REL = @as(c_int, 4);
pub const __ATOMIC_SEQ_CST = @as(c_int, 5);
pub const __OPENCL_MEMORY_SCOPE_WORK_ITEM = @as(c_int, 0);
pub const __OPENCL_MEMORY_SCOPE_WORK_GROUP = @as(c_int, 1);
pub const __OPENCL_MEMORY_SCOPE_DEVICE = @as(c_int, 2);
pub const __OPENCL_MEMORY_SCOPE_ALL_SVM_DEVICES = @as(c_int, 3);
pub const __OPENCL_MEMORY_SCOPE_SUB_GROUP = @as(c_int, 4);
pub const __PRAGMA_REDEFINE_EXTNAME = @as(c_int, 1);
pub const __VERSION__ = "Clang 16.0.6 (https://github.com/ziglang/zig-bootstrap 34644ad5032c58e39327d33d7f96d63d7c330003)";
pub const __OBJC_BOOL_IS_BOOL = @as(c_int, 1);
pub const __CONSTANT_CFSTRINGS__ = @as(c_int, 1);
pub const __BLOCKS__ = @as(c_int, 1);
pub const __clang_literal_encoding__ = "UTF-8";
pub const __clang_wide_literal_encoding__ = "UTF-32";
pub const __ORDER_LITTLE_ENDIAN__ = @as(c_int, 1234);
pub const __ORDER_BIG_ENDIAN__ = @as(c_int, 4321);
pub const __ORDER_PDP_ENDIAN__ = @as(c_int, 3412);
pub const __BYTE_ORDER__ = __ORDER_LITTLE_ENDIAN__;
pub const __LITTLE_ENDIAN__ = @as(c_int, 1);
pub const _LP64 = @as(c_int, 1);
pub const __LP64__ = @as(c_int, 1);
pub const __CHAR_BIT__ = @as(c_int, 8);
pub const __BOOL_WIDTH__ = @as(c_int, 8);
pub const __SHRT_WIDTH__ = @as(c_int, 16);
pub const __INT_WIDTH__ = @as(c_int, 32);
pub const __LONG_WIDTH__ = @as(c_int, 64);
pub const __LLONG_WIDTH__ = @as(c_int, 64);
pub const __BITINT_MAXWIDTH__ = @as(c_int, 128);
pub const __SCHAR_MAX__ = @as(c_int, 127);
pub const __SHRT_MAX__ = @as(c_int, 32767);
pub const __INT_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __LONG_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __LONG_LONG_MAX__ = @as(c_longlong, 9223372036854775807);
pub const __WCHAR_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __WCHAR_WIDTH__ = @as(c_int, 32);
pub const __WINT_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __WINT_WIDTH__ = @as(c_int, 32);
pub const __INTMAX_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __INTMAX_WIDTH__ = @as(c_int, 64);
pub const __SIZE_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const __SIZE_WIDTH__ = @as(c_int, 64);
pub const __UINTMAX_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const __UINTMAX_WIDTH__ = @as(c_int, 64);
pub const __PTRDIFF_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __PTRDIFF_WIDTH__ = @as(c_int, 64);
pub const __INTPTR_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __INTPTR_WIDTH__ = @as(c_int, 64);
pub const __UINTPTR_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const __UINTPTR_WIDTH__ = @as(c_int, 64);
pub const __SIZEOF_DOUBLE__ = @as(c_int, 8);
pub const __SIZEOF_FLOAT__ = @as(c_int, 4);
pub const __SIZEOF_INT__ = @as(c_int, 4);
pub const __SIZEOF_LONG__ = @as(c_int, 8);
pub const __SIZEOF_LONG_DOUBLE__ = @as(c_int, 8);
pub const __SIZEOF_LONG_LONG__ = @as(c_int, 8);
pub const __SIZEOF_POINTER__ = @as(c_int, 8);
pub const __SIZEOF_SHORT__ = @as(c_int, 2);
pub const __SIZEOF_PTRDIFF_T__ = @as(c_int, 8);
pub const __SIZEOF_SIZE_T__ = @as(c_int, 8);
pub const __SIZEOF_WCHAR_T__ = @as(c_int, 4);
pub const __SIZEOF_WINT_T__ = @as(c_int, 4);
pub const __SIZEOF_INT128__ = @as(c_int, 16);
pub const __INTMAX_TYPE__ = c_long;
pub const __INTMAX_FMTd__ = "ld";
pub const __INTMAX_FMTi__ = "li";
pub const __UINTMAX_TYPE__ = c_ulong;
pub const __UINTMAX_FMTo__ = "lo";
pub const __UINTMAX_FMTu__ = "lu";
pub const __UINTMAX_FMTx__ = "lx";
pub const __UINTMAX_FMTX__ = "lX";
pub const __PTRDIFF_TYPE__ = c_long;
pub const __PTRDIFF_FMTd__ = "ld";
pub const __PTRDIFF_FMTi__ = "li";
pub const __INTPTR_TYPE__ = c_long;
pub const __INTPTR_FMTd__ = "ld";
pub const __INTPTR_FMTi__ = "li";
pub const __SIZE_TYPE__ = c_ulong;
pub const __SIZE_FMTo__ = "lo";
pub const __SIZE_FMTu__ = "lu";
pub const __SIZE_FMTx__ = "lx";
pub const __SIZE_FMTX__ = "lX";
pub const __WCHAR_TYPE__ = c_int;
pub const __WINT_TYPE__ = c_int;
pub const __SIG_ATOMIC_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __SIG_ATOMIC_WIDTH__ = @as(c_int, 32);
pub const __CHAR16_TYPE__ = c_ushort;
pub const __CHAR32_TYPE__ = c_uint;
pub const __UINTPTR_TYPE__ = c_ulong;
pub const __UINTPTR_FMTo__ = "lo";
pub const __UINTPTR_FMTu__ = "lu";
pub const __UINTPTR_FMTx__ = "lx";
pub const __UINTPTR_FMTX__ = "lX";
pub const __FLT16_HAS_DENORM__ = @as(c_int, 1);
pub const __FLT16_DIG__ = @as(c_int, 3);
pub const __FLT16_DECIMAL_DIG__ = @as(c_int, 5);
pub const __FLT16_HAS_INFINITY__ = @as(c_int, 1);
pub const __FLT16_HAS_QUIET_NAN__ = @as(c_int, 1);
pub const __FLT16_MANT_DIG__ = @as(c_int, 11);
pub const __FLT16_MAX_10_EXP__ = @as(c_int, 4);
pub const __FLT16_MAX_EXP__ = @as(c_int, 16);
pub const __FLT16_MIN_10_EXP__ = -@as(c_int, 4);
pub const __FLT16_MIN_EXP__ = -@as(c_int, 13);
pub const __FLT_DENORM_MIN__ = @as(f32, 1.40129846e-45);
pub const __FLT_HAS_DENORM__ = @as(c_int, 1);
pub const __FLT_DIG__ = @as(c_int, 6);
pub const __FLT_DECIMAL_DIG__ = @as(c_int, 9);
pub const __FLT_EPSILON__ = @as(f32, 1.19209290e-7);
pub const __FLT_HAS_INFINITY__ = @as(c_int, 1);
pub const __FLT_HAS_QUIET_NAN__ = @as(c_int, 1);
pub const __FLT_MANT_DIG__ = @as(c_int, 24);
pub const __FLT_MAX_10_EXP__ = @as(c_int, 38);
pub const __FLT_MAX_EXP__ = @as(c_int, 128);
pub const __FLT_MAX__ = @as(f32, 3.40282347e+38);
pub const __FLT_MIN_10_EXP__ = -@as(c_int, 37);
pub const __FLT_MIN_EXP__ = -@as(c_int, 125);
pub const __FLT_MIN__ = @as(f32, 1.17549435e-38);
pub const __DBL_DENORM_MIN__ = @as(f64, 4.9406564584124654e-324);
pub const __DBL_HAS_DENORM__ = @as(c_int, 1);
pub const __DBL_DIG__ = @as(c_int, 15);
pub const __DBL_DECIMAL_DIG__ = @as(c_int, 17);
pub const __DBL_EPSILON__ = @as(f64, 2.2204460492503131e-16);
pub const __DBL_HAS_INFINITY__ = @as(c_int, 1);
pub const __DBL_HAS_QUIET_NAN__ = @as(c_int, 1);
pub const __DBL_MANT_DIG__ = @as(c_int, 53);
pub const __DBL_MAX_10_EXP__ = @as(c_int, 308);
pub const __DBL_MAX_EXP__ = @as(c_int, 1024);
pub const __DBL_MAX__ = @as(f64, 1.7976931348623157e+308);
pub const __DBL_MIN_10_EXP__ = -@as(c_int, 307);
pub const __DBL_MIN_EXP__ = -@as(c_int, 1021);
pub const __DBL_MIN__ = @as(f64, 2.2250738585072014e-308);
pub const __LDBL_DENORM_MIN__ = @as(c_longdouble, 4.9406564584124654e-324);
pub const __LDBL_HAS_DENORM__ = @as(c_int, 1);
pub const __LDBL_DIG__ = @as(c_int, 15);
pub const __LDBL_DECIMAL_DIG__ = @as(c_int, 17);
pub const __LDBL_EPSILON__ = @as(c_longdouble, 2.2204460492503131e-16);
pub const __LDBL_HAS_INFINITY__ = @as(c_int, 1);
pub const __LDBL_HAS_QUIET_NAN__ = @as(c_int, 1);
pub const __LDBL_MANT_DIG__ = @as(c_int, 53);
pub const __LDBL_MAX_10_EXP__ = @as(c_int, 308);
pub const __LDBL_MAX_EXP__ = @as(c_int, 1024);
pub const __LDBL_MAX__ = @as(c_longdouble, 1.7976931348623157e+308);
pub const __LDBL_MIN_10_EXP__ = -@as(c_int, 307);
pub const __LDBL_MIN_EXP__ = -@as(c_int, 1021);
pub const __LDBL_MIN__ = @as(c_longdouble, 2.2250738585072014e-308);
pub const __POINTER_WIDTH__ = @as(c_int, 64);
pub const __BIGGEST_ALIGNMENT__ = @as(c_int, 8);
pub const __INT8_TYPE__ = i8;
pub const __INT8_FMTd__ = "hhd";
pub const __INT8_FMTi__ = "hhi";
pub const __INT8_C_SUFFIX__ = "";
pub const __INT16_TYPE__ = c_short;
pub const __INT16_FMTd__ = "hd";
pub const __INT16_FMTi__ = "hi";
pub const __INT16_C_SUFFIX__ = "";
pub const __INT32_TYPE__ = c_int;
pub const __INT32_FMTd__ = "d";
pub const __INT32_FMTi__ = "i";
pub const __INT32_C_SUFFIX__ = "";
pub const __INT64_TYPE__ = c_longlong;
pub const __INT64_FMTd__ = "lld";
pub const __INT64_FMTi__ = "lli";
pub const __UINT8_TYPE__ = u8;
pub const __UINT8_FMTo__ = "hho";
pub const __UINT8_FMTu__ = "hhu";
pub const __UINT8_FMTx__ = "hhx";
pub const __UINT8_FMTX__ = "hhX";
pub const __UINT8_C_SUFFIX__ = "";
pub const __UINT8_MAX__ = @as(c_int, 255);
pub const __INT8_MAX__ = @as(c_int, 127);
pub const __UINT16_TYPE__ = c_ushort;
pub const __UINT16_FMTo__ = "ho";
pub const __UINT16_FMTu__ = "hu";
pub const __UINT16_FMTx__ = "hx";
pub const __UINT16_FMTX__ = "hX";
pub const __UINT16_C_SUFFIX__ = "";
pub const __UINT16_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 65535, .decimal);
pub const __INT16_MAX__ = @as(c_int, 32767);
pub const __UINT32_TYPE__ = c_uint;
pub const __UINT32_FMTo__ = "o";
pub const __UINT32_FMTu__ = "u";
pub const __UINT32_FMTx__ = "x";
pub const __UINT32_FMTX__ = "X";
pub const __UINT32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_uint, 4294967295, .decimal);
pub const __INT32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __UINT64_TYPE__ = c_ulonglong;
pub const __UINT64_FMTo__ = "llo";
pub const __UINT64_FMTu__ = "llu";
pub const __UINT64_FMTx__ = "llx";
pub const __UINT64_FMTX__ = "llX";
pub const __UINT64_MAX__ = @as(c_ulonglong, 18446744073709551615);
pub const __INT64_MAX__ = @as(c_longlong, 9223372036854775807);
pub const __INT_LEAST8_TYPE__ = i8;
pub const __INT_LEAST8_MAX__ = @as(c_int, 127);
pub const __INT_LEAST8_WIDTH__ = @as(c_int, 8);
pub const __INT_LEAST8_FMTd__ = "hhd";
pub const __INT_LEAST8_FMTi__ = "hhi";
pub const __UINT_LEAST8_TYPE__ = u8;
pub const __UINT_LEAST8_MAX__ = @as(c_int, 255);
pub const __UINT_LEAST8_FMTo__ = "hho";
pub const __UINT_LEAST8_FMTu__ = "hhu";
pub const __UINT_LEAST8_FMTx__ = "hhx";
pub const __UINT_LEAST8_FMTX__ = "hhX";
pub const __INT_LEAST16_TYPE__ = c_short;
pub const __INT_LEAST16_MAX__ = @as(c_int, 32767);
pub const __INT_LEAST16_WIDTH__ = @as(c_int, 16);
pub const __INT_LEAST16_FMTd__ = "hd";
pub const __INT_LEAST16_FMTi__ = "hi";
pub const __UINT_LEAST16_TYPE__ = c_ushort;
pub const __UINT_LEAST16_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 65535, .decimal);
pub const __UINT_LEAST16_FMTo__ = "ho";
pub const __UINT_LEAST16_FMTu__ = "hu";
pub const __UINT_LEAST16_FMTx__ = "hx";
pub const __UINT_LEAST16_FMTX__ = "hX";
pub const __INT_LEAST32_TYPE__ = c_int;
pub const __INT_LEAST32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __INT_LEAST32_WIDTH__ = @as(c_int, 32);
pub const __INT_LEAST32_FMTd__ = "d";
pub const __INT_LEAST32_FMTi__ = "i";
pub const __UINT_LEAST32_TYPE__ = c_uint;
pub const __UINT_LEAST32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_uint, 4294967295, .decimal);
pub const __UINT_LEAST32_FMTo__ = "o";
pub const __UINT_LEAST32_FMTu__ = "u";
pub const __UINT_LEAST32_FMTx__ = "x";
pub const __UINT_LEAST32_FMTX__ = "X";
pub const __INT_LEAST64_TYPE__ = c_longlong;
pub const __INT_LEAST64_MAX__ = @as(c_longlong, 9223372036854775807);
pub const __INT_LEAST64_WIDTH__ = @as(c_int, 64);
pub const __INT_LEAST64_FMTd__ = "lld";
pub const __INT_LEAST64_FMTi__ = "lli";
pub const __UINT_LEAST64_TYPE__ = c_ulonglong;
pub const __UINT_LEAST64_MAX__ = @as(c_ulonglong, 18446744073709551615);
pub const __UINT_LEAST64_FMTo__ = "llo";
pub const __UINT_LEAST64_FMTu__ = "llu";
pub const __UINT_LEAST64_FMTx__ = "llx";
pub const __UINT_LEAST64_FMTX__ = "llX";
pub const __INT_FAST8_TYPE__ = i8;
pub const __INT_FAST8_MAX__ = @as(c_int, 127);
pub const __INT_FAST8_WIDTH__ = @as(c_int, 8);
pub const __INT_FAST8_FMTd__ = "hhd";
pub const __INT_FAST8_FMTi__ = "hhi";
pub const __UINT_FAST8_TYPE__ = u8;
pub const __UINT_FAST8_MAX__ = @as(c_int, 255);
pub const __UINT_FAST8_FMTo__ = "hho";
pub const __UINT_FAST8_FMTu__ = "hhu";
pub const __UINT_FAST8_FMTx__ = "hhx";
pub const __UINT_FAST8_FMTX__ = "hhX";
pub const __INT_FAST16_TYPE__ = c_short;
pub const __INT_FAST16_MAX__ = @as(c_int, 32767);
pub const __INT_FAST16_WIDTH__ = @as(c_int, 16);
pub const __INT_FAST16_FMTd__ = "hd";
pub const __INT_FAST16_FMTi__ = "hi";
pub const __UINT_FAST16_TYPE__ = c_ushort;
pub const __UINT_FAST16_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 65535, .decimal);
pub const __UINT_FAST16_FMTo__ = "ho";
pub const __UINT_FAST16_FMTu__ = "hu";
pub const __UINT_FAST16_FMTx__ = "hx";
pub const __UINT_FAST16_FMTX__ = "hX";
pub const __INT_FAST32_TYPE__ = c_int;
pub const __INT_FAST32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __INT_FAST32_WIDTH__ = @as(c_int, 32);
pub const __INT_FAST32_FMTd__ = "d";
pub const __INT_FAST32_FMTi__ = "i";
pub const __UINT_FAST32_TYPE__ = c_uint;
pub const __UINT_FAST32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_uint, 4294967295, .decimal);
pub const __UINT_FAST32_FMTo__ = "o";
pub const __UINT_FAST32_FMTu__ = "u";
pub const __UINT_FAST32_FMTx__ = "x";
pub const __UINT_FAST32_FMTX__ = "X";
pub const __INT_FAST64_TYPE__ = c_longlong;
pub const __INT_FAST64_MAX__ = @as(c_longlong, 9223372036854775807);
pub const __INT_FAST64_WIDTH__ = @as(c_int, 64);
pub const __INT_FAST64_FMTd__ = "lld";
pub const __INT_FAST64_FMTi__ = "lli";
pub const __UINT_FAST64_TYPE__ = c_ulonglong;
pub const __UINT_FAST64_MAX__ = @as(c_ulonglong, 18446744073709551615);
pub const __UINT_FAST64_FMTo__ = "llo";
pub const __UINT_FAST64_FMTu__ = "llu";
pub const __UINT_FAST64_FMTx__ = "llx";
pub const __UINT_FAST64_FMTX__ = "llX";
pub const __NO_MATH_ERRNO__ = @as(c_int, 1);
pub const __FINITE_MATH_ONLY__ = @as(c_int, 0);
pub const __GNUC_STDC_INLINE__ = @as(c_int, 1);
pub const __GCC_ATOMIC_TEST_AND_SET_TRUEVAL = @as(c_int, 1);
pub const __CLANG_ATOMIC_BOOL_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_CHAR_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_CHAR16_T_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_CHAR32_T_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_WCHAR_T_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_SHORT_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_INT_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_LONG_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_LLONG_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_POINTER_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_BOOL_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_CHAR_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_CHAR16_T_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_CHAR32_T_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_WCHAR_T_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_SHORT_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_INT_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_LONG_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_LLONG_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_POINTER_LOCK_FREE = @as(c_int, 2);
pub const __NO_INLINE__ = @as(c_int, 1);
pub const __PIC__ = @as(c_int, 2);
pub const __pic__ = @as(c_int, 2);
pub const __FLT_RADIX__ = @as(c_int, 2);
pub const __DECIMAL_DIG__ = __LDBL_DECIMAL_DIG__;
pub const __SSP_STRONG__ = @as(c_int, 2);
pub const __AARCH64EL__ = @as(c_int, 1);
pub const __aarch64__ = @as(c_int, 1);
pub const __AARCH64_CMODEL_SMALL__ = @as(c_int, 1);
pub const __ARM_ACLE = @as(c_int, 200);
pub const __ARM_ARCH = @as(c_int, 8);
pub const __ARM_ARCH_PROFILE = 'A';
pub const __ARM_64BIT_STATE = @as(c_int, 1);
pub const __ARM_PCS_AAPCS64 = @as(c_int, 1);
pub const __ARM_ARCH_ISA_A64 = @as(c_int, 1);
pub const __ARM_FEATURE_CLZ = @as(c_int, 1);
pub const __ARM_FEATURE_FMA = @as(c_int, 1);
pub const __ARM_FEATURE_LDREX = @as(c_int, 0xF);
pub const __ARM_FEATURE_IDIV = @as(c_int, 1);
pub const __ARM_FEATURE_DIV = @as(c_int, 1);
pub const __ARM_FEATURE_NUMERIC_MAXMIN = @as(c_int, 1);
pub const __ARM_FEATURE_DIRECTED_ROUNDING = @as(c_int, 1);
pub const __ARM_ALIGN_MAX_STACK_PWR = @as(c_int, 4);
pub const __ARM_FP = @as(c_int, 0xE);
pub const __ARM_FP16_FORMAT_IEEE = @as(c_int, 1);
pub const __ARM_FP16_ARGS = @as(c_int, 1);
pub const __ARM_SIZEOF_WCHAR_T = @as(c_int, 4);
pub const __ARM_SIZEOF_MINIMAL_ENUM = @as(c_int, 4);
pub const __ARM_NEON = @as(c_int, 1);
pub const __ARM_NEON_FP = @as(c_int, 0xE);
pub const __ARM_FEATURE_UNALIGNED = @as(c_int, 1);
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_1 = @as(c_int, 1);
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_2 = @as(c_int, 1);
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_4 = @as(c_int, 1);
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_8 = @as(c_int, 1);
pub const __FP_FAST_FMA = @as(c_int, 1);
pub const __FP_FAST_FMAF = @as(c_int, 1);
pub const __AARCH64_SIMD__ = @as(c_int, 1);
pub const __ARM64_ARCH_8__ = @as(c_int, 1);
pub const __ARM_NEON__ = @as(c_int, 1);
pub const __REGISTER_PREFIX__ = "";
pub const __arm64 = @as(c_int, 1);
pub const __arm64__ = @as(c_int, 1);
pub const __APPLE_CC__ = @as(c_int, 6000);
pub const __APPLE__ = @as(c_int, 1);
pub const __STDC_NO_THREADS__ = @as(c_int, 1);
pub const __strong = "";
pub const __unsafe_unretained = "";
pub const __DYNAMIC__ = @as(c_int, 1);
pub const __ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 130401, .decimal);
pub const __MACH__ = @as(c_int, 1);
pub const __STDC__ = @as(c_int, 1);
pub const __STDC_HOSTED__ = @as(c_int, 1);
pub const __STDC_VERSION__ = @as(c_long, 201710);
pub const __STDC_UTF_16__ = @as(c_int, 1);
pub const __STDC_UTF_32__ = @as(c_int, 1);
pub const _DEBUG = @as(c_int, 1);
pub const CIMGUI_DEFINE_ENUMS_AND_STRUCTS = @as(c_int, 1);
pub const __GCC_HAVE_DWARF2_CFI_ASM = @as(c_int, 1);
pub const CIMGUI_INCLUDED = "";
pub const _STDIO_H_ = "";
pub const __STDIO_H_ = "";
pub const _CDEFS_H_ = "";
pub const __BEGIN_DECLS = "";
pub const __END_DECLS = "";
pub inline fn __P(protos: anytype) @TypeOf(protos) {
    return protos;
}
pub const __signed = c_int;
pub inline fn __deprecated_enum_msg(_msg: anytype) @TypeOf(__deprecated_msg(_msg)) {
    return __deprecated_msg(_msg);
}
pub const __kpi_unavailable = "";
pub const __kpi_deprecated_arm64_macos_unavailable = "";
pub const __dead = "";
pub const __pure = "";
pub const __abortlike = __dead2 ++ __cold ++ __not_tail_called;
pub const __DARWIN_ONLY_64_BIT_INO_T = @as(c_int, 1);
pub const __DARWIN_ONLY_UNIX_CONFORMANCE = @as(c_int, 1);
pub const __DARWIN_ONLY_VERS_1050 = @as(c_int, 1);
pub const __DARWIN_UNIX03 = @as(c_int, 1);
pub const __DARWIN_64_BIT_INO_T = @as(c_int, 1);
pub const __DARWIN_VERS_1050 = @as(c_int, 1);
pub const __DARWIN_NON_CANCELABLE = @as(c_int, 0);
pub const __DARWIN_SUF_UNIX03 = "";
pub const __DARWIN_SUF_64_BIT_INO_T = "";
pub const __DARWIN_SUF_1050 = "";
pub const __DARWIN_SUF_NON_CANCELABLE = "";
pub const __DARWIN_SUF_EXTSN = "$DARWIN_EXTSN";
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_0(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_1(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_2(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_3(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_4(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_5(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_6(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_7(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_8(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_9(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_10(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_10_2(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_10_3(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_11(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_11_2(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_11_3(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_11_4(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_12(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_12_1(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_12_2(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_12_4(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_13(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_13_1(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_13_2(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_13_4(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_14(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_14_1(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_14_4(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_14_5(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_14_6(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_15(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_15_1(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_15_4(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_16(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_11_0(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_11_1(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_11_3(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_12_0(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_12_1(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_12_2(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_12_3(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_13_0(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_13_1(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_13_2(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_13_3(x: anytype) @TypeOf(x) {
    return x;
}
pub const ___POSIX_C_DEPRECATED_STARTING_198808L = "";
pub const ___POSIX_C_DEPRECATED_STARTING_199009L = "";
pub const ___POSIX_C_DEPRECATED_STARTING_199209L = "";
pub const ___POSIX_C_DEPRECATED_STARTING_199309L = "";
pub const ___POSIX_C_DEPRECATED_STARTING_199506L = "";
pub const ___POSIX_C_DEPRECATED_STARTING_200112L = "";
pub const ___POSIX_C_DEPRECATED_STARTING_200809L = "";
pub const __DARWIN_C_ANSI = @as(c_long, 0o10000);
pub const __DARWIN_C_FULL = @as(c_long, 900000);
pub const __DARWIN_C_LEVEL = __DARWIN_C_FULL;
pub const __STDC_WANT_LIB_EXT1__ = @as(c_int, 1);
pub const __DARWIN_NO_LONG_LONG = @as(c_int, 0);
pub const _DARWIN_FEATURE_64_BIT_INODE = @as(c_int, 1);
pub const _DARWIN_FEATURE_ONLY_64_BIT_INODE = @as(c_int, 1);
pub const _DARWIN_FEATURE_ONLY_VERS_1050 = @as(c_int, 1);
pub const _DARWIN_FEATURE_ONLY_UNIX_CONFORMANCE = @as(c_int, 1);
pub const _DARWIN_FEATURE_UNIX_CONFORMANCE = @as(c_int, 3);
pub const __has_ptrcheck = @as(c_int, 0);
pub const __single = "";
pub const __unsafe_indexable = "";
pub const __null_terminated = "";
pub inline fn __unsafe_forge_bidi_indexable(T: anytype, P: anytype, S: anytype) @TypeOf(T(P)) {
    _ = @TypeOf(S);
    return T(P);
}
pub const __unsafe_forge_single = @import("std").zig.c_translation.Macros.CAST_OR_CALL;
pub inline fn __terminated_by_to_indexable(P: anytype) @TypeOf(P) {
    return P;
}
pub inline fn __unsafe_terminated_by_to_indexable(P: anytype) @TypeOf(P) {
    return P;
}
pub inline fn __null_terminated_to_indexable(P: anytype) @TypeOf(P) {
    return P;
}
pub inline fn __unsafe_null_terminated_to_indexable(P: anytype) @TypeOf(P) {
    return P;
}
pub const __array_decay_dicards_count_in_parameters = "";
pub const __unsafe_late_const = "";
pub const __ASSUME_PTR_ABI_SINGLE_BEGIN = __ptrcheck_abi_assume_single();
pub const __ASSUME_PTR_ABI_SINGLE_END = __ptrcheck_abi_assume_unsafe_indexable();
pub const __header_indexable = "";
pub const __header_bidi_indexable = "";
pub const __kernel_ptr_semantics = "";
pub const __kernel_data_semantics = "";
pub const __kernel_dual_semantics = "";
pub const __AVAILABILITY__ = "";
pub const __API_TO_BE_DEPRECATED = @import("std").zig.c_translation.promoteIntLiteral(c_int, 100000, .decimal);
pub const __API_TO_BE_DEPRECATED_MACOS = @import("std").zig.c_translation.promoteIntLiteral(c_int, 100000, .decimal);
pub const __API_TO_BE_DEPRECATED_IOS = @import("std").zig.c_translation.promoteIntLiteral(c_int, 100000, .decimal);
pub const __API_TO_BE_DEPRECATED_TVOS = @import("std").zig.c_translation.promoteIntLiteral(c_int, 100000, .decimal);
pub const __API_TO_BE_DEPRECATED_WATCHOS = @import("std").zig.c_translation.promoteIntLiteral(c_int, 100000, .decimal);
pub const __API_TO_BE_DEPRECATED_MACCATALYST = @import("std").zig.c_translation.promoteIntLiteral(c_int, 100000, .decimal);
pub const __API_TO_BE_DEPRECATED_DRIVERKIT = @import("std").zig.c_translation.promoteIntLiteral(c_int, 100000, .decimal);
pub const __AVAILABILITY_VERSIONS__ = "";
pub const __MAC_10_0 = @as(c_int, 1000);
pub const __MAC_10_1 = @as(c_int, 1010);
pub const __MAC_10_2 = @as(c_int, 1020);
pub const __MAC_10_3 = @as(c_int, 1030);
pub const __MAC_10_4 = @as(c_int, 1040);
pub const __MAC_10_5 = @as(c_int, 1050);
pub const __MAC_10_6 = @as(c_int, 1060);
pub const __MAC_10_7 = @as(c_int, 1070);
pub const __MAC_10_8 = @as(c_int, 1080);
pub const __MAC_10_9 = @as(c_int, 1090);
pub const __MAC_10_10 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 101000, .decimal);
pub const __MAC_10_10_2 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 101002, .decimal);
pub const __MAC_10_10_3 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 101003, .decimal);
pub const __MAC_10_11 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 101100, .decimal);
pub const __MAC_10_11_2 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 101102, .decimal);
pub const __MAC_10_11_3 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 101103, .decimal);
pub const __MAC_10_11_4 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 101104, .decimal);
pub const __MAC_10_12 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 101200, .decimal);
pub const __MAC_10_12_1 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 101201, .decimal);
pub const __MAC_10_12_2 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 101202, .decimal);
pub const __MAC_10_12_4 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 101204, .decimal);
pub const __MAC_10_13 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 101300, .decimal);
pub const __MAC_10_13_1 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 101301, .decimal);
pub const __MAC_10_13_2 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 101302, .decimal);
pub const __MAC_10_13_4 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 101304, .decimal);
pub const __MAC_10_14 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 101400, .decimal);
pub const __MAC_10_14_1 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 101401, .decimal);
pub const __MAC_10_14_4 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 101404, .decimal);
pub const __MAC_10_14_6 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 101406, .decimal);
pub const __MAC_10_15 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 101500, .decimal);
pub const __MAC_10_15_1 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 101501, .decimal);
pub const __MAC_10_15_4 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 101504, .decimal);
pub const __MAC_10_16 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 101600, .decimal);
pub const __MAC_11_0 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 110000, .decimal);
pub const __MAC_11_1 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 110100, .decimal);
pub const __MAC_11_3 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 110300, .decimal);
pub const __MAC_11_4 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 110400, .decimal);
pub const __MAC_11_5 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 110500, .decimal);
pub const __MAC_11_6 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 110600, .decimal);
pub const __MAC_12_0 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 120000, .decimal);
pub const __MAC_12_1 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 120100, .decimal);
pub const __MAC_12_2 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 120200, .decimal);
pub const __MAC_12_3 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 120300, .decimal);
pub const __MAC_13_0 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 130000, .decimal);
pub const __MAC_13_1 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 130100, .decimal);
pub const __MAC_13_2 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 130200, .decimal);
pub const __MAC_13_3 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 130300, .decimal);
pub const __IPHONE_2_0 = @as(c_int, 20000);
pub const __IPHONE_2_1 = @as(c_int, 20100);
pub const __IPHONE_2_2 = @as(c_int, 20200);
pub const __IPHONE_3_0 = @as(c_int, 30000);
pub const __IPHONE_3_1 = @as(c_int, 30100);
pub const __IPHONE_3_2 = @as(c_int, 30200);
pub const __IPHONE_4_0 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 40000, .decimal);
pub const __IPHONE_4_1 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 40100, .decimal);
pub const __IPHONE_4_2 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 40200, .decimal);
pub const __IPHONE_4_3 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 40300, .decimal);
pub const __IPHONE_5_0 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 50000, .decimal);
pub const __IPHONE_5_1 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 50100, .decimal);
pub const __IPHONE_6_0 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 60000, .decimal);
pub const __IPHONE_6_1 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 60100, .decimal);
pub const __IPHONE_7_0 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 70000, .decimal);
pub const __IPHONE_7_1 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 70100, .decimal);
pub const __IPHONE_8_0 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 80000, .decimal);
pub const __IPHONE_8_1 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 80100, .decimal);
pub const __IPHONE_8_2 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 80200, .decimal);
pub const __IPHONE_8_3 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 80300, .decimal);
pub const __IPHONE_8_4 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 80400, .decimal);
pub const __IPHONE_9_0 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 90000, .decimal);
pub const __IPHONE_9_1 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 90100, .decimal);
pub const __IPHONE_9_2 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 90200, .decimal);
pub const __IPHONE_9_3 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 90300, .decimal);
pub const __IPHONE_10_0 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 100000, .decimal);
pub const __IPHONE_10_1 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 100100, .decimal);
pub const __IPHONE_10_2 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 100200, .decimal);
pub const __IPHONE_10_3 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 100300, .decimal);
pub const __IPHONE_11_0 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 110000, .decimal);
pub const __IPHONE_11_1 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 110100, .decimal);
pub const __IPHONE_11_2 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 110200, .decimal);
pub const __IPHONE_11_3 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 110300, .decimal);
pub const __IPHONE_11_4 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 110400, .decimal);
pub const __IPHONE_12_0 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 120000, .decimal);
pub const __IPHONE_12_1 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 120100, .decimal);
pub const __IPHONE_12_2 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 120200, .decimal);
pub const __IPHONE_12_3 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 120300, .decimal);
pub const __IPHONE_12_4 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 120400, .decimal);
pub const __IPHONE_13_0 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 130000, .decimal);
pub const __IPHONE_13_1 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 130100, .decimal);
pub const __IPHONE_13_2 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 130200, .decimal);
pub const __IPHONE_13_3 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 130300, .decimal);
pub const __IPHONE_13_4 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 130400, .decimal);
pub const __IPHONE_13_5 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 130500, .decimal);
pub const __IPHONE_13_6 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 130600, .decimal);
pub const __IPHONE_13_7 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 130700, .decimal);
pub const __IPHONE_14_0 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 140000, .decimal);
pub const __IPHONE_14_1 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 140100, .decimal);
pub const __IPHONE_14_2 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 140200, .decimal);
pub const __IPHONE_14_3 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 140300, .decimal);
pub const __IPHONE_14_5 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 140500, .decimal);
pub const __IPHONE_14_6 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 140600, .decimal);
pub const __IPHONE_14_7 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 140700, .decimal);
pub const __IPHONE_14_8 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 140800, .decimal);
pub const __IPHONE_15_0 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 150000, .decimal);
pub const __IPHONE_15_1 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 150100, .decimal);
pub const __IPHONE_15_2 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 150200, .decimal);
pub const __IPHONE_15_3 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 150300, .decimal);
pub const __IPHONE_15_4 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 150400, .decimal);
pub const __IPHONE_16_0 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 160000, .decimal);
pub const __IPHONE_16_1 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 160100, .decimal);
pub const __IPHONE_16_2 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 160200, .decimal);
pub const __IPHONE_16_3 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 160300, .decimal);
pub const __IPHONE_16_4 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 160400, .decimal);
pub const __TVOS_9_0 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 90000, .decimal);
pub const __TVOS_9_1 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 90100, .decimal);
pub const __TVOS_9_2 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 90200, .decimal);
pub const __TVOS_10_0 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 100000, .decimal);
pub const __TVOS_10_0_1 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 100001, .decimal);
pub const __TVOS_10_1 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 100100, .decimal);
pub const __TVOS_10_2 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 100200, .decimal);
pub const __TVOS_11_0 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 110000, .decimal);
pub const __TVOS_11_1 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 110100, .decimal);
pub const __TVOS_11_2 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 110200, .decimal);
pub const __TVOS_11_3 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 110300, .decimal);
pub const __TVOS_11_4 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 110400, .decimal);
pub const __TVOS_12_0 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 120000, .decimal);
pub const __TVOS_12_1 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 120100, .decimal);
pub const __TVOS_12_2 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 120200, .decimal);
pub const __TVOS_12_3 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 120300, .decimal);
pub const __TVOS_12_4 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 120400, .decimal);
pub const __TVOS_13_0 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 130000, .decimal);
pub const __TVOS_13_2 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 130200, .decimal);
pub const __TVOS_13_3 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 130300, .decimal);
pub const __TVOS_13_4 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 130400, .decimal);
pub const __TVOS_14_0 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 140000, .decimal);
pub const __TVOS_14_1 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 140100, .decimal);
pub const __TVOS_14_2 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 140200, .decimal);
pub const __TVOS_14_3 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 140300, .decimal);
pub const __TVOS_14_5 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 140500, .decimal);
pub const __TVOS_14_6 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 140600, .decimal);
pub const __TVOS_14_7 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 140700, .decimal);
pub const __TVOS_15_0 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 150000, .decimal);
pub const __TVOS_15_1 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 150100, .decimal);
pub const __TVOS_15_2 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 150200, .decimal);
pub const __TVOS_15_3 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 150300, .decimal);
pub const __TVOS_15_4 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 150400, .decimal);
pub const __TVOS_16_0 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 160000, .decimal);
pub const __TVOS_16_1 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 160100, .decimal);
pub const __TVOS_16_2 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 160200, .decimal);
pub const __TVOS_16_3 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 160300, .decimal);
pub const __TVOS_16_4 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 160400, .decimal);
pub const __WATCHOS_1_0 = @as(c_int, 10000);
pub const __WATCHOS_2_0 = @as(c_int, 20000);
pub const __WATCHOS_2_1 = @as(c_int, 20100);
pub const __WATCHOS_2_2 = @as(c_int, 20200);
pub const __WATCHOS_3_0 = @as(c_int, 30000);
pub const __WATCHOS_3_1 = @as(c_int, 30100);
pub const __WATCHOS_3_1_1 = @as(c_int, 30101);
pub const __WATCHOS_3_2 = @as(c_int, 30200);
pub const __WATCHOS_4_0 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 40000, .decimal);
pub const __WATCHOS_4_1 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 40100, .decimal);
pub const __WATCHOS_4_2 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 40200, .decimal);
pub const __WATCHOS_4_3 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 40300, .decimal);
pub const __WATCHOS_5_0 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 50000, .decimal);
pub const __WATCHOS_5_1 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 50100, .decimal);
pub const __WATCHOS_5_2 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 50200, .decimal);
pub const __WATCHOS_5_3 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 50300, .decimal);
pub const __WATCHOS_6_0 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 60000, .decimal);
pub const __WATCHOS_6_1 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 60100, .decimal);
pub const __WATCHOS_6_2 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 60200, .decimal);
pub const __WATCHOS_7_0 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 70000, .decimal);
pub const __WATCHOS_7_1 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 70100, .decimal);
pub const __WATCHOS_7_2 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 70200, .decimal);
pub const __WATCHOS_7_3 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 70300, .decimal);
pub const __WATCHOS_7_4 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 70400, .decimal);
pub const __WATCHOS_7_5 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 70500, .decimal);
pub const __WATCHOS_7_6 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 70600, .decimal);
pub const __WATCHOS_8_0 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 80000, .decimal);
pub const __WATCHOS_8_1 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 80100, .decimal);
pub const __WATCHOS_8_3 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 80300, .decimal);
pub const __WATCHOS_8_4 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 80400, .decimal);
pub const __WATCHOS_8_5 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 80500, .decimal);
pub const __WATCHOS_9_0 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 90000, .decimal);
pub const __WATCHOS_9_1 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 90100, .decimal);
pub const __WATCHOS_9_2 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 90200, .decimal);
pub const __WATCHOS_9_3 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 90300, .decimal);
pub const __WATCHOS_9_4 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 90400, .decimal);
pub const MAC_OS_X_VERSION_10_0 = @as(c_int, 1000);
pub const MAC_OS_X_VERSION_10_1 = @as(c_int, 1010);
pub const MAC_OS_X_VERSION_10_2 = @as(c_int, 1020);
pub const MAC_OS_X_VERSION_10_3 = @as(c_int, 1030);
pub const MAC_OS_X_VERSION_10_4 = @as(c_int, 1040);
pub const MAC_OS_X_VERSION_10_5 = @as(c_int, 1050);
pub const MAC_OS_X_VERSION_10_6 = @as(c_int, 1060);
pub const MAC_OS_X_VERSION_10_7 = @as(c_int, 1070);
pub const MAC_OS_X_VERSION_10_8 = @as(c_int, 1080);
pub const MAC_OS_X_VERSION_10_9 = @as(c_int, 1090);
pub const MAC_OS_X_VERSION_10_10 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 101000, .decimal);
pub const MAC_OS_X_VERSION_10_10_2 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 101002, .decimal);
pub const MAC_OS_X_VERSION_10_10_3 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 101003, .decimal);
pub const MAC_OS_X_VERSION_10_11 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 101100, .decimal);
pub const MAC_OS_X_VERSION_10_11_2 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 101102, .decimal);
pub const MAC_OS_X_VERSION_10_11_3 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 101103, .decimal);
pub const MAC_OS_X_VERSION_10_11_4 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 101104, .decimal);
pub const MAC_OS_X_VERSION_10_12 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 101200, .decimal);
pub const MAC_OS_X_VERSION_10_12_1 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 101201, .decimal);
pub const MAC_OS_X_VERSION_10_12_2 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 101202, .decimal);
pub const MAC_OS_X_VERSION_10_12_4 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 101204, .decimal);
pub const MAC_OS_X_VERSION_10_13 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 101300, .decimal);
pub const MAC_OS_X_VERSION_10_13_1 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 101301, .decimal);
pub const MAC_OS_X_VERSION_10_13_2 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 101302, .decimal);
pub const MAC_OS_X_VERSION_10_13_4 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 101304, .decimal);
pub const MAC_OS_X_VERSION_10_14 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 101400, .decimal);
pub const MAC_OS_X_VERSION_10_14_1 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 101401, .decimal);
pub const MAC_OS_X_VERSION_10_14_4 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 101404, .decimal);
pub const MAC_OS_X_VERSION_10_14_6 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 101406, .decimal);
pub const MAC_OS_X_VERSION_10_15 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 101500, .decimal);
pub const MAC_OS_X_VERSION_10_15_1 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 101501, .decimal);
pub const MAC_OS_X_VERSION_10_16 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 101600, .decimal);
pub const MAC_OS_VERSION_11_0 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 110000, .decimal);
pub const MAC_OS_VERSION_12_0 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 120000, .decimal);
pub const MAC_OS_VERSION_13_0 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 130000, .decimal);
pub const __DRIVERKIT_19_0 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 190000, .decimal);
pub const __DRIVERKIT_20_0 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 200000, .decimal);
pub const __DRIVERKIT_21_0 = @import("std").zig.c_translation.promoteIntLiteral(c_int, 210000, .decimal);
pub const __AVAILABILITY_INTERNAL__ = "";
pub const __MAC_OS_X_VERSION_MIN_REQUIRED = __ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__;
pub const __MAC_OS_X_VERSION_MAX_ALLOWED = __MAC_13_3;
pub const __AVAILABILITY_INTERNAL_REGULAR = "";
pub const __ENABLE_LEGACY_MAC_AVAILABILITY = @as(c_int, 1);
pub inline fn __API_AVAILABLE1(x: anytype) @TypeOf(__API_A(x)) {
    return __API_A(x);
}
pub inline fn __API_RANGE_STRINGIFY(x: anytype) @TypeOf(__API_RANGE_STRINGIFY2(x)) {
    return __API_RANGE_STRINGIFY2(x);
}
pub inline fn __API_AVAILABLE_BEGIN1(a: anytype) @TypeOf(__API_A_BEGIN(a)) {
    return __API_A_BEGIN(a);
}
pub inline fn __API_DEPRECATED_MSG2(msg: anytype, x: anytype) @TypeOf(__API_D(msg, x)) {
    return __API_D(msg, x);
}
pub inline fn __API_DEPRECATED_BEGIN_MSG2(msg: anytype, a: anytype) @TypeOf(__API_D_BEGIN(msg, a)) {
    return __API_D_BEGIN(msg, a);
}
pub inline fn __API_DEPRECATED_REP2(rep: anytype, x: anytype) @TypeOf(__API_R(rep, x)) {
    return __API_R(rep, x);
}
pub inline fn __API_DEPRECATED_BEGIN_REP2(rep: anytype, a: anytype) @TypeOf(__API_R_BEGIN(rep, a)) {
    return __API_R_BEGIN(rep, a);
}
pub inline fn __API_UNAVAILABLE1(x: anytype) @TypeOf(__API_U(x)) {
    return __API_U(x);
}
pub inline fn __API_UNAVAILABLE_BEGIN1(a: anytype) @TypeOf(__API_U_BEGIN(a)) {
    return __API_U_BEGIN(a);
}
pub const __TYPES_H_ = "";
pub const _SYS__TYPES_H_ = "";
pub const _BSD_MACHINE__TYPES_H_ = "";
pub const _BSD_ARM__TYPES_H_ = "";
pub const __DARWIN_NULL = @import("std").zig.c_translation.cast(?*anyopaque, @as(c_int, 0));
pub const _SYS__PTHREAD_TYPES_H_ = "";
pub const __PTHREAD_SIZE__ = @as(c_int, 8176);
pub const __PTHREAD_ATTR_SIZE__ = @as(c_int, 56);
pub const __PTHREAD_MUTEXATTR_SIZE__ = @as(c_int, 8);
pub const __PTHREAD_MUTEX_SIZE__ = @as(c_int, 56);
pub const __PTHREAD_CONDATTR_SIZE__ = @as(c_int, 8);
pub const __PTHREAD_COND_SIZE__ = @as(c_int, 40);
pub const __PTHREAD_ONCE_SIZE__ = @as(c_int, 8);
pub const __PTHREAD_RWLOCK_SIZE__ = @as(c_int, 192);
pub const __PTHREAD_RWLOCKATTR_SIZE__ = @as(c_int, 16);
pub const __DARWIN_WCHAR_MAX = __WCHAR_MAX__;
pub const __DARWIN_WCHAR_MIN = -@import("std").zig.c_translation.promoteIntLiteral(c_int, 0x7fffffff, .hexadecimal) - @as(c_int, 1);
pub const __DARWIN_WEOF = @import("std").zig.c_translation.cast(__darwin_wint_t, -@as(c_int, 1));
pub const _FORTIFY_SOURCE = @as(c_int, 2);
pub const _VA_LIST_T = "";
pub const _BSD_MACHINE_TYPES_H_ = "";
pub const _ARM_MACHTYPES_H_ = "";
pub const _MACHTYPES_H_ = "";
pub const _INT8_T = "";
pub const _INT16_T = "";
pub const _INT32_T = "";
pub const _INT64_T = "";
pub const _U_INT8_T = "";
pub const _U_INT16_T = "";
pub const _U_INT32_T = "";
pub const _U_INT64_T = "";
pub const _INTPTR_T = "";
pub const _UINTPTR_T = "";
pub const USER_ADDR_NULL = @import("std").zig.c_translation.cast(user_addr_t, @as(c_int, 0));
pub inline fn CAST_USER_ADDR_T(a_ptr: anytype) user_addr_t {
    return @import("std").zig.c_translation.cast(user_addr_t, @import("std").zig.c_translation.cast(usize, a_ptr));
}
pub const _SIZE_T = "";
pub const NULL = __DARWIN_NULL;
pub const _SYS_STDIO_H_ = "";
pub const RENAME_SECLUDE = @as(c_int, 0x00000001);
pub const RENAME_SWAP = @as(c_int, 0x00000002);
pub const RENAME_EXCL = @as(c_int, 0x00000004);
pub const RENAME_RESERVED1 = @as(c_int, 0x00000008);
pub const RENAME_NOFOLLOW_ANY = @as(c_int, 0x00000010);
pub const _FSTDIO = "";
pub const __SLBF = @as(c_int, 0x0001);
pub const __SNBF = @as(c_int, 0x0002);
pub const __SRD = @as(c_int, 0x0004);
pub const __SWR = @as(c_int, 0x0008);
pub const __SRW = @as(c_int, 0x0010);
pub const __SEOF = @as(c_int, 0x0020);
pub const __SERR = @as(c_int, 0x0040);
pub const __SMBF = @as(c_int, 0x0080);
pub const __SAPP = @as(c_int, 0x0100);
pub const __SSTR = @as(c_int, 0x0200);
pub const __SOPT = @as(c_int, 0x0400);
pub const __SNPT = @as(c_int, 0x0800);
pub const __SOFF = @as(c_int, 0x1000);
pub const __SMOD = @as(c_int, 0x2000);
pub const __SALC = @as(c_int, 0x4000);
pub const __SIGN = @import("std").zig.c_translation.promoteIntLiteral(c_int, 0x8000, .hexadecimal);
pub const _IOFBF = @as(c_int, 0);
pub const _IOLBF = @as(c_int, 1);
pub const _IONBF = @as(c_int, 2);
pub const BUFSIZ = @as(c_int, 1024);
pub const EOF = -@as(c_int, 1);
pub const FOPEN_MAX = @as(c_int, 20);
pub const FILENAME_MAX = @as(c_int, 1024);
pub const P_tmpdir = "/var/tmp/";
pub const L_tmpnam = @as(c_int, 1024);
pub const TMP_MAX = @import("std").zig.c_translation.promoteIntLiteral(c_int, 308915776, .decimal);
pub const SEEK_SET = @as(c_int, 0);
pub const SEEK_CUR = @as(c_int, 1);
pub const SEEK_END = @as(c_int, 2);
pub const stdin = __stdinp;
pub const stdout = __stdoutp;
pub const stderr = __stderrp;
pub const L_ctermid = @as(c_int, 1024);
pub const _CTERMID_H_ = "";
pub inline fn __sfeof(p: anytype) @TypeOf((p.*._flags & __SEOF) != @as(c_int, 0)) {
    return (p.*._flags & __SEOF) != @as(c_int, 0);
}
pub inline fn __sferror(p: anytype) @TypeOf((p.*._flags & __SERR) != @as(c_int, 0)) {
    return (p.*._flags & __SERR) != @as(c_int, 0);
}
pub inline fn __sfileno(p: anytype) @TypeOf(p.*._file) {
    return p.*._file;
}
pub const _OFF_T = "";
pub const _SSIZE_T = "";
pub inline fn fropen(cookie: anytype, @"fn": anytype) @TypeOf(funopen(cookie, @"fn", @as(c_int, 0), @as(c_int, 0), @as(c_int, 0))) {
    return funopen(cookie, @"fn", @as(c_int, 0), @as(c_int, 0), @as(c_int, 0));
}
pub inline fn fwopen(cookie: anytype, @"fn": anytype) @TypeOf(funopen(cookie, @as(c_int, 0), @"fn", @as(c_int, 0), @as(c_int, 0))) {
    return funopen(cookie, @as(c_int, 0), @"fn", @as(c_int, 0), @as(c_int, 0));
}
pub inline fn feof_unlocked(p: anytype) @TypeOf(__sfeof(p)) {
    return __sfeof(p);
}
pub inline fn ferror_unlocked(p: anytype) @TypeOf(__sferror(p)) {
    return __sferror(p);
}
pub inline fn clearerr_unlocked(p: anytype) @TypeOf(__sclearerr(p)) {
    return __sclearerr(p);
}
pub inline fn fileno_unlocked(p: anytype) @TypeOf(__sfileno(p)) {
    return __sfileno(p);
}
pub const _SECURE__STDIO_H_ = "";
pub const _SECURE__COMMON_H_ = "";
pub const _USE_FORTIFY_LEVEL = @as(c_int, 2);
pub inline fn __darwin_obsz0(object: anytype) @TypeOf(__builtin_object_size(object, @as(c_int, 0))) {
    return __builtin_object_size(object, @as(c_int, 0));
}
pub inline fn __darwin_obsz(object: anytype) @TypeOf(__builtin_object_size(object, if (_USE_FORTIFY_LEVEL > @as(c_int, 1)) @as(c_int, 1) else @as(c_int, 0))) {
    return __builtin_object_size(object, if (_USE_FORTIFY_LEVEL > @as(c_int, 1)) @as(c_int, 1) else @as(c_int, 0));
}
pub const __CLANG_STDINT_H = "";
pub const _STDINT_H_ = "";
pub const __WORDSIZE = @as(c_int, 64);
pub const _UINT8_T = "";
pub const _UINT16_T = "";
pub const _UINT32_T = "";
pub const _UINT64_T = "";
pub const _INTMAX_T = "";
pub const _UINTMAX_T = "";
pub inline fn INT8_C(v: anytype) @TypeOf(v) {
    return v;
}
pub inline fn INT16_C(v: anytype) @TypeOf(v) {
    return v;
}
pub inline fn INT32_C(v: anytype) @TypeOf(v) {
    return v;
}
pub const INT64_C = @import("std").zig.c_translation.Macros.LL_SUFFIX;
pub inline fn UINT8_C(v: anytype) @TypeOf(v) {
    return v;
}
pub inline fn UINT16_C(v: anytype) @TypeOf(v) {
    return v;
}
pub const UINT32_C = @import("std").zig.c_translation.Macros.U_SUFFIX;
pub const UINT64_C = @import("std").zig.c_translation.Macros.ULL_SUFFIX;
pub const INTMAX_C = @import("std").zig.c_translation.Macros.L_SUFFIX;
pub const UINTMAX_C = @import("std").zig.c_translation.Macros.UL_SUFFIX;
pub const INT8_MAX = @as(c_int, 127);
pub const INT16_MAX = @as(c_int, 32767);
pub const INT32_MAX = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const INT64_MAX = @as(c_longlong, 9223372036854775807);
pub const INT8_MIN = -@as(c_int, 128);
pub const INT16_MIN = -@import("std").zig.c_translation.promoteIntLiteral(c_int, 32768, .decimal);
pub const INT32_MIN = -INT32_MAX - @as(c_int, 1);
pub const INT64_MIN = -INT64_MAX - @as(c_int, 1);
pub const UINT8_MAX = @as(c_int, 255);
pub const UINT16_MAX = @import("std").zig.c_translation.promoteIntLiteral(c_int, 65535, .decimal);
pub const UINT32_MAX = @import("std").zig.c_translation.promoteIntLiteral(c_uint, 4294967295, .decimal);
pub const UINT64_MAX = @as(c_ulonglong, 18446744073709551615);
pub const INT_LEAST8_MIN = INT8_MIN;
pub const INT_LEAST16_MIN = INT16_MIN;
pub const INT_LEAST32_MIN = INT32_MIN;
pub const INT_LEAST64_MIN = INT64_MIN;
pub const INT_LEAST8_MAX = INT8_MAX;
pub const INT_LEAST16_MAX = INT16_MAX;
pub const INT_LEAST32_MAX = INT32_MAX;
pub const INT_LEAST64_MAX = INT64_MAX;
pub const UINT_LEAST8_MAX = UINT8_MAX;
pub const UINT_LEAST16_MAX = UINT16_MAX;
pub const UINT_LEAST32_MAX = UINT32_MAX;
pub const UINT_LEAST64_MAX = UINT64_MAX;
pub const INT_FAST8_MIN = INT8_MIN;
pub const INT_FAST16_MIN = INT16_MIN;
pub const INT_FAST32_MIN = INT32_MIN;
pub const INT_FAST64_MIN = INT64_MIN;
pub const INT_FAST8_MAX = INT8_MAX;
pub const INT_FAST16_MAX = INT16_MAX;
pub const INT_FAST32_MAX = INT32_MAX;
pub const INT_FAST64_MAX = INT64_MAX;
pub const UINT_FAST8_MAX = UINT8_MAX;
pub const UINT_FAST16_MAX = UINT16_MAX;
pub const UINT_FAST32_MAX = UINT32_MAX;
pub const UINT_FAST64_MAX = UINT64_MAX;
pub const INTPTR_MAX = @import("std").zig.c_translation.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const INTPTR_MIN = -INTPTR_MAX - @as(c_int, 1);
pub const UINTPTR_MAX = @import("std").zig.c_translation.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const INTMAX_MAX = INTMAX_C(@import("std").zig.c_translation.promoteIntLiteral(c_int, 9223372036854775807, .decimal));
pub const UINTMAX_MAX = UINTMAX_C(@import("std").zig.c_translation.promoteIntLiteral(c_int, 18446744073709551615, .decimal));
pub const INTMAX_MIN = -INTMAX_MAX - @as(c_int, 1);
pub const PTRDIFF_MIN = INTMAX_MIN;
pub const PTRDIFF_MAX = INTMAX_MAX;
pub const SIZE_MAX = UINTPTR_MAX;
pub const RSIZE_MAX = SIZE_MAX >> @as(c_int, 1);
pub const WCHAR_MAX = __WCHAR_MAX__;
pub const WCHAR_MIN = -WCHAR_MAX - @as(c_int, 1);
pub const WINT_MIN = INT32_MIN;
pub const WINT_MAX = INT32_MAX;
pub const SIG_ATOMIC_MIN = INT32_MIN;
pub const SIG_ATOMIC_MAX = INT32_MAX;
pub const __GNUC_VA_LIST = "";
pub const __STDARG_H = "";
pub const _VA_LIST = "";
pub const __STDBOOL_H = "";
pub const __bool_true_false_are_defined = @as(c_int, 1);
pub const @"bool" = bool;
pub const @"true" = @as(c_int, 1);
pub const @"false" = @as(c_int, 0);
pub const CIMGUI_API = EXTERN ++ API;
pub const IMGUI_HAS_DOCK = @as(c_int, 1);
pub const __darwin_pthread_handler_rec = struct___darwin_pthread_handler_rec;
pub const _opaque_pthread_attr_t = struct__opaque_pthread_attr_t;
pub const _opaque_pthread_cond_t = struct__opaque_pthread_cond_t;
pub const _opaque_pthread_condattr_t = struct__opaque_pthread_condattr_t;
pub const _opaque_pthread_mutex_t = struct__opaque_pthread_mutex_t;
pub const _opaque_pthread_mutexattr_t = struct__opaque_pthread_mutexattr_t;
pub const _opaque_pthread_once_t = struct__opaque_pthread_once_t;
pub const _opaque_pthread_rwlock_t = struct__opaque_pthread_rwlock_t;
pub const _opaque_pthread_rwlockattr_t = struct__opaque_pthread_rwlockattr_t;
pub const _opaque_pthread_t = struct__opaque_pthread_t;
pub const __sbuf = struct___sbuf;
pub const __sFILEX = struct___sFILEX;
pub const __sFILE = struct___sFILE;
