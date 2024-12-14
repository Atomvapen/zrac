const profile = @import("state.zig").RiskArea;

pub fn calculateH(self: *profile) i32 {
    return self.Amax + self.l;
}

pub fn calculateL(self: *profile) i32 {
    return switch (self.factor + 1) {
        1 => @intFromFloat(0.8 * @as(f32, @floatFromInt(self.Dmax)) - 0.7 * @as(f32, @floatFromInt(self.Amax))),
        2 => @intFromFloat(0.6 * @as(f32, @floatFromInt(self.Dmax)) - 0.5 * @as(f32, @floatFromInt(self.Amax))),
        3 => @intFromFloat(0.4 * @as(f32, @floatFromInt(self.Dmax)) - 0.3 * @as(f32, @floatFromInt(self.Amax))),
        else => 0,
    };
}

pub fn calculateC(self: *profile) f32 {
    return switch (self.inForest) {
        true => self.weaponCaliber.c,
        false => switch (self.factor + 1) {
            1 => 0.2 * @as(f32, @floatFromInt(self.Dmax - self.Amin)),
            2 => 0.15 * @as(f32, @floatFromInt(self.Dmax - self.Amin)),
            3 => 0.08 * @as(f32, @floatFromInt(self.Dmax - self.Amin)),
            else => 0.0,
        },
    };
}

pub fn calculateQ1(self: *profile) f32 {
    return switch (self.factor + 1) {
        1 => self.weaponType.c,
        2, 3 => 400.0,
        else => 0.0,
    };
}

pub fn calculateQ2(self: *profile) f32 {
    return if (self.forestDist < 0) 0.0 else 1000.0;
}
