const std = @import("std");
const gui = @import("gui.zig");

pub const std_options = std.Options{
    .log_level = .debug,
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    try gui.init();
    defer gui.deinit();

    try gui.main(allocator);
}
