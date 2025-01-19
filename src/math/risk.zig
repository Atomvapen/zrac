const reg = @import("reg");
const RiskProfile = reg.data.state;

pub fn calculateH(riskProfile: RiskProfile) f32 {
    return riskProfile.terrainValues.Amax + riskProfile.terrainValues.l;
}

pub fn calculateL(riskProfile: RiskProfile) f32 {
    return switch (riskProfile.terrainValues.factor) {
        .I => 0.8 * riskProfile.weaponValues.caliber.Dmax - 0.7 * riskProfile.terrainValues.Amax,
        .II => 0.6 * riskProfile.weaponValues.caliber.Dmax - 0.5 * riskProfile.terrainValues.Amax,
        .III => 0.4 * riskProfile.weaponValues.caliber.Dmax - 0.3 * riskProfile.terrainValues.Amax,
    };
}

pub fn calculateC(riskProfile: RiskProfile) f32 {
    return switch (riskProfile.terrainValues.interceptingForest) {
        true => riskProfile.weaponValues.caliber.c,
        false => switch (riskProfile.terrainValues.factor) {
            .I => 0.2 * (riskProfile.weaponValues.caliber.Dmax - riskProfile.terrainValues.Amin),
            .II => 0.15 * (riskProfile.weaponValues.caliber.Dmax - riskProfile.terrainValues.Amin),
            .III => 0.08 * (riskProfile.weaponValues.caliber.Dmax - riskProfile.terrainValues.Amin),
        },
    };
}

pub fn calculateQ1(riskProfile: RiskProfile) f32 {
    return switch (riskProfile.terrainValues.factor) {
        .I => riskProfile.weaponValues.caliber.c,
        .II, .III => 400.0,
    };
}

pub fn calculateQ2(riskProfile: RiskProfile) f32 {
    return if (riskProfile.terrainValues.forestDist < 0) 0.0 else 1000.0;
}
