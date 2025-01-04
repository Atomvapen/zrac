const std = @import("std");
const json = @import("json.zig");

pub fn save() void {
    std.debug.print("Save\n", .{});
}
pub fn load() void {
    std.debug.print("Load\n", .{});
}
