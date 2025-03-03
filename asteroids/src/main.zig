const std = @import("std");
const rl = @import("raylib");
const Game = @import("game.zig").Game;
const Ship = @import("ship.zig").Ship;
const Bullet = @import("bullet.zig").Bullet;
const Asteroid = @import("asteroid.zig").Asteroid;
const constants = @import("constants.zig");

const print = std.debug.print;
const assert = std.debug.assert;
const Vector2 = rl.Vector2;

pub fn main() anyerror!void {
    rl.initWindow(constants.SCREEN_WIDTH, constants.SCREEN_HEIGHT, "Asteroids!");
    defer rl.closeWindow();

    rl.setTargetFPS(rl.getMonitorRefreshRate(1));
    rl.clearBackground(constants.BLACK);

    var GlobalGameState = Game{};
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

    var playerIsImmune = false;
    var immunityTimer: u32 = 0;
    var immunityVisible = false;

    // Spawns initial asteroids
    for (0..8) |_| {
        try asteroids.append(Asteroid.init());
    }

    // Main game loop
    while (!rl.windowShouldClose()) {
        if (checkCollision(&player, asteroids.items)) |i| {
            assert(i >= 0 and i < asteroids.items.len);
            _ = asteroids.swapRemove(i);
            GlobalGameState.lives -= 1;
            if (GlobalGameState.lives == 0) {
                rl.closeWindow();
                bullets.deinit();
                asteroids.deinit();
                continue;
            }

            player.center = try findEmptySpace(asteroids.items);
            player.setPoints();
            playerIsImmune = true;
        }

        if (rl.windowShouldClose()) break; // Skips logic if player loses

        const playerMovement = checkPlayerMovement(); // Calculates player position and angle changes
        player.move(playerMovement.delta, playerMovement.angle);

        if (rl.isKeyDown(rl.KeyboardKey.space) and canShoot) {
            try bullets.append(Bullet.init(player.direction, player.points[0]));
            canShoot = false;
        }

        // TODO: Add actual logic for rate of spawning asteroids
        try generateAsteroids(&asteroids, frame);

        if (!canShoot) {
            shotCooldown += 1;
            if (shotCooldown == shotBlock) {
                canShoot = true;
                shotCooldown = 0;
            }
        }

        // Logic for blinking ship when hit
        if (playerIsImmune) {
            playerImmunityBlinker(&immunityTimer, &playerIsImmune, &immunityVisible);
        }

        if (frame + 1 == rl.getMonitorRefreshRate(1)) {
            GlobalGameState.time += 1;
            frame = 0;
        } else {
            frame += 1;
        }

        ////////////////////////////////////////// DRAWING SECTION //////////////////////////////////////////
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(constants.BLACK);

        try writeScore(u32, GlobalGameState.score, 10, 10);
        drawLives(GlobalGameState.lives);

        if (!playerIsImmune or immunityVisible) {
            player.draw(constants.WHITE);
        }

        // TODO: Move the logic that can be moved above beginDrawing()
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

        // TODO: Optimize this function! Write Tests??
        // MultiArrayList??
        var i: usize = 0;
        var removed: bool = false;
        while (i < asteroids.items.len) {
            var asteroid = &asteroids.items[i];
            removed = false;

            for (bullets.items, 0..) |*bullet, j| {
                if (rl.checkCollisionCircles(bullet.location, 1.5, asteroid.center, asteroid.getAsteroidRadius())) {
                    if (asteroid.split(&GlobalGameState)) |newAsteroids| {
                        try asteroids.appendSlice(&newAsteroids); // Does this cause an error in some cases?
                    }
                    _ = asteroids.swapRemove(i);
                    _ = bullets.swapRemove(j);
                    removed = true;
                    break;
                }
            }

            if (removed) continue;

            const xLoc = asteroid.center.x;
            const yLoc = asteroid.center.y;
            if (i < asteroids.items.len) {
                if (xLoc < -10 or xLoc >= constants.SCREEN_WIDTH + 10 or yLoc < -10 or yLoc >= constants.SCREEN_HEIGHT + 10) {
                    _ = asteroids.swapRemove(i);
                    removed = true;
                } else {
                    asteroid.move();
                }
            }

            if (!removed) i += 1;
        }
    }
}

fn checkPlayerMovement() struct { delta: Vector2, angle: f32 } {
    const key = rl.KeyboardKey;
    var delta = Vector2.init(0.0, 0.0);
    if (rl.isKeyDown(key.right) or rl.isKeyDown(key.d)) delta.x += 0.2;
    if (rl.isKeyDown(key.left) or rl.isKeyDown(key.a)) delta.x -= 0.2;
    if (rl.isKeyDown(key.up) or rl.isKeyDown(key.w)) delta.y -= 0.2;
    if (rl.isKeyDown(key.down) or rl.isKeyDown(key.s)) delta.y += 0.2;

    var angle: f32 = 0.0;
    if (rl.isKeyDown(key.e) or rl.isKeyDown(key.k)) angle += 2.0;
    if (rl.isKeyDown(key.q) or rl.isKeyDown(key.j)) angle -= 2.0;

    return .{ .delta = delta, .angle = angle };
}

