const std = @import("std");
const rl = @import("raylib");
const constants = @import("constants.zig");
const utils = @import("utils.zig");

const Vector2 = rl.Vector2;

pub const Bullet = struct {
    direction: Vector2,
    location: Vector2,

    pub fn init(angle: f32, location: Vector2) Bullet {
        const radAngle = utils.toRadians(angle);
        const xAxis = @cos(radAngle);
        const yAxis = @sin(radAngle);
        const nonNormalizedVector = Vector2.init(xAxis, yAxis);
        const direction = nonNormalizedVector.normalize();

        return Bullet{
            .direction = direction,
            .location = location,
        };
    }

    pub fn move(self: *Bullet) void {
        self.location = self.location.add(self.direction.scale(constants.BULLET_SPEED));
        self.draw();
    }

    fn draw(self: *Bullet) void {
        rl.drawCircleV(self.location, 1.5, constants.WHITE);
    }
};
