const std = @import("std");
const gui = @import("../gui/state.zig");

pub const amm = @import("ammunition.zig");
pub const weapon = @import("weapon.zig");

const calc = @import("calculations.zig");

const RiskValidationError = error{
    NoValue,
    NegativeValue,
    InvalidRange,
    IntegerOverflow,
    UnknownError,
    InvadlidCharacter,
};

pub const RiskArea = struct {
    // Given values
    weaponType: weapon.Weapons.Model,
    weaponCaliber: amm.Caliber,
    selectedWeaponType: i32,
    factor: i32,
    inForest: bool,
    forestDist: i32,

    Dmax: i32,
    Amax: i32,
    Amin: i32,
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

    fn validate(self: *RiskArea) RiskValidationError!void {
        // Check for zero values in Amax or Amin
        if (self.Amax == 0 or self.Amin == 0) {
            return RiskValidationError.NoValue;
        }

        // Check for invalid range conditions
        if (self.Amin > self.Amax or self.Amin > self.Dmax or self.Amax > self.Dmax) {
            return RiskValidationError.InvalidRange;
        }

        // Check for negative values
        if (self.Dmax < 0 or self.Amax < 0 or self.Amin < 0 or self.f < 0 or self.q1 < 0 or self.c < 0 or self.l < 0 or self.h < 0) {
            return RiskValidationError.NegativeValue;
        }

        // Check for integer overflow (example check - you can adjust based on your logic)
        if (self.Amax > std.math.maxInt(i32) or self.Amin > std.math.maxInt(i32) or self.Dmax > std.math.maxInt(i32) or self.f > std.math.maxInt(i32)) {
            return RiskValidationError.IntegerOverflow;
        }

        // If all checks pass, set the valid flag
        self.valid = true;
    }

    fn controlUpdate(self: *RiskArea, state: gui.guiState) bool {
        return (!(self.factor == state.riskFactor.value and
            self.fixedTarget == state.targetType.value and
            self.inForest == state.inForest.value and
            self.Amin == calc.combineAsciiToInt(&state.Amin.value) and
            self.Amax == calc.combineAsciiToInt(&state.Amax.value) and
            self.f == calc.combineAsciiToInt(&state.f.value) and
            self.forestDist == calc.combineAsciiToInt(&state.forestDist.value) and
            std.mem.eql(u8, self.weaponCaliber.name, calc.getAmmunitionType(state.ammunitionType.value).name) and
            std.mem.eql(u8, self.weaponType.caliber.name, calc.getWeaponType(state.weaponType.value).caliber.name)));
    }

    pub fn update(self: *RiskArea, state: gui.guiState) !void {
        if (controlUpdate(self, state) == false) return;

        self.factor = state.riskFactor.value;
        self.Amin = calc.combineAsciiToInt(&state.Amin.value);
        self.Amax = calc.combineAsciiToInt(&state.Amax.value);
        self.f = calc.combineAsciiToInt(&state.f.value);
        self.inForest = state.inForest.value;
        self.forestDist = calc.combineAsciiToInt(&state.forestDist.value);
        self.fixedTarget = state.targetType.value;
        self.weaponCaliber = calc.getAmmunitionType(state.ammunitionType.value);
        self.weaponType = calc.getWeaponType(state.weaponType.value);

        self.v = if (self.fixedTarget) self.weaponType.v_still else self.weaponType.v_moveable;
        self.Dmax = self.weaponCaliber.Dmax;

        self.l = self.calculateL();
        self.h = self.calculateH();
        self.c = self.calculateC();
        self.q1 = self.calculateQ1();
        self.q2 = self.calculateQ2();

        validate(self) catch |err| {
            std.log.info("Validation failed: {any}", .{err});
            return;
        };
    }
};
