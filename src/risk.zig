const std = @import("std");
const gui = @import("gui.zig");

const RiskValidationError = error{
    NoValue,
    NegativeValue,
    InvalidRange,
    IntegerOverflow,
    UnknownError,
    InvadlidCharacter,
};

pub const RiskArea = struct {
    // Given values
    weaponType: WeaponArsenal.Model,
    weaponCaliber: WeaponArsenal.Caliber,
    selectedWeaponType: i32,
    factor: i32,
    inForest: bool,
    forestDist: i32,

    Dmax: i32,
    Amax: i32,
    Amin: i32,
    Amin2: [*:0]u8,
    f: i32,
    fixedTarget: bool,

    // Calculated and/or fixed values
    valid: bool,
    v: f32 = undefined,
    q1: f32 = undefined,
    q2: f32 = undefined,
    ch: f32 = 1000,

    c: f32 = undefined,
    l: i32 = undefined,
    h: i32 = undefined,

    pub fn update(self: *RiskArea, state: gui.guiState) !void {
        self.factor = state.riskFactor.value;
        self.Amin = combineAsciiToInt(&state.Amin.value);
        self.Amax = combineAsciiToInt(&state.Amax.value);
        self.f = combineAsciiToInt(&state.f.value);
        self.inForest = state.inForest.value;
        self.forestDist = combineAsciiToInt(&state.forstDist.value);
        self.fixedTarget = state.targetType.value;
        self.weaponCaliber = switch (state.ammunitionType.value) {
            0 => WeaponArsenal.Caliber.hagelptr,
            1 => WeaponArsenal.Caliber.long_rifle_22,
            2 => WeaponArsenal.Caliber.ptr556_sk_prj_slprj,
            3 => WeaponArsenal.Caliber.ptr65_sk_prj_m41,
            4 => WeaponArsenal.Caliber.ptr762_sk_10b_prj_slprj,
            5 => WeaponArsenal.Caliber.ptr762_sk_10_pprj,
            6 => WeaponArsenal.Caliber.ptr762_sk_prick_lh,
            7 => WeaponArsenal.Caliber.ptr762_sk_prick,
            8 => WeaponArsenal.Caliber.ptr762_sk_39_prj,
            9 => WeaponArsenal.Caliber.ptr762_sk_95_prj_slprj,
            10 => WeaponArsenal.Caliber.ptr9_sk_39b,
            11 => WeaponArsenal.Caliber.ptr9_9_39_ovnprj_11,
            12 => WeaponArsenal.Caliber.ptr9_sk_67_slprj,
            13 => WeaponArsenal.Caliber.ptr127_sk_45_nprj_slnprj,
            14 => WeaponArsenal.Caliber.ptr27_sk_nprj_prick_slprj_prick,
            15 => WeaponArsenal.Caliber.ptr127_sk_45_pbrsprj_brsprj_slbrsprj,
            else => unreachable,
        };
        self.weaponType = switch (state.weaponType.value) {
            0 => WeaponArsenal.AK5,
            1 => WeaponArsenal.KSP58,
            2 => WeaponArsenal.KSP58_Benstod,
            else => WeaponArsenal.invalid,
        };

        self.v = if (self.fixedTarget) self.weaponType.v_still else self.weaponType.v_moveable;
        self.Dmax = self.weaponCaliber.Dmax;

        self.l = self.calculateL();
        self.h = self.calculateH();
        self.c = self.calculateC();
        self.q1 = self.calculateQ1();
        self.q2 = self.calculateQ2();
    }

    pub fn validate(self: *RiskArea) void {
        self.valid = !((self.f == 0 and self.Amax == 0 and self.Amin == 0) or
            (self.forestDist < -1) or
            (self.Dmax < 0) or
            (self.Amax < 0) or
            (self.Amin < 0) or
            (self.f < 0) or
            (self.q1 < 0) or
            (self.c < 0) or
            (self.l < 0) or
            (self.h < 0) or
            (self.Amin > self.Amax) or
            (self.Amax > self.Dmax));
    }

    pub fn calculateH(self: *RiskArea) i32 {
        return self.Amax + self.l;
    }

    pub fn calculateL(self: *RiskArea) i32 {
        switch (self.factor + 1) {
            1 => return @intFromFloat(0.8 * @as(f32, @floatFromInt(self.Dmax)) - 0.7 * @as(f32, @floatFromInt(self.Amax))),
            2 => return @intFromFloat(0.6 * @as(f32, @floatFromInt(self.Dmax)) - 0.5 * @as(f32, @floatFromInt(self.Amax))),
            3 => return @intFromFloat(0.4 * @as(f32, @floatFromInt(self.Dmax)) - 0.3 * @as(f32, @floatFromInt(self.Amax))),
            else => return 0,
        }
    }

    pub fn calculateC(self: *RiskArea) f32 {
        switch (self.inForest) {
            true => return self.weaponCaliber.c,
            false => switch (self.factor + 1) {
                1 => return 0.2 * @as(f32, @floatFromInt(self.Dmax - self.Amin)),
                2 => return 0.15 * @as(f32, @floatFromInt(self.Dmax - self.Amin)),
                3 => return 0.08 * @as(f32, @floatFromInt(self.Dmax - self.Amin)),
                else => return 0.0,
            },
        }
    }

    pub fn calculateQ1(self: *RiskArea) f32 {
        switch (self.factor + 1) {
            1 => return self.weaponType.c,
            2, 3 => return 400.0,
            else => return 0.0,
        }
    }

    pub fn calculateQ2(self: *RiskArea) f32 {
        if (self.forestDist < 0) return 0.0;
        return 1000.0;
    }
};

