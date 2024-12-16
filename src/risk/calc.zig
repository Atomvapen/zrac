const riskProfile = @import("state.zig").RiskArea;

pub fn calculateH(self: *riskProfile) f32 {
    return self.Amax + self.l;
}

pub fn calculateL(self: *riskProfile) f32 {
    return switch (self.factor + 1) {
        1 => 0.8 * self.Dmax - 0.7 * self.Amax,
        2 => 0.6 * self.Dmax - 0.5 * self.Amax,
        3 => 0.4 * self.Dmax - 0.3 * self.Amax,
        else => 0,
    };
}

pub fn calculateC(self: *riskProfile) f32 {
    return switch (self.interceptingForest) {
        false => self.weaponCaliber.c,
        true => switch (self.factor + 1) {
            1 => 0.2 * (self.Dmax - self.Amin),
            2 => 0.15 * (self.Dmax - self.Amin),
            3 => 0.08 * (self.Dmax - self.Amin),
            else => 0.0,
        },
    };
}

pub fn calculateQ1(self: *riskProfile) f32 {
    return switch (self.factor + 1) {
        1 => self.weaponType.c,
        2, 3 => 400.0,
        else => 0.0,
    };
}

pub fn calculateQ2(self: *riskProfile) f32 {
    return if (self.forestDist < 0) 0.0 else 1000.0;
}
