const Self = @This();
const Context = @import("../Context.zig");
const Window = @import("Window.zig");
const zglfw = @import("zglfw");

offsetX: f32 = 0,
offsetY: f32 = 0,
isDragging: bool = false,
lastMouseX: f64 = 0,
lastMouseY: f64 = 0,
zoom: f32 = 1.0,

pub fn zoomToward(self: *Self, window: *zglfw.Window, zoomDelta: f32) void {
    const mousePos: [2]f64 = window.getCursorPos();
    const screenPos: [2]f32 = .{
        @floatCast(mousePos[0]),
        @floatCast(mousePos[1]),
    };

    const oldZoom = self.zoom;
    self.zoom = @max(@min(self.zoom + zoomDelta, 1.5), 0.1);
    const zoomFactor = self.zoom / oldZoom;

    self.offsetX = screenPos[0] - (screenPos[0] - self.offsetX) * zoomFactor;
    self.offsetY = screenPos[1] - (screenPos[1] - self.offsetY) * zoomFactor;
}

pub fn update(self: *Self, ctx: *Context) void {
    const mousePos: [2]f64 = ctx.window.getCursorPos();
    const mouseX: f64 = mousePos[0];
    const mouseY: f64 = mousePos[1];

    if (mouseY < 25 or Window.Drag.dragging) return;

    if (self.isDragging) {
        self.offsetX += @floatCast(mouseX - self.lastMouseX);
        self.offsetY += @floatCast(mouseY - self.lastMouseY);
    }

    const mouseButton: zglfw.Action = ctx.window.getMouseButton(.left);
    switch (mouseButton) {
        .press => {
            if (!self.isDragging) {
                self.isDragging = true;
                self.lastMouseX = mouseX;
                self.lastMouseY = mouseY;
            }
        },
        .release => self.isDragging = false,
        else => {},
    }

    self.lastMouseX = mouseX;
    self.lastMouseY = mouseY;
}

pub fn screenToWorld(self: Self, screen: [2]f32) [2]f32 {
    return .{
        (screen[0] - self.offsetX) / self.zoom,
        (screen[1] - self.offsetY) / self.zoom,
    };
}

pub fn worldToScreen(self: Self, world: [2]f32) [2]f32 {
    return .{
        world[0] * self.zoom + self.offsetX,
        world[1] * self.zoom + self.offsetY,
    };
}
