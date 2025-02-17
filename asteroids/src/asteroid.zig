const std = @import("std");
const rl = @import("raylib");
const utils = @import("utils.zig");
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
        // const velocity = Vector2.one();
        const velocity = calculateInitialVelocity(center);

        return Asteroid{
            .center = center,
            .size = size,
            .velocity = velocity,
        };
    }

    fn generateSpawnLocation(rng: std.Random) Vector2 {
        const side = rng.intRangeLessThan(u8, 0, 4); // 0 : left, 1: top, 2: right, 3: bottom
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

    fn calculateInitialVelocity(center: Vector2) Vector2 {
        // Figure out what side the asteroid is starting on
        var addAngle: f16 = 0.0;

        // We don't need the case the asteroid is starting at the bottom of the screen
        // because we don't need to change our angle calculation for that
        if (center.x == 0) {
            addAngle = 270.0;
        } else if (center.x == constants.SCREEN_WIDTH) {
            addAngle = 90.0;
        } else if (center.y == constants.SCREEN_HEIGHT) {
            addAngle = 180.0;
        }

        // Generate the min / max angles and the corresponding vectors
        const highAngle: Vector2 = utils.generateDirectionVector(135.0 + addAngle).normalize();
        const lowAngle: Vector2 = utils.generateDirectionVector(45.0 + addAngle).normalize();

        // Calculate a random vector between those bounds and return
        var rng = std.crypto.random;
        const xComponent = splitValues(lowAngle.x, highAngle.x, rng.float(f32));
        const yComponent = splitValues(lowAngle.y, highAngle.y, rng.float(f32));

        return Vector2.init(xComponent, yComponent).normalize();
    }

    // Helper function used to find the vector value that is inbetween two other vectors. Used for x and y individually
    fn splitValues(lowComponent: f32, highComponent: f32, randomVal: f32) f32 {
        var lower: f32 = 0.0;
        var higher: f32 = 0.0;
        if (lowComponent > highComponent) {
            lower = highComponent;
            higher = lowComponent;
        } else {
            lower = lowComponent;
            higher = highComponent;
        }

        const diff = 0.0 - lower;
        higher += diff;
        higher *= randomVal;
        higher -= diff;

        return higher;
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
