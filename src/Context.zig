const Self = @This();

const std = @import("std");
const zgui = @import("zgui");
const zgpu = @import("zgpu");
const zglfw = @import("zglfw");

const Window = @import("gui/Window.zig");

gctx: *zgpu.GraphicsContext,
draw_list: zgui.DrawList,
allocator: std.mem.Allocator,
window: *zglfw.Window,

pub fn create(allocator: std.mem.Allocator) !*Self {
    const window: *zglfw.Window = try Window.init();
    errdefer window.destroy();

    const gctx: *zgpu.GraphicsContext = try zgpu.GraphicsContext.create(allocator, .{
        .window = window,
        .fn_getTime = @ptrCast(&zglfw.getTime),
        .fn_getFramebufferSize = @ptrCast(&zglfw.Window.getFramebufferSize),
        .fn_getWin32Window = @ptrCast(&zglfw.getWin32Window),
        .fn_getX11Display = @ptrCast(&zglfw.getX11Display),
        .fn_getX11Window = @ptrCast(&zglfw.getX11Window),
        .fn_getWaylandDisplay = @ptrCast(&zglfw.getWaylandDisplay),
        .fn_getWaylandSurface = @ptrCast(&zglfw.getWaylandWindow),
        .fn_getCocoaWindow = @ptrCast(&zglfw.getCocoaWindow),
    }, .{});
    errdefer gctx.destroy(allocator);

    zgui.init(allocator);
    errdefer zgui.deinit();

    zgui.backend.init(
        window,
        gctx.device,
        @intFromEnum(zgpu.GraphicsContext.swapchain_format),
        @intFromEnum(zgpu.wgpu.TextureFormat.undef),
    );
    errdefer zgui.backend.deinit();

    const scale: [2]f32 = window.getContentScale();
    const scale_factor: f32 = if (scale[0] > scale[1]) scale[0] else scale[1];
    const style: *zgui.Style = zgui.getStyle();
    style.scaleAllSizes(scale_factor);

    const context: *Self = try allocator.create(Self);

    context.* = .{
        .gctx = gctx,
        .draw_list = zgui.createDrawList(),
        .allocator = allocator,
        .window = window,
    };

    Window.Keybinds.init(context);

    return context;
}

pub fn destroy(self: *Self, allocator: std.mem.Allocator) void {
    self.window.destroy();
    zgui.destroyDrawList(self.draw_list);
    zgui.backend.deinit();
    zgui.deinit();
    self.gctx.destroy(allocator);
    allocator.destroy(self);
}
