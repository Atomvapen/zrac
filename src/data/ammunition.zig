// pub const weapon = @import("weapon.zig").Model;
// pub const Models = @import("weapon.zig").Models;

// pub fn getEnum(model: Models) type {
//     return switch (model) {
//         Models.AK5 => ehvCalibers,
//         else => ksp58Calibers,
//     };
// }

// pub const ksp58Calibers = enum {
//     ptr762_sk_10b_prj_slprj,
//     ptr762_sk_10_pprj,
//     ptr762_sk_prick_lh,
//     ptr762_sk_prick,
//     ptr762_sk_39_prj,
//     ptr762_sk_95_prj_slprj,
// };

// pub const ehvCalibers = enum {
//     ptr556_sk_prj_slprj,
//     ptr65_sk_prj_m41,
// };

pub const Calibers = enum {
    hagelptr,
    long_rifle_22,
    ptr556_sk_prj_slprj,
    ptr65_sk_prj_m41,
    ptr762_sk_10b_prj_slprj,
    ptr762_sk_10_pprj,
    ptr762_sk_prick_lh,
    ptr762_sk_prick,
    ptr762_sk_39_prj,
    ptr762_sk_95_prj_slprj,
    ptr9_sk_39b,
    ptr9_9_39_ovnprj_11,
    ptr9_sk_67_slprj,
    ptr127_sk_45_nprj_slnprj,
    ptr27_sk_nprj_prick_slprj_prick,
    ptr127_sk_45_pbrsprj_brsprj_slbrsprj,
};

pub const Caliber = struct {
    Dmax: f32,
    y: f32,
    c: f32,
    id: i32,

    pub const invalid: Caliber = Caliber{ .Dmax = undefined, .y = undefined, .c = undefined, .id = -1 };
    pub const hagelptr: Caliber = Caliber{ .Dmax = 350, .y = undefined, .c = 70, .id = 0 };
    pub const long_rifle_22: Caliber = Caliber{ .Dmax = 1500, .y = undefined, .c = 200, .id = 1 };
    pub const ptr556_sk_prj_slprj: Caliber = Caliber{ .Dmax = 3000, .y = undefined, .c = 200, .id = 2 };
    pub const ptr65_sk_prj_m41: Caliber = Caliber{ .Dmax = 4500, .y = undefined, .c = 200, .id = 3 };
    pub const ptr762_sk_10b_prj_slprj: Caliber = Caliber{ .Dmax = 4300, .y = undefined, .c = 200, .id = 4 };
    pub const ptr762_sk_10_pprj: Caliber = Caliber{ .Dmax = 4300, .y = undefined, .c = 200, .id = 5 };
    pub const ptr762_sk_prick_lh: Caliber = Caliber{ .Dmax = 4300, .y = undefined, .c = 200, .id = 6 };
    pub const ptr762_sk_prick: Caliber = Caliber{ .Dmax = 4300, .y = undefined, .c = 200, .id = 7 };
    pub const ptr762_sk_39_prj: Caliber = Caliber{ .Dmax = 4000, .y = undefined, .c = 200, .id = 8 };
    pub const ptr762_sk_95_prj_slprj: Caliber = Caliber{ .Dmax = 4700, .y = undefined, .c = 200, .id = 9 };
    pub const ptr9_sk_39b: Caliber = Caliber{ .Dmax = 1800, .y = undefined, .c = 150, .id = 10 };
    pub const ptr9_9_39_ovnprj_11: Caliber = Caliber{ .Dmax = 1800, .y = undefined, .c = 150, .id = 11 };
    pub const ptr9_sk_67_slprj: Caliber = Caliber{ .Dmax = 1600, .y = undefined, .c = 150, .id = 12 };
    pub const ptr127_sk_45_nprj_slnprj: Caliber = Caliber{ .Dmax = 7000, .y = undefined, .c = 400, .id = 13 };
    pub const ptr27_sk_nprj_prick_slprj_prick: Caliber = Caliber{ .Dmax = 7000, .y = undefined, .c = 400, .id = 14 };
    pub const ptr127_sk_45_pbrsprj_brsprj_slbrsprj: Caliber = Caliber{ .Dmax = 7000, .y = undefined, .c = 400, .id = 15 };
};

pub fn getAmmunitionType(value: Calibers) Caliber {
    return switch (value) {
        .hagelptr => Caliber.hagelptr,
        .long_rifle_22 => Caliber.long_rifle_22,
        .ptr556_sk_prj_slprj => Caliber.ptr556_sk_prj_slprj,
        .ptr65_sk_prj_m41 => Caliber.ptr65_sk_prj_m41,
        .ptr762_sk_10b_prj_slprj => Caliber.ptr762_sk_10b_prj_slprj,
        .ptr762_sk_10_pprj => Caliber.ptr762_sk_10_pprj,
        .ptr762_sk_prick_lh => Caliber.ptr762_sk_prick_lh,
        .ptr762_sk_prick => Caliber.ptr762_sk_prick,
        .ptr762_sk_39_prj => Caliber.ptr762_sk_39_prj,
        .ptr762_sk_95_prj_slprj => Caliber.ptr762_sk_95_prj_slprj,
        .ptr9_sk_39b => Caliber.ptr9_sk_39b,
        .ptr9_9_39_ovnprj_11 => Caliber.ptr9_9_39_ovnprj_11,
        .ptr9_sk_67_slprj => Caliber.ptr9_sk_67_slprj,
        .ptr127_sk_45_nprj_slnprj => Caliber.ptr127_sk_45_nprj_slnprj,
        .ptr27_sk_nprj_prick_slprj_prick => Caliber.ptr27_sk_nprj_prick_slprj_prick,
        .ptr127_sk_45_pbrsprj_brsprj_slbrsprj => Caliber.ptr127_sk_45_pbrsprj_brsprj_slbrsprj,
    };
}
