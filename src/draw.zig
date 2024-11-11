const std = @import("std");
const risk = @import("risk.zig");
const rl = @import("raylib");
const rg = @import("raylib-zig/lib/raygui.zig");

const screenWidth = 800;
const screenHeight: i32 = 800;
const textOffsetY = 20;
const textOffsetX = 5;

pub fn draw(riskProfile: risk.RiskArea) !void {
    rl.initWindow(screenWidth, screenHeight, "Risk");
    defer rl.closeWindow(); // Close window and OpenGL context
    rl.setTargetFPS(60);
    // var t: [32]u8 = "Initial text"; // Initialize the buffer with a default value
    // var b: bool = false; // Initialize the boolean variable
    var inForest: bool = undefined;
    var val: i32 = 0;
    // var selectedWeapon: i32 = undefined;

    // const items: [3][*:0]const u8 = .{ "Item 1", "Item 2", "Item 3" }; // Array of string slices
    // var selectedItem: i32 = 0; // Variable to hold the selected item index

    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);
        rl.drawRectangle(0, 0, 200, screenHeight, rl.Color.white);

        // Input fields
        if (rg.guiButton(.{ .x = 10, .y = 10, .width = 100, .height = 50 }, "Beräkna") == 1) {
            std.debug.print("{s} \n", .{"Beräkna"});
            std.debug.print("{any} \n", .{inForest});
            std.debug.print("{d} \n", .{val});
        }
        _ = rg.guiCheckBox(.{ .x = 10, .y = 10 + 50 + 10, .width = 25, .height = 25 }, "I skog", &inForest);
        _ = rg.guiValueBox(.{ .x = 10, .y = 10 + 50 + 10 + 50 + 10 + 50, .width = 50, .height = 25 }, "Val", &val, 0, 100, true);

        // Lines
        drawLines(riskProfile);

        // std.debug.print("h: {any}.\n", .{riskProfile.h});
        // std.debug.print("x: {any}.\n", .{x});
        // std.debug.print("x*: {any}.\n", .{@cos(risk.milsToRadians(riskProfile.v))});
        // std.debug.print("y*: {any}.\n", .{@sin(risk.milsToRadians(riskProfile.v))});
    }
}

pub fn drawLines(riskProfile: risk.RiskArea) void {
    // Origin
    const oX: i32 = screenWidth / 2;
    const oY: i32 = screenHeight - 50;

    // h
    const hX: i32 = oX;
    const hY: i32 = screenHeight - riskProfile.h;

    rl.drawText("h", hX - textOffsetX, hY - textOffsetY, 13, rl.Color.white);
    rl.drawLine(oX, oY, hX, hY, rl.Color.red);

    // Amin
    const AminX: i32 = oX;
    const AminY: i32 = screenHeight - riskProfile.Amin;
    rl.drawText("Amin", AminX - textOffsetX - 25, AminY, 13, rl.Color.white);

    // f
    const fX: i32 = oX;
    const fY: i32 = AminY + riskProfile.f;

    rl.drawText("f", fX - textOffsetX - 25, fY, 13, rl.Color.white);
    rl.drawLine(oX, oY, fX, fY, rl.Color.white);

    // v
    var vX: i32 = hX;
    var vY: i32 = hY;
    const vAngle: f64 = risk.milsToRadians(riskProfile.v);

    rotateLineEndPoints(&vX, &vY, oX, oY, vAngle);
    rl.drawText("v", vX - textOffsetX, vY - textOffsetY, 13, rl.Color.white);
    rl.drawLine(oX, oY, vX, vY, rl.Color.green);

    // q1
    // https://www.omnicalculator.com/math/right-triangle-side-angle
    // a = b × tan(α)
    var q1X: i32 = vX;
    var q1Y: i32 = vY;
    const q1oX: i32 = @intFromFloat(@as(f64, @floatFromInt(riskProfile.f)) * @tan(vAngle) + fX);
    const q1oY: i32 = fY;
    const q1Angle: f64 = risk.milsToRadians(riskProfile.q1);

    // std.debug.print("q1 mils: {any}.\n", .{riskProfile.q1});

    rotateLineEndPoints(&q1X, &q1Y, q1oX, q1oY, q1Angle);
    rl.drawText("q1", q1oX + 25, q1oY, 13, rl.Color.white);
    rl.drawLine(q1oX, q1oY, q1X, q1Y, rl.Color.green);
}

pub fn rotateLineEndPoints(x: *i32, y: *i32, ox: i32, oy: i32, angle: f64) void {
    // https://danceswithcode.net/engineeringnotes/rotations_in_2d/rotations_in_2d.html
    //
    // Rotating Points around an Arbitrary Center
    //
    // (x, y) = Point to be rotated
    // (ox, oy) = Coordinates of center of rotation
    // θ = Angle of rotation (positive counterclockwise) in radians
    // (x1, y1) = Coordinates of point after rotation
    //
    // x1 = (x – ox) * cos(θ) – (y – oy)* sin(θ) + ox
    // y1 = (x – ox) * sin(θ) + (y – oy)* cos(θ) + oy
    //
    // Instead of assigning to x1 and y1, the original values are mutated

    const cos: f64 = @cos(angle);
    const sin: f64 = @sin(angle);

    x.* = @intFromFloat((@as(f64, @floatFromInt(x.* - ox)) * cos - (@as(f64, @floatFromInt(y.* - oy))) * sin) + @as(f64, @floatFromInt(ox)));
    y.* = @intFromFloat((@as(f64, @floatFromInt(x.* - ox)) * sin + (@as(f64, @floatFromInt(y.* - oy))) * cos) + @as(f64, @floatFromInt(oy)));
}
