const std = @import("std");
const reg = @import("reg");
const renderer = reg.gui.renderer;
const Context = reg.data.Context;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var ctx: Context = Context.create(allocator);
    defer ctx.destroy();

    ctx.window.init();
    defer ctx.window.deinit();
    ctx.window.setProperties(&ctx);
    ctx.window.style();

    try renderer.main(&ctx);
}
