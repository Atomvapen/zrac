const std = @import("std");
const reg = @import("reg");
const State = reg.data.State;

const ValidationError = error{
    NoValue,
    NegativeValue,
    InvalidRange,
    Overflow,
    UnknownError,
};

pub fn validate(state: *State) bool {
    if (!state.config.show) return false;
    if (!validateZeroValues(state)) return false;
    if (!validateRangeConditions(state)) return false;
    if (!validateNegativeValues(state)) return false;
    if (!validateOverflow(state)) return false;
    switch (state.config.sort) {
        .Box => if (!validateBox(state)) return false,
        .SST => if (!validateSST(state)) return false,
        .Halva => return true,
    }

    return true;
}

fn validateBox(state: *State) bool {
    return (state.box.length > 0 and
        state.box.width > 0 and
        state.box.v > 0 and
        state.box.h > 0);
}

fn validateSST(state: *State) bool {
    return (state.sst.width > 0 and
        state.sst.hh > 0 and
        state.sst.hv > 0 and
        state.sst.vv > 0 and
        state.sst.vh > 0);
}

fn validateZeroValues(state: *State) bool {
    return (state.terrainValues.Amax != 0 and
        state.terrainValues.h != 0 and
        state.terrainValues.l != 0 and
        state.weaponValues.v != 0);
}

fn validateRangeConditions(state: *State) bool {
    return (state.terrainValues.Amin < state.terrainValues.Amax and
        state.terrainValues.f < state.terrainValues.Amax and
        state.terrainValues.f < state.terrainValues.Amin and
        state.terrainValues.forestDist < state.terrainValues.h);
}

fn validateNegativeValues(state: *State) bool {
    return (state.terrainValues.Amax >= 0 and
        state.terrainValues.Amin >= 0 and
        state.terrainValues.f >= 0 and
        state.terrainValues.l >= 0 and
        state.terrainValues.h >= 0 and
        state.terrainValues.forestDist >= 0);
}

fn validateOverflow(state: *State) bool {
    const max = std.math.floatMax(f32);
    return (state.terrainValues.Amax < max and
        state.terrainValues.Amin < max and
        state.terrainValues.f < max and
        state.terrainValues.forestDist < max);
}
