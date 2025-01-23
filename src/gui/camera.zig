const rl = @import("raylib");

pub var enabled: bool = true;

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
    zoomTowardMouse();
}

fn move() void {
    const button = rl.isMouseButtonDown(.right);
    if (!button) return;

    var delta = rl.getMouseDelta();
    delta = rl.math.vector2Scale(delta, -1.0 / camera.zoom);
    camera.target = rl.math.vector2Add(camera.target, delta);
}

fn zoom() void {
    const MIN_ZOOM: f32 = 0.125;
    const MAX_ZOOM: f32 = 1.0;

    const wheel = rl.getMouseWheelMove();
    if (wheel == 0) return;

    const mouseWorldPos = rl.getScreenToWorld2D(rl.getMousePosition(), camera);
    camera.offset = rl.getMousePosition();
    camera.target = mouseWorldPos;
    var scaleFactor = 1.0 + (0.25 * @abs(wheel));
    if (wheel < 0) scaleFactor = 1.0 / scaleFactor;
    camera.zoom = rl.math.clamp(camera.zoom * scaleFactor, MIN_ZOOM, MAX_ZOOM);
}

fn zoomTowardMouse() void {
    const MIN_ZOOM: f32 = 0.125;
    const MAX_ZOOM: f32 = 1.0;

    const wheel = rl.getMouseWheelMove();
    if (wheel == 0) return;

    const mouseWorldPos = rl.getScreenToWorld2D(rl.getMousePosition(), camera);
    camera.zoom *= if (wheel > 0) 1.25 else 0.8;
    camera.zoom = rl.math.clamp(camera.zoom, MIN_ZOOM, MAX_ZOOM);

    const newMouseWorldPos = rl.getScreenToWorld2D(rl.getMousePosition(), camera);
    const delta = rl.math.vector2Subtract(mouseWorldPos, newMouseWorldPos);
    camera.target = rl.math.vector2Add(camera.target, delta);
}
