const std = @import("std");
const rl = @import("raylib");
const utils = @import("utils.zig");

pub const Game = struct {
    score: u32 = 0,
    lives: u4 = 4,
    time: u64 = 0,

    pub fn drawInfo(self: *Game) [*:0]const u8 {
        self.drawScore();
        self.drawLives();
        self.drawTime();
    }

    pub const AllocPrintError = error{OutOfMemory};
    pub fn drawScore(self: *Game, allocator: std.mem.Allocator) [*:0]const u8 {
        const res = std.fmt.allocPrint(allocator, "{d}", .{self.score}) catch |err| return err;
        return &res;
    }
};
