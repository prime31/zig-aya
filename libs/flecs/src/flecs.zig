pub const __builtin_va_list = [*c]u8;
pub const va_list = __builtin_va_list;

pub extern fn memchr(__s: ?*const anyopaque, __c: c_int, __n: c_ulong) ?*anyopaque;
pub extern fn memcmp(__s1: ?*const anyopaque, __s2: ?*const anyopaque, __n: c_ulong) c_int;
pub extern fn memcpy(__dst: ?*anyopaque, __src: ?*const anyopaque, __n: c_ulong) ?*anyopaque;
pub extern fn memmove(__dst: ?*anyopaque, __src: ?*const anyopaque, __len: c_ulong) ?*anyopaque;
pub extern fn memset(__b: ?*anyopaque, __c: c_int, __len: c_ulong) ?*anyopaque;
pub extern fn strcat(__s1: [*c]u8, __s2: [*c]const u8) [*c]u8;
pub extern fn strchr(__s: [*c]const u8, __c: c_int) [*c]u8;
pub extern fn strcmp(__s1: [*c]const u8, __s2: [*c]const u8) c_int;
pub extern fn strcoll(__s1: [*c]const u8, __s2: [*c]const u8) c_int;
pub extern fn strcpy(__dst: [*c]u8, __src: [*c]const u8) [*c]u8;
pub extern fn strcspn(__s: [*c]const u8, __charset: [*c]const u8) c_ulong;
pub extern fn strerror(__errnum: c_int) [*c]u8;
pub extern fn strlen(__s: [*c]const u8) c_ulong;
pub extern fn strncat(__s1: [*c]u8, __s2: [*c]const u8, __n: c_ulong) [*c]u8;
pub extern fn strncmp(__s1: [*c]const u8, __s2: [*c]const u8, __n: c_ulong) c_int;
pub extern fn strncpy(__dst: [*c]u8, __src: [*c]const u8, __n: c_ulong) [*c]u8;

