const zgui = @import("zgui");
const zgpu = @import("zgpu");
const zglfw = @import("zglfw");

const Context = @import("Context.zig");
const Window = @import("gui/Window.zig");
const ContextMenu = @import("gui/ContextMenu.zig");

pub var camera: Camera2D = .{};
var grid: Grid = undefined;

pub fn init() void {
    grid = Grid.init(100, 100, 200, 150); // Starting position and size
}

pub fn update(ctx: *Context) void {
    Window.Drag.handle(ctx.window);
    camera.update(ctx.window);

    zglfw.pollEvents();

    zgui.backend.newFrame(
        ctx.gctx.swapchain_descriptor.width,
        ctx.gctx.swapchain_descriptor.height,
    );

    grid.draw();
    grid.addLine(10.0, 10.0, 50.0, 50.0, 0xFFFF0000); // Red line

    Window.draw(ctx);
}

pub fn draw(ctx: *Context) void {
    const gctx: *zgpu.GraphicsContext = ctx.gctx;

    const swapchain_texv: zgpu.wgpu.TextureView = gctx.swapchain.getCurrentTextureView();
    defer swapchain_texv.release();

    const commands: zgpu.wgpu.CommandBuffer = commands: {
        const encoder: zgpu.wgpu.CommandEncoder = gctx.device.createCommandEncoder(null);
        defer encoder.release();

        {
            const pass: zgpu.wgpu.RenderPassEncoder = zgpu.beginRenderPassSimple(encoder, .load, swapchain_texv, null, null, null);
            defer zgpu.endReleasePass(pass);
            zgui.backend.draw(pass);
        }

        break :commands encoder.finish(null);
    };
    defer commands.release();

    gctx.submit(&.{commands});
    _ = gctx.present();
}

pub const Camera2D = struct {
    offsetX: f32 = 0,
    offsetY: f32 = 0,
    isDragging: bool = false,
    lastMouseX: f64 = 0,
    lastMouseY: f64 = 0,
    zoom: f32 = 1.0,

    pub fn onScroll(window: *zglfw.Window, xoffset: f64, yoffset: f64) callconv(.C) void {
        _ = xoffset;

        // Calculate mouse position in world space
        const mousePos = window.getCursorPos();
        const mouseX: f32 = @floatCast(mousePos[0]);
        const mouseY: f32 = @floatCast(mousePos[1]);

        // Convert mouse position to world space
        const mouseWorld = camera.screenToWorld(.{ mouseX, mouseY });

        // Calculate new zoom level
        var newZoom: f32 = camera.zoom + @as(f32, @floatCast(yoffset * 0.1));
        if (newZoom < 0.1) {
            newZoom = 0.1;
        } else if (newZoom > 5.0) {
            newZoom = 5.0;
        }

        // Adjust camera offset to zoom toward the mouse position
        const zoomFactor: f32 = @as(f32, @floatCast(newZoom)) / camera.zoom;
        camera.offsetX = mouseWorld[0] - (mouseWorld[0] - camera.offsetX) * zoomFactor;
        camera.offsetY = mouseWorld[1] - (mouseWorld[1] - camera.offsetY) * zoomFactor;

        camera.zoom = newZoom;
    }

    pub fn update(self: *Camera2D, window: *zglfw.Window) void {
        const mousePos = window.getCursorPos();
        const mouseX = mousePos[0];
        const mouseY = mousePos[1];

        if (self.isDragging) {
            self.offsetX += @floatCast(mouseX - self.lastMouseX);
            self.offsetY += @floatCast(mouseY - self.lastMouseY);
        }

        const mouseButton = window.getMouseButton(.left);
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
    pub fn screenToWorld(self: Camera2D, screen: [2]f32) [2]f32 {
        return .{
            (screen[0] - self.offsetX) / self.zoom,
            (screen[1] - self.offsetY) / self.zoom,
        };
    }

    pub fn worldToScreen(self: Camera2D, world: [2]f32) [2]f32 {
        return .{
            world[0] * self.zoom + self.offsetX,
            world[1] * self.zoom + self.offsetY,
        };
    }
};

pub const Grid = struct {
    x: f64,
    y: f64,
    width: f32,
    height: f32,
    isDragging: bool,
    dragOffsetX: f64,
    dragOffsetY: f64,

    const cellSize: f32 = 40.0; // Each cell is 20x20 pixels
    const gridSize: usize = 100;

    pub fn init(x: f64, y: f64, width: f32, height: f32) Grid {
        return Grid{
            .x = x,
            .y = y,
            .width = width,
            .height = height,
            .isDragging = false,
            .dragOffsetX = 0,
            .dragOffsetY = 0,
        };
    }

    pub fn addLine(_: *Grid, x1: f32, y1: f32, x2: f32, y2: f32, color: u32) void {
        const draw_list = zgui.getBackgroundDrawList();

        // Convert line start and end points from screen space to world space
        const start = camera.worldToScreen(.{ x1, y1 });
        const end = camera.worldToScreen(.{ x2, y2 });

        // Draw the line using transformed world-space coordinates
        draw_list.addLine(.{
            .p1 = .{ start[0], start[1] },
            .p2 = .{ end[0], end[1] },
            .col = color,
            .thickness = 2.0,
        });
    }

    pub fn draw(_: *Grid) void {
        const draw_list = zgui.getBackgroundDrawList();

        const color: u32 = 0xFFAAAAAA; // Light gray grid

        for (0..gridSize) |i| {
            const pos = @as(f32, @floatFromInt(i)) * cellSize;

            // Vertical lines (world to screen with zoom and offset)
            draw_list.addLine(.{
                .p1 = .{
                    (pos + camera.offsetX) * camera.zoom,
                    (0.0 + camera.offsetY) * camera.zoom,
                },
                .p2 = .{
                    (pos + camera.offsetX) * camera.zoom,
                    (cellSize * gridSize + camera.offsetY) * camera.zoom,
                },
                .col = color,
                .thickness = 1.0,
            });

            // Horizontal lines
            draw_list.addLine(.{
                .p1 = .{
                    (0.0 + camera.offsetX) * camera.zoom,
                    (pos + camera.offsetY) * camera.zoom,
                },
                .p2 = .{
                    (cellSize * gridSize + camera.offsetX) * camera.zoom,
                    (pos + camera.offsetY) * camera.zoom,
                },
                .col = color,
                .thickness = 1.0,
            });
        }
    }
};
