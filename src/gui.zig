const std = @import("std");
const risk = @import("risk.zig");
const weapons = @import("weapons.zig");
const rl = @import("raylib");
const rg = @import("raygui");
const RiskLine = @import("draw.zig").RiskLine;

const lineIntersection = @import("math2.zig").lineIntersection;

const screenWidth = 800;
const screenHeight: i32 = 800;
const Point = struct {
    x: i32,
    y: i32,
};
pub const guiState = struct {
    const textBoxState = struct {
        value: [64]u8,
        editMode: bool,
    };

    const checkBoxState = struct {
        value: bool,
    };

    const comboBoxState = struct {
        value: i32,
    };

    const dropdownBoxState = struct {
        value: i32,
        editMode: bool,
    };

    Amin: textBoxState = .{ .editMode = false, .value = std.mem.zeroes([64]u8) },
    Amax: textBoxState = .{ .editMode = false, .value = std.mem.zeroes([64]u8) },
    f: textBoxState = .{ .editMode = false, .value = std.mem.zeroes([64]u8) },
    forstDist: textBoxState = .{ .editMode = false, .value = std.mem.zeroes([64]u8) },
    show: checkBoxState = .{ .value = true },
    inForest: checkBoxState = .{ .value = false },
    riskFactor: comboBoxState = .{ .value = 0 },
    ammunitionType: dropdownBoxState = .{ .editMode = false, .value = 0 },
    weaponType: dropdownBoxState = .{ .editMode = false, .value = 0 },
    targetType: checkBoxState = .{ .value = false },
    menu: Menu = .{ .page = 1 },

    pub fn reset(self: *guiState) void {
        self.Amin = .{ .editMode = false, .value = std.mem.zeroes([64]u8) };
        self.Amax = .{ .editMode = false, .value = std.mem.zeroes([64]u8) };
        self.f = .{ .editMode = false, .value = std.mem.zeroes([64]u8) };
        self.forstDist = .{ .editMode = false, .value = std.mem.zeroes([64]u8) };
        self.show = .{ .value = true };
        self.inForest = .{ .value = false };
        self.riskFactor = .{ .value = 0 };
        self.ammunitionType = .{ .editMode = false, .value = 0 };
        self.weaponType = .{ .editMode = false, .value = 0 };
        self.targetType = .{ .value = false };
    }

    pub fn init(self: *guiState) !void {
        try self.menu.init();
        gui.show.value = true;
        self.reset();
    }
};

var camera = rl.Camera2D{
    .target = .{ .x = 0, .y = 0 },
    .offset = .{ .x = 0, .y = 0 },
    .zoom = 1.0,
    .rotation = 0,
};
var gui: guiState = undefined;

