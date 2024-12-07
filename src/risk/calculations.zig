const std = @import("std");
const gui = @import("../gui/state.zig");

pub const amm = @import("ammunition.zig");
pub const weapon = @import("weapon.zig");

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
    weaponType: weapon.Weapons.Model,
    weaponCaliber: amm.Caliber,
    selectedWeaponType: i32,
    factor: i32,
    inForest: bool,
    forestDist: i32,

    Dmax: i32,
    Amax: i32,
    Amin: i32,
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

    fn validate(self: *RiskArea) RiskValidationError!void {
        // Check for zero values in Amax or Amin
        if (self.Amax == 0 or self.Amin == 0) {
            return RiskValidationError.NoValue;
        }

        // Check for invalid range conditions
        if (self.Amin > self.Amax or self.Amin > self.Dmax or self.Amax > self.Dmax) {
            return RiskValidationError.InvalidRange;
        }

        // Check for negative values
        if (self.Dmax < 0 or self.Amax < 0 or self.Amin < 0 or self.f < 0 or self.q1 < 0 or self.c < 0 or self.l < 0 or self.h < 0) {
            return RiskValidationError.NegativeValue;
        }

        // Check for integer overflow (example check - you can adjust based on your logic)
        if (self.Amax > std.math.maxInt(i32) or self.Amin > std.math.maxInt(i32) or self.Dmax > std.math.maxInt(i32) or self.f > std.math.maxInt(i32)) {
            return RiskValidationError.IntegerOverflow;
        }

        // If all checks pass, set the valid flag
        self.valid = true;
    }

    fn getAmmunitionType(value: i32) amm.Caliber {
        return switch (value) {
            0 => amm.Caliber.hagelptr,
            1 => amm.Caliber.long_rifle_22,
            2 => amm.Caliber.ptr556_sk_prj_slprj,
            3 => amm.Caliber.ptr65_sk_prj_m41,
            4 => amm.Caliber.ptr762_sk_10b_prj_slprj,
            5 => amm.Caliber.ptr762_sk_10_pprj,
            6 => amm.Caliber.ptr762_sk_prick_lh,
            7 => amm.Caliber.ptr762_sk_prick,
            8 => amm.Caliber.ptr762_sk_39_prj,
            9 => amm.Caliber.ptr762_sk_95_prj_slprj,
            10 => amm.Caliber.ptr9_sk_39b,
            11 => amm.Caliber.ptr9_9_39_ovnprj_11,
            12 => amm.Caliber.ptr9_sk_67_slprj,
            13 => amm.Caliber.ptr127_sk_45_nprj_slnprj,
            14 => amm.Caliber.ptr27_sk_nprj_prick_slprj_prick,
            15 => amm.Caliber.ptr127_sk_45_pbrsprj_brsprj_slbrsprj,
            else => unreachable,
        };
    }

    fn getWeaponType(value: i32) weapon.Weapons.Model {
        return switch (value) {
            0 => weapon.Weapons.AK5,
            1 => weapon.Weapons.KSP58,
            2 => weapon.Weapons.KSP58_Benstod,
            else => weapon.Weapons.invalid,
        };
    }

    fn controlUpdate(self: *RiskArea, state: gui.guiState) bool {
        return (!(self.factor == state.riskFactor.value and
            self.fixedTarget == state.targetType.value and
            self.inForest == state.inForest.value and
            self.Amin == combineAsciiToInt(&state.Amin.value) and
            self.Amax == combineAsciiToInt(&state.Amax.value) and
            self.f == combineAsciiToInt(&state.f.value) and
            self.forestDist == combineAsciiToInt(&state.forestDist.value) and
            std.mem.eql(u8, self.weaponCaliber.name, getAmmunitionType(state.ammunitionType.value).name) and
            std.mem.eql(u8, self.weaponType.caliber.name, getWeaponType(state.weaponType.value).caliber.name)));
    }

    pub fn update(self: *RiskArea, state: gui.guiState) !void {
        if (controlUpdate(self, state) == false) return;

        self.factor = state.riskFactor.value;
        self.Amin = combineAsciiToInt(&state.Amin.value);
        self.Amax = combineAsciiToInt(&state.Amax.value);
        self.f = combineAsciiToInt(&state.f.value);
        self.inForest = state.inForest.value;
        self.forestDist = combineAsciiToInt(&state.forestDist.value);
        self.fixedTarget = state.targetType.value;
        self.weaponCaliber = getAmmunitionType(state.ammunitionType.value);
        self.weaponType = getWeaponType(state.weaponType.value);

        self.v = if (self.fixedTarget) self.weaponType.v_still else self.weaponType.v_moveable;
        self.Dmax = self.weaponCaliber.Dmax;

        self.l = self.calculateL();
        self.h = self.calculateH();
        self.c = self.calculateC();
        self.q1 = self.calculateQ1();
        self.q2 = self.calculateQ2();

        validate(self) catch |err| {
            std.log.info("Validation failed: {any}", .{err});
            return;
        };
    }

    fn calculateH(self: *RiskArea) i32 {
        return self.Amax + self.l;
    }

    fn calculateL(self: *RiskArea) i32 {
        return switch (self.factor + 1) {
            1 => @intFromFloat(0.8 * @as(f32, @floatFromInt(self.Dmax)) - 0.7 * @as(f32, @floatFromInt(self.Amax))),
            2 => @intFromFloat(0.6 * @as(f32, @floatFromInt(self.Dmax)) - 0.5 * @as(f32, @floatFromInt(self.Amax))),
            3 => @intFromFloat(0.4 * @as(f32, @floatFromInt(self.Dmax)) - 0.3 * @as(f32, @floatFromInt(self.Amax))),
            else => 0,
        };
    }

    fn calculateC(self: *RiskArea) f32 {
        return switch (self.inForest) {
            true => self.weaponCaliber.c,
            false => switch (self.factor + 1) {
                1 => 0.2 * @as(f32, @floatFromInt(self.Dmax - self.Amin)),
                2 => 0.15 * @as(f32, @floatFromInt(self.Dmax - self.Amin)),
                3 => 0.08 * @as(f32, @floatFromInt(self.Dmax - self.Amin)),
                else => 0.0,
            },
        };
    }

    fn calculateQ1(self: *RiskArea) f32 {
        return switch (self.factor + 1) {
            1 => self.weaponType.c,
            2, 3 => 400.0,
            else => 0.0,
        };
    }

    fn calculateQ2(self: *RiskArea) f32 {
        return if (self.forestDist < 0) 0.0 else 1000.0;
    }
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
