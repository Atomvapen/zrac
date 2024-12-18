const std = @import("std");
const state = @import("../risk/state.zig");
const rl = @import("raylib");
const camera_fn = @import("camera.zig");
const drawLines = @import("draw.zig").drawLines;

var camera = rl.Camera2D{
    .target = .{ .x = 0, .y = 0 },
    .offset = .{ .x = 0, .y = 0 },
    .zoom = 1.0,
    .rotation = 0,
};

pub fn render(allocator: std.mem.Allocator, riskProfile: *state.riskState) !void {
    rl.clearBackground(rl.Color.ray_white);

    { // Moveable UI
        camera.begin();
        defer camera.end();

        rl.gl.rlPushMatrix();
        rl.gl.rlTranslatef(0, 50 * 50, 0);
        rl.gl.rlRotatef(90, 1, 0, 0);
        rl.drawGrid(200, 100);
        rl.gl.rlPopMatrix();

        if (riskProfile.showLines == true and riskProfile.valid == true) drawLines(riskProfile);
    }

    { // Static UI
        try riskProfile.menu.drawMenu(allocator, riskProfile);
        if (riskProfile.showPanel == true) try riskProfile.menu.drawInfoPanel(riskProfile.*, allocator);
    }
}

pub fn init() !void {
    const screenWidth: i32 = 800;
    const screenHeight: i32 = 800;

    rl.initWindow(screenWidth, screenHeight, "Risk");
    rl.setTargetFPS(15);
    rl.setExitKey(.key_escape);
}

pub fn deinit() void {
    rl.closeWindow();
}

pub fn update(_: std.mem.Allocator, riskProfile: *state.riskState) !void {
    try riskProfile.update();
}

pub fn main(allocator: std.mem.Allocator) !void {
    var riskProfile: state.riskState = undefined;
    try riskProfile.init();

    while (!rl.windowShouldClose()) {
        camera_fn.handleCamera(&camera);

        try update(allocator, &riskProfile);

        rl.beginDrawing();
        defer rl.endDrawing();

        try render(allocator, &riskProfile);
    }
}
