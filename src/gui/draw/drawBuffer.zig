const std = @import("std");
const rl = @import("raylib");

pub const DrawBuffer = struct {
    const Type = enum {
        Line,
        Semicircle,
        Text,
    };
    pub const BufferItem = struct {
        type: Type,
        buffer: []const rl.Vector2,
        color: rl.Color,

        pub fn init(sort: Type, items: []const rl.Vector2, color: rl.Color) !BufferItem {
            return BufferItem{
                .type = sort,
                .buffer = items,
                .color = color,
            };
        }
    };

    buffer: std.ArrayList(BufferItem),

    pub fn init(allocator: std.mem.Allocator) DrawBuffer {
        return DrawBuffer{
            .buffer = std.ArrayList(BufferItem).init(allocator),
        };
    }

    pub fn deinit(self: *DrawBuffer) void {
        self.buffer.deinit();
    }

    pub fn append(self: *DrawBuffer, item: BufferItem) !void {
        try self.buffer.append(item);
    }

    pub fn execute(self: *DrawBuffer) !void {
        if (self.buffer.items.len < 2) return;

        for (self.buffer.items) |item| {
            switch (item.type) {
                .Line, .Semicircle => {
                    rl.gl.rlBegin(rl.gl.rl_lines);

                    for (0..item.buffer.len - 1) |i| {
                        rl.gl.rlColor4ub(item.color.r, item.color.g, item.color.b, item.color.a);
                        rl.gl.rlVertex2f(item.buffer[i].x, item.buffer[i].y);
                        rl.gl.rlVertex2f(item.buffer[i + 1].x, item.buffer[i + 1].y);
                    }

                    rl.gl.rlEnd();
                },
                .Text => continue,
            }
        }
    }
};