pub extern fn memmem(__big: ?*const anyopaque, __big_len: usize, __little: ?*const anyopaque, __little_len: usize) ?*anyopaque;
pub extern fn memset_pattern4(__b: ?*anyopaque, __pattern4: ?*const anyopaque, __len: usize) void;
pub extern fn memset_pattern8(__b: ?*anyopaque, __pattern8: ?*const anyopaque, __len: usize) void;
pub extern fn memset_pattern16(__b: ?*anyopaque, __pattern16: ?*const anyopaque, __len: usize) void;
pub extern fn strcasestr(__big: [*c]const u8, __little: [*c]const u8) [*c]u8;
pub extern fn strnstr(__big: [*c]const u8, __little: [*c]const u8, __len: usize) [*c]u8;
pub extern fn strlcat(__dst: [*c]u8, __source: [*c]const u8, __size: c_ulong) c_ulong;
pub extern fn strlcpy(__dst: [*c]u8, __source: [*c]const u8, __size: c_ulong) c_ulong;
pub extern fn strmode(__mode: c_int, __bp: [*c]u8) void;
pub extern fn strsep(__stringp: [*c][*c]u8, __delim: [*c]const u8) [*c]u8;
pub extern fn swab(noalias ?*const anyopaque, noalias ?*anyopaque, isize) void;
pub extern fn timingsafe_bcmp(__b1: ?*const anyopaque, __b2: ?*const anyopaque, __len: usize) c_int;
pub extern fn strsignal_r(__sig: c_int, __strsignalbuf: [*c]u8, __buflen: usize) c_int;
pub extern fn bcmp(?*const anyopaque, ?*const anyopaque, c_ulong) c_int;
pub extern fn bcopy(?*const anyopaque, ?*anyopaque, usize) void;
pub extern fn bzero(?*anyopaque, c_ulong) void;
pub extern fn index([*c]const u8, c_int) [*c]u8;
pub extern fn rindex([*c]const u8, c_int) [*c]u8;
pub extern fn ffs(c_int) c_int;
pub extern fn strcasecmp([*c]const u8, [*c]const u8) c_int;
pub extern fn strncasecmp([*c]const u8, [*c]const u8, c_ulong) c_int;
pub extern fn ffsl(c_long) c_int;
pub extern fn ffsll(c_longlong) c_int;
pub extern fn fls(c_int) c_int;
pub extern fn flsl(c_long) c_int;
pub extern fn flsll(c_longlong) c_int;
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
pub const ecs_flags8_t = u8;
pub const ecs_flags16_t = u16;
pub const ecs_flags32_t = u32;
pub const ecs_flags64_t = u64;
pub const ecs_size_t = i32;
pub const struct_ecs_block_allocator_chunk_header_t = extern struct {
    next: [*c]struct_ecs_block_allocator_chunk_header_t,
};
pub const ecs_block_allocator_chunk_header_t = struct_ecs_block_allocator_chunk_header_t;
pub const struct_ecs_block_allocator_block_t = extern struct {
    memory: ?*anyopaque,
    next: [*c]struct_ecs_block_allocator_block_t,
};
pub const ecs_block_allocator_block_t = struct_ecs_block_allocator_block_t;
pub const struct_ecs_block_allocator_t = extern struct {
    head: [*c]ecs_block_allocator_chunk_header_t,
    block_head: [*c]ecs_block_allocator_block_t,
    block_tail: [*c]ecs_block_allocator_block_t,
    chunk_size: i32,
    data_size: i32,
    chunks_per_block: i32,
    block_size: i32,
    alloc_count: i32,
};
pub const ecs_block_allocator_t = struct_ecs_block_allocator_t;
pub const struct_ecs_vec_t = extern struct {
    array: ?*anyopaque,
    count: i32,
    size: i32,
    elem_size: ecs_size_t,
};
pub const ecs_vec_t = struct_ecs_vec_t;
pub const struct_ecs_sparse_t = extern struct {
    dense: ecs_vec_t,
    pages: ecs_vec_t,
    size: ecs_size_t,
    count: i32,
    max_id: u64,
    allocator: [*c]struct_ecs_allocator_t,
    page_allocator: [*c]struct_ecs_block_allocator_t,
};
pub const struct_ecs_allocator_t = extern struct {
    chunks: ecs_block_allocator_t,
    sizes: struct_ecs_sparse_t,
};
pub const ecs_allocator_t = struct_ecs_allocator_t;
pub extern fn ecs_vec_init(allocator: [*c]struct_ecs_allocator_t, vec: [*c]ecs_vec_t, size: ecs_size_t, elem_count: i32) [*c]ecs_vec_t;
pub extern fn ecs_vec_init_if(vec: [*c]ecs_vec_t, size: ecs_size_t) void;
pub extern fn ecs_vec_fini(allocator: [*c]struct_ecs_allocator_t, vec: [*c]ecs_vec_t, size: ecs_size_t) void;
pub extern fn ecs_vec_reset(allocator: [*c]struct_ecs_allocator_t, vec: [*c]ecs_vec_t, size: ecs_size_t) [*c]ecs_vec_t;
pub extern fn ecs_vec_clear(vec: [*c]ecs_vec_t) void;
pub extern fn ecs_vec_append(allocator: [*c]struct_ecs_allocator_t, vec: [*c]ecs_vec_t, size: ecs_size_t) ?*anyopaque;
pub extern fn ecs_vec_remove(vec: [*c]ecs_vec_t, size: ecs_size_t, elem: i32) void;
pub extern fn ecs_vec_remove_last(vec: [*c]ecs_vec_t) void;
pub extern fn ecs_vec_copy(allocator: [*c]struct_ecs_allocator_t, vec: [*c]const ecs_vec_t, size: ecs_size_t) ecs_vec_t;
pub extern fn ecs_vec_reclaim(allocator: [*c]struct_ecs_allocator_t, vec: [*c]ecs_vec_t, size: ecs_size_t) void;
pub extern fn ecs_vec_set_size(allocator: [*c]struct_ecs_allocator_t, vec: [*c]ecs_vec_t, size: ecs_size_t, elem_count: i32) void;
pub extern fn ecs_vec_set_min_size(allocator: [*c]struct_ecs_allocator_t, vec: [*c]ecs_vec_t, size: ecs_size_t, elem_count: i32) void;
pub extern fn ecs_vec_set_min_count(allocator: [*c]struct_ecs_allocator_t, vec: [*c]ecs_vec_t, size: ecs_size_t, elem_count: i32) void;
pub extern fn ecs_vec_set_min_count_zeromem(allocator: [*c]struct_ecs_allocator_t, vec: [*c]ecs_vec_t, size: ecs_size_t, elem_count: i32) void;
pub extern fn ecs_vec_set_count(allocator: [*c]struct_ecs_allocator_t, vec: [*c]ecs_vec_t, size: ecs_size_t, elem_count: i32) void;
pub extern fn ecs_vec_grow(allocator: [*c]struct_ecs_allocator_t, vec: [*c]ecs_vec_t, size: ecs_size_t, elem_count: i32) ?*anyopaque;
pub extern fn ecs_vec_count(vec: [*c]const ecs_vec_t) i32;
pub extern fn ecs_vec_size(vec: [*c]const ecs_vec_t) i32;
pub extern fn ecs_vec_get(vec: [*c]const ecs_vec_t, size: ecs_size_t, index: i32) ?*anyopaque;
pub extern fn ecs_vec_first(vec: [*c]const ecs_vec_t) ?*anyopaque;
pub extern fn ecs_vec_last(vec: [*c]const ecs_vec_t, size: ecs_size_t) ?*anyopaque;
pub const ecs_sparse_t = struct_ecs_sparse_t;
pub extern fn flecs_sparse_init(sparse: [*c]ecs_sparse_t, allocator: [*c]struct_ecs_allocator_t, page_allocator: [*c]struct_ecs_block_allocator_t, elem_size: ecs_size_t) void;
pub extern fn flecs_sparse_fini(sparse: [*c]ecs_sparse_t) void;
pub extern fn flecs_sparse_clear(sparse: [*c]ecs_sparse_t) void;
pub extern fn flecs_sparse_add(sparse: [*c]ecs_sparse_t, elem_size: ecs_size_t) ?*anyopaque;
pub extern fn flecs_sparse_last_id(sparse: [*c]const ecs_sparse_t) u64;
pub extern fn flecs_sparse_new_id(sparse: [*c]ecs_sparse_t) u64;
pub extern fn flecs_sparse_remove(sparse: [*c]ecs_sparse_t, elem_size: ecs_size_t, id: u64) void;
pub extern fn flecs_sparse_is_alive(sparse: [*c]const ecs_sparse_t, id: u64) bool;
pub extern fn flecs_sparse_get_dense(sparse: [*c]const ecs_sparse_t, elem_size: ecs_size_t, index: i32) ?*anyopaque;
pub extern fn flecs_sparse_count(sparse: [*c]const ecs_sparse_t) i32;
pub extern fn flecs_sparse_get(sparse: [*c]const ecs_sparse_t, elem_size: ecs_size_t, id: u64) ?*anyopaque;
pub extern fn flecs_sparse_try(sparse: [*c]const ecs_sparse_t, elem_size: ecs_size_t, id: u64) ?*anyopaque;
pub extern fn flecs_sparse_get_any(sparse: [*c]const ecs_sparse_t, elem_size: ecs_size_t, id: u64) ?*anyopaque;
pub extern fn flecs_sparse_ensure(sparse: [*c]ecs_sparse_t, elem_size: ecs_size_t, id: u64) ?*anyopaque;
pub extern fn flecs_sparse_ensure_fast(sparse: [*c]ecs_sparse_t, elem_size: ecs_size_t, id: u64) ?*anyopaque;
pub extern fn flecs_sparse_ids(sparse: [*c]const ecs_sparse_t) [*c]const u64;
pub extern fn ecs_sparse_init(sparse: [*c]ecs_sparse_t, elem_size: ecs_size_t) void;
pub extern fn ecs_sparse_add(sparse: [*c]ecs_sparse_t, elem_size: ecs_size_t) ?*anyopaque;
pub extern fn ecs_sparse_last_id(sparse: [*c]const ecs_sparse_t) u64;
pub extern fn ecs_sparse_count(sparse: [*c]const ecs_sparse_t) i32;
pub extern fn flecs_sparse_set_generation(sparse: [*c]ecs_sparse_t, id: u64) void;
pub extern fn ecs_sparse_get_dense(sparse: [*c]const ecs_sparse_t, elem_size: ecs_size_t, index: i32) ?*anyopaque;
pub extern fn ecs_sparse_get(sparse: [*c]const ecs_sparse_t, elem_size: ecs_size_t, id: u64) ?*anyopaque;
pub extern fn flecs_ballocator_init(ba: [*c]ecs_block_allocator_t, size: ecs_size_t) void;
pub extern fn flecs_ballocator_new(size: ecs_size_t) [*c]ecs_block_allocator_t;
pub extern fn flecs_ballocator_fini(ba: [*c]ecs_block_allocator_t) void;
pub extern fn flecs_ballocator_free(ba: [*c]ecs_block_allocator_t) void;
pub extern fn flecs_balloc(allocator: [*c]ecs_block_allocator_t) ?*anyopaque;
pub extern fn flecs_bcalloc(allocator: [*c]ecs_block_allocator_t) ?*anyopaque;
pub extern fn flecs_bfree(allocator: [*c]ecs_block_allocator_t, memory: ?*anyopaque) void;
pub extern fn flecs_brealloc(dst: [*c]ecs_block_allocator_t, src: [*c]ecs_block_allocator_t, memory: ?*anyopaque) ?*anyopaque;
pub extern fn flecs_bdup(ba: [*c]ecs_block_allocator_t, memory: ?*anyopaque) ?*anyopaque;
pub const ecs_map_data_t = u64;
pub const ecs_map_key_t = ecs_map_data_t;
pub const ecs_map_val_t = ecs_map_data_t;
pub const struct_ecs_bucket_entry_t = extern struct {
    key: ecs_map_key_t,
    value: ecs_map_val_t,
    next: [*c]struct_ecs_bucket_entry_t,
};
pub const ecs_bucket_entry_t = struct_ecs_bucket_entry_t;
pub const struct_ecs_bucket_t = extern struct {
    first: [*c]ecs_bucket_entry_t,
};
pub const ecs_bucket_t = struct_ecs_bucket_t;
pub const struct_ecs_map_t = extern struct {
    bucket_shift: u8,
    shared_allocator: bool,
    buckets: [*c]ecs_bucket_t,
    bucket_count: i32,
    count: i32,
    entry_allocator: [*c]struct_ecs_block_allocator_t,
    allocator: [*c]struct_ecs_allocator_t,
};
pub const ecs_map_t = struct_ecs_map_t;
pub const struct_ecs_map_iter_t = extern struct {
    map: [*c]const ecs_map_t,
    bucket: [*c]ecs_bucket_t,
    entry: [*c]ecs_bucket_entry_t,
    res: [*c]ecs_map_data_t,
};
pub const ecs_map_iter_t = struct_ecs_map_iter_t;
pub const struct_ecs_map_params_t = extern struct {
    allocator: [*c]struct_ecs_allocator_t,
    entry_allocator: struct_ecs_block_allocator_t,
};
pub const ecs_map_params_t = struct_ecs_map_params_t;
pub extern fn ecs_map_params_init(params: [*c]ecs_map_params_t, allocator: [*c]struct_ecs_allocator_t) void;
pub extern fn ecs_map_params_fini(params: [*c]ecs_map_params_t) void;
pub extern fn ecs_map_init(map: [*c]ecs_map_t, allocator: [*c]struct_ecs_allocator_t) void;
pub extern fn ecs_map_init_w_params(map: [*c]ecs_map_t, params: [*c]ecs_map_params_t) void;
pub extern fn ecs_map_init_if(map: [*c]ecs_map_t, allocator: [*c]struct_ecs_allocator_t) void;
pub extern fn ecs_map_init_w_params_if(result: [*c]ecs_map_t, params: [*c]ecs_map_params_t) void;
pub extern fn ecs_map_fini(map: [*c]ecs_map_t) void;
pub extern fn ecs_map_get(map: [*c]const ecs_map_t, key: ecs_map_key_t) [*c]ecs_map_val_t;
pub extern fn ecs_map_get_deref_(map: [*c]const ecs_map_t, key: ecs_map_key_t) ?*anyopaque;
pub extern fn ecs_map_ensure(map: [*c]ecs_map_t, key: ecs_map_key_t) [*c]ecs_map_val_t;
pub extern fn ecs_map_ensure_alloc(map: [*c]ecs_map_t, elem_size: ecs_size_t, key: ecs_map_key_t) ?*anyopaque;
pub extern fn ecs_map_insert(map: [*c]ecs_map_t, key: ecs_map_key_t, value: ecs_map_val_t) void;
pub extern fn ecs_map_insert_alloc(map: [*c]ecs_map_t, elem_size: ecs_size_t, key: ecs_map_key_t) ?*anyopaque;
pub extern fn ecs_map_remove(map: [*c]ecs_map_t, key: ecs_map_key_t) ecs_map_val_t;
pub extern fn ecs_map_remove_free(map: [*c]ecs_map_t, key: ecs_map_key_t) void;
pub extern fn ecs_map_clear(map: [*c]ecs_map_t) void;
pub extern fn ecs_map_iter(map: [*c]const ecs_map_t) ecs_map_iter_t;
pub extern fn ecs_map_next(iter: [*c]ecs_map_iter_t) bool;
pub extern fn ecs_map_copy(dst: [*c]ecs_map_t, src: [*c]const ecs_map_t) void;
pub extern var ecs_block_allocator_alloc_count: i64;
pub extern var ecs_block_allocator_free_count: i64;
pub extern var ecs_stack_allocator_alloc_count: i64;
pub extern var ecs_stack_allocator_free_count: i64;
pub extern fn flecs_allocator_init(a: [*c]ecs_allocator_t) void;
pub extern fn flecs_allocator_fini(a: [*c]ecs_allocator_t) void;
pub extern fn flecs_allocator_get(a: [*c]ecs_allocator_t, size: ecs_size_t) [*c]ecs_block_allocator_t;
pub extern fn flecs_strdup(a: [*c]ecs_allocator_t, str: [*c]const u8) [*c]u8;
pub extern fn flecs_strfree(a: [*c]ecs_allocator_t, str: [*c]u8) void;
pub extern fn flecs_dup(a: [*c]ecs_allocator_t, size: ecs_size_t, src: ?*const anyopaque) ?*anyopaque;
pub const struct_ecs_strbuf_element = extern struct {
    buffer_embedded: bool,
    pos: i32,
    buf: [*c]u8,
    next: [*c]struct_ecs_strbuf_element,
};
pub const ecs_strbuf_element = struct_ecs_strbuf_element;
pub const struct_ecs_strbuf_element_embedded = extern struct {
    super: ecs_strbuf_element,
    buf: [512]u8,
};
pub const ecs_strbuf_element_embedded = struct_ecs_strbuf_element_embedded;
pub const struct_ecs_strbuf_element_str = extern struct {
    super: ecs_strbuf_element,
    alloc_str: [*c]u8,
};
pub const ecs_strbuf_element_str = struct_ecs_strbuf_element_str;
pub const struct_ecs_strbuf_list_elem = extern struct {
    count: i32,
    separator: [*c]const u8,
};
pub const ecs_strbuf_list_elem = struct_ecs_strbuf_list_elem;
pub const struct_ecs_strbuf_t = extern struct {
    buf: [*c]u8,
    max: i32,
    size: i32,
    elementCount: i32,
    firstElement: ecs_strbuf_element_embedded,
    current: [*c]ecs_strbuf_element,
    list_stack: [32]ecs_strbuf_list_elem,
    list_sp: i32,
    content: [*c]u8,
    length: i32,
};
pub const ecs_strbuf_t = struct_ecs_strbuf_t;
pub extern fn ecs_strbuf_append(buffer: [*c]ecs_strbuf_t, fmt: [*c]const u8, ...) bool;
pub extern fn ecs_strbuf_vappend(buffer: [*c]ecs_strbuf_t, fmt: [*c]const u8, args: va_list) bool;
pub extern fn ecs_strbuf_appendstr(buffer: [*c]ecs_strbuf_t, str: [*c]const u8) bool;
pub extern fn ecs_strbuf_appendch(buffer: [*c]ecs_strbuf_t, ch: u8) bool;
pub extern fn ecs_strbuf_appendint(buffer: [*c]ecs_strbuf_t, v: i64) bool;
pub extern fn ecs_strbuf_appendflt(buffer: [*c]ecs_strbuf_t, v: f64, nan_delim: u8) bool;
pub extern fn ecs_strbuf_appendbool(buffer: [*c]ecs_strbuf_t, v: bool) bool;
pub extern fn ecs_strbuf_mergebuff(dst_buffer: [*c]ecs_strbuf_t, src_buffer: [*c]ecs_strbuf_t) bool;
pub extern fn ecs_strbuf_appendstr_zerocpy(buffer: [*c]ecs_strbuf_t, str: [*c]u8) bool;
pub extern fn ecs_strbuf_appendstr_zerocpyn(buffer: [*c]ecs_strbuf_t, str: [*c]u8, n: i32) bool;
pub extern fn ecs_strbuf_appendstr_zerocpy_const(buffer: [*c]ecs_strbuf_t, str: [*c]const u8) bool;
pub extern fn ecs_strbuf_appendstr_zerocpyn_const(buffer: [*c]ecs_strbuf_t, str: [*c]const u8, n: i32) bool;
pub extern fn ecs_strbuf_appendstrn(buffer: [*c]ecs_strbuf_t, str: [*c]const u8, n: i32) bool;
pub extern fn ecs_strbuf_get(buffer: [*c]ecs_strbuf_t) [*c]u8;
pub extern fn ecs_strbuf_get_small(buffer: [*c]ecs_strbuf_t) [*c]u8;
pub extern fn ecs_strbuf_reset(buffer: [*c]ecs_strbuf_t) void;
pub extern fn ecs_strbuf_list_push(buffer: [*c]ecs_strbuf_t, list_open: [*c]const u8, separator: [*c]const u8) void;
pub extern fn ecs_strbuf_list_pop(buffer: [*c]ecs_strbuf_t, list_close: [*c]const u8) void;
pub extern fn ecs_strbuf_list_next(buffer: [*c]ecs_strbuf_t) void;
pub extern fn ecs_strbuf_list_appendch(buffer: [*c]ecs_strbuf_t, ch: u8) bool;
pub extern fn ecs_strbuf_list_append(buffer: [*c]ecs_strbuf_t, fmt: [*c]const u8, ...) bool;
pub extern fn ecs_strbuf_list_appendstr(buffer: [*c]ecs_strbuf_t, str: [*c]const u8) bool;
pub extern fn ecs_strbuf_list_appendstrn(buffer: [*c]ecs_strbuf_t, str: [*c]const u8, n: i32) bool;
pub extern fn ecs_strbuf_written(buffer: [*c]const ecs_strbuf_t) i32;
pub extern fn __error() [*c]c_int;
pub extern fn alloca(c_ulong) ?*anyopaque;
pub const struct_ecs_time_t = extern struct {
    sec: u32,
    nanosec: u32,
};
pub const ecs_time_t = struct_ecs_time_t;
pub extern var ecs_os_api_malloc_count: i64;
pub extern var ecs_os_api_realloc_count: i64;
pub extern var ecs_os_api_calloc_count: i64;
pub extern var ecs_os_api_free_count: i64;
pub const ecs_os_thread_t = usize;
pub const ecs_os_cond_t = usize;
pub const ecs_os_mutex_t = usize;
pub const ecs_os_dl_t = usize;
pub const ecs_os_sock_t = usize;
pub const ecs_os_thread_id_t = u64;
pub const ecs_os_proc_t = ?*const fn () callconv(.C) void;
pub const ecs_os_api_init_t = ?*const fn () callconv(.C) void;
pub const ecs_os_api_fini_t = ?*const fn () callconv(.C) void;
pub const ecs_os_api_malloc_t = ?*const fn (ecs_size_t) callconv(.C) ?*anyopaque;
pub const ecs_os_api_free_t = ?*const fn (?*anyopaque) callconv(.C) void;
pub const ecs_os_api_realloc_t = ?*const fn (?*anyopaque, ecs_size_t) callconv(.C) ?*anyopaque;
pub const ecs_os_api_calloc_t = ?*const fn (ecs_size_t) callconv(.C) ?*anyopaque;
pub const ecs_os_api_strdup_t = ?*const fn ([*c]const u8) callconv(.C) [*c]u8;
pub const ecs_os_thread_callback_t = ?*const fn (?*anyopaque) callconv(.C) ?*anyopaque;
pub const ecs_os_api_thread_new_t = ?*const fn (ecs_os_thread_callback_t, ?*anyopaque) callconv(.C) ecs_os_thread_t;
pub const ecs_os_api_thread_join_t = ?*const fn (ecs_os_thread_t) callconv(.C) ?*anyopaque;
pub const ecs_os_api_thread_self_t = ?*const fn () callconv(.C) ecs_os_thread_id_t;
pub const ecs_os_api_task_new_t = ?*const fn (ecs_os_thread_callback_t, ?*anyopaque) callconv(.C) ecs_os_thread_t;
pub const ecs_os_api_task_join_t = ?*const fn (ecs_os_thread_t) callconv(.C) ?*anyopaque;
pub const ecs_os_api_ainc_t = ?*const fn ([*c]i32) callconv(.C) i32;
pub const ecs_os_api_lainc_t = ?*const fn ([*c]i64) callconv(.C) i64;
pub const ecs_os_api_mutex_new_t = ?*const fn () callconv(.C) ecs_os_mutex_t;
pub const ecs_os_api_mutex_lock_t = ?*const fn (ecs_os_mutex_t) callconv(.C) void;
pub const ecs_os_api_mutex_unlock_t = ?*const fn (ecs_os_mutex_t) callconv(.C) void;
pub const ecs_os_api_mutex_free_t = ?*const fn (ecs_os_mutex_t) callconv(.C) void;
pub const ecs_os_api_cond_new_t = ?*const fn () callconv(.C) ecs_os_cond_t;
pub const ecs_os_api_cond_free_t = ?*const fn (ecs_os_cond_t) callconv(.C) void;
pub const ecs_os_api_cond_signal_t = ?*const fn (ecs_os_cond_t) callconv(.C) void;
pub const ecs_os_api_cond_broadcast_t = ?*const fn (ecs_os_cond_t) callconv(.C) void;
pub const ecs_os_api_cond_wait_t = ?*const fn (ecs_os_cond_t, ecs_os_mutex_t) callconv(.C) void;
pub const ecs_os_api_sleep_t = ?*const fn (i32, i32) callconv(.C) void;
pub const ecs_os_api_enable_high_timer_resolution_t = ?*const fn (bool) callconv(.C) void;
pub const ecs_os_api_get_time_t = ?*const fn ([*c]ecs_time_t) callconv(.C) void;
pub const ecs_os_api_now_t = ?*const fn () callconv(.C) u64;
pub const ecs_os_api_log_t = ?*const fn (i32, [*c]const u8, i32, [*c]const u8) callconv(.C) void;
pub const ecs_os_api_abort_t = ?*const fn () callconv(.C) void;
pub const ecs_os_api_dlopen_t = ?*const fn ([*c]const u8) callconv(.C) ecs_os_dl_t;
pub const ecs_os_api_dlproc_t = ?*const fn (ecs_os_dl_t, [*c]const u8) callconv(.C) ecs_os_proc_t;
pub const ecs_os_api_dlclose_t = ?*const fn (ecs_os_dl_t) callconv(.C) void;
pub const ecs_os_api_module_to_path_t = ?*const fn ([*c]const u8) callconv(.C) [*c]u8;
pub const struct_ecs_os_api_t = extern struct {
    init_: ecs_os_api_init_t,
    fini_: ecs_os_api_fini_t,
    malloc_: ecs_os_api_malloc_t,
    realloc_: ecs_os_api_realloc_t,
    calloc_: ecs_os_api_calloc_t,
    free_: ecs_os_api_free_t,
    strdup_: ecs_os_api_strdup_t,
    thread_new_: ecs_os_api_thread_new_t,
    thread_join_: ecs_os_api_thread_join_t,
    thread_self_: ecs_os_api_thread_self_t,
    task_new_: ecs_os_api_thread_new_t,
    task_join_: ecs_os_api_thread_join_t,
    ainc_: ecs_os_api_ainc_t,
    adec_: ecs_os_api_ainc_t,
    lainc_: ecs_os_api_lainc_t,
    ladec_: ecs_os_api_lainc_t,
    mutex_new_: ecs_os_api_mutex_new_t,
    mutex_free_: ecs_os_api_mutex_free_t,
    mutex_lock_: ecs_os_api_mutex_lock_t,
    mutex_unlock_: ecs_os_api_mutex_lock_t,
    cond_new_: ecs_os_api_cond_new_t,
    cond_free_: ecs_os_api_cond_free_t,
    cond_signal_: ecs_os_api_cond_signal_t,
    cond_broadcast_: ecs_os_api_cond_broadcast_t,
    cond_wait_: ecs_os_api_cond_wait_t,
    sleep_: ecs_os_api_sleep_t,
    now_: ecs_os_api_now_t,
    get_time_: ecs_os_api_get_time_t,
    log_: ecs_os_api_log_t,
    abort_: ecs_os_api_abort_t,
    dlopen_: ecs_os_api_dlopen_t,
    dlproc_: ecs_os_api_dlproc_t,
    dlclose_: ecs_os_api_dlclose_t,
    module_to_dl_: ecs_os_api_module_to_path_t,
    module_to_etc_: ecs_os_api_module_to_path_t,
    log_level_: i32,
    log_indent_: i32,
    log_last_error_: i32,
    log_last_timestamp_: i64,
    flags_: ecs_flags32_t,
};
pub const ecs_os_api_t = struct_ecs_os_api_t;
pub extern var ecs_os_api: ecs_os_api_t;
pub extern fn ecs_os_init() void;
pub extern fn ecs_os_fini() void;
pub extern fn ecs_os_set_api(os_api: [*c]ecs_os_api_t) void;
pub extern fn ecs_os_get_api() ecs_os_api_t;
pub extern fn ecs_os_set_api_defaults() void;
pub extern fn ecs_os_dbg(file: [*c]const u8, line: i32, msg: [*c]const u8) void;
pub extern fn ecs_os_trace(file: [*c]const u8, line: i32, msg: [*c]const u8) void;
pub extern fn ecs_os_warn(file: [*c]const u8, line: i32, msg: [*c]const u8) void;
pub extern fn ecs_os_err(file: [*c]const u8, line: i32, msg: [*c]const u8) void;
pub extern fn ecs_os_fatal(file: [*c]const u8, line: i32, msg: [*c]const u8) void;
pub extern fn ecs_os_strerror(err: c_int) [*c]const u8;
pub extern fn ecs_os_strset(str: [*c][*c]u8, value: [*c]const u8) void;
pub extern fn ecs_sleepf(t: f64) void;
pub extern fn ecs_time_measure(start: [*c]ecs_time_t) f64;
pub extern fn ecs_time_sub(t1: ecs_time_t, t2: ecs_time_t) ecs_time_t;
pub extern fn ecs_time_to_double(t: ecs_time_t) f64;
pub extern fn ecs_os_memdup(src: ?*const anyopaque, size: ecs_size_t) ?*anyopaque;
pub extern fn ecs_os_has_heap() bool;
pub extern fn ecs_os_has_threading() bool;
pub extern fn ecs_os_has_task_support() bool;
pub extern fn ecs_os_has_time() bool;
pub extern fn ecs_os_has_logging() bool;
pub extern fn ecs_os_has_dl() bool;
pub extern fn ecs_os_has_modules() bool;
pub const ecs_id_t = u64;
pub const ecs_entity_t = ecs_id_t;
pub const ecs_type_t = extern struct {
    array: [*c]ecs_id_t,
    count: i32,
};
pub const struct_ecs_world_t = @import("flecs_world.zig").struct_ecs_world_t;
// pub const struct_ecs_world_t = opaque {};
pub const ecs_world_t = struct_ecs_world_t;
pub const struct_ecs_table_t = opaque {};
pub const ecs_table_t = struct_ecs_table_t;
pub const struct_ecs_term_id_t = extern struct {
    id: ecs_entity_t,
    name: [*c]const u8,
    trav: ecs_entity_t,
    flags: ecs_flags32_t,
};
pub const ecs_term_id_t = struct_ecs_term_id_t;
pub const EcsInOutDefault: c_int = 0;
pub const EcsInOutNone: c_int = 1;
pub const EcsInOut: c_int = 2;
pub const EcsIn: c_int = 3;
pub const EcsOut: c_int = 4;
pub const enum_ecs_inout_kind_t = c_uint;
pub const ecs_inout_kind_t = enum_ecs_inout_kind_t;
pub const EcsAnd: c_int = 0;
pub const EcsOr: c_int = 1;
pub const EcsNot: c_int = 2;
pub const EcsOptional: c_int = 3;
pub const EcsAndFrom: c_int = 4;
pub const EcsOrFrom: c_int = 5;
pub const EcsNotFrom: c_int = 6;
pub const enum_ecs_oper_kind_t = c_uint;
pub const ecs_oper_kind_t = enum_ecs_oper_kind_t;
pub const struct_ecs_id_record_t = opaque {};
pub const ecs_id_record_t = struct_ecs_id_record_t;
pub const struct_ecs_term_t = extern struct {
    id: ecs_id_t,
    src: ecs_term_id_t,
    first: ecs_term_id_t,
    second: ecs_term_id_t,
    inout: ecs_inout_kind_t,
    oper: ecs_oper_kind_t,
    id_flags: ecs_id_t,
    name: [*c]u8,
    field_index: i32,
    idr: ?*ecs_id_record_t,
    flags: ecs_flags16_t,
    move: bool,
};
pub const ecs_term_t = struct_ecs_term_t;
pub const struct_ecs_mixins_t = opaque {};
pub const ecs_mixins_t = struct_ecs_mixins_t;
pub const struct_ecs_header_t = extern struct {
    magic: i32,
    type: i32,
    mixins: ?*ecs_mixins_t,
};
pub const ecs_header_t = struct_ecs_header_t;
pub const ecs_poly_t = anyopaque;
pub const struct_ecs_table_range_t = extern struct {
    table: ?*ecs_table_t,
    offset: i32,
    count: i32,
};
pub const ecs_table_range_t = struct_ecs_table_range_t;
pub const struct_ecs_var_t = extern struct {
    range: ecs_table_range_t,
    entity: ecs_entity_t,
};
pub const ecs_var_t = struct_ecs_var_t;
pub const struct_ecs_table_record_t = opaque {};
pub const struct_ecs_record_t = extern struct {
    idr: ?*ecs_id_record_t,
    table: ?*ecs_table_t,
    row: u32,
    dense: i32,
};
pub const ecs_record_t = struct_ecs_record_t;
pub const struct_ecs_ref_t = extern struct {
    entity: ecs_entity_t,
    id: ecs_entity_t,
    tr: ?*struct_ecs_table_record_t,
    record: [*c]ecs_record_t,
};
pub const ecs_ref_t = struct_ecs_ref_t;
pub const struct_ecs_table_cache_hdr_t = opaque {};
pub const struct_ecs_table_cache_iter_t = extern struct {
    cur: ?*struct_ecs_table_cache_hdr_t,
    next: ?*struct_ecs_table_cache_hdr_t,
    next_list: ?*struct_ecs_table_cache_hdr_t,
};
pub const ecs_table_cache_iter_t = struct_ecs_table_cache_iter_t;
pub const struct_ecs_term_iter_t = extern struct {
    term: ecs_term_t,
    self_index: ?*ecs_id_record_t,
    set_index: ?*ecs_id_record_t,
    cur: ?*ecs_id_record_t,
    it: ecs_table_cache_iter_t,
    index: i32,
    observed_table_count: i32,
    table: ?*ecs_table_t,
    cur_match: i32,
    match_count: i32,
    last_column: i32,
    empty_tables: bool,
    id: ecs_id_t,
    column: i32,
    subject: ecs_entity_t,
    size: ecs_size_t,
    ptr: ?*anyopaque,
};
pub const ecs_term_iter_t = struct_ecs_term_iter_t;
pub const ecs_filter_t = struct_ecs_filter_t;
pub const EcsIterEvalCondition: c_int = 0;
pub const EcsIterEvalTables: c_int = 1;
pub const EcsIterEvalChain: c_int = 2;
pub const EcsIterEvalNone: c_int = 3;
pub const enum_ecs_iter_kind_t = c_uint;
pub const ecs_iter_kind_t = enum_ecs_iter_kind_t;
pub const struct_ecs_filter_iter_t = extern struct {
    filter: [*c]const ecs_filter_t,
    kind: ecs_iter_kind_t,
    term_iter: ecs_term_iter_t,
    matches_left: i32,
    pivot_term: i32,
};
pub const ecs_filter_iter_t = struct_ecs_filter_iter_t;
pub const struct_ecs_query_t = opaque {};
pub const ecs_query_t = struct_ecs_query_t;
pub const struct_ecs_query_table_match_t = opaque {};
pub const ecs_query_table_match_t = struct_ecs_query_table_match_t;
pub const struct_ecs_query_iter_t = extern struct {
    query: ?*ecs_query_t,
    node: ?*ecs_query_table_match_t,
    prev: ?*ecs_query_table_match_t,
    last: ?*ecs_query_table_match_t,
    sparse_smallest: i32,
    sparse_first: i32,
    bitset_first: i32,
    skip_count: i32,
};
pub const ecs_query_iter_t = struct_ecs_query_iter_t;
pub const struct_ecs_rule_t = opaque {};
pub const ecs_rule_t = struct_ecs_rule_t;
pub const struct_ecs_rule_var_t = opaque {};
pub const struct_ecs_rule_op_t = opaque {};
pub const struct_ecs_rule_op_ctx_t = opaque {};
pub const struct_ecs_rule_op_profile_t = extern struct {
    count: [2]i32,
};
pub const ecs_rule_op_profile_t = struct_ecs_rule_op_profile_t;
pub const struct_ecs_rule_iter_t = extern struct {
    rule: ?*const ecs_rule_t,
    vars: [*c]struct_ecs_var_t,
    rule_vars: ?*const struct_ecs_rule_var_t,
    ops: ?*const struct_ecs_rule_op_t,
    op_ctx: ?*struct_ecs_rule_op_ctx_t,
    written: [*c]u64,
    profile: [*c]ecs_rule_op_profile_t,
    redo: bool,
    op: i16,
    sp: i16,
};
pub const ecs_rule_iter_t = struct_ecs_rule_iter_t;
pub const struct_ecs_snapshot_iter_t = extern struct {
    filter: ecs_filter_t,
    tables: ecs_vec_t,
    index: i32,
};
pub const ecs_snapshot_iter_t = struct_ecs_snapshot_iter_t;
pub const struct_ecs_page_iter_t = extern struct {
    offset: i32,
    limit: i32,
    remaining: i32,
};
pub const ecs_page_iter_t = struct_ecs_page_iter_t;
pub const struct_ecs_worker_iter_t = extern struct {
    index: i32,
    count: i32,
};
pub const ecs_worker_iter_t = struct_ecs_worker_iter_t;
const union_unnamed_1 = extern union {
    term: ecs_term_iter_t,
    filter: ecs_filter_iter_t,
    query: ecs_query_iter_t,
    rule: ecs_rule_iter_t,
    snapshot: ecs_snapshot_iter_t,
    page: ecs_page_iter_t,
    worker: ecs_worker_iter_t,
};
pub const struct_ecs_stack_page_t = opaque {};
pub const struct_ecs_stack_t = opaque {};
pub const struct_ecs_stack_cursor_t = extern struct {
    prev: [*c]struct_ecs_stack_cursor_t,
    page: ?*struct_ecs_stack_page_t,
    sp: i16,
    is_free: bool,
    owner: ?*struct_ecs_stack_t,
};
pub const ecs_stack_cursor_t = struct_ecs_stack_cursor_t;
pub const struct_ecs_iter_cache_t = extern struct {
    stack_cursor: [*c]ecs_stack_cursor_t,
    used: ecs_flags8_t,
    allocated: ecs_flags8_t,
};
pub const ecs_iter_cache_t = struct_ecs_iter_cache_t;
pub const struct_ecs_iter_private_t = extern struct {
    iter: union_unnamed_1,
    entity_iter: ?*anyopaque,
    cache: ecs_iter_cache_t,
};
pub const ecs_iter_private_t = struct_ecs_iter_private_t;
pub const ecs_iter_next_action_t = ?*const fn ([*c]ecs_iter_t) callconv(.C) bool;
pub const ecs_iter_action_t = ?*const fn ([*c]ecs_iter_t) callconv(.C) void;
pub const ecs_iter_fini_action_t = ?*const fn ([*c]ecs_iter_t) callconv(.C) void;
pub const struct_ecs_iter_t = extern struct {
    world: ?*ecs_world_t,
    real_world: ?*ecs_world_t,
    entities: [*c]ecs_entity_t,
    ptrs: [*c]?*anyopaque,
    sizes: [*c]ecs_size_t,
    table: ?*ecs_table_t,
    other_table: ?*ecs_table_t,
    ids: [*c]ecs_id_t,
    variables: [*c]ecs_var_t,
    columns: [*c]i32,
    sources: [*c]ecs_entity_t,
    match_indices: [*c]i32,
    references: [*c]ecs_ref_t,
    constrained_vars: ecs_flags64_t,
    group_id: u64,
    field_count: i32,
    system: ecs_entity_t,
    event: ecs_entity_t,
    event_id: ecs_id_t,
    terms: [*c]ecs_term_t,
    table_count: i32,
    term_index: i32,
    variable_count: i32,
    variable_names: [*c][*c]u8,
    param: ?*anyopaque,
    ctx: ?*anyopaque,
    binding_ctx: ?*anyopaque,
    delta_time: f32,
    delta_system_time: f32,
    frame_offset: i32,
    offset: i32,
    count: i32,
    instance_count: i32,
    flags: ecs_flags32_t,
    interrupted_by: ecs_entity_t,
    priv: ecs_iter_private_t,
    next: ecs_iter_next_action_t,
    // MIKEWASHERE: hack for https://github.com/ziglang/zig/issues/12325
    // callback: ecs_iter_action_t,
    // set_var: ecs_iter_action_t,
    callback: *anyopaque,
    set_var: *anyopaque,
    fini: ecs_iter_fini_action_t,
    chain_it: [*c]ecs_iter_t,
};
pub const ecs_iter_t = struct_ecs_iter_t;
pub const ecs_iter_init_action_t = ?*const fn (?*const ecs_world_t, ?*const ecs_poly_t, [*c]ecs_iter_t, [*c]ecs_term_t) callconv(.C) void;
pub const struct_ecs_iterable_t = extern struct {
    init: ecs_iter_init_action_t,
};
pub const ecs_iterable_t = struct_ecs_iterable_t;
pub const ecs_poly_dtor_t = ?*const fn (?*ecs_poly_t) callconv(.C) void;
pub const struct_ecs_filter_t = extern struct {
    hdr: ecs_header_t,
    terms: [*c]ecs_term_t,
    term_count: i32,
    field_count: i32,
    owned: bool,
    terms_owned: bool,
    flags: ecs_flags32_t,
    variable_names: [1][*c]u8,
    sizes: [*c]i32,
    entity: ecs_entity_t,
    iterable: ecs_iterable_t,
    dtor: ecs_poly_dtor_t,
    world: ?*ecs_world_t,
};
pub const ecs_run_action_t = ?*const fn ([*c]ecs_iter_t) callconv(.C) void;
pub const ecs_ctx_free_t = ?*const fn (?*anyopaque) callconv(.C) void;
pub const struct_ecs_event_id_record_t = opaque {};
pub const struct_ecs_event_record_t = extern struct {
    any: ?*struct_ecs_event_id_record_t,
    wildcard: ?*struct_ecs_event_id_record_t,
    wildcard_pair: ?*struct_ecs_event_id_record_t,
    event_ids: ecs_map_t,
    event: ecs_entity_t,
};
pub const ecs_event_record_t = struct_ecs_event_record_t;
pub const struct_ecs_observable_t = extern struct {
    on_add: ecs_event_record_t,
    on_remove: ecs_event_record_t,
    on_set: ecs_event_record_t,
    un_set: ecs_event_record_t,
    on_wildcard: ecs_event_record_t,
    events: ecs_sparse_t,
};
pub const ecs_observable_t = struct_ecs_observable_t;
pub const struct_ecs_observer_t = extern struct {
    hdr: ecs_header_t,
    filter: ecs_filter_t,
    events: [8]ecs_entity_t,
    event_count: i32,
    callback: ecs_iter_action_t,
    run: ecs_run_action_t,
    ctx: ?*anyopaque,
    binding_ctx: ?*anyopaque,
    ctx_free: ecs_ctx_free_t,
    binding_ctx_free: ecs_ctx_free_t,
    observable: [*c]ecs_observable_t,
    last_event_id: [*c]i32,
    last_event_id_storage: i32,
    register_id: ecs_id_t,
    term_index: i32,
    is_monitor: bool,
    is_multi: bool,
    dtor: ecs_poly_dtor_t,
};
pub const ecs_observer_t = struct_ecs_observer_t;
pub const ecs_type_hooks_t = struct_ecs_type_hooks_t;
pub const struct_ecs_type_info_t = extern struct {
    size: ecs_size_t,
    alignment: ecs_size_t,
    hooks: ecs_type_hooks_t,
    component: ecs_entity_t,
    name: [*c]const u8,
};
pub const ecs_type_info_t = struct_ecs_type_info_t;
pub const ecs_xtor_t = ?*const fn (?*anyopaque, i32, [*c]const ecs_type_info_t) callconv(.C) void;
pub const ecs_copy_t = ?*const fn (?*anyopaque, ?*const anyopaque, i32, [*c]const ecs_type_info_t) callconv(.C) void;
pub const ecs_move_t = ?*const fn (?*anyopaque, ?*anyopaque, i32, [*c]const ecs_type_info_t) callconv(.C) void;
pub const struct_ecs_type_hooks_t = extern struct {
    ctor: ecs_xtor_t,
    dtor: ecs_xtor_t,
    copy: ecs_copy_t,
    move: ecs_move_t,
    copy_ctor: ecs_copy_t,
    move_ctor: ecs_move_t,
    ctor_move_dtor: ecs_move_t,
    move_dtor: ecs_move_t,
    on_add: ecs_iter_action_t,
    on_set: ecs_iter_action_t,
    on_remove: ecs_iter_action_t,
    ctx: ?*anyopaque,
    binding_ctx: ?*anyopaque,
    ctx_free: ecs_ctx_free_t,
    binding_ctx_free: ecs_ctx_free_t,
};
pub const ecs_table_record_t = struct_ecs_table_record_t;
pub const ecs_order_by_action_t = ?*const fn (ecs_entity_t, ?*const anyopaque, ecs_entity_t, ?*const anyopaque) callconv(.C) c_int;
pub const ecs_sort_table_action_t = ?*const fn (?*ecs_world_t, ?*ecs_table_t, [*c]ecs_entity_t, ?*anyopaque, i32, i32, i32, ecs_order_by_action_t) callconv(.C) void;
pub const ecs_group_by_action_t = ?*const fn (?*ecs_world_t, ?*ecs_table_t, ecs_id_t, ?*anyopaque) callconv(.C) u64;
pub const ecs_group_create_action_t = ?*const fn (?*ecs_world_t, u64, ?*anyopaque) callconv(.C) ?*anyopaque;
pub const ecs_group_delete_action_t = ?*const fn (?*ecs_world_t, u64, ?*anyopaque, ?*anyopaque) callconv(.C) void;
pub const ecs_module_action_t = ?*const fn (?*ecs_world_t) callconv(.C) void;
pub const ecs_fini_action_t = ?*const fn (?*ecs_world_t, ?*anyopaque) callconv(.C) void;
pub const ecs_compare_action_t = ?*const fn (?*const anyopaque, ?*const anyopaque) callconv(.C) c_int;
pub const ecs_hash_value_action_t = ?*const fn (?*const anyopaque) callconv(.C) u64;
pub extern var ECS_FILTER_INIT: ecs_filter_t;
pub const struct_ecs_stage_t = opaque {};
pub const ecs_stage_t = struct_ecs_stage_t;
pub const struct_ecs_data_t = opaque {};
pub const ecs_data_t = struct_ecs_data_t;
pub const struct_ecs_switch_t = opaque {};
pub const ecs_switch_t = struct_ecs_switch_t;
pub extern fn ecs_module_path_from_c(c_name: [*c]const u8) [*c]u8;
pub extern fn ecs_identifier_is_0(id: [*c]const u8) bool;
pub extern fn ecs_default_ctor(ptr: ?*anyopaque, count: i32, ctx: [*c]const ecs_type_info_t) void;
pub extern fn ecs_vasprintf(fmt: [*c]const u8, args: va_list) [*c]u8;
pub extern fn ecs_asprintf(fmt: [*c]const u8, ...) [*c]u8;
pub extern fn flecs_to_snake_case(str: [*c]const u8) [*c]u8;
pub extern fn flecs_table_observed_count(table: ?*const ecs_table_t) i32;
pub const ecs_hm_bucket_t = extern struct {
    keys: ecs_vec_t,
    values: ecs_vec_t,
};
pub const ecs_hashmap_t = extern struct {
    hash: ecs_hash_value_action_t,
    compare: ecs_compare_action_t,
    key_size: ecs_size_t,
    value_size: ecs_size_t,
    hashmap_allocator: [*c]ecs_block_allocator_t,
    bucket_allocator: ecs_block_allocator_t,
    impl: ecs_map_t,
};
pub const flecs_hashmap_iter_t = extern struct {
    it: ecs_map_iter_t,
    bucket: [*c]ecs_hm_bucket_t,
    index: i32,
};
pub const flecs_hashmap_result_t = extern struct {
    key: ?*anyopaque,
    value: ?*anyopaque,
    hash: u64,
};
pub extern fn flecs_hashmap_init_(hm: [*c]ecs_hashmap_t, key_size: ecs_size_t, value_size: ecs_size_t, hash: ecs_hash_value_action_t, compare: ecs_compare_action_t, allocator: [*c]ecs_allocator_t) void;
pub extern fn flecs_hashmap_fini(map: [*c]ecs_hashmap_t) void;
pub extern fn flecs_hashmap_get_(map: [*c]const ecs_hashmap_t, key_size: ecs_size_t, key: ?*const anyopaque, value_size: ecs_size_t) ?*anyopaque;
pub extern fn flecs_hashmap_ensure_(map: [*c]ecs_hashmap_t, key_size: ecs_size_t, key: ?*const anyopaque, value_size: ecs_size_t) flecs_hashmap_result_t;
pub extern fn flecs_hashmap_set_(map: [*c]ecs_hashmap_t, key_size: ecs_size_t, key: ?*anyopaque, value_size: ecs_size_t, value: ?*const anyopaque) void;
pub extern fn flecs_hashmap_remove_(map: [*c]ecs_hashmap_t, key_size: ecs_size_t, key: ?*const anyopaque, value_size: ecs_size_t) void;
pub extern fn flecs_hashmap_remove_w_hash_(map: [*c]ecs_hashmap_t, key_size: ecs_size_t, key: ?*const anyopaque, value_size: ecs_size_t, hash: u64) void;
pub extern fn flecs_hashmap_get_bucket(map: [*c]const ecs_hashmap_t, hash: u64) [*c]ecs_hm_bucket_t;
pub extern fn flecs_hm_bucket_remove(map: [*c]ecs_hashmap_t, bucket: [*c]ecs_hm_bucket_t, hash: u64, index: i32) void;
pub extern fn flecs_hashmap_copy(dst: [*c]ecs_hashmap_t, src: [*c]const ecs_hashmap_t) void;
pub extern fn flecs_hashmap_iter(map: [*c]ecs_hashmap_t) flecs_hashmap_iter_t;
pub extern fn flecs_hashmap_next_(it: [*c]flecs_hashmap_iter_t, key_size: ecs_size_t, key_out: ?*anyopaque, value_size: ecs_size_t) ?*anyopaque;
pub const struct_ecs_entity_desc_t = extern struct {
    _canary: i32,
    id: ecs_entity_t,
    name: [*c]const u8,
    sep: [*c]const u8,
    root_sep: [*c]const u8,
    symbol: [*c]const u8,
    use_low_id: bool,
    add: [32]ecs_id_t,
    add_expr: [*c]const u8,
};
pub const ecs_entity_desc_t = struct_ecs_entity_desc_t;
pub const struct_ecs_bulk_desc_t = extern struct {
    _canary: i32,
    entities: [*c]ecs_entity_t,
    count: i32,
    ids: [32]ecs_id_t,
    data: [*c]?*anyopaque,
    table: ?*ecs_table_t,
};
pub const ecs_bulk_desc_t = struct_ecs_bulk_desc_t;
pub const struct_ecs_component_desc_t = extern struct {
    _canary: i32,
    entity: ecs_entity_t,
    type: ecs_type_info_t,
};
pub const ecs_component_desc_t = struct_ecs_component_desc_t;
pub const struct_ecs_filter_desc_t = extern struct {
    _canary: i32,
    terms: [16]ecs_term_t,
    terms_buffer: [*c]ecs_term_t,
    terms_buffer_count: i32,
    storage: [*c]ecs_filter_t,
    instanced: bool,
    flags: ecs_flags32_t,
    expr: [*c]const u8,
    entity: ecs_entity_t,
};
pub const ecs_filter_desc_t = struct_ecs_filter_desc_t;
pub const struct_ecs_query_desc_t = extern struct {
    _canary: i32,
    filter: ecs_filter_desc_t,
    order_by_component: ecs_entity_t,
    order_by: ecs_order_by_action_t,
    sort_table: ecs_sort_table_action_t,
    group_by_id: ecs_id_t,
    group_by: ecs_group_by_action_t,
    on_group_create: ecs_group_create_action_t,
    on_group_delete: ecs_group_delete_action_t,
    group_by_ctx: ?*anyopaque,
    group_by_ctx_free: ecs_ctx_free_t,
    parent: ?*ecs_query_t,
    ctx: ?*anyopaque,
    binding_ctx: ?*anyopaque,
    ctx_free: ecs_ctx_free_t,
    binding_ctx_free: ecs_ctx_free_t,
};
pub const ecs_query_desc_t = struct_ecs_query_desc_t;
pub const struct_ecs_observer_desc_t = extern struct {
    _canary: i32,
    entity: ecs_entity_t,
    filter: ecs_filter_desc_t,
    events: [8]ecs_entity_t,
    yield_existing: bool,
    callback: ecs_iter_action_t,
    run: ecs_run_action_t,
    ctx: ?*anyopaque,
    binding_ctx: ?*anyopaque,
    ctx_free: ecs_ctx_free_t,
    binding_ctx_free: ecs_ctx_free_t,
    observable: ?*ecs_poly_t,
    last_event_id: [*c]i32,
    term_index: i32,
};
pub const ecs_observer_desc_t = struct_ecs_observer_desc_t;
pub const struct_ecs_event_desc_t = extern struct {
    event: ecs_entity_t,
    ids: [*c]const ecs_type_t,
    table: ?*ecs_table_t,
    other_table: ?*ecs_table_t,
    offset: i32,
    count: i32,
    entity: ecs_entity_t,
    param: ?*const anyopaque,
    observable: ?*ecs_poly_t,
    flags: ecs_flags32_t,
};
pub const ecs_event_desc_t = struct_ecs_event_desc_t;
pub const struct_ecs_value_t = extern struct {
    type: ecs_entity_t,
    ptr: ?*anyopaque,
};
pub const ecs_value_t = struct_ecs_value_t;
const struct_unnamed_2 = extern struct {
    add_count: i64,
    remove_count: i64,
    delete_count: i64,
    clear_count: i64,
    set_count: i64,
    get_mut_count: i64,
    modified_count: i64,
    other_count: i64,
    discard_count: i64,
    batched_entity_count: i64,
    batched_command_count: i64,
};
pub const struct_ecs_world_info_t = extern struct {
    last_component_id: ecs_entity_t,
    min_id: ecs_entity_t,
    max_id: ecs_entity_t,
    delta_time_raw: f32,
    delta_time: f32,
    time_scale: f32,
    target_fps: f32,
    frame_time_total: f32,
    system_time_total: f32,
    emit_time_total: f32,
    merge_time_total: f32,
    world_time_total: f32,
    world_time_total_raw: f32,
    rematch_time_total: f32,
    frame_count_total: i64,
    merge_count_total: i64,
    rematch_count_total: i64,
    id_create_total: i64,
    id_delete_total: i64,
    table_create_total: i64,
    table_delete_total: i64,
    pipeline_build_count_total: i64,
    systems_ran_frame: i64,
    observers_ran_frame: i64,
    id_count: i32,
    tag_id_count: i32,
    component_id_count: i32,
    pair_id_count: i32,
    wildcard_id_count: i32,
    table_count: i32,
    tag_table_count: i32,
    trivial_table_count: i32,
    empty_table_count: i32,
    table_record_count: i32,
    table_storage_count: i32,
    cmd: struct_unnamed_2,
    name_prefix: [*c]const u8,
};
pub const ecs_world_info_t = struct_ecs_world_info_t;
pub const struct_ecs_query_group_info_t = extern struct {
    match_count: i32,
    table_count: i32,
    ctx: ?*anyopaque,
};
pub const ecs_query_group_info_t = struct_ecs_query_group_info_t;
pub const struct_EcsIdentifier = extern struct {
    value: [*c]u8,
    length: ecs_size_t,
    hash: u64,
    index_hash: u64,
    index: [*c]ecs_hashmap_t,
};
pub const EcsIdentifier = struct_EcsIdentifier;
pub const struct_EcsComponent = extern struct {
    size: ecs_size_t,
    alignment: ecs_size_t,
};
pub const EcsComponent = struct_EcsComponent;
pub const struct_EcsPoly = extern struct {
    poly: ?*ecs_poly_t,
};
pub const EcsPoly = struct_EcsPoly;
pub const struct_EcsTarget = extern struct {
    count: i32,
    target: [*c]ecs_record_t,
};
pub const EcsTarget = struct_EcsTarget;
pub const EcsIterable = ecs_iterable_t;
pub extern const ECS_PAIR: ecs_id_t;
pub extern const ECS_OVERRIDE: ecs_id_t;
pub extern const ECS_TOGGLE: ecs_id_t;
pub extern const ECS_AND: ecs_id_t;
pub extern const FLECS_IDEcsComponentID_: ecs_entity_t;
pub extern const FLECS_IDEcsIdentifierID_: ecs_entity_t;
pub extern const FLECS_IDEcsIterableID_: ecs_entity_t;
pub extern const FLECS_IDEcsPolyID_: ecs_entity_t;
pub extern const EcsQuery: ecs_entity_t;
pub extern const EcsObserver: ecs_entity_t;
pub extern const EcsSystem: ecs_entity_t;
pub extern const FLECS_IDEcsTickSourceID_: ecs_entity_t;
pub extern const FLECS_IDEcsPipelineQueryID_: ecs_entity_t;
pub extern const FLECS_IDEcsTimerID_: ecs_entity_t;
pub extern const FLECS_IDEcsRateFilterID_: ecs_entity_t;
pub extern const EcsFlecs: ecs_entity_t;
pub extern const EcsFlecsCore: ecs_entity_t;
pub extern const EcsWorld: ecs_entity_t;
pub extern const EcsWildcard: ecs_entity_t;
pub extern const EcsAny: ecs_entity_t;
pub extern const EcsThis: ecs_entity_t;
pub extern const EcsVariable: ecs_entity_t;
pub extern const EcsTransitive: ecs_entity_t;
pub extern const EcsReflexive: ecs_entity_t;
pub extern const EcsFinal: ecs_entity_t;
pub extern const EcsDontInherit: ecs_entity_t;
pub extern const EcsAlwaysOverride: ecs_entity_t;
pub extern const EcsSymmetric: ecs_entity_t;
pub extern const EcsExclusive: ecs_entity_t;
pub extern const EcsAcyclic: ecs_entity_t;
pub extern const EcsTraversable: ecs_entity_t;
pub extern const EcsWith: ecs_entity_t;
pub extern const EcsOneOf: ecs_entity_t;
pub extern const EcsTag: ecs_entity_t;
pub extern const EcsUnion: ecs_entity_t;
pub extern const EcsName: ecs_entity_t;
pub extern const EcsSymbol: ecs_entity_t;
pub extern const EcsAlias: ecs_entity_t;
pub extern const EcsChildOf: ecs_entity_t;
pub extern const EcsIsA: ecs_entity_t;
pub extern const EcsDependsOn: ecs_entity_t;
pub extern const EcsSlotOf: ecs_entity_t;
pub extern const EcsModule: ecs_entity_t;
pub extern const EcsPrivate: ecs_entity_t;
pub extern const EcsPrefab: ecs_entity_t;
pub extern const EcsDisabled: ecs_entity_t;
pub extern const EcsOnAdd: ecs_entity_t;
pub extern const EcsOnRemove: ecs_entity_t;
pub extern const EcsOnSet: ecs_entity_t;
pub extern const EcsUnSet: ecs_entity_t;
pub extern const EcsMonitor: ecs_entity_t;
pub extern const EcsOnTableCreate: ecs_entity_t;
pub extern const EcsOnTableDelete: ecs_entity_t;
pub extern const EcsOnTableEmpty: ecs_entity_t;
pub extern const EcsOnTableFill: ecs_entity_t;
pub extern const EcsOnDelete: ecs_entity_t;
pub extern const EcsOnDeleteTarget: ecs_entity_t;
pub extern const EcsRemove: ecs_entity_t;
pub extern const EcsDelete: ecs_entity_t;
pub extern const EcsPanic: ecs_entity_t;
pub extern const FLECS_IDEcsTargetID_: ecs_entity_t;
pub extern const EcsFlatten: ecs_entity_t;
pub extern const EcsDefaultChildComponent: ecs_entity_t;
pub extern const EcsPredEq: ecs_entity_t;
pub extern const EcsPredMatch: ecs_entity_t;
pub extern const EcsPredLookup: ecs_entity_t;
pub extern const EcsScopeOpen: ecs_entity_t;
pub extern const EcsScopeClose: ecs_entity_t;
pub extern const EcsEmpty: ecs_entity_t;
pub extern const FLECS_IDEcsPipelineID_: ecs_entity_t;
pub extern const EcsOnStart: ecs_entity_t;
pub extern const EcsPreFrame: ecs_entity_t;
pub extern const EcsOnLoad: ecs_entity_t;
pub extern const EcsPostLoad: ecs_entity_t;
pub extern const EcsPreUpdate: ecs_entity_t;
pub extern const EcsOnUpdate: ecs_entity_t;
pub extern const EcsOnValidate: ecs_entity_t;
pub extern const EcsPostUpdate: ecs_entity_t;
pub extern const EcsPreStore: ecs_entity_t;
pub extern const EcsOnStore: ecs_entity_t;
pub extern const EcsPostFrame: ecs_entity_t;
pub extern const EcsPhase: ecs_entity_t;
pub extern fn ecs_init() ?*ecs_world_t;
pub extern fn ecs_mini() ?*ecs_world_t;
pub extern fn ecs_init_w_args(argc: c_int, argv: [*c][*c]u8) ?*ecs_world_t;
pub extern fn ecs_fini(world: ?*ecs_world_t) c_int;
pub extern fn ecs_is_fini(world: ?*const ecs_world_t) bool;
pub extern fn ecs_atfini(world: ?*ecs_world_t, action: ecs_fini_action_t, ctx: ?*anyopaque) void;
pub extern fn ecs_frame_begin(world: ?*ecs_world_t, delta_time: f32) f32;
pub extern fn ecs_frame_end(world: ?*ecs_world_t) void;
pub extern fn ecs_run_post_frame(world: ?*ecs_world_t, action: ecs_fini_action_t, ctx: ?*anyopaque) void;
pub extern fn ecs_quit(world: ?*ecs_world_t) void;
pub extern fn ecs_should_quit(world: ?*const ecs_world_t) bool;
pub extern fn ecs_measure_frame_time(world: ?*ecs_world_t, enable: bool) void;
pub extern fn ecs_measure_system_time(world: ?*ecs_world_t, enable: bool) void;
pub extern fn ecs_set_target_fps(world: ?*ecs_world_t, fps: f32) void;
pub extern fn ecs_readonly_begin(world: ?*ecs_world_t) bool;
pub extern fn ecs_readonly_end(world: ?*ecs_world_t) void;
pub extern fn ecs_merge(world: ?*ecs_world_t) void;
pub extern fn ecs_defer_begin(world: ?*ecs_world_t) bool;
pub extern fn ecs_is_deferred(world: ?*const ecs_world_t) bool;
pub extern fn ecs_defer_end(world: ?*ecs_world_t) bool;
pub extern fn ecs_defer_suspend(world: ?*ecs_world_t) void;
pub extern fn ecs_defer_resume(world: ?*ecs_world_t) void;
pub extern fn ecs_set_automerge(world: ?*ecs_world_t, automerge: bool) void;
pub extern fn ecs_set_stage_count(world: ?*ecs_world_t, stages: i32) void;
pub extern fn ecs_get_stage_count(world: ?*const ecs_world_t) i32;
pub extern fn ecs_get_stage_id(world: ?*const ecs_world_t) i32;
pub extern fn ecs_get_stage(world: ?*const ecs_world_t, stage_id: i32) ?*ecs_world_t;
pub extern fn ecs_stage_is_readonly(world: ?*const ecs_world_t) bool;
pub extern fn ecs_async_stage_new(world: ?*ecs_world_t) ?*ecs_world_t;
pub extern fn ecs_async_stage_free(stage: ?*ecs_world_t) void;
pub extern fn ecs_stage_is_async(stage: ?*ecs_world_t) bool;
pub extern fn ecs_set_ctx(world: ?*ecs_world_t, ctx: ?*anyopaque, ctx_free: ecs_ctx_free_t) void;
pub extern fn ecs_set_binding_ctx(world: ?*ecs_world_t, ctx: ?*anyopaque, ctx_free: ecs_ctx_free_t) void;
pub extern fn ecs_get_ctx(world: ?*const ecs_world_t) ?*anyopaque;
pub extern fn ecs_get_binding_ctx(world: ?*const ecs_world_t) ?*anyopaque;
pub extern fn ecs_get_world_info(world: ?*const ecs_world_t) [*c]const ecs_world_info_t;
pub extern fn ecs_dim(world: ?*ecs_world_t, entity_count: i32) void;
pub extern fn ecs_set_entity_range(world: ?*ecs_world_t, id_start: ecs_entity_t, id_end: ecs_entity_t) void;
pub extern fn ecs_enable_range_check(world: ?*ecs_world_t, enable: bool) bool;
pub extern fn ecs_get_max_id(world: ?*const ecs_world_t) ecs_entity_t;
pub extern fn ecs_run_aperiodic(world: ?*ecs_world_t, flags: ecs_flags32_t) void;
pub extern fn ecs_delete_empty_tables(world: ?*ecs_world_t, id: ecs_id_t, clear_generation: u16, delete_generation: u16, min_id_count: i32, time_budget_seconds: f64) i32;
pub extern fn ecs_get_world(poly: ?*const ecs_poly_t) ?*const ecs_world_t;
pub extern fn ecs_get_entity(poly: ?*const ecs_poly_t) ecs_entity_t;
pub extern fn ecs_poly_is_(object: ?*const ecs_poly_t, @"type": i32) bool;
pub extern fn ecs_make_pair(first: ecs_entity_t, second: ecs_entity_t) ecs_id_t;
pub extern fn ecs_new_id(world: ?*ecs_world_t) ecs_entity_t;
pub extern fn ecs_new_low_id(world: ?*ecs_world_t) ecs_entity_t;
pub extern fn ecs_new_w_id(world: ?*ecs_world_t, id: ecs_id_t) ecs_entity_t;
pub extern fn ecs_new_w_table(world: ?*ecs_world_t, table: ?*ecs_table_t) ecs_entity_t;
pub extern fn ecs_entity_init(world: ?*ecs_world_t, desc: [*c]const ecs_entity_desc_t) ecs_entity_t;
pub extern fn ecs_bulk_init(world: ?*ecs_world_t, desc: [*c]const ecs_bulk_desc_t) [*c]const ecs_entity_t;
pub extern fn ecs_bulk_new_w_id(world: ?*ecs_world_t, id: ecs_id_t, count: i32) [*c]const ecs_entity_t;
pub extern fn ecs_clone(world: ?*ecs_world_t, dst: ecs_entity_t, src: ecs_entity_t, copy_value: bool) ecs_entity_t;
pub extern fn ecs_delete(world: ?*ecs_world_t, entity: ecs_entity_t) void;
pub extern fn ecs_delete_with(world: ?*ecs_world_t, id: ecs_id_t) void;
pub extern fn ecs_add_id(world: ?*ecs_world_t, entity: ecs_entity_t, id: ecs_id_t) void;
pub extern fn ecs_remove_id(world: ?*ecs_world_t, entity: ecs_entity_t, id: ecs_id_t) void;
pub extern fn ecs_override_id(world: ?*ecs_world_t, entity: ecs_entity_t, id: ecs_id_t) void;
pub extern fn ecs_clear(world: ?*ecs_world_t, entity: ecs_entity_t) void;
pub extern fn ecs_remove_all(world: ?*ecs_world_t, id: ecs_id_t) void;
pub extern fn ecs_set_with(world: ?*ecs_world_t, id: ecs_id_t) ecs_entity_t;
pub extern fn ecs_get_with(world: ?*const ecs_world_t) ecs_id_t;
pub extern fn ecs_enable(world: ?*ecs_world_t, entity: ecs_entity_t, enabled: bool) void;
pub extern fn ecs_enable_id(world: ?*ecs_world_t, entity: ecs_entity_t, id: ecs_id_t, enable: bool) void;
pub extern fn ecs_is_enabled_id(world: ?*const ecs_world_t, entity: ecs_entity_t, id: ecs_id_t) bool;
pub extern fn ecs_get_id(world: ?*const ecs_world_t, entity: ecs_entity_t, id: ecs_id_t) ?*const anyopaque;
pub extern fn ecs_ref_init_id(world: ?*const ecs_world_t, entity: ecs_entity_t, id: ecs_id_t) ecs_ref_t;
pub extern fn ecs_ref_get_id(world: ?*const ecs_world_t, ref: [*c]ecs_ref_t, id: ecs_id_t) ?*anyopaque;
pub extern fn ecs_ref_update(world: ?*const ecs_world_t, ref: [*c]ecs_ref_t) void;
pub extern fn ecs_get_mut_id(world: ?*ecs_world_t, entity: ecs_entity_t, id: ecs_id_t) ?*anyopaque;
pub extern fn ecs_get_mut_modified_id(world: ?*ecs_world_t, entity: ecs_entity_t, id: ecs_id_t) ?*anyopaque;
pub extern fn ecs_write_begin(world: ?*ecs_world_t, entity: ecs_entity_t) [*c]ecs_record_t;
pub extern fn ecs_write_end(record: [*c]ecs_record_t) void;
pub extern fn ecs_read_begin(world: ?*ecs_world_t, entity: ecs_entity_t) [*c]const ecs_record_t;
pub extern fn ecs_read_end(record: [*c]const ecs_record_t) void;
pub extern fn ecs_record_get_entity(record: [*c]const ecs_record_t) ecs_entity_t;
pub extern fn ecs_record_get_id(world: ?*ecs_world_t, record: [*c]const ecs_record_t, id: ecs_id_t) ?*const anyopaque;
pub extern fn ecs_record_get_mut_id(world: ?*ecs_world_t, record: [*c]ecs_record_t, id: ecs_id_t) ?*anyopaque;
pub extern fn ecs_record_has_id(world: ?*ecs_world_t, record: [*c]const ecs_record_t, id: ecs_id_t) bool;
pub extern fn ecs_emplace_id(world: ?*ecs_world_t, entity: ecs_entity_t, id: ecs_id_t) ?*anyopaque;
pub extern fn ecs_modified_id(world: ?*ecs_world_t, entity: ecs_entity_t, id: ecs_id_t) void;
pub extern fn ecs_set_id(world: ?*ecs_world_t, entity: ecs_entity_t, id: ecs_id_t, size: usize, ptr: ?*const anyopaque) ecs_entity_t;
pub extern fn ecs_is_valid(world: ?*const ecs_world_t, e: ecs_entity_t) bool;
pub extern fn ecs_is_alive(world: ?*const ecs_world_t, e: ecs_entity_t) bool;
pub extern fn ecs_strip_generation(e: ecs_entity_t) ecs_id_t;
pub extern fn ecs_set_entity_generation(world: ?*ecs_world_t, entity: ecs_entity_t) void;
pub extern fn ecs_get_alive(world: ?*const ecs_world_t, e: ecs_entity_t) ecs_entity_t;
pub extern fn ecs_ensure(world: ?*ecs_world_t, entity: ecs_entity_t) void;
pub extern fn ecs_ensure_id(world: ?*ecs_world_t, id: ecs_id_t) void;
pub extern fn ecs_exists(world: ?*const ecs_world_t, entity: ecs_entity_t) bool;
pub extern fn ecs_get_type(world: ?*const ecs_world_t, entity: ecs_entity_t) [*c]const ecs_type_t;
pub extern fn ecs_get_table(world: ?*const ecs_world_t, entity: ecs_entity_t) ?*ecs_table_t;
pub extern fn ecs_type_str(world: ?*const ecs_world_t, @"type": [*c]const ecs_type_t) [*c]u8;
pub extern fn ecs_table_str(world: ?*const ecs_world_t, table: ?*const ecs_table_t) [*c]u8;
pub extern fn ecs_entity_str(world: ?*const ecs_world_t, entity: ecs_entity_t) [*c]u8;
pub extern fn ecs_has_id(world: ?*const ecs_world_t, entity: ecs_entity_t, id: ecs_id_t) bool;
pub extern fn ecs_owns_id(world: ?*const ecs_world_t, entity: ecs_entity_t, id: ecs_id_t) bool;
pub extern fn ecs_get_target(world: ?*const ecs_world_t, entity: ecs_entity_t, rel: ecs_entity_t, index: i32) ecs_entity_t;
pub extern fn ecs_get_parent(world: ?*const ecs_world_t, entity: ecs_entity_t) ecs_entity_t;
pub extern fn ecs_get_target_for_id(world: ?*const ecs_world_t, entity: ecs_entity_t, rel: ecs_entity_t, id: ecs_id_t) ecs_entity_t;
pub extern fn ecs_get_depth(world: ?*const ecs_world_t, entity: ecs_entity_t, rel: ecs_entity_t) i32;
pub const struct_ecs_flatten_desc_t = extern struct {
    keep_names: bool,
    lose_depth: bool,
};
pub const ecs_flatten_desc_t = struct_ecs_flatten_desc_t;
pub extern fn ecs_flatten(world: ?*ecs_world_t, pair: ecs_id_t, desc: [*c]const ecs_flatten_desc_t) void;
pub extern fn ecs_count_id(world: ?*const ecs_world_t, entity: ecs_id_t) i32;
pub extern fn ecs_get_name(world: ?*const ecs_world_t, entity: ecs_entity_t) [*c]const u8;
pub extern fn ecs_get_symbol(world: ?*const ecs_world_t, entity: ecs_entity_t) [*c]const u8;
pub extern fn ecs_set_name(world: ?*ecs_world_t, entity: ecs_entity_t, name: [*c]const u8) ecs_entity_t;
pub extern fn ecs_set_symbol(world: ?*ecs_world_t, entity: ecs_entity_t, symbol: [*c]const u8) ecs_entity_t;
pub extern fn ecs_set_alias(world: ?*ecs_world_t, entity: ecs_entity_t, alias: [*c]const u8) void;
pub extern fn ecs_lookup(world: ?*const ecs_world_t, name: [*c]const u8) ecs_entity_t;
pub extern fn ecs_lookup_child(world: ?*const ecs_world_t, parent: ecs_entity_t, name: [*c]const u8) ecs_entity_t;
pub extern fn ecs_lookup_path_w_sep(world: ?*const ecs_world_t, parent: ecs_entity_t, path: [*c]const u8, sep: [*c]const u8, prefix: [*c]const u8, recursive: bool) ecs_entity_t;
pub extern fn ecs_lookup_symbol(world: ?*const ecs_world_t, symbol: [*c]const u8, lookup_as_path: bool, recursive: bool) ecs_entity_t;
pub extern fn ecs_get_path_w_sep(world: ?*const ecs_world_t, parent: ecs_entity_t, child: ecs_entity_t, sep: [*c]const u8, prefix: [*c]const u8) [*c]u8;
pub extern fn ecs_get_path_w_sep_buf(world: ?*const ecs_world_t, parent: ecs_entity_t, child: ecs_entity_t, sep: [*c]const u8, prefix: [*c]const u8, buf: [*c]ecs_strbuf_t) void;
pub extern fn ecs_new_from_path_w_sep(world: ?*ecs_world_t, parent: ecs_entity_t, path: [*c]const u8, sep: [*c]const u8, prefix: [*c]const u8) ecs_entity_t;
pub extern fn ecs_add_path_w_sep(world: ?*ecs_world_t, entity: ecs_entity_t, parent: ecs_entity_t, path: [*c]const u8, sep: [*c]const u8, prefix: [*c]const u8) ecs_entity_t;
pub extern fn ecs_set_scope(world: ?*ecs_world_t, scope: ecs_entity_t) ecs_entity_t;
pub extern fn ecs_get_scope(world: ?*const ecs_world_t) ecs_entity_t;
pub extern fn ecs_set_name_prefix(world: ?*ecs_world_t, prefix: [*c]const u8) [*c]const u8;
pub extern fn ecs_set_lookup_path(world: ?*ecs_world_t, lookup_path: [*c]const ecs_entity_t) [*c]ecs_entity_t;
pub extern fn ecs_get_lookup_path(world: ?*const ecs_world_t) [*c]ecs_entity_t;
pub extern fn ecs_component_init(world: ?*ecs_world_t, desc: [*c]const ecs_component_desc_t) ecs_entity_t;
pub extern fn ecs_get_type_info(world: ?*const ecs_world_t, id: ecs_id_t) [*c]const ecs_type_info_t;
pub extern fn ecs_set_hooks_id(world: ?*ecs_world_t, id: ecs_entity_t, hooks: [*c]const ecs_type_hooks_t) void;
pub extern fn ecs_get_hooks_id(world: ?*ecs_world_t, id: ecs_entity_t) [*c]const ecs_type_hooks_t;
pub extern fn ecs_id_is_tag(world: ?*const ecs_world_t, id: ecs_id_t) bool;
pub extern fn ecs_id_is_union(world: ?*const ecs_world_t, id: ecs_id_t) bool;
pub extern fn ecs_id_in_use(world: ?*const ecs_world_t, id: ecs_id_t) bool;
pub extern fn ecs_get_typeid(world: ?*const ecs_world_t, id: ecs_id_t) ecs_entity_t;
pub extern fn ecs_id_match(id: ecs_id_t, pattern: ecs_id_t) bool;
pub extern fn ecs_id_is_pair(id: ecs_id_t) bool;
pub extern fn ecs_id_is_wildcard(id: ecs_id_t) bool;
pub extern fn ecs_id_is_valid(world: ?*const ecs_world_t, id: ecs_id_t) bool;
pub extern fn ecs_id_get_flags(world: ?*const ecs_world_t, id: ecs_id_t) ecs_flags32_t;
pub extern fn ecs_id_flag_str(id_flags: ecs_id_t) [*c]const u8;
pub extern fn ecs_id_str(world: ?*const ecs_world_t, id: ecs_id_t) [*c]u8;
pub extern fn ecs_id_str_buf(world: ?*const ecs_world_t, id: ecs_id_t, buf: [*c]ecs_strbuf_t) void;
pub extern fn ecs_term_iter(world: ?*const ecs_world_t, term: [*c]ecs_term_t) ecs_iter_t;
pub extern fn ecs_term_chain_iter(it: [*c]const ecs_iter_t, term: [*c]ecs_term_t) ecs_iter_t;
pub extern fn ecs_term_next(it: [*c]ecs_iter_t) bool;
pub extern fn ecs_children(world: ?*const ecs_world_t, parent: ecs_entity_t) ecs_iter_t;
pub extern fn ecs_children_next(it: [*c]ecs_iter_t) bool;
pub extern fn ecs_term_id_is_set(id: [*c]const ecs_term_id_t) bool;
pub extern fn ecs_term_is_initialized(term: [*c]const ecs_term_t) bool;
pub extern fn ecs_term_match_this(term: [*c]const ecs_term_t) bool;
pub extern fn ecs_term_match_0(term: [*c]const ecs_term_t) bool;
pub extern fn ecs_term_finalize(world: ?*const ecs_world_t, term: [*c]ecs_term_t) c_int;
pub extern fn ecs_term_copy(src: [*c]const ecs_term_t) ecs_term_t;
pub extern fn ecs_term_move(src: [*c]ecs_term_t) ecs_term_t;
pub extern fn ecs_term_fini(term: [*c]ecs_term_t) void;
pub extern fn ecs_filter_init(world: ?*ecs_world_t, desc: [*c]const ecs_filter_desc_t) [*c]ecs_filter_t;
pub extern fn ecs_filter_fini(filter: [*c]ecs_filter_t) void;
pub extern fn ecs_filter_finalize(world: ?*const ecs_world_t, filter: [*c]ecs_filter_t) c_int;
pub extern fn ecs_filter_find_this_var(filter: [*c]const ecs_filter_t) i32;
pub extern fn ecs_term_str(world: ?*const ecs_world_t, term: [*c]const ecs_term_t) [*c]u8;
pub extern fn ecs_filter_str(world: ?*const ecs_world_t, filter: [*c]const ecs_filter_t) [*c]u8;
pub extern fn ecs_filter_iter(world: ?*const ecs_world_t, filter: [*c]const ecs_filter_t) ecs_iter_t;
pub extern fn ecs_filter_chain_iter(it: [*c]const ecs_iter_t, filter: [*c]const ecs_filter_t) ecs_iter_t;
pub extern fn ecs_filter_pivot_term(world: ?*const ecs_world_t, filter: [*c]const ecs_filter_t) i32;
pub extern fn ecs_filter_next(it: [*c]ecs_iter_t) bool;
pub extern fn ecs_filter_next_instanced(it: [*c]ecs_iter_t) bool;
pub extern fn ecs_filter_move(dst: [*c]ecs_filter_t, src: [*c]ecs_filter_t) void;
pub extern fn ecs_filter_copy(dst: [*c]ecs_filter_t, src: [*c]const ecs_filter_t) void;
pub extern fn ecs_query_init(world: ?*ecs_world_t, desc: [*c]const ecs_query_desc_t) ?*ecs_query_t;
pub extern fn ecs_query_fini(query: ?*ecs_query_t) void;
pub extern fn ecs_query_get_filter(query: ?*const ecs_query_t) [*c]const ecs_filter_t;
pub extern fn ecs_query_iter(world: ?*const ecs_world_t, query: ?*ecs_query_t) ecs_iter_t;
pub extern fn ecs_query_next(iter: [*c]ecs_iter_t) bool;
pub extern fn ecs_query_next_instanced(iter: [*c]ecs_iter_t) bool;
pub extern fn ecs_query_next_table(iter: [*c]ecs_iter_t) bool;
pub extern fn ecs_query_populate(iter: [*c]ecs_iter_t, when_changed: bool) c_int;
pub extern fn ecs_query_changed(query: ?*ecs_query_t, it: [*c]const ecs_iter_t) bool;
pub extern fn ecs_query_skip(it: [*c]ecs_iter_t) void;
pub extern fn ecs_query_set_group(it: [*c]ecs_iter_t, group_id: u64) void;
pub extern fn ecs_query_get_group_ctx(query: ?*const ecs_query_t, group_id: u64) ?*anyopaque;
pub extern fn ecs_query_get_group_info(query: ?*const ecs_query_t, group_id: u64) [*c]const ecs_query_group_info_t;
pub extern fn ecs_query_orphaned(query: ?*const ecs_query_t) bool;
pub extern fn ecs_query_str(query: ?*const ecs_query_t) [*c]u8;
pub extern fn ecs_query_table_count(query: ?*const ecs_query_t) i32;
pub extern fn ecs_query_empty_table_count(query: ?*const ecs_query_t) i32;
pub extern fn ecs_query_entity_count(query: ?*const ecs_query_t) i32;
pub extern fn ecs_query_get_ctx(query: ?*const ecs_query_t) ?*anyopaque;
pub extern fn ecs_query_get_binding_ctx(query: ?*const ecs_query_t) ?*anyopaque;
pub extern fn ecs_emit(world: ?*ecs_world_t, desc: [*c]ecs_event_desc_t) void;
pub extern fn ecs_observer_init(world: ?*ecs_world_t, desc: [*c]const ecs_observer_desc_t) ecs_entity_t;
pub extern fn ecs_observer_default_run_action(it: [*c]ecs_iter_t) bool;
pub extern fn ecs_observer_get_ctx(world: ?*const ecs_world_t, observer: ecs_entity_t) ?*anyopaque;
pub extern fn ecs_observer_get_binding_ctx(world: ?*const ecs_world_t, observer: ecs_entity_t) ?*anyopaque;
pub extern fn ecs_iter_poly(world: ?*const ecs_world_t, poly: ?*const ecs_poly_t, iter: [*c]ecs_iter_t, filter: [*c]ecs_term_t) void;
pub extern fn ecs_iter_next(it: [*c]ecs_iter_t) bool;
pub extern fn ecs_iter_fini(it: [*c]ecs_iter_t) void;
pub extern fn ecs_iter_count(it: [*c]ecs_iter_t) i32;
pub extern fn ecs_iter_is_true(it: [*c]ecs_iter_t) bool;
pub extern fn ecs_iter_first(it: [*c]ecs_iter_t) ecs_entity_t;
pub extern fn ecs_iter_set_var(it: [*c]ecs_iter_t, var_id: i32, entity: ecs_entity_t) void;
pub extern fn ecs_iter_set_var_as_table(it: [*c]ecs_iter_t, var_id: i32, table: ?*const ecs_table_t) void;
pub extern fn ecs_iter_set_var_as_range(it: [*c]ecs_iter_t, var_id: i32, range: [*c]const ecs_table_range_t) void;
pub extern fn ecs_iter_get_var(it: [*c]ecs_iter_t, var_id: i32) ecs_entity_t;
pub extern fn ecs_iter_get_var_as_table(it: [*c]ecs_iter_t, var_id: i32) ?*ecs_table_t;
pub extern fn ecs_iter_get_var_as_range(it: [*c]ecs_iter_t, var_id: i32) ecs_table_range_t;
pub extern fn ecs_iter_var_is_constrained(it: [*c]ecs_iter_t, var_id: i32) bool;
pub extern fn ecs_iter_str(it: [*c]const ecs_iter_t) [*c]u8;
pub extern fn ecs_page_iter(it: [*c]const ecs_iter_t, offset: i32, limit: i32) ecs_iter_t;
pub extern fn ecs_page_next(it: [*c]ecs_iter_t) bool;
pub extern fn ecs_worker_iter(it: [*c]const ecs_iter_t, index: i32, count: i32) ecs_iter_t;
pub extern fn ecs_worker_next(it: [*c]ecs_iter_t) bool;
pub extern fn ecs_field_w_size(it: [*c]const ecs_iter_t, size: usize, index: i32) ?*anyopaque;
pub extern fn ecs_field_is_readonly(it: [*c]const ecs_iter_t, index: i32) bool;
pub extern fn ecs_field_is_writeonly(it: [*c]const ecs_iter_t, index: i32) bool;
pub extern fn ecs_field_is_set(it: [*c]const ecs_iter_t, index: i32) bool;
pub extern fn ecs_field_id(it: [*c]const ecs_iter_t, index: i32) ecs_id_t;
pub extern fn ecs_field_column_index(it: [*c]const ecs_iter_t, index: i32) i32;
pub extern fn ecs_field_src(it: [*c]const ecs_iter_t, index: i32) ecs_entity_t;
pub extern fn ecs_field_size(it: [*c]const ecs_iter_t, index: i32) usize;
pub extern fn ecs_field_is_self(it: [*c]const ecs_iter_t, index: i32) bool;
pub extern fn ecs_table_get_type(table: ?*const ecs_table_t) [*c]const ecs_type_t;
pub extern fn ecs_table_get_type_index(world: ?*const ecs_world_t, table: ?*const ecs_table_t, id: ecs_id_t) i32;
pub extern fn ecs_table_get_column_index(world: ?*const ecs_world_t, table: ?*const ecs_table_t, id: ecs_id_t) i32;
pub extern fn ecs_table_column_count(table: ?*const ecs_table_t) i32;
pub extern fn ecs_table_type_to_column_index(table: ?*const ecs_table_t, index: i32) i32;
pub extern fn ecs_table_column_to_type_index(table: ?*const ecs_table_t, index: i32) i32;
pub extern fn ecs_table_get_column(table: ?*const ecs_table_t, index: i32, offset: i32) ?*anyopaque;
pub extern fn ecs_table_get_id(world: ?*const ecs_world_t, table: ?*const ecs_table_t, id: ecs_id_t, offset: i32) ?*anyopaque;
pub extern fn ecs_table_get_column_size(table: ?*const ecs_table_t, index: i32) usize;
pub extern fn ecs_table_count(table: ?*const ecs_table_t) i32;
pub extern fn ecs_table_has_id(world: ?*const ecs_world_t, table: ?*const ecs_table_t, id: ecs_id_t) bool;
pub extern fn ecs_table_get_depth(world: ?*const ecs_world_t, table: ?*const ecs_table_t, rel: ecs_entity_t) i32;
pub extern fn ecs_table_add_id(world: ?*ecs_world_t, table: ?*ecs_table_t, id: ecs_id_t) ?*ecs_table_t;
pub extern fn ecs_table_find(world: ?*ecs_world_t, ids: [*c]const ecs_id_t, id_count: i32) ?*ecs_table_t;
pub extern fn ecs_table_remove_id(world: ?*ecs_world_t, table: ?*ecs_table_t, id: ecs_id_t) ?*ecs_table_t;
pub extern fn ecs_table_lock(world: ?*ecs_world_t, table: ?*ecs_table_t) void;
pub extern fn ecs_table_unlock(world: ?*ecs_world_t, table: ?*ecs_table_t) void;
pub extern fn ecs_table_has_flags(table: ?*ecs_table_t, flags: ecs_flags32_t) bool;
pub extern fn ecs_table_swap_rows(world: ?*ecs_world_t, table: ?*ecs_table_t, row_1: i32, row_2: i32) void;
pub extern fn ecs_commit(world: ?*ecs_world_t, entity: ecs_entity_t, record: [*c]ecs_record_t, table: ?*ecs_table_t, added: [*c]const ecs_type_t, removed: [*c]const ecs_type_t) bool;
pub extern fn ecs_record_find(world: ?*const ecs_world_t, entity: ecs_entity_t) [*c]ecs_record_t;
pub extern fn ecs_record_get_column(r: [*c]const ecs_record_t, column: i32, c_size: usize) ?*anyopaque;
pub extern fn ecs_search(world: ?*const ecs_world_t, table: ?*const ecs_table_t, id: ecs_id_t, id_out: [*c]ecs_id_t) i32;
pub extern fn ecs_search_offset(world: ?*const ecs_world_t, table: ?*const ecs_table_t, offset: i32, id: ecs_id_t, id_out: [*c]ecs_id_t) i32;
pub extern fn ecs_search_relation(world: ?*const ecs_world_t, table: ?*const ecs_table_t, offset: i32, id: ecs_id_t, rel: ecs_entity_t, flags: ecs_flags32_t, subject_out: [*c]ecs_entity_t, id_out: [*c]ecs_id_t, tr_out: [*c]?*struct_ecs_table_record_t) i32;
pub extern fn ecs_value_init(world: ?*const ecs_world_t, @"type": ecs_entity_t, ptr: ?*anyopaque) c_int;
pub extern fn ecs_value_init_w_type_info(world: ?*const ecs_world_t, ti: [*c]const ecs_type_info_t, ptr: ?*anyopaque) c_int;
pub extern fn ecs_value_new(world: ?*ecs_world_t, @"type": ecs_entity_t) ?*anyopaque;
pub extern fn ecs_value_new_w_type_info(world: ?*ecs_world_t, ti: [*c]const ecs_type_info_t) ?*anyopaque;
pub extern fn ecs_value_fini_w_type_info(world: ?*const ecs_world_t, ti: [*c]const ecs_type_info_t, ptr: ?*anyopaque) c_int;
pub extern fn ecs_value_fini(world: ?*const ecs_world_t, @"type": ecs_entity_t, ptr: ?*anyopaque) c_int;
pub extern fn ecs_value_free(world: ?*ecs_world_t, @"type": ecs_entity_t, ptr: ?*anyopaque) c_int;
pub extern fn ecs_value_copy_w_type_info(world: ?*const ecs_world_t, ti: [*c]const ecs_type_info_t, dst: ?*anyopaque, src: ?*const anyopaque) c_int;
pub extern fn ecs_value_copy(world: ?*const ecs_world_t, @"type": ecs_entity_t, dst: ?*anyopaque, src: ?*const anyopaque) c_int;
pub extern fn ecs_value_move_w_type_info(world: ?*const ecs_world_t, ti: [*c]const ecs_type_info_t, dst: ?*anyopaque, src: ?*anyopaque) c_int;
pub extern fn ecs_value_move(world: ?*const ecs_world_t, @"type": ecs_entity_t, dst: ?*anyopaque, src: ?*anyopaque) c_int;
pub extern fn ecs_value_move_ctor_w_type_info(world: ?*const ecs_world_t, ti: [*c]const ecs_type_info_t, dst: ?*anyopaque, src: ?*anyopaque) c_int;
pub extern fn ecs_value_move_ctor(world: ?*const ecs_world_t, @"type": ecs_entity_t, dst: ?*anyopaque, src: ?*anyopaque) c_int;
pub extern fn ecs_deprecated_(file: [*c]const u8, line: i32, msg: [*c]const u8) void;
pub extern fn ecs_log_push_(level: i32) void;
pub extern fn ecs_log_pop_(level: i32) void;
pub extern fn ecs_should_log(level: i32) bool;
pub extern fn ecs_strerror(error_code: i32) [*c]const u8;
pub extern fn ecs_print_(level: i32, file: [*c]const u8, line: i32, fmt: [*c]const u8, ...) void;
pub extern fn ecs_printv_(level: c_int, file: [*c]const u8, line: i32, fmt: [*c]const u8, args: va_list) void;
pub extern fn ecs_log_(level: i32, file: [*c]const u8, line: i32, fmt: [*c]const u8, ...) void;
pub extern fn ecs_logv_(level: c_int, file: [*c]const u8, line: i32, fmt: [*c]const u8, args: va_list) void;
pub extern fn ecs_abort_(error_code: i32, file: [*c]const u8, line: i32, fmt: [*c]const u8, ...) void;
pub extern fn ecs_assert_(condition: bool, error_code: i32, condition_str: [*c]const u8, file: [*c]const u8, line: i32, fmt: [*c]const u8, ...) bool;
pub extern fn ecs_parser_error_(name: [*c]const u8, expr: [*c]const u8, column: i64, fmt: [*c]const u8, ...) void;
pub extern fn ecs_parser_errorv_(name: [*c]const u8, expr: [*c]const u8, column: i64, fmt: [*c]const u8, args: va_list) void;
pub extern fn ecs_log_set_level(level: c_int) c_int;
pub extern fn ecs_log_get_level() c_int;
pub extern fn ecs_log_enable_colors(enabled: bool) bool;
pub extern fn ecs_log_enable_timestamp(enabled: bool) bool;
pub extern fn ecs_log_enable_timedelta(enabled: bool) bool;
pub extern fn ecs_log_last_error() c_int;
pub const ecs_app_init_action_t = ?*const fn (?*ecs_world_t) callconv(.C) c_int;
pub const struct_ecs_app_desc_t = extern struct {
    target_fps: f32,
    delta_time: f32,
    threads: i32,
    frames: i32,
    enable_rest: bool,
    enable_monitor: bool,
    port: u16,
    init: ecs_app_init_action_t,
    ctx: ?*anyopaque,
};
pub const ecs_app_desc_t = struct_ecs_app_desc_t;
pub const ecs_app_run_action_t = ?*const fn (?*ecs_world_t, [*c]ecs_app_desc_t) callconv(.C) c_int;
pub const ecs_app_frame_action_t = ?*const fn (?*ecs_world_t, [*c]const ecs_app_desc_t) callconv(.C) c_int;
pub extern fn ecs_app_run(world: ?*ecs_world_t, desc: [*c]ecs_app_desc_t) c_int;
pub extern fn ecs_app_run_frame(world: ?*ecs_world_t, desc: [*c]const ecs_app_desc_t) c_int;
pub extern fn ecs_app_set_run_action(callback: ecs_app_run_action_t) c_int;
pub extern fn ecs_app_set_frame_action(callback: ecs_app_frame_action_t) c_int;
pub const struct_ecs_http_server_t = opaque {};
pub const ecs_http_server_t = struct_ecs_http_server_t;
pub const ecs_http_connection_t = extern struct {
    id: u64,
    server: ?*ecs_http_server_t,
    host: [128]u8,
    port: [16]u8,
};
pub const ecs_http_key_value_t = extern struct {
    key: [*c]const u8,
    value: [*c]const u8,
};
pub const EcsHttpGet: c_int = 0;
pub const EcsHttpPost: c_int = 1;
pub const EcsHttpPut: c_int = 2;
pub const EcsHttpDelete: c_int = 3;
pub const EcsHttpOptions: c_int = 4;
pub const EcsHttpMethodUnsupported: c_int = 5;
pub const ecs_http_method_t = c_uint;
pub const ecs_http_request_t = extern struct {
    id: u64,
    method: ecs_http_method_t,
    path: [*c]u8,
    body: [*c]u8,
    headers: [32]ecs_http_key_value_t,
    params: [32]ecs_http_key_value_t,
    header_count: i32,
    param_count: i32,
    conn: [*c]ecs_http_connection_t,
};
pub const ecs_http_reply_t = extern struct {
    code: c_int,
    body: ecs_strbuf_t,
    status: [*c]const u8,
    content_type: [*c]const u8,
    headers: ecs_strbuf_t,
};
pub extern var ecs_http_request_received_count: i64;
pub extern var ecs_http_request_invalid_count: i64;
pub extern var ecs_http_request_handled_ok_count: i64;
pub extern var ecs_http_request_handled_error_count: i64;
pub extern var ecs_http_request_not_handled_count: i64;
pub extern var ecs_http_request_preflight_count: i64;
pub extern var ecs_http_send_ok_count: i64;
pub extern var ecs_http_send_error_count: i64;
pub extern var ecs_http_busy_count: i64;
pub const ecs_http_reply_action_t = ?*const fn ([*c]const ecs_http_request_t, [*c]ecs_http_reply_t, ?*anyopaque) callconv(.C) bool;
pub const ecs_http_server_desc_t = extern struct {
    callback: ecs_http_reply_action_t,
    ctx: ?*anyopaque,
    port: u16,
    ipaddr: [*c]const u8,
    send_queue_wait_ms: i32,
};
pub extern fn ecs_http_server_init(desc: [*c]const ecs_http_server_desc_t) ?*ecs_http_server_t;
pub extern fn ecs_http_server_fini(server: ?*ecs_http_server_t) void;
pub extern fn ecs_http_server_start(server: ?*ecs_http_server_t) c_int;
pub extern fn ecs_http_server_dequeue(server: ?*ecs_http_server_t, delta_time: f32) void;
pub extern fn ecs_http_server_stop(server: ?*ecs_http_server_t) void;
pub extern fn ecs_http_server_http_request(srv: ?*ecs_http_server_t, req: [*c]const u8, len: ecs_size_t, reply_out: [*c]ecs_http_reply_t) c_int;
pub extern fn ecs_http_server_request(srv: ?*ecs_http_server_t, method: [*c]const u8, req: [*c]const u8, reply_out: [*c]ecs_http_reply_t) c_int;
pub extern fn ecs_http_server_ctx(srv: ?*ecs_http_server_t) ?*anyopaque;
pub extern fn ecs_http_get_header(req: [*c]const ecs_http_request_t, name: [*c]const u8) [*c]const u8;
pub extern fn ecs_http_get_param(req: [*c]const ecs_http_request_t, name: [*c]const u8) [*c]const u8;
pub extern const FLECS_IDEcsRestID_: ecs_entity_t;
pub const EcsRest = extern struct {
    port: u16,
    ipaddr: [*c]u8,
    impl: ?*anyopaque,
};
pub extern var ecs_rest_request_count: i64;
pub extern var ecs_rest_entity_count: i64;
pub extern var ecs_rest_entity_error_count: i64;
pub extern var ecs_rest_query_count: i64;
pub extern var ecs_rest_query_error_count: i64;
pub extern var ecs_rest_query_name_count: i64;
pub extern var ecs_rest_query_name_error_count: i64;
pub extern var ecs_rest_query_name_from_cache_count: i64;
pub extern var ecs_rest_enable_count: i64;
pub extern var ecs_rest_enable_error_count: i64;
pub extern var ecs_rest_delete_count: i64;
pub extern var ecs_rest_delete_error_count: i64;
pub extern var ecs_rest_world_stats_count: i64;
pub extern var ecs_rest_pipeline_stats_count: i64;
pub extern var ecs_rest_stats_error_count: i64;
pub extern fn ecs_rest_server_init(world: ?*ecs_world_t, desc: [*c]const ecs_http_server_desc_t) ?*ecs_http_server_t;
pub extern fn ecs_rest_server_fini(srv: ?*ecs_http_server_t) void;
pub extern fn FlecsRestImport(world: ?*ecs_world_t) void;
pub const struct_EcsTimer = extern struct {
    timeout: f32,
    time: f32,
    overshoot: f32,
    fired_count: i32,
    active: bool,
    single_shot: bool,
};
pub const EcsTimer = struct_EcsTimer;
pub const struct_EcsRateFilter = extern struct {
    src: ecs_entity_t,
    rate: i32,
    tick_count: i32,
    time_elapsed: f32,
};
pub const EcsRateFilter = struct_EcsRateFilter;
pub extern fn ecs_set_timeout(world: ?*ecs_world_t, tick_source: ecs_entity_t, timeout: f32) ecs_entity_t;
pub extern fn ecs_get_timeout(world: ?*const ecs_world_t, tick_source: ecs_entity_t) f32;
pub extern fn ecs_set_interval(world: ?*ecs_world_t, tick_source: ecs_entity_t, interval: f32) ecs_entity_t;
pub extern fn ecs_get_interval(world: ?*const ecs_world_t, tick_source: ecs_entity_t) f32;
pub extern fn ecs_start_timer(world: ?*ecs_world_t, tick_source: ecs_entity_t) void;
pub extern fn ecs_stop_timer(world: ?*ecs_world_t, tick_source: ecs_entity_t) void;
pub extern fn ecs_reset_timer(world: ?*ecs_world_t, tick_source: ecs_entity_t) void;
pub extern fn ecs_randomize_timers(world: ?*ecs_world_t) void;
pub extern fn ecs_set_rate(world: ?*ecs_world_t, tick_source: ecs_entity_t, rate: i32, source: ecs_entity_t) ecs_entity_t;
pub extern fn ecs_set_tick_source(world: ?*ecs_world_t, system: ecs_entity_t, tick_source: ecs_entity_t) void;
pub extern fn FlecsTimerImport(world: ?*ecs_world_t) void;
pub const struct_ecs_pipeline_desc_t = extern struct {
    entity: ecs_entity_t,
    query: ecs_query_desc_t,
};
pub const ecs_pipeline_desc_t = struct_ecs_pipeline_desc_t;
pub extern fn ecs_pipeline_init(world: ?*ecs_world_t, desc: [*c]const ecs_pipeline_desc_t) ecs_entity_t;
pub extern fn ecs_set_pipeline(world: ?*ecs_world_t, pipeline: ecs_entity_t) void;
pub extern fn ecs_get_pipeline(world: ?*const ecs_world_t) ecs_entity_t;
pub extern fn ecs_progress(world: ?*ecs_world_t, delta_time: f32) bool;
pub extern fn ecs_set_time_scale(world: ?*ecs_world_t, scale: f32) void;
pub extern fn ecs_reset_clock(world: ?*ecs_world_t) void;
pub extern fn ecs_run_pipeline(world: ?*ecs_world_t, pipeline: ecs_entity_t, delta_time: f32) void;
pub extern fn ecs_set_threads(world: ?*ecs_world_t, threads: i32) void;
pub extern fn ecs_set_task_threads(world: ?*ecs_world_t, task_threads: i32) void;
pub extern fn ecs_using_task_threads(world: ?*ecs_world_t) bool;
pub extern fn FlecsPipelineImport(world: ?*ecs_world_t) void;
pub const struct_EcsTickSource = extern struct {
    tick: bool,
    time_elapsed: f32,
};
pub const EcsTickSource = struct_EcsTickSource;
pub const struct_ecs_system_desc_t = extern struct {
    _canary: i32,
    entity: ecs_entity_t,
    query: ecs_query_desc_t,
    run: ecs_run_action_t,
    callback: ecs_iter_action_t,
    ctx: ?*anyopaque,
    binding_ctx: ?*anyopaque,
    ctx_free: ecs_ctx_free_t,
    binding_ctx_free: ecs_ctx_free_t,
    interval: f32,
    rate: i32,
    tick_source: ecs_entity_t,
    multi_threaded: bool,
    no_readonly: bool,
};
pub const ecs_system_desc_t = struct_ecs_system_desc_t;
pub extern fn ecs_system_init(world: ?*ecs_world_t, desc: [*c]const ecs_system_desc_t) ecs_entity_t;
pub extern fn ecs_run(world: ?*ecs_world_t, system: ecs_entity_t, delta_time: f32, param: ?*anyopaque) ecs_entity_t;
pub extern fn ecs_run_worker(world: ?*ecs_world_t, system: ecs_entity_t, stage_current: i32, stage_count: i32, delta_time: f32, param: ?*anyopaque) ecs_entity_t;
pub extern fn ecs_run_w_filter(world: ?*ecs_world_t, system: ecs_entity_t, delta_time: f32, offset: i32, limit: i32, param: ?*anyopaque) ecs_entity_t;
pub extern fn ecs_system_get_query(world: ?*const ecs_world_t, system: ecs_entity_t) ?*ecs_query_t;
pub extern fn ecs_system_get_ctx(world: ?*const ecs_world_t, system: ecs_entity_t) ?*anyopaque;
pub extern fn ecs_system_get_binding_ctx(world: ?*const ecs_world_t, system: ecs_entity_t) ?*anyopaque;
pub extern fn FlecsSystemImport(world: ?*ecs_world_t) void;
pub const struct_ecs_gauge_t = extern struct {
    avg: [60]f32,
    min: [60]f32,
    max: [60]f32,
};
pub const ecs_gauge_t = struct_ecs_gauge_t;
pub const struct_ecs_counter_t = extern struct {
    rate: ecs_gauge_t,
    value: [60]f64,
};
pub const ecs_counter_t = struct_ecs_counter_t;
pub const union_ecs_metric_t = extern union {
    gauge: ecs_gauge_t,
    counter: ecs_counter_t,
};
pub const ecs_metric_t = union_ecs_metric_t;
const struct_unnamed_3 = extern struct {
    count: ecs_metric_t,
    not_alive_count: ecs_metric_t,
};
const struct_unnamed_4 = extern struct {
    count: ecs_metric_t,
    tag_count: ecs_metric_t,
    component_count: ecs_metric_t,
    pair_count: ecs_metric_t,
    wildcard_count: ecs_metric_t,
    type_count: ecs_metric_t,
    create_count: ecs_metric_t,
    delete_count: ecs_metric_t,
};
const struct_unnamed_5 = extern struct {
    count: ecs_metric_t,
    empty_count: ecs_metric_t,
    tag_only_count: ecs_metric_t,
    trivial_only_count: ecs_metric_t,
    record_count: ecs_metric_t,
    storage_count: ecs_metric_t,
    create_count: ecs_metric_t,
    delete_count: ecs_metric_t,
};
const struct_unnamed_6 = extern struct {
    query_count: ecs_metric_t,
    observer_count: ecs_metric_t,
    system_count: ecs_metric_t,
};
const struct_unnamed_7 = extern struct {
    add_count: ecs_metric_t,
    remove_count: ecs_metric_t,
    delete_count: ecs_metric_t,
    clear_count: ecs_metric_t,
    set_count: ecs_metric_t,
    get_mut_count: ecs_metric_t,
    modified_count: ecs_metric_t,
    other_count: ecs_metric_t,
    discard_count: ecs_metric_t,
    batched_entity_count: ecs_metric_t,
    batched_count: ecs_metric_t,
};
const struct_unnamed_8 = extern struct {
    frame_count: ecs_metric_t,
    merge_count: ecs_metric_t,
    rematch_count: ecs_metric_t,
    pipeline_build_count: ecs_metric_t,
    systems_ran: ecs_metric_t,
    observers_ran: ecs_metric_t,
    event_emit_count: ecs_metric_t,
};
const struct_unnamed_9 = extern struct {
    world_time_raw: ecs_metric_t,
    world_time: ecs_metric_t,
    frame_time: ecs_metric_t,
    system_time: ecs_metric_t,
    emit_time: ecs_metric_t,
    merge_time: ecs_metric_t,
    rematch_time: ecs_metric_t,
    fps: ecs_metric_t,
    delta_time: ecs_metric_t,
};
const struct_unnamed_10 = extern struct {
    alloc_count: ecs_metric_t,
    realloc_count: ecs_metric_t,
    free_count: ecs_metric_t,
    outstanding_alloc_count: ecs_metric_t,
    block_alloc_count: ecs_metric_t,
    block_free_count: ecs_metric_t,
    block_outstanding_alloc_count: ecs_metric_t,
    stack_alloc_count: ecs_metric_t,
    stack_free_count: ecs_metric_t,
    stack_outstanding_alloc_count: ecs_metric_t,
};
const struct_unnamed_11 = extern struct {
    request_count: ecs_metric_t,
    entity_count: ecs_metric_t,
    entity_error_count: ecs_metric_t,
    query_count: ecs_metric_t,
    query_error_count: ecs_metric_t,
    query_name_count: ecs_metric_t,
    query_name_error_count: ecs_metric_t,
    query_name_from_cache_count: ecs_metric_t,
    enable_count: ecs_metric_t,
    enable_error_count: ecs_metric_t,
    world_stats_count: ecs_metric_t,
    pipeline_stats_count: ecs_metric_t,
    stats_error_count: ecs_metric_t,
};
const struct_unnamed_12 = extern struct {
    request_received_count: ecs_metric_t,
    request_invalid_count: ecs_metric_t,
    request_handled_ok_count: ecs_metric_t,
    request_handled_error_count: ecs_metric_t,
    request_not_handled_count: ecs_metric_t,
    request_preflight_count: ecs_metric_t,
    send_ok_count: ecs_metric_t,
    send_error_count: ecs_metric_t,
    busy_count: ecs_metric_t,
};
pub const struct_ecs_world_stats_t = extern struct {
    first_: i64,
    entities: struct_unnamed_3,
    ids: struct_unnamed_4,
    tables: struct_unnamed_5,
    queries: struct_unnamed_6,
    commands: struct_unnamed_7,
    frame: struct_unnamed_8,
    performance: struct_unnamed_9,
    memory: struct_unnamed_10,
    rest: struct_unnamed_11,
    http: struct_unnamed_12,
    last_: i64,
    t: i32,
};
pub const ecs_world_stats_t = struct_ecs_world_stats_t;
pub const struct_ecs_query_stats_t = extern struct {
    first_: i64,
    matched_table_count: ecs_metric_t,
    matched_empty_table_count: ecs_metric_t,
    matched_entity_count: ecs_metric_t,
    last_: i64,
    t: i32,
};
pub const ecs_query_stats_t = struct_ecs_query_stats_t;
pub const struct_ecs_system_stats_t = extern struct {
    first_: i64,
    time_spent: ecs_metric_t,
    invoke_count: ecs_metric_t,
    last_: i64,
    task: bool,
    query: ecs_query_stats_t,
};
pub const ecs_system_stats_t = struct_ecs_system_stats_t;
pub const struct_ecs_sync_stats_t = extern struct {
    first_: i64,
    time_spent: ecs_metric_t,
    commands_enqueued: ecs_metric_t,
    last_: i64,
    system_count: i32,
    multi_threaded: bool,
    no_readonly: bool,
};
pub const ecs_sync_stats_t = struct_ecs_sync_stats_t;
pub const struct_ecs_pipeline_stats_t = extern struct {
    canary_: i8,
    systems: ecs_vec_t,
    sync_points: ecs_vec_t,
    system_stats: ecs_map_t,
    t: i32,
    system_count: i32,
    active_system_count: i32,
    rebuild_count: i32,
};
pub const ecs_pipeline_stats_t = struct_ecs_pipeline_stats_t;
pub extern fn ecs_world_stats_get(world: ?*const ecs_world_t, stats: [*c]ecs_world_stats_t) void;
pub extern fn ecs_world_stats_reduce(dst: [*c]ecs_world_stats_t, src: [*c]const ecs_world_stats_t) void;
pub extern fn ecs_world_stats_reduce_last(stats: [*c]ecs_world_stats_t, old: [*c]const ecs_world_stats_t, count: i32) void;
pub extern fn ecs_world_stats_repeat_last(stats: [*c]ecs_world_stats_t) void;
pub extern fn ecs_world_stats_copy_last(dst: [*c]ecs_world_stats_t, src: [*c]const ecs_world_stats_t) void;
pub extern fn ecs_world_stats_log(world: ?*const ecs_world_t, stats: [*c]const ecs_world_stats_t) void;
pub extern fn ecs_query_stats_get(world: ?*const ecs_world_t, query: ?*const ecs_query_t, stats: [*c]ecs_query_stats_t) void;
pub extern fn ecs_query_stats_reduce(dst: [*c]ecs_query_stats_t, src: [*c]const ecs_query_stats_t) void;
pub extern fn ecs_query_stats_reduce_last(stats: [*c]ecs_query_stats_t, old: [*c]const ecs_query_stats_t, count: i32) void;
pub extern fn ecs_query_stats_repeat_last(stats: [*c]ecs_query_stats_t) void;
pub extern fn ecs_query_stats_copy_last(dst: [*c]ecs_query_stats_t, src: [*c]const ecs_query_stats_t) void;
pub extern fn ecs_system_stats_get(world: ?*const ecs_world_t, system: ecs_entity_t, stats: [*c]ecs_system_stats_t) bool;
pub extern fn ecs_system_stats_reduce(dst: [*c]ecs_system_stats_t, src: [*c]const ecs_system_stats_t) void;
pub extern fn ecs_system_stats_reduce_last(stats: [*c]ecs_system_stats_t, old: [*c]const ecs_system_stats_t, count: i32) void;
pub extern fn ecs_system_stats_repeat_last(stats: [*c]ecs_system_stats_t) void;
pub extern fn ecs_system_stats_copy_last(dst: [*c]ecs_system_stats_t, src: [*c]const ecs_system_stats_t) void;
pub extern fn ecs_pipeline_stats_get(world: ?*ecs_world_t, pipeline: ecs_entity_t, stats: [*c]ecs_pipeline_stats_t) bool;
pub extern fn ecs_pipeline_stats_fini(stats: [*c]ecs_pipeline_stats_t) void;
pub extern fn ecs_pipeline_stats_reduce(dst: [*c]ecs_pipeline_stats_t, src: [*c]const ecs_pipeline_stats_t) void;
pub extern fn ecs_pipeline_stats_reduce_last(stats: [*c]ecs_pipeline_stats_t, old: [*c]const ecs_pipeline_stats_t, count: i32) void;
pub extern fn ecs_pipeline_stats_repeat_last(stats: [*c]ecs_pipeline_stats_t) void;
pub extern fn ecs_pipeline_stats_copy_last(dst: [*c]ecs_pipeline_stats_t, src: [*c]const ecs_pipeline_stats_t) void;
pub extern fn ecs_metric_reduce(dst: [*c]ecs_metric_t, src: [*c]const ecs_metric_t, t_dst: i32, t_src: i32) void;
pub extern fn ecs_metric_reduce_last(m: [*c]ecs_metric_t, t: i32, count: i32) void;
pub extern fn ecs_metric_copy(m: [*c]ecs_metric_t, dst: i32, src: i32) void;
pub extern var FLECS_IDFlecsMetricsID_: ecs_entity_t;
pub extern var EcsMetric: ecs_entity_t;
pub extern var FLECS_IDEcsMetricID_: ecs_entity_t;
pub extern var EcsCounter: ecs_entity_t;
pub extern var FLECS_IDEcsCounterID_: ecs_entity_t;
pub extern var EcsCounterIncrement: ecs_entity_t;
pub extern var FLECS_IDEcsCounterIncrementID_: ecs_entity_t;
pub extern var EcsCounterId: ecs_entity_t;
pub extern var FLECS_IDEcsCounterIdID_: ecs_entity_t;
pub extern var EcsGauge: ecs_entity_t;
pub extern var FLECS_IDEcsGaugeID_: ecs_entity_t;
pub extern var EcsMetricInstance: ecs_entity_t;
pub extern var FLECS_IDEcsMetricInstanceID_: ecs_entity_t;
pub extern var FLECS_IDEcsMetricValueID_: ecs_entity_t;
pub extern var FLECS_IDEcsMetricSourceID_: ecs_entity_t;
pub const struct_EcsMetricValue = extern struct {
    value: f64,
};
pub const EcsMetricValue = struct_EcsMetricValue;
pub const struct_EcsMetricSource = extern struct {
    entity: ecs_entity_t,
};
pub const EcsMetricSource = struct_EcsMetricSource;
pub const struct_ecs_metric_desc_t = extern struct {
    _canary: i32,
    entity: ecs_entity_t,
    member: ecs_entity_t,
    id: ecs_id_t,
    targets: bool,
    kind: ecs_entity_t,
    brief: [*c]const u8,
};
pub const ecs_metric_desc_t = struct_ecs_metric_desc_t;
pub extern fn ecs_metric_init(world: ?*ecs_world_t, desc: [*c]const ecs_metric_desc_t) ecs_entity_t;
pub extern fn FlecsMetricsImport(world: ?*ecs_world_t) void;
pub extern var FLECS_IDFlecsAlertsID_: ecs_entity_t;
pub extern var FLECS_IDEcsAlertID_: ecs_entity_t;
pub extern var FLECS_IDEcsAlertInstanceID_: ecs_entity_t;
pub extern var FLECS_IDEcsAlertsActiveID_: ecs_entity_t;
pub extern var FLECS_IDEcsAlertTimeoutID_: ecs_entity_t;
pub extern var EcsAlertInfo: ecs_entity_t;
pub extern var FLECS_IDEcsAlertInfoID_: ecs_entity_t;
pub extern var EcsAlertWarning: ecs_entity_t;
pub extern var FLECS_IDEcsAlertWarningID_: ecs_entity_t;
pub extern var EcsAlertError: ecs_entity_t;
pub extern var FLECS_IDEcsAlertErrorID_: ecs_entity_t;
pub extern var EcsAlertCritical: ecs_entity_t;
pub extern var FLECS_IDEcsAlertCriticalID_: ecs_entity_t;
pub const struct_EcsAlertInstance = extern struct {
    message: [*c]u8,
};
pub const EcsAlertInstance = struct_EcsAlertInstance;
pub const struct_EcsAlertsActive = extern struct {
    info_count: i32,
    warning_count: i32,
    error_count: i32,
    alerts: ecs_map_t,
};
pub const EcsAlertsActive = struct_EcsAlertsActive;
pub const struct_ecs_alert_severity_filter_t = extern struct {
    severity: ecs_entity_t,
    with: ecs_id_t,
    @"var": [*c]const u8,
    _var_index: i32,
};
pub const ecs_alert_severity_filter_t = struct_ecs_alert_severity_filter_t;
pub const struct_ecs_alert_desc_t = extern struct {
    _canary: i32,
    entity: ecs_entity_t,
    filter: ecs_filter_desc_t,
    message: [*c]const u8,
    doc_name: [*c]const u8,
    brief: [*c]const u8,
    severity: ecs_entity_t,
    severity_filters: [4]ecs_alert_severity_filter_t,
    retain_period: f32,
    member: ecs_entity_t,
    id: ecs_id_t,
    @"var": [*c]const u8,
};
pub const ecs_alert_desc_t = struct_ecs_alert_desc_t;
pub extern fn ecs_alert_init(world: ?*ecs_world_t, desc: [*c]const ecs_alert_desc_t) ecs_entity_t;
pub extern fn ecs_get_alert_count(world: ?*const ecs_world_t, entity: ecs_entity_t, alert: ecs_entity_t) i32;
pub extern fn ecs_get_alert(world: ?*const ecs_world_t, entity: ecs_entity_t, alert: ecs_entity_t) ecs_entity_t;
pub extern fn FlecsAlertsImport(world: ?*ecs_world_t) void;
pub extern var FLECS_IDFlecsMonitorID_: ecs_entity_t;
pub extern var FLECS_IDEcsWorldStatsID_: ecs_entity_t;
pub extern var FLECS_IDEcsWorldSummaryID_: ecs_entity_t;
pub extern var FLECS_IDEcsPipelineStatsID_: ecs_entity_t;
pub extern var EcsPeriod1s: ecs_entity_t;
pub extern var EcsPeriod1m: ecs_entity_t;
pub extern var EcsPeriod1h: ecs_entity_t;
pub extern var EcsPeriod1d: ecs_entity_t;
pub extern var EcsPeriod1w: ecs_entity_t;
pub const EcsStatsHeader = extern struct {
    elapsed: f32,
    reduce_count: i32,
};
pub const EcsWorldStats = extern struct {
    hdr: EcsStatsHeader,
    stats: ecs_world_stats_t,
};
pub const EcsPipelineStats = extern struct {
    hdr: EcsStatsHeader,
    stats: ecs_pipeline_stats_t,
};
pub const EcsWorldSummary = extern struct {
    target_fps: f64,
    frame_time_total: f64,
    system_time_total: f64,
    merge_time_total: f64,
    frame_time_last: f64,
    system_time_last: f64,
    merge_time_last: f64,
};
pub extern fn FlecsMonitorImport(world: ?*ecs_world_t) void;
pub extern fn FlecsCoreDocImport(world: ?*ecs_world_t) void;
pub extern const FLECS_IDEcsDocDescriptionID_: ecs_entity_t;
pub extern const EcsDocBrief: ecs_entity_t;
pub extern const EcsDocDetail: ecs_entity_t;
pub extern const EcsDocLink: ecs_entity_t;
pub extern const EcsDocColor: ecs_entity_t;
pub const struct_EcsDocDescription = extern struct {
    value: [*c]u8,
};
pub const EcsDocDescription = struct_EcsDocDescription;
pub extern fn ecs_doc_set_name(world: ?*ecs_world_t, entity: ecs_entity_t, name: [*c]const u8) void;
pub extern fn ecs_doc_set_brief(world: ?*ecs_world_t, entity: ecs_entity_t, description: [*c]const u8) void;
pub extern fn ecs_doc_set_detail(world: ?*ecs_world_t, entity: ecs_entity_t, description: [*c]const u8) void;
pub extern fn ecs_doc_set_link(world: ?*ecs_world_t, entity: ecs_entity_t, link: [*c]const u8) void;
pub extern fn ecs_doc_set_color(world: ?*ecs_world_t, entity: ecs_entity_t, color: [*c]const u8) void;
pub extern fn ecs_doc_get_name(world: ?*const ecs_world_t, entity: ecs_entity_t) [*c]const u8;
pub extern fn ecs_doc_get_brief(world: ?*const ecs_world_t, entity: ecs_entity_t) [*c]const u8;
pub extern fn ecs_doc_get_detail(world: ?*const ecs_world_t, entity: ecs_entity_t) [*c]const u8;
pub extern fn ecs_doc_get_link(world: ?*const ecs_world_t, entity: ecs_entity_t) [*c]const u8;
pub extern fn ecs_doc_get_color(world: ?*const ecs_world_t, entity: ecs_entity_t) [*c]const u8;
pub extern fn FlecsDocImport(world: ?*ecs_world_t) void;
pub const struct_ecs_from_json_desc_t = extern struct {
    name: [*c]const u8,
    expr: [*c]const u8,
    lookup_action: ?*const fn (?*const ecs_world_t, [*c]const u8, ?*anyopaque) callconv(.C) ecs_entity_t,
    lookup_ctx: ?*anyopaque,
};
pub const ecs_from_json_desc_t = struct_ecs_from_json_desc_t;
pub extern fn ecs_ptr_from_json(world: ?*const ecs_world_t, @"type": ecs_entity_t, ptr: ?*anyopaque, json: [*c]const u8, desc: [*c]const ecs_from_json_desc_t) [*c]const u8;
pub extern fn ecs_entity_from_json(world: ?*ecs_world_t, entity: ecs_entity_t, json: [*c]const u8, desc: [*c]const ecs_from_json_desc_t) [*c]const u8;
pub extern fn ecs_world_from_json(world: ?*ecs_world_t, json: [*c]const u8, desc: [*c]const ecs_from_json_desc_t) [*c]const u8;
pub extern fn ecs_array_to_json(world: ?*const ecs_world_t, @"type": ecs_entity_t, data: ?*const anyopaque, count: i32) [*c]u8;
pub extern fn ecs_array_to_json_buf(world: ?*const ecs_world_t, @"type": ecs_entity_t, data: ?*const anyopaque, count: i32, buf_out: [*c]ecs_strbuf_t) c_int;
pub extern fn ecs_ptr_to_json(world: ?*const ecs_world_t, @"type": ecs_entity_t, data: ?*const anyopaque) [*c]u8;
pub extern fn ecs_ptr_to_json_buf(world: ?*const ecs_world_t, @"type": ecs_entity_t, data: ?*const anyopaque, buf_out: [*c]ecs_strbuf_t) c_int;
pub extern fn ecs_type_info_to_json(world: ?*const ecs_world_t, @"type": ecs_entity_t) [*c]u8;
pub extern fn ecs_type_info_to_json_buf(world: ?*const ecs_world_t, @"type": ecs_entity_t, buf_out: [*c]ecs_strbuf_t) c_int;
pub const struct_ecs_entity_to_json_desc_t = extern struct {
    serialize_path: bool,
    serialize_label: bool,
    serialize_brief: bool,
    serialize_link: bool,
    serialize_color: bool,
    serialize_ids: bool,
    serialize_id_labels: bool,
    serialize_base: bool,
    serialize_private: bool,
    serialize_hidden: bool,
    serialize_values: bool,
    serialize_type_info: bool,
    serialize_alerts: bool,
    serialize_refs: ecs_entity_t,
    serialize_matches: bool,
};
pub const ecs_entity_to_json_desc_t = struct_ecs_entity_to_json_desc_t;
pub extern fn ecs_entity_to_json(world: ?*const ecs_world_t, entity: ecs_entity_t, desc: [*c]const ecs_entity_to_json_desc_t) [*c]u8;
pub extern fn ecs_entity_to_json_buf(world: ?*const ecs_world_t, entity: ecs_entity_t, buf_out: [*c]ecs_strbuf_t, desc: [*c]const ecs_entity_to_json_desc_t) c_int;
pub const struct_ecs_iter_to_json_desc_t = extern struct {
    serialize_term_ids: bool,
    serialize_term_labels: bool,
    serialize_ids: bool,
    serialize_id_labels: bool,
    serialize_sources: bool,
    serialize_variables: bool,
    serialize_is_set: bool,
    serialize_values: bool,
    serialize_private: bool,
    serialize_entities: bool,
    serialize_entity_labels: bool,
    serialize_entity_ids: bool,
    serialize_entity_names: bool,
    serialize_variable_labels: bool,
    serialize_variable_ids: bool,
    serialize_colors: bool,
    measure_eval_duration: bool,
    serialize_type_info: bool,
    serialize_table: bool,
};
pub const ecs_iter_to_json_desc_t = struct_ecs_iter_to_json_desc_t;
pub extern fn ecs_iter_to_json(world: ?*const ecs_world_t, iter: [*c]ecs_iter_t, desc: [*c]const ecs_iter_to_json_desc_t) [*c]u8;
pub extern fn ecs_iter_to_json_buf(world: ?*const ecs_world_t, iter: [*c]ecs_iter_t, buf_out: [*c]ecs_strbuf_t, desc: [*c]const ecs_iter_to_json_desc_t) c_int;
pub const struct_ecs_world_to_json_desc_t = extern struct {
    serialize_builtin: bool,
    serialize_modules: bool,
};
pub const ecs_world_to_json_desc_t = struct_ecs_world_to_json_desc_t;
pub extern fn ecs_world_to_json(world: ?*ecs_world_t, desc: [*c]const ecs_world_to_json_desc_t) [*c]u8;
pub extern fn ecs_world_to_json_buf(world: ?*ecs_world_t, buf_out: [*c]ecs_strbuf_t, desc: [*c]const ecs_world_to_json_desc_t) c_int;
pub extern var EcsUnitPrefixes: ecs_entity_t;
pub extern var FLECS_IDEcsUnitPrefixesID_: ecs_entity_t;
pub extern var EcsYocto: ecs_entity_t;
pub extern var FLECS_IDEcsYoctoID_: ecs_entity_t;
pub extern var EcsZepto: ecs_entity_t;
pub extern var FLECS_IDEcsZeptoID_: ecs_entity_t;
pub extern var EcsAtto: ecs_entity_t;
pub extern var FLECS_IDEcsAttoID_: ecs_entity_t;
pub extern var EcsFemto: ecs_entity_t;
pub extern var FLECS_IDEcsFemtoID_: ecs_entity_t;
pub extern var EcsPico: ecs_entity_t;
pub extern var FLECS_IDEcsPicoID_: ecs_entity_t;
pub extern var EcsNano: ecs_entity_t;
pub extern var FLECS_IDEcsNanoID_: ecs_entity_t;
pub extern var EcsMicro: ecs_entity_t;
pub extern var FLECS_IDEcsMicroID_: ecs_entity_t;
pub extern var EcsMilli: ecs_entity_t;
pub extern var FLECS_IDEcsMilliID_: ecs_entity_t;
pub extern var EcsCenti: ecs_entity_t;
pub extern var FLECS_IDEcsCentiID_: ecs_entity_t;
pub extern var EcsDeci: ecs_entity_t;
pub extern var FLECS_IDEcsDeciID_: ecs_entity_t;
pub extern var EcsDeca: ecs_entity_t;
pub extern var FLECS_IDEcsDecaID_: ecs_entity_t;
pub extern var EcsHecto: ecs_entity_t;
pub extern var FLECS_IDEcsHectoID_: ecs_entity_t;
pub extern var EcsKilo: ecs_entity_t;
pub extern var FLECS_IDEcsKiloID_: ecs_entity_t;
pub extern var EcsMega: ecs_entity_t;
pub extern var FLECS_IDEcsMegaID_: ecs_entity_t;
pub extern var EcsGiga: ecs_entity_t;
pub extern var FLECS_IDEcsGigaID_: ecs_entity_t;
pub extern var EcsTera: ecs_entity_t;
pub extern var FLECS_IDEcsTeraID_: ecs_entity_t;
pub extern var EcsPeta: ecs_entity_t;
pub extern var FLECS_IDEcsPetaID_: ecs_entity_t;
pub extern var EcsExa: ecs_entity_t;
pub extern var FLECS_IDEcsExaID_: ecs_entity_t;
pub extern var EcsZetta: ecs_entity_t;
pub extern var FLECS_IDEcsZettaID_: ecs_entity_t;
pub extern var EcsYotta: ecs_entity_t;
pub extern var FLECS_IDEcsYottaID_: ecs_entity_t;
pub extern var EcsKibi: ecs_entity_t;
pub extern var FLECS_IDEcsKibiID_: ecs_entity_t;
pub extern var EcsMebi: ecs_entity_t;
pub extern var FLECS_IDEcsMebiID_: ecs_entity_t;
pub extern var EcsGibi: ecs_entity_t;
pub extern var FLECS_IDEcsGibiID_: ecs_entity_t;
pub extern var EcsTebi: ecs_entity_t;
pub extern var FLECS_IDEcsTebiID_: ecs_entity_t;
pub extern var EcsPebi: ecs_entity_t;
pub extern var FLECS_IDEcsPebiID_: ecs_entity_t;
pub extern var EcsExbi: ecs_entity_t;
pub extern var FLECS_IDEcsExbiID_: ecs_entity_t;
pub extern var EcsZebi: ecs_entity_t;
pub extern var FLECS_IDEcsZebiID_: ecs_entity_t;
pub extern var EcsYobi: ecs_entity_t;
pub extern var FLECS_IDEcsYobiID_: ecs_entity_t;
pub extern var EcsDuration: ecs_entity_t;
pub extern var FLECS_IDEcsDurationID_: ecs_entity_t;
pub extern var EcsPicoSeconds: ecs_entity_t;
pub extern var FLECS_IDEcsPicoSecondsID_: ecs_entity_t;
pub extern var EcsNanoSeconds: ecs_entity_t;
pub extern var FLECS_IDEcsNanoSecondsID_: ecs_entity_t;
pub extern var EcsMicroSeconds: ecs_entity_t;
pub extern var FLECS_IDEcsMicroSecondsID_: ecs_entity_t;
pub extern var EcsMilliSeconds: ecs_entity_t;
pub extern var FLECS_IDEcsMilliSecondsID_: ecs_entity_t;
pub extern var EcsSeconds: ecs_entity_t;
pub extern var FLECS_IDEcsSecondsID_: ecs_entity_t;
pub extern var EcsMinutes: ecs_entity_t;
pub extern var FLECS_IDEcsMinutesID_: ecs_entity_t;
pub extern var EcsHours: ecs_entity_t;
pub extern var FLECS_IDEcsHoursID_: ecs_entity_t;
pub extern var EcsDays: ecs_entity_t;
pub extern var FLECS_IDEcsDaysID_: ecs_entity_t;
pub extern var EcsTime: ecs_entity_t;
pub extern var FLECS_IDEcsTimeID_: ecs_entity_t;
pub extern var EcsDate: ecs_entity_t;
pub extern var FLECS_IDEcsDateID_: ecs_entity_t;
pub extern var EcsMass: ecs_entity_t;
pub extern var FLECS_IDEcsMassID_: ecs_entity_t;
pub extern var EcsGrams: ecs_entity_t;
pub extern var FLECS_IDEcsGramsID_: ecs_entity_t;
pub extern var EcsKiloGrams: ecs_entity_t;
pub extern var FLECS_IDEcsKiloGramsID_: ecs_entity_t;
pub extern var EcsElectricCurrent: ecs_entity_t;
pub extern var FLECS_IDEcsElectricCurrentID_: ecs_entity_t;
pub extern var EcsAmpere: ecs_entity_t;
pub extern var FLECS_IDEcsAmpereID_: ecs_entity_t;
pub extern var EcsAmount: ecs_entity_t;
pub extern var FLECS_IDEcsAmountID_: ecs_entity_t;
pub extern var EcsMole: ecs_entity_t;
pub extern var FLECS_IDEcsMoleID_: ecs_entity_t;
pub extern var EcsLuminousIntensity: ecs_entity_t;
pub extern var FLECS_IDEcsLuminousIntensityID_: ecs_entity_t;
pub extern var EcsCandela: ecs_entity_t;
pub extern var FLECS_IDEcsCandelaID_: ecs_entity_t;
pub extern var EcsForce: ecs_entity_t;
pub extern var FLECS_IDEcsForceID_: ecs_entity_t;
pub extern var EcsNewton: ecs_entity_t;
pub extern var FLECS_IDEcsNewtonID_: ecs_entity_t;
pub extern var EcsLength: ecs_entity_t;
pub extern var FLECS_IDEcsLengthID_: ecs_entity_t;
pub extern var EcsMeters: ecs_entity_t;
pub extern var FLECS_IDEcsMetersID_: ecs_entity_t;
pub extern var EcsPicoMeters: ecs_entity_t;
pub extern var FLECS_IDEcsPicoMetersID_: ecs_entity_t;
pub extern var EcsNanoMeters: ecs_entity_t;
pub extern var FLECS_IDEcsNanoMetersID_: ecs_entity_t;
pub extern var EcsMicroMeters: ecs_entity_t;
pub extern var FLECS_IDEcsMicroMetersID_: ecs_entity_t;
pub extern var EcsMilliMeters: ecs_entity_t;
pub extern var FLECS_IDEcsMilliMetersID_: ecs_entity_t;
pub extern var EcsCentiMeters: ecs_entity_t;
pub extern var FLECS_IDEcsCentiMetersID_: ecs_entity_t;
pub extern var EcsKiloMeters: ecs_entity_t;
pub extern var FLECS_IDEcsKiloMetersID_: ecs_entity_t;
pub extern var EcsMiles: ecs_entity_t;
pub extern var FLECS_IDEcsMilesID_: ecs_entity_t;
pub extern var EcsPixels: ecs_entity_t;
pub extern var FLECS_IDEcsPixelsID_: ecs_entity_t;
pub extern var EcsPressure: ecs_entity_t;
pub extern var FLECS_IDEcsPressureID_: ecs_entity_t;
pub extern var EcsPascal: ecs_entity_t;
pub extern var FLECS_IDEcsPascalID_: ecs_entity_t;
pub extern var EcsBar: ecs_entity_t;
pub extern var FLECS_IDEcsBarID_: ecs_entity_t;
pub extern var EcsSpeed: ecs_entity_t;
pub extern var FLECS_IDEcsSpeedID_: ecs_entity_t;
pub extern var EcsMetersPerSecond: ecs_entity_t;
pub extern var FLECS_IDEcsMetersPerSecondID_: ecs_entity_t;
pub extern var EcsKiloMetersPerSecond: ecs_entity_t;
pub extern var FLECS_IDEcsKiloMetersPerSecondID_: ecs_entity_t;
pub extern var EcsKiloMetersPerHour: ecs_entity_t;
pub extern var FLECS_IDEcsKiloMetersPerHourID_: ecs_entity_t;
pub extern var EcsMilesPerHour: ecs_entity_t;
pub extern var FLECS_IDEcsMilesPerHourID_: ecs_entity_t;
pub extern var EcsTemperature: ecs_entity_t;
pub extern var FLECS_IDEcsTemperatureID_: ecs_entity_t;
pub extern var EcsKelvin: ecs_entity_t;
pub extern var FLECS_IDEcsKelvinID_: ecs_entity_t;
pub extern var EcsCelsius: ecs_entity_t;
pub extern var FLECS_IDEcsCelsiusID_: ecs_entity_t;
pub extern var EcsFahrenheit: ecs_entity_t;
pub extern var FLECS_IDEcsFahrenheitID_: ecs_entity_t;
pub extern var EcsData: ecs_entity_t;
pub extern var FLECS_IDEcsDataID_: ecs_entity_t;
pub extern var EcsBits: ecs_entity_t;
pub extern var FLECS_IDEcsBitsID_: ecs_entity_t;
pub extern var EcsKiloBits: ecs_entity_t;
pub extern var FLECS_IDEcsKiloBitsID_: ecs_entity_t;
pub extern var EcsMegaBits: ecs_entity_t;
pub extern var FLECS_IDEcsMegaBitsID_: ecs_entity_t;
pub extern var EcsGigaBits: ecs_entity_t;
pub extern var FLECS_IDEcsGigaBitsID_: ecs_entity_t;
pub extern var EcsBytes: ecs_entity_t;
pub extern var FLECS_IDEcsBytesID_: ecs_entity_t;
pub extern var EcsKiloBytes: ecs_entity_t;
pub extern var FLECS_IDEcsKiloBytesID_: ecs_entity_t;
pub extern var EcsMegaBytes: ecs_entity_t;
pub extern var FLECS_IDEcsMegaBytesID_: ecs_entity_t;
pub extern var EcsGigaBytes: ecs_entity_t;
pub extern var FLECS_IDEcsGigaBytesID_: ecs_entity_t;
pub extern var EcsKibiBytes: ecs_entity_t;
pub extern var FLECS_IDEcsKibiBytesID_: ecs_entity_t;
pub extern var EcsMebiBytes: ecs_entity_t;
pub extern var FLECS_IDEcsMebiBytesID_: ecs_entity_t;
pub extern var EcsGibiBytes: ecs_entity_t;
pub extern var FLECS_IDEcsGibiBytesID_: ecs_entity_t;
pub extern var EcsDataRate: ecs_entity_t;
pub extern var FLECS_IDEcsDataRateID_: ecs_entity_t;
pub extern var EcsBitsPerSecond: ecs_entity_t;
pub extern var FLECS_IDEcsBitsPerSecondID_: ecs_entity_t;
pub extern var EcsKiloBitsPerSecond: ecs_entity_t;
pub extern var FLECS_IDEcsKiloBitsPerSecondID_: ecs_entity_t;
pub extern var EcsMegaBitsPerSecond: ecs_entity_t;
pub extern var FLECS_IDEcsMegaBitsPerSecondID_: ecs_entity_t;
pub extern var EcsGigaBitsPerSecond: ecs_entity_t;
pub extern var FLECS_IDEcsGigaBitsPerSecondID_: ecs_entity_t;
pub extern var EcsBytesPerSecond: ecs_entity_t;
pub extern var FLECS_IDEcsBytesPerSecondID_: ecs_entity_t;
pub extern var EcsKiloBytesPerSecond: ecs_entity_t;
pub extern var FLECS_IDEcsKiloBytesPerSecondID_: ecs_entity_t;
pub extern var EcsMegaBytesPerSecond: ecs_entity_t;
pub extern var FLECS_IDEcsMegaBytesPerSecondID_: ecs_entity_t;
pub extern var EcsGigaBytesPerSecond: ecs_entity_t;
pub extern var FLECS_IDEcsGigaBytesPerSecondID_: ecs_entity_t;
pub extern var EcsAngle: ecs_entity_t;
pub extern var FLECS_IDEcsAngleID_: ecs_entity_t;
pub extern var EcsRadians: ecs_entity_t;
pub extern var FLECS_IDEcsRadiansID_: ecs_entity_t;
pub extern var EcsDegrees: ecs_entity_t;
pub extern var FLECS_IDEcsDegreesID_: ecs_entity_t;
pub extern var EcsFrequency: ecs_entity_t;
pub extern var FLECS_IDEcsFrequencyID_: ecs_entity_t;
pub extern var EcsHertz: ecs_entity_t;
pub extern var FLECS_IDEcsHertzID_: ecs_entity_t;
pub extern var EcsKiloHertz: ecs_entity_t;
pub extern var FLECS_IDEcsKiloHertzID_: ecs_entity_t;
pub extern var EcsMegaHertz: ecs_entity_t;
pub extern var FLECS_IDEcsMegaHertzID_: ecs_entity_t;
pub extern var EcsGigaHertz: ecs_entity_t;
pub extern var FLECS_IDEcsGigaHertzID_: ecs_entity_t;
pub extern var EcsUri: ecs_entity_t;
pub extern var FLECS_IDEcsUriID_: ecs_entity_t;
pub extern var EcsUriHyperlink: ecs_entity_t;
pub extern var FLECS_IDEcsUriHyperlinkID_: ecs_entity_t;
pub extern var EcsUriImage: ecs_entity_t;
pub extern var FLECS_IDEcsUriImageID_: ecs_entity_t;
pub extern var EcsUriFile: ecs_entity_t;
pub extern var FLECS_IDEcsUriFileID_: ecs_entity_t;
pub extern var EcsAcceleration: ecs_entity_t;
pub extern var FLECS_IDEcsAccelerationID_: ecs_entity_t;
pub extern var EcsPercentage: ecs_entity_t;
pub extern var FLECS_IDEcsPercentageID_: ecs_entity_t;
pub extern var EcsBel: ecs_entity_t;
pub extern var FLECS_IDEcsBelID_: ecs_entity_t;
pub extern var EcsDeciBel: ecs_entity_t;
pub extern var FLECS_IDEcsDeciBelID_: ecs_entity_t;
pub extern fn FlecsUnitsImport(world: ?*ecs_world_t) void;
pub const ptrdiff_t = c_long;
pub const wchar_t = c_int;
pub const max_align_t = c_longdouble;
pub const ecs_bool_t = bool;
pub const ecs_char_t = u8;
pub const ecs_byte_t = u8;
pub const ecs_u8_t = u8;
pub const ecs_u16_t = u16;
pub const ecs_u32_t = u32;
pub const ecs_u64_t = u64;
pub const ecs_uptr_t = usize;
pub const ecs_i8_t = i8;
pub const ecs_i16_t = i16;
pub const ecs_i32_t = i32;
pub const ecs_i64_t = i64;
pub const ecs_iptr_t = isize;
pub const ecs_f32_t = f32;
pub const ecs_f64_t = f64;
pub const ecs_string_t = [*c]u8;
pub extern const FLECS_IDEcsMetaTypeID_: ecs_entity_t;
pub extern const FLECS_IDEcsMetaTypeSerializedID_: ecs_entity_t;
pub extern const FLECS_IDEcsPrimitiveID_: ecs_entity_t;
pub extern const FLECS_IDEcsEnumID_: ecs_entity_t;
pub extern const FLECS_IDEcsBitmaskID_: ecs_entity_t;
pub extern const FLECS_IDEcsMemberID_: ecs_entity_t;
pub extern const FLECS_IDEcsMemberRangesID_: ecs_entity_t;
pub extern const FLECS_IDEcsStructID_: ecs_entity_t;
pub extern const FLECS_IDEcsArrayID_: ecs_entity_t;
pub extern const FLECS_IDEcsVectorID_: ecs_entity_t;
pub extern const FLECS_IDEcsOpaqueID_: ecs_entity_t;
pub extern const FLECS_IDEcsUnitID_: ecs_entity_t;
pub extern const FLECS_IDEcsUnitPrefixID_: ecs_entity_t;
pub extern const EcsConstant: ecs_entity_t;
pub extern const EcsQuantity: ecs_entity_t;
pub extern const FLECS_IDecs_bool_tID_: ecs_entity_t;
pub extern const FLECS_IDecs_char_tID_: ecs_entity_t;
pub extern const FLECS_IDecs_byte_tID_: ecs_entity_t;
pub extern const FLECS_IDecs_u8_tID_: ecs_entity_t;
pub extern const FLECS_IDecs_u16_tID_: ecs_entity_t;
pub extern const FLECS_IDecs_u32_tID_: ecs_entity_t;
pub extern const FLECS_IDecs_u64_tID_: ecs_entity_t;
pub extern const FLECS_IDecs_uptr_tID_: ecs_entity_t;
pub extern const FLECS_IDecs_i8_tID_: ecs_entity_t;
pub extern const FLECS_IDecs_i16_tID_: ecs_entity_t;
pub extern const FLECS_IDecs_i32_tID_: ecs_entity_t;
pub extern const FLECS_IDecs_i64_tID_: ecs_entity_t;
pub extern const FLECS_IDecs_iptr_tID_: ecs_entity_t;
pub extern const FLECS_IDecs_f32_tID_: ecs_entity_t;
pub extern const FLECS_IDecs_f64_tID_: ecs_entity_t;
pub extern const FLECS_IDecs_string_tID_: ecs_entity_t;
pub extern const FLECS_IDecs_entity_tID_: ecs_entity_t;
pub const EcsPrimitiveType: c_int = 0;
pub const EcsBitmaskType: c_int = 1;
pub const EcsEnumType: c_int = 2;
pub const EcsStructType: c_int = 3;
pub const EcsArrayType: c_int = 4;
pub const EcsVectorType: c_int = 5;
pub const EcsOpaqueType: c_int = 6;
pub const EcsTypeKindLast: c_int = 6;
pub const enum_ecs_type_kind_t = c_uint;
pub const ecs_type_kind_t = enum_ecs_type_kind_t;
pub const struct_EcsMetaType = extern struct {
    kind: ecs_type_kind_t,
    existing: bool,
    partial: bool,
};
pub const EcsMetaType = struct_EcsMetaType;
pub const EcsBool: c_int = 1;
pub const EcsChar: c_int = 2;
pub const EcsByte: c_int = 3;
pub const EcsU8: c_int = 4;
pub const EcsU16: c_int = 5;
pub const EcsU32: c_int = 6;
pub const EcsU64: c_int = 7;
pub const EcsI8: c_int = 8;
pub const EcsI16: c_int = 9;
pub const EcsI32: c_int = 10;
pub const EcsI64: c_int = 11;
pub const EcsF32: c_int = 12;
pub const EcsF64: c_int = 13;
pub const EcsUPtr: c_int = 14;
pub const EcsIPtr: c_int = 15;
pub const EcsString: c_int = 16;
pub const EcsEntity: c_int = 17;
pub const EcsPrimitiveKindLast: c_int = 17;
pub const enum_ecs_primitive_kind_t = c_uint;
pub const ecs_primitive_kind_t = enum_ecs_primitive_kind_t;
pub const struct_EcsPrimitive = extern struct {
    kind: ecs_primitive_kind_t,
};
pub const EcsPrimitive = struct_EcsPrimitive;
pub const struct_EcsMember = extern struct {
    type: ecs_entity_t,
    count: i32,
    unit: ecs_entity_t,
    offset: i32,
};
pub const EcsMember = struct_EcsMember;
pub const struct_ecs_member_value_range_t = extern struct {
    min: f64,
    max: f64,
};
pub const ecs_member_value_range_t = struct_ecs_member_value_range_t;
pub const struct_EcsMemberRanges = extern struct {
    value: ecs_member_value_range_t,
    warning: ecs_member_value_range_t,
    @"error": ecs_member_value_range_t,
};
pub const EcsMemberRanges = struct_EcsMemberRanges;
pub const struct_ecs_member_t = extern struct {
    name: [*c]const u8,
    type: ecs_entity_t,
    count: i32,
    offset: i32,
    unit: ecs_entity_t,
    range: ecs_member_value_range_t,
    error_range: ecs_member_value_range_t,
    warning_range: ecs_member_value_range_t,
    size: ecs_size_t,
    member: ecs_entity_t,
};
pub const ecs_member_t = struct_ecs_member_t;
pub const struct_EcsStruct = extern struct {
    members: ecs_vec_t,
};
pub const EcsStruct = struct_EcsStruct;
pub const struct_ecs_enum_constant_t = extern struct {
    name: [*c]const u8,
    value: i32,
    constant: ecs_entity_t,
};
pub const ecs_enum_constant_t = struct_ecs_enum_constant_t;
pub const struct_EcsEnum = extern struct {
    constants: ecs_map_t,
};
pub const EcsEnum = struct_EcsEnum;
pub const struct_ecs_bitmask_constant_t = extern struct {
    name: [*c]const u8,
    value: ecs_flags32_t,
    constant: ecs_entity_t,
};
pub const ecs_bitmask_constant_t = struct_ecs_bitmask_constant_t;
pub const struct_EcsBitmask = extern struct {
    constants: ecs_map_t,
};
pub const EcsBitmask = struct_EcsBitmask;
pub const struct_EcsArray = extern struct {
    type: ecs_entity_t,
    count: i32,
};
pub const EcsArray = struct_EcsArray;
pub const struct_EcsVector = extern struct {
    type: ecs_entity_t,
};
pub const EcsVector = struct_EcsVector;
pub const struct_ecs_serializer_t = extern struct {
    value: ?*const fn ([*c]const struct_ecs_serializer_t, ecs_entity_t, ?*const anyopaque) callconv(.C) c_int,
    member: ?*const fn ([*c]const struct_ecs_serializer_t, [*c]const u8) callconv(.C) c_int,
    world: ?*const ecs_world_t,
    ctx: ?*anyopaque,
};
pub const ecs_serializer_t = struct_ecs_serializer_t;
pub const ecs_meta_serialize_t = ?*const fn ([*c]const ecs_serializer_t, ?*const anyopaque) callconv(.C) c_int;
pub const struct_EcsOpaque = extern struct {
    as_type: ecs_entity_t,
    serialize: ecs_meta_serialize_t,
    assign_bool: ?*const fn (?*anyopaque, bool) callconv(.C) void,
    assign_char: ?*const fn (?*anyopaque, u8) callconv(.C) void,
    assign_int: ?*const fn (?*anyopaque, i64) callconv(.C) void,
    assign_uint: ?*const fn (?*anyopaque, u64) callconv(.C) void,
    assign_float: ?*const fn (?*anyopaque, f64) callconv(.C) void,
    assign_string: ?*const fn (?*anyopaque, [*c]const u8) callconv(.C) void,
    assign_entity: ?*const fn (?*anyopaque, ?*ecs_world_t, ecs_entity_t) callconv(.C) void,
    assign_null: ?*const fn (?*anyopaque) callconv(.C) void,
    clear: ?*const fn (?*anyopaque) callconv(.C) void,
    ensure_element: ?*const fn (?*anyopaque, usize) callconv(.C) ?*anyopaque,
    ensure_member: ?*const fn (?*anyopaque, [*c]const u8) callconv(.C) ?*anyopaque,
    count: ?*const fn (?*const anyopaque) callconv(.C) usize,
    resize: ?*const fn (?*anyopaque, usize) callconv(.C) void,
};
pub const EcsOpaque = struct_EcsOpaque;
pub const struct_ecs_unit_translation_t = extern struct {
    factor: i32,
    power: i32,
};
pub const ecs_unit_translation_t = struct_ecs_unit_translation_t;
pub const struct_EcsUnit = extern struct {
    symbol: [*c]u8,
    prefix: ecs_entity_t,
    base: ecs_entity_t,
    over: ecs_entity_t,
    translation: ecs_unit_translation_t,
};
pub const EcsUnit = struct_EcsUnit;
pub const struct_EcsUnitPrefix = extern struct {
    symbol: [*c]u8,
    translation: ecs_unit_translation_t,
};
pub const EcsUnitPrefix = struct_EcsUnitPrefix;
pub const EcsOpArray: c_int = 0;
pub const EcsOpVector: c_int = 1;
pub const EcsOpOpaque: c_int = 2;
pub const EcsOpPush: c_int = 3;
pub const EcsOpPop: c_int = 4;
pub const EcsOpScope: c_int = 5;
pub const EcsOpEnum: c_int = 6;
pub const EcsOpBitmask: c_int = 7;
pub const EcsOpPrimitive: c_int = 8;
pub const EcsOpBool: c_int = 9;
pub const EcsOpChar: c_int = 10;
pub const EcsOpByte: c_int = 11;
pub const EcsOpU8: c_int = 12;
pub const EcsOpU16: c_int = 13;
pub const EcsOpU32: c_int = 14;
pub const EcsOpU64: c_int = 15;
pub const EcsOpI8: c_int = 16;
pub const EcsOpI16: c_int = 17;
pub const EcsOpI32: c_int = 18;
pub const EcsOpI64: c_int = 19;
pub const EcsOpF32: c_int = 20;
pub const EcsOpF64: c_int = 21;
pub const EcsOpUPtr: c_int = 22;
pub const EcsOpIPtr: c_int = 23;
pub const EcsOpString: c_int = 24;
pub const EcsOpEntity: c_int = 25;
pub const EcsMetaTypeOpKindLast: c_int = 25;
pub const enum_ecs_meta_type_op_kind_t = c_uint;
pub const ecs_meta_type_op_kind_t = enum_ecs_meta_type_op_kind_t;
pub const struct_ecs_meta_type_op_t = extern struct {
    kind: ecs_meta_type_op_kind_t,
    offset: ecs_size_t,
    count: i32,
    name: [*c]const u8,
    op_count: i32,
    size: ecs_size_t,
    type: ecs_entity_t,
    member_index: i32,
    members: [*c]ecs_hashmap_t,
};
pub const ecs_meta_type_op_t = struct_ecs_meta_type_op_t;
pub const struct_EcsMetaTypeSerialized = extern struct {
    ops: ecs_vec_t,
};
pub const EcsMetaTypeSerialized = struct_EcsMetaTypeSerialized;
pub const struct_ecs_meta_scope_t = extern struct {
    type: ecs_entity_t,
    ops: [*c]ecs_meta_type_op_t,
    op_count: i32,
    op_cur: i32,
    elem_cur: i32,
    prev_depth: i32,
    ptr: ?*anyopaque,
    comp: [*c]const EcsComponent,
    @"opaque": [*c]const EcsOpaque,
    vector: [*c]ecs_vec_t,
    members: [*c]ecs_hashmap_t,
    is_collection: bool,
    is_inline_array: bool,
    is_empty_scope: bool,
};
pub const ecs_meta_scope_t = struct_ecs_meta_scope_t;
pub const struct_ecs_meta_cursor_t = extern struct {
    world: ?*const ecs_world_t,
    scope: [32]ecs_meta_scope_t,
    depth: i32,
    valid: bool,
    is_primitive_scope: bool,
    lookup_action: ?*const fn (?*const ecs_world_t, [*c]const u8, ?*anyopaque) callconv(.C) ecs_entity_t,
    lookup_ctx: ?*anyopaque,
};
pub const ecs_meta_cursor_t = struct_ecs_meta_cursor_t;
pub extern fn ecs_meta_cursor(world: ?*const ecs_world_t, @"type": ecs_entity_t, ptr: ?*anyopaque) ecs_meta_cursor_t;
pub extern fn ecs_meta_get_ptr(cursor: [*c]ecs_meta_cursor_t) ?*anyopaque;
pub extern fn ecs_meta_next(cursor: [*c]ecs_meta_cursor_t) c_int;
pub extern fn ecs_meta_elem(cursor: [*c]ecs_meta_cursor_t, elem: i32) c_int;
pub extern fn ecs_meta_member(cursor: [*c]ecs_meta_cursor_t, name: [*c]const u8) c_int;
pub extern fn ecs_meta_dotmember(cursor: [*c]ecs_meta_cursor_t, name: [*c]const u8) c_int;
pub extern fn ecs_meta_push(cursor: [*c]ecs_meta_cursor_t) c_int;
pub extern fn ecs_meta_pop(cursor: [*c]ecs_meta_cursor_t) c_int;
pub extern fn ecs_meta_is_collection(cursor: [*c]const ecs_meta_cursor_t) bool;
pub extern fn ecs_meta_get_type(cursor: [*c]const ecs_meta_cursor_t) ecs_entity_t;
pub extern fn ecs_meta_get_unit(cursor: [*c]const ecs_meta_cursor_t) ecs_entity_t;
pub extern fn ecs_meta_get_member(cursor: [*c]const ecs_meta_cursor_t) [*c]const u8;
pub extern fn ecs_meta_set_bool(cursor: [*c]ecs_meta_cursor_t, value: bool) c_int;
pub extern fn ecs_meta_set_char(cursor: [*c]ecs_meta_cursor_t, value: u8) c_int;
pub extern fn ecs_meta_set_int(cursor: [*c]ecs_meta_cursor_t, value: i64) c_int;
pub extern fn ecs_meta_set_uint(cursor: [*c]ecs_meta_cursor_t, value: u64) c_int;
pub extern fn ecs_meta_set_float(cursor: [*c]ecs_meta_cursor_t, value: f64) c_int;
pub extern fn ecs_meta_set_string(cursor: [*c]ecs_meta_cursor_t, value: [*c]const u8) c_int;
pub extern fn ecs_meta_set_string_literal(cursor: [*c]ecs_meta_cursor_t, value: [*c]const u8) c_int;
pub extern fn ecs_meta_set_entity(cursor: [*c]ecs_meta_cursor_t, value: ecs_entity_t) c_int;
pub extern fn ecs_meta_set_null(cursor: [*c]ecs_meta_cursor_t) c_int;
pub extern fn ecs_meta_set_value(cursor: [*c]ecs_meta_cursor_t, value: [*c]const ecs_value_t) c_int;
pub extern fn ecs_meta_get_bool(cursor: [*c]const ecs_meta_cursor_t) bool;
pub extern fn ecs_meta_get_char(cursor: [*c]const ecs_meta_cursor_t) u8;
pub extern fn ecs_meta_get_int(cursor: [*c]const ecs_meta_cursor_t) i64;
pub extern fn ecs_meta_get_uint(cursor: [*c]const ecs_meta_cursor_t) u64;
pub extern fn ecs_meta_get_float(cursor: [*c]const ecs_meta_cursor_t) f64;
pub extern fn ecs_meta_get_string(cursor: [*c]const ecs_meta_cursor_t) [*c]const u8;
pub extern fn ecs_meta_get_entity(cursor: [*c]const ecs_meta_cursor_t) ecs_entity_t;
pub extern fn ecs_meta_ptr_to_float(type_kind: ecs_primitive_kind_t, ptr: ?*const anyopaque) f64;
pub const struct_ecs_primitive_desc_t = extern struct {
    entity: ecs_entity_t,
    kind: ecs_primitive_kind_t,
};
pub const ecs_primitive_desc_t = struct_ecs_primitive_desc_t;
pub extern fn ecs_primitive_init(world: ?*ecs_world_t, desc: [*c]const ecs_primitive_desc_t) ecs_entity_t;
pub const struct_ecs_enum_desc_t = extern struct {
    entity: ecs_entity_t,
    constants: [32]ecs_enum_constant_t,
};
pub const ecs_enum_desc_t = struct_ecs_enum_desc_t;
pub extern fn ecs_enum_init(world: ?*ecs_world_t, desc: [*c]const ecs_enum_desc_t) ecs_entity_t;
pub const struct_ecs_bitmask_desc_t = extern struct {
    entity: ecs_entity_t,
    constants: [32]ecs_bitmask_constant_t,
};
pub const ecs_bitmask_desc_t = struct_ecs_bitmask_desc_t;
pub extern fn ecs_bitmask_init(world: ?*ecs_world_t, desc: [*c]const ecs_bitmask_desc_t) ecs_entity_t;
pub const struct_ecs_array_desc_t = extern struct {
    entity: ecs_entity_t,
    type: ecs_entity_t,
    count: i32,
};
pub const ecs_array_desc_t = struct_ecs_array_desc_t;
pub extern fn ecs_array_init(world: ?*ecs_world_t, desc: [*c]const ecs_array_desc_t) ecs_entity_t;
pub const struct_ecs_vector_desc_t = extern struct {
    entity: ecs_entity_t,
    type: ecs_entity_t,
};
pub const ecs_vector_desc_t = struct_ecs_vector_desc_t;
pub extern fn ecs_vector_init(world: ?*ecs_world_t, desc: [*c]const ecs_vector_desc_t) ecs_entity_t;
pub const struct_ecs_struct_desc_t = extern struct {
    entity: ecs_entity_t,
    members: [32]ecs_member_t,
};
pub const ecs_struct_desc_t = struct_ecs_struct_desc_t;
pub extern fn ecs_struct_init(world: ?*ecs_world_t, desc: [*c]const ecs_struct_desc_t) ecs_entity_t;
pub const struct_ecs_opaque_desc_t = extern struct {
    entity: ecs_entity_t,
    type: EcsOpaque,
};
pub const ecs_opaque_desc_t = struct_ecs_opaque_desc_t;
pub extern fn ecs_opaque_init(world: ?*ecs_world_t, desc: [*c]const ecs_opaque_desc_t) ecs_entity_t;
pub const struct_ecs_unit_desc_t = extern struct {
    entity: ecs_entity_t,
    symbol: [*c]const u8,
    quantity: ecs_entity_t,
    base: ecs_entity_t,
    over: ecs_entity_t,
    translation: ecs_unit_translation_t,
    prefix: ecs_entity_t,
};
pub const ecs_unit_desc_t = struct_ecs_unit_desc_t;
pub extern fn ecs_unit_init(world: ?*ecs_world_t, desc: [*c]const ecs_unit_desc_t) ecs_entity_t;
pub const struct_ecs_unit_prefix_desc_t = extern struct {
    entity: ecs_entity_t,
    symbol: [*c]const u8,
    translation: ecs_unit_translation_t,
};
pub const ecs_unit_prefix_desc_t = struct_ecs_unit_prefix_desc_t;
pub extern fn ecs_unit_prefix_init(world: ?*ecs_world_t, desc: [*c]const ecs_unit_prefix_desc_t) ecs_entity_t;
pub extern fn ecs_quantity_init(world: ?*ecs_world_t, desc: [*c]const ecs_entity_desc_t) ecs_entity_t;
pub extern fn FlecsMetaImport(world: ?*ecs_world_t) void;
pub extern fn ecs_chresc(out: [*c]u8, in: u8, delimiter: u8) [*c]u8;
pub extern fn ecs_chrparse(in: [*c]const u8, out: [*c]u8) [*c]const u8;
pub extern fn ecs_stresc(out: [*c]u8, size: ecs_size_t, delimiter: u8, in: [*c]const u8) ecs_size_t;
pub extern fn ecs_astresc(delimiter: u8, in: [*c]const u8) [*c]u8;
pub const struct_ecs_expr_var_t = extern struct {
    name: [*c]u8,
    value: ecs_value_t,
    owned: bool,
};
pub const ecs_expr_var_t = struct_ecs_expr_var_t;
pub const struct_ecs_expr_var_scope_t = extern struct {
    var_index: ecs_hashmap_t,
    vars: ecs_vec_t,
    parent: [*c]struct_ecs_expr_var_scope_t,
};
pub const ecs_expr_var_scope_t = struct_ecs_expr_var_scope_t;
pub const struct_ecs_vars_t = extern struct {
    world: ?*ecs_world_t,
    root: ecs_expr_var_scope_t,
    cur: [*c]ecs_expr_var_scope_t,
};
pub const ecs_vars_t = struct_ecs_vars_t;
pub extern fn ecs_vars_init(world: ?*ecs_world_t, vars: [*c]ecs_vars_t) void;
pub extern fn ecs_vars_fini(vars: [*c]ecs_vars_t) void;
pub extern fn ecs_vars_push(vars: [*c]ecs_vars_t) void;
pub extern fn ecs_vars_pop(vars: [*c]ecs_vars_t) c_int;
pub extern fn ecs_vars_declare(vars: [*c]ecs_vars_t, name: [*c]const u8, @"type": ecs_entity_t) [*c]ecs_expr_var_t;
pub extern fn ecs_vars_declare_w_value(vars: [*c]ecs_vars_t, name: [*c]const u8, value: [*c]ecs_value_t) [*c]ecs_expr_var_t;
pub extern fn ecs_vars_lookup(vars: [*c]const ecs_vars_t, name: [*c]const u8) [*c]ecs_expr_var_t;
pub const struct_ecs_parse_expr_desc_t = extern struct {
    name: [*c]const u8,
    expr: [*c]const u8,
    lookup_action: ?*const fn (?*const ecs_world_t, [*c]const u8, ?*anyopaque) callconv(.C) ecs_entity_t,
    lookup_ctx: ?*anyopaque,
    vars: [*c]ecs_vars_t,
};
pub const ecs_parse_expr_desc_t = struct_ecs_parse_expr_desc_t;
pub extern fn ecs_parse_expr(world: ?*ecs_world_t, ptr: [*c]const u8, value: [*c]ecs_value_t, desc: [*c]const ecs_parse_expr_desc_t) [*c]const u8;
pub extern fn ecs_ptr_to_expr(world: ?*const ecs_world_t, @"type": ecs_entity_t, data: ?*const anyopaque) [*c]u8;
pub extern fn ecs_ptr_to_expr_buf(world: ?*const ecs_world_t, @"type": ecs_entity_t, data: ?*const anyopaque, buf: [*c]ecs_strbuf_t) c_int;
pub extern fn ecs_ptr_to_str(world: ?*const ecs_world_t, @"type": ecs_entity_t, data: ?*const anyopaque) [*c]u8;
pub extern fn ecs_ptr_to_str_buf(world: ?*const ecs_world_t, @"type": ecs_entity_t, data: ?*const anyopaque, buf: [*c]ecs_strbuf_t) c_int;
pub extern fn ecs_primitive_to_expr_buf(world: ?*const ecs_world_t, kind: ecs_primitive_kind_t, data: ?*const anyopaque, buf: [*c]ecs_strbuf_t) c_int;
pub extern fn ecs_parse_expr_token(name: [*c]const u8, expr: [*c]const u8, ptr: [*c]const u8, token: [*c]u8) [*c]const u8;
pub extern fn ecs_interpolate_string(world: ?*ecs_world_t, str: [*c]const u8, vars: [*c]const ecs_vars_t) [*c]u8;
pub extern fn ecs_iter_to_vars(it: [*c]const ecs_iter_t, vars: [*c]ecs_vars_t, offset: c_int) void;
pub extern fn ecs_meta_from_desc(world: ?*ecs_world_t, component: ecs_entity_t, kind: ecs_type_kind_t, desc: [*c]const u8) c_int;
pub extern var FLECS_IDEcsScriptID_: ecs_entity_t;
pub const struct_EcsScript = extern struct {
    using_: ecs_vec_t,
    script: [*c]u8,
    prop_defaults: ecs_vec_t,
    world: ?*ecs_world_t,
};
pub const EcsScript = struct_EcsScript;
pub extern fn ecs_plecs_from_str(world: ?*ecs_world_t, name: [*c]const u8, str: [*c]const u8) c_int;
pub extern fn ecs_plecs_from_file(world: ?*ecs_world_t, filename: [*c]const u8) c_int;
pub const struct_ecs_script_desc_t = extern struct {
    entity: ecs_entity_t,
    filename: [*c]const u8,
    str: [*c]const u8,
};
pub const ecs_script_desc_t = struct_ecs_script_desc_t;
pub extern fn ecs_script_init(world: ?*ecs_world_t, desc: [*c]const ecs_script_desc_t) ecs_entity_t;
pub extern fn ecs_script_update(world: ?*ecs_world_t, script: ecs_entity_t, instance: ecs_entity_t, str: [*c]const u8, vars: [*c]ecs_vars_t) c_int;
pub extern fn ecs_script_clear(world: ?*ecs_world_t, script: ecs_entity_t, instance: ecs_entity_t) void;
pub extern fn FlecsScriptImport(world: ?*ecs_world_t) void;
pub extern fn ecs_rule_init(world: ?*ecs_world_t, desc: [*c]const ecs_filter_desc_t) ?*ecs_rule_t;
pub extern fn ecs_rule_fini(rule: ?*ecs_rule_t) void;
pub extern fn ecs_rule_get_filter(rule: ?*const ecs_rule_t) [*c]const ecs_filter_t;
pub extern fn ecs_rule_var_count(rule: ?*const ecs_rule_t) i32;
pub extern fn ecs_rule_find_var(rule: ?*const ecs_rule_t, name: [*c]const u8) i32;
pub extern fn ecs_rule_var_name(rule: ?*const ecs_rule_t, var_id: i32) [*c]const u8;
pub extern fn ecs_rule_var_is_entity(rule: ?*const ecs_rule_t, var_id: i32) bool;
pub extern fn ecs_rule_iter(world: ?*const ecs_world_t, rule: ?*const ecs_rule_t) ecs_iter_t;
pub extern fn ecs_rule_next(it: [*c]ecs_iter_t) bool;
pub extern fn ecs_rule_next_instanced(it: [*c]ecs_iter_t) bool;
pub extern fn ecs_rule_str(rule: ?*const ecs_rule_t) [*c]u8;
pub extern fn ecs_rule_str_w_profile(rule: ?*const ecs_rule_t, it: [*c]const ecs_iter_t) [*c]u8;
pub extern fn ecs_rule_parse_vars(rule: ?*ecs_rule_t, it: [*c]ecs_iter_t, expr: [*c]const u8) [*c]const u8;
pub const struct_ecs_snapshot_t = opaque {};
pub const ecs_snapshot_t = struct_ecs_snapshot_t;
pub extern fn ecs_snapshot_take(world: ?*ecs_world_t) ?*ecs_snapshot_t;
pub extern fn ecs_snapshot_take_w_iter(iter: [*c]ecs_iter_t) ?*ecs_snapshot_t;
pub extern fn ecs_snapshot_restore(world: ?*ecs_world_t, snapshot: ?*ecs_snapshot_t) void;
pub extern fn ecs_snapshot_iter(snapshot: ?*ecs_snapshot_t) ecs_iter_t;
pub extern fn ecs_snapshot_next(iter: [*c]ecs_iter_t) bool;
pub extern fn ecs_snapshot_free(snapshot: ?*ecs_snapshot_t) void;
pub extern fn ecs_parse_ws(ptr: [*c]const u8) [*c]const u8;
pub extern fn ecs_parse_ws_eol(ptr: [*c]const u8) [*c]const u8;
pub extern fn ecs_parse_identifier(name: [*c]const u8, expr: [*c]const u8, ptr: [*c]const u8, token_out: [*c]u8) [*c]const u8;
pub extern fn ecs_parse_digit(ptr: [*c]const u8, token: [*c]u8) [*c]const u8;
pub extern fn ecs_parse_token(name: [*c]const u8, expr: [*c]const u8, ptr: [*c]const u8, token_out: [*c]u8, delim: u8) [*c]const u8;
pub extern fn ecs_parse_term(world: ?*const ecs_world_t, name: [*c]const u8, expr: [*c]const u8, ptr: [*c]const u8, term_out: [*c]ecs_term_t) [*c]u8;
pub extern fn ecs_set_os_api_impl() void;
pub extern fn ecs_import(world: ?*ecs_world_t, module: ecs_module_action_t, module_name: [*c]const u8) ecs_entity_t;
pub extern fn ecs_import_c(world: ?*ecs_world_t, module: ecs_module_action_t, module_name_c: [*c]const u8) ecs_entity_t;
pub extern fn ecs_import_from_library(world: ?*ecs_world_t, library_name: [*c]const u8, module_name: [*c]const u8) ecs_entity_t;
pub extern fn ecs_module_init(world: ?*ecs_world_t, c_name: [*c]const u8, desc: [*c]const ecs_component_desc_t) ecs_entity_t;
pub extern fn ecs_cpp_get_type_name(type_name: [*c]u8, func_name: [*c]const u8, len: usize, front_len: usize) [*c]u8;
pub extern fn ecs_cpp_get_symbol_name(symbol_name: [*c]u8, type_name: [*c]const u8, len: usize) [*c]u8;
pub extern fn ecs_cpp_get_constant_name(constant_name: [*c]u8, func_name: [*c]const u8, len: usize, back_len: usize) [*c]u8;
pub extern fn ecs_cpp_trim_module(world: ?*ecs_world_t, type_name: [*c]const u8) [*c]const u8;
pub extern fn ecs_cpp_component_validate(world: ?*ecs_world_t, id: ecs_entity_t, name: [*c]const u8, symbol: [*c]const u8, size: usize, alignment: usize, implicit_name: bool) void;
pub extern fn ecs_cpp_component_register(world: ?*ecs_world_t, id: ecs_entity_t, name: [*c]const u8, symbol: [*c]const u8, size: ecs_size_t, alignment: ecs_size_t, implicit_name: bool, existing_out: [*c]bool) ecs_entity_t;
pub extern fn ecs_cpp_component_register_explicit(world: ?*ecs_world_t, s_id: ecs_entity_t, id: ecs_entity_t, name: [*c]const u8, type_name: [*c]const u8, symbol: [*c]const u8, size: usize, alignment: usize, is_component: bool, existing_out: [*c]bool) ecs_entity_t;
pub extern fn ecs_cpp_enum_init(world: ?*ecs_world_t, id: ecs_entity_t) void;
pub extern fn ecs_cpp_enum_constant_register(world: ?*ecs_world_t, parent: ecs_entity_t, id: ecs_entity_t, name: [*c]const u8, value: c_int) ecs_entity_t;
pub extern fn ecs_cpp_reset_count_get() i32;
pub extern fn ecs_cpp_reset_count_inc() i32;
pub extern fn ecs_cpp_last_member(world: ?*const ecs_world_t, @"type": ecs_entity_t) [*c]const ecs_member_t;

