const reg = @import("reg");
const State = reg.data.State;

pub fn calculateH(state: State) f32 {
    return state.terrainValues.Amax + state.terrainValues.l;
}

pub fn calculateL(state: State) f32 {
    return switch (state.terrainValues.factor) {
        .I => 0.8 * state.weaponValues.caliber.Dmax - 0.7 * state.terrainValues.Amax,
        .II => 0.6 * state.weaponValues.caliber.Dmax - 0.5 * state.terrainValues.Amax,
        .III => 0.4 * state.weaponValues.caliber.Dmax - 0.3 * state.terrainValues.Amax,
    };
}

pub fn calculateC(state: State) f32 {
    return switch (state.terrainValues.interceptingForest) {
        true => state.weaponValues.caliber.c,
        false => switch (state.terrainValues.factor) {
            .I => 0.2 * (state.weaponValues.caliber.Dmax - state.terrainValues.Amin),
            .II => 0.15 * (state.weaponValues.caliber.Dmax - state.terrainValues.Amin),
            .III => 0.08 * (state.weaponValues.caliber.Dmax - state.terrainValues.Amin),
        },
    };
}

pub fn calculateQ1(state: State) f32 {
    return switch (state.terrainValues.factor) {
        .I => state.weaponValues.caliber.c,
        .II, .III => 400.0,
    };
}

pub fn calculateQ2(state: State) f32 {
    return if (state.terrainValues.forestDist < 0) 0.0 else 1000.0;
}
