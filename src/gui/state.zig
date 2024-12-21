const weapon = @import("../data/weapon.zig");
const ammunition = @import("../data/ammunition.zig");

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
};

pub const weaponValues = struct {
   pub var weapon_enum_value: weapon.Models = .AK5;
   pub var amm_enum_values: ammunition.Calibers = .hagelptr;
   pub var target_enum_value: targetType = .Fast;
};