pub const flecs_STATIC = "";
pub const FLECS_H = "";
pub const ecs_float_t = f32;
pub const ecs_ftime_t = ecs_float_t;
pub const FLECS_NO_DEPRECATED_WARNINGS = "";
pub const FLECS_DEBUG = "";
pub const FLECS_CPP = "";
pub const FLECS_MODULE = "";
pub const FLECS_PARSER = "";
pub const FLECS_PLECS = "";
pub const FLECS_RULES = "";
pub const FLECS_SNAPSHOT = "";
pub const FLECS_STATS = "";
pub const FLECS_MONITOR = "";
pub const FLECS_METRICS = "";
pub const FLECS_ALERTS = "";
pub const FLECS_SYSTEM = "";
pub const FLECS_PIPELINE = "";
pub const FLECS_TIMER = "";
pub const FLECS_META = "";
pub const FLECS_META_C = "";
pub const FLECS_UNITS = "";
pub const FLECS_EXPR = "";
pub const FLECS_JSON = "";
pub const FLECS_DOC = "";
pub const FLECS_COREDOC = "";
pub const FLECS_LOG = "";
pub const FLECS_APP = "";
pub const FLECS_OS_API_IMPL = "";
pub const FLECS_HTTP = "";
pub const FLECS_REST = "";
pub const FLECS_HI_COMPONENT_ID = @as(c_int, 256);
pub const FLECS_HI_ID_RECORD_ID = @as(c_int, 1024);
pub const FLECS_SPARSE_PAGE_BITS = @as(c_int, 12);
pub const FLECS_ENTITY_PAGE_BITS = @as(c_int, 12);
pub const FLECS_ID_DESC_MAX = @as(c_int, 32);
pub const FLECS_TERM_DESC_MAX = @as(c_int, 16);
pub const FLECS_EVENT_DESC_MAX = @as(c_int, 8);
pub const FLECS_VARIABLE_COUNT_MAX = @as(c_int, 64);
pub const FLECS_QUERY_SCOPE_NESTING_MAX = @as(c_int, 8);
pub const FLECS_API_DEFINES_H = "";
pub const FLECS_API_FLAGS_H = "";
pub const EcsWorldQuitWorkers = @as(c_uint, 1) << @as(c_int, 0);
pub const EcsWorldReadonly = @as(c_uint, 1) << @as(c_int, 1);
pub const EcsWorldInit = @as(c_uint, 1) << @as(c_int, 2);
pub const EcsWorldQuit = @as(c_uint, 1) << @as(c_int, 3);
pub const EcsWorldFini = @as(c_uint, 1) << @as(c_int, 4);
pub const EcsWorldMeasureFrameTime = @as(c_uint, 1) << @as(c_int, 5);
pub const EcsWorldMeasureSystemTime = @as(c_uint, 1) << @as(c_int, 6);
pub const EcsWorldMultiThreaded = @as(c_uint, 1) << @as(c_int, 7);
pub const EcsOsApiHighResolutionTimer = @as(c_uint, 1) << @as(c_int, 0);
pub const EcsOsApiLogWithColors = @as(c_uint, 1) << @as(c_int, 1);
pub const EcsOsApiLogWithTimeStamp = @as(c_uint, 1) << @as(c_int, 2);
pub const EcsOsApiLogWithTimeDelta = @as(c_uint, 1) << @as(c_int, 3);
pub const EcsEntityIsId = @as(c_uint, 1) << @as(c_int, 31);
pub const EcsEntityIsTarget = @as(c_uint, 1) << @as(c_int, 30);
pub const EcsEntityIsTraversable = @as(c_uint, 1) << @as(c_int, 29);
pub const EcsIdOnDeleteRemove = @as(c_uint, 1) << @as(c_int, 0);
pub const EcsIdOnDeleteDelete = @as(c_uint, 1) << @as(c_int, 1);
pub const EcsIdOnDeletePanic = @as(c_uint, 1) << @as(c_int, 2);
pub const EcsIdOnDeleteMask = (EcsIdOnDeletePanic | EcsIdOnDeleteRemove) | EcsIdOnDeleteDelete;
pub const EcsIdOnDeleteObjectRemove = @as(c_uint, 1) << @as(c_int, 3);
pub const EcsIdOnDeleteObjectDelete = @as(c_uint, 1) << @as(c_int, 4);
pub const EcsIdOnDeleteObjectPanic = @as(c_uint, 1) << @as(c_int, 5);
pub const EcsIdOnDeleteObjectMask = (EcsIdOnDeleteObjectPanic | EcsIdOnDeleteObjectRemove) | EcsIdOnDeleteObjectDelete;
pub const EcsIdExclusive = @as(c_uint, 1) << @as(c_int, 6);
pub const EcsIdDontInherit = @as(c_uint, 1) << @as(c_int, 7);
pub const EcsIdTraversable = @as(c_uint, 1) << @as(c_int, 8);
pub const EcsIdTag = @as(c_uint, 1) << @as(c_int, 9);
pub const EcsIdWith = @as(c_uint, 1) << @as(c_int, 10);
pub const EcsIdUnion = @as(c_uint, 1) << @as(c_int, 11);
pub const EcsIdAlwaysOverride = @as(c_uint, 1) << @as(c_int, 12);
pub const EcsIdHasOnAdd = @as(c_uint, 1) << @as(c_int, 16);
pub const EcsIdHasOnRemove = @as(c_uint, 1) << @as(c_int, 17);
pub const EcsIdHasOnSet = @as(c_uint, 1) << @as(c_int, 18);
pub const EcsIdHasUnSet = @as(c_uint, 1) << @as(c_int, 19);
pub const EcsIdHasOnTableFill = @as(c_uint, 1) << @as(c_int, 20);
pub const EcsIdHasOnTableEmpty = @as(c_uint, 1) << @as(c_int, 21);
pub const EcsIdHasOnTableCreate = @as(c_uint, 1) << @as(c_int, 22);
pub const EcsIdHasOnTableDelete = @as(c_uint, 1) << @as(c_int, 23);
pub const EcsIdEventMask = ((((((EcsIdHasOnAdd | EcsIdHasOnRemove) | EcsIdHasOnSet) | EcsIdHasUnSet) | EcsIdHasOnTableFill) | EcsIdHasOnTableEmpty) | EcsIdHasOnTableCreate) | EcsIdHasOnTableDelete;
pub const EcsIdMarkedForDelete = @as(c_uint, 1) << @as(c_int, 30);