pub fn init() !void {
    rl.initWindow(screenWidth, screenHeight, "Risk");
    rl.setTargetFPS(15);
    rl.setExitKey(.key_escape);
    try gui.init();
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

pub fn main() !void {
    var riskProfile: risk.RiskArea = undefined;

    while (!rl.windowShouldClose()) {
        handleCamera();

        rl.beginDrawing();
        defer rl.endDrawing();

        // Link Risk Values to GUI State
        {
            try riskProfile.update(gui);
            riskProfile.validate();
        }

        rl.clearBackground(rl.Color.ray_white);

        // Moveable UI
        {
            camera.begin();
            defer camera.end();

            rl.gl.rlPushMatrix();
            rl.gl.rlTranslatef(0, 50 * 50, 0);
            rl.gl.rlRotatef(90, 1, 0, 0);
            rl.drawGrid(200, 100);
            rl.gl.rlPopMatrix();

            if (gui.show.value == true and riskProfile.valid == true) drawLines(riskProfile);
        }

        // Static UI
        {
            gui.menu.drawMenu();
        }
    }
}

fn drawLines(riskProfile: risk.RiskArea) void {
    // Origin
    const origin: Point = Point{ .x = screenWidth / 2, .y = screenHeight - 50 };
    // const center: rl.Vector2 = rl.Vector2{ .x = screenWidth / 2, .y = screenHeight - 50 };

    // h
    var h = RiskLine{ .startX = origin.x, .startY = origin.y, .endX = origin.x, .endY = origin.y - riskProfile.h, .angle = undefined };
    h.drawLine();
    h.drawText("h", 0, -20, 30);

    // Amin
    var Amin = RiskLine{ .startX = undefined, .startY = undefined, .endX = origin.x, .endY = origin.y - riskProfile.Amin, .angle = undefined };
    Amin.drawText("Amin", -30, 0, 30);

    // v
    var v = RiskLine{ .startX = origin.x, .startY = origin.y, .endX = origin.x, .endY = origin.y - riskProfile.h, .angle = riskProfile.v };
    v.rotateEndPoint();
    v.drawLine();
    v.drawText("v", -5, -20, 30);

    if (riskProfile.f > riskProfile.Amin) return;
    // if (riskProfile.f <= riskProfile.Amin) {
    //f
    var f = RiskLine{ .startX = origin.x, .startY = origin.y, .endX = origin.x, .endY = Amin.endY + (riskProfile.f + 50), .angle = undefined };
    f.drawText("f", -30, -50, 30);

    // q1
    var q1 = RiskLine{ .startX = undefined, .startY = origin.y - riskProfile.Amin + riskProfile.f, .endX = v.endX, .endY = v.endY, .angle = riskProfile.q1 };
    q1.startX = q1.calculateXfromAngle(riskProfile.Amin - riskProfile.f, v.angle) + origin.x;
    q1.rotateEndPoint();
    // q1.drawLine();
    // q1.drawText("q1", 15, 0, 30);
    // }

    // h -> v
    var hv = RiskLine{ .startX = origin.x, .startY = origin.y, .endX = undefined, .endY = undefined, .angle = riskProfile.v };
    hv.drawCircleSector(@as(f32, @floatFromInt(riskProfile.h)));

    // ch
    var ch = RiskLine{ .startX = v.endX, .startY = v.endY, .endX = v.endX - 300, .endY = v.endY - 300, .angle = riskProfile.ch };
    ch.rotateEndPoint();
    const intsersectPoint: rl.Vector2 = lineIntersection(ch.getStartVector(), ch.getEndVector(), q1.getStartVector(), q1.getEndVector()) orelse rl.Vector2{ .x = -10, .y = -10 };
    ch = RiskLine{ .startX = v.endX, .startY = v.endY, .endX = @intFromFloat(intsersectPoint.x), .endY = @intFromFloat(intsersectPoint.y), .angle = riskProfile.ch };

    q1 = RiskLine{ .startX = q1.startX, .startY = origin.y - riskProfile.Amin + riskProfile.f, .endX = @intFromFloat(intsersectPoint.x), .endY = @intFromFloat(intsersectPoint.y), .angle = riskProfile.q1 };
    q1.drawLine();
    q1.drawText("q1", 15, 0, 30);

    ch.drawLine();
    ch.drawText("ch", -5, -20, 30);

    // q2
    if (riskProfile.inForest == true) {
        var q2 = RiskLine{ .startX = origin.x, .startY = origin.y, .endX = v.endX, .endY = v.endY, .angle = riskProfile.q2 };
        q2.rotateEndPoint();
        q2.drawLine();
        q2.drawText("q2", 25, 0, 30);
    } else if (riskProfile.forestDist > 0 and riskProfile.forestDist <= riskProfile.h) {
        // forestMin
        var forestMin = RiskLine{ .startX = undefined, .startY = undefined, .endX = origin.x, .endY = origin.y - riskProfile.forestDist, .angle = undefined };
        forestMin.drawText("forestMin", -65, 0, 30);

        var q2 = RiskLine{ .startX = undefined, .startY = origin.y - riskProfile.forestDist, .endX = v.endX, .endY = v.endY, .angle = riskProfile.q2 };
        q2.startX = q2.calculateXfromAngle(riskProfile.forestDist, v.angle) + origin.x;
        q2.rotateEndPoint();
        q2.drawLine();
        q2.drawText("q2", 25, 0, 30);
    }
}

pub const Menu = struct {
    pub const barWidth = 100;
    pub const barHeight = 30;
    pub const originPoint = Point{
        .x = 0,
        .y = 1,
    };

    var pageNr: i8 = 1;

    page: i8, //TODO: måste ha en getPage istället så att denna inte kan ändras hur som
    origin: Point = originPoint,

    var p: i32 = 1;

    pub fn init(self: *Menu) !void {
        self.origin = originPoint;
        self.page = 1;
    }

    pub fn setPage(self: *Menu, value: i8) void {
        if (value != self.page) gui.reset();
        self.page = value;
    }

    pub fn drawMenu(self: *Menu) void {
        //Pane
        rl.drawRectangle(self.origin.x, self.origin.y, (barWidth * 2), screenHeight, rl.Color.white);
        rl.drawRectangle(self.origin.x + (barWidth * 2), self.origin.y, 1, screenHeight, rl.Color.black);
        rl.drawRectangle(self.origin.x, self.origin.y - 1, (barWidth * 2), 1, rl.Color.black);

        // Switch Page
        switch (self.page) {
            1 => self.drawMenuSST(),
            2 => self.drawMenuBOX(),
            else => return,
        }

        // Reset button
        if (rg.guiButton(.{ .x = 10, .y = 740, .width = 180, .height = 30 }, "Nollställ") == 1) gui.reset();

        // Switch page buttons
        if (rg.guiLabelButton(.{ .x = 0 + 40, .y = 10, .width = 10, .height = 10 }, "SST") == 1) gui.menu.setPage(1);
        if (rg.guiLabelButton(.{ .x = 0 + barWidth + 40, .y = 10, .width = 10, .height = 10 }, "BOX") == 1) gui.menu.setPage(2);

        // Status bar
        const mouse_pos = rl.getMousePosition();
        var gpa = std.heap.GeneralPurposeAllocator(.{}){};
        defer _ = gpa.deinit();

        const allocator = gpa.allocator();

        const string = std.fmt.allocPrintZ(allocator, "ZRAC v0.0.1 | x: {d} y: {d}", .{ mouse_pos.x, mouse_pos.y }) catch |err| {
            std.debug.print("{any}", .{err});
            return;
        };

        defer allocator.free(string);

        _ = rg.guiStatusBar(.{ .x = 0, .y = @as(f32, @floatFromInt(screenHeight - 20)), .width = @as(f32, @floatFromInt(screenWidth)), .height = 20 }, string);
    }

    pub fn drawMenuSST(self: *Menu) void {
        // Menu Bar
        rl.drawRectangle(self.origin.x, self.origin.y, barWidth + 1, barHeight, rl.Color.black);
        rl.drawRectangle(self.origin.x, self.origin.y, barWidth, barHeight, rl.Color.white);

        rl.drawRectangle(self.origin.x + barWidth - 1, self.origin.y, barWidth + 1, barHeight + 1, rl.Color.black);
        rl.drawRectangle(self.origin.x + barWidth, self.origin.y, barWidth, barHeight, rl.Color.light_gray);

        // Input fields
        _ = rg.guiLabel(.{ .x = 160, .y = barHeight + 10, .width = 30, .height = 10 }, "Visa");
        _ = rg.guiCheckBox(.{ .x = 160, .y = barHeight + 25, .width = 30, .height = 30 }, "", &gui.show.value);
        // _ = rg.guiCheckBox(.{ .x = 160, .y = barHeight + 25, .width = 30, .height = 30 }, "", &riskProfile.show);

        _ = rg.guiLabel(.{ .x = 10, .y = barHeight + 10, .width = 180, .height = 10 }, "Riskfaktor");
        _ = rg.guiComboBox(.{ .x = 10, .y = barHeight + 25, .width = 60, .height = 30 }, "I;II;III", &gui.riskFactor.value);
        // _ = rg.guiComboBox(.{ .x = 10, .y = barHeight + 25, .width = 60, .height = 30 }, "I;II;III", &riskProfile.factor);

        _ = rg.guiLabel(.{ .x = 10, .y = barHeight + 65, .width = 180, .height = 10 }, "Amin");
        if (rg.guiTextBox(.{ .x = 10, .y = barHeight + 80, .width = 180, .height = 30 }, @as([*:0]u8, @ptrCast(&gui.Amin.value)), 63, gui.Amin.editMode) != 0) gui.Amin.editMode = !gui.Amin.editMode;

        _ = rg.guiLabel(.{ .x = 10, .y = barHeight + 120, .width = 180, .height = 10 }, "Amax");
        if (rg.guiTextBox(.{ .x = 10, .y = barHeight + 135, .width = 180, .height = 30 }, @as([*:0]u8, @ptrCast(&gui.Amax.value)), 63, gui.Amax.editMode) != 0) gui.Amax.editMode = !gui.Amax.editMode;

        _ = rg.guiLabel(.{ .x = 10, .y = barHeight + 175, .width = 180, .height = 10 }, "f");
        if (rg.guiTextBox(.{ .x = 10, .y = barHeight + 190, .width = 180, .height = 30 }, @as([*:0]u8, @ptrCast(&gui.f.value)), 63, gui.f.editMode) != 0) gui.f.editMode = !gui.f.editMode;

        _ = rg.guiLabel(.{ .x = 10, .y = barHeight + 230, .width = 30, .height = 10 }, "Skog");
        _ = rg.guiCheckBox(.{ .x = 10, .y = barHeight + 245, .width = 30, .height = 30 }, "", &gui.inForest.value);
        _ = rg.guiLabel(.{ .x = 50, .y = barHeight + 230, .width = 100, .height = 10 }, "Skogsavstånd");
        if (rg.guiTextBox(.{ .x = 50, .y = barHeight + 245, .width = 140, .height = 30 }, @as([*:0]u8, @ptrCast(&gui.forstDist.value)), 63, gui.forstDist.editMode) != 0) gui.forstDist.editMode = !gui.forstDist.editMode;

        _ = rg.guiLabel(.{ .x = 10, .y = barHeight + 340, .width = 30, .height = 10 }, "Fast");
        _ = rg.guiCheckBox(.{ .x = 10, .y = barHeight + 355, .width = 30, .height = 30 }, "", &gui.targetType.value);

        _ = rg.guiLabel(.{ .x = 50, .y = barHeight + 340, .width = 140, .height = 10 }, "Ammunitionstyp");
        if (rg.guiDropdownBox(.{ .x = 50, .y = barHeight + 355, .width = 140, .height = 30 }, weapons.AmmunitionType.allNames, &gui.ammunitionType.value, gui.ammunitionType.editMode) != 0) gui.ammunitionType.editMode = !gui.ammunitionType.editMode;

        _ = rg.guiLabel(.{ .x = 10, .y = barHeight + 285, .width = 180, .height = 10 }, "Vapentyp");
        if (rg.guiDropdownBox(.{ .x = 10, .y = barHeight + 300, .width = 180, .height = 30 }, weapons.Weapons.allNames, &gui.weaponType.value, gui.weaponType.editMode) != 0) gui.weaponType.editMode = !gui.weaponType.editMode;
    }

    pub fn drawMenuBOX(self: *Menu) void {
        // Menu Bar
        rl.drawRectangle(self.origin.x - 1, self.origin.y, barWidth + 1, barHeight + 1, rl.Color.black);
        rl.drawRectangle(self.origin.x, self.origin.y, barWidth, barHeight, rl.Color.light_gray);

        rl.drawRectangle(self.origin.x + barWidth - 1, self.origin.y, barWidth + 1, barHeight, rl.Color.black);
        rl.drawRectangle(self.origin.x + barWidth, self.origin.y, barWidth, barHeight, rl.Color.white);

        _ = rg.guiLabel(.{ .x = 10, .y = barHeight + 10, .width = 30, .height = 10 }, "TBA");

        // Input fields
    }
};
