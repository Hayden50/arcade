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

        const center = generateSpawnLocation(rng);
        const velocity = Vector2.one();

        return Asteroid{
            .center = center,
            .size = size,
            .velocity = velocity,
        };
    }

    fn generateSpawnLocation(rng: std.Random) Vector2 {

        // 0 : left, 1: top, 2: right, 3: bottom
        const side = rng.intRangeLessThan(u8, 0, 4);
        var xVal: f32 = 0.0;
        var yVal: f32 = 0.0;

        switch (side) {
            0 => {
                yVal = @as(f32, @floatFromInt(rng.intRangeLessThan(u32, 0, constants.SCREEN_HEIGHT)));
            },
            1 => {
                xVal = @as(f32, @floatFromInt(rng.intRangeLessThan(u32, 0, constants.SCREEN_WIDTH)));
            },
            2 => {
                xVal = @as(f32, @floatFromInt(constants.SCREEN_WIDTH));
                yVal = @as(f32, @floatFromInt(rng.intRangeLessThan(u32, 0, constants.SCREEN_HEIGHT)));
            },
            3 => {
                xVal = @as(f32, @floatFromInt(rng.intRangeLessThan(u32, 0, constants.SCREEN_WIDTH)));
                yVal = @as(f32, @floatFromInt(constants.SCREEN_HEIGHT));
            },
            else => {},
        }

        return Vector2.init(xVal, yVal);
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
        // TODO: Cleanup this casting
        const asteroidSize = 10.0 * @as(f32, @floatFromInt(@intFromEnum(self.size)));
        rl.drawCircleV(self.center, asteroidSize, constants.WHITE);
    }
};