pub inline fn ECS_ID_ON_DELETE_FLAG(id: anytype) @TypeOf(@as(c_uint, 1) << (id - EcsRemove)) {
    return @as(c_uint, 1) << (id - EcsRemove);
}
pub inline fn ECS_ID_ON_DELETE_TARGET_FLAG(id: anytype) @TypeOf(@as(c_uint, 1) << (@as(c_int, 3) + (id - EcsRemove))) {
    return @as(c_uint, 1) << (@as(c_int, 3) + (id - EcsRemove));
}
pub const EcsIterIsValid = @as(c_uint, 1) << @as(c_uint, 0);
pub const EcsIterNoData = @as(c_uint, 1) << @as(c_uint, 1);
pub const EcsIterIsInstanced = @as(c_uint, 1) << @as(c_uint, 2);
pub const EcsIterHasShared = @as(c_uint, 1) << @as(c_uint, 3);
pub const EcsIterTableOnly = @as(c_uint, 1) << @as(c_uint, 4);
pub const EcsIterEntityOptional = @as(c_uint, 1) << @as(c_uint, 5);
pub const EcsIterNoResults = @as(c_uint, 1) << @as(c_uint, 6);
pub const EcsIterIgnoreThis = @as(c_uint, 1) << @as(c_uint, 7);
pub const EcsIterMatchVar = @as(c_uint, 1) << @as(c_uint, 8);
pub const EcsIterHasCondSet = @as(c_uint, 1) << @as(c_uint, 10);
pub const EcsIterProfile = @as(c_uint, 1) << @as(c_uint, 11);
pub const EcsEventTableOnly = @as(c_uint, 1) << @as(c_uint, 4);
pub const EcsEventNoOnSet = @as(c_uint, 1) << @as(c_uint, 16);
pub const EcsFilterMatchThis = @as(c_uint, 1) << @as(c_uint, 1);
pub const EcsFilterMatchOnlyThis = @as(c_uint, 1) << @as(c_uint, 2);
pub const EcsFilterMatchPrefab = @as(c_uint, 1) << @as(c_uint, 3);
pub const EcsFilterMatchDisabled = @as(c_uint, 1) << @as(c_uint, 4);
pub const EcsFilterMatchEmptyTables = @as(c_uint, 1) << @as(c_uint, 5);
pub const EcsFilterMatchAnything = @as(c_uint, 1) << @as(c_uint, 6);
pub const EcsFilterNoData = @as(c_uint, 1) << @as(c_uint, 7);
pub const EcsFilterIsInstanced = @as(c_uint, 1) << @as(c_uint, 8);
pub const EcsFilterPopulate = @as(c_uint, 1) << @as(c_uint, 9);
pub const EcsFilterHasCondSet = @as(c_uint, 1) << @as(c_uint, 10);
pub const EcsFilterUnresolvedByName = @as(c_uint, 1) << @as(c_uint, 11);
pub const EcsFilterHasPred = @as(c_uint, 1) << @as(c_uint, 12);
pub const EcsFilterHasScopes = @as(c_uint, 1) << @as(c_uint, 13);
pub const EcsTableHasBuiltins = @as(c_uint, 1) << @as(c_uint, 1);
pub const EcsTableIsPrefab = @as(c_uint, 1) << @as(c_uint, 2);
pub const EcsTableHasIsA = @as(c_uint, 1) << @as(c_uint, 3);
pub const EcsTableHasChildOf = @as(c_uint, 1) << @as(c_uint, 4);
pub const EcsTableHasName = @as(c_uint, 1) << @as(c_uint, 5);
pub const EcsTableHasPairs = @as(c_uint, 1) << @as(c_uint, 6);
pub const EcsTableHasModule = @as(c_uint, 1) << @as(c_uint, 7);
pub const EcsTableIsDisabled = @as(c_uint, 1) << @as(c_uint, 8);
pub const EcsTableHasCtors = @as(c_uint, 1) << @as(c_uint, 9);
pub const EcsTableHasDtors = @as(c_uint, 1) << @as(c_uint, 10);
pub const EcsTableHasCopy = @as(c_uint, 1) << @as(c_uint, 11);
pub const EcsTableHasMove = @as(c_uint, 1) << @as(c_uint, 12);
pub const EcsTableHasUnion = @as(c_uint, 1) << @as(c_uint, 13);
pub const EcsTableHasToggle = @as(c_uint, 1) << @as(c_uint, 14);
pub const EcsTableHasOverrides = @as(c_uint, 1) << @as(c_uint, 15);
pub const EcsTableHasOnAdd = @as(c_uint, 1) << @as(c_uint, 16);
pub const EcsTableHasOnRemove = @as(c_uint, 1) << @as(c_uint, 17);
pub const EcsTableHasOnSet = @as(c_uint, 1) << @as(c_uint, 18);
pub const EcsTableHasUnSet = @as(c_uint, 1) << @as(c_uint, 19);
pub const EcsTableHasOnTableFill = @as(c_uint, 1) << @as(c_uint, 20);
pub const EcsTableHasOnTableEmpty = @as(c_uint, 1) << @as(c_uint, 21);
pub const EcsTableHasOnTableCreate = @as(c_uint, 1) << @as(c_uint, 22);
pub const EcsTableHasOnTableDelete = @as(c_uint, 1) << @as(c_uint, 23);
pub const EcsTableHasTraversable = @as(c_uint, 1) << @as(c_uint, 25);
pub const EcsTableHasTarget = @as(c_uint, 1) << @as(c_uint, 26);
pub const EcsTableMarkedForDelete = @as(c_uint, 1) << @as(c_uint, 30);
pub const EcsTableHasLifecycle = EcsTableHasCtors | EcsTableHasDtors;
pub const EcsTableIsComplex = (EcsTableHasLifecycle | EcsTableHasUnion) | EcsTableHasToggle;
pub const EcsTableHasAddActions = (((EcsTableHasIsA | EcsTableHasUnion) | EcsTableHasCtors) | EcsTableHasOnAdd) | EcsTableHasOnSet;
pub const EcsTableHasRemoveActions = ((EcsTableHasIsA | EcsTableHasDtors) | EcsTableHasOnRemove) | EcsTableHasUnSet;
pub const EcsQueryHasRefs = @as(c_uint, 1) << @as(c_uint, 1);
pub const EcsQueryIsSubquery = @as(c_uint, 1) << @as(c_uint, 2);
pub const EcsQueryIsOrphaned = @as(c_uint, 1) << @as(c_uint, 3);
pub const EcsQueryHasOutTerms = @as(c_uint, 1) << @as(c_uint, 4);
pub const EcsQueryHasNonThisOutTerms = @as(c_uint, 1) << @as(c_uint, 5);
pub const EcsQueryHasMonitor = @as(c_uint, 1) << @as(c_uint, 6);
pub const EcsQueryTrivialIter = @as(c_uint, 1) << @as(c_uint, 7);
pub const EcsAperiodicEmptyTables = @as(c_uint, 1) << @as(c_uint, 1);
pub const EcsAperiodicComponentMonitors = @as(c_uint, 1) << @as(c_uint, 2);
pub const EcsAperiodicEmptyQueries = @as(c_uint, 1) << @as(c_uint, 4);
pub const ECS_TARGET_DARWIN = "";
pub const ECS_TARGET_POSIX = "";
pub const ECS_TARGET_CLANG = "";
pub const ECS_TARGET_GNU = "";

