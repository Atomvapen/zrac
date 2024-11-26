const std = @import("std");
const risk = @import("risk.zig");
const weapons = @import("weapons.zig");
const rl = @import("raylib");
const rg = @import("raygui");

const screenWidth = 800;
const screenHeight: i32 = 800;

const Point = struct {
    x: i32,
    y: i32,
};

var camera = rl.Camera2D{
    .target = .{ .x = 0, .y = 0 },
    .offset = .{ .x = 0, .y = 0 },
    .zoom = 1.0,
    .rotation = 0,
};

pub fn init() !void {
    rl.initWindow(screenWidth, screenHeight, "Risk");
    rl.setTargetFPS(15);
    rl.setExitKey(.key_escape);
}

pub fn deinit() void {
    rl.closeWindow();
}

fn handleCamera() void {
    const pos = rl.getMousePosition();
    if (pos.x < 200) return;

    if (rl.isMouseButtonDown(.mouse_button_right)) {
        var delta = rl.getMouseDelta();
        delta = rl.math.vector2Scale(delta, -1.0 / camera.zoom);
        camera.target = rl.math.vector2Add(camera.target, delta);
    }

    const wheel = rl.getMouseWheelMove();
    if (wheel != 0) {
        const mouseWorldPos = rl.getScreenToWorld2D(rl.getMousePosition(), camera);
        camera.offset = rl.getMousePosition();
        camera.target = mouseWorldPos;
        var scaleFactor = 1.0 + (0.25 * @abs(wheel));
        if (wheel < 0) scaleFactor = 1.0 / scaleFactor;
        camera.zoom = rl.math.clamp(camera.zoom * scaleFactor, 0.125, 64.0);
    }
}

pub fn menuPane() void {}

