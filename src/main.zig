const std = @import("std");
const zstbi = @import("zstbi");
const zglfw = @import("zglfw");

const renderer = @import("renderer.zig");
const Context = @import("Context.zig");

var gpa: std.heap.DebugAllocator(.{}) = std.heap.DebugAllocator(.{}).init;
pub const allocator: std.mem.Allocator = gpa.allocator();
// pub const allocator: std.mem.Allocator = std.heap.c_allocator;

pub fn main() !void {
    zstbi.init(allocator);
    defer zstbi.deinit();

    try zglfw.init();
    defer zglfw.terminate();

    var ctx: *Context = try Context.create(allocator);
    defer ctx.destroy(allocator);

    _ = zglfw.setScrollCallback(ctx.window, renderer.Camera2D.onScroll);

    while (!ctx.window.shouldClose() and ctx.window.getKey(.escape) != .press) {
        renderer.update(ctx);
        renderer.draw(ctx);
    }
}
