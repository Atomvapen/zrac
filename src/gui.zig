const std = @import("std");
const risk = @import("risk.zig");
// const weapons = @import("weapons.zig");
const rl = @import("raylib");
const rg = @import("raygui");
const geo = @import("geo_calculations.zig");

const screenWidth: i32 = 800;
const screenHeight: i32 = 800;

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

    Amin: textBoxState, //.{ .editMode = false, .value = std.mem.zeroes([64]u8) },
    Amax: textBoxState, //.{ .editMode = false, .value = std.mem.zeroes([64]u8) },
    f: textBoxState, //.{ .editMode = false, .value = std.mem.zeroes([64]u8) },
    forestDist: textBoxState, //.{ .editMode = false, .value = std.mem.zeroes([64]u8) },
    show: checkBoxState, //.{ .value = true },
    inForest: checkBoxState, //.{ .value = false },
    riskFactor: comboBoxState, //.{ .value = 0 },
    ammunitionType: dropdownBoxState, //.{ .editMode = false, .value = 0 },
    weaponType: dropdownBoxState, //.{ .editMode = false, .value = 0 },
    targetType: checkBoxState, //.{ .value = false },
    menu: Menu, //.{ .page = 1, .origin = rl.Vector2{ .x = 0, .y = 1 } },
    infoPanel: checkBoxState, //.{ .value = false },

    pub fn reset(self: *guiState) void {
        try self.init();
    }

    pub fn init(self: *guiState) !void {
        self.Amin = .{ .editMode = false, .value = std.mem.zeroes([64]u8) };
        self.Amax = .{ .editMode = false, .value = std.mem.zeroes([64]u8) };
        self.f = .{ .editMode = false, .value = std.mem.zeroes([64]u8) };
        self.forestDist = .{ .editMode = false, .value = std.mem.zeroes([64]u8) };
        self.show = .{ .value = true };
        self.inForest = .{ .value = false };
        self.riskFactor = .{ .value = 0 };
        self.ammunitionType = .{ .editMode = false, .value = 0 };
        self.weaponType = .{ .editMode = false, .value = 0 };
        self.targetType = .{ .value = false };

        try self.menu.init();
        gui.show.value = true;
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

pub fn update(_: std.mem.Allocator, riskProfile: *risk.RiskArea) !void {
    try riskProfile.update(gui);
    // riskProfile.validate();
}

pub fn render(allocator: std.mem.Allocator, riskProfile: *risk.RiskArea) !void {
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

        if (gui.show.value == true and riskProfile.valid == true) drawLines(riskProfile.*);
    }

    // Static UI
    {
        try gui.menu.drawMenu(allocator, riskProfile);
        if (gui.infoPanel.value == true) try gui.menu.drawInfoPanel(riskProfile.*, allocator);
    }
}

pub fn main(allocator: std.mem.Allocator) !void {
    var riskProfile: risk.RiskArea = undefined;
    riskProfile.valid = false;

    while (!rl.windowShouldClose()) {
        handleCamera();

        try update(allocator, &riskProfile);

        rl.beginDrawing();
        defer rl.endDrawing();

        try render(allocator, &riskProfile);
    }
}

