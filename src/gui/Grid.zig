const Self = @This();
const zgui = @import("zgui");
const Context = @import("../Context.zig");

const cellSize: f32 = 40.0;
const gridSize: usize = 100;

pub fn addCircleSector(_: *Self, ctx: *Context, cx: f32, cy: f32, radius: f32, color: u32, angle_start: f32, angle_end: f32) void {
    const draw_list: zgui.DrawList = zgui.getBackgroundDrawList();
    const num_segments: usize = 36;

    var points: [num_segments][2]f32 = undefined;
    var point_count: usize = 0;

    for (0..num_segments) |i| {
        const t = @as(f32, @floatFromInt(i)) / @as(f32, num_segments);
        const angle = angle_start + (angle_end - angle_start) * t;

        const x = cx + radius * @cos(angle);
        const y = cy + radius * @sin(angle);

        points[point_count] = .{ x, y };
        point_count += 1;
    }

    var screen_points: [num_segments][2]f32 = undefined;
    for (0..point_count) |i| {
        screen_points[i] = ctx.camera.worldToScreen(points[i]);
    }

    draw_list.addPolyline(screen_points[0..point_count], .{
        .col = color,
        .flags = .{},
        .thickness = 2.0,
    });
}

pub fn addRect(_: *Self, ctx: *Context, x1: f32, y1: f32, x2: f32, y2: f32, color: u32, rounding: f32, thickness: f32) void {
    const draw_list: zgui.DrawList = zgui.getBackgroundDrawList();

    const screen_pmin: [2]f32 = ctx.camera.worldToScreen(.{ x1, y1 });
    const screen_pmax: [2]f32 = ctx.camera.worldToScreen(.{ x2, y2 });

    draw_list.addRect(.{
        .pmin = .{ screen_pmin[0], screen_pmin[1] },
        .pmax = .{ screen_pmax[0], screen_pmax[1] },
        .col = color,
        .rounding = rounding,
        .flags = .{},
        .thickness = thickness,
    });
}

pub fn addLine(_: *Self, ctx: *Context, x1: f32, y1: f32, x2: f32, y2: f32, color: u32) void {
    const draw_list: zgui.DrawList = zgui.getBackgroundDrawList();

    const start: [2]f32 = ctx.camera.worldToScreen(.{ x1, y1 });
    const end: [2]f32 = ctx.camera.worldToScreen(.{ x2, y2 });

    draw_list.addLine(.{
        .p1 = .{ start[0], start[1] },
        .p2 = .{ end[0], end[1] },
        .col = color,
        .thickness = 2.0,
    });
}

pub fn addCircle(_: *Self, ctx: *Context, cx: f32, cy: f32, radius: f32, color: u32) void {
    const draw_list: zgui.DrawList = zgui.getBackgroundDrawList();
    const num_segments: usize = 36;

    const center: [2]f32 = ctx.camera.worldToScreen(.{ cx, cy });

    draw_list.addCircle(.{
        .p = .{ center[0], center[1] },
        .r = radius * ctx.camera.zoom,
        .col = color,
        .num_segments = num_segments,
        .thickness = 2.0,
    });
}

pub fn draw(_: *Self, ctx: *Context) void {
    const draw_list: zgui.DrawList = zgui.getBackgroundDrawList();
    const color: u32 = 0xFFAAAAAA;

    for (0..gridSize) |i| {
        const pos = @as(f32, @floatFromInt(i)) * cellSize;

        // Vertical lines
        const v1: [2]f32 = ctx.camera.worldToScreen(.{ pos, 0.0 });
        const v2: [2]f32 = ctx.camera.worldToScreen(.{ pos, cellSize * gridSize });

        draw_list.addLine(.{
            .p1 = .{ v1[0], v1[1] },
            .p2 = .{ v2[0], v2[1] },
            .col = color,
            .thickness = 1.0,
        });

        // Horizontal lines
        const h1: [2]f32 = ctx.camera.worldToScreen(.{ 0.0, pos });
        const h2: [2]f32 = ctx.camera.worldToScreen(.{ cellSize * gridSize, pos });

        draw_list.addLine(.{
            .p1 = .{ h1[0], h1[1] },
            .p2 = .{ h2[0], h2[1] },
            .col = color,
            .thickness = 1.0,
        });
    }
}