pub const NULL = @import("std").zig.c_translation.cast(?*anyopaque, @as(c_int, 0));

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
pub const WINT_MIN = INT32_MIN;
pub const WINT_MAX = INT32_MAX;
pub const SIG_ATOMIC_MIN = INT32_MIN;
pub const SIG_ATOMIC_MAX = INT32_MAX;
pub const FLECS_BAKE_CONFIG_H = "";
pub const FLECS_API = "";
pub const FLECS_DBG_API = FLECS_API;
pub const __STDBOOL_H = "";
pub const __bool_true_false_are_defined = @as(c_int, 1);
pub const @"bool" = bool;
pub const @"true" = @as(c_int, 1);
pub const @"false" = @as(c_int, 0);
pub inline fn ECS_SIZEOF(T: anytype) @TypeOf(ECS_CAST(ecs_size_t, @import("std").zig.c_translation.sizeof(T))) {
    _ = @TypeOf(T);
    return ECS_CAST(ecs_size_t, @import("std").zig.c_translation.sizeof(T));
}
pub inline fn ECS_ALIGN(size: anytype, alignment: anytype) ecs_size_t {
    return @import("std").zig.c_translation.cast(ecs_size_t, (@import("std").zig.c_translation.MacroArithmetic.div(@import("std").zig.c_translation.cast(usize, size) - @as(c_int, 1), @import("std").zig.c_translation.cast(usize, alignment)) + @as(c_int, 1)) * @import("std").zig.c_translation.cast(usize, alignment));
}
pub inline fn ECS_MAX(a: anytype, b: anytype) @TypeOf(if (a > b) a else b) {
    return if (a > b) a else b;
}
pub inline fn ECS_MIN(a: anytype, b: anytype) @TypeOf(if (a < b) a else b) {
    return if (a < b) a else b;
}
pub const ECS_CAST = @import("std").zig.c_translation.Macros.CAST_OR_CALL;
pub inline fn ECS_CONST_CAST(@"type": anytype, value: anytype) @TypeOf(@"type"(usize)(value)) {
    return @"type"(usize)(value);
}
pub inline fn ECS_PTR_CAST(@"type": anytype, value: anytype) @TypeOf(@"type"(usize)(value)) {
    return @"type"(usize)(value);
}
pub inline fn ECS_EQ(a: anytype, b: anytype) @TypeOf(ecs_os_memcmp(&a, &b, @import("std").zig.c_translation.sizeof(a)) == @as(c_int, 0)) {
    return ecs_os_memcmp(&a, &b, @import("std").zig.c_translation.sizeof(a)) == @as(c_int, 0);
}
pub inline fn ECS_NEQ(a: anytype, b: anytype) @TypeOf(!(ECS_EQ(a, b) != 0)) {
    return !(ECS_EQ(a, b) != 0);
}
pub inline fn ECS_EQZERO(a: anytype) @TypeOf(ECS_EQ(a, @import("std").mem.zeroInit(u64, .{@as(c_int, 0)}))) {
    return ECS_EQ(a, @import("std").mem.zeroInit(u64, .{@as(c_int, 0)}));
}
pub inline fn ECS_NEQZERO(a: anytype) @TypeOf(ECS_NEQ(a, @import("std").mem.zeroInit(u64, .{@as(c_int, 0)}))) {
    return ECS_NEQ(a, @import("std").mem.zeroInit(u64, .{@as(c_int, 0)}));
}
pub const ecs_world_t_magic = @import("std").zig.c_translation.promoteIntLiteral(c_int, 0x65637377, .hexadecimal);
pub const ecs_stage_t_magic = @import("std").zig.c_translation.promoteIntLiteral(c_int, 0x65637373, .hexadecimal);
pub const ecs_query_t_magic = @import("std").zig.c_translation.promoteIntLiteral(c_int, 0x65637371, .hexadecimal);
pub const ecs_rule_t_magic = @import("std").zig.c_translation.promoteIntLiteral(c_int, 0x65637375, .hexadecimal);
pub const ecs_table_t_magic = @import("std").zig.c_translation.promoteIntLiteral(c_int, 0x65637374, .hexadecimal);
pub const ecs_filter_t_magic = @import("std").zig.c_translation.promoteIntLiteral(c_int, 0x65637366, .hexadecimal);
pub const ecs_trigger_t_magic = @import("std").zig.c_translation.promoteIntLiteral(c_int, 0x65637372, .hexadecimal);
pub const ecs_observer_t_magic = @import("std").zig.c_translation.promoteIntLiteral(c_int, 0x65637362, .hexadecimal);
pub const ECS_ROW_MASK = @import("std").zig.c_translation.promoteIntLiteral(c_uint, 0x0FFFFFFF, .hexadecimal);
pub const ECS_ROW_FLAGS_MASK = ~ECS_ROW_MASK;
pub inline fn ECS_RECORD_TO_ROW(v: anytype) @TypeOf(ECS_CAST(i32, ECS_CAST(u32, v) & ECS_ROW_MASK)) {
    return ECS_CAST(i32, ECS_CAST(u32, v) & ECS_ROW_MASK);
}
pub inline fn ECS_RECORD_TO_ROW_FLAGS(v: anytype) @TypeOf(ECS_CAST(u32, v) & ECS_ROW_FLAGS_MASK) {
    return ECS_CAST(u32, v) & ECS_ROW_FLAGS_MASK;
}
pub inline fn ECS_ROW_TO_RECORD(row: anytype, flags: anytype) @TypeOf(ECS_CAST(u32, ECS_CAST(u32, row) | flags)) {
    return ECS_CAST(u32, ECS_CAST(u32, row) | flags);
}
pub const ECS_ID_FLAGS_MASK = @as(c_ulonglong, 0xFF) << @as(c_int, 60);
pub const ECS_ENTITY_MASK = @as(c_ulonglong, 0xFFFFFFFF);
pub const ECS_GENERATION_MASK = @as(c_ulonglong, 0xFFFF) << @as(c_int, 32);
pub inline fn ECS_GENERATION(e: anytype) @TypeOf((e & ECS_GENERATION_MASK) >> @as(c_int, 32)) {
    return (e & ECS_GENERATION_MASK) >> @as(c_int, 32);
}
pub inline fn ECS_GENERATION_INC(e: anytype) @TypeOf((e & ~ECS_GENERATION_MASK) | ((@import("std").zig.c_translation.promoteIntLiteral(c_int, 0xFFFF, .hexadecimal) & (ECS_GENERATION(e) + @as(c_int, 1))) << @as(c_int, 32))) {
    return (e & ~ECS_GENERATION_MASK) | ((@import("std").zig.c_translation.promoteIntLiteral(c_int, 0xFFFF, .hexadecimal) & (ECS_GENERATION(e) + @as(c_int, 1))) << @as(c_int, 32));
}
pub const ECS_COMPONENT_MASK = ~ECS_ID_FLAGS_MASK;
pub inline fn ECS_IS_PAIR(id: anytype) @TypeOf((id & ECS_ID_FLAGS_MASK) == ECS_PAIR) {
    return (id & ECS_ID_FLAGS_MASK) == ECS_PAIR;
}
pub inline fn ECS_PAIR_FIRST(e: anytype) @TypeOf(ecs_entity_t_hi(e & ECS_COMPONENT_MASK)) {
    return ecs_entity_t_hi(e & ECS_COMPONENT_MASK);
}
pub inline fn ECS_PAIR_SECOND(e: anytype) @TypeOf(ecs_entity_t_lo(e)) {
    return ecs_entity_t_lo(e);
}
pub inline fn ecs_entity_t_lo(value: anytype) @TypeOf(ECS_CAST(u32, value)) {
    return ECS_CAST(u32, value);
}
pub inline fn ecs_entity_t_hi(value: anytype) @TypeOf(ECS_CAST(u32, value >> @as(c_int, 32))) {
    return ECS_CAST(u32, value >> @as(c_int, 32));
}
pub inline fn ecs_entity_t_comb(lo: anytype, hi: anytype) @TypeOf((ECS_CAST(u64, hi) << @as(c_int, 32)) + ECS_CAST(u32, lo)) {
    return (ECS_CAST(u64, hi) << @as(c_int, 32)) + ECS_CAST(u32, lo);
}
pub inline fn ecs_pair(pred: anytype, obj: anytype) @TypeOf(ECS_PAIR | ecs_entity_t_comb(obj, pred)) {
    return ECS_PAIR | ecs_entity_t_comb(obj, pred);
}
pub inline fn ecs_pair_first(world: anytype, pair: anytype) @TypeOf(ecs_get_alive(world, ECS_PAIR_FIRST(pair))) {
    return ecs_get_alive(world, ECS_PAIR_FIRST(pair));
}
pub inline fn ecs_pair_second(world: anytype, pair: anytype) @TypeOf(ecs_get_alive(world, ECS_PAIR_SECOND(pair))) {
    return ecs_get_alive(world, ECS_PAIR_SECOND(pair));
}
pub const ecs_pair_relation = ecs_pair_first;
pub const ecs_pair_object = ecs_pair_second;

