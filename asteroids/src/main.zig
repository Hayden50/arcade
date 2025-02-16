const std = @import("std");
const rl = @import("raylib");

const Ship = @import("ship.zig").Ship;
const constants = @import("constants.zig");

const print = std.debug.print;
const Vector2 = rl.Vector2;

pub fn main() anyerror!void {
    rl.initWindow(constants.SCREEN_WIDTH, constants.SCREEN_HEIGHT, "Asteroids!");
    defer rl.closeWindow();

    rl.setTargetFPS(rl.getMonitorRefreshRate(1));
    rl.clearBackground(constants.BLACK);

    var player = Ship.init();

    // Main game loop
    while (!rl.windowShouldClose()) {
        // Logic
        const key = rl.KeyboardKey;
        var delta = Vector2.init(0.0, 0.0);
        if (rl.isKeyDown(key.right) or rl.isKeyDown(key.d)) delta.x += 2.0;
        if (rl.isKeyDown(key.left) or rl.isKeyDown(key.a)) delta.x -= 2.0;
        if (rl.isKeyDown(key.up) or rl.isKeyDown(key.w)) delta.y -= 2.0;
        if (rl.isKeyDown(key.down) or rl.isKeyDown(key.s)) delta.y += 2.0;

        var angle: f32 = 0.0;
        if (rl.isKeyDown(key.e)) angle += 2.0;
        if (rl.isKeyDown(key.q)) angle -= 2.0;

        // Drawing -- Uses setTargetFPS function to limit movement
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(constants.BLACK);
        player.move(delta, angle);
    }
}
