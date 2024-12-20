pub const weapon = @import("weapon.zig").Model;

pub const names: [*:0]const u8 = "Hagelptr; 22 long rifle;5,56 mm sk ptr 5/5B prj/slprj;6,5 mm sk ptr prj m/41;7,62 mm sk ptr 10(B) prj/slprj;7,62 mm sk ptr 10 PPRJ;7,62 mm sk ptr PRICK LH;7,62 mm sk ptr PRICK;7,62 mm sk ptr 39 prj;7,62 mm sk ptr 95 prj/slprj;9 mm sk ptr m/39B;9 mm 9/39 övnprj 11;9 mm sk ptr m/67 slprj;12,7 mm sk ptr m/45 nprj och slnprj;12,7 mm sk ptr nprj prick och slprj prick;12,7 mm sk ptr m/45 pbrsprj, brsprj och slbrsprj";

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

pub fn getValidNames(model: weapon) [*:0]const u8 {
    return switch (model.id) {
        0 => "5,56 mm sk ptr 5/5B prj/slprj",
        1, 2 => "7,62 mm sk ptr 10(B) prj/slprj;7,62 mm sk ptr 10 PPRJ;7,62 mm sk ptr PRICK LH;7,62 mm sk ptr PRICK;7,62 mm sk ptr 39 prj;7,62 mm sk ptr 95 prj/slprj",
        else => "",
    };
}

pub fn getAmmunitionType(value: i32) Caliber {
    return switch (value) {
        0 => Caliber.hagelptr,
        1 => Caliber.long_rifle_22,
        2 => Caliber.ptr556_sk_prj_slprj,
        3 => Caliber.ptr65_sk_prj_m41,
        4 => Caliber.ptr762_sk_10b_prj_slprj,
        5 => Caliber.ptr762_sk_10_pprj,
        6 => Caliber.ptr762_sk_prick_lh,
        7 => Caliber.ptr762_sk_prick,
        8 => Caliber.ptr762_sk_39_prj,
        9 => Caliber.ptr762_sk_95_prj_slprj,
        10 => Caliber.ptr9_sk_39b,
        11 => Caliber.ptr9_9_39_ovnprj_11,
        12 => Caliber.ptr9_sk_67_slprj,
        13 => Caliber.ptr127_sk_45_nprj_slnprj,
        14 => Caliber.ptr27_sk_nprj_prick_slprj_prick,
        15 => Caliber.ptr127_sk_45_pbrsprj_brsprj_slbrsprj,
        else => unreachable,
    };
}
