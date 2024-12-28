const renderer = @import("gui/renderer.zig");

pub fn main() !void {
    try renderer.main();
    // try @import("gui/draw2.zig").main();
}
