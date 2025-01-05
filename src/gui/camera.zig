const rl = @import("raylib");

var camera = rl.Camera2D{
    .target = .{ .x = 9e2, .y = -5e2 },
    .offset = .{ .x = 7e2, .y = 2e2 },
    .zoom = 4e-1,
    .rotation = 0,
};

pub fn begin() void {
    camera.begin();
}

pub fn end() void {
    camera.end();
}

pub fn handle() void {
    move();
    zoom();
}

fn move() void {
    const button = rl.isMouseButtonDown(.right);
    if (!button) return;

    var delta = rl.getMouseDelta();
    delta = rl.math.vector2Scale(delta, -1.0 / camera.zoom);
    camera.target = rl.math.vector2Add(camera.target, delta);
}

fn zoom() void {
    const wheel = rl.getMouseWheelMove();
    if (wheel == 0) return;

    const mouseWorldPos = rl.getScreenToWorld2D(rl.getMousePosition(), camera);
    camera.offset = rl.getMousePosition();
    camera.target = mouseWorldPos;
    var scaleFactor = 1.0 + (0.25 * @abs(wheel));
    if (wheel < 0) scaleFactor = 1.0 / scaleFactor;
    camera.zoom = rl.math.clamp(camera.zoom * scaleFactor, 0.125, 1);
}
