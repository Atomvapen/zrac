const rl = @import("raylib");

pub var enabled: bool = true;

var camera: rl.Camera2D = rl.Camera2D{
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
    if (!enabled) return;
    move();
    zoomTowardMouse();
}

fn move() void {
    const button: bool = rl.isMouseButtonDown(.left);
    if (!button) return;
    if (rl.getMousePosition().y <= 30) return;
    if (rl.getMousePosition().x < 350) return;
    var delta: rl.Vector2 = rl.getMouseDelta();
    delta = rl.math.vector2Scale(delta, -1.0 / camera.zoom);
    camera.target = rl.math.vector2Add(camera.target, delta);
}

fn zoom() void {
    const min_zoom: f32 = 0.125;
    const max_zoom: f32 = 1.0;

    const wheel: f32 = rl.getMouseWheelMove();
    if (wheel == 0) return;

    const mouseWorldPos: rl.Vector2 = rl.getScreenToWorld2D(rl.getMousePosition(), camera);
    camera.offset = rl.getMousePosition();
    camera.target = mouseWorldPos;

    var scaleFactor = 1.0 + (0.25 * @abs(wheel));
    if (wheel < 0) scaleFactor = 1.0 / scaleFactor;
    camera.zoom = rl.math.clamp(camera.zoom * scaleFactor, min_zoom, max_zoom);
}

fn zoomTowardMouse() void {
    const min_zoom: f32 = 0.125;
    const max_zoom: f32 = 1.0;

    const wheel: f32 = rl.getMouseWheelMove();
    if (wheel == 0) return;

    const mouseWorldPos: rl.Vector2 = rl.getScreenToWorld2D(rl.getMousePosition(), camera);
    camera.zoom *= if (wheel > 0) 1.25 else 0.8;
    camera.zoom = rl.math.clamp(camera.zoom, min_zoom, max_zoom);

    const newMouseWorldPos: rl.Vector2 = rl.getScreenToWorld2D(rl.getMousePosition(), camera);
    const delta: rl.Vector2 = rl.math.vector2Subtract(mouseWorldPos, newMouseWorldPos);
    camera.target = rl.math.vector2Add(camera.target, delta);
}
