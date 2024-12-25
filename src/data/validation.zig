const std = @import("std");
const RiskProfile = @import("state.zig").RiskProfile;

const ValidationError = error{
    NoValue,
    NegativeValue,
    InvalidRange,
    Overflow,
    UnknownError,
};

pub fn validate(self: *RiskProfile) bool {
    std.debug.print("zero: {any}\n", .{validateZeroValues(self)});
    std.debug.print("range: {any}\n", .{validateRangeConditions(self)});
    std.debug.print("negative: {any}\n", .{validateNegativeValues(self)});
    std.debug.print("overflow: {any}\n", .{validateOverflow(self)});

    if (!self.config.show) return false;
    if (!validateZeroValues(self)) return false;
    if (!validateRangeConditions(self)) return false;
    if (!validateNegativeValues(self)) return false;
    if (!validateOverflow(self)) return false;

    return true;
}

fn validateZeroValues(self: *RiskProfile) bool {
    return (self.terrainValues.Amax != 0 and
        self.terrainValues.h != 0 and
        self.terrainValues.l != 0 and
        self.weaponValues.v != 0);
}

fn validateRangeConditions(self: *RiskProfile) bool {
    return (self.terrainValues.Amin < self.terrainValues.Amax and
        self.terrainValues.f < self.terrainValues.Amax and
        self.terrainValues.f < self.terrainValues.Amin and
        self.terrainValues.forestDist < self.terrainValues.h);
}

fn validateNegativeValues(self: *RiskProfile) bool {
    return (self.terrainValues.Amax >= 0 and
        self.terrainValues.Amin >= 0 and
        self.terrainValues.f >= 0 and
        self.terrainValues.l >= 0 and
        self.terrainValues.h >= 0 and
        self.terrainValues.forestDist >= 0);
}

fn validateOverflow(self: *RiskProfile) bool {
    const max = std.math.floatMax(f32);
    return (self.terrainValues.Amax < max and
        self.terrainValues.Amin < max and
        self.terrainValues.f < max and
        self.terrainValues.forestDist < max);
}
