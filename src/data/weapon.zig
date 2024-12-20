const std = @import("std");
const amm = @import("ammunition.zig");

pub const names: [*:0]const u8 = "AK5C;KSP58;KSP58_Benstod";

pub const Model = struct {
    Dmax: i32,
    v_still: f32,
    v_moveable: f32,
    c: f32,
    caliber: amm.Caliber,
    id: i8,

    pub const Invalid: Model = Model{ .Dmax = undefined, .v_still = undefined, .v_moveable = undefined, .c = undefined, .caliber = undefined, .id = -1 };
    pub const AK5: Model = Model{ .Dmax = 3000, .v_still = 100.0, .v_moveable = 100.0, .c = 200.0, .caliber = undefined, .id = 0 };
    pub const KSP58: Model = Model{ .Dmax = 4300, .v_still = 200.0, .v_moveable = 300.0, .c = 200.0, .caliber = undefined, .id = 1 };
    pub const KSP58_Benstod: Model = Model{ .Dmax = 4300, .v_still = 100.0, .v_moveable = 200.0, .c = 200.0, .caliber = undefined, .id = 2 };
};

pub fn getWeaponType(value: i32) Model {
    return switch (value) {
        0 => Model.AK5,
        1 => Model.KSP58,
        2 => Model.KSP58_Benstod,
        else => Model.Invalid,
    };
}
