const std = @import("std");
const rl = @import("raylib");
const rg = @import("raygui");

pub fn testIt() !void {
    const line1_start: rl.Vector2 = rl.Vector2{ .x = 6.41e2, .y = -1.698e3 };
    const line1_end: rl.Vector2 = rl.Vector2{ .x = 3.41e2, .y = -1.998e3 };
    const line2_start: rl.Vector2 = rl.Vector2{ .x = 4.09e2, .y = 6.5e2 };
    const line2_end: rl.Vector2 = rl.Vector2{ .x = 1.094e3, .y = -1.607e3 };

    const intsersectPoint: rl.Vector2 = lineIntersection(line1_start, line1_end, line2_start, line2_end) orelse rl.Vector2{ .x = -1, .y = -1 };

    std.debug.print("{any}", .{intsersectPoint});
}

pub fn lineIntersection(line1_start: rl.Vector2, line1_end: rl.Vector2, line2_start: rl.Vector2, line2_end: rl.Vector2) ?rl.Vector2 {
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
