const Self = @This();
const zgui = @import("zgui");
const Context = @import("../Context.zig");

cellSize: f32 = undefined,
gridSize: f32 = undefined,

pub fn init(cellSize: f32, gridSize: f32) Self {
    return .{
        .cellSize = cellSize,
        .gridSize = gridSize,
    };
}

pub fn addCircle(_: *Self, ctx: *Context, center: [2]f32, radius: f32, color: u32) void {
    const draw_list: zgui.DrawList = zgui.getBackgroundDrawList();
    const num_segments: usize = 36;
    const center_screen: [2]f32 = ctx.camera.worldToScreen(center);

    draw_list.addCircle(.{
        .p = center_screen,
        .r = radius * ctx.camera.zoom,
        .col = color,
        .num_segments = num_segments,
        .thickness = 2.0,
    });
}

pub fn addCircleSector(_: *Self, ctx: *Context, center: [2]f32, radius: f32, color: u32, angle_start: f32, angle_end: f32, thickness: f32) void {
    const draw_list: zgui.DrawList = zgui.getBackgroundDrawList();
    const num_segments: usize = 36;
    var points: [num_segments][2]f32 = undefined;

    for (0..num_segments) |i| {
        const t = @as(f32, @floatFromInt(i)) / @as(f32, num_segments);
        const angle = angle_start + (angle_end - angle_start) * t;
        const x = center[0] + radius * @cos(angle);
        const y = center[1] + radius * @sin(angle);
        points[i] = ctx.camera.worldToScreen(.{ x, y });
    }

    draw_list.addPolyline(points[0..points.len], .{
        .col = color,
        .flags = .{},
        .thickness = thickness,
    });
}

pub fn addRect(_: *Self, ctx: *Context, pmin: [2]f32, pmax: [2]f32, color: u32, rounding: f32, thickness: f32) void {
    const draw_list: zgui.DrawList = zgui.getBackgroundDrawList();
    const screen_pmin: [2]f32 = ctx.camera.worldToScreen(pmin);
    const screen_pmax: [2]f32 = ctx.camera.worldToScreen(pmax);

    draw_list.addRect(.{
        .pmin = screen_pmin,
        .pmax = screen_pmax,
        .col = color,
        .rounding = rounding,
        .flags = .{},
        .thickness = thickness,
    });
}

pub fn addLine(_: *Self, ctx: *Context, start: [2]f32, end: [2]f32, color: u32, thickness: f32) void {
    const draw_list: zgui.DrawList = zgui.getBackgroundDrawList();
    const start_screen: [2]f32 = ctx.camera.worldToScreen(start);
    const end_screen: [2]f32 = ctx.camera.worldToScreen(end);

    draw_list.addLine(.{
        .p1 = start_screen,
        .p2 = end_screen,
        .col = color,
        .thickness = thickness,
    });
}

pub fn draw(self: *Self, ctx: *Context, thickness: f32) void {
    const draw_list: zgui.DrawList = zgui.getBackgroundDrawList();
    const color: u32 = 0xFFAAAAAA;

    for (0..@intFromFloat(self.gridSize)) |i| {
        const pos = @as(f32, @floatFromInt(i)) * self.cellSize;

        // Vertical lines
        const v1: [2]f32 = ctx.camera.worldToScreen(.{ pos, 0.0 });
        const v2: [2]f32 = ctx.camera.worldToScreen(.{ pos, self.cellSize * self.gridSize });
        draw_list.addLine(.{
            .p1 = .{ v1[0], v1[1] },
            .p2 = .{ v2[0], v2[1] },
            .col = color,
            .thickness = thickness,
        });

        // Horizontal lines
        const h1: [2]f32 = ctx.camera.worldToScreen(.{ 0.0, pos });
        const h2: [2]f32 = ctx.camera.worldToScreen(.{ self.cellSize * self.gridSize, pos });
        draw_list.addLine(.{
            .p1 = .{ h1[0], h1[1] },
            .p2 = .{ h2[0], h2[1] },
            .col = color,
            .thickness = thickness,
        });
    }
}
