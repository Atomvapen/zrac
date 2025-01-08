const std = @import("std");
const rl = @import("raylib");
const reg = @import("reg");
const trig = reg.math.trig;
const DrawBuffer = reg.gui.DrawBuffer;

pub const Semicircle = struct {
    color: rl.Color,
    startAngle: f32,
    endAngle: f32,
    radius: f32,
    center: rl.Vector2,
    segments: i32,
    // command: DrawBuffer.Command = undefined,

    pub fn init(color: rl.Color, startAngle: f32, endAngle: f32, radius: f32, center: rl.Vector2, segments: i32) Semicircle {
        return Semicircle{
            .color = color,
            .startAngle = trig.convertAngle(startAngle, .Mils, .Degrees),
            .endAngle = trig.convertAngle(endAngle, .Mils, .Degrees),
            .radius = radius,
            .center = center,
            .segments = segments,
        };
    }

    pub fn createDrawCommand(self: *Semicircle) DrawBuffer.Command {
        return .{ .Semicircle = DrawBuffer.Command.create(.Semicircle).init(self.color, self.startAngle, self.endAngle, self.radius, self.center, self.segments) };
    }
};

pub const Line = struct {
    start: rl.Vector2,
    end: rl.Vector2,
    text: DrawBuffer.Command = undefined,
    // command: drawBuffer.Command = undefined,

    /// Initiates a Line.
    pub fn init(start: rl.Vector2, end: rl.Vector2) Line {
        return Line{ .start = start, .end = end };
    }

    /// Adds text to the line for later drawing.
    pub fn addText(self: *Line, text: [*:0]const u8, textOffsetX: i32, textOffsetY: i32, fontSize: i32, color: rl.Color, pos: rl.Vector2) void {
        self.text = .{ .Text = DrawBuffer.Command.create(.Text).init(text, textOffsetX, textOffsetY, fontSize, color, pos) };
    }

    /// Creates draw-command for execution
    pub fn createDrawCommand(self: *Line) DrawBuffer.Command {
        return .{ .Line = DrawBuffer.Command.create(.Line).init2(self.start, self.end, rl.Color.red) };
    }

    /// Rotates one endpoint of a `Line` around the other by the specified angle.
    ///
    /// This function modifies the position of either the starting point (`Start`)
    /// or the ending point (`End`) of the line, depending on the `direction` provided.
    /// The rotation is performed around the other fixed point, using the formula for
    /// rotating points around an arbitrary center.
    ///
    /// ### Parameters:
    /// - `direction`: Specifies which endpoint to rotate. Can be:
    ///   - `.Start`: Rotates the starting point around the ending point.
    ///   - `.End`: Rotates the ending point around the starting point.
    /// - `line`: A pointer to the `Line` structure, which contains the `start` and `end` points.
    /// - `angle`: The rotation angle in milliradians. Use a positive angle for counterclockwise
    ///   rotation and a negative angle for clockwise rotation.
    pub fn rotate(self: *Line, direction: enum { End, Start }, angle: f32) void {
        const rad = trig.convertAngle(angle, .Mils, .Radians);

        const cosAngle = @cos(rad);
        const sinAngle = @sin(rad);

        switch (direction) {
            .End => {
                const dx = self.end.x - self.start.x;
                const dy = self.end.y - self.start.y;

                self.end.x = (dx * cosAngle) - (dy * sinAngle) + self.start.x;
                self.end.y = (dx * sinAngle) + (dy * cosAngle) + self.start.y;
            },
            .Start => {
                const dx = self.start.x - self.end.x;
                const dy = self.start.y - self.end.y;

                self.start.x = (dx * cosAngle) - (dy * sinAngle) + self.end.x;
                self.start.y = (dx * sinAngle) + (dy * cosAngle) + self.end.y;
            },
        }
    }

    /// Calculates the intersection point of two line segments, if it exists.
    ///
    /// The function determines the point where two lines intersect, based on their
    /// start and end coordinates. If the lines are parallel and do not intersect,
    /// it returns `null`.
    ///
    /// The formula for finding the intersection is derived from solving the equations
    /// of the two lines in parametric form:
    pub fn getIntersectionPoint(self: *Line, line: Line) ?rl.Vector2 {
        // Self points
        const line1_start_x: f32 = self.start.x;
        const line1_start_y: f32 = self.start.y;
        const line1_end_x: f32 = self.end.x;
        const line1_end_y: f32 = self.end.y;

        // Other line points
        const line2_start_x: f32 = line.start.x;
        const line2_start_y: f32 = line.start.y;
        const line2_end_x: f32 = line.end.x;
        const line2_end_y: f32 = line.end.y;

        // Denominator for the intersection calculation
        const denominator = (line1_start_x - line1_end_x) * (line2_start_y - line2_end_y) - (line1_start_y - line1_end_y) * (line2_start_x - line2_end_x);
        if (denominator == 0) return null;

        // Parameter t for intersection calculation
        const t = ((line1_start_x - line2_start_x) * (line2_start_y - line2_end_y) - (line1_start_y - line2_start_y) * (line2_start_x - line2_end_x)) / denominator;

        // Intersection point
        const intersection_x = line1_start_x + t * (line1_end_x - line1_start_x);
        const intersection_y = line1_start_y + t * (line1_end_y - line1_start_y);

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
    pub fn getParallelLine(self: *Line, offset: f32) !Line {
        const start_x: f32 = self.start.x;
        const start_y: f32 = self.start.y;
        const end_x: f32 = self.end.x;
        const end_y: f32 = self.end.y;

        // Compute direction vector of the original line
        const dx = end_x - start_x;
        const dy = end_y - start_y;

        // Compute the perpendicular direction (90 degrees rotated)
        var perpendicular_x = -dy;
        var perpendicular_y = dx;

        // Normalize the perpendicular direction
        const length = std.math.sqrt(perpendicular_x * perpendicular_x + perpendicular_y * perpendicular_y);
        perpendicular_x /= length;
        perpendicular_y /= length;

        // Offset the original line by distance c along the perpendicular direction
        const offset_x = perpendicular_x * offset;
        const offset_y = perpendicular_y * offset;

        // Calculate new endpoints for the parallel line (both above and below the original line)
        const x1_parallel = start_x + offset_x;
        const y1_parallel = start_y + offset_y;
        const x2_parallel = end_x + offset_x;
        const y2_parallel = end_y + offset_y;

        // Return the new start and end points of the parallel line
        return Line{ .start = rl.Vector2{ .x = x1_parallel, .y = y1_parallel }, .end = rl.Vector2{ .x = x2_parallel, .y = y2_parallel } };
    }
};
