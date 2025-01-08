const std = @import("std");
const reg = @import("reg");

pub const AngleUnit = enum {
    Mils,
    Degrees,
    Radians,
};

/// Calculates the length of one leg of a right triangle given the other leg and an angle.
///
/// ### Paramaters
/// - `angle` Angle θ (where 0<θ<90∘) in mils
/// - `length` Length of the adjacent leg a
pub fn triangleOppositeLeg(length: f32, angle: f32) f32 {
    return length * @tan(convertAngle(angle, .Mils, .Radians));
}

/// Converts an angle measurement from one unit to another.
///
/// ### Parameters
/// - `value` (`f32`): The angle value to convert.
/// - `from` (`AngleUnit`): The unit of the input angle. Must be one of:
///   - `.Mils`: Milliradians
///   - `.Degrees`: Degrees
///   - `.Radians`: Radians
/// - `to` (`AngleUnit`): The desired unit for the output angle. Must also be one of the options in `AngleUnit`.
pub fn convertAngle(value: f32, from: AngleUnit, to: AngleUnit) f32 {
    const MILS_TO_DEGREES: f32 = 0.05625;
    const DEGREES_TO_RADIANS: f32 = std.math.pi / 180.0;

    if (from == to) return value;

    const intermediateDegrees: f32 = switch (from) {
        .Mils => value * MILS_TO_DEGREES,
        .Degrees => value,
        .Radians => value / DEGREES_TO_RADIANS,
    };

    return switch (to) {
        .Mils => intermediateDegrees / MILS_TO_DEGREES,
        .Degrees => intermediateDegrees,
        .Radians => intermediateDegrees * DEGREES_TO_RADIANS,
    };
}
