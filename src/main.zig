const gui = @import("gui.zig");
// const rl = @import("raylib");

pub fn main() !void {
    try gui.init();
    defer gui.deinit();

    // while (!rl.windowShouldClose()) {
    try gui.main();
    // }
}
