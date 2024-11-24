const WeaponType = enum {
    AK5,
    KSP58,
};

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
    valid: bool,
    v: i32 = undefined,
    q1: i32 = undefined,
    q2: i32 = undefined,
    ch: i32 = 1000,

    c: i32 = undefined,
    l: i32 = undefined,
    h: i32 = undefined,

    pub fn validate(self: *RiskArea) bool {
        return !((self.f == 0 and self.Amax == 0 and self.Amin == 0) or
            (self.forestMin < -1) or
            (self.forestMin > self.Dmax) or
            (self.Dmax < 0) or
            (self.Amax < 0) or
            (self.Amin < 0) or
            (self.f < 0) or
            (self.q1 < 0) or
            (self.c < 0) or
            (self.l < 0) or
            (self.h < 0) or
            (self.Amin > self.Amax) or
            (self.Amax > self.Dmax) or
            (self.f > self.Amin) or
            (self.f > self.Amax) or
            (self.f > self.Dmax));
    }

    pub fn calculateH(self: *RiskArea) i32 {
        return self.Amax + self.l;
    }

    pub fn calculateL(self: *RiskArea) i32 {
        switch (self.factor) {
            1 => return @intFromFloat(0.8 * @as(f64, @floatFromInt(self.Dmax)) - 0.7 * @as(f64, @floatFromInt(self.Amax))),
            2 => return @intFromFloat(0.6 * @as(f64, @floatFromInt(self.Dmax)) - 0.5 * @as(f64, @floatFromInt(self.Amax))),
            3 => return @intFromFloat(0.4 * @as(f64, @floatFromInt(self.Dmax)) - 0.3 * @as(f64, @floatFromInt(self.Amax))),
            else => return 0,
        }
    }

    pub fn calculateC(self: *RiskArea) i32 {
        switch (self.inForest) {
            true => return 200.0,
            false => switch (self.factor) {
                1 => return @intFromFloat(0.2 * @as(f64, @floatFromInt(self.Dmax - self.Amin))),
                2 => return @intFromFloat(0.15 * @as(f64, @floatFromInt(self.Dmax - self.Amin))),
                3 => return @intFromFloat(0.08 * @as(f64, @floatFromInt(self.Dmax - self.Amin))),
                else => return 0,
            },
        }
    }

    pub fn calculateQ1(self: *RiskArea) i32 {
        switch (self.factor) {
            1 => return 200,
            2, 3 => return 400,
            else => return 0,
        }
    }

    pub fn calculateQ2(self: *RiskArea) i32 {
        if (self.forestMin < 0) return 0;
        return 1000;

        // switch (self.forestMin) {
        //     0 => return 0,
        //     else => return 1000,
        // }
    }
};

pub fn milsToDegree(mils: i32) f64 {
    return @as(f64, @floatFromInt(mils)) * 0.05625;
}

pub fn milsToRadians(mils: i32) f64 {
    return @as(f64, @floatFromInt(mils)) * 0.000982;
}
