const std = @import("std");

pub const names: [*:0]const u8 = "AK5C;KSP58;KSP58_Benstod";

pub const Model = struct {
    v_still: f32,
    v_moveable: f32,
    id: i8,

    pub const Invalid: Model = Model{ .v_still = undefined, .v_moveable = undefined, .id = -1 };
    pub const EHV: Model = Model{ .v_still = 100.0, .v_moveable = 100.0, .id = 0 };
    pub const AG90: Model = Model{ .v_still = 100.0, .v_moveable = 100.0, .id = 6 };
    pub const KSPMBS: Model = Model{ .v_still = 100.0, .v_moveable = 200.0, .id = 2 };
    pub const KSP58: Model = Model{ .v_still = 200.0, .v_moveable = 300.0, .id = 1 };
    pub const KSP58MMLVS: Model = Model{ .v_still = 100.0, .v_moveable = 200.0, .id = 3 };
    pub const KSP90: Model = Model{ .v_still = 100.0, .v_moveable = 200.0, .id = 4 };
    pub const KSP88MMS: Model = Model{ .v_still = 200.0, .v_moveable = 300.0, .id = 5 };
};

pub fn getWeaponType(value: i32) Model {
    return switch (value) {
        0 => Model.EHV,
        1 => Model.KSP58,
        2 => Model.KSPMBS,
        else => Model.Invalid,
    };
}