pub inline fn ECS_TABLE_UNLOCK(world: anytype, table: anytype) @TypeOf(ecs_table_unlock(world, table)) {
    return ecs_table_unlock(world, table);
}
pub const EcsIterNextYield = @as(c_int, 0);
pub const EcsIterYield = -@as(c_int, 1);
pub const EcsIterNext = @as(c_int, 1);
pub const FLECS_VEC_H = "";
pub inline fn ecs_vec_init_t(allocator: anytype, vec: anytype, T: anytype, elem_count: anytype) @TypeOf(ecs_vec_init(allocator, vec, ECS_SIZEOF(T), elem_count)) {
    return ecs_vec_init(allocator, vec, ECS_SIZEOF(T), elem_count);
}
pub inline fn ecs_vec_init_if_t(vec: anytype, T: anytype) @TypeOf(ecs_vec_init_if(vec, ECS_SIZEOF(T))) {
    return ecs_vec_init_if(vec, ECS_SIZEOF(T));
}
pub inline fn ecs_vec_fini_t(allocator: anytype, vec: anytype, T: anytype) @TypeOf(ecs_vec_fini(allocator, vec, ECS_SIZEOF(T))) {
    return ecs_vec_fini(allocator, vec, ECS_SIZEOF(T));
}
pub inline fn ecs_vec_reset_t(allocator: anytype, vec: anytype, T: anytype) @TypeOf(ecs_vec_reset(allocator, vec, ECS_SIZEOF(T))) {
    return ecs_vec_reset(allocator, vec, ECS_SIZEOF(T));
}
pub inline fn ecs_vec_remove_t(vec: anytype, T: anytype, elem: anytype) @TypeOf(ecs_vec_remove(vec, ECS_SIZEOF(T), elem)) {
    return ecs_vec_remove(vec, ECS_SIZEOF(T), elem);
}
pub inline fn ecs_vec_copy_t(allocator: anytype, vec: anytype, T: anytype) @TypeOf(ecs_vec_copy(allocator, vec, ECS_SIZEOF(T))) {
    return ecs_vec_copy(allocator, vec, ECS_SIZEOF(T));
}
pub inline fn ecs_vec_reclaim_t(allocator: anytype, vec: anytype, T: anytype) @TypeOf(ecs_vec_reclaim(allocator, vec, ECS_SIZEOF(T))) {
    return ecs_vec_reclaim(allocator, vec, ECS_SIZEOF(T));
}
pub inline fn ecs_vec_set_size_t(allocator: anytype, vec: anytype, T: anytype, elem_count: anytype) @TypeOf(ecs_vec_set_size(allocator, vec, ECS_SIZEOF(T), elem_count)) {
    return ecs_vec_set_size(allocator, vec, ECS_SIZEOF(T), elem_count);
}
pub inline fn ecs_vec_set_min_size_t(allocator: anytype, vec: anytype, T: anytype, elem_count: anytype) @TypeOf(ecs_vec_set_min_size(allocator, vec, ECS_SIZEOF(T), elem_count)) {
    return ecs_vec_set_min_size(allocator, vec, ECS_SIZEOF(T), elem_count);
}
pub inline fn ecs_vec_set_min_count_t(allocator: anytype, vec: anytype, T: anytype, elem_count: anytype) @TypeOf(ecs_vec_set_min_count(allocator, vec, ECS_SIZEOF(T), elem_count)) {
    return ecs_vec_set_min_count(allocator, vec, ECS_SIZEOF(T), elem_count);
}
pub inline fn ecs_vec_set_min_count_zeromem_t(allocator: anytype, vec: anytype, T: anytype, elem_count: anytype) @TypeOf(ecs_vec_set_min_count_zeromem(allocator, vec, ECS_SIZEOF(T), elem_count)) {
    return ecs_vec_set_min_count_zeromem(allocator, vec, ECS_SIZEOF(T), elem_count);
}
pub inline fn ecs_vec_set_count_t(allocator: anytype, vec: anytype, T: anytype, elem_count: anytype) @TypeOf(ecs_vec_set_count(allocator, vec, ECS_SIZEOF(T), elem_count)) {
    return ecs_vec_set_count(allocator, vec, ECS_SIZEOF(T), elem_count);
}
pub inline fn ecs_vec_grow_t(allocator: anytype, vec: anytype, T: anytype, elem_count: anytype) @TypeOf(ecs_vec_grow(allocator, vec, ECS_SIZEOF(T), elem_count)) {
    return ecs_vec_grow(allocator, vec, ECS_SIZEOF(T), elem_count);
}
pub const FLECS_SPARSE_H = "";
pub const FLECS_SPARSE_PAGE_SIZE = @as(c_int, 1) << FLECS_SPARSE_PAGE_BITS;
pub inline fn flecs_sparse_init_t(sparse: anytype, allocator: anytype, page_allocator: anytype, T: anytype) @TypeOf(flecs_sparse_init(sparse, allocator, page_allocator, ECS_SIZEOF(T))) {
    return flecs_sparse_init(sparse, allocator, page_allocator, ECS_SIZEOF(T));
}
pub inline fn flecs_sparse_remove_t(sparse: anytype, T: anytype, id: anytype) @TypeOf(flecs_sparse_remove(sparse, ECS_SIZEOF(T), id)) {
    return flecs_sparse_remove(sparse, ECS_SIZEOF(T), id);
}
pub inline fn ecs_sparse_init_t(sparse: anytype, T: anytype) @TypeOf(ecs_sparse_init(sparse, ECS_SIZEOF(T))) {
    return ecs_sparse_init(sparse, ECS_SIZEOF(T));
}
pub const FLECS_BLOCK_ALLOCATOR_H = "";
pub inline fn flecs_ballocator_init_t(ba: anytype, T: anytype) @TypeOf(flecs_ballocator_init(ba, ECS_SIZEOF(T))) {
    return flecs_ballocator_init(ba, ECS_SIZEOF(T));
}
pub inline fn flecs_ballocator_init_n(ba: anytype, T: anytype, count: anytype) @TypeOf(flecs_ballocator_init(ba, ECS_SIZEOF(T) * count)) {
    return flecs_ballocator_init(ba, ECS_SIZEOF(T) * count);
}
pub inline fn flecs_ballocator_new_t(T: anytype) @TypeOf(flecs_ballocator_new(ECS_SIZEOF(T))) {
    return flecs_ballocator_new(ECS_SIZEOF(T));
}
pub inline fn flecs_ballocator_new_n(T: anytype, count: anytype) @TypeOf(flecs_ballocator_new(ECS_SIZEOF(T) * count)) {
    return flecs_ballocator_new(ECS_SIZEOF(T) * count);
}
pub const FLECS_MAP_H = "";
pub inline fn ecs_map_count(map: anytype) @TypeOf(if (map) map.*.count else @as(c_int, 0)) {
    return if (map) map.*.count else @as(c_int, 0);
}
pub inline fn ecs_map_is_init(map: anytype) @TypeOf(if (map) map.*.bucket_shift != @as(c_int, 0) else @"false") {
    return if (map) map.*.bucket_shift != @as(c_int, 0) else @"false";
}
pub inline fn ecs_map_insert_ptr(m: anytype, k: anytype, v: anytype) @TypeOf(ecs_map_insert(m, k, ECS_CAST(ecs_map_val_t, ECS_PTR_CAST(usize, v)))) {
    return ecs_map_insert(m, k, ECS_CAST(ecs_map_val_t, ECS_PTR_CAST(usize, v)));
}
pub inline fn ecs_map_remove_ptr(m: anytype, k: anytype) @TypeOf(ECS_PTR_CAST(?*anyopaque, ECS_CAST(usize, ecs_map_remove(m, k)))) {
    return ECS_PTR_CAST(?*anyopaque, ECS_CAST(usize, ecs_map_remove(m, k)));
}
pub inline fn ecs_map_key(it: anytype) @TypeOf(it.*.res[@as(usize, @intCast(@as(c_int, 0)))]) {
    return it.*.res[@as(usize, @intCast(@as(c_int, 0)))];
}
pub inline fn ecs_map_value(it: anytype) @TypeOf(it.*.res[@as(usize, @intCast(@as(c_int, 1)))]) {
    return it.*.res[@as(usize, @intCast(@as(c_int, 1)))];
}
pub inline fn ecs_map_ptr(it: anytype) @TypeOf(ECS_PTR_CAST(?*anyopaque, ECS_CAST(usize, ecs_map_value(it)))) {
    return ECS_PTR_CAST(?*anyopaque, ECS_CAST(usize, ecs_map_value(it)));
}
pub const FLECS_ALLOCATOR_H = "";
pub inline fn flecs_allocator(obj: anytype) @TypeOf(&obj.*.allocators.dyn) {
    return &obj.*.allocators.dyn;
}
pub inline fn flecs_alloc(a: anytype, size: anytype) @TypeOf(flecs_balloc(flecs_allocator_get(a, size))) {
    return flecs_balloc(flecs_allocator_get(a, size));
}
pub inline fn flecs_alloc_t(a: anytype, T: anytype) @TypeOf(flecs_alloc(a, ECS_SIZEOF(T))) {
    return flecs_alloc(a, ECS_SIZEOF(T));
}
pub inline fn flecs_alloc_n(a: anytype, T: anytype, count: anytype) @TypeOf(flecs_alloc(a, ECS_SIZEOF(T) * count)) {
    return flecs_alloc(a, ECS_SIZEOF(T) * count);
}
pub inline fn flecs_calloc(a: anytype, size: anytype) @TypeOf(flecs_bcalloc(flecs_allocator_get(a, size))) {
    return flecs_bcalloc(flecs_allocator_get(a, size));
}
pub inline fn flecs_calloc_t(a: anytype, T: anytype) @TypeOf(flecs_calloc(a, ECS_SIZEOF(T))) {
    return flecs_calloc(a, ECS_SIZEOF(T));
}
pub inline fn flecs_calloc_n(a: anytype, T: anytype, count: anytype) @TypeOf(flecs_calloc(a, ECS_SIZEOF(T) * count)) {
    return flecs_calloc(a, ECS_SIZEOF(T) * count);
}
pub inline fn flecs_free(a: anytype, size: anytype, ptr: anytype) @TypeOf(flecs_bfree(flecs_allocator_get(a, size), ptr)) {
    return flecs_bfree(flecs_allocator_get(a, size), ptr);
}
pub inline fn flecs_free_t(a: anytype, T: anytype, ptr: anytype) @TypeOf(flecs_free(a, ECS_SIZEOF(T), ptr)) {
    return flecs_free(a, ECS_SIZEOF(T), ptr);
}
pub inline fn flecs_free_n(a: anytype, T: anytype, count: anytype, ptr: anytype) @TypeOf(flecs_free(a, ECS_SIZEOF(T) * count, ptr)) {
    return flecs_free(a, ECS_SIZEOF(T) * count, ptr);
}
pub inline fn flecs_realloc(a: anytype, size_dst: anytype, size_src: anytype, ptr: anytype) @TypeOf(flecs_brealloc(flecs_allocator_get(a, size_dst), flecs_allocator_get(a, size_src), ptr)) {
    return flecs_brealloc(flecs_allocator_get(a, size_dst), flecs_allocator_get(a, size_src), ptr);
}
pub inline fn flecs_realloc_n(a: anytype, T: anytype, count_dst: anytype, count_src: anytype, ptr: anytype) @TypeOf(flecs_realloc(a, ECS_SIZEOF(T) * count_dst, ECS_SIZEOF(T) * count_src, ptr)) {
    return flecs_realloc(a, ECS_SIZEOF(T) * count_dst, ECS_SIZEOF(T) * count_src, ptr);
}
pub inline fn flecs_dup_n(a: anytype, T: anytype, count: anytype, ptr: anytype) @TypeOf(flecs_dup(a, ECS_SIZEOF(T) * count, ptr)) {
    return flecs_dup(a, ECS_SIZEOF(T) * count, ptr);
}
pub const FLECS_STRBUF_H_ = "";
pub const ECS_STRBUF_INIT = @import("std").mem.zeroInit(ecs_strbuf_t, .{@as(c_int, 0)});
pub const ECS_STRBUF_ELEMENT_SIZE = @as(c_int, 511);
pub const ECS_STRBUF_MAX_LIST_DEPTH = @as(c_int, 32);
pub inline fn ecs_strbuf_appendlit(buf: anytype, str: anytype) @TypeOf(ecs_strbuf_appendstrn(buf, str, @import("std").zig.c_translation.cast(i32, @import("std").zig.c_translation.sizeof(str) - @as(c_int, 1)))) {
    return ecs_strbuf_appendstrn(buf, str, @import("std").zig.c_translation.cast(i32, @import("std").zig.c_translation.sizeof(str) - @as(c_int, 1)));
}
pub inline fn ecs_strbuf_list_appendlit(buf: anytype, str: anytype) @TypeOf(ecs_strbuf_list_appendstrn(buf, str, @import("std").zig.c_translation.cast(i32, @import("std").zig.c_translation.sizeof(str) - @as(c_int, 1)))) {
    return ecs_strbuf_list_appendstrn(buf, str, @import("std").zig.c_translation.cast(i32, @import("std").zig.c_translation.sizeof(str) - @as(c_int, 1)));
}
pub const FLECS_OS_API_H = "";
pub const _SYS_ERRNO_H_ = "";
pub const errno = __error().*;
pub const EPERM = @as(c_int, 1);
pub const ENOENT = @as(c_int, 2);
pub const ESRCH = @as(c_int, 3);
pub const EINTR = @as(c_int, 4);
pub const EIO = @as(c_int, 5);
pub const ENXIO = @as(c_int, 6);
pub const E2BIG = @as(c_int, 7);
pub const ENOEXEC = @as(c_int, 8);
pub const EBADF = @as(c_int, 9);
pub const ECHILD = @as(c_int, 10);
pub const EDEADLK = @as(c_int, 11);
pub const ENOMEM = @as(c_int, 12);
pub const EACCES = @as(c_int, 13);
pub const EFAULT = @as(c_int, 14);
pub const ENOTBLK = @as(c_int, 15);
pub const EBUSY = @as(c_int, 16);
pub const EEXIST = @as(c_int, 17);
pub const EXDEV = @as(c_int, 18);
pub const ENODEV = @as(c_int, 19);
pub const ENOTDIR = @as(c_int, 20);
pub const EISDIR = @as(c_int, 21);
pub const EINVAL = @as(c_int, 22);
pub const ENFILE = @as(c_int, 23);
pub const EMFILE = @as(c_int, 24);
pub const ENOTTY = @as(c_int, 25);
pub const ETXTBSY = @as(c_int, 26);
pub const EFBIG = @as(c_int, 27);
pub const ENOSPC = @as(c_int, 28);
pub const ESPIPE = @as(c_int, 29);
pub const EROFS = @as(c_int, 30);
pub const EMLINK = @as(c_int, 31);
pub const EPIPE = @as(c_int, 32);
pub const EDOM = @as(c_int, 33);
pub const ERANGE = @as(c_int, 34);
pub const EAGAIN = @as(c_int, 35);
pub const EWOULDBLOCK = EAGAIN;
pub const EINPROGRESS = @as(c_int, 36);
pub const EALREADY = @as(c_int, 37);
pub const ENOTSOCK = @as(c_int, 38);
pub const EDESTADDRREQ = @as(c_int, 39);
pub const EMSGSIZE = @as(c_int, 40);
pub const EPROTOTYPE = @as(c_int, 41);
pub const ENOPROTOOPT = @as(c_int, 42);
pub const EPROTONOSUPPORT = @as(c_int, 43);
pub const ESOCKTNOSUPPORT = @as(c_int, 44);
pub const ENOTSUP = @as(c_int, 45);
pub const EPFNOSUPPORT = @as(c_int, 46);
pub const EAFNOSUPPORT = @as(c_int, 47);
pub const EADDRINUSE = @as(c_int, 48);
pub const EADDRNOTAVAIL = @as(c_int, 49);
pub const ENETDOWN = @as(c_int, 50);
pub const ENETUNREACH = @as(c_int, 51);
pub const ENETRESET = @as(c_int, 52);
pub const ECONNABORTED = @as(c_int, 53);
pub const ECONNRESET = @as(c_int, 54);
pub const ENOBUFS = @as(c_int, 55);
pub const EISCONN = @as(c_int, 56);
pub const ENOTCONN = @as(c_int, 57);
pub const ESHUTDOWN = @as(c_int, 58);
pub const ETOOMANYREFS = @as(c_int, 59);
pub const ETIMEDOUT = @as(c_int, 60);
pub const ECONNREFUSED = @as(c_int, 61);
pub const ELOOP = @as(c_int, 62);
pub const ENAMETOOLONG = @as(c_int, 63);
pub const EHOSTDOWN = @as(c_int, 64);
pub const EHOSTUNREACH = @as(c_int, 65);
pub const ENOTEMPTY = @as(c_int, 66);
pub const EPROCLIM = @as(c_int, 67);
pub const EUSERS = @as(c_int, 68);
pub const EDQUOT = @as(c_int, 69);
pub const ESTALE = @as(c_int, 70);
pub const EREMOTE = @as(c_int, 71);
pub const EBADRPC = @as(c_int, 72);
pub const ERPCMISMATCH = @as(c_int, 73);
pub const EPROGUNAVAIL = @as(c_int, 74);
pub const EPROGMISMATCH = @as(c_int, 75);
pub const EPROCUNAVAIL = @as(c_int, 76);
pub const ENOLCK = @as(c_int, 77);
pub const ENOSYS = @as(c_int, 78);
pub const EFTYPE = @as(c_int, 79);
pub const EAUTH = @as(c_int, 80);
pub const ENEEDAUTH = @as(c_int, 81);
pub const EPWROFF = @as(c_int, 82);
pub const EDEVERR = @as(c_int, 83);
pub const EOVERFLOW = @as(c_int, 84);
pub const EBADEXEC = @as(c_int, 85);
pub const EBADARCH = @as(c_int, 86);
pub const ESHLIBVERS = @as(c_int, 87);
pub const EBADMACHO = @as(c_int, 88);
pub const ECANCELED = @as(c_int, 89);
pub const EIDRM = @as(c_int, 90);
pub const ENOMSG = @as(c_int, 91);
pub const EILSEQ = @as(c_int, 92);
pub const ENOATTR = @as(c_int, 93);
pub const EBADMSG = @as(c_int, 94);
pub const EMULTIHOP = @as(c_int, 95);
pub const ENODATA = @as(c_int, 96);
pub const ENOLINK = @as(c_int, 97);
pub const ENOSR = @as(c_int, 98);
pub const ENOSTR = @as(c_int, 99);
pub const EPROTO = @as(c_int, 100);
pub const ETIME = @as(c_int, 101);
pub const EOPNOTSUPP = @as(c_int, 102);
pub const ENOPOLICY = @as(c_int, 103);
pub const ENOTRECOVERABLE = @as(c_int, 104);
pub const EOWNERDEAD = @as(c_int, 105);
pub const EQFULL = @as(c_int, 106);
pub const ELAST = @as(c_int, 106);
pub const _ALLOCA_H_ = "";
pub inline fn ecs_os_malloc(size: anytype) @TypeOf(ecs_os_api.malloc_(size)) {
    return ecs_os_api.malloc_(size);
}
pub inline fn ecs_os_free(ptr: anytype) @TypeOf(ecs_os_api.free_(ptr)) {
    return ecs_os_api.free_(ptr);
}
pub inline fn ecs_os_realloc(ptr: anytype, size: anytype) @TypeOf(ecs_os_api.realloc_(ptr, size)) {
    return ecs_os_api.realloc_(ptr, size);
}
pub inline fn ecs_os_calloc(size: anytype) @TypeOf(ecs_os_api.calloc_(size)) {
    return ecs_os_api.calloc_(size);
}
pub inline fn ecs_os_alloca(size: anytype) @TypeOf(alloca(@import("std").zig.c_translation.cast(usize, size))) {
    return alloca(@import("std").zig.c_translation.cast(usize, size));
}
pub inline fn ecs_os_strdup(str: anytype) @TypeOf(ecs_os_api.strdup_(str)) {
    return ecs_os_api.strdup_(str);
}
pub inline fn ecs_os_strlen(str: anytype) ecs_size_t {
    return @import("std").zig.c_translation.cast(ecs_size_t, strlen(str));
}
pub inline fn ecs_os_strncmp(str1: anytype, str2: anytype, num: anytype) @TypeOf(strncmp(str1, str2, @import("std").zig.c_translation.cast(usize, num))) {
    return strncmp(str1, str2, @import("std").zig.c_translation.cast(usize, num));
}
pub inline fn ecs_os_memcmp(ptr1: anytype, ptr2: anytype, num: anytype) @TypeOf(memcmp(ptr1, ptr2, @import("std").zig.c_translation.cast(usize, num))) {
    return memcmp(ptr1, ptr2, @import("std").zig.c_translation.cast(usize, num));
}
pub inline fn ecs_os_memcpy(ptr1: anytype, ptr2: anytype, num: anytype) @TypeOf(memcpy(ptr1, ptr2, @import("std").zig.c_translation.cast(usize, num))) {
    return memcpy(ptr1, ptr2, @import("std").zig.c_translation.cast(usize, num));
}
pub inline fn ecs_os_memset(ptr: anytype, value: anytype, num: anytype) @TypeOf(memset(ptr, value, @import("std").zig.c_translation.cast(usize, num))) {
    return memset(ptr, value, @import("std").zig.c_translation.cast(usize, num));
}
pub inline fn ecs_os_memmove(dst: anytype, src: anytype, size: anytype) @TypeOf(memmove(dst, src, @import("std").zig.c_translation.cast(usize, size))) {
    return memmove(dst, src, @import("std").zig.c_translation.cast(usize, size));
}
pub inline fn ecs_os_memcpy_t(ptr1: anytype, ptr2: anytype, T: anytype) @TypeOf(ecs_os_memcpy(ptr1, ptr2, ECS_SIZEOF(T))) {
    return ecs_os_memcpy(ptr1, ptr2, ECS_SIZEOF(T));
}
pub inline fn ecs_os_memcpy_n(ptr1: anytype, ptr2: anytype, T: anytype, count: anytype) @TypeOf(ecs_os_memcpy(ptr1, ptr2, ECS_SIZEOF(T) * count)) {
    return ecs_os_memcpy(ptr1, ptr2, ECS_SIZEOF(T) * count);
}
pub inline fn ecs_os_memcmp_t(ptr1: anytype, ptr2: anytype, T: anytype) @TypeOf(ecs_os_memcmp(ptr1, ptr2, ECS_SIZEOF(T))) {
    return ecs_os_memcmp(ptr1, ptr2, ECS_SIZEOF(T));
}
pub inline fn ecs_os_strcmp(str1: anytype, str2: anytype) @TypeOf(strcmp(str1, str2)) {
    return strcmp(str1, str2);
}
pub inline fn ecs_os_memset_t(ptr: anytype, value: anytype, T: anytype) @TypeOf(ecs_os_memset(ptr, value, ECS_SIZEOF(T))) {
    return ecs_os_memset(ptr, value, ECS_SIZEOF(T));
}
pub inline fn ecs_os_memset_n(ptr: anytype, value: anytype, T: anytype, count: anytype) @TypeOf(ecs_os_memset(ptr, value, ECS_SIZEOF(T) * count)) {
    return ecs_os_memset(ptr, value, ECS_SIZEOF(T) * count);
}
pub inline fn ecs_os_zeromem(ptr: anytype) @TypeOf(ecs_os_memset(ptr, @as(c_int, 0), ECS_SIZEOF(ptr.*))) {
    return ecs_os_memset(ptr, @as(c_int, 0), ECS_SIZEOF(ptr.*));
}
pub inline fn ecs_os_memdup_t(ptr: anytype, T: anytype) @TypeOf(ecs_os_memdup(ptr, ECS_SIZEOF(T))) {
    return ecs_os_memdup(ptr, ECS_SIZEOF(T));
}
pub inline fn ecs_os_memdup_n(ptr: anytype, T: anytype, count: anytype) @TypeOf(ecs_os_memdup(ptr, ECS_SIZEOF(T) * count)) {
    return ecs_os_memdup(ptr, ECS_SIZEOF(T) * count);
}
pub inline fn ecs_os_strcat(str1: anytype, str2: anytype) @TypeOf(strcat(str1, str2)) {
    return strcat(str1, str2);
}
pub inline fn ecs_os_strcpy(str1: anytype, str2: anytype) @TypeOf(strcpy(str1, str2)) {
    return strcpy(str1, str2);
}
pub inline fn ecs_os_strncpy(str1: anytype, str2: anytype, num: anytype) @TypeOf(strncpy(str1, str2, @import("std").zig.c_translation.cast(usize, num))) {
    return strncpy(str1, str2, @import("std").zig.c_translation.cast(usize, num));
}
pub inline fn ecs_os_thread_new(callback: anytype, param: anytype) @TypeOf(ecs_os_api.thread_new_(callback, param)) {
    return ecs_os_api.thread_new_(callback, param);
}
pub inline fn ecs_os_thread_join(thread: anytype) @TypeOf(ecs_os_api.thread_join_(thread)) {
    return ecs_os_api.thread_join_(thread);
}
pub inline fn ecs_os_thread_self() @TypeOf(ecs_os_api.thread_self_()) {
    return ecs_os_api.thread_self_();
}
pub inline fn ecs_os_task_new(callback: anytype, param: anytype) @TypeOf(ecs_os_api.task_new_(callback, param)) {
    return ecs_os_api.task_new_(callback, param);
}
pub inline fn ecs_os_task_join(thread: anytype) @TypeOf(ecs_os_api.task_join_(thread)) {
    return ecs_os_api.task_join_(thread);
}
pub inline fn ecs_os_ainc(value: anytype) @TypeOf(ecs_os_api.ainc_(value)) {
    return ecs_os_api.ainc_(value);
}
pub inline fn ecs_os_adec(value: anytype) @TypeOf(ecs_os_api.adec_(value)) {
    return ecs_os_api.adec_(value);
}
pub inline fn ecs_os_lainc(value: anytype) @TypeOf(ecs_os_api.lainc_(value)) {
    return ecs_os_api.lainc_(value);
}
pub inline fn ecs_os_ladec(value: anytype) @TypeOf(ecs_os_api.ladec_(value)) {
    return ecs_os_api.ladec_(value);
}
pub inline fn ecs_os_mutex_new() @TypeOf(ecs_os_api.mutex_new_()) {
    return ecs_os_api.mutex_new_();
}
pub inline fn ecs_os_mutex_free(mutex: anytype) @TypeOf(ecs_os_api.mutex_free_(mutex)) {
    return ecs_os_api.mutex_free_(mutex);
}
pub inline fn ecs_os_mutex_lock(mutex: anytype) @TypeOf(ecs_os_api.mutex_lock_(mutex)) {
    return ecs_os_api.mutex_lock_(mutex);
}
pub inline fn ecs_os_mutex_unlock(mutex: anytype) @TypeOf(ecs_os_api.mutex_unlock_(mutex)) {
    return ecs_os_api.mutex_unlock_(mutex);
}
pub inline fn ecs_os_cond_new() @TypeOf(ecs_os_api.cond_new_()) {
    return ecs_os_api.cond_new_();
}
pub inline fn ecs_os_cond_free(cond: anytype) @TypeOf(ecs_os_api.cond_free_(cond)) {
    return ecs_os_api.cond_free_(cond);
}
pub inline fn ecs_os_cond_signal(cond: anytype) @TypeOf(ecs_os_api.cond_signal_(cond)) {
    return ecs_os_api.cond_signal_(cond);
}
pub inline fn ecs_os_cond_broadcast(cond: anytype) @TypeOf(ecs_os_api.cond_broadcast_(cond)) {
    return ecs_os_api.cond_broadcast_(cond);
}
pub inline fn ecs_os_cond_wait(cond: anytype, mutex: anytype) @TypeOf(ecs_os_api.cond_wait_(cond, mutex)) {
    return ecs_os_api.cond_wait_(cond, mutex);
}
pub inline fn ecs_os_sleep(sec: anytype, nanosec: anytype) @TypeOf(ecs_os_api.sleep_(sec, nanosec)) {
    return ecs_os_api.sleep_(sec, nanosec);
}
pub inline fn ecs_os_now() @TypeOf(ecs_os_api.now_()) {
    return ecs_os_api.now_();
}
pub inline fn ecs_os_get_time(time_out: anytype) @TypeOf(ecs_os_api.get_time_(time_out)) {
    return ecs_os_api.get_time_(time_out);
}
pub inline fn ecs_os_abort() @TypeOf(ecs_os_api.abort_()) {
    return ecs_os_api.abort_();
}
pub inline fn ecs_os_dlopen(libname: anytype) @TypeOf(ecs_os_api.dlopen_(libname)) {
    return ecs_os_api.dlopen_(libname);
}
pub inline fn ecs_os_dlproc(lib: anytype, procname: anytype) @TypeOf(ecs_os_api.dlproc_(lib, procname)) {
    return ecs_os_api.dlproc_(lib, procname);
}
pub inline fn ecs_os_dlclose(lib: anytype) @TypeOf(ecs_os_api.dlclose_(lib)) {
    return ecs_os_api.dlclose_(lib);
}
pub inline fn ecs_os_module_to_dl(lib: anytype) @TypeOf(ecs_os_api.module_to_dl_(lib)) {
    return ecs_os_api.module_to_dl_(lib);
}
pub inline fn ecs_os_module_to_etc(lib: anytype) @TypeOf(ecs_os_api.module_to_etc_(lib)) {
    return ecs_os_api.module_to_etc_(lib);
}
pub const EcsSelf = @as(c_uint, 1) << @as(c_int, 1);
pub const EcsUp = @as(c_uint, 1) << @as(c_int, 2);
pub const EcsDown = @as(c_uint, 1) << @as(c_int, 3);
pub const EcsTraverseAll = @as(c_uint, 1) << @as(c_int, 4);
pub const EcsCascade = @as(c_uint, 1) << @as(c_int, 5);
pub const EcsParent = @as(c_uint, 1) << @as(c_int, 6);
pub const EcsIsVariable = @as(c_uint, 1) << @as(c_int, 7);
pub const EcsIsEntity = @as(c_uint, 1) << @as(c_int, 8);
pub const EcsIsName = @as(c_uint, 1) << @as(c_int, 9);
pub const EcsFilter = @as(c_uint, 1) << @as(c_int, 10);
pub const EcsTraverseFlags = ((((EcsUp | EcsDown) | EcsTraverseAll) | EcsSelf) | EcsCascade) | EcsParent;
pub const EcsTermMatchAny = @as(c_uint, 1) << @as(c_int, 0);
pub const EcsTermMatchAnySrc = @as(c_uint, 1) << @as(c_int, 1);
pub const EcsTermSrcFirstEq = @as(c_uint, 1) << @as(c_int, 2);
pub const EcsTermSrcSecondEq = @as(c_uint, 1) << @as(c_int, 3);
pub const EcsTermTransitive = @as(c_uint, 1) << @as(c_int, 4);
pub const EcsTermReflexive = @as(c_uint, 1) << @as(c_int, 5);
pub const EcsTermIdInherited = @as(c_uint, 1) << @as(c_int, 6);
pub const EcsTermMatchDisabled = @as(c_uint, 1) << @as(c_int, 7);
pub const EcsTermMatchPrefab = @as(c_uint, 1) << @as(c_int, 8);
pub const FLECS_API_TYPES_H = "";
pub const flecs_iter_cache_ids = @as(c_uint, 1) << @as(c_uint, 0);
pub const flecs_iter_cache_columns = @as(c_uint, 1) << @as(c_uint, 1);
pub const flecs_iter_cache_sources = @as(c_uint, 1) << @as(c_uint, 2);
pub const flecs_iter_cache_ptrs = @as(c_uint, 1) << @as(c_uint, 3);
pub const flecs_iter_cache_match_indices = @as(c_uint, 1) << @as(c_uint, 4);
pub const flecs_iter_cache_variables = @as(c_uint, 1) << @as(c_uint, 5);
pub const flecs_iter_cache_all = @as(c_int, 255);
pub const FLECS_API_SUPPORT_H = "";
pub const ECS_MAX_COMPONENT_ID = ~@import("std").zig.c_translation.cast(u32, ECS_ID_FLAGS_MASK >> @as(c_int, 32));
pub const ECS_MAX_RECURSION = @as(c_int, 512);
pub const ECS_MAX_TOKEN_SIZE = @as(c_int, 256);
pub const FLECS_ID0ID_ = @as(c_int, 0);
pub inline fn ECS_OFFSET(o: anytype, offset: anytype) ?*anyopaque {
    return @import("std").zig.c_translation.cast(?*anyopaque, @import("std").zig.c_translation.cast(usize, o) + @import("std").zig.c_translation.cast(usize, offset));
}
pub inline fn ECS_OFFSET_T(o: anytype, T: anytype) @TypeOf(ECS_OFFSET(o, ECS_SIZEOF(T))) {
    return ECS_OFFSET(o, ECS_SIZEOF(T));
}
pub inline fn ECS_ELEM(ptr: anytype, size: anytype, index_1: anytype) @TypeOf(ECS_OFFSET(ptr, size * index_1)) {
    return ECS_OFFSET(ptr, size * index_1);
}
pub inline fn ECS_ELEM_T(o: anytype, T: anytype, index_1: anytype) @TypeOf(ECS_ELEM(o, ECS_SIZEOF(T), index_1)) {
    return ECS_ELEM(o, ECS_SIZEOF(T), index_1);
}
pub inline fn ECS_BIT_IS_SET(flags: anytype, bit: anytype) @TypeOf(flags & bit) {
    return flags & bit;
}
pub const FLECS_HASHMAP_H = "";

