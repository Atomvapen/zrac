const std = @import("std");
const gui = @import("gui.zig");
// const rl = @import("raylib");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    _ = allocator;

    try gui.init();
    defer gui.deinit();

    try gui.main();

    // const test2 = @import("math2.zig");

    // try test2.main();
}
