const weapon = @import("weapon.zig");
const ammunition = @import("ammunition.zig");
const state = @import("../gui/renderer.zig").guiState;

const factor = enum {
    I,
    II,
    III,
};

const targetType = enum {
    Fast,
    Flyttbart,
};

pub const show = struct {
    pub var showLines: bool = true;
};

pub const terrainValues = struct {
    pub var interceptingForest: bool = false;
    pub var factor_enum_value: factor = .I;
    pub var Amin: f32 = 0;
    pub var Amax: f32 = 0;
    pub var f: f32 = 0;
    pub var forestDist: f32 = 0;
    pub var l: f32 = 0;
    pub var h: f32 = 0;
};

pub const weaponValues = struct {
    pub var weapon_enum_value: weapon.Models = .AK5;
    pub var amm_enum_values: ammunition.Calibers = .hagelptr;
    pub var target_enum_value: targetType = .Fast;
    pub var model: weapon.Model = model.Invalid;
    pub var caliber: ammunition.Calaiber = caliber.invalid;
};

const math = @import("../math/risk.zig");

// pub fn update() void {
//     terrainValues.l = math.calculateL(terrainValues);
//     terrainValues.h = math.calculateH(terrainValues.Amax, terrainValues.l);
// }
