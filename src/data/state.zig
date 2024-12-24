const std = @import("std");

const weapon = @import("weapon.zig");
const ammunition = @import("ammunition.zig");

const math = @import("../math/risk.zig");
const validation = @import("validation.zig");

pub const RiskProfile = struct {
    const Factor = enum {
        I,
        II,
        III,
    };
    const Target = enum {
        Fast,
        Flyttbart,
    };
    const Config = struct {
        show: bool = true,
    };
    const TerrainValues = struct {
        interceptingForest: bool = false,
        factor: Factor = .I,
        Amin: f32 = 100,
        Amax: f32 = 200,
        f: f32 = 50,
        forestDist: f32 = 100,
        l: f32 = 0,
        h: f32 = 0,
    };
    const WeaponValues = struct {
        weapon_enum_value: weapon.Models = .AK5,
        amm_enum_values: ammunition.Calibers.ptr556 = .hagelptr,
        target: Target = .Fast,
        model: weapon.Model = .EHV,
        caliber: ammunition.Caliber = .hagelptr,
        v: f32 = 0,
    };

    terrainValues: TerrainValues,
    weaponValues: WeaponValues,
    config: Config,

    amm556: ammunition.Calibers.ptr556 = .hagelptr,
    ammK762: ammunition.Calibers.ptr762 = .ptr762_sk_10_pprj,
    amm9: ammunition.Calibers.ptr9 = .ptr9_9_39_ovnprj_11,
    amm127: ammunition.Calibers.ptr127 = .ptr127_sk_45_nprj_slnprj,

    ch: f32 = 1000,
    q1: f32 = 0,
    q2: f32 = 0,
    c: f32 = 0,

    pub fn init() RiskProfile {
        return RiskProfile{
            .terrainValues = TerrainValues{},
            .weaponValues = WeaponValues{},
            .config = Config{},
        };
    }

    pub fn validate(self: *RiskProfile) bool {
        return validation.validate(self);
    }

    pub fn update(self: *RiskProfile) void {
        self.terrainValues.l = math.calculateL(self);
        self.terrainValues.h = math.calculateH(self);
        self.q1 = math.calculateQ1(self);
        self.q2 = math.calculateQ2(self);
        self.c = math.calculateC(self);
        self.weaponValues.model = weapon.getWeaponType(self.weaponValues.weapon_enum_value);

        //TODO fixa så att caliber går efter den enum som är aktiv genom switch (guiState.weaponValues.weapon_enum_value) {
        self.weaponValues.caliber = ammunition.getAmmunitionType(self.weaponValues.amm_enum_values);

        self.weaponValues.v = if (self.weaponValues.target == .Fast) self.weaponValues.model.v_still else self.weaponValues.model.v_moveable;
    }
};
