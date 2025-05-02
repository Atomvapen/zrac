const std = @import("std");
const vec = @import("vector.zig");

const Vec2f = vec.Vec2f;

pub const AngleUnit = enum {
    Mils,
    Degrees,
    Radians,
};

/// Calculates the length of one leg of a right triangle given the other leg and an angle.
///
/// ### Paramaters
/// - `angle` Angle θ (where 0<θ<90∘) in rad
/// - `length` Length of the adjacent leg a
pub fn triangleOppositeLeg(length: f32, angle: f32) f32 {
    return length * @tan(angle);
}

pub fn getIntersectionPoint(a1: Vec2f, a2: Vec2f, b1: Vec2f, b2: Vec2f) ?Vec2f {
    const denom = (a1[0] - a2[0]) * (b1[1] - b2[1]) - (a1[1] - a2[1]) * (b1[0] - b2[0]);
    if (denom == 0.0) return null;

    const t = ((a1[0] - b1[0]) * (b1[1] - b2[1]) - (a1[1] - b1[1]) * (b1[0] - b2[0])) / denom;

    return a1 + @as(Vec2f, @splat(t)) * (a2 - a1);
}

pub fn getParallelLine(start: Vec2f, end: Vec2f, offset: f32) [2]Vec2f {
    const dir = end - start;
    const perp: Vec2f = .{ -dir[1], dir[0] };
    const length = std.math.sqrt(perp[0] * perp[0] + perp[1] * perp[1]);
    const norm = perp / @as(Vec2f, @splat(length));
    const offset_vec = norm * @as(Vec2f, @splat(offset));

    return .{ start + offset_vec, end + offset_vec };
}
