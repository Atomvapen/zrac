pub const RiskArea = struct {
    // Given values
    factor: i32,
    inForest: bool,
    forestMin: i32,
    PV: bool,

    Dmax: i32,
    Amax: i32,
    Amin: i32,
    f: i32,

    // Calculated and/or fixed values
    v: i32 = undefined,
    q1: i32 = undefined,
    q2: i32 = undefined,
    ch: i32 = 1000,

    c: i32 = undefined,
    l: i32 = undefined,
    h: i32 = undefined,
};

pub fn calculateH(Amax: i32, l: i32) i32 {
    return Amax + l;
}

pub fn calculateL(RF: i32, Dmax: i32, Amax: i32) i32 {
    const val: f64 = switch (RF) {
        1 => 0.8 * @as(f64, @floatFromInt(Dmax)) - 0.7 * @as(f64, @floatFromInt(Amax)),
        2 => 0.6 * @as(f64, @floatFromInt(Dmax)) - 0.5 * @as(f64, @floatFromInt(Amax)),
        3 => 0.4 * @as(f64, @floatFromInt(Dmax)) - 0.3 * @as(f64, @floatFromInt(Amax)),
        else => 0,
    };

    return @intFromFloat(val);
}

pub fn calculateC(RF: i32, Dmax: i32, Amin: i32, inForest: bool) i32 {
    const val: f64 = switch (inForest) {
        true => 200.0,
        false => switch (RF) {
            1 => 0.2 * @as(f64, @floatFromInt(Dmax - Amin)),
            2 => 0.15 * @as(f64, @floatFromInt(Dmax - Amin)),
            3 => 0.08 * @as(f64, @floatFromInt(Dmax - Amin)),
            else => 0,
        },
    };

    return @intFromFloat(val);
}

pub fn calculateQ1(RF: i32) i32 {
    const value = switch (RF) {
        1 => 200,
        2 => 400,
        2 => 400,
    };
    return value;
}

pub fn calculateQ2(inForest: bool) i32 {
    const value = switch (inForest) {
        true => 0,
        false => 1000,
    };
    return value;
}

pub fn milsToDegree(mils: i32) f64 {
    return @as(f64, @floatFromInt(mils)) * 0.05625;
}

pub fn milsToRadians(mils: i32) f64 {
    return @as(f64, @floatFromInt(mils)) * 0.000982;
}
