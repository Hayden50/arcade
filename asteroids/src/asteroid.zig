const std = @import("std");
const rl = @import("raylib");
const constants = @import("constants.zig");

const Vector2 = rl.Vector2;

const Size = enum(u2) {
    small = 3,
    medium = 2,
    large = 1,
};

pub const Asteroid = struct {
    center: Vector2,
    size: Size,
    velocity: Vector2,

    pub fn init() Asteroid {
        var rng = std.crypto.random;
        const sizeVals = std.enums.values(Size);
        const size = sizeVals[rng.intRangeLessThan(usize, 0, 3)];

        var xVal: f32 = 0.0;
        var yVal: f32 = 0.0;

        // Randomly choose if the asteroids are coming from the top or bottom
        if (rng.boolean()) {
            xVal = @as(f32, @floatFromInt(rng.intRangeLessThan(u32, 0, constants.SCREEN_WIDTH)));
            yVal = 0.0;
        } else {
            xVal = 0.0;
            yVal = @as(f32, @floatFromInt(rng.intRangeLessThan(u32, 0, constants.SCREEN_HEIGHT)));
        }
        const center = Vector2.init(xVal, yVal);
        const velocity = Vector2.one();

        return Asteroid{
            .center = center,
            .size = size,
            .velocity = velocity,
        };
    }

    // TODO: Implement this function properly
    pub fn split(self: *Asteroid) ?[2]*Asteroid {
        if (self.size == Size.small) {
            return null;
        } else if (self.size == Size.medium) {
            return null;
        } else {
            return null;
        }
    }

    pub fn move(self: *Asteroid) void {
        self.center = self.center.add(self.velocity);
        self.draw();
    }

    fn draw(self: *Asteroid) void {
        rl.drawCircleV(self.center, 10.0 * @intFromEnum(self.size), constants.WHITE);
    }
};
