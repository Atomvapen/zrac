const std = @import("std");
const reg = @import("reg");
const renderer = reg.gui.renderer;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    try renderer.main(allocator);
}
