pub const Weapon = struct {
    Dmax: i32,
    v_still: i32,
    v_moveable: i32,
    c: i32,
};

pub const AmmunitionType = struct {
    pub const allNames: [*:0]const u8 =
        \\Hagelptr;
        \\22 long rifle;
        \\5,56 mm sk ptr 5/5B prj/slprj;
        \\6,5 mm sk ptr prj m/41;
        \\7,62 mm sk ptr 10(B) prj/slprj;
        \\7,62 mm sk ptr 10 PPRJ;
        \\7,62 mm sk ptr PRICK LH;
        \\7,62 mm sk ptr PRICK;
        \\7,62 mm sk ptr 39 prj;
        \\7,62 mm sk ptr 95 prj/slprj;
        \\9 mm sk ptr m/39B;
        \\9 mm 9/39 övnprj 11;
        \\9 mm sk ptr m/67 slprj;
        \\12,7 mm sk ptr m/45 nprj och slnprj;
        \\2,7 mm sk ptr nprj prick och slprj prick;
        \\12,7 mm sk ptr m/45 pbrsprj, brsprj och slbrsprj;
    ;
};

pub const Weapons = struct {
    pub const allNames: [*:0]const u8 = "AK5C;KSP58;KSP58_Benstod";

    pub var invalid: Weapon = Weapon{
        .Dmax = 0,
        .v_still = 0,
        .v_moveable = 0,
        .c = 0,
    };

    pub var AK5: Weapon = Weapon{
        .Dmax = 3000,
        .v_still = 100,
        .v_moveable = 100,
        .c = 200,
    };

    pub var KSP58: Weapon = Weapon{
        .Dmax = 4300,
        .v_still = 200,
        .v_moveable = 300,
        .c = 200,
    };

    pub var KSP58_Benstod: Weapon = Weapon{
        .Dmax = 4300,
        .v_still = 100,
        .v_moveable = 200,
        .c = 200,
    };
};
