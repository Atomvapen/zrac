const std = @import("std");

const zglfw = @import("zglfw");
const zgpu = @import("zgpu");
const wgpu = zgpu.wgpu;
const zgui = @import("zgui");

const window_title = "ZRAC";
const window_size = .{ .width = 800, .height = 800 };

const weapon = @import("../data/weapon.zig");
const ammunition = @import("../data/ammunition.zig");

const State = struct {
    gctx: *zgpu.GraphicsContext,
    draw_list: zgui.DrawList,
};

fn create(
    allocator: std.mem.Allocator,
    window: *zglfw.Window,
) !*State {
    const gctx = try zgpu.GraphicsContext.create(
        allocator,
        .{
            .window = window,
            .fn_getTime = @ptrCast(&zglfw.getTime),
            .fn_getFramebufferSize = @ptrCast(&zglfw.Window.getFramebufferSize),
            .fn_getWin32Window = @ptrCast(&zglfw.getWin32Window),
            .fn_getX11Display = @ptrCast(&zglfw.getX11Display),
            .fn_getX11Window = @ptrCast(&zglfw.getX11Window),
            .fn_getWaylandDisplay = @ptrCast(&zglfw.getWaylandDisplay),
            .fn_getWaylandSurface = @ptrCast(&zglfw.getWaylandWindow),
            .fn_getCocoaWindow = @ptrCast(&zglfw.getCocoaWindow),
        },
        .{},
    );
    errdefer gctx.destroy(allocator);

    const scale_factor = scale_factor: {
        const scale = window.getContentScale();
        break :scale_factor @max(scale[0], scale[1]);
    };

    zgui.init(allocator);
    // defer zgui.deinit();

    zgui.backend.init(
        window,
        gctx.device,
        @intFromEnum(zgpu.GraphicsContext.swapchain_format),
        @intFromEnum(wgpu.TextureFormat.undef),
    );
    // defer zgui.backend.deinit();

    zgui.getStyle().scaleAllSizes(scale_factor);

    const draw_list = zgui.createDrawList();

    const demo = try allocator.create(State);
    demo.* = .{
        .gctx = gctx,
        .draw_list = draw_list,
    };

    return demo;
}

fn destroy(
    allocator: std.mem.Allocator,
    demo: *State,
) void {
    zgui.backend.deinit();
    // zgui.plot.deinit();
    zgui.destroyDrawList(demo.draw_list);
    zgui.deinit();
    demo.gctx.destroy(allocator);
    allocator.destroy(demo);
}

pub fn main(
    allocator: std.mem.Allocator,
) !void {
    try zglfw.init();
    defer zglfw.terminate();

    { // Change current working directory to where the executable is located.
        var buffer: [1024]u8 = undefined;
        const path = std.fs.selfExeDirPath(buffer[0..]) catch ".";
        std.posix.chdir(path) catch {};
    }

    zglfw.windowHintTyped(.client_api, .no_api);

    const window = try zglfw.Window.create(window_size.width, window_size.height, window_title, null);
    defer window.destroy();
    window.setSizeLimits(800, 800, 800, 800);

    const demo = try create(allocator, window);
    defer destroy(allocator, demo);

    while (!window.shouldClose() and window.getKey(.escape) != .press) {
        zglfw.pollEvents();
        try update(demo);
        draw(demo);
    }
}
const SimpleEnum = enum {
    first,
    second,
    third,
};
const SparseEnum = enum(i32) {
    first = 10,
    second = 100,
    third = 1000,
};
const NonExhaustiveEnum = enum(i32) {
    first = 10,
    second = 100,
    third = 1000,
    _,
};

fn update(
    demo: *State,
) !void {
    zgui.backend.newFrame(
        demo.gctx.swapchain_descriptor.width,
        demo.gctx.swapchain_descriptor.height,
    );

    // Set the starting window position and size to custom values
    zgui.setNextWindowPos(.{ .x = 20.0, .y = 20.0, .cond = .first_use_ever });
    zgui.setNextWindowSize(.{ .w = -1.0, .h = -1.0, .cond = .first_use_ever });

    if (zgui.begin("Riskprofil", .{ .flags = .{
        .menu_bar = true,
        .no_move = true,
        .no_resize = true,
        .always_auto_resize = true,
    } })) {
        zgui.bullet();
        zgui.textUnformattedColored(.{ 0, 0.8, 0, 1 }, "Average :");
        zgui.sameLine(.{});
        zgui.text("Risk", .{});

        zgui.separator();
        if (zgui.button("Press me!", .{ .w = 200.0 })) {
            std.debug.print("Button pressed\n", .{});
        }

        // Vapen & Amm
        // if (zgui.collapsingHeader("Vapen", .{})) {
        const static = struct {
            var selection_index: u32 = 0;
            var current_item: i32 = 0;
            var weapon_enum_value: weapon.Models = .AK5;
            var amm_enum_values: ammunition.Calibers = .hagelptr;
        };

        _ = zgui.comboFromEnum("Vapentyp", &static.weapon_enum_value);
        _ = zgui.comboFromEnum("Ammunitionstyp", &static.amm_enum_values);
        // }
    }

    const draw_list = zgui.getBackgroundDrawList();
    draw_list.addPolyline(
        &.{ .{ 100, 700 }, .{ 200, 600 }, .{ 300, 700 }, .{ 400, 600 } },
        .{ .col = zgui.colorConvertFloat3ToU32([_]f32{ 0x11.0 / 0xff.0, 0xaa.0 / 0xff.0, 0 }), .thickness = 7 },
    );

    zgui.end();
}

fn draw(
    demo: *State,
) void {
    const gctx = demo.gctx;

    const swapchain_texv = gctx.swapchain.getCurrentTextureView();
    defer swapchain_texv.release();

    const commands = commands: {
        const encoder = gctx.device.createCommandEncoder(null);
        defer encoder.release();

        { // Gui pass.
            const pass = zgpu.beginRenderPassSimple(encoder, .load, swapchain_texv, null, null, null);
            defer zgpu.endReleasePass(pass);
            zgui.backend.draw(pass);
        }

        break :commands encoder.finish(null);
    };
    defer commands.release();

    gctx.submit(&.{commands});
    _ = gctx.present();
}
