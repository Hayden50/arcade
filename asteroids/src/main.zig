const std = @import("std");
const rl = @import("raylib");

const Game = @import("game.zig").Game;
const Ship = @import("ship.zig").Ship;
const Bullet = @import("bullet.zig").Bullet;
const Asteroid = @import("asteroid.zig").Asteroid;
const constants = @import("constants.zig");

const print = std.debug.print;
const Vector2 = rl.Vector2;

pub fn main() anyerror!void {
    rl.initWindow(constants.SCREEN_WIDTH, constants.SCREEN_HEIGHT, "Asteroids!");
    defer rl.closeWindow();

    rl.setTargetFPS(rl.getMonitorRefreshRate(1));
    rl.clearBackground(constants.BLACK);

    var GameState = Game{};
    var player = Ship.init();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();
    var bullets = std.ArrayList(Bullet).init(allocator);
    var asteroids = std.ArrayList(Asteroid).init(allocator);

    var shotCooldown: u32 = 0;
    var frame: u32 = 0;
    var canShoot: bool = true;
    const shotBlock = @divFloor(rl.getMonitorRefreshRate(1), 6); // Required number of frames before another shot can occur

    for (0..5) |_| {
        try asteroids.append(Asteroid.init());
    }

    // Main game loop
    while (!rl.windowShouldClose()) {
        // Logic
        const key = rl.KeyboardKey;
        var delta = Vector2.init(0.0, 0.0);
        if (rl.isKeyDown(key.right) or rl.isKeyDown(key.d)) delta.x += 0.5;
        if (rl.isKeyDown(key.left) or rl.isKeyDown(key.a)) delta.x -= 0.5;
        if (rl.isKeyDown(key.up) or rl.isKeyDown(key.w)) delta.y -= 0.5;
        if (rl.isKeyDown(key.down) or rl.isKeyDown(key.s)) delta.y += 0.5;

        var angle: f32 = 0.0;
        if (rl.isKeyDown(key.e) or rl.isKeyDown(key.k)) angle += 2.0;
        if (rl.isKeyDown(key.q) or rl.isKeyDown(key.j)) angle -= 2.0;

        if (rl.isKeyDown(key.space) and canShoot) {
            try bullets.append(Bullet.init(player.direction, player.points[0]));
            canShoot = false;
        }

        // TODO: Add actual logic for rate of spawning asteroids
        if (frame == 20 or frame == 80) {
            try asteroids.append(Asteroid.init());
        }

        if (!canShoot) {
            shotCooldown += 1;
            if (shotCooldown == shotBlock) {
                canShoot = true;
                shotCooldown = 0;
            }
        }

        if (frame + 1 == rl.getMonitorRefreshRate(1)) {
            GameState.time += 1;
            frame = 0;
        } else {
            frame += 1;
        }

        // Drawing -- Uses setTargetFPS function to limit movement
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(constants.BLACK);

        // Could I create some sort of union to simplify this code?
        player.move(delta, angle);
        for (bullets.items, 0..) |*bullet, i| {
            const xLoc = bullet.location.x;
            const yLoc = bullet.location.y;
            if (i < bullets.items.len) {
                if (xLoc < 0 or xLoc >= constants.SCREEN_WIDTH or yLoc < 0 or yLoc >= constants.SCREEN_HEIGHT) {
                    _ = bullets.swapRemove(i);
                }
                bullet.move();
            }
        }

        for (asteroids.items, 0..) |*asteroid, i| {
            const xLoc = asteroid.center.x;
            const yLoc = asteroid.center.y;
            if (i < asteroids.items.len) {
                if (xLoc < -10 or xLoc >= constants.SCREEN_WIDTH + 10 or yLoc < -10 or yLoc >= constants.SCREEN_HEIGHT + 10) {
                    _ = asteroids.swapRemove(i);
                }
                asteroid.move();
            }
        }
    }
}
