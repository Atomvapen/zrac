const Self = @This();

const std = @import("std");
const rl = @import("raylib");
const geo = @import("../math/geo.zig");
const vec = @import("../math/vector.zig");

const Command = union(Tag) {
    const Tag = enum(u8) { Line, Semicircle, Text };

    const SemiCommand = struct {
        const InitArgs = struct {
            color: rl.Color,
            startAngle: f32,
            endAngle: f32,
            radius: f32,
            center: vec.Vec2f,
            segments: i32,
        };

        color: rl.Color,
        startAngle: f32,
        endAngle: f32,
        radius: f32,
        center: vec.Vec2f,
        segments: i32,

        pub fn render(self: *const SemiCommand) void {
            rl.drawRingLines(
                .{ .x = self.center[0], .y = self.center[1] },
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
        const InitArgs = struct {
            color: rl.Color,
            start: vec.Vec2f,
            end: vec.Vec2f,
        };

        color: rl.Color,
        start: vec.Vec2f,
        end: vec.Vec2f,

        pub fn render(self: *const LineCommand) void {
            rl.drawLineV(.{ .x = self.start[0], .y = self.start[1] }, .{ .x = self.end[0], .y = self.end[1] }, self.color);
        }
    };

    const TextCommand = struct {
        const InitArgs = struct {
            text: [:0]const u8,
            textOffsetX: i32,
            textOffsetY: i32,
            fontSize: i32,
            color: rl.Color,
            pos: vec.Vec2f,
            show: bool,
        };

        text: [:0]const u8,
        textOffsetX: i32,
        textOffsetY: i32,
        fontSize: i32,
        color: rl.Color,
        pos: vec.Vec2f,
        show: bool,

        pub fn render(self: *const TextCommand) void {
            if (!self.show) return;

            rl.drawText(
                self.text,
                @as(i32, @intFromFloat(self.pos[0])) + self.textOffsetX,
                @as(i32, @intFromFloat(self.pos[1])) + self.textOffsetY,
                self.fontSize,
                self.color,
            );
        }
    };

    Line: LineCommand,
    Semicircle: SemiCommand,
    Text: TextCommand,

    pub fn create(comptime tag: Tag, args: @typeInfo(Command).@"union".fields[@intFromEnum(tag)].type.InitArgs) Command {
        const PayloadType = @typeInfo(Command).@"union".fields[@intFromEnum(tag)].type;
        const field_names: []const std.builtin.Type.StructField = @typeInfo(PayloadType).@"struct".fields;
        var payload: PayloadType = undefined;
        inline for (field_names) |field| @field(payload, field.name) = @field(args, field.name);
        return @unionInit(Command, @tagName(tag), payload);
    }

    pub fn render(self: Command) void {
        switch (self) {
            inline else => |c| if (@hasDecl(@TypeOf(c), "render")) c.render(),
        }
    }
};

buffer: std.ArrayList(Command),

pub fn init(allocator: std.mem.Allocator) Self {
    return Self{ .buffer = std.ArrayList(Command).init(allocator) };
}

pub fn deinit(self: *Self) void {
    self.buffer.deinit();
}

pub fn append(self: *Self, item: geo.Shape) !void {
    const drawResult: Command = switch (item) {
        .Line => |line| Command.create(.Line, .{ .start = line.start, .end = line.end, .color = rl.Color.red }),
        .Semicircle => |semi| Command.create(.Semicircle, .{ .color = semi.color, .startAngle = semi.startAngle, .endAngle = semi.endAngle, .radius = semi.radius, .center = semi.center, .segments = semi.segments }),
        .Point => |point| Command.create(.Text, .{ .text = point.text.text, .textOffsetX = point.text.textOffsetX, .textOffsetY = point.text.textOffsetY, .fontSize = point.text.fontSize, .color = point.text.color, .pos = point.text.pos, .show = point.text.init == true and point.text.show == true }),
    };

    // const textResult: Command = switch (item) {
    //     .Line => |line| Command{ .Text = Self.Command.create(.Text).init(line.text.text, line.text.textOffsetX, line.text.textOffsetY, line.text.fontSize, line.text.color, line.text.pos, line.text.init == true and line.text.show == true) },
    //     // .Point => |point| Command{ .Text = Self.Command.create(.Text).init(point.text.text, point.text.textOffsetX, point.text.textOffsetY, point.text.fontSize, point.text.color, point.text.pos, point.text.init == true and point.text.show == true) },
    //     .Semicircle => |semi| Command{ .Text = Self.Command.create(.Text).init(semi.text.text, semi.text.textOffsetX, semi.text.textOffsetY, semi.text.fontSize, semi.text.color, semi.text.pos, semi.text.init == true and semi.text.show == true) },
    //     else => {
    //         return;
    //     },
    // };

    try self.buffer.append(drawResult);
    errdefer self.buffer.resize(self.buffer.items.len - 1) catch {};

    // try self.buffer.append(textResult);
    // errdefer self.buffer.resize(self.buffer.items.len - 1) catch {};
}

pub fn clearAndFree(self: *Self) void {
    self.buffer.clearAndFree();
}

pub fn clear(self: *Self) !void {
    try self.buffer.resize(0);
}

pub fn execute(self: *Self) void {
    if (self.buffer.items.len == 0) return;

    for (self.buffer.items) |item| {
        item.render();
    }
}
