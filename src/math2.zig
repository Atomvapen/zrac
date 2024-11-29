const std = @import("std");
const rl = @import("raylib");
const rg = @import("raygui");

pub const Line = struct {
    start: rl.Vector2,
    end: rl.Vector2,
};

pub fn main() !void {
    const line1_start: rl.Vector2 = rl.Vector2{ .x = 6.41e2, .y = -1.698e3 };
    const line1_end: rl.Vector2 = rl.Vector2{ .x = 3.41e2, .y = -1.998e3 };
    // const line2_start: rl.Vector2 = rl.Vector2{ .x = 4.09e2, .y = 6.5e2 };
    // const line2_end: rl.Vector2 = rl.Vector2{ .x = 1.094e3, .y = -1.607e3 };

    const parallel_line: Line = try calculate_parallel_line(line1_start.x, line1_start.y, line1_end.x, line1_end.y, 50);

    std.debug.print("{any}", .{parallel_line});
}

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
