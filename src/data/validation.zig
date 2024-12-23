const std = @import("std");
const riskProfile = @import("state.zig").riskProfile;

const ValidationError = error{
    NoValue,
    NegativeValue,
    InvalidRange,
    IntegerOverflow,
    UnknownError,
    InvadlidCharacter,
};

pub fn validate(self: *riskProfile) bool {
    if (!self.show) return false;
    if (!validateZeroValues(self)) return false;
    if (!validateRangeConditions(self)) return false;
    if (!validateNegativeValues(self)) return false;
    if (!validateOverflow(self)) return false;

    return true;
}

fn validateZeroValues(self: *riskProfile) bool {
    return !(self.terrainValues.Amax == 0 or
        self.terrainValues.h == 0 or
        self.terrainValues.l == 0 or
        self.weaponValues.v == 0);
}

fn validateRangeConditions(self: *riskProfile) bool {
    return !(self.terrainValues.Amin > self.terrainValues.Amax or
        self.terrainValues.f > self.terrainValues.Amax or
        self.terrainValues.f > self.terrainValues.Amin or
        self.terrainValues.forestDist > self.terrainValues.Amax);
}

fn validateNegativeValues(self: *riskProfile) bool {
    return !(self.terrainValues.Amax < 0 or
        self.terrainValues.Amin < 0 or
        self.terrainValues.f < 0 or
        self.terrainValues.l < 0 or
        self.terrainValues.h < 0 or
        self.terrainValues.forestDist < 0);
}

fn validateOverflow(self: *riskProfile) bool {
    const max = std.math.floatMax(f32);
    return !(self.terrainValues.Amax > max or
        self.terrainValues.Amin > max or
        self.terrainValues.f > max or
        self.terrainValues.forestDist > max);
}
