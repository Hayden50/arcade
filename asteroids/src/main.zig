const std = @import("std");
const rl = @import("raylib");

const print = std.debug.print;

const SCREEN_WIDTH = 1920;
const SCREEN_HEIGHT = 1080;
const BLACK = rl.Color.black;
const WHITE = rl.Color.white;
const Vector2 = rl.Vector2;

const Ship = struct {
    center: Vector2,
    size: f32 = 80.0,
    direction: f32 = 0.0,

    pub fn init(center: Vector2, direction: f32) Ship {
        return Ship{
            .center = center,
            .direction = direction,
        };
    }

    pub fn draw(self: Ship) void {
        const frontDelta = calcVectorDelta(self.size, self.direction);
        const leftDelta = calcVectorDelta(self.size, @mod((self.direction + 150.0), 360.0));
        const rightDelta = calcVectorDelta(self.size, @mod((self.direction + 210.0), 360.0));

        print("Front Delta: {}, {}\n", .{ frontDelta.x, frontDelta.y });

        const frontPoint: Vector2 = .{ .x = (self.center.x + frontDelta.x), .y = (self.center.y + frontDelta.y) };
        const leftPoint: Vector2 = .{ .x = (self.center.x + leftDelta.x), .y = (self.center.y + leftDelta.y) };
        const rightPoint: Vector2 = .{ .x = (self.center.x + rightDelta.x), .y = (self.center.y + rightDelta.y) };

        print("Front Point: {}, {}\n", .{ frontPoint.x, frontPoint.y });
        print("Center: {}, {}\n", .{ self.center.x, self.center.y });

        rl.drawLineV(frontPoint, leftPoint, rl.Color.green);
        rl.drawLineV(frontPoint, rightPoint, rl.Color.blue);
        rl.drawLineV(leftPoint, rightPoint, WHITE);

        return;
    }
};

pub fn main() anyerror!void {
    rl.initWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Asteroids!");
    defer rl.closeWindow();

    rl.setTargetFPS(rl.getMonitorRefreshRate(1));
    rl.clearBackground(BLACK);

    const center = Vector2.init((SCREEN_WIDTH / 2), (SCREEN_HEIGHT / 2));
    rl.drawCircleLines(960, 540, 80.0, WHITE);
    var player = Ship.init(center, 90.0);
    player.draw();

    // Main game loop
    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();
    }
}

fn calcVectorDelta(size: f32, dir: f32) Vector2 {
    const radDir = toRadians(dir);
    const newX = size * std.math.cos(radDir);
    const newY = size * std.math.sin(radDir);
    return Vector2.init(newX, newY);
}

test toRadians {
    // 0 degrees
    try std.testing.expect(toRadians(0) == 0.0);

    // 240 degrees location
    try std.testing.expect(toRadians(240) == (std.math.pi * 4) / 3.0);

    // >360 degrees test
    // Not sure how to handle this yet
}

fn toRadians(deg: f32) f32 {
    return deg * (std.math.pi / 180.0);
}
