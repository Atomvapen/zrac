const std = @import("std");
const rl = @import("raylib");

pub const Line = struct {
    start: rl.Vector2,
    end: rl.Vector2,
};

pub const RiskLine = struct {
    startX: i32,
    startY: i32,
    endX: i32,
    endY: i32,
    angle: f32,

    pub fn getStartVector(self: *RiskLine) rl.Vector2 {
        return rl.Vector2{
            .x = @floatFromInt(self.startX),
            .y = @floatFromInt(self.startY),
        };
    }

    pub fn getEndVector(self: *RiskLine) rl.Vector2 {
        return rl.Vector2{
            .x = @floatFromInt(self.endX),
            .y = @floatFromInt(self.endY),
        };
    }

    pub fn drawCircleSector(self: *RiskLine, radius: f32) void {
        rl.drawCircleSectorLines(.{ .x = @floatFromInt(self.startX), .y = @floatFromInt(self.startY) }, radius, -90, -90 + milsToDegree(self.angle), 50, rl.Color.maroon);
    }

    pub fn drawText(self: *RiskLine, text: [*:0]const u8, textOffsetX: i32, textOffsetY: i32, fontSize: i32) void {
        rl.drawText(text, self.endX + textOffsetX, self.endY + textOffsetY, fontSize, rl.Color.black);
    }

    pub fn drawLine(self: *RiskLine) void {
        rl.drawLine(self.startX, self.startY, self.endX, self.endY, rl.Color.maroon);
    }

    /// Calculates the length of one leg of a right triangle given the other leg and an angle.
    ///
    /// This function uses the formula for finding a missing leg in a right triangle:
    /// ```
    /// a = b × tan(α)
    /// ```
    /// where:
    /// - `a` is the length of the missing leg.
    /// - `b` is the length of the known leg.
    /// - `α` is the angle in radians.
    ///
    /// For more details, see [Right Triangle Side Angle Calculator](https://www.omnicalculator.com/math/right-triangle-side-angle).
    ///
    /// # Parameters
    /// - `self`: A pointer to the `RiskLine` instance (not used in the calculation).
    /// - `width`: The length of the known leg (integer).
    /// - `angle`: The angle in degrees (converted to radians internally).
    ///
    /// # Returns
    /// - `i32`: The length of the missing leg, rounded to the nearest integer.
    ///
    /// # Example
    /// ```zig
    /// const myRiskLine = RiskLine{};
    /// const width = 10;
    /// const angle = 45.0; // in degrees
    /// const x = myRiskLine.calculateXfromAngle(width, angle);
    /// std.debug.print("The missing leg length is: {}\n", .{x});
    /// ```
    pub fn calculateXfromAngle(self: *RiskLine, width: i32, angle: f32) i32 {
        _ = self;
        const b: f32 = @as(f32, @floatFromInt(width));
        const a: f32 = @tan(milsToRadians(angle));

        return @intFromFloat(b * a);
    }

    /// Rotates the endpoint of a `RiskLine` around its starting point by the specified angle.
    ///
    /// This function modifies the `endX` and `endY` coordinates of the `RiskLine` to reflect
    /// the new position of the endpoint after rotation.
    ///
    /// The rotation is performed using the formula for rotating points around an arbitrary center:
    /// - `(x, y)` is the point to be rotated.
    /// - `(ox, oy)` is the center of rotation.
    /// - `θ` is the angle of rotation (positive counterclockwise) in radians.
    /// - `(x1, y1)` is the point after rotation.
    ///
    /// Formulas:
    /// ```
    /// rotated_x = (x – ox) * cos(θ) – (y – oy) * sin(θ) + ox
    /// rotated_y = (x – ox) * sin(θ) + (y – oy) * cos(θ) + oy
    /// ```
    ///
    /// For more details, see [Rotations in 2D](https://danceswithcode.net/engineeringnotes/rotations_in_2d/rotations_in_2d.html).
    ///
    /// # Parameters
    /// - `self`: A pointer to the `RiskLine` instance whose endpoint should be rotated.
    ///
    /// # Safety
    /// This function assumes `self` is a valid, non-null pointer to a `RiskLine` instance.
    ///
    /// # Example
    /// ```zig
    /// const myRiskLine = RiskLine{
    ///     .startX = 0,
    ///     .startY = 0,
    ///     .endX = 10,
    ///     .endY = 0,
    ///     .angle = 90, // in degrees (converted to radians internally)
    /// };
    /// myRiskLine.rotateEndPoint();
    /// ```
    pub fn rotateEndPoint(self: *RiskLine) void {
        const localEndX: i32 = @intFromFloat((@as(f32, @floatFromInt(self.endX - self.startX)) * @cos(milsToRadians(self.angle)) - (@as(f32, @floatFromInt(self.endY - self.startY))) * @sin(milsToRadians(self.angle))) + @as(f32, @floatFromInt(self.startX)));
        const localEndY: i32 = @intFromFloat((@as(f32, @floatFromInt(self.endX - self.startX)) * @sin(milsToRadians(self.angle)) + (@as(f32, @floatFromInt(self.endY - self.startY))) * @cos(milsToRadians(self.angle))) + @as(f32, @floatFromInt(self.startY)));

        self.*.endX = localEndX;
        self.*.endY = localEndY;
    }

    pub fn milsToDegree(mils: f32) f32 {
        return mils * 0.05625;
    }

    pub fn milsToRadians(mils: f32) f32 {
        return mils * 0.000982;
    }
};

