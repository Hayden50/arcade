const std = @import("std");

pub const Game = struct {
    score: u32 = 0,
    lives: u4 = 4,
    time: u64 = 0,
};
