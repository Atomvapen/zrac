const std = @import("std");

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
pub fn combineAsciiToInt(asciiArray: []const u8) i32 {
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

/// Combines an array of ASCII characters representing digits into a floating-point number (`f32`).
///
/// This function takes an array of ASCII characters, interprets them as a numeric value,
/// and combines them into a single floating-point number. Both integer and fractional parts are supported,
/// with the decimal point (`.`) used to separate the two. Non-numeric characters, other than the decimal point,
/// are ignored.
///
/// # Parameters
/// - `asciiArray`: A slice of unsigned 8-bit integers (`[]const u8`) representing ASCII characters.
///
/// # Returns
/// - `f32`: The combined floating-point value of the ASCII digits. If no valid numeric characters are found,
/// the function returns `0.0`.
///
/// # Example
/// ```zig
/// const asciiArray: []const u8 = "123.456";
/// const result = combineAsciiToFloat(asciiArray);
/// std.debug.print("The combined float is: {}\n", .{result});
/// ```
///
/// # Notes
/// - Non-digit characters (except the decimal point) in the input are ignored.
/// - If multiple decimal points are encountered, the function stops processing further.
/// - Leading zeros are handled correctly, e.g., "000123.45" results in `123.45`.
/// - Overflow is not explicitly checked; extreme inputs may result in rounding due to `f32` precision limits.
/// - Trailing invalid characters (e.g., "123abc") are ignored.
///
/// # Limitations
/// - Does not handle negative numbers or scientific notation (e.g., "1.23e4"). These cases would require additional logic.
pub fn combineAsciiToFloat(asciiArray: []const u8) f32 {
    var result: f32 = 0.0;
    var isFractional = false;
    var fractionalDivisor: f32 = 1.0;

    for (asciiArray) |asciiChar| {
        if (asciiChar == '.') {
            if (isFractional) break; // Only allow one decimal point
            isFractional = true;
            continue;
        }

        const digit = @as(i32, @intCast(asciiChar)) - '0'; // Convert ASCII digit to numeric value
        if (digit < 0 or digit > 9) continue; // Skip non-digit characters

        if (isFractional) {
            fractionalDivisor *= 10.0;
            result += @as(f32, @floatFromInt(digit)) / fractionalDivisor;
        } else {
            result = result * 10.0 + @as(f32, @floatFromInt(digit));
        }
    }

    return result;
}
