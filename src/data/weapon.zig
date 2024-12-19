const amm = @import("ammunition.zig");

pub const Model2 = struct {
    Dmax: i32,
    v_still: f32,
    v_moveable: f32,
    c: f32,
    caliber: amm.Caliber,
    id: i8,
};

pub const ModelEnums = enum(Model2) {
    Invalid = Model2{ .Dmax = undefined, .v_still = undefined, .v_moveable = undefined, .c = undefined, .caliber = undefined, .id = -1 },
    AK5C = Model2{ .Dmax = 3000, .v_still = 100.0, .v_moveable = 100.0, .c = 200.0, .caliber = undefined, .id = 0 },
    KSP58 = Model2{ .Dmax = 4300, .v_still = 200.0, .v_moveable = 300.0, .c = 200.0, .caliber = undefined, .id = 1 },
    KSP58MB = Model2{ .Dmax = 4300, .v_still = 100.0, .v_moveable = 200.0, .c = 200.0, .caliber = undefined, .id = 2 },
};

pub fn getWeaponType(value: i32) Models.Model {
    return switch (value) {
        0 => Models.AK5,
        1 => Models.KSP58,
        2 => Models.KSP58_Benstod,
        else => Models.Invalid,
    };
}

pub const names: [*:0]const u8 = "AK5C;KSP58;KSP58_Benstod";

pub const Models = struct {
    pub const Model = struct {
        Dmax: i32,
        v_still: f32,
        v_moveable: f32,
        c: f32,
        caliber: amm.Caliber,
        id: i8,
    };

    pub var Invalid: Model = Model{
        .Dmax = 0,
        .v_still = 0.0,
        .v_moveable = 0.0,
        .c = 0.0,
        .caliber = undefined,
        .id = -1,
    };

    pub var AK5: Model = Model{
        .Dmax = 3000,
        .v_still = 100.0,
        .v_moveable = 100.0,
        .c = 200.0,
        .caliber = undefined,
        .id = 0,
    };

    pub var KSP58: Model = Model{
        .Dmax = 4300,
        .v_still = 200.0,
        .v_moveable = 300.0,
        .c = 200.0,
        .caliber = undefined,
        .id = 1,
    };

    pub var KSP58_Benstod: Model = Model{
        .Dmax = 4300,
        .v_still = 100.0,
        .v_moveable = 200.0,
        .c = 200.0,
        .caliber = undefined,
        .id = 2,
    };
};
