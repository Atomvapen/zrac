const std = @import("std");
const calc = @import("../math/risk.zig");
const utils = @import("conversion.zig");
const render = @import("../gui/render.zig");
const menuPane = @import("../gui/menu.zig").Menu;

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

pub const riskState = struct {
    const textBoxState = struct {
        value: [64]u8,
        editMode: bool,
    };

    const dropdownBoxState = struct {
        value: i32,
        editMode: bool,
    };

    valid: bool,
    showLines: bool,
    showPanel: bool,
    menu: menuPane,

    weaponSelected: dropdownBoxState,
    weaponType: weapon.Models.Model,

    ammunitionSelected: dropdownBoxState,
    weaponCaliber: amm.Caliber,

    factor: i32,

    interceptingForest: bool,
    targetType: bool,

    f: textBoxState,
    Amin: textBoxState,
    Amax: textBoxState,
    Dmax: textBoxState,
    forestDist: textBoxState,

    v: f32,
    q1: f32,
    q2: f32,
    ch: f32 = 1000,

    c: f32,
    l: f32,
    h: f32,

    pub fn init(self: *riskState) !void {
        self.reset();

        try self.menu.init();
        self.showLines = true;
        self.valid = false;
    }

    pub fn reset(self: *riskState) void {
        self.Amin = .{ .editMode = false, .value = std.mem.zeroes([64]u8) };
        self.Amax = .{ .editMode = false, .value = std.mem.zeroes([64]u8) };
        self.f = .{ .editMode = false, .value = std.mem.zeroes([64]u8) };
        self.forestDist = .{ .editMode = false, .value = std.mem.zeroes([64]u8) };
        self.showLines = true;
        self.interceptingForest = false;
        self.factor = 0;
        self.weaponSelected = .{ .editMode = false, .value = 0 };
        self.ammunitionSelected = .{ .editMode = false, .value = 0 };
        self.targetType = false;
    }

    pub fn update(self: *riskState) !void {
        // if (!controlUpdate(self, state)) return;

        // self.updateValues(state);
        self.calculateMetrics();
        self.updateValues();

        self.valid = true;

        // self.validate() catch |err| {
        //     std.log.info("Validation failed: {any}", .{err});
        //     return;
        // };
    }

    // fn controlUpdate(self: *riskState, state: guiState) bool {
    //     return (!(self.factor == state.riskFactor.value and
    //         self.targetType == state.targetType.value and
    //         self.interceptingForest == state.interceptingForest.value and
    //         self.Amin == utils.combineAsciiToFloat(&state.Amin.value) and
    //         self.Amax == utils.combineAsciiToFloat(&state.Amax.value) and
    //         self.f == utils.combineAsciiToFloat(&state.f.value) and
    //         self.forestDist == utils.combineAsciiToFloat(&state.forestDist.value) and
    //         self.weaponType.id == weapon.getWeaponType(state.weaponType.value).caliber.id and
    //         self.weaponType.caliber.id == weapon.getAmmunitionType(state.ammunitionType.value).id and

    //         // std.mem.eql(u8, self.weaponCaliber.name, amm.getAmmunitionType(state.ammunitionType.value).name) and
    //         // std.mem.eql(u8, self.weaponType.caliber.name, weapon.getWeaponType(state.weaponType.value).caliber.name)));
    // }

    // fn updateValues(self: *riskState, state: guiState) void {
    //     self.setFactor(state.riskFactor.value);
    //     self.setAmin(&state.Amin.value);
    //     self.setAmax(&state.Amax.value);
    //     self.setF(&state.f.value);
    //     self.setInterceptingForest(state.interceptingForest.value);
    //     self.setForestDist(&state.forestDist.value);
    //     self.setFixedTarget(state.targetType.value);
    //     self.setWeaponType(state.weaponType.value);
    //     self.setWeaponCaliber(state.ammunitionType.value);
    // }

    fn updateValues(self: *riskState) void {
        self.setWeaponType();
        self.setWeaponCaliber();
        self.v = self.getV();
    }

    fn calculateMetrics(self: *riskState) void {
        self.l = calc.calculateL(self);
        self.h = calc.calculateH(self);
        self.c = calc.calculateC(self);
        self.q1 = calc.calculateQ1(self);
        self.q2 = calc.calculateQ2(self);
    }

    fn validate(self: *riskState) RiskValidationError!void {
        // Check for zero values in Amax or Amin
        if (self.getAmax() == 0 or self.getAmin() == 0) {
            return RiskValidationError.NoValue;
        }

        // Check for invalid range conditions
        if (self.getAmin() > self.getAmax() or self.getAmin() > self.getDmax() or self.getAmax() > self.getDmax()) {
            return RiskValidationError.InvalidRange;
        }

        // Check for negative values
        if (self.getDmax() < 0 or self.getAmax() < 0 or self.getAmin() < 0 or self.getF() < 0 or self.q1 < 0 or self.c < 0 or self.l < 0 or self.h < 0) {
            return RiskValidationError.NegativeValue;
        }

        // Check for integer overflow (example check - you can adjust based on your logic)
        if (self.getAmax() > std.math.floatMax(f32) or self.getAmin() > std.math.floatMax(f32) or self.getDmax() > std.math.floatMax(f32) or self.getF() > std.math.floatMax(f32)) {
            return RiskValidationError.IntegerOverflow;
        }

        // If all checks pass, set the valid flag
        self.valid = true;
    }

    pub fn getWeaponType(self: *riskState) weapon.Models.Model {
        return self.weaponType;
    }

    fn setWeaponType(self: *riskState) void {
        self.weaponType = weapon.getWeaponType(self.weaponSelected.value);
    }

    pub fn getWeaponCaliber(self: *riskState) amm.Caliber {
        return self.weaponCaliber;
    }

    fn setWeaponCaliber(self: *riskState) void {
        self.weaponCaliber = amm.getAmmunitionType(self.ammunitionSelected.value);
    }

    // pub fn getCh(self: *riskState) f32 {
    //     _ = self;
    //     return 1000;
    // }

    // pub fn getQ1(self: *riskState) f32 {
    //     return calc.calculateQ1(self);
    // }

    // pub fn getQ2(self: *riskState) f32 {
    //     return calc.calculateQ2(self);
    // }

    // pub fn getC(self: *riskState) f32 {
    //     return calc.calculateC(self);
    // }

    // pub fn getL(self: *riskState) f32 {
    //     return calc.calculateL(self);
    // }

    // pub fn getH(self: *riskState) f32 {
    //     return calc.calculateH(self);
    // }

    pub fn getDmax(self: *riskState) f32 {
        return self.weaponCaliber.Dmax;
    }

    pub fn getV(self: *riskState) f32 {
        return if (self.targetType) self.weaponType.v_still else self.weaponType.v_moveable;
    }

    pub fn getInterceptingForest(self: *riskState) bool {
        return self.interceptingForest;
    }

    // fn setInterceptingForest(self: *riskState, value: bool) bool {
    //     self.interceptingForest = value;
    // }

    pub fn getFixedTarget(self: *riskState) bool {
        return self.targetType;
    }

    // fn setFixedTarget(self: *riskState, value: bool) bool {
    //     self.targetType = value;
    // }

    pub fn getFactor(self: *riskState) i32 {
        return self.factor;
    }

    // fn setFactor(self: *riskState, value: i32) void {
    //     self.factor.value = value;
    // }

    pub fn getF(self: *riskState) f32 {
        return utils.combineAsciiToFloat(&self.f.value);
    }

    // fn setF(self: *riskState, value: []const u8) void {
    //     self.f.value = value;
    // }

    pub fn getAmin(self: *riskState) f32 {
        return utils.combineAsciiToFloat(&self.Amin.value);
    }

    // fn setAmin(self: *riskState, value: []const u8) void {
    //     self.Amin.value = value;
    // }

    pub fn getAmax(self: *riskState) f32 {
        return utils.combineAsciiToFloat(&self.Amax.value);
    }

    // fn setAmax(self: *riskState, value: []const u8) void {
    //     self.Amax.value = value;
    // }

    pub fn getForestDist(self: *riskState) f32 {
        return utils.combineAsciiToFloat(&self.forestDist.value);
    }

    // fn setForestDist(self: *riskState, value: []const u8) void {
    //     self.forestDist.value = value;
    // }
};
