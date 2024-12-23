const weapon = @import("weapon.zig");
const ammunition = @import("ammunition.zig");
const math = @import("../math/risk.zig");
const std = @import("std");
const validation = @import("validation.zig");

pub const riskProfile = struct {
    const factor = enum {
        I,
        II,
        III,
    };
    const targetType = enum {
        Fast,
        Flyttbart,
    };

    terrainValues: terrainValues2,
    weaponValues: weaponValues2,

    show: bool = true,
    ch: f32 = 1000,
    q1: f32 = 0,
    q2: f32 = 0,
    c: f32 = 0,

    const terrainValues2 = struct {
        interceptingForest: bool = false,
        factor_enum_value: factor = .I,
        Amin: f32 = 100,
        Amax: f32 = 200,
        f: f32 = 50,
        forestDist: f32 = 100,
        l: f32 = 0,
        h: f32 = 0,
    };

    const weaponValues2 = struct {
        weapon_enum_value: weapon.Models = .AK5,
        amm_enum_values: ammunition.Calibers = .hagelptr,
        target_enum_value: targetType = .Fast,
        model: weapon.Model = .EHV, //weapon.Model.EHV,
        caliber: ammunition.Caliber = .hagelptr, //ammunition.Caliber.ptr556_sk_prj_slpr
        v: f32 = 0,
    };

    pub fn init() riskProfile {
        return riskProfile{
            .terrainValues = terrainValues2{},
            .weaponValues = weaponValues2{},
        };
    }

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
        return validation.validate(self);
    }
};
