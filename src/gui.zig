const std = @import("std");
const risk = @import("risk.zig");
const rl = @import("raylib");
// const rl = @import("raylib-zig/lib/raylib.zig");
const rg = @import("raylib-zig/lib/raygui.zig");
const r = @import("raylib");

const screenWidth = 800;
const screenHeight: i32 = 800;

const Point = struct {
    x: i32,
    y: i32,
};

pub fn init() !void {
    rl.initWindow(screenWidth, screenHeight, "Risk");
    rl.setTargetFPS(30);
    rl.setExitKey(.key_escape);
}

pub fn deinit() void {
    rl.closeWindow();
}

pub fn draw() !void {
    var drawRisk: bool = true;
    var inForest: bool = false;

    var dropdownBox000Active: i32 = 0;
    var comboBoxActive: i32 = 0;
    var dropDown000EditMode: bool = false;

    // var textBoxText001 = std.mem.zeroes([64]u8);
    // var textBoxEditMode001: bool = false;

    var textBoxText002 = std.mem.zeroes([64]u8);
    var textBoxEditMode002: bool = false;

    var textBoxText003 = std.mem.zeroes([64]u8);
    var textBoxEditMode003: bool = false;

    var textBoxText004 = std.mem.zeroes([64]u8);
    var textBoxEditMode004: bool = false;

    var textBoxText005 = std.mem.zeroes([64]u8);
    var textBoxEditMode005: bool = false;

    // var saveRisk: bool = false;
    // var textInput = std.mem.zeroes([256]u8);
    // var textInputFileName = std.mem.zeroes([256]u8);

    var riskProfile: risk.RiskArea = undefined;

    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);
        rl.drawRectangle(0, 0, 200, screenHeight, rl.Color.white);

        // Input fields
        _ = rg.guiCheckBox(.{ .x = 210, .y = 10, .width = 25, .height = 25 }, "Draw", &drawRisk);

        _ = rg.guiLabel(.{ .x = 10, .y = 10, .width = 180, .height = 10 }, "Riskfaktor");
        _ = rg.guiComboBox(.{ .x = 10, .y = 25, .width = 180, .height = 30 }, "I;II;III", &comboBoxActive);

        _ = rg.guiLabel(.{ .x = 10, .y = 65, .width = 180, .height = 10 }, "Amin");
        if (rg.guiTextBox(.{ .x = 10, .y = 80, .width = 180, .height = 30 }, @as([*:0]u8, @ptrCast(&textBoxText002)), 63, textBoxEditMode002) != 0) textBoxEditMode002 = !textBoxEditMode002;

        _ = rg.guiLabel(.{ .x = 10, .y = 120, .width = 180, .height = 10 }, "Amax");
        if (rg.guiTextBox(.{ .x = 10, .y = 135, .width = 180, .height = 30 }, @as([*:0]u8, @ptrCast(&textBoxText003)), 63, textBoxEditMode003) != 0) textBoxEditMode003 = !textBoxEditMode003;

        _ = rg.guiLabel(.{ .x = 10, .y = 175, .width = 180, .height = 10 }, "f");
        if (rg.guiTextBox(.{ .x = 10, .y = 190, .width = 180, .height = 30 }, @as([*:0]u8, @ptrCast(&textBoxText004)), 63, textBoxEditMode004) != 0) textBoxEditMode004 = !textBoxEditMode004;

        _ = rg.guiLabel(.{ .x = 10, .y = 230, .width = 30, .height = 10 }, "Skog");
        _ = rg.guiCheckBox(.{ .x = 10, .y = 245, .width = 30, .height = 30 }, "", &inForest);
        _ = rg.guiLabel(.{ .x = 50, .y = 230, .width = 100, .height = 10 }, "Skogsavstånd");
        if (rg.guiTextBox(.{ .x = 50, .y = 245, .width = 140, .height = 30 }, @as([*:0]u8, @ptrCast(&textBoxText005)), 63, textBoxEditMode005) != 0) textBoxEditMode005 = !textBoxEditMode005;

        _ = rg.guiLabel(.{ .x = 10, .y = 585, .width = 100, .height = 10 }, "Vapentyp");
        if (rg.guiDropdownBox(.{ .x = 10, .y = 600, .width = 100, .height = 30 }, "AK5;KSP58;KSP88;KSP90", &dropdownBox000Active, dropDown000EditMode) != 0) dropDown000EditMode = !dropDown000EditMode;

        // if (rg.guiButton(.{ .x = 10, .y = 680, .width = 100, .height = 50 }, "Beräkna") == 1) {
        riskProfile.factor = comboBoxActive + 1;
        riskProfile.Amin = combineAsciiToInt(&textBoxText002);
        riskProfile.Amax = combineAsciiToInt(&textBoxText003);
        riskProfile.f = combineAsciiToInt(&textBoxText004);
        riskProfile.inForest = inForest;
        riskProfile.forestMin = combineAsciiToInt(&textBoxText005);

        riskProfile.v = 100;
        riskProfile.Dmax = 500;

        riskProfile.l = riskProfile.calculateL();
        riskProfile.h = riskProfile.calculateH();
        riskProfile.c = riskProfile.calculateC();
        riskProfile.q1 = riskProfile.calculateQ1();
        riskProfile.q2 = riskProfile.calculateQ2();
        riskProfile.valid = riskProfile.validate();

        // std.debug.print("valid :{any} \n", .{riskProfile.valid});

        // std.debug.print("RF :{d} \n", .{riskProfile2.factor});
        // std.debug.print("Amin :{d} \n", .{riskProfile2.Amin});
        // std.debug.print("Amax :{d} \n", .{riskProfile2.Amax});
        // std.debug.print("f :{d} \n", .{riskProfile2.f});
        // std.debug.print("inForest :{any} \n", .{riskProfile2.inForest});
        // std.debug.print("forestMin :{d} \n", .{riskProfile2.forestMin});
        // }

        // Draw Lines
        if (drawRisk == true and riskProfile.valid == true) drawLines(riskProfile);

        // Save
        // if (rg.guiButton(.{ .x = 10, .y = 740, .width = 100, .height = 50 }, "Spara") == 1) {
        //     saveRisk = !saveRisk;
        // }

        // if (saveRisk == true) {
        //     rl.drawRectangle(0, 0, rl.getScreenWidth(), rl.getScreenHeight(), rl.fade(rl.Color.ray_white, 0.8));
        //     var secretViewActive = false;
        //     const result = rg.guiTextInputBox(
        //         .{ .x = @as(f32, @floatFromInt(rl.getScreenWidth())) / 2 - 120, .y = @as(f32, @floatFromInt(rl.getScreenHeight())) / 2 - 60, .width = 240, .height = 140 },
        //         "Save",
        //         "Save file as...",
        //         "Ok;Cancel",
        //         @as([*:0]u8, @ptrCast(&textInput)),
        //         255,
        //         &secretViewActive,
        //     );

        //     if (result == 1) {
        //         // TODO: Validate textInput value and save
        //         std.mem.copyForwards(u8, &textInputFileName, &textInput);
        //         // std.debug.print("{d} \n", .{textInputFileName});

        //         // const teststring = asciiToString(&textInputFileName);
        //         // std.debug.print("{d} \n", .{teststring});

        //         // const teststring: i32 = combineAsciiToInt(&textInputFileName);

        //     }

        //     if (result != 1) {
        //         saveRisk = false;
        //         std.mem.copyForwards(u8, &textInput, &[_]u8{0});
        //     }
        // }
    }
}

