const std = @import("std");
const risk = @import("../risk/state.zig");
const rl = @import("raylib");
const state = @import("state.zig");
const geo = @import("../geo/calculations.zig");

pub const screenWidth: i32 = 800;
pub const screenHeight: i32 = 800;

pub var gui: state.guiState = undefined;

var camera = rl.Camera2D{
    .target = .{ .x = 0, .y = 0 },
    .offset = .{ .x = 0, .y = 0 },
    .zoom = 1.0,
    .rotation = 0,
};

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

        if (gui.draw.value == true and riskProfile.valid == true) drawLines(riskProfile.*);
    }

    // Static UI
    {
        try gui.menu.drawMenu(allocator, riskProfile);
        if (gui.showInfoPanel.value == true) try gui.menu.drawInfoPanel(riskProfile.*, allocator);
    }
}

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
        .y = origin.y - riskProfile.h,
    }, false, undefined);
    h.drawLine();
    h.drawText("h", 0, -30, 30);

    // Amin
    var Amin: geo.Line = try geo.Line.init(rl.Vector2{
        .x = undefined,
        .y = undefined,
    }, rl.Vector2{
        .x = origin.x,
        .y = origin.y - riskProfile.Amin,
    }, false, undefined);
    Amin.drawText("Amin", -70, 0, 30);

    // v
    var v: geo.Line = try geo.Line.init(rl.Vector2{
        .x = origin.x,
        .y = origin.y,
    }, rl.Vector2{
        .x = origin.x,
        .y = origin.y - riskProfile.h,
    }, true, riskProfile.v);
    v.drawLine();
    v.drawText("v", -5, -30, 30);

    if (riskProfile.f > riskProfile.Amin) return;
    var f: geo.Line = try geo.Line.init(rl.Vector2{
        .x = origin.x,
        .y = origin.y - riskProfile.Amin + riskProfile.f,
    }, rl.Vector2{
        .x = origin.x,
        .y = Amin.end.y + (riskProfile.f + 50.0),
    }, false, undefined);
    f.drawText("f", -30, -70, 30);

    // q1
    var q1: geo.Line = try geo.Line.init(rl.Vector2{
        .x = geo.calculateXfromAngle(@intFromFloat(riskProfile.Amin - riskProfile.f), v.angle) + origin.x,
        .y = origin.y - riskProfile.Amin + riskProfile.f,
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
    hv.drawCircleSector(riskProfile.h);

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
    } else if (riskProfile.forestDist > 0 and riskProfile.forestDist <= @as(i32, @intFromFloat(riskProfile.h))) {
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
