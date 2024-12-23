// const std = @import("std");
// const math = std.math;

// pub fn main() !void {
//     const points = try semicirclePoints(5.0, 5.0, 10.0, 5.0, 8);
//     for (points) |pt| {
//         std.debug.print("Point: ({}, {})\n", .{ pt.x, pt.y });
//     }
// }

// fn semicirclePoints(x1: f64, y1: f64, x2: f64, y2: f64, n: usize) ![]const Point {
//     const allocator = std.heap.page_allocator;

//     const dx = x2 - x1;
//     const dy = y2 - y1;
//     const distance = math.sqrt(dx * dx + dy * dy);

//     // Midpoint of the line segment
//     const mx = (x1 + x2) / 2.0;
//     const my = (y1 + y2) / 2.0;

//     // Normal vector to the line segment
//     const nx = -dy / distance;
//     const ny = dx / distance;

//     // Center of the semicircle
//     const cx = mx + nx * distance / 2.0;
//     const cy = my + ny * distance / 2.0;

//     // Allocate space for n points
//     var points = try allocator.alloc(Point, n);
//     const angleStep = 2.0 * std.math.pi / @as(f64, @floatFromInt(n));

//     for (0..n) |i| {
//         const angle = angleStep * @as(f64, @floatFromInt(i));
//         const px = cx + (x1 - cx) * math.cos(angle) + (y1 - cy) * math.sin(angle);
//         const py = cy + (y1 - cy) * math.cos(angle) - (x1 - cx) * math.sin(angle);
//         points[i] = Point{ .x = px, .y = py };
//     }

//     return points;
// }

// const Point = struct {
//     x: f64,
//     y: f64,
// };
const std = @import("std");

pub fn main() !void {
    const origin = Point{ .x = 5.0, .y = 5.0 };
    const radius = 70.0;
    const startAngle = 0.0; // Starting angle in radians
    const endAngle = std.math.pi / 2.0; // Ending angle (90 degrees in radians)
    const n = 200; // Number of points to generate
    const xMin = 5.0;
    const xMax = 10.0;

    const points = try generatePoints(origin, radius, startAngle, endAngle, n, xMin, xMax);
    for (points) |point| {
        std.debug.print("Point: ({}, {})\n", .{ point.x, point.y });
    }
}

const Point = struct {
    x: f64,
    y: f64,
};

fn generatePoints(
    origin: Point,
    radius: f64,
    startAngle: f64,
    endAngle: f64,
    n: usize,
    xMin: f64,
    xMax: f64,
) ![]Point {
    var allocator = std.heap.page_allocator;
    var result = try allocator.alloc(Point, n);

    var index: usize = 0;
    const angleStep = (endAngle - startAngle) / (@as(f64, @floatFromInt(n)) - 1);
    for (0..n) |i| {
        const angle = startAngle + @as(f64, @floatFromInt(i)) * angleStep;
        const x = origin.x + radius * std.math.cos(angle);
        const y = origin.y + radius * std.math.sin(angle);

        if (x >= xMin and x <= xMax) {
            result[index] = Point{ .x = x, .y = y };
            index += 1;
        }
    }

    // Resize result array to only include valid points
    return result[0..index];
}
