//! DrawBuffer
//!
//! Managing and executing draw-commands using raylib.

const std = @import("std");
const rl = @import("raylib");

pub const DrawBuffer = struct {
    pub const Command = union(CommandType) {
        const CommandType = enum {
            Line,
            Semicircle,
            Text,
        };

        const SemiCommand = struct {
            points: []const rl.Vector2,
            color: rl.Color,

            pub fn init(items: []const rl.Vector2, color: rl.Color) SemiCommand {
                return SemiCommand{
                    .points = items,
                    .color = color,
                };
            }

            pub fn draw(self: *const SemiCommand) void {
                rl.gl.rlBegin(rl.gl.rl_lines);
                defer rl.gl.rlEnd();

                for (0..self.points.len - 1) |i| {
                    rl.gl.rlColor4ub(self.color.r, self.color.g, self.color.b, self.color.a);
                    rl.gl.rlVertex2f(self.points[i].x, self.points[i].y);
                    rl.gl.rlVertex2f(self.points[i + 1].x, self.points[i + 1].y);
                }
            }
        };

        const LineCommand = struct {
            points: []const rl.Vector2,
            color: rl.Color,

            pub fn init(points: []const rl.Vector2, color: rl.Color) LineCommand {
                return LineCommand{
                    .points = points,
                    .color = color,
                };
            }

            pub fn draw(self: *const LineCommand) void {
                rl.gl.rlBegin(rl.gl.rl_lines);
                defer rl.gl.rlEnd();

                for (0..self.points.len - 1) |i| {
                    rl.gl.rlColor4ub(self.color.r, self.color.g, self.color.b, self.color.a);
                    rl.gl.rlVertex2f(self.points[i].x, self.points[i].y);
                    rl.gl.rlVertex2f(self.points[i + 1].x, self.points[i + 1].y);
                }
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

        pub fn create(comptime sort: CommandType) type {
            return switch (sort) {
                .Line => LineCommand,
                .Semicircle => SemiCommand,
                .Text => TextCommand,
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
            }
        }
    }
};
