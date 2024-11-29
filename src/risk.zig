const std = @import("std");
const arms = @import("weapons.zig");
const gui = @import("gui.zig");

pub const RiskArea = struct {
    // Given values
    weaponType: arms.Weapon,
    selectedWeaponType: i32,
    factor: i32,
    inForest: bool,
    forestDist: i32,

    Dmax: i32,
    Amax: i32,
    Amin: i32,
    Amin2: [*:0]u8,
    f: i32,
    fixedTarget: bool,

    // Calculated and/or fixed values
    valid: bool,
    v: f32 = undefined,
    q1: f32 = undefined,
    q2: f32 = undefined,
    ch: f32 = 1000,

    c: f32 = undefined,
    l: i32 = undefined,
    h: i32 = undefined,

    pub fn update(self: *RiskArea, state: gui.guiState) !void {
        self.factor = state.riskFactor.value;
        self.Amin = combineAsciiToInt(&state.Amin.value);
        self.Amax = combineAsciiToInt(&state.Amax.value);
        self.f = combineAsciiToInt(&state.f.value);
        self.inForest = state.inForest.value;
        self.forestDist = combineAsciiToInt(&state.forstDist.value);
        self.fixedTarget = state.targetType.value;
        self.weaponType = switch (state.weaponType.value) {
            0 => arms.Weapons.AK5,
            1 => arms.Weapons.KSP58,
            2 => arms.Weapons.KSP58_Benstod,
            else => arms.Weapons.invalid,
        };

        self.v = if (self.fixedTarget) self.weaponType.v_still else self.weaponType.v_moveable;
        self.Dmax = self.weaponType.Dmax;

        self.l = self.calculateL();
        self.h = self.calculateH();
        self.c = self.calculateC();
        self.q1 = self.calculateQ1();
        self.q2 = self.calculateQ2();
    }

    pub fn validate(self: *RiskArea) void {
        self.valid = !((self.f == 0 and self.Amax == 0 and self.Amin == 0) or
            (self.forestDist < -1) or
            (self.Dmax < 0) or
            (self.Amax < 0) or
            (self.Amin < 0) or
            (self.f < 0) or
            (self.q1 < 0) or
            (self.c < 0) or
            (self.l < 0) or
            (self.h < 0) or
            (self.Amin > self.Amax) or
            (self.Amax > self.Dmax));
    }

    pub fn calculateH(self: *RiskArea) i32 {
        return self.Amax + self.l;
    }

    pub fn calculateL(self: *RiskArea) i32 {
        switch (self.factor + 1) {
            1 => return @intFromFloat(0.8 * @as(f32, @floatFromInt(self.Dmax)) - 0.7 * @as(f32, @floatFromInt(self.Amax))),
            2 => return @intFromFloat(0.6 * @as(f32, @floatFromInt(self.Dmax)) - 0.5 * @as(f32, @floatFromInt(self.Amax))),
            3 => return @intFromFloat(0.4 * @as(f32, @floatFromInt(self.Dmax)) - 0.3 * @as(f32, @floatFromInt(self.Amax))),
            else => return 0,
        }
    }

    pub fn calculateC(self: *RiskArea) f32 {
        switch (self.inForest) {
            true => return 200.0,
            false => switch (self.factor + 1) {
                1 => return 0.2 * @as(f32, @floatFromInt(self.Dmax - self.Amin)),
                2 => return 0.15 * @as(f32, @floatFromInt(self.Dmax - self.Amin)),
                3 => return 0.08 * @as(f32, @floatFromInt(self.Dmax - self.Amin)),
                else => return 0.0,
            },
        }
    }

    pub fn calculateQ1(self: *RiskArea) f32 {
        switch (self.factor + 1) {
            1 => return self.weaponType.c,
            2, 3 => return 400.0,
            else => return 0.0,
        }
    }

    pub fn calculateQ2(self: *RiskArea) f32 {
        if (self.forestDist < 0) return 0.0;
        return 1000.0;
    }
};

fn combineAsciiToInt(asciiArray: []const u8) i32 {
    var result: i32 = 0;

    for (asciiArray) |asciiChar| {
        const digit = @as(i32, @intCast(asciiChar)) - '0'; // Convert ASCII digit to numeric value

        // Check for potential overflow before performing the operation
        if (digit < 0 or digit > 9) continue; // Skip non-digit characters

        if (result > @divFloor((std.math.maxInt(i32) - digit), 10)) {
            // Handle overflow (e.g., return an error, set result to max, etc.)
            return std.math.maxInt(i32); // Return max value on overflow
        }

        result = result * 10 + digit; // Shift left and add digit
    }

    return result;
}
