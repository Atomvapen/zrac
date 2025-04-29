const std = @import("std");
const reg = @import("reg");
const json = reg.data.json;

pub fn save() void {
    std.debug.print("Save\n", .{});
}
pub fn load() void {
    std.debug.print("Load\n", .{});
}
