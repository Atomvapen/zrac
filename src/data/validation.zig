const std = @import("std");
const Profile = @import("state.zig").RiskProfile;

const ValidationError = error{
    NoValue,
    NegativeValue,
    InvalidRange,
    Overflow,
    UnknownError,
};

pub fn validate(profile: *Profile) bool {
    if (!profile.config.show) return false;
    if (!validateZeroValues(profile)) return false;
    if (!validateRangeConditions(profile)) return false;
    if (!validateNegativeValues(profile)) return false;
    if (!validateOverflow(profile)) return false;

    return true;
}

fn validateZeroValues(profile: *Profile) bool {
    return (profile.terrainValues.Amax != 0 and
        profile.terrainValues.h != 0 and
        profile.terrainValues.l != 0 and
        profile.weaponValues.v != 0);
}

fn validateRangeConditions(profile: *Profile) bool {
    return (profile.terrainValues.Amin < profile.terrainValues.Amax and
        profile.terrainValues.f < profile.terrainValues.Amax and
        profile.terrainValues.f < profile.terrainValues.Amin and
        profile.terrainValues.forestDist < profile.terrainValues.h);
}

fn validateNegativeValues(profile: *Profile) bool {
    return (profile.terrainValues.Amax >= 0 and
        profile.terrainValues.Amin >= 0 and
        profile.terrainValues.f >= 0 and
        profile.terrainValues.l >= 0 and
        profile.terrainValues.h >= 0 and
        profile.terrainValues.forestDist >= 0);
}

fn validateOverflow(profile: *Profile) bool {
    const max = std.math.floatMax(f32);
    return (profile.terrainValues.Amax < max and
        profile.terrainValues.Amin < max and
        profile.terrainValues.f < max and
        profile.terrainValues.forestDist < max);
}
