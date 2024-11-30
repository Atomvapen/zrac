const std = @import("std");
const gui = @import("gui.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    try gui.init();
    defer gui.deinit();

    try gui.main(allocator);
}
