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

    const oldZoom: f32 = self.zoom;
    self.zoom = @max(@min(self.zoom + zoomDelta, 1.5), 0.1);
    const zoomFactor = self.zoom / oldZoom;

    self.offsetX = screenPos[0] - (screenPos[0] - self.offsetX) * zoomFactor;
    self.offsetY = screenPos[1] - (screenPos[1] - self.offsetY) * zoomFactor;
}

pub fn update(self: *Self, ctx: *Context) void {
    const mousePos: [2]f64 = ctx.window.getCursorPos();
    if (mousePos[1] < 25 or Window.Drag.dragging or mousePos[0] < 350) return;

    if (self.isDragging) {
        self.offsetX += @floatCast(mousePos[0] - self.lastMouseX);
        self.offsetY += @floatCast(mousePos[1] - self.lastMouseY);
    }

    switch (ctx.window.getMouseButton(.left)) {
        .press => if (!self.isDragging) {
            self.isDragging = true;
            self.lastMouseX = mousePos[0];
            self.lastMouseY = mousePos[1];
        },
        .release => self.isDragging = false,
        else => {},
    }

    self.lastMouseX = mousePos[0];
    self.lastMouseY = mousePos[1];
}

pub fn screenToWorld(self: Self, screen: [2]f32) [2]f32 {
    return .{
        (screen[0] - self.offsetX) / self.zoom,
        (screen[1] - self.offsetY) / self.zoom,
    };
}

pub fn worldToScreen(self: Self, world: [2]f32) [2]f32 {
    return .{
        (world[0] * self.zoom) + self.offsetX,
        (world[1] * self.zoom) + self.offsetY,
    };
}
