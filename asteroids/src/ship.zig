const std = @import("std");
const rl = @import("raylib");
const constants = @import("constants.zig");
const utils = @import("utils.zig");

const Vector2 = rl.Vector2;
const print = std.debug.print;

pub const Ship = struct {
    center: Vector2 = Vector2.init((constants.SCREEN_WIDTH / 2), (constants.SCREEN_HEIGHT / 2)),
    size: f32 = 20.0,
    direction: f32 = 270.0,
    points: [3]Vector2 = std.mem.zeroes([3]Vector2),

    pub fn init() Ship {
        var s = Ship{};
        s.setPoints();

        s.draw(constants.WHITE);
        return s;
    }

    pub fn setPoints(s: *Ship) void {
        const front = calcVectorDelta(s.size, s.direction);
        s.points[0] = Vector2.init(front.x + s.center.x, front.y + s.center.y);
        const left = calcVectorDelta(s.size, @mod((s.direction + 150.0), 360.0));
        s.points[1] = Vector2.init(left.x + s.center.x, left.y + s.center.y);
        const right = calcVectorDelta(s.size, @mod((s.direction + 210.0), 360.0));
        s.points[2] = Vector2.init(right.x + s.center.x, right.y + s.center.y);
    }

    pub fn move(self: *Ship, positionDelta: Vector2, angleDelta: f32) void {
        self.rotate(angleDelta);
        self.shift(positionDelta);
    }

    pub fn draw(self: *Ship, color: rl.Color) void {
        rl.drawLineV(self.points[0], self.points[1], color);
        rl.drawLineV(self.points[0], self.points[2], color);
        rl.drawLineV(self.points[1], self.points[2], color);
    }

    fn shift(self: *Ship, delta: Vector2) void {
        var newPoints = std.mem.zeroes([3]Vector2);
        for (newPoints, 0..) |_, i| {
            newPoints[i] = Vector2.init(self.points[i].x + delta.x, self.points[i].y + delta.y);
        }

        if (checkBounds(&newPoints)) {
            self.center.x += delta.x;
            self.center.y += delta.y;
            @memcpy(&self.points, &newPoints);
        }
    }

    // TODO: Optimize this function (or just clean it up)
    fn rotate(self: *Ship, angleDelta: f32) void {
        var newPoints = std.mem.zeroes([3]Vector2);
        const newDir = self.direction + angleDelta;

        const front = calcVectorDelta(self.size, newDir);
        newPoints[0].x = front.x + self.center.x;
        newPoints[0].y = front.y + self.center.y;
        const left = calcVectorDelta(self.size, @mod((newDir + 150.0), 360.0));
        newPoints[1].x = left.x + self.center.x;
        newPoints[1].y = left.y + self.center.y;
        const right = calcVectorDelta(self.size, @mod((newDir + 210.0), 360.0));
        newPoints[2].x = right.x + self.center.x;
        newPoints[2].y = right.y + self.center.y;

        if (checkBounds(&newPoints)) {
            self.direction = newDir;
            @memcpy(&self.points, &newPoints);
        }
    }

    // Returns true if its fine to move there
    fn checkBounds(points: *[3]Vector2) bool {
        for (points) |*point| {
            if (point.x >= constants.SCREEN_WIDTH or point.x < 0) return false;
            if (point.y >= constants.SCREEN_HEIGHT or point.y < 0) return false;
        }
        return true;
    }

    pub fn printData(self: *Ship) void {
        print("------------------------------\n", .{});
        print("Center - X: {}, Y: {}\n", .{ self.center.x, self.center.y });
        print("Size - {}\n", .{self.size});
        print("Direction - {}\n", .{self.direction});
        for (&self.points) |*point| {
            print("Center - X: {}, Y: {}\n", .{ point.x, point.y });
        }
        print("------------------------------\n", .{});
    }
};

// Inputs the size of the ship and the direction it is pointing and calculates the
// change in each point rotationally
fn calcVectorDelta(size: f32, dir: f32) Vector2 {
    const radDir = utils.toRadians(dir);
    const newX = size * std.math.cos(radDir);
    const newY = size * std.math.sin(radDir);
    return Vector2.init(newX, newY);
}
