const weapon = @import("weapon.zig");
const ammunition = @import("ammunition.zig");
// const state = @import("../gui/renderer.zig").guiState;
const math = @import("../math/risk.zig");
const std = @import("std");

pub const riskProfile = struct {
    terrainValues: terrainValues2,
    weaponValues: weaponValues2,

    show: bool = true,
    ch: f32 = 1000,
    q1: f32 = 0,
    q2: f32 = 0,
    c: f32 = 0,

    pub fn init() riskProfile {
        return riskProfile{
            .terrainValues = terrainValues2{},
            .weaponValues = weaponValues2{},
        };
    }

    const factor = enum {
        I,
        II,
        III,
    };

    const targetType = enum {
        Fast,
        Flyttbart,
    };

    pub const terrainValues2 = struct {
        interceptingForest: bool = false,
        factor_enum_value: factor = .I,
        Amin: f32 = 100,
        Amax: f32 = 200,
        f: f32 = 50,
        forestDist: f32 = 100,
        l: f32 = 0,
        h: f32 = 0,
    };

    pub const weaponValues2 = struct {
        weapon_enum_value: weapon.Models = .AK5,
        amm_enum_values: ammunition.Calibers = .hagelptr,
        target_enum_value: targetType = .Fast,
        model: weapon.Model = .EHV, //weapon.Model.EHV,
        caliber: ammunition.Caliber = .hagelptr, //ammunition.Caliber.ptr556_sk_prj_slpr
        v: f32 = 0,
        // stead: bool = false,
    };

    pub fn update(self: *riskProfile) void {
        self.terrainValues.l = math.calculateL(self);
        self.terrainValues.h = math.calculateH(self);
        self.q1 = math.calculateQ1(self);
        self.q2 = math.calculateQ2(self);
        self.c = math.calculateC(self);
        self.weaponValues.model = weapon.getWeaponType(self.weaponValues.weapon_enum_value);
        self.weaponValues.caliber = ammunition.getAmmunitionType(self.weaponValues.amm_enum_values);
        self.weaponValues.v = if (self.weaponValues.target_enum_value == .Fast) self.weaponValues.model.v_still else self.weaponValues.model.v_moveable;
    }

    pub fn validate(self: *riskProfile) bool {
        //
        if (!self.show) {
            return false;
        }

        // Check for zero values in Amax
        if (self.terrainValues.Amax == 0) {
            return false;
        }

        // Check for invalid range conditions
        if (self.terrainValues.Amin > self.terrainValues.Amax or self.terrainValues.f > self.terrainValues.Amax or self.terrainValues.f > self.terrainValues.Amin) {
            return false;
        }
        if (self.terrainValues.forestDist > self.terrainValues.Amax) {
            return false;
        }

        // Check for negative values
        if (self.terrainValues.Amax < 0 or self.terrainValues.Amin < 0 or self.terrainValues.f < 0 or self.terrainValues.l < 0 or self.terrainValues.h < 0) {
            return false;
        }
        if (self.terrainValues.forestDist < 0) {
            return false;
        }
        //     if (self.getDmax() < 0 or self.getAmax() < 0 or self.getAmin() < 0 or self.getF() < 0 or self.q1 < 0 or self.c < 0 or self.l < 0 or self.h < 0) {
        //         return Rfalse;
        //     }

        // Check for integer overflow (example check - you can adjust based on your logic)
        if (self.terrainValues.Amax > std.math.floatMax(f32) or self.terrainValues.Amin > std.math.floatMax(f32) or self.terrainValues.f > std.math.floatMax(f32)) {
            return false;
        }
        if (self.terrainValues.forestDist > std.math.floatMax(f32)) {
            return false;
        }

        //     if (self.getAmax() > std.math.floatMax(f32) or self.getAmin() > std.math.floatMax(f32) or self.getDmax() > std.math.floatMax(f32) or self.getF() > std.math.floatMax(f32)) {
        //         return false;
        //     }

        // If all checks pass, set the valid flag
        return true;
    }
};
