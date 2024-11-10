const std = @import("std");
const risk = @import("risk.zig");
const draw = @import("draw.zig");

const print = std.debug.print;

fn fatal(comptime format: []const u8, args: anytype) noreturn {
    var gpa_allocator = std.heap.GeneralPurposeAllocator(.{}){};
    const msg = std.fmt.allocPrint(gpa_allocator.allocator(), "Fatal: " ++ format ++ "\n", args) catch std.process.exit(1);
    defer gpa_allocator.allocator().free(msg);
    std.io.getStdErr().writeAll(msg) catch std.process.exit(1);
    std.process.exit(1);
}

pub fn askBool(prompt: []const u8) !bool {
    const stdin = std.io.getStdIn();
    var buffer: [64]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const allocator = fba.allocator();

    while (true) : (print("Invalid boolean input. Please use y/n. \n", .{})) {
        print("{s}: ", .{prompt});

        const read = try stdin.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', 64) orelse continue;
        defer allocator.free(read);

        if (read.len == 0) return error.EndOfStream; // Handle end of stream

        switch (buffer[0]) {
            'y', 'Y' => return true,
            'n', 'N' => return false,
            else => continue,
        }
    }
}

pub fn askInteger(prompt: []const u8) !i32 {
    const stdin = std.io.getStdIn();
    var buffer: [256]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const allocator = fba.allocator();

    while (true) : (print("Invalid integer input. Please enter a valid integer.\n", .{})) {
        print("{s}: ", .{prompt});

        const read = try stdin.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', 256) orelse continue;
        defer allocator.free(read);
        if (read.len == 0) return error.EndOfStream; // Handle end of stream

        // Trim the input and check if it's empty
        const trimmed = std.mem.trim(u8, read, " \r\n");
        if (trimmed.len == 0) continue; // If input is empty, continue the loop

        // Try to parse the integer
        const value = std.fmt.parseInt(i32, trimmed, 10) catch continue; // Try to parse the integer

        return value; // Return the parsed integer
    }
}

pub fn main() !void {
    var riskProfile: risk.RiskArea = undefined;
    riskProfile.factor = 1;
    riskProfile.Amax = 100;
    riskProfile.Dmax = 150;
    riskProfile.f = 10;
    riskProfile.v = 100;
    // riskProfile.inForest = true;

    // riskProfile.h = try askInteger("h");

    // riskProfile.factor = try askInteger("Riskfaktor");
    // riskProfile.Amax = try askInteger("Amax");
    // riskProfile.Amin = try askInteger("Amin");
    // riskProfile.Dmax = try askInteger("Dmax");
    // riskProfile.f = try askInteger("f");
    // riskProfile.inForest = try askBool("I skog?");
    // if (!riskProfile.inForest) {
    //     riskProfile.forestMin = try askInteger("Avstånd till skog (0 vid ingen skog)");
    // }
    // riskProfile.PV = try askBool("PV?");
    // riskProfile.v = try askInteger("Vinkel V");

    riskProfile.l = risk.calculateL(riskProfile.factor, riskProfile.Dmax, riskProfile.Amax);
    riskProfile.h = risk.calculateH(riskProfile.Amax, riskProfile.l);
    // riskProfile.c = risk.calculateC(riskProfile.factor, riskProfile.Dmax, riskProfile.Amin, riskProfile.inForest);

    // print("{s:-<60}\n", .{""});
    // print("RF: {d} \n", .{riskProfile.factor});
    // print("V: {d} \n", .{riskProfile.v});
    // print("l: {d} \n", .{riskProfile.l});
    // print("h: {d} \n", .{riskProfile.h});
    // print("c: {d} \n", .{riskProfile.c});
    // print("inForest: {s} \n", .{if (riskProfile.inForest) "true" else "false"});

    try draw.draw(riskProfile);
}