pub fn combineAsciiToInt(asciiArray: []const u8) i32 {
    var result: i32 = 0;

    for (asciiArray) |asciiChar| {
        const digit = @as(i32, @intCast(asciiChar)) - '0'; // Convert ASCII digit to numeric value

        // Check for potential overflow before performing the operation
        if (digit < 0 or digit > 9) continue; // Skip non-digit characters

        if (result > @divFloor((std.math.maxInt(i32) - digit), 10)) {
            // Handle overflow (e.g., return an error, set result to max, etc.)
            return std.math.maxInt(i32); // Example: return max value on overflow
        }

        result = result * 10 + digit; // Shift left and add digit
    }

    return result;
}

pub fn drawLines(riskProfile: risk.RiskArea) void {
    // Origin
    const origin: Point = Point{ .x = screenWidth / 2, .y = screenHeight - 50 };
    const center: rl.Vector2 = rl.Vector2{ .x = screenWidth / 2, .y = screenHeight - 50 };

    // h
    var h = RiskLine{ .startX = origin.x, .startY = origin.y, .endX = origin.x, .endY = origin.y - riskProfile.h, .angle = undefined };
    h.DrawLine(false);
    h.DrawText("h", 0, -20);

    // Amin
    var Amin = RiskLine{ .startX = undefined, .startY = undefined, .endX = origin.x, .endY = origin.y - riskProfile.Amin, .angle = undefined };
    Amin.DrawText("Amin", -30, 0);

    // f
    var f = RiskLine{ .startX = origin.x, .startY = origin.y, .endX = origin.x, .endY = Amin.endY + (riskProfile.f + 50), .angle = undefined };
    // f.DrawLine(false);
    if (riskProfile.f != 0) f.DrawText("f", -30, -50);

    // v
    var v = RiskLine{ .startX = origin.x, .startY = origin.y, .endX = origin.x, .endY = origin.y - riskProfile.h, .angle = risk.milsToRadians(riskProfile.v) };
    v.DrawLine(true);
    v.DrawText("v", -5, -20);

    // h -> v
    rl.drawCircleSectorLines(center, @as(f32, @floatFromInt(riskProfile.h)), -90, -90 + @as(f32, @as(f32, @floatFromInt(riskProfile.v)) * 0.05625), 50, rl.Color.green);

    // ch
    // var ch = RiskLine{ .startX = v.endX, .startY = v.endY, .endX = v.endX - 100, .endY = v.endY - 100, .angle = risk.milsToRadians(riskProfile.ch+1000) };
    var ch = RiskLine{ .startX = v.endX, .startY = v.endY, .endX = v.endX - 100, .endY = v.endY - 100, .angle = risk.milsToRadians(riskProfile.ch + 1000) };
    // ch.startX = ch.calculateXfromAngle(riskProfile.v, v.angle) + origin.x;

    ch.DrawLine(true);
    ch.DrawText("ch", -5, -20);

    // q1
    var q1 = RiskLine{ .startX = undefined, .startY = origin.y - riskProfile.Amin + (riskProfile.f + 50), .endX = v.endX, .endY = v.endY, .angle = risk.milsToRadians(riskProfile.q1) };
    q1.startX = q1.calculateXfromAngle((riskProfile.f + 50), v.angle) + origin.x;
    q1.DrawLine(true);
    q1.DrawText("q1", 15, 0);

    // q2
    if (riskProfile.inForest == true) {
        var q2 = RiskLine{ .startX = origin.x, .startY = origin.y, .endX = v.endX, .endY = v.endY, .angle = risk.milsToRadians(riskProfile.q2) };
        // q2.startX = q2.calculateXfromAngle(riskProfile.forestMin, v.angle) + origin.x;
        q2.DrawLine(true);
        q2.DrawText("q2", 25, 0);
    } else if (riskProfile.forestMin > 0) {
        // forestMin
        var forestMin = RiskLine{ .startX = undefined, .startY = undefined, .endX = origin.x, .endY = origin.y - riskProfile.forestMin, .angle = undefined };
        forestMin.DrawText("forestMin", -65, 0);

        var q2 = RiskLine{ .startX = undefined, .startY = origin.y - riskProfile.forestMin, .endX = v.endX, .endY = v.endY, .angle = risk.milsToRadians(riskProfile.q2) };
        q2.startX = q2.calculateXfromAngle(riskProfile.forestMin, v.angle) + origin.x;
        q2.DrawLine(true);
        q2.DrawText("q2", 25, 0);
    }
}

