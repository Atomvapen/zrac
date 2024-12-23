const state = @import("../data/state.zig").riskProfile;

pub fn calculateH(self: *state) f32 {
    return self.terrainValues.Amax + self.terrainValues.l;
}

pub fn calculateL(self: *state) f32 {
    return switch (self.terrainValues.factor) {
        .I => 0.8 * self.weaponValues.caliber.Dmax - 0.7 * self.terrainValues.Amax,
        .II => 0.6 * self.weaponValues.caliber.Dmax - 0.5 * self.terrainValues.Amax,
        .III => 0.4 * self.weaponValues.caliber.Dmax - 0.3 * self.terrainValues.Amax,
    };
}

pub fn calculateC(self: *state) f32 {
    return switch (self.terrainValues.interceptingForest) {
        false => self.weaponValues.caliber.c,
        true => switch (self.terrainValues.factor) {
            .I => 0.2 * (self.weaponValues.caliber.Dmax - self.terrainValues.Amin),
            .II => 0.15 * (self.weaponValues.caliber.Dmax - self.terrainValues.Amin),
            .III => 0.08 * (self.weaponValues.caliber.Dmax - self.terrainValues.Amin),
        },
    };
}

pub fn calculateQ1(self: *state) f32 {
    return switch (self.terrainValues.factor) {
        .I => self.weaponValues.caliber.c,
        .II, .III => 400.0,
    };
}

pub fn calculateQ2(self: *state) f32 {
    return if (self.terrainValues.forestDist < 0) 0.0 else 1000.0;
}
