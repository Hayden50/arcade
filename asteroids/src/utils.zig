const std = @import("std");
const rl = @import("raylib");

test toRadians {
    // 0 degrees
    try std.testing.expect(toRadians(0) == 0.0);

    // 240 degrees location
    try std.testing.expect(toRadians(240) == (std.math.pi * 4) / 3.0);

    // >360 degrees test
    // Not sure how to handle this yet
}

pub fn toRadians(deg: f32) f32 {
    return deg * (std.math.pi / 180.0);
}

pub fn generateDirectionVector(angle: f16) rl.Vector2 {
    const x = @cos(toRadians(angle));
    const y = @sin(toRadians(angle));
    return rl.Vector2.init(x, y);
}
