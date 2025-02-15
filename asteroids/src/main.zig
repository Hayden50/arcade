const std = @import("std");
const rl = @import("raylib");
const rm = @import("raymath");

const print = std.debug.print;

const SCREEN_WIDTH = 1920;
const SCREEN_HEIGHT = 1080;
const Vector2 = rl.Vector2;

const Ship = struct {
    center: Vector2,
    size: f32 = 10.0,
    direction: f32 = 0.0,

    pub fn init(center: Vector2, direction: f32) Ship {
        return Ship{
            .center = center,
            .direction = direction,
        };
    }

    pub fn draw(self: Ship) void {
        const frontDelta = calcVectorDelta(self.size, self.direction);
        const leftDelta = calcVectorDelta(self.size, @mod((self.direction - 145.0), 360.0));
        const rightDelta = calcVectorDelta(self.size, @mod((self.direction + 145.0), 360.0));

        print("Front Delta: {}, {}\n", .{ frontDelta.x, frontDelta.y });

        const frontPoint: Vector2 = .{ .x = (self.center.x + frontDelta.x), .y = (self.center.y + frontDelta.y) };
        const leftPoint: Vector2 = .{ .x = (self.center.x + leftDelta.x), .y = (self.center.y + leftDelta.y) };
        const rightPoint: Vector2 = .{ .x = (self.center.x + rightDelta.x), .y = (self.center.y + rightDelta.y) };

        print("Front Point: {}, {}\n", .{ frontPoint.x, frontPoint.y });
        print("Center: {}, {}\n", .{ self.center.x, self.center.y });

        rl.drawLineV(frontPoint, leftPoint, rl.Color.white);
        rl.drawLineV(frontPoint, rightPoint, rl.Color.white);

        return;
    }
};

pub fn main() anyerror!void {
    rl.initWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Asteroids!");
    defer rl.closeWindow();

    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second
    rl.clearBackground(rl.Color.black);

    const center = Vector2.init((SCREEN_WIDTH / 2), (SCREEN_HEIGHT / 2));
    var player = Ship.init(center, 0.0);
    player.draw();

    // Main game loop
    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();
    }
}

fn calcVectorDelta(size: f32, dir: f32) Vector2 {
    print("Dir: {}\n", .{dir});
    const radDir = toRadians(dir);
    print("Radian Dir: {}\n", .{radDir});
    const newX = size * std.math.cos(radDir);
    const newY = size * std.math.sin(radDir);
    return Vector2.init(newX, newY);
}

test toRadians {
    // const vec1 = Vector2.init(10.0, 0.0);
    // const res = calcVectorDelta(10.0, 0.0).equals(vec1);
    // print("{}", .{res});
    try std.testing.expect(0 == 0);
    try std.testing.expect(1 == 0);
}

fn toRadians(deg: f32) f32 {
    return deg * (180.0 / std.math.pi);
}