pub const WeaponArsenal = struct {
    const Model = struct {
        Dmax: i32,
        v_still: f32,
        v_moveable: f32,
        c: f32,
        caliber: Caliber,
    };

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

    pub const allAmmunitionNames: [*:0]const u8 = "Hagelptr; 22 long rifle;5,56 mm sk ptr 5/5B prj/slprj;6,5 mm sk ptr prj m/41;7,62 mm sk ptr 10(B) prj/slprj;7,62 mm sk ptr 10 PPRJ;7,62 mm sk ptr PRICK LH;7,62 mm sk ptr PRICK;7,62 mm sk ptr 39 prj;7,62 mm sk ptr 95 prj/slprj;9 mm sk ptr m/39B;9 mm 9/39 övnprj 11;9 mm sk ptr m/67 slprj;12,7 mm sk ptr m/45 nprj och slnprj;12,7 mm sk ptr nprj prick och slprj prick;12,7 mm sk ptr m/45 pbrsprj, brsprj och slbrsprj";

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

/// Combines an array of ASCII characters representing digits into an integer.
///
/// This function takes an array of ASCII characters, interprets them as numeric digits,
/// and combines them into a single integer. Non-digit characters are skipped.
/// The function handles potential overflow by returning the maximum value of an `i32`
/// when overflow is detected.
///
/// # Parameters
/// - `asciiArray`: A slice of unsigned 8-bit integers (`[]const u8`) representing ASCII characters.
///
/// # Returns
/// - `i32`: The combined integer value of the ASCII digits. If an overflow occurs,
/// the function returns `std.math.maxInt(i32)`.
///
/// # Example
/// ```zig
/// const asciiArray: []const u8 = "12345";
/// const result = combineAsciiToInt(asciiArray);
/// std.debug.print("The combined integer is: {}", .{result});
/// ```
///
/// # Notes
/// - Non-digit characters in the input are ignored.
/// - Overflow is handled gracefully by returning the maximum integer value.
fn combineAsciiToInt(asciiArray: []const u8) i32 {
    var result: i32 = 0;

    for (asciiArray) |asciiChar| {
        const digit = @as(i32, @intCast(asciiChar)) - '0'; // Convert ASCII digit to numeric value

        // Check for potential overflow before performing the operation
        if (digit < 0 or digit > 9) continue; // Skip non-digit characters

        if (result > @divFloor((std.math.maxInt(i32) - digit), 10)) {
            // Handle overflow (e.g., return an error, set result to max, etc.)
            return std.math.maxInt(i32); // Return max value on overflow
        }

        result = result * 10 + digit; // Shift left and add digit
    }

    return result;
}
