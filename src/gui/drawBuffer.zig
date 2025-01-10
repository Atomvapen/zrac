const std = @import("std");
const rl = @import("raylib");
const reg = @import("reg");
const geo = reg.math.geometry;
const DrawBuffer = @This();

pub const Command = union(CommandType) {
    const CommandType = enum {
        Line,
        Semicircle,
        Text,
        PolyLine,
    };

    const SemiCommand = struct {
        color: rl.Color,
        startAngle: f32,
        endAngle: f32,
        radius: f32,
        center: rl.Vector2,
        segments: i32,

        pub fn init(color: rl.Color, startAngle: f32, endAngle: f32, radius: f32, center: rl.Vector2, segments: i32) SemiCommand {
            return SemiCommand{ .color = color, .startAngle = startAngle, .endAngle = endAngle, .radius = radius, .center = center, .segments = segments };
        }

        pub fn draw(self: *const SemiCommand) void {
            rl.drawRingLines(
                .{ .x = self.center.x, .y = self.center.y },
                self.radius,
                self.radius,
                self.startAngle,
                self.endAngle,
                self.segments,
                self.color,
            );
        }
    };

    const LineCommand = struct {
        color: rl.Color,
        start: rl.Vector2 = undefined,
        end: rl.Vector2 = undefined,

        pub fn init(start: rl.Vector2, end: rl.Vector2, color: rl.Color) LineCommand {
            return LineCommand{
                .start = start,
                .end = end,
                .color = color,
            };
        }

        pub fn draw(self: *const LineCommand) void {
            rl.drawLineV(self.start, self.end, self.color);
        }
    };

    const PolyLineCommand = struct {
        color: rl.Color,
        points: []const rl.Vector2 = undefined,

        pub fn init(points: []const rl.Vector2, color: rl.Color) PolyLineCommand {
            return PolyLineCommand{
                .points = points,
                .color = color,
            };
        }

        pub fn draw(self: *const PolyLineCommand) void {
            if (self.points.len < 2) return;

            rl.gl.rlBegin(rl.gl.rl_lines);

            for (0..self.points.len - 1) |i| {
                rl.gl.rlColor4ub(self.color.r, self.color.g, self.color.b, self.color.a);
                rl.gl.rlVertex2f(self.points[i].x, self.points[i].y);
                rl.gl.rlVertex2f(self.points[i + 1].x, self.points[i + 1].y);
            }

            rl.gl.rlEnd();
        }
    };

    const TextCommand = struct {
        text: [*:0]const u8,
        textOffsetX: i32,
        textOffsetY: i32,
        fontSize: i32,
        color: rl.Color,
        pos: rl.Vector2,

        pub fn init(text: [*:0]const u8, textOffsetX: i32, textOffsetY: i32, fontSize: i32, color: rl.Color, pos: rl.Vector2) TextCommand {
            return TextCommand{
                .text = text,
                .textOffsetX = textOffsetX,
                .textOffsetY = textOffsetY,
                .fontSize = fontSize,
                .color = color,
                .pos = pos,
            };
        }

        pub fn draw(self: *const TextCommand) void {
            rl.drawText(
                self.text,
                @as(i32, @intFromFloat(self.pos.x)) + self.textOffsetX,
                @as(i32, @intFromFloat(self.pos.y)) + self.textOffsetY,
                self.fontSize,
                self.color,
            );
        }
    };

    Line: LineCommand,
    Semicircle: SemiCommand,
    Text: TextCommand,
    PolyLine: PolyLineCommand,

    pub fn create(comptime sort: CommandType) type {
        return switch (sort) {
            .Line => LineCommand,
            .Semicircle => SemiCommand,
            .Text => TextCommand,
            .PolyLine => PolyLineCommand,
        };
    }
};

buffer: std.ArrayList(Command),

pub fn init(allocator: std.mem.Allocator) DrawBuffer {
    return DrawBuffer{ .buffer = std.ArrayList(Command).init(allocator) };
}

pub fn deinit(self: *DrawBuffer) void {
    self.buffer.deinit();
}

pub fn append(self: *DrawBuffer, item: Command) !void {
    try self.buffer.append(item);
}

pub fn append2(self: *DrawBuffer, item: geo.Shape) !void {
    switch (item) {
        .Line => |line| {
            const result: Command = Command{ .Line = DrawBuffer.Command.create(.Line).init(line.start, line.end, rl.Color.red) };
            try self.buffer.append(result);

            if (line.text.init == true and line.text.show == true) {
                const result2: Command = Command{ .Text = DrawBuffer.Command.create(.Text).init(line.text.text, line.text.textOffsetX, line.text.textOffsetY, line.text.fontSize, line.text.color, line.text.pos) };
                try self.buffer.append(result2);
            }
        },

        .Point => |point| {
            if (point.text.init == true and point.text.show == true) {
                const result2: Command = Command{ .Text = DrawBuffer.Command.create(.Text).init(point.text.text, point.text.textOffsetX, point.text.textOffsetY, point.text.fontSize, point.text.color, point.text.pos) };
                try self.buffer.append(result2);
            }
        },
        .Semicircle => |semi| {
            const result: Command = Command{ .Semicircle = DrawBuffer.Command.create(.Semicircle).init(semi.color, semi.startAngle, semi.endAngle, semi.radius, semi.center, semi.segments) };
            try self.buffer.append(result);
        },
    }
}

pub fn clearAndFree(self: *DrawBuffer) void {
    self.buffer.clearAndFree();
}

pub fn clear(self: *DrawBuffer) !void {
    try self.buffer.resize(0);
}

pub fn execute(self: *DrawBuffer) !void {
    for (self.buffer.items) |item| {
        switch (item) {
            .Line => |line| line.draw(),
            .Semicircle => |semi| semi.draw(),
            .Text => |text| text.draw(),
            .PolyLine => |line| line.draw(),
        }
    }
}
