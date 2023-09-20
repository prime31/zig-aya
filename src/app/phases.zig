const std = @import("std");

pub var pre_startup: u64 = 0;
pub var startup: u64 = 0;
pub var post_startup: u64 = 0;

pub var first: u64 = 0;
pub var pre_update: u64 = 0;
pub var state_transition: u64 = 0;
pub var run_fixed_update_loop: u64 = 0;
pub var update: u64 = 0;
pub var post_update: u64 = 0;
pub var last: u64 = 0;
