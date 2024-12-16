const amm = @import("ammunition.zig");

pub fn getWeaponType(value: i32) Weapons.Model {
    return switch (value) {
        0 => Weapons.AK5,
        1 => Weapons.KSP58,
        2 => Weapons.KSP58_Benstod,
        else => Weapons.invalid,
    };
}

pub const names: [*:0]const u8 = "AK5C;KSP58;KSP58_Benstod";

pub const Weapons = struct {
    pub const Model = struct {
        Dmax: i32,
        v_still: f32,
        v_moveable: f32,
        c: f32,
        caliber: amm.Caliber,
        name: [*:0]const u8,
        id: i8,
    };

    pub var invalid: Model = Model{
        .Dmax = 0,
        .v_still = 0.0,
        .v_moveable = 0.0,
        .c = 0.0,
        .caliber = undefined,
        .name = "",
        .id = -1,
    };

    pub var AK5: Model = Model{
        .Dmax = 3000,
        .v_still = 100.0,
        .v_moveable = 100.0,
        .c = 200.0,
        .caliber = undefined,
        .name = "AK5C",
        .id = 0,
    };

    pub var KSP58: Model = Model{
        .Dmax = 4300,
        .v_still = 200.0,
        .v_moveable = 300.0,
        .c = 200.0,
        .caliber = undefined,
        .name = "KSP58",
        .id = 1,
    };

    pub var KSP58_Benstod: Model = Model{
        .Dmax = 4300,
        .v_still = 100.0,
        .v_moveable = 200.0,
        .c = 200.0,
        .caliber = undefined,
        .name = "KSP58_Benstod",
        .id = 2,
    };
};
