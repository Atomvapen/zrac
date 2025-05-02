const Self = @This();
const std = @import("std");
const zgui = @import("zgui");
const zgpu = @import("zgpu");
const zglfw = @import("zglfw");

pub const Window = @import("gui/Window.zig");
const Camera2D = @import("gui/Camera.zig");
const Grid = @import("gui/Grid.zig");
const ContextMenu = @import("gui/ContextMenu.zig");
const Modal = @import("gui/Modal.zig");

const CreateContextError = error{
    FailedToCreateGraphicsContext,
    OutOfMemory,
} || Window.CreateWindowError;

gctx: *zgpu.GraphicsContext,
draw_list: zgui.DrawList,
allocator: std.mem.Allocator,
window: *zglfw.Window,
camera: Camera2D,
grid: Grid,
contextMenu: ContextMenu,
modal: ?Modal,

pub fn create(allocator: std.mem.Allocator) CreateContextError!*Self {
    std.log.info("[zrac] Creating Context", .{});
    std.log.info("[zrac]   Creating context object", .{});
    const context: *Self = allocator.create(Self) catch return CreateContextError.OutOfMemory;

    std.log.info("[zrac]   Creating window", .{});
    const window: *zglfw.Window = try Window.init(context);
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
    }, .{}) catch return CreateContextError.FailedToCreateGraphicsContext;
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

    std.log.info("[zrac]   Settings context object fields", .{});
    context.* = .{
        .gctx = gctx,
        .draw_list = zgui.createDrawList(),
        .allocator = allocator,
        .window = window,
        .camera = .{},
        .grid = Grid.init(40, 100),
        .contextMenu = .{},
        .modal = null,
    };
    errdefer context.destroy(allocator);

    return context;
}

pub fn destroy(self: *Self, allocator: std.mem.Allocator) void {
    std.log.info("[zrac] Destroying Context", .{});
    std.log.info("[zrac]   Destroying window", .{});
    self.window.destroy();
    std.log.info("[zrac]   Deinitializing ZGUI backend", .{});
    zgui.backend.deinit();
    std.log.info("[zrac]   Destroying drawlist", .{});
    zgui.destroyDrawList(self.draw_list);
    std.log.info("[zrac]   Deinitializing ZGUI", .{});
    zgui.deinit();
    std.log.info("[zrac]   Destroying Graphics Context", .{});
    self.gctx.destroy(allocator);
    std.log.info("[zrac]   Destroying Context object", .{});
    allocator.destroy(self);
}
