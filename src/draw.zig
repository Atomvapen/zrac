const std = @import("std");
const risk = @import("risk.zig");
const rl = @import("raylib");
const ru = @import("raylib-zig/lib/raygui.zig");

const screenWidth = 800;
const screenHeight = 800;
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

        // Buttons
        if (ru.guiButton(.{ .x = 10, .y = 10, .width = 100, .height = 50 }, "Beräkna") == 1) {
            std.debug.print("{s} \n", .{"Beräkna"});
            std.debug.print("{any} \n", .{inForest});
            std.debug.print("{d} \n", .{val});
        }
        _ = ru.guiCheckBox(.{ .x = 10, .y = 10 + 50 + 10, .width = 25, .height = 25 }, "I skog", &inForest);

        // _ = ru.guiSliderBar(.{ .x = 10, .y = 10 + 50 + 10 + 50 + 10, .width = 100, .height = 50 }, "", "v", &t, 0.0, 100.0);
        // _ = ru.guiSlider(.{ .x = 10, .y = 10 + 50 + 10 + 50 + 10 + 50 + 10, .width = 100, .height = 50 }, "", "h", &t, 0.0, 100.0);
        // _ = ru.guiTextInputBox(.{ .x = 10, .y = 10 + 50 + 10 + 50 + 10 + 50, .width = 200, .height = 200 }, "Titel", "message", "button", t[0..], 32, &b);
        // _ = ru.guiLabelButton(.{ .x = 10, .y = 10 + 50 + 10 + 50 + 10 + 50, .width = 200, .height = 200 }, "text: [*:0]const u8");
        _ = ru.guiValueBox(.{ .x = 10, .y = 10 + 50 + 10 + 50 + 10 + 50, .width = 50, .height = 25 }, "Val", &val, 0, 100, true);
        // const text: []const u8 = "text[0..]"; // Create a mutable buffer for the text
        // var buffer: [1024]u8 = undefined;
        // var fba = std.heap.FixedBufferAllocator.init(&buffer);
        // const allocator = fba.allocator();
        // const test2 = std.mem.Allocator.dupeZ(allocator, u8, text) catch |err| {
        //     std.debug.print("Allocation failed: {}\n", .{err});
        //     return; // Handle the error appropriately
        // };
        // _ = ru.guiTextBox(.{ .x = 10, .y = 10 + 50 + 100, .width = 100, .height = 50 }, "test2", 12, true);
        // _ = ru.guiDropdownBox(.{ .x = 200, .y = 200, .width = 100, .height = 50 }, "text", &selectedWeapon, false);
        // _ = ru.guiComboBox(.{ .x = 10, .y = 10 + 50 + 10 + 50 + 10, .width = 100, .height = 50 }, items[0..], &selectedItem);
        // _ = ru.guiComboBox(.{ .x = 10, .y = 10 + 50 + 10 + 50 + 10, .width = 100, .height = 50 }, a3, &selectedWeapon);

        // h
        rl.drawText("h", screenWidth / 2 - textOffsetX, screenHeight - riskProfile.h - textOffsetY, 13, rl.Color.white);
        rl.drawLine(screenWidth / 2, screenHeight - 50, screenWidth / 2, screenHeight - riskProfile.h, rl.Color.red);

        // v
        const x = @as(i32, @intFromFloat(@as(f64, @floatFromInt(riskProfile.h)) * @cos(risk.milsToRadians(riskProfile.v)) - risk.milsToRadians(90)));
        const y = @as(i32, @intFromFloat(@as(f64, @floatFromInt(riskProfile.h)) * @sin(risk.milsToRadians(riskProfile.v)) - risk.milsToRadians(90)));
        // const x = (@as(f64, @floatFromInt(riskProfile.h)) * @cos(risk.milsToDegree(riskProfile.v)));
        // const y = (@as(f64, @floatFromInt(riskProfile.h)) * @sin(risk.milsToDegree(riskProfile.v)));

        // const adjustedX = @as(i32, @intFromFloat(x * @cos(@as(f64, @floatFromInt(riskProfile.h))) - y * @sin(@as(f64, @floatFromInt(riskProfile.h)))));
        // const adjustedY = @as(i32, @intFromFloat(y * @cos(@as(f64, @floatFromInt(riskProfile.h))) + x * @sin(@as(f64, @floatFromInt(riskProfile.h)))));

        rl.drawLine(screenWidth / 2, screenHeight - 50, screenWidth / 2 + x, screenHeight - y, rl.Color.green);
        rl.drawLine(screenWidth / 2, screenHeight - 50, screenWidth / 2 + x, screenHeight - riskProfile.h - y, rl.Color.blue);
        rl.drawLine(screenWidth / 2, screenHeight - 50, screenWidth / 2 + x, screenHeight - riskProfile.h + y, rl.Color.gold);
        // rl.drawLine(screenWidth / 2, screenHeight - 50, screenWidth / 2 + adjustedX, screenHeight - adjustedY, rl.Color.red);

        // ru.guiTextBox(bounds: Rectangle, text: [*:0]u8, textSize: i32, editMode: bool)
        // std.debug.print("pressed\n", .{});
        // }

        // std.debug.print("h: {any}.\n", .{riskProfile.h});
        // std.debug.print("x: {any}.\n", .{x});
        // std.debug.print("x*: {any}.\n", .{@cos(risk.milsToRadians(riskProfile.v))});
        // std.debug.print("y*: {any}.\n", .{@sin(risk.milsToRadians(riskProfile.v))});
    }
}