pub fn main() !void {
    var riskProfile: risk.RiskArea = undefined;

    var drawRisk: bool = true;
    var inForest: bool = false;
    var fixedTarget: bool = true;

    var WeaponDropdownBoxActive: i32 = 0;
    var WeaponDropdownBoxEditMode: bool = false;

    var AmmunitionDropdownBoxActive: i32 = 0;
    var AmmunitionDropdownBoxEditMode: bool = false;

    var riskFactorComboBoxActive: i32 = 0;

    var AminTextBox = std.mem.zeroes([64]u8);
    var AminTextBoxEditMode: bool = false;

    var AmaxTextBox = std.mem.zeroes([64]u8);
    var AmaxTextBoxEditMode: bool = false;

    var fTextBox = std.mem.zeroes([64]u8);
    var fTextBoxEditMode: bool = false;

    var forstDistTextBox = std.mem.zeroes([64]u8);
    var forstDistTextBoxEditMode: bool = false;

    var menuPage: i8 = 1;

    while (!rl.windowShouldClose()) {
        handleCamera();

        rl.beginDrawing();
        defer rl.endDrawing();

        // Risk Values
        {
            riskProfile.factor = riskFactorComboBoxActive + 1;
            riskProfile.Amin = combineAsciiToInt(&AminTextBox);
            riskProfile.Amax = combineAsciiToInt(&AmaxTextBox);
            riskProfile.f = combineAsciiToInt(&fTextBox);
            riskProfile.inForest = inForest;
            riskProfile.forestMin = combineAsciiToInt(&forstDistTextBox);
            riskProfile.fixedTarget = fixedTarget;
            riskProfile.weaponType = switch (WeaponDropdownBoxActive) {
                0 => weapons.Weapons.AK5,
                1 => weapons.Weapons.KSP58,
                2 => weapons.Weapons.KSP58_Benstod,
                else => weapons.Weapons.invalid,
            };

            riskProfile.v = if (riskProfile.fixedTarget) riskProfile.weaponType.v_still else riskProfile.weaponType.v_moveable;
            riskProfile.Dmax = riskProfile.weaponType.Dmax;

            riskProfile.l = riskProfile.calculateL();
            riskProfile.h = riskProfile.calculateH();
            riskProfile.c = riskProfile.calculateC();
            riskProfile.q1 = riskProfile.calculateQ1();
            riskProfile.q2 = riskProfile.calculateQ2();
            riskProfile.valid = riskProfile.validate();

            rl.clearBackground(rl.Color.ray_white);
        }

        // Moveable UI
        {
            camera.begin();
            defer camera.end();

            rl.gl.rlPushMatrix();
            // rl.gl.rlTranslatef(0, 25 * 50, 0);
            rl.gl.rlTranslatef(0, 50 * 50, 0);
            rl.gl.rlRotatef(90, 1, 0, 0);
            // rl.drawGrid(100, 50);
            rl.drawGrid(200, 100);
            rl.gl.rlPopMatrix();

            if (drawRisk == true and riskProfile.valid == true) drawLines(riskProfile);
        }

        // Static UI
        {
            rl.drawRectangle(200, 0, 1, screenHeight, rl.Color.black);
            rl.drawRectangle(0, 0, 200, screenHeight, rl.Color.white);

            // NEW Menu
            {
                const menuOrigin = Point{
                    .x = 210,
                    .y = 1,
                };

                const barWidth = 100;
                const barHeight = 30;

                //Pane
                rl.drawRectangle(menuOrigin.x, menuOrigin.y, (barWidth * 2), screenHeight, rl.Color.white);
                rl.drawRectangle(menuOrigin.x + (barWidth * 2), menuOrigin.y, 1, screenHeight, rl.Color.black);
                rl.drawRectangle(menuOrigin.x, menuOrigin.y - 1, (barWidth * 2), 1, rl.Color.black);

                // Buttons
                if (menuPage == 1) { //SST
                    rl.drawRectangle(menuOrigin.x, menuOrigin.y, barWidth + 1, barHeight, rl.Color.black);
                    rl.drawRectangle(menuOrigin.x, menuOrigin.y, barWidth, barHeight, rl.Color.white);

                    rl.drawRectangle(menuOrigin.x + barWidth - 1, menuOrigin.y, barWidth + 1, barHeight + 1, rl.Color.black);
                    rl.drawRectangle(menuOrigin.x + barWidth, menuOrigin.y, barWidth, barHeight, rl.Color.light_gray);
                } else if (menuPage == 2) { //BOX
                    rl.drawRectangle(menuOrigin.x - 1, menuOrigin.y, barWidth + 1, barHeight + 1, rl.Color.black);
                    rl.drawRectangle(menuOrigin.x, menuOrigin.y, barWidth, barHeight, rl.Color.light_gray);

                    rl.drawRectangle(menuOrigin.x + barWidth - 1, menuOrigin.y, barWidth + 1, barHeight, rl.Color.black);
                    rl.drawRectangle(menuOrigin.x + barWidth, menuOrigin.y, barWidth, barHeight, rl.Color.white);
                }

                if (rg.guiLabelButton(.{ .x = menuOrigin.x + 40, .y = 10, .width = 10, .height = 10 }, "SST") == 1) menuPage = 1;
                if (rg.guiLabelButton(.{ .x = menuOrigin.x + barWidth + 40, .y = 10, .width = 10, .height = 10 }, "BOX") == 1) menuPage = 2;
            }

            // Input fields
            _ = rg.guiLabel(.{ .x = 160, .y = 10, .width = 30, .height = 10 }, "Visa");
            _ = rg.guiCheckBox(.{ .x = 160, .y = 25, .width = 30, .height = 30 }, "", &drawRisk);

            _ = rg.guiLabel(.{ .x = 10, .y = 10, .width = 180, .height = 10 }, "Riskfaktor");
            _ = rg.guiComboBox(.{ .x = 10, .y = 25, .width = 60, .height = 30 }, "I;II;III", &riskFactorComboBoxActive);

            _ = rg.guiLabel(.{ .x = 10, .y = 65, .width = 180, .height = 10 }, "Amin");
            if (rg.guiTextBox(.{ .x = 10, .y = 80, .width = 180, .height = 30 }, @as([*:0]u8, @ptrCast(&AminTextBox)), 63, AminTextBoxEditMode) != 0) AminTextBoxEditMode = !AminTextBoxEditMode;

            _ = rg.guiLabel(.{ .x = 10, .y = 120, .width = 180, .height = 10 }, "Amax");
            if (rg.guiTextBox(.{ .x = 10, .y = 135, .width = 180, .height = 30 }, @as([*:0]u8, @ptrCast(&AmaxTextBox)), 63, AmaxTextBoxEditMode) != 0) AmaxTextBoxEditMode = !AmaxTextBoxEditMode;

            _ = rg.guiLabel(.{ .x = 10, .y = 175, .width = 180, .height = 10 }, "f");
            if (rg.guiTextBox(.{ .x = 10, .y = 190, .width = 180, .height = 30 }, @as([*:0]u8, @ptrCast(&fTextBox)), 63, fTextBoxEditMode) != 0) fTextBoxEditMode = !fTextBoxEditMode;

            _ = rg.guiLabel(.{ .x = 10, .y = 230, .width = 30, .height = 10 }, "Skog");
            _ = rg.guiCheckBox(.{ .x = 10, .y = 245, .width = 30, .height = 30 }, "", &inForest);
            _ = rg.guiLabel(.{ .x = 50, .y = 230, .width = 100, .height = 10 }, "Skogsavstånd");
            if (rg.guiTextBox(.{ .x = 50, .y = 245, .width = 140, .height = 30 }, @as([*:0]u8, @ptrCast(&forstDistTextBox)), 63, forstDistTextBoxEditMode) != 0) forstDistTextBoxEditMode = !forstDistTextBoxEditMode;

            _ = rg.guiLabel(.{ .x = 10, .y = 340, .width = 30, .height = 10 }, "Fast");
            _ = rg.guiCheckBox(.{ .x = 10, .y = 355, .width = 30, .height = 30 }, "", &fixedTarget);

            _ = rg.guiLabel(.{ .x = 50, .y = 340, .width = 140, .height = 10 }, "Ammunitionstyp");
            if (rg.guiDropdownBox(.{ .x = 50, .y = 355, .width = 140, .height = 30 }, weapons.AmmunitionType.allNames, &AmmunitionDropdownBoxActive, AmmunitionDropdownBoxEditMode) != 0) AmmunitionDropdownBoxEditMode = !AmmunitionDropdownBoxEditMode;

            _ = rg.guiLabel(.{ .x = 10, .y = 285, .width = 180, .height = 10 }, "Vapentyp");
            if (rg.guiDropdownBox(.{ .x = 10, .y = 300, .width = 180, .height = 30 }, weapons.Weapons.allNames, &WeaponDropdownBoxActive, WeaponDropdownBoxEditMode) != 0) WeaponDropdownBoxEditMode = !WeaponDropdownBoxEditMode;

            _ = rg.guiStatusBar(.{ .x = 0, .y = @as(f32, @floatFromInt(rl.getScreenHeight() - 20)), .width = @as(f32, @floatFromInt(rl.getScreenWidth())), .height = 20 }, "ZRAC v0.0.1");
        }
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
            return std.math.maxInt(i32); // Return max value on overflow
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

    // v
    var v = RiskLine{ .startX = origin.x, .startY = origin.y, .endX = origin.x, .endY = origin.y - riskProfile.h, .angle = risk.milsToRadians(riskProfile.v) };
    v.DrawLine(true);
    v.DrawText("v", -5, -20);

    if (riskProfile.f <= riskProfile.Amin) {
        //f
        var f = RiskLine{ .startX = origin.x, .startY = origin.y, .endX = origin.x, .endY = Amin.endY + (riskProfile.f + 50), .angle = undefined };
        f.DrawText("f", -30, -50);

        // q1
        var q1 = RiskLine{ .startX = undefined, .startY = origin.y - riskProfile.Amin + riskProfile.f, .endX = v.endX, .endY = v.endY, .angle = risk.milsToRadians(riskProfile.q1) };
        q1.startX = q1.calculateXfromAngle(riskProfile.Amin - riskProfile.f, v.angle) + origin.x;
        q1.DrawLine(true);
        q1.DrawText("q1", 15, 0);
    }

    // h -> v
    rl.drawCircleSectorLines(center, @as(f32, @floatFromInt(riskProfile.h)), -90, -90 + @as(f32, @as(f32, @floatFromInt(riskProfile.v)) * 0.05625), 50, rl.Color.maroon);
    // rl.drawCircleSectorLines(center, @as(f32, @floatFromInt(riskProfile.h)), -90, -90 + @as(f32, @as(f32, risk.milsToDegree(riskProfile.v))), 50, rl.Color.maroon);

    // ch
    // var ch = RiskLine{ .startX = v.endX, .startY = v.endY, .endX = v.endX - 100, .endY = v.endY - 100, .angle = risk.milsToRadians(riskProfile.ch+1000) };
    // var ch = RiskLine{ .startX = v.endX, .startY = v.endY, .endX = v.endX - 300, .endY = v.endY - 300, .angle = risk.milsToRadians(riskProfile.ch + 1000) };
    var ch = RiskLine{ .startX = v.endX, .startY = v.endY, .endX = v.endX - 300, .endY = v.endY - 300, .angle = 45 + risk.milsToRadians(riskProfile.ch) };
    // ch.startX = ch.calculateXfromAngle(riskProfile.v, v.angle) + origin.x;

    ch.DrawLine(true);
    ch.DrawText("ch", -5, -20);

    // q2
    if (riskProfile.inForest == true) {
        var q2 = RiskLine{ .startX = origin.x, .startY = origin.y, .endX = v.endX, .endY = v.endY, .angle = risk.milsToRadians(riskProfile.q2) };
        q2.DrawLine(true);
        q2.DrawText("q2", 25, 0);
    } else if (riskProfile.forestMin > 0 and riskProfile.forestMin <= riskProfile.h) {
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

        rl.drawLine(self.startX, self.startY, self.endX, self.endY, rl.Color.maroon);
    }

    fn DrawText(self: *RiskLine, text: [*:0]const u8, textOffsetX: i32, textOffsetY: i32) void {
        rl.drawText(text, self.endX + textOffsetX, self.endY + textOffsetY, 30, rl.Color.black);
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
