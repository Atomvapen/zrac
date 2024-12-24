pub const Models = enum {
    AK5,
    KSP58,
    KSP88,
    KSP90,
};

pub const Model = struct {
    v_still: f32,
    v_moveable: f32,
    id: i8,

    pub const Invalid: Model = Model{ .v_still = undefined, .v_moveable = undefined, .id = -1 };
    pub const EHV: Model = Model{ .v_still = 100.0, .v_moveable = 100.0, .id = 0 };
    pub const AG90: Model = Model{ .v_still = 100.0, .v_moveable = 100.0, .id = 6 };
    pub const KSP58: Model = Model{ .v_still = 200.0, .v_moveable = 300.0, .id = 1 };
    pub const KSP58MBS: Model = Model{ .v_still = 100.0, .v_moveable = 200.0, .id = 1 };
    pub const KSP58MMLVS: Model = Model{ .v_still = 100.0, .v_moveable = 200.0, .id = 3 };
    pub const KSP90: Model = Model{ .v_still = 100.0, .v_moveable = 200.0, .id = 4 };
    pub const KSP90MBS: Model = Model{ .v_still = 100.0, .v_moveable = 200.0, .id = 4 };
    pub const KSP88MMS: Model = Model{ .v_still = 200.0, .v_moveable = 300.0, .id = 5 };
    pub const KSP88MBS: Model = Model{ .v_still = 100.0, .v_moveable = 200.0, .id = 5 };
};

pub fn getWeaponType(value: Models) Model {
    return switch (value) {
        .AK5 => Model.EHV,
        .KSP58 => Model.KSP58,
        .KSP88 => Model.KSP88MMS,
        .KSP90 => Model.KSP90,
    };
}
