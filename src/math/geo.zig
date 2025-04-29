const std = @import("std");
const rl = @import("raylib");
const trig = @import("trig.zig");
const DrawBuffer = @import("../gui/DrawBuffer.zig");
const vec = @import("vector.zig");

pub const Shape = union(Tag) {
    const Tag = enum(u8) { Point, Semicircle, Line };
    Point: Point,
    Semicircle: Semicircle,
    Line: Line,
};

pub const Point = struct {
    pos: vec.Vec2f,
    text: struct { show: bool = false, init: bool = false, text: [:0]const u8, textOffsetX: i32, textOffsetY: i32, fontSize: i32, color: rl.Color, pos: vec.Vec2f } = undefined,

    /// Initiates a Point
    pub fn init(pos: vec.Vec2f) Point {
        return Point{ .pos = pos };
    }

    /// Add text-command
    pub fn addText(self: *Point, text: [:0]const u8, textOffsetX: i32, textOffsetY: i32, fontSize: i32, color: rl.Color, show: bool) void {
        self.text = .{ .show = show, .init = true, .text = text, .textOffsetX = textOffsetX, .textOffsetY = textOffsetY, .fontSize = fontSize, .color = color, .pos = self.pos };
    }

    /// Rotates a `Point` around the other Point by the specified angle in mils.
    ///
    /// This function modifies the position of the  point
    /// The rotation is performed around the other fixed point.
    pub fn rotate(self: *Point, point: vec.Vec2f, angle: f32) void {
        const rad = trig.convertAngle(angle, .Mils, .Radians);
        if (rad == 0) return;

        const cosAngle = @cos(rad);
        const sinAngle = @sin(rad);

        const dx = self.pos[0] - point[0];
        const dy = self.pos[1] - point[1];

        self.pos[0] = (dx * cosAngle) - (dy * sinAngle) + point[0];
        self.pos[1] = (dx * sinAngle) + (dy * cosAngle) + point[1];
    }
};

pub const Semicircle = struct {
    color: rl.Color,
    startAngle: f32,
    endAngle: f32,
    radius: f32,
    center: vec.Vec2f,
    segments: i32,
    text: struct { show: bool = false, init: bool = false, text: [*:0]const u8, textOffsetX: i32, textOffsetY: i32, fontSize: i32, color: rl.Color, pos: vec.Vec2f } = undefined,

    /// Initiates a Semicircle
    pub fn init(color: rl.Color, startAngle: f32, endAngle: f32, radius: f32, center: vec.Vec2f, segments: i32) Semicircle {
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
};

pub const Line = struct {
    start: vec.Vec2f,
    end: vec.Vec2f,
    text: struct { show: bool = false, init: bool = false, text: [*:0]const u8, textOffsetX: i32, textOffsetY: i32, fontSize: i32, color: rl.Color, pos: vec.Vec2f } = undefined,

    /// Initiates a Line
    pub fn init(start: vec.Vec2f, end: vec.Vec2f) Line {
        return Line{ .start = start, .end = end };
    }

    /// Add text-command
    pub fn addText(self: *Line, text: [*:0]const u8, textOffsetX: i32, textOffsetY: i32, fontSize: i32, color: rl.Color, pos: vec.Vec2f, show: bool) void {
        self.text = .{ .show = show, .init = true, .text = text, .textOffsetX = textOffsetX, .textOffsetY = textOffsetY, .fontSize = fontSize, .color = color, .pos = pos };
    }

    /// Rotates one endpoint of a `Line` around the other by the specified angle in mils.
    ///
    /// This function modifies the position of either the starting point (`Start`)
    /// or the ending point (`End`) of the line, depending on the `direction` provided.
    /// The rotation is performed around the other fixed point.
    pub fn rotate(self: *Line, direction: enum { End, Start }, angle: f32) void {
        const rad = trig.convertAngle(angle, .Mils, .Radians);
        if (rad == 0) return;

        const cosAngle = @cos(rad);
        const sinAngle = @sin(rad);

        switch (direction) {
            .End => {
                const dx = self.end[0] - self.start[0];
                const dy = self.end[1] - self.start[1];

                self.end[0] = (dx * cosAngle) - (dy * sinAngle) + self.start[0];
                self.end[1] = (dx * sinAngle) + (dy * cosAngle) + self.start[1];
            },
            .Start => {
                const dx = self.start[0] - self.end[0];
                const dy = self.start[1] - self.end[1];

                self.start[0] = (dx * cosAngle) - (dy * sinAngle) + self.end[0];
                self.start[1] = (dx * sinAngle) + (dy * cosAngle) + self.end[1];
            },
        }
    }

    /// Calculates the intersection point of two line segments, if it exists.
    ///
    /// The function determines the point where two lines intersect, based on their
    /// start and end coordinates. If the lines are parallel and do not intersect,
    /// it returns `null`.
    pub fn getIntersectionPoint(self: *Line, line: Line) ?vec.Vec2f {
        // Self points
        const line1_start_x: f32 = self.start[0];
        const line1_start_y: f32 = self.start[1];
        const line1_end_x: f32 = self.end[0];
        const line1_end_y: f32 = self.end[1];

        // Other line points
        const line2_start_x: f32 = line.start[0];
        const line2_start_y: f32 = line.start[1];
        const line2_end_x: f32 = line.end[0];
        const line2_end_y: f32 = line.end[1];

        // Denominator for the intersection calculation
        const denominator = (line1_start_x - line1_end_x) * (line2_start_y - line2_end_y) - (line1_start_y - line1_end_y) * (line2_start_x - line2_end_x);
        if (denominator == 0) return null;

        // Parameter t for intersection calculation
        const t = ((line1_start_x - line2_start_x) * (line2_start_y - line2_end_y) - (line1_start_y - line2_start_y) * (line2_start_x - line2_end_x)) / denominator;

        // Intersection point
        const intersection_x = line1_start_x + t * (line1_end_x - line1_start_x);
        const intersection_y = line1_start_y + t * (line1_end_y - line1_start_y);

        return .{ intersection_x, intersection_y };
    }

    /// Calculates a line parallel to the given line at a specified distance.
    ///
    /// This function computes the coordinates of a line parallel to the input line.
    /// The parallel line is offset by a specified distance `offset` along a perpendicular
    /// direction.
    pub fn getParallelLine(self: *Line, offset: f32) !Line {
        const start_x: f32 = self.start[0];
        const start_y: f32 = self.start[1];
        const end_x: f32 = self.end[0];
        const end_y: f32 = self.end[1];

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
        return Line{ .start = .{ x1_parallel, y1_parallel }, .end = .{ x2_parallel, y2_parallel } };
    }
};
