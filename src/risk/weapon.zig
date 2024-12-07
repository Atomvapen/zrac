const amm = @import("ammunition.zig");

pub const Weapons = struct {
    pub const Model = struct {
        Dmax: i32,
        v_still: f32,
        v_moveable: f32,
        c: f32,
        caliber: amm.Caliber,
    };

    pub const names: [*:0]const u8 = "AK5C;KSP58;KSP58_Benstod";

    pub var invalid: Model = Model{
        .Dmax = 0,
        .v_still = 0.0,
        .v_moveable = 0.0,
        .c = 0.0,
        .caliber = undefined,
    };

    pub var AK5: Model = Model{
        .Dmax = 3000,
        .v_still = 100.0,
        .v_moveable = 100.0,
        .c = 200.0,
        .caliber = undefined,
    };

    pub var KSP58: Model = Model{
        .Dmax = 4300,
        .v_still = 200.0,
        .v_moveable = 300.0,
        .c = 200.0,
        .caliber = undefined,
    };

    pub var KSP58_Benstod: Model = Model{
        .Dmax = 4300,
        .v_still = 100.0,
        .v_moveable = 200.0,
        .c = 200.0,
        .caliber = undefined,
    };
};
