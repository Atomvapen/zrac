const Self = @This();

const std = @import("std");
const zgui = @import("zgui");
const zgpu = @import("zgpu");
const zglfw = @import("zglfw");

pub const Window = @import("gui/Window.zig"); //TODO make not pub

const Camera2D = @import("renderer.zig").Camera2D;

const CreateError = error{
    FailedToCreateGraphicsContext,
    OutOfMemory,
};
const ContextError = CreateError || Window.WindowError;

gctx: *zgpu.GraphicsContext,
draw_list: zgui.DrawList,
allocator: std.mem.Allocator,
window: *zglfw.Window,
camera: Camera2D,

pub fn create(allocator: std.mem.Allocator) ContextError!*Self {
    std.log.info("[zrac] Creating Context", .{});
    std.log.info("[zrac]   Creating window", .{});
    const window: *zglfw.Window = try Window.init();
    errdefer window.destroy();

    std.log.info("[zrac]   Creating Graphics Context", .{});
    const gctx: *zgpu.GraphicsContext = zgpu.GraphicsContext.create(allocator, .{
        .window = window,
        .fn_getTime = @ptrCast(&zglfw.getTime),
        .fn_getFramebufferSize = @ptrCast(&zglfw.Window.getFramebufferSize),
        .fn_getWin32Window = @ptrCast(&zglfw.getWin32Window),
        .fn_getX11Display = @ptrCast(&zglfw.getX11Display),
        .fn_getX11Window = @ptrCast(&zglfw.getX11Window),
        .fn_getWaylandDisplay = @ptrCast(&zglfw.getWaylandDisplay),
        .fn_getWaylandSurface = @ptrCast(&zglfw.getWaylandWindow),
        .fn_getCocoaWindow = @ptrCast(&zglfw.getCocoaWindow),
    }, .{}) catch return CreateError.FailedToCreateGraphicsContext;
    errdefer gctx.destroy(allocator);

    std.log.info("[zrac]   Initializing ZGUI", .{});
    zgui.init(allocator);
    errdefer zgui.deinit();

    std.log.info("[zrac]   Initializing ZGUI backend", .{});
    zgui.backend.init(
        window,
        gctx.device,
        @intFromEnum(zgpu.GraphicsContext.swapchain_format),
        @intFromEnum(zgpu.wgpu.TextureFormat.undef),
    );
    errdefer zgui.backend.deinit();

    std.log.info("[zrac]   Setting ZGUI style", .{});
    const scale: [2]f32 = window.getContentScale();
    const scale_factor: f32 = if (scale[0] > scale[1]) scale[0] else scale[1];
    const style: *zgui.Style = zgui.getStyle();
    style.scaleAllSizes(scale_factor);

    std.log.info("[zrac]   Creating context object", .{});
    const context: *Self = allocator.create(Self) catch return CreateError.OutOfMemory;
    context.* = .{
        .gctx = gctx,
        .draw_list = zgui.createDrawList(),
        .allocator = allocator,
        .window = window,
        .camera = .{},
    };
    errdefer context.destroy(allocator);

    std.log.info("[zrac]   Initializing window keybinds", .{});
    Window.Keybinds.init(context);

    return context;
}

pub fn destroy(self: *Self, allocator: std.mem.Allocator) void {
    std.log.info("[zrac] Destroying Context", .{});
    std.log.info("[zrac]   Destroying window", .{});
    self.window.destroy();
    std.log.info("[zrac]   Destroying drawlist", .{});
    zgui.destroyDrawList(self.draw_list);
    std.log.info("[zrac]   Deinitializing ZGUI backend", .{});
    zgui.backend.deinit();
    std.log.info("[zrac]   Deinitializing ZGUI", .{});
    zgui.deinit();
    std.log.info("[zrac]   Destroying Graphics Context", .{});
    self.gctx.destroy(allocator);
    std.log.info("[zrac]   Destroying Context object", .{});
    allocator.destroy(self);
}