fn drawLines(riskProfile: risk.RiskArea) void {
    // Origin
    const origin: rl.Vector2 = rl.Vector2{ .x = @as(f32, @floatFromInt(screenWidth)) / 2, .y = @as(f32, @floatFromInt(screenHeight)) - 50 };

    // h
    var h: geo.Line = try geo.Line.init(rl.Vector2{
        .x = origin.x,
        .y = origin.y,
    }, rl.Vector2{
        .x = origin.x,
        .y = origin.y - @as(f32, @floatFromInt(riskProfile.h)),
    }, false, undefined);
    h.drawLine();
    h.drawText("h", 0, -30, 30);

    // Amin
    var Amin: geo.Line = try geo.Line.init(rl.Vector2{
        .x = undefined,
        .y = undefined,
    }, rl.Vector2{
        .x = origin.x,
        .y = origin.y - @as(f32, @floatFromInt(riskProfile.Amin)),
    }, false, undefined);
    Amin.drawText("Amin", -70, 0, 30);

    // v
    var v: geo.Line = try geo.Line.init(rl.Vector2{
        .x = origin.x,
        .y = origin.y,
    }, rl.Vector2{
        .x = origin.x,
        .y = origin.y - @as(f32, @floatFromInt(riskProfile.h)),
    }, true, riskProfile.v);
    v.drawLine();
    v.drawText("v", -5, -30, 30);

    if (riskProfile.f > riskProfile.Amin) return;
    var f: geo.Line = try geo.Line.init(rl.Vector2{
        .x = origin.x,
        .y = origin.y - @as(f32, @floatFromInt(riskProfile.Amin)) + @as(f32, @floatFromInt(riskProfile.f)),
    }, rl.Vector2{
        .x = origin.x,
        .y = Amin.end.y + (@as(f32, @floatFromInt(riskProfile.f)) + 50.0),
    }, false, undefined);
    f.drawText("f", -30, -70, 30);

    // q1
    var q1: geo.Line = try geo.Line.init(rl.Vector2{
        .x = geo.calculateXfromAngle(riskProfile.Amin - riskProfile.f, v.angle) + origin.x,
        .y = origin.y - @as(f32, @floatFromInt(riskProfile.Amin)) + @as(f32, @floatFromInt(riskProfile.f)),
    }, rl.Vector2{
        .x = v.end.x,
        .y = v.end.y,
    }, true, riskProfile.q1);

    // h -> v
    var hv: geo.Line = try geo.Line.init(rl.Vector2{
        .x = origin.x,
        .y = origin.y,
    }, rl.Vector2{
        .x = undefined,
        .y = undefined,
    }, false, riskProfile.v);
    hv.drawCircleSector(@as(f32, @floatFromInt(riskProfile.h)));

    // ch
    var ch: geo.Line = try geo.Line.init(rl.Vector2{
        .x = v.end.x,
        .y = v.end.y,
    }, rl.Vector2{
        .x = v.end.x - 30000.0,
        .y = v.end.y - 30000.0,
    }, true, riskProfile.ch);

    if (riskProfile.inForest == false and riskProfile.forestDist <= 0) {
        ch.endAtIntersection(q1);
        // ch.drawLine();
        // ch.drawText("ch", -5, -20, 30);

        q1.endAtIntersection(ch);
        // q1.drawLine();
        // q1.drawText("q1", 15, 0, 30);

        // c
        var c: geo.Line = try geo.getParallelLine(v, riskProfile.c);
        c.startAtIntersection(q1);
        c.endAtIntersection(ch);
        // c.drawLine();

        if (riskProfile.factor > 0) {
            q1.end = c.start;
            ch.end = c.end;
            c.drawLine();
        }

        q1.drawLine();
        q1.drawText("q1", 15, 0, 30);
        ch.drawLine();
        ch.drawText("ch", -5, -20, 30);
    }

    // q2
    if (riskProfile.inForest == true) {
        // q2
        var q2: geo.Line = try geo.Line.init(rl.Vector2{
            .x = origin.x,
            .y = origin.y,
        }, rl.Vector2{
            .x = v.end.x,
            .y = v.end.y,
        }, true, riskProfile.q2);

        var c: geo.Line = try geo.getParallelLine(v, riskProfile.c);
        c.startAtIntersection(q2);

        ch.endAtIntersection(c);
        ch.drawLine();
        ch.drawText("ch", -5, -20, 30);

        c.end = ch.end;
        // c.end.y = ch.end.y;
        c.drawLine();

        q2.end = c.start;
        q2.drawLine();
        q2.drawText("q2", 25, 0, 30);
    } else if (riskProfile.forestDist > 0 and riskProfile.forestDist <= riskProfile.h) {
        // forestMin
        var forestMin: geo.Line = try geo.Line.init(rl.Vector2{
            .x = undefined,
            .y = undefined,
        }, rl.Vector2{
            .x = origin.x,
            .y = origin.y - @as(f32, @floatFromInt(riskProfile.forestDist)),
        }, false, undefined);
        forestMin.drawText("forestMin", -65, -70, 30);

        // q2
        var q2: geo.Line = try geo.Line.init(rl.Vector2{
            .x = geo.calculateXfromAngle(riskProfile.forestDist, v.angle) + origin.x,
            .y = origin.y - @as(f32, @floatFromInt(riskProfile.forestDist)),
        }, rl.Vector2{
            .x = v.end.x,
            .y = v.end.y,
        }, true, riskProfile.q2);

        var c: geo.Line = try geo.getParallelLine(v, riskProfile.c);
        c.startAtIntersection(q2);

        ch.endAtIntersection(c);
        ch.drawLine();
        ch.drawText("ch", -5, -20, 30);

        c.endAtIntersection(ch);
        c.drawLine();

        q2.endAtIntersection(c);
        q2.drawLine();
        q2.drawText("q2", 25, 0, 30);
    }
}