pub const EcsFirstUserComponentId = @as(c_int, 8);
pub const EcsFirstUserEntityId = FLECS_HI_COMPONENT_ID + @as(c_int, 128);
pub const FLECS_C_ = "";

pub const FLECS_ADDONS_H = "";
pub const FLECS_LOG_H = "";
pub const FLECS_LOG_3 = "";
pub inline fn ecs_should_log_1() @TypeOf(ecs_should_log(@as(c_int, 1))) {
    return ecs_should_log(@as(c_int, 1));
}
pub inline fn ecs_should_log_2() @TypeOf(ecs_should_log(@as(c_int, 2))) {
    return ecs_should_log(@as(c_int, 2));
}
pub inline fn ecs_should_log_3() @TypeOf(ecs_should_log(@as(c_int, 3))) {
    return ecs_should_log(@as(c_int, 3));
}
pub const FLECS_LOG_2 = "";
pub const FLECS_LOG_1 = "";
pub const FLECS_LOG_0 = "";

pub inline fn ecs_log_push() @TypeOf(ecs_log_push_(@as(c_int, 0))) {
    return ecs_log_push_(@as(c_int, 0));
}
pub inline fn ecs_log_pop() @TypeOf(ecs_log_pop_(@as(c_int, 0))) {
    return ecs_log_pop_(@as(c_int, 0));
}
pub inline fn ecs_parser_errorv(name: anytype, expr: anytype, column: anytype, fmt: anytype, args: anytype) @TypeOf(ecs_parser_errorv_(name, expr, column, fmt, args)) {
    return ecs_parser_errorv_(name, expr, column, fmt, args);
}
pub const ECS_INVALID_OPERATION = @as(c_int, 1);
pub const ECS_INVALID_PARAMETER = @as(c_int, 2);
pub const ECS_CONSTRAINT_VIOLATED = @as(c_int, 3);
pub const ECS_OUT_OF_MEMORY = @as(c_int, 4);
pub const ECS_OUT_OF_RANGE = @as(c_int, 5);
pub const ECS_UNSUPPORTED = @as(c_int, 6);
pub const ECS_INTERNAL_ERROR = @as(c_int, 7);
pub const ECS_ALREADY_DEFINED = @as(c_int, 8);
pub const ECS_MISSING_OS_API = @as(c_int, 9);
pub const ECS_OPERATION_FAILED = @as(c_int, 10);
pub const ECS_INVALID_CONVERSION = @as(c_int, 11);
pub const ECS_ID_IN_USE = @as(c_int, 12);
pub const ECS_CYCLE_DETECTED = @as(c_int, 13);
pub const ECS_LEAK_DETECTED = @as(c_int, 14);
pub const ECS_DOUBLE_FREE = @as(c_int, 15);
pub const ECS_INCONSISTENT_NAME = @as(c_int, 20);
pub const ECS_NAME_IN_USE = @as(c_int, 21);
pub const ECS_NOT_A_COMPONENT = @as(c_int, 22);
pub const ECS_INVALID_COMPONENT_SIZE = @as(c_int, 23);
pub const ECS_INVALID_COMPONENT_ALIGNMENT = @as(c_int, 24);
pub const ECS_COMPONENT_NOT_REGISTERED = @as(c_int, 25);
pub const ECS_INCONSISTENT_COMPONENT_ID = @as(c_int, 26);
pub const ECS_INCONSISTENT_COMPONENT_ACTION = @as(c_int, 27);
pub const ECS_MODULE_UNDEFINED = @as(c_int, 28);
pub const ECS_MISSING_SYMBOL = @as(c_int, 29);
pub const ECS_ALREADY_IN_USE = @as(c_int, 30);
pub const ECS_ACCESS_VIOLATION = @as(c_int, 40);
pub const ECS_COLUMN_INDEX_OUT_OF_RANGE = @as(c_int, 41);
pub const ECS_COLUMN_IS_NOT_SHARED = @as(c_int, 42);
pub const ECS_COLUMN_IS_SHARED = @as(c_int, 43);
pub const ECS_COLUMN_TYPE_MISMATCH = @as(c_int, 45);
pub const ECS_INVALID_WHILE_READONLY = @as(c_int, 70);
pub const ECS_LOCKED_STORAGE = @as(c_int, 71);
pub const ECS_INVALID_FROM_WORKER = @as(c_int, 72);
pub const ECS_BLACK = "\x1b[1;30m";
pub const ECS_RED = "\x1b[0;31m";
pub const ECS_GREEN = "\x1b[0;32m";
pub const ECS_YELLOW = "\x1b[0;33m";
pub const ECS_BLUE = "\x1b[0;34m";
pub const ECS_MAGENTA = "\x1b[0;35m";
pub const ECS_CYAN = "\x1b[0;36m";
pub const ECS_WHITE = "\x1b[1;37m";
pub const ECS_GREY = "\x1b[0;37m";
pub const ECS_NORMAL = "\x1b[0;49m";
pub const ECS_BOLD = "\x1b[1;49m";
pub const FLECS_APP_H = "";
pub const FLECS_HTTP_H = "";
pub const ECS_HTTP_HEADER_COUNT_MAX = @as(c_int, 32);
pub const ECS_HTTP_QUERY_PARAM_COUNT_MAX = @as(c_int, 32);
pub const ECS_HTTP_REPLY_INIT = @import("std").mem.zeroInit(ecs_http_reply_t, .{ @as(c_int, 200), ECS_STRBUF_INIT, "OK", "application/json", ECS_STRBUF_INIT });
pub const FLECS_REST_H = "";
pub const ECS_REST_DEFAULT_PORT = @as(c_int, 27750);
pub const FLECS_TIMER_H = "";
pub const FLECS_PIPELINE_H = "";
pub const FLECS_SYSTEM_H = "";
pub const FLECS_STATS_H = "";
pub const ECS_STAT_WINDOW = @as(c_int, 60);
pub const FLECS_METRICS_H = "";
pub const FLECS_ALERTS_H = "";
pub const ECS_ALERT_MAX_SEVERITY_FILTERS = @as(c_int, 4);
pub const FLECS_MONITOR_H = "";
pub const FLECS_COREDOC_H = "";
pub const FLECS_DOC_H = "";
pub const FLECS_JSON_H = "";
pub const ECS_ENTITY_TO_JSON_INIT = @import("std").mem.zeroInit(ecs_entity_to_json_desc_t, .{ @"true", @"false", @"false", @"false", @"false", @"true", @"false", @"true", @"false", @"false", @"false", @"false", @"false", @"false", @"false" });
pub const ECS_ITER_TO_JSON_INIT = @import("std").mem.zeroInit(ecs_iter_to_json_desc_t, .{
    .serialize_term_ids = @"true",
    .serialize_term_labels = @"false",
    .serialize_ids = @"true",
    .serialize_id_labels = @"false",
    .serialize_sources = @"true",
    .serialize_variables = @"true",
    .serialize_is_set = @"true",
    .serialize_values = @"true",
    .serialize_entities = @"true",
    .serialize_entity_labels = @"false",
    .serialize_entity_ids = @"false",
    .serialize_entity_names = @"false",
    .serialize_variable_labels = @"false",
    .serialize_variable_ids = @"false",
    .serialize_colors = @"false",
    .measure_eval_duration = @"false",
    .serialize_type_info = @"false",
    .serialize_table = @"false",
});
pub const FLECS_UNITS_H = "";
pub const __STDDEF_H = "";
pub const __need_ptrdiff_t = "";
pub const __need_size_t = "";
pub const __need_wchar_t = "";
pub const __need_NULL = "";
pub const __need_STDDEF_H_misc = "";
pub const _PTRDIFF_T = "";
pub const _WCHAR_T = "";
pub const __CLANG_MAX_ALIGN_T_DEFINED = "";
pub const FLECS_META_H = "";
pub const ECS_MEMBER_DESC_CACHE_SIZE = @as(c_int, 32);
pub const ECS_META_MAX_SCOPE_DEPTH = @as(c_int, 32);
pub const FLECS_EXPR_H = "";
pub const FLECS_META_C_H = "";
pub const ECS_PRIVATE = "";
pub const FLECS_PLECS_H = "";
pub const FLECS_RULES_H = "";
pub const FLECS_SNAPSHOT_H = "";
pub const FLECS_PARSER_H = "";
pub const FLECS_OS_API_IMPL_H = "";
pub const FLECS_MODULE_H = "";
pub const FLECS_CPP_H = "";

pub const ecs_table_cache_hdr_t = struct_ecs_table_cache_hdr_t;
pub const ecs_rule_var_t = struct_ecs_rule_var_t;
pub const ecs_rule_op_t = struct_ecs_rule_op_t;
pub const ecs_rule_op_ctx_t = struct_ecs_rule_op_ctx_t;
pub const ecs_stack_page_t = struct_ecs_stack_page_t;
pub const ecs_stack_t = struct_ecs_stack_t;
pub const ecs_event_id_record_t = struct_ecs_event_id_record_t;
