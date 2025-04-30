const std = @import("std");
const rl = @import("raylib");
const zgui = @import("zgui");
const Context = @import("Context.zig");
const Renderer = @import("renderer.zig");
const zglfw = @import("zglfw");

var gpa: std.heap.DebugAllocator(.{}) = std.heap.DebugAllocator(.{}).init;
pub const allocator: std.mem.Allocator = gpa.allocator();
// pub const allocator: std.mem.Allocator = std.heap.c_allocator;

pub fn main() !void {
    var ctx: *Context = try Context.create(allocator);
    defer ctx.destroy(allocator);

    zgui.rlimgui.setup(true);
    defer zgui.rlimgui.shutdown();

    while (!rl.windowShouldClose() and ctx.window.quit != true) {
        ctx.update();
        ctx.window.update();

        rl.beginDrawing();
        defer rl.endDrawing();

        zgui.rlimgui.begin();
        defer zgui.rlimgui.end();

        try Renderer.render(ctx);
    }
}