/// Calculates the intersection point of two line segments, if it exists.
///
/// The function determines the point where two lines intersect, based on their
/// start and end coordinates. If the lines are parallel and do not intersect,
/// it returns `null`.
///
/// The formula for finding the intersection is derived from solving the equations
/// of the two lines in parametric form:
/// ```
/// denom = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)
/// t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / denom
/// intersection_x = x1 + t * (x2 - x1)
/// intersection_y = y1 + t * (y2 - y1)
/// ```
///
/// # Parameters
/// - `line1_start`: The starting point of the first line.
/// - `line1_end`: The ending point of the first line.
/// - `line2_start`: The starting point of the second line.
/// - `line2_end`: The ending point of the second line.
///
/// # Returns
/// - `?rl.Vector2`: The intersection point as `rl.Vector2`, or `null` if the lines are parallel.
///
/// # Example
/// ```zig
/// const line1_start = rl.Vector2{ .x = 0, .y = 0 };
/// const line1_end = rl.Vector2{ .x = 10, .y = 10 };
/// const line2_start = rl.Vector2{ .x = 0, .y = 10 };
/// const line2_end = rl.Vector2{ .x = 10, .y = 0 };
/// const intersection = getLineIntersectionPoint(line1_start, line1_end, line2_start, line2_end);
/// if (intersection) |point| {
///     std.debug.print("Intersection at: ({}, {})\n", .{point.x, point.y});
/// } else {
///     std.debug.print("No intersection\n", .{});
/// }
/// ```
pub fn getLineIntersectionPoint(line1_start: rl.Vector2, line1_end: rl.Vector2, line2_start: rl.Vector2, line2_end: rl.Vector2) ?rl.Vector2 {
    const x1 = line1_start.x;
    const y1 = line1_start.y;
    const x2 = line1_end.x;
    const y2 = line1_end.y;

    const x3 = line2_start.x;
    const y3 = line2_start.y;
    const x4 = line2_end.x;
    const y4 = line2_end.y;

    const denom = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
    if (denom == 0) return null;

    const t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / denom;
    const intersection_x = x1 + t * (x2 - x1);
    const intersection_y = y1 + t * (y2 - y1);

    return rl.Vector2{ .x = intersection_x, .y = intersection_y };
}

/// Calculates a line parallel to the given line at a specified distance.
///
/// This function computes the coordinates of a line parallel to the input line.
/// The parallel line is offset by a specified distance `c` along a perpendicular
/// direction.
///
/// The perpendicular direction is calculated by rotating the original direction vector
/// of the line by 90 degrees, then normalizing it. The endpoints of the original line
/// are then offset by the perpendicular vector scaled by the distance `c`.
///
/// # Parameters
/// - `x1`: The x-coordinate of the starting point of the original line.
/// - `y1`: The y-coordinate of the starting point of the original line.
/// - `x2`: The x-coordinate of the ending point of the original line.
/// - `y2`: The y-coordinate of the ending point of the original line.
/// - `c`: The perpendicular distance by which to offset the line.
///
/// # Returns
/// - `!Line`: A new `Line` structure representing the parallel line.
///
/// # Errors
/// This function may fail if:
/// - The length of the original line is zero, causing a division by zero during normalization.
///
/// # Example
/// ```zig
/// const x1: f32 = 0.0;
/// const y1: f32 = 0.0;
/// const x2: f32 = 10.0;
/// const y2: f32 = 0.0;
/// const c: f32 = 5.0;
/// const parallelLine = calculate_parallel_line(x1, y1, x2, y2, c) catch {
///     std.debug.print("Error calculating parallel line\n", .{});
///     return;
/// };
/// std.debug.print("Parallel Line: Start({},{}) End({},{})\n",
///     .{parallelLine.start.x, parallelLine.start.y, parallelLine.end.x, parallelLine.end.y});
/// ```
pub fn calculate_parallel_line(x1: f32, y1: f32, x2: f32, y2: f32, c: f32) !Line {
    // Compute direction vector of the original line
    const dx = x2 - x1;
    const dy = y2 - y1;

    // Compute the perpendicular direction (90 degrees rotated)
    var perpendicular_x = -dy;
    var perpendicular_y = dx;

    // Normalize the perpendicular direction
    const length = std.math.sqrt(perpendicular_x * perpendicular_x + perpendicular_y * perpendicular_y);
    perpendicular_x /= length;
    perpendicular_y /= length;

    // Offset the original line by distance c along the perpendicular direction
    const offset_x = perpendicular_x * c;
    const offset_y = perpendicular_y * c;

    // Calculate new endpoints for the parallel line (both above and below the original line)
    const x1_parallel = x1 + offset_x;
    const y1_parallel = y1 + offset_y;
    const x2_parallel = x2 + offset_x;
    const y2_parallel = y2 + offset_y;

    // Return the new start and end points of the parallel line
    return Line{ .start = rl.Vector2{ .x = x1_parallel, .y = y1_parallel }, .end = rl.Vector2{ .x = x2_parallel, .y = y2_parallel } };
}
