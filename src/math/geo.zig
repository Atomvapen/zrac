const std = @import("std");
const rl = @import("raylib");
const reg = @import("reg");
const trig = reg.math.trig;
const DrawBuffer = reg.gui.DrawBuffer;

pub const Shape = union(enum) {
    Point: Point,
    Semicircle: Semicircle,
    Line: Line,
};

pub const Point = struct {
    pos: rl.Vector2,
    text: struct { show: bool = false, init: bool = false, text: [*:0]const u8, textOffsetX: i32, textOffsetY: i32, fontSize: i32, color: rl.Color, pos: rl.Vector2 } = undefined,

    /// Initiates a Point
    pub fn init(pos: rl.Vector2) Point {
        return Point{ .pos = pos };
    }

    /// Distance from the origin (0,0) to the point
    pub fn magnitude(self: *Point) f32 {
        return @sqrt(self.pos.x * self.pos.x + self.pos.y * self.pos.y);
    }

    /// Add Point
    pub fn add(self: *Point, b: Point) void {
        self.pos = rl.Vector2{ .x = self.pos.x + b.pos.x, .y = self.pos.y + b.pos.y };
    }

    /// Subtract Point
    pub fn sub(self: *Point, b: Point) void {
        self.pos = rl.Vector2{ .x = self.pos.x - b.pos.x, .y = self.pos.y - b.pos.y };
    }

    /// Scale Point by factor
    pub fn scale(self: *Point, factor: f32) void {
        self.pos = rl.Vector2{ .x = self.pos.x * factor, .y = self.pos.y * factor };
    }

    /// Multiply Point by Point
    pub fn multiply(self: *Point, b: Point) void {
        self.pos = rl.Vector2{ .x = self.pos.x * b.pos.x, .y = self.pos.y * b.pos.y };
    }

    /// Add text-command
    pub fn addText(self: *Point, text: [*:0]const u8, textOffsetX: i32, textOffsetY: i32, fontSize: i32, color: rl.Color, show: bool) void {
        self.text = .{ .show = show, .init = true, .text = text, .textOffsetX = textOffsetX, .textOffsetY = textOffsetY, .fontSize = fontSize, .color = color, .pos = self.pos };
    }

    pub fn normalize(self: Point) Point {
        const mag = self.magnitude(); // Calculate the vector's magnitude

        if (mag == 0) return self; // Handle the special case for zero vector

        // Divide each component by the magnitude to normalize
        return Point{
            .x = self.pos.x / mag,
            .y = self.pos.y / mag,
        };
    }

    /// Rotates a `Point` around the other Point by the specified angle in mils.
    ///
    /// This function modifies the position of the  point
    /// The rotation is performed around the other fixed point.
    pub fn rotate(self: *Point, point: rl.Vector2, angle: f32) void {
        const rad = trig.convertAngle(angle, .Mils, .Radians);

        const cosAngle = @cos(rad);
        const sinAngle = @sin(rad);

        const dx = self.pos.x - point.x;
        const dy = self.pos.y - point.y;

        self.pos.x = (dx * cosAngle) - (dy * sinAngle) + point.x;
        self.pos.y = (dx * sinAngle) + (dy * cosAngle) + point.y;
    }
};

pub const Semicircle = struct {
    color: rl.Color,
    startAngle: f32,
    endAngle: f32,
    radius: f32,
    center: rl.Vector2,
    segments: i32,
    text: struct { show: bool = false, init: bool = false, text: [*:0]const u8, textOffsetX: i32, textOffsetY: i32, fontSize: i32, color: rl.Color, pos: rl.Vector2 } = undefined,

    /// Initiates a Semicircle
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

    /// Add text-command
    pub fn addText(self: *Semicircle, text: [*:0]const u8, textOffsetX: i32, textOffsetY: i32, fontSize: i32, color: rl.Color, pos: rl.Vector2, show: bool) void {
        self.text = .{ .show = show, .init = true, .text = text, .textOffsetX = textOffsetX, .textOffsetY = textOffsetY, .fontSize = fontSize, .color = color, .pos = pos };
    }

    /// Scale Semicircle by factor
    pub fn scale(self: *Semicircle, factor: f32) void {
        self.radius *= factor;
    }

    /// Add Semicircle
    pub fn add(self: *Semicircle, semicircle: Semicircle) void {
        self.radius += semicircle.radius;
        self.center.x += semicircle.center.x;
        self.center.y += semicircle.center.y;
    }
};

pub const Line = struct {
    start: rl.Vector2,
    end: rl.Vector2,
    text: struct { show: bool = false, init: bool = false, text: [*:0]const u8, textOffsetX: i32, textOffsetY: i32, fontSize: i32, color: rl.Color, pos: rl.Vector2 } = undefined,

    /// Initiates a Line
    pub fn init(start: rl.Vector2, end: rl.Vector2) Line {
        return Line{ .start = start, .end = end };
    }

    /// Add text-command
    pub fn addText(self: *Line, text: [*:0]const u8, textOffsetX: i32, textOffsetY: i32, fontSize: i32, color: rl.Color, pos: rl.Vector2, show: bool) void {
        self.text = .{ .show = show, .init = true, .text = text, .textOffsetX = textOffsetX, .textOffsetY = textOffsetY, .fontSize = fontSize, .color = color, .pos = pos };
    }

    /// Length of Line
    pub fn getLength(self: *Line) f32 {
        return @sqrt(self.start.x * self.end.x + self.start.y * self.end.y);
    }

    /// Distance from the origin (0,0) to the endpoint
    pub fn getEndLength(self: *Line) f32 {
        return @sqrt(self.end.x * self.end.x + self.end.y * self.end.y);
    }

    /// Distance from the origin (0,0) to the startpoint
    pub fn getStartLength(self: *Line) f32 {
        return @sqrt(self.start.x * self.start.x + self.start.y * self.start.y);
    }

    /// Add Line
    pub fn add(self: *Line, b: Line) void {
        self.start = rl.Vector2{ .x = self.start.x + b.start.x, .y = self.start.y + b.start.y };
        self.end = rl.Vector2{ .x = self.end.x + b.end.x, .y = self.end.y + b.end.y };
    }

    /// Subtract Line
    pub fn sub(self: *Line, b: Line) void {
        self.start = rl.Vector2{ .x = self.start.x - b.start.x, .y = self.start.y - b.start.y };
        self.end = rl.Vector2{ .x = self.end.x - b.end.x, .y = self.end.y - b.end.y };
    }

    /// Scale Line by factor
    pub fn scale(self: *Line, factor: f32) void {
        self.start = rl.Vector2{ .x = self.start.x * factor, .y = self.start.y * factor };
        self.end = rl.Vector2{ .x = self.end.x * factor, .y = self.end.y * factor };
    }

    /// Multiply Line by Line
    pub fn multiply(self: *Line, b: Line) void {
        self.start = rl.Vector2{ .x = self.start.x * b.start.x, .y = self.start.y * b.start.y };
        self.end = rl.Vector2{ .x = self.end.x * b.end.x, .y = self.end.y * b.end.y };
    }

    /// Rotates one endpoint of a `Line` around the other by the specified angle in mils.
    ///
    /// This function modifies the position of either the starting point (`Start`)
    /// or the ending point (`End`) of the line, depending on the `direction` provided.
    /// The rotation is performed around the other fixed point.
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
    /// The parallel line is offset by a specified distance `offset` along a perpendicular
    /// direction.
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
