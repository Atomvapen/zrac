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
        valid: bool = false,
    };
    const TerrainValues = struct {
        interceptingForest: bool = false,
        factor: Factor = .I,
        Amin: f32 = 100,
        Amax: f32 = 200,
        f: f32 = 50,
        forestDist: f32 = 300,
        l: f32 = 0,
        h: f32 = 0,
        q1: f32 = 0,
        q2: f32 = 0,
        ch: f32 = 1000,
    };
    const WeaponValues = struct {
        weapon_enum_value: weapon.Models = .P88,
        target: Target = .Fast,
        model: weapon.Model = .EHV,
        caliber: ammunition.Caliber = .ptr9_sk_39b,
        v: f32 = 0,
        amm556: ammunition.Calibers.ptr556 = .ptr556_sk_prj_slprj,
        amm762: ammunition.Calibers.ptr762 = .ptr762_sk_10_pprj,
        amm9: ammunition.Calibers.ptr9 = .ptr9_sk_39b,
        amm127: ammunition.Calibers.ptr127 = .ptr127_sk_45_nprj_slnprj,
        support: bool = false,
        c: f32 = 0,
    };

    terrainValues: TerrainValues,
    weaponValues: WeaponValues,
    config: Config,

    pub fn init() RiskProfile {
        return RiskProfile{
            .terrainValues = TerrainValues{},
            .weaponValues = WeaponValues{},
            .config = Config{},
        };
    }

    pub fn getHasSupport(self: *RiskProfile) bool {
        return weapon.getWeaponModel(self.weaponValues.weapon_enum_value, false).supportable;
    }

    pub fn reset(self: *RiskProfile) void {
        self.terrainValues = TerrainValues{};
        self.weaponValues = WeaponValues{};
        self.config = Config{};
    }

    pub fn update(self: *RiskProfile) void {
        self.terrainValues.l = math.calculateL(self);
        self.terrainValues.h = math.calculateH(self);
        self.terrainValues.q1 = math.calculateQ1(self);
        self.terrainValues.q2 = math.calculateQ2(self);
        self.weaponValues.c = math.calculateC(self);
        self.weaponValues.model = weapon.getWeaponModel(self.weaponValues.weapon_enum_value, self.weaponValues.support);
        self.weaponValues.v = if (self.weaponValues.target == .Fast) self.weaponValues.model.v_still else self.weaponValues.model.v_moveable;

        //TODO fixa alla vapen
        switch (self.weaponValues.weapon_enum_value) {
            .AK5, .KSP90 => self.weaponValues.caliber = ammunition.getCaliber(self.weaponValues.amm556),
            .KSP58 => self.weaponValues.caliber = ammunition.getCaliber(self.weaponValues.amm762),
            .KSP88, .AG90 => self.weaponValues.caliber = ammunition.getCaliber(self.weaponValues.amm127),
            .P88 => self.weaponValues.caliber = ammunition.getCaliber(self.weaponValues.amm9),
        }

        self.config.valid = validation.validate(self);
    }
};
