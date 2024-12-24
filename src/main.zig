const std = @import("std");
const renderer = @import("gui/renderer.zig");

// pub const std_options = std.Options{
//     .log_level = .debug,
// };

pub fn main() !void {
    // var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // defer _ = gpa.deinit();

    // const allocator = gpa.allocator();

    try renderer.main();
}