fn generateAsteroids(asteroids: *std.ArrayList(Asteroid), frame: u32) error{OutOfMemory}!void {
    if (frame == 20 or frame == 80) {
        try asteroids.append(Asteroid.init());
    }
}

fn playerImmunityBlinker(immunityTimer: *u32, playerIsImmune: *bool, immunityVisible: *bool) void {
    if (immunityTimer.* == rl.getMonitorRefreshRate(1)) {
        immunityTimer.* = 0;
        playerIsImmune.* = false;
        immunityVisible.* = true;
    } else {
        immunityTimer.* += 1;
        if (immunityTimer.* % 20 == 0) {
            immunityVisible.* = !immunityVisible.*;
        }
    }
}

fn checkCollision(player: *Ship, asteroids: []Asteroid) ?usize {
    const point1 = player.points[0];
    const point2 = player.points[1];
    const point3 = player.points[2];

    for (asteroids, 0..) |*asteroid, i| {
        if (rl.checkCollisionCircleLine(asteroid.center, asteroid.getAsteroidRadius(), point1, point2)) {
            return i;
        }
        if (rl.checkCollisionCircleLine(asteroid.center, asteroid.getAsteroidRadius(), point3, point2)) {
            return i;
        }
        if (rl.checkCollisionCircleLine(asteroid.center, asteroid.getAsteroidRadius(), point1, point3)) {
            return i;
        }
    }
    return null;
}

fn writeScore(T: type, data: T, x: i32, y: i32) error{OutOfMemory}!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const gpall = gpa.allocator();
    defer {
        _ = gpa.deinit();
        // assert(deinit_res == .ok);
    }

    const res = std.fmt.allocPrint(gpall, "{d}", .{data}) catch |err| return err;

    // Allocate a new buffer with an extra byte for the null terminator
    const res_null_terminated = gpall.allocSentinel(u8, res.len, 0) catch |err| return err;
    defer gpall.free(res_null_terminated);

    @memcpy(res_null_terminated[0..res.len], res); // Copy data
    gpall.free(res); // Free old buffer

    const c_string: [*:0]const u8 = res_null_terminated.ptr;

    // const scoreText = GlobalGameState.drawScore(gpall);
    rl.drawText(c_string, x, y, 40, constants.WHITE);
}

fn drawLives(numLives: u4) void {
    assert(numLives <= 4);
    var buffer: [4]Ship = .{ .{ .center = Vector2.init(20, 80) }, .{ .center = Vector2.init(50, 80) }, .{ .center = Vector2.init(80, 80) }, .{ .center = Vector2.init(110, 80) } };
    for (0..4) |i| {
        buffer[i].setPoints();
    }
    for (0..numLives) |i| {
        buffer[i].draw(constants.WHITE);
    }
}

// Loop in widening concentric circles around the origin to find a space where the player can respawn
fn findEmptySpace(asteroids: []Asteroid) error{NoOpenSpace}!Vector2 {
    const playerRad: f32 = 50.0;
    const screenCenter: Vector2 = Vector2.init(constants.SCREEN_WIDTH / 2, constants.SCREEN_HEIGHT / 2);
    const dirs = [4][2]f32{ .{ 1, 0 }, .{ 0, -1 }, .{ -1, 0 }, .{ 0, 1 } };
    var loopIterations: f32 = 1.0;

    var hitAsteroid = false;
    for (asteroids) |*asteroid| {
        if (rl.checkCollisionCircles(screenCenter, playerRad, asteroid.center, asteroid.getAsteroidRadius())) hitAsteroid = true;
    }

    if (!hitAsteroid) {
        return screenCenter;
    }

    while (true) {
        var counter: f32 = 0;
        var dir: u8 = 0;
        var delta = Vector2.init(-1 * loopIterations * playerRad, 1 * loopIterations * playerRad);

        while (counter != 8 * loopIterations) {
            const playerCenter = screenCenter.add(delta);

            // Check to see if there are any asteroids in the area
            hitAsteroid = false;
            for (asteroids) |*asteroid| {
                if (rl.checkCollisionCircles(playerCenter, playerRad, asteroid.center, asteroid.getAsteroidRadius())) hitAsteroid = true;
            }
            if (!hitAsteroid) return playerCenter;

            // moveDelta based on dir -> update counter -> check if update dir
            const newMove = Vector2.init(playerRad * dirs[dir][0], playerRad * dirs[dir][1]);
            delta = delta.add(newMove);

            counter += 1;
            if (@mod(counter, (2 * loopIterations)) == 0) dir += 1;
        }
        loopIterations += 1;
        if (loopIterations > 5) return error.NoOpenSpace;
    }

    return error.NoOpenSpace; // Shouldn't get reached
}
