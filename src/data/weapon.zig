pub const Models = enum {
    P88,
    AK5,
    AG90,
    KSP58,
    KSP88,
    KSP90,

    pub fn getModel(self: Models, support: bool) Model {
        return switch (self) {
            .AK5, .AG90, .P88 => Model.EHV,
            .KSP58 => if (support) Model.KSP58MBS else Model.KSP58,
            .KSP88 => Model.KSP88MMS,
            .KSP90 => if (support) Model.KSP90MBS else Model.KSP90,
        };
    }
};

pub const Model = struct {
    v_still: f32,
    v_moveable: f32,
    id: i8, //TODO remove, unused
    supportable: bool = false,

    pub const EHV: Model = Model{ .v_still = 100.0, .v_moveable = 100.0, .id = 0 };
    pub const KSP58: Model = Model{ .v_still = 200.0, .v_moveable = 300.0, .id = 2, .supportable = true };
    pub const KSP58MBS: Model = Model{ .v_still = 100.0, .v_moveable = 200.0, .id = 3, .supportable = true };
    pub const KSP58MMLVS: Model = Model{ .v_still = 100.0, .v_moveable = 200.0, .id = 4 };
    pub const KSP90: Model = Model{ .v_still = 100.0, .v_moveable = 200.0, .id = 5, .supportable = true };
    pub const KSP90MBS: Model = Model{ .v_still = 100.0, .v_moveable = 200.0, .id = 6, .supportable = true };
    pub const KSP88MMS: Model = Model{ .v_still = 200.0, .v_moveable = 300.0, .id = 7 };
    pub const KSP88MBS: Model = Model{ .v_still = 100.0, .v_moveable = 200.0, .id = 8 };
};
