const std = @import("std");

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
