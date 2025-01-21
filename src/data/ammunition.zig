// pub const CaliberType = union(enum) {
//     ptr556: Calibers.ptr556,
//     ptr65: Calibers.ptr65,
//     ptr762: Calibers.ptr762,
//     ptr9: Calibers.ptr9,
//     ptr127: Calibers.ptr127,
//     ptrOther: Calibers.ptrOther,
// };

pub const Calibers = enum {
    pub const ptr556 = enum {
        ptr556_sk_prj_slprj,
    };
    pub const ptr65 = enum {
        ptr65_sk_prj_m41,
    };
    pub const ptr762 = enum {
        ptr762_sk_10b_prj_slprj,
        ptr762_sk_10_pprj,
        ptr762_sk_prick_lh,
        ptr762_sk_prick,
        ptr762_sk_39_prj,
        ptr762_sk_95_prj_slprj,
    };
    pub const ptr9 = enum {
        ptr9_sk_39b,
        ptr9_9_39_ovnprj_11,
        ptr9_sk_67_slprj,
    };
    pub const ptr127 = enum {
        ptr127_sk_45_nprj_slnprj,
        ptr127_sk_nprj_prick_slprj_prick,
        ptr127_sk_45_pbrsprj_brsprj_slbrsprj,
    };
    pub const ptrOther = enum {
        hagelptr,
        long_rifle_22,
    };

    pub fn getCaliber(value: union(enum) {
        ptr556: Calibers.ptr556,
        ptr65: Calibers.ptr65,
        ptr762: Calibers.ptr762,
        ptr9: Calibers.ptr9,
        ptr127: Calibers.ptr127,
        ptrOther: Calibers.ptrOther,
    }) Caliber {
        return switch (value) {
            .ptr556 => switch (value.ptr556) {
                .ptr556_sk_prj_slprj => Caliber.ptr556_sk_prj_slprj,
            },
            .ptr65 => switch (value.ptr65) {
                .ptr65_sk_prj_m41 => Caliber.ptr65_sk_prj_m41,
            },
            .ptr762 => switch (value.ptr762) {
                .ptr762_sk_10b_prj_slprj => Caliber.ptr762_sk_10b_prj_slprj,
                .ptr762_sk_10_pprj => Caliber.ptr762_sk_10_pprj,
                .ptr762_sk_prick_lh => Caliber.ptr762_sk_prick_lh,
                .ptr762_sk_prick => Caliber.ptr762_sk_prick,
                .ptr762_sk_39_prj => Caliber.ptr762_sk_39_prj,
                .ptr762_sk_95_prj_slprj => Caliber.ptr762_sk_95_prj_slprj,
            },
            .ptr9 => switch (value.ptr9) {
                .ptr9_sk_39b => Caliber.ptr9_sk_39b,
                .ptr9_9_39_ovnprj_11 => Caliber.ptr9_9_39_ovnprj_11,
                .ptr9_sk_67_slprj => Caliber.ptr9_sk_67_slprj,
            },
            .ptr127 => switch (value.ptr127) {
                .ptr127_sk_45_nprj_slnprj => Caliber.ptr127_sk_45_nprj_slnprj,
                .ptr127_sk_nprj_prick_slprj_prick => Caliber.ptr127_sk_nprj_prick_slprj_prick,
                .ptr127_sk_45_pbrsprj_brsprj_slbrsprj => Caliber.ptr127_sk_45_pbrsprj_brsprj_slbrsprj,
            },
            .ptrOther => switch (value.ptrOther) {
                .hagelptr => Caliber.hagelptr,
                .long_rifle_22 => Caliber.long_rifle_22,
            },
        };
    }
};

pub const Caliber = struct {
    Dmax: f32,
    yMax: f32,
    c: f32,

    pub const invalid: Caliber = Caliber{ .Dmax = undefined, .yMax = undefined, .c = undefined };
    pub const hagelptr: Caliber = Caliber{ .Dmax = 350, .yMax = undefined, .c = 70 };
    pub const long_rifle_22: Caliber = Caliber{ .Dmax = 1500, .yMax = undefined, .c = 200 };
    pub const ptr556_sk_prj_slprj: Caliber = Caliber{ .Dmax = 3000, .yMax = 700, .c = 200 };
    pub const ptr65_sk_prj_m41: Caliber = Caliber{ .Dmax = 4500, .yMax = 1500, .c = 200 };
    pub const ptr762_sk_10b_prj_slprj: Caliber = Caliber{ .Dmax = 4300, .yMax = 1400, .c = 200 };
    pub const ptr762_sk_10_pprj: Caliber = Caliber{ .Dmax = 4300, .yMax = 1400, .c = 200 };
    pub const ptr762_sk_prick_lh: Caliber = Caliber{ .Dmax = 4300, .yMax = 1400, .c = 200 };
    pub const ptr762_sk_prick: Caliber = Caliber{ .Dmax = 4300, .yMax = 1400, .c = 200 };
    pub const ptr762_sk_39_prj: Caliber = Caliber{ .Dmax = 4000, .yMax = 1400, .c = 200 };
    pub const ptr762_sk_95_prj_slprj: Caliber = Caliber{ .Dmax = 4700, .yMax = 1400, .c = 200 };
    pub const ptr9_sk_39b: Caliber = Caliber{ .Dmax = 1800, .yMax = 500, .c = 150 };
    pub const ptr9_9_39_ovnprj_11: Caliber = Caliber{ .Dmax = 1800, .yMax = 500, .c = 150 };
    pub const ptr9_sk_67_slprj: Caliber = Caliber{ .Dmax = 1600, .yMax = 500, .c = 150 };
    pub const ptr127_sk_45_nprj_slnprj: Caliber = Caliber{ .Dmax = 7000, .yMax = 2000, .c = 400 };
    pub const ptr127_sk_nprj_prick_slprj_prick: Caliber = Caliber{ .Dmax = 7000, .yMax = 2000, .c = 400 };
    pub const ptr127_sk_45_pbrsprj_brsprj_slbrsprj: Caliber = Caliber{ .Dmax = 7000, .yMax = 2000, .c = 400 };
};
