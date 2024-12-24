const std = @import("std");

// pub const ptr762Caliber = enum {
//     ptr762_sk_10b_prj_slprj,
//     ptr762_sk_10_pprj,
//     ptr762_sk_prick_lh,
//     ptr762_sk_prick,
//     ptr762_sk_39_prj,
//     ptr762_sk_95_prj_slprj,
// };

// pub const ptr556Caliber = enum {
//     hagelptr,
//     ptr556_sk_prj_slprj,
// };

// pub const ptr9Caliber = enum {
//     ptr9_sk_39b,
//     ptr9_9_39_ovnprj_11,
//     ptr9_sk_67_slprj,
// };

// pub const ptr127Caliber = enum {
//     ptr127_sk_45_nprj_slnprj,
//     ptr127_sk_nprj_prick_slprj_prick,
//     ptr127_sk_45_pbrsprj_brsprj_slbrsprj,
// };

pub const Calibers = enum {
    pub const ptr762 = enum {
        ptr762_sk_10b_prj_slprj,
        ptr762_sk_10_pprj,
        ptr762_sk_prick_lh,
        ptr762_sk_prick,
        ptr762_sk_39_prj,
        ptr762_sk_95_prj_slprj,
    };
    pub const ptr556 = enum {
        hagelptr,
        ptr556_sk_prj_slprj,
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

    // hagelptr,
    // long_rifle_22,
    // ptr556_sk_prj_slprj,
    // ptr65_sk_prj_m41,
    // ptr762_sk_10b_prj_slprj,
    // ptr762_sk_10_pprj,
    // ptr762_sk_prick_lh,
    // ptr762_sk_prick,
    // ptr762_sk_39_prj,
    // ptr762_sk_95_prj_slprj,
    // ptr9_sk_39b,
    // ptr9_9_39_ovnprj_11,
    // ptr9_sk_67_slprj,
    // ptr127_sk_45_nprj_slnprj,
    // ptr127_sk_nprj_prick_slprj_prick,
    // ptr127_sk_45_pbrsprj_brsprj_slbrsprj,
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
    pub const ptr127_sk_nprj_prick_slprj_prick: Caliber = Caliber{ .Dmax = 7000, .y = undefined, .c = 400, .id = 14 };
    pub const ptr127_sk_45_pbrsprj_brsprj_slbrsprj: Caliber = Caliber{ .Dmax = 7000, .y = undefined, .c = 400, .id = 15 };
};

pub fn getAmmunitionType2(value: anytype) Caliber {
    std.debug.print("{any}\n", .{@TypeOf(value)});
    std.debug.print("{any}\n", .{@TypeOf(value) == Calibers.ptr556});
    std.debug.print("{any}\n", .{value});
    if (@TypeOf(value) == Calibers.ptr762) {
        // if (std.mem.eql(u8, @tagName(value), "ptr762")) {
        const v762 = value;
        if (v762 == .ptr762_sk_10b_prj_slprj) return Caliber.ptr762_sk_10b_prj_slprj;
        if (v762 == .ptr762_sk_10_pprj) return Caliber.ptr762_sk_10_pprj;
        if (v762 == .ptr762_sk_prick_lh) return Caliber.ptr762_sk_prick_lh;
        if (v762 == .ptr762_sk_prick) return Caliber.ptr762_sk_prick;
        if (v762 == .ptr762_sk_39_prj) return Caliber.ptr762_sk_39_prj;
        if (v762 == .ptr762_sk_95_prj_slprj) return Caliber.ptr762_sk_95_prj_slprj;
    } else if (@TypeOf(value) == Calibers.ptr127) {
        const v127 = value;
        if (v127 == .ptr127_sk_45_nprj_slnprj) return Caliber.ptr127_sk_45_nprj_slnprj;
        if (v127 == .ptr127_sk_nprj_prick_slprj_prick) return Caliber.ptr127_sk_nprj_prick_slprj_prick;
        if (v127 == .ptr127_sk_45_pbrsprj_brsprj_slbrsprj) return Caliber.ptr127_sk_45_pbrsprj_brsprj_slbrsprj;
    } else if (@TypeOf(value) == Calibers.ptr556) {
        std.debug.print("test\n", .{});
        const v556 = value;
        if (v556 == .ptr556_sk_prj_slprj) return Caliber.ptr556_sk_prj_slprj;
        if (v556 == .hagelptr) return Caliber.hagelptr;
    } else if (@TypeOf(value) == Calibers.ptr9) {
        const v9 = value;
        if (v9 == .ptr9_sk_39b) return Caliber.ptr9_sk_39b;
        if (v9 == .ptr9_9_39_ovnprj_11) return Caliber.ptr9_9_39_ovnprj_11;
        if (v9 == .ptr9_sk_67_slprj) return Caliber.ptr9_sk_67_slprj;
    }

    return Caliber.invalid;
}

// pub fn getAmmunitionType2(value: type) Caliber {
//     switch (@TypeOf(value)) {
//         Calibers.ptr762 => return switch (value) {
//             .ptr762_sk_10b_prj_slprj => Caliber.ptr762_sk_10b_prj_slprj,
//             .ptr762_sk_10_pprj => Caliber.ptr762_sk_10_pprj,
//             .ptr762_sk_prick_lh => Caliber.ptr762_sk_prick_lh,
//             .ptr762_sk_prick => Caliber.ptr762_sk_prick,
//             .ptr762_sk_39_prj => Caliber.ptr762_sk_39_prj,
//             .ptr762_sk_95_prj_slprj => Caliber.ptr762_sk_95_prj_slprj,
//         },
//         Calibers.ptr127 => return switch (value) {
//             .ptr127_sk_45_nprj_slnprj => Caliber.ptr127_sk_45_nprj_slnprj,
//             .ptr127_sk_nprj_prick_slprj_prick => Caliber.ptr127_sk_nprj_prick_slprj_prick,
//             .ptr127_sk_45_pbrsprj_brsprj_slbrsprj => Caliber.ptr127_sk_45_pbrsprj_brsprj_slbrsprj,
//         },
//         Calibers.ptr556 => return switch (value) {
//             .ptr556_sk_prj_slprj => Caliber.ptr556_sk_prj_slprj,
//             .hagelptr => Caliber.hagelptr,
//         },
//         Calibers.ptr9 => return switch (value) {
//             .ptr9_sk_39b => Caliber.ptr9_sk_39b,
//             .ptr9_9_39_ovnprj_11 => Caliber.ptr9_9_39_ovnprj_11,
//             .ptr9_sk_67_slprj => Caliber.ptr9_sk_67_slprj,
//         },

//         // return switch (value) {
//         //     .long_rifle_22 => Caliber.long_rifle_22,
//         //     .ptr65_sk_prj_m41 => Caliber.ptr65_sk_prj_m41,
//         // };
//     }
// }

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
        .ptr127_sk_nprj_prick_slprj_prick => Caliber.ptr127_sk_nprj_prick_slprj_prick,
        .ptr127_sk_45_pbrsprj_brsprj_slbrsprj => Caliber.ptr127_sk_45_pbrsprj_brsprj_slbrsprj,
    };
}
