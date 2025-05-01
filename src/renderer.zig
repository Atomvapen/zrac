const zgui = @import("zgui");
const zgpu = @import("zgpu");
const zglfw = @import("zglfw");

const Context = @import("Context.zig");
const Window = @import("gui/Window.zig");
const ContextMenu = @import("gui/ContextMenu.zig");

var camera: Camera2D = undefined;
var grid: Grid = undefined;

pub fn init(ctx: *Context) void {
    grid = Grid.init(100, 100, 200, 150);
    camera = ctx.camera;
}

pub fn beginFrame(ctx: *Context) void {
    zglfw.pollEvents();

    zgui.backend.newFrame(
        ctx.gctx.swapchain_descriptor.width,
        ctx.gctx.swapchain_descriptor.height,
    );
}

pub fn update(ctx: *Context) void {
    Window.Drag.handle(ctx.window);
    camera.update(ctx);

    grid.draw();
    grid.addLine(10.0, 10.0, 50.0, 50.0, 0xFFFF0000); // Red line
    grid.addRect(10.0, 10.0, 50.0, 50.0, 0xFF00FF00, 5.0, 2.0);
    grid.addCircle(20.0, 20.0, 15.0, 0xFF0000FF); // Blue circle

    Window.draw(ctx);
    ContextMenu.draw(ctx);
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

    pub fn scrollCallback(window: *zglfw.Window, xoffset: f64, yoffset: f64) callconv(.C) void {
        _ = xoffset;

        const mousePos: [2]f64 = window.getCursorPos();
        const screenPos: [2]f32 = .{
            @floatCast(mousePos[0]),
            @floatCast(mousePos[1]),
        };

        camera.zoomToward(screenPos, @floatCast(yoffset * 0.1));
    }

    pub fn zoomToward(self: *Camera2D, screenPos: [2]f32, zoomDelta: f32) void {
        const oldZoom = self.zoom;
        self.zoom = @max(@min(self.zoom + zoomDelta, 1.0), 0.1);
        const zoomFactor = self.zoom / oldZoom;

        self.offsetX = screenPos[0] - (screenPos[0] - self.offsetX) * zoomFactor;
        self.offsetY = screenPos[1] - (screenPos[1] - self.offsetY) * zoomFactor;
    }

    pub fn update(self: *Camera2D, ctx: *Context) void {
        const mousePos: [2]f64 = ctx.window.getCursorPos();
        const mouseX: f64 = mousePos[0];
        const mouseY: f64 = mousePos[1];

        if (mouseY < 25 or Context.Window.Drag.dragging) return;

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
    const cellSize: f32 = 40.0;
    const gridSize: usize = 100;

    x: f64,
    y: f64,
    width: f32,
    height: f32,
    isDragging: bool,
    dragOffsetX: f64,
    dragOffsetY: f64,

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

    pub fn addRect(_: *Grid, x1: f32, y1: f32, x2: f32, y2: f32, color: u32, rounding: f32, thickness: f32) void {
        const draw_list = zgui.getBackgroundDrawList();

        // Convert rectangle corners from world space to screen space
        const screen_pmin = camera.worldToScreen(.{ x1, y1 });
        const screen_pmax = camera.worldToScreen(.{ x2, y2 });

        // Add rectangle to the draw list
        draw_list.addRect(.{
            .pmin = .{ screen_pmin[0], screen_pmin[1] },
            .pmax = .{ screen_pmax[0], screen_pmax[1] },
            .col = color,
            .rounding = rounding,
            .flags = .{}, // No flags (can be customized if needed)
            .thickness = thickness,
        });
    }

    pub fn addLine(_: *Grid, x1: f32, y1: f32, x2: f32, y2: f32, color: u32) void {
        const draw_list = zgui.getBackgroundDrawList();

        // Convert line start and end points from screen space to world space
        const start: [2]f32 = camera.worldToScreen(.{ x1, y1 });
        const end: [2]f32 = camera.worldToScreen(.{ x2, y2 });

        // Draw the line using transformed world-space coordinates
        draw_list.addLine(.{
            .p1 = .{ start[0], start[1] },
            .p2 = .{ end[0], end[1] },
            .col = color,
            .thickness = 2.0,
        });
    }

    pub fn addCircle(_: *Grid, cx: f32, cy: f32, radius: f32, color: u32) void {
        const draw_list = zgui.getBackgroundDrawList();

        // Convert center position from world space to screen space
        const center = camera.worldToScreen(.{ cx, cy });

        draw_list.addCircle(.{
            .p = .{ center[0], center[1] },
            .r = radius * camera.zoom, // Consider zoom
            .col = color,
            .num_segments = 36, // Number of segments (higher is smoother)
            .thickness = 2.0,
        });
    }

    pub fn draw(_: *Grid) void {
        const draw_list = zgui.getBackgroundDrawList();
        const color: u32 = 0xFFAAAAAA;

        for (0..gridSize) |i| {
            const pos = @as(f32, @floatFromInt(i)) * cellSize;

            // Vertical lines
            const v1 = camera.worldToScreen(.{ pos, 0.0 });
            const v2 = camera.worldToScreen(.{ pos, cellSize * gridSize });

            draw_list.addLine(.{
                .p1 = .{ v1[0], v1[1] },
                .p2 = .{ v2[0], v2[1] },
                .col = color,
                .thickness = 1.0,
            });

            // Horizontal lines
            const h1 = camera.worldToScreen(.{ 0.0, pos });
            const h2 = camera.worldToScreen(.{ cellSize * gridSize, pos });

            draw_list.addLine(.{
                .p1 = .{ h1[0], h1[1] },
                .p2 = .{ h2[0], h2[1] },
                .col = color,
                .thickness = 1.0,
            });
        }
    }
};
