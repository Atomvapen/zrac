const rl = @import("raylib");

pub fn init(self: *rl.Camera2D) void {
    self.begin();
    defer self.end();
}

pub fn handleCamera(self: *rl.Camera2D) void {
    if (checkDeadZone()) return;
    moveCamera(self);
    zoomCamera(self);
}

fn moveCamera(self: *rl.Camera2D) void {
    if (rl.isMouseButtonDown(.mouse_button_right)) {
        var delta = rl.getMouseDelta();
        delta = rl.math.vector2Scale(delta, -1.0 / self.zoom);
        self.target = rl.math.vector2Add(self.target, delta);
    }
}

fn zoomCamera(self: *rl.Camera2D) void {
    const wheel = rl.getMouseWheelMove();
    if (wheel != 0) {
        const mouseWorldPos = rl.getScreenToWorld2D(rl.getMousePosition(), self.*);
        self.offset = rl.getMousePosition();
        self.target = mouseWorldPos;
        var scaleFactor = 1.0 + (0.25 * @abs(wheel));
        if (wheel < 0) scaleFactor = 1.0 / scaleFactor;
        self.zoom = rl.math.clamp(self.zoom * scaleFactor, 0.125, 64.0);
    }
}

fn checkDeadZone() bool {
    return if (rl.getMousePosition().x < 200) true else false;
}
