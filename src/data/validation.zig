const std = @import("std");
const RiskProfile = @import("state.zig").RiskProfile;

const ValidationError = error{
    NoValue,
    NegativeValue,
    InvalidRange,
    IntegerOverflow,
    UnknownError,
    InvadlidCharacter,
};

pub fn validate(self: *RiskProfile) bool {
    if (!self.config.show) return false;
    if (!validateZeroValues(self)) return false;
    if (!validateRangeConditions(self)) return false;
    if (!validateNegativeValues(self)) return false;
    if (!validateOverflow(self)) return false;

    return true;
}

fn validateZeroValues(self: *RiskProfile) bool {
    return !(self.terrainValues.Amax == 0 or
        self.terrainValues.h == 0 or
        self.terrainValues.l == 0 or
        self.weaponValues.v == 0);
}

fn validateRangeConditions(self: *RiskProfile) bool {
    return !(self.terrainValues.Amin > self.terrainValues.Amax or
        self.terrainValues.f > self.terrainValues.Amax or
        self.terrainValues.f > self.terrainValues.Amin or
        self.terrainValues.forestDist > self.terrainValues.Amax);
}

fn validateNegativeValues(self: *RiskProfile) bool {
    return !(self.terrainValues.Amax < 0 or
        self.terrainValues.Amin < 0 or
        self.terrainValues.f < 0 or
        self.terrainValues.l < 0 or
        self.terrainValues.h < 0 or
        self.terrainValues.forestDist < 0);
}

fn validateOverflow(self: *RiskProfile) bool {
    const max = std.math.floatMax(f32);
    return !(self.terrainValues.Amax > max or
        self.terrainValues.Amin > max or
        self.terrainValues.f > max or
        self.terrainValues.forestDist > max);
}