pub const RiskLine = struct {
    startX: i32,
    startY: i32,
    endX: i32,
    endY: i32,
    angle: f64,

    fn DrawLine(self: *RiskLine, rotate: bool) void {
        if (rotate) {
            const point: Point = self.rotateLineEndPoints();
            self.endX = point.x;
            self.endY = point.y;
        }

        rl.drawLine(self.startX, self.startY, self.endX, self.endY, rl.Color.green);
    }

    fn DrawText(self: *RiskLine, text: [*:0]const u8, textOffsetX: i32, textOffsetY: i32) void {
        rl.drawText(text, self.endX + textOffsetX, self.endY + textOffsetY, 13, rl.Color.white);
    }

    fn calculateXfromAngle(self: *RiskLine, width: i32, angle: f64) i32 {
        // https://www.omnicalculator.com/math/right-triangle-side-angle
        //
        // Given an angle and one leg
        // Find the missing leg using trigonometric functions
        //
        // a = b × tan(α)

        _ = self;
        const b: f64 = @as(f64, @floatFromInt(width));
        const a: f64 = @tan(angle);

        return @intFromFloat(b * a);
    }

    fn rotateLineEndPoints(self: *RiskLine) Point {
        // https://danceswithcode.net/engineeringnotes/rotations_in_2d/rotations_in_2d.html
        //
        // Rotating Points around an Arbitrary Center
        //
        // (x, y) = Point to be rotated
        // (ox, oy) = Coordinates of center of rotation
        // θ = Angle of rotation (positive counterclockwise) in radians
        // (x1, y1) = Coordinates of point after rotation
        //
        // rotated_x = (x – ox) * cos(θ) – (y – oy)* sin(θ) + ox
        // rotated_y = (x – ox) * sin(θ) + (y – oy)* cos(θ) + oy

        var rotatedPoints: Point = Point{ .x = 0, .y = 0 };

        rotatedPoints.x = @intFromFloat((@as(f64, @floatFromInt(self.endX - self.startX)) * @cos(self.angle) - (@as(f64, @floatFromInt(self.endY - self.startY))) * @sin(self.angle)) + @as(f64, @floatFromInt(self.startX)));
        rotatedPoints.y = @intFromFloat((@as(f64, @floatFromInt(self.endX - self.startX)) * @sin(self.angle) + (@as(f64, @floatFromInt(self.endY - self.startY))) * @cos(self.angle)) + @as(f64, @floatFromInt(self.startY)));

        return rotatedPoints;
    }
};
