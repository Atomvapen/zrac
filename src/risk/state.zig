const std = @import("std");
const calc = @import("calc.zig");
const utils = @import("../utils.zig");
const render = @import("../gui/render.zig");

pub const amm = @import("ammunition.zig");
pub const weapon = @import("weapon.zig");

const RiskValidationError = error{
    NoValue,
    NegativeValue,
    InvalidRange,
    IntegerOverflow,
    UnknownError,
    InvadlidCharacter,
};

// TODO rensa valeus som finns i weapon etc
// slå ihop med gui state
pub const RiskArea = struct {
    // Given values
    weaponType: weapon.Weapons.Model,
    weaponCaliber: amm.Caliber,
    selectedWeaponType: i32,
    factor: i32,
    interceptingForest: bool,

    fixedTarget: bool,

    forestDist: f32,
    Dmax: f32,
    Amax: f32,
    Amin: f32,
    f: f32,

    // Calculated and/or fixed values
    valid: bool,
    v: f32 = undefined,
    q1: f32 = undefined,
    q2: f32 = undefined,
    ch: f32 = 1000,

    c: f32 = undefined,
    l: f32 = undefined,
    h: f32 = undefined,

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
        if (self.Amax > std.math.floatMax(f32) or self.Amin > std.math.floatMax(f32) or self.Dmax > std.math.floatMax(f32) or self.f > std.math.floatMax(f32)) {
            return RiskValidationError.IntegerOverflow;
        }

        // If all checks pass, set the valid flag
        self.valid = true;
    }

    fn controlUpdate(self: *RiskArea, state: guiState) bool {
        return (!(self.factor == state.riskFactor.value and
            self.fixedTarget == state.targetType.value and
            self.interceptingForest == state.interceptingForest.value and
            self.Amin == utils.combineAsciiToFloat(&state.Amin.value) and
            self.Amax == utils.combineAsciiToFloat(&state.Amax.value) and
            self.f == utils.combineAsciiToFloat(&state.f.value) and
            self.forestDist == utils.combineAsciiToFloat(&state.forestDist.value) and
            std.mem.eql(u8, self.weaponCaliber.name, amm.getAmmunitionType(state.ammunitionType.value).name) and
            std.mem.eql(u8, self.weaponType.caliber.name, weapon.getWeaponType(state.weaponType.value).caliber.name)));
    }

    fn updateValues(self: *RiskArea, state: guiState) void {
        self.factor = state.riskFactor.value;
        self.Amin = utils.combineAsciiToFloat(&state.Amin.value);
        self.Amax = utils.combineAsciiToFloat(&state.Amax.value);
        self.f = utils.combineAsciiToFloat(&state.f.value);
        self.interceptingForest = state.interceptingForest.value;
        self.forestDist = utils.combineAsciiToFloat(&state.forestDist.value);
        self.fixedTarget = state.targetType.value;
        self.weaponCaliber = amm.getAmmunitionType(state.ammunitionType.value);
        self.weaponType = weapon.getWeaponType(state.weaponType.value);
        self.v = if (self.fixedTarget) self.weaponType.v_still else self.weaponType.v_moveable;
        self.Dmax = self.weaponCaliber.Dmax;
    }

    fn calculateMetrics(self: *RiskArea) void {
        self.l = calc.calculateL(self);
        self.h = calc.calculateH(self);
        self.c = calc.calculateC(self);
        self.q1 = calc.calculateQ1(self);
        self.q2 = calc.calculateQ2(self);
    }

    pub fn update(self: *RiskArea, state: guiState) !void {
        if (!controlUpdate(self, state)) return;

        self.updateValues(state);
        self.calculateMetrics();

        self.validate() catch |err| {
            std.log.info("Validation failed: {any}", .{err});
            return;
        };
    }
};

pub const guiState = struct {
    const textBoxState = struct {
        value: [64]u8,
        editMode: bool,
    };

    const checkBoxState = struct {
        value: bool,
    };

    const comboBoxState = struct {
        value: i32,
    };

    const dropdownBoxState = struct {
        value: i32,
        editMode: bool,
    };

    Amin: textBoxState,
    Amax: textBoxState,
    f: textBoxState,
    forestDist: textBoxState,
    draw: checkBoxState,
    interceptingForest: checkBoxState,
    riskFactor: comboBoxState,
    ammunitionType: dropdownBoxState,
    weaponType: dropdownBoxState,
    targetType: checkBoxState,
    menu: render.Menu,
    showInfoPanel: checkBoxState,

    pub fn init(self: *guiState) !void {
        self.reset();

        try self.menu.init();
        render.gui.draw.value = true;
    }

    pub fn reset(self: *guiState) void {
        self.Amin = .{ .editMode = false, .value = std.mem.zeroes([64]u8) };
        self.Amax = .{ .editMode = false, .value = std.mem.zeroes([64]u8) };
        self.f = .{ .editMode = false, .value = std.mem.zeroes([64]u8) };
        self.forestDist = .{ .editMode = false, .value = std.mem.zeroes([64]u8) };
        self.draw = .{ .value = true };
        self.interceptingForest = .{ .value = false };
        self.riskFactor = .{ .value = 0 };
        self.ammunitionType = .{ .editMode = false, .value = 0 };
        self.weaponType = .{ .editMode = false, .value = 0 };
        self.targetType = .{ .value = false };
    }
};
