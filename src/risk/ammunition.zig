pub const Caliber = struct {
    Dmax: i32,
    y: i32,
    c: f32,
    name: []const u8,

    pub var hagelptr: Caliber = Caliber{
        .Dmax = 350,
        .y = undefined,
        .c = 70,
        .name = "Hagelptr",
    };

    pub var long_rifle_22: Caliber = Caliber{
        .Dmax = 1500,
        .y = undefined,
        .c = 200,
        .name = "22 long rifle",
    };

    pub var ptr556_sk_prj_slprj: Caliber = Caliber{
        .Dmax = 3000,
        .y = undefined,
        .c = 200,
        .name = "5,56 mm sk ptr 5/5B prj/slprj",
    };

    pub var ptr65_sk_prj_m41: Caliber = Caliber{
        .Dmax = 4500,
        .y = undefined,
        .c = 200,
        .name = "6,5 mm sk ptr m/41",
    };

    pub var ptr762_sk_10b_prj_slprj: Caliber = Caliber{
        .Dmax = 4300,
        .y = undefined,
        .c = 200,
        .name = "7,62 mm sk ptr 10(B) prj/slprj",
    };

    pub var ptr762_sk_10_pprj: Caliber = Caliber{
        .Dmax = 4300,
        .y = undefined,
        .c = 200,
        .name = "7,62 mm sk ptr 10 PPRJ",
    };

    pub var ptr762_sk_prick_lh: Caliber = Caliber{
        .Dmax = 4300,
        .y = undefined,
        .c = 200,
        .name = "7,62 mm sk ptr PRICK LH",
    };

    pub var ptr762_sk_prick: Caliber = Caliber{
        .Dmax = 4300,
        .y = undefined,
        .c = 200,
        .name = "7,62 mm sk ptr PRICK",
    };

    pub var ptr762_sk_39_prj: Caliber = Caliber{
        .Dmax = 4000,
        .y = undefined,
        .c = 200,
        .name = "7,62 mm sk ptr 39 prj",
    };

    pub var ptr762_sk_95_prj_slprj: Caliber = Caliber{
        .Dmax = 4700,
        .y = undefined,
        .c = 200,
        .name = "7,62 mm sk ptr 95 prj/slprj",
    };

    pub var ptr9_sk_39b: Caliber = Caliber{
        .Dmax = 1800,
        .y = undefined,
        .c = 150,
        .name = "9 mm sk ptr m/39B",
    };

    pub var ptr9_9_39_ovnprj_11: Caliber = Caliber{
        .Dmax = 1800,
        .y = undefined,
        .c = 150,
        .name = "9 mm 9/39 övnprj 11",
    };

    pub var ptr9_sk_67_slprj: Caliber = Caliber{
        .Dmax = 1600,
        .y = undefined,
        .c = 150,
        .name = "9 mm sk ptr m/67 slprj",
    };

    pub var ptr127_sk_45_nprj_slnprj: Caliber = Caliber{
        .Dmax = 7000,
        .y = undefined,
        .c = 400,
        .name = "12,7 mm sk ptr m/45 nprj och slnprj",
    };

    pub var ptr27_sk_nprj_prick_slprj_prick: Caliber = Caliber{
        .Dmax = 7000,
        .y = undefined,
        .c = 400,
        .name = "2,7 mm sk ptr nprj prick och slprj prick",
    };

    pub var ptr127_sk_45_pbrsprj_brsprj_slbrsprj: Caliber = Caliber{
        .Dmax = 7000,
        .y = undefined,
        .c = 400,
        .name = "12,7 mm sk ptr m/45 pbrsprj, brsprj och slbrsprj",
    };
};

pub const names: [*:0]const u8 = "Hagelptr; 22 long rifle;5,56 mm sk ptr 5/5B prj/slprj;6,5 mm sk ptr prj m/41;7,62 mm sk ptr 10(B) prj/slprj;7,62 mm sk ptr 10 PPRJ;7,62 mm sk ptr PRICK LH;7,62 mm sk ptr PRICK;7,62 mm sk ptr 39 prj;7,62 mm sk ptr 95 prj/slprj;9 mm sk ptr m/39B;9 mm 9/39 övnprj 11;9 mm sk ptr m/67 slprj;12,7 mm sk ptr m/45 nprj och slnprj;12,7 mm sk ptr nprj prick och slprj prick;12,7 mm sk ptr m/45 pbrsprj, brsprj och slbrsprj";
