const riskProfile = @import("../data/state.zig").riskState;

pub fn calculateH(self: *riskProfile) f32 {
    return self.getAmax() + self.l;
}

pub fn calculateL(self: *riskProfile) f32 {
    return switch (self.getFactor() + 1) {
        1 => 0.8 * self.getDmax() - 0.7 * self.getAmax(),
        2 => 0.6 * self.getDmax() - 0.5 * self.getAmax(),
        3 => 0.4 * self.getDmax() - 0.3 * self.getAmax(),
        else => 0,
    };
}

pub fn calculateC(self: *riskProfile) f32 {
    return switch (self.getInterceptingForest()) {
        false => self.getWeaponCaliber().c,
        true => switch (self.getFactor() + 1) {
            1 => 0.2 * (self.getDmax() - self.getAmin()),
            2 => 0.15 * (self.getDmax() - self.getAmin()),
            3 => 0.08 * (self.getDmax() - self.getAmin()),
            else => 0.0,
        },
    };
}

pub fn calculateQ1(self: *riskProfile) f32 {
    return switch (self.getFactor() + 1) {
        1 => self.getWeaponCaliber().c,
        2, 3 => 400.0,
        else => 0.0,
    };
}

pub fn calculateQ2(self: *riskProfile) f32 {
    return if (self.getForestDist() < 0) 0.0 else 1000.0;
}