pub const Menu = struct {
    pub const barWidth = 100;
    pub const barHeight = 30;

    page: i8, //TODO: måste ha en getPage istället så att denna inte kan ändras hur som
    origin: rl.Vector2,

    pub fn init(self: *Menu) !void {
        self.origin = rl.Vector2{
            .x = 0,
            .y = 1,
        };
        self.page = 1;
    }

    pub fn setPage(self: *Menu, value: i8) void {
        if (value != self.page) gui.reset();
        self.page = value;
    }

    pub fn drawMenu(self: *Menu, allocator: std.mem.Allocator, riskProfile: *risk.RiskArea) !void {
        //Pane
        rl.drawRectangle(@as(i32, @intFromFloat(self.origin.x)), @as(i32, @intFromFloat(self.origin.y)), (barWidth * 2), screenHeight, rl.Color.white);
        rl.drawRectangle(@as(i32, @intFromFloat(self.origin.x)) + (barWidth * 2), @as(i32, @intFromFloat(self.origin.y)), 1, screenHeight, rl.Color.black);
        rl.drawRectangle(@as(i32, @intFromFloat(self.origin.x)), @as(i32, @intFromFloat(self.origin.y)) - 1, (barWidth * 2), 1, rl.Color.black);

        // Switch Page
        switch (self.page) {
            1 => self.drawMenuSST(riskProfile),
            2 => self.drawMenuBOX(),
            else => return,
        }

        // Show calculations
        _ = rg.guiLabel(.{ .x = 10, .y = 740 - 10 - 15 - 30, .width = 180, .height = 10 }, "Visa beräknade värden");
        _ = rg.guiCheckBox(.{ .x = 10, .y = 740 - 10 - 30, .width = 30, .height = 30 }, "", &gui.infoPanel.value);

        // Reset button
        if (rg.guiButton(.{ .x = 10, .y = 740, .width = 180, .height = 30 }, "Nollställ") == 1) gui.reset();

        // Switch page buttons
        if (rg.guiLabelButton(.{ .x = 0 + 40, .y = 10, .width = 10, .height = 10 }, "SST") == 1) gui.menu.setPage(1);
        if (rg.guiLabelButton(.{ .x = 0 + barWidth + 40, .y = 10, .width = 10, .height = 10 }, "BOX") == 1) gui.menu.setPage(2);

        // Status bar
        {
            const mouse_pos = rl.getMousePosition();
            const string = try std.fmt.allocPrintZ(allocator, "ZRAC v0.0.1 | x: {d} y: {d}", .{ mouse_pos.x, mouse_pos.y });

            defer allocator.free(string);

            _ = rg.guiStatusBar(.{ .x = 0, .y = @as(f32, @floatFromInt(screenHeight - 20)), .width = @as(f32, @floatFromInt(screenWidth)), .height = 20 }, string);
        }
    }

    pub fn drawInfoPanel(self: *Menu, riskProfile: risk.RiskArea, allocator: std.mem.Allocator) !void {
        _ = self;

        const infoPanelXOffset: i32 = 10;
        const infoPanelWidth: i32 = 100;
        const infoPanelHeight: i32 = 150;

        _ = rg.guiPanel(.{ .x = screenWidth - infoPanelWidth - infoPanelXOffset, .y = 10, .width = infoPanelWidth, .height = infoPanelHeight }, "Values");

        const c_string = try std.fmt.allocPrintZ(allocator, "c:  {d}", .{riskProfile.c});
        defer allocator.free(c_string);
        _ = rg.guiLabel(.{ .x = screenWidth - infoPanelWidth - infoPanelXOffset + 10, .y = 10 + 30, .width = 180, .height = 10 }, c_string);

        const l_string = try std.fmt.allocPrintZ(allocator, "l:  {d}", .{riskProfile.l});
        defer allocator.free(l_string);
        _ = rg.guiLabel(.{ .x = screenWidth - infoPanelWidth - infoPanelXOffset + 10, .y = 10 + 30 + 15, .width = 180, .height = 10 }, l_string);

        const h_string = try std.fmt.allocPrintZ(allocator, "h:  {d}", .{riskProfile.h});
        defer allocator.free(h_string);
        _ = rg.guiLabel(.{ .x = screenWidth - infoPanelWidth - infoPanelXOffset + 10, .y = 10 + 30 + 15 + 15, .width = 180, .height = 10 }, h_string);

        const q1_string = try std.fmt.allocPrintZ(allocator, "q1: {d}", .{riskProfile.q1});
        defer allocator.free(q1_string);
        _ = rg.guiLabel(.{ .x = screenWidth - infoPanelWidth - infoPanelXOffset + 10, .y = 10 + 30 + 15 + 15 + 15, .width = 180, .height = 10 }, q1_string);

        const q2_string = try std.fmt.allocPrintZ(allocator, "q2: {d}", .{riskProfile.q2});
        defer allocator.free(q2_string);
        _ = rg.guiLabel(.{ .x = screenWidth - infoPanelWidth - infoPanelXOffset + 10, .y = 10 + 30 + 15 + 15 + 15 + 15, .width = 180, .height = 10 }, q2_string);
    }

    pub fn drawMenuSST(self: *Menu, riskProfile: *risk.RiskArea) void {
        _ = riskProfile;
        // Menu Bar
        rl.drawRectangle(@as(i32, @intFromFloat(self.origin.x)), @as(i32, @intFromFloat(self.origin.y)), barWidth + 1, barHeight, rl.Color.black);
        rl.drawRectangle(@as(i32, @intFromFloat(self.origin.x)), @as(i32, @intFromFloat(self.origin.y)), barWidth, barHeight, rl.Color.white);

        rl.drawRectangle(@as(i32, @intFromFloat(self.origin.x)) + barWidth - 1, @as(i32, @intFromFloat(self.origin.y)), barWidth + 1, barHeight + 1, rl.Color.black);
        rl.drawRectangle(@as(i32, @intFromFloat(self.origin.x)) + barWidth, @as(i32, @intFromFloat(self.origin.y)), barWidth, barHeight, rl.Color.light_gray);

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
        // _ = rg.guiCheckBox(.{ .x = 10, .y = barHeight + 245, .width = 30, .height = 30 }, "", &riskProfile.inForest);

        _ = rg.guiLabel(.{ .x = 50, .y = barHeight + 230, .width = 100, .height = 10 }, "Skogsavstånd");
        if (rg.guiTextBox(.{ .x = 50, .y = barHeight + 245, .width = 140, .height = 30 }, @as([*:0]u8, @ptrCast(&gui.forestDist.value)), 63, gui.forestDist.editMode) != 0) gui.forestDist.editMode = !gui.forestDist.editMode;

        _ = rg.guiLabel(.{ .x = 10, .y = barHeight + 340, .width = 30, .height = 10 }, "Fast");
        _ = rg.guiCheckBox(.{ .x = 10, .y = barHeight + 355, .width = 30, .height = 30 }, "", &gui.targetType.value);
        // _ = rg.guiCheckBox(.{ .x = 10, .y = barHeight + 355, .width = 30, .height = 30 }, "", &riskProfile.fixedTarget);

        _ = rg.guiLabel(.{ .x = 50, .y = barHeight + 340, .width = 140, .height = 10 }, "Ammunitionstyp");
        if (rg.guiDropdownBox(.{ .x = 50, .y = barHeight + 355, .width = 140, .height = 30 }, risk.WeaponArsenal.allAmmunitionNames, &gui.ammunitionType.value, gui.ammunitionType.editMode) != 0) gui.ammunitionType.editMode = !gui.ammunitionType.editMode;

        _ = rg.guiLabel(.{ .x = 10, .y = barHeight + 285, .width = 180, .height = 10 }, "Vapentyp");
        if (rg.guiDropdownBox(.{ .x = 10, .y = barHeight + 300, .width = 180, .height = 30 }, risk.WeaponArsenal.names, &gui.weaponType.value, gui.weaponType.editMode) != 0) gui.weaponType.editMode = !gui.weaponType.editMode;
    }

    pub fn drawMenuBOX(self: *Menu) void {
        // Menu Bar
        rl.drawRectangle(@as(i32, @intFromFloat(self.origin.x)) - 1, @as(i32, @intFromFloat(self.origin.y)), barWidth + 1, barHeight + 1, rl.Color.black);
        rl.drawRectangle(@as(i32, @intFromFloat(self.origin.x)), @as(i32, @intFromFloat(self.origin.y)), barWidth, barHeight, rl.Color.light_gray);

        rl.drawRectangle(@as(i32, @intFromFloat(self.origin.x)) + barWidth - 1, @as(i32, @intFromFloat(self.origin.y)), barWidth + 1, barHeight, rl.Color.black);
        rl.drawRectangle(@as(i32, @intFromFloat(self.origin.x)) + barWidth, @as(i32, @intFromFloat(self.origin.y)), barWidth, barHeight, rl.Color.white);

        _ = rg.guiLabel(.{ .x = 10, .y = barHeight + 10, .width = 30, .height = 10 }, "TBA");

        // Input fields
    }
};
