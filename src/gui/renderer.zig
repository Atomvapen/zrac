const std = @import("std");
const zglfw = @import("zglfw");
const zgpu = @import("zgpu");
const zgui = @import("zgui");
const geo = @import("../math/geo.zig");

var guiState = @import("../data/state.zig").riskProfile.init();

const window_title = "ZRAC";
const window_size = .{ .width = 800, .height = 800 };

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

    zgui.backend.init(
        window,
        gctx.device,
        @intFromEnum(zgpu.GraphicsContext.swapchain_format),
        @intFromEnum(zgpu.wgpu.TextureFormat.undef),
    );

    zgui.getStyle().scaleAllSizes(scale_factor);

    const draw_list = zgui.createDrawList();

    const app = try allocator.create(State);
    app.* = .{
        .gctx = gctx,
        .draw_list = draw_list,
    };

    return app;
}

fn destroy(
    allocator: std.mem.Allocator,
    app: *State,
) void {
    zgui.backend.deinit();
    zgui.destroyDrawList(app.draw_list);
    zgui.deinit();
    app.gctx.destroy(allocator);
    allocator.destroy(app);
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

    const app = try create(allocator, window);
    defer destroy(allocator, app);

    while (!window.shouldClose() and window.getKey(.escape) != .press) {
        zglfw.pollEvents();
        try update(app);
        draw(app);
    }
}

fn draw(
    app: *State,
) void {
    const gctx = app.gctx;

    const swapchain_texv = gctx.swapchain.getCurrentTextureView();
    defer swapchain_texv.release();

    const commands = commands: {
        const encoder = gctx.device.createCommandEncoder(null);
        defer encoder.release();

        { // GUI pass
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

fn update(
    app: *State,
) !void {
    guiState.update();

    zgui.backend.newFrame(
        app.gctx.swapchain_descriptor.width,
        app.gctx.swapchain_descriptor.height,
    );

    // Set the starting window position and size to custom values
    zgui.setNextWindowPos(.{ .x = 20.0, .y = 20.0, .cond = .first_use_ever });
    zgui.setNextWindowSize(.{ .w = -1.0, .h = -1.0, .cond = .first_use_ever });

    if (zgui.begin("Riskprofil", .{
        .flags = .{
            .no_move = true,
            .no_resize = true,
            .always_auto_resize = true,
            // .no_collapse = true,
        },
    })) {
        { // Show
            _ = zgui.checkbox("Visa", .{ .v = &guiState.show });
        }

        zgui.separatorText("Terrängvärden");
        { // Values
            _ = zgui.comboFromEnum("Faktor", &guiState.terrainValues.factor_enum_value);
            _ = zgui.inputFloat("Amin", .{ .v = &guiState.terrainValues.Amin });
            _ = zgui.inputFloat("Amax", .{ .v = &guiState.terrainValues.Amax });
            _ = zgui.inputFloat("f", .{ .v = &guiState.terrainValues.f });
            zgui.setNextItemWidth(90);
            _ = zgui.inputFloat("Skogsavstånd", .{ .v = &guiState.terrainValues.forestDist });
            zgui.sameLine(.{});
            _ = zgui.checkbox("Uppfångande", .{ .v = &guiState.terrainValues.interceptingForest });
        }

        zgui.separatorText("Vapenvärden");
        { // Weapons & Ammunition Comboboxes
            // zgui.setNextItemWidth(120);
            _ = zgui.comboFromEnum("Vapentyp", &guiState.weaponValues.weapon_enum_value);
            // zgui.sameLine(.{});
            // _ = zgui.checkbox("Benstöd", .{ .v = &guiState.weaponValues.stead });
            _ = zgui.comboFromEnum("Ammunitionstyp", &guiState.weaponValues.amm_enum_values);
            _ = zgui.comboFromEnum("Måltyp", &guiState.weaponValues.target_enum_value);
        }
    }

    if (guiState.validate()) { // Lines
        const origin = .{ .x = 400, .y = 750 };
        const draw_list = zgui.getBackgroundDrawList();

        // h
        var h: geo.Line = try geo.Line.init(geo.Vector2{
            .x = origin.x,
            .y = origin.y,
        }, geo.Vector2{
            .x = origin.x,
            .y = origin.y - guiState.terrainValues.h,
        }, false, undefined);
        h.drawLine(draw_list, .{ 1.0, 1.0, 1.0 });
        h.drawText("h", -10, 0, .{ 1.0, 1.0, 1.0 }, draw_list);

        // v
        var v: geo.Line = try geo.Line.init(geo.Vector2{
            .x = origin.x,
            .y = origin.y,
        }, geo.Vector2{
            .x = origin.x,
            .y = origin.y - guiState.terrainValues.h,
        }, true, guiState.weaponValues.v);
        v.drawLine(draw_list, .{ 1.0, 1.0, 1.0 });
        v.drawText("v", -10, 0, .{ 1.0, 1.0, 1.0 }, draw_list);

        // Amin
        var Amin: geo.Line = try geo.Line.init(geo.Vector2{
            .x = undefined,
            .y = undefined,
        }, geo.Vector2{
            .x = origin.x,
            .y = origin.y - guiState.terrainValues.Amin,
        }, false, undefined);
        Amin.drawText("Amin", -40, 0, .{ 1.0, 1.0, 1.0 }, draw_list);

        //f
        var f: geo.Line = try geo.Line.init(geo.Vector2{
            .x = origin.x,
            .y = origin.y - guiState.terrainValues.Amin + guiState.terrainValues.f,
        }, geo.Vector2{
            .x = origin.x,
            .y = Amin.end.y + guiState.terrainValues.f,
        }, false, undefined);
        f.drawText("f", -20, 0, .{ 1.0, 1.0, 1.0 }, draw_list);

        // h -> v
        var hv: geo.Line = try geo.Line.init(geo.Vector2{
            .x = h.end.x,
            .y = h.end.y,
        }, geo.Vector2{
            .x = v.end.x,
            .y = v.end.y,
        }, false, undefined);
        // hv.drawLine(draw_list, .{ 1.0, 1.0, 1.0 });
        try hv.drawCircleSector(
            guiState.terrainValues.h,
            draw_list,
            .{ 1.0, 1.0, 1.0 },
        );

        // ch
        var ch: geo.Line = try geo.Line.init(geo.Vector2{
            .x = v.end.x,
            .y = v.end.y,
        }, geo.Vector2{
            .x = v.end.x - 1,
            .y = v.end.y - 100,
        }, true, 3200 - 1000);

        // q1
        var q1: geo.Line = try geo.Line.init(geo.Vector2{
            .x = geo.calculateXfromAngle(@intFromFloat(guiState.terrainValues.Amin - guiState.terrainValues.f), v.angle) + origin.x,
            .y = origin.y - guiState.terrainValues.Amin + guiState.terrainValues.f,
        }, geo.Vector2{
            .x = v.end.x,
            .y = v.end.y,
        }, true, guiState.q1);

        if (guiState.terrainValues.forestDist > 0) {
            // forestMin
            var forestMin: geo.Line = try geo.Line.init(geo.Vector2{
                .x = undefined,
                .y = undefined,
            }, geo.Vector2{
                .x = origin.x,
                .y = origin.y - guiState.terrainValues.forestDist,
            }, false, undefined);
            forestMin.drawText("forestMin", -65, -70, .{ 1.0, 1.0, 1.0 }, draw_list);

            // q2
            var q2: geo.Line = try geo.Line.init(geo.Vector2{
                .x = geo.calculateXfromAngle(@intFromFloat(guiState.terrainValues.forestDist), v.angle) + origin.x,
                .y = origin.y - guiState.terrainValues.forestDist,
            }, geo.Vector2{
                .x = v.end.x,
                .y = v.end.y,
            }, true, guiState.q2);

            var c: geo.Line = try geo.getParallelLine(v, guiState.c);

            c.startAtIntersection(q2);

            ch.endAtIntersection(c);
            ch.drawLine(draw_list, .{ 1.0, 1.0, 1.0 });
            ch.drawText("ch", -5, -20, .{ 1.0, 1.0, 1.0 }, draw_list);

            c.endAtIntersection(ch);
            c.drawLine(draw_list, .{ 1.0, 1.0, 1.0 });

            q2.endAtIntersection(c);
            q2.drawLine(draw_list, .{ 1.0, 1.0, 1.0 });
            q2.drawText("q2", 10, 0, .{ 1.0, 1.0, 1.0 }, draw_list);
        } else {
            ch.endAtIntersection(q1);
            // ch.drawLine();
            // ch.drawText("ch", -5, -20, 30);

            q1.endAtIntersection(ch);
            // q1.drawLine();
            // q1.drawText("q1", 15, 0, 30);

            // c
            var c: geo.Line = try geo.getParallelLine(v, guiState.c);
            c.startAtIntersection(q1);
            c.endAtIntersection(ch);
            // c.drawLine();

            // if (guiState.terrainValues.factor_enum_value > 0) {
            q1.end = c.start;
            ch.end = c.end;
            c.drawLine(draw_list, .{ 1.0, 1.0, 1.0 });
            // }

            q1.drawLine(draw_list, .{ 1.0, 1.0, 1.0 });
            q1.drawText("q1", 15, 0, .{ 1.0, 1.0, 1.0 }, draw_list);
            ch.drawLine(draw_list, .{ 1.0, 1.0, 1.0 });
            ch.drawText("ch", -5, -20, .{ 1.0, 1.0, 1.0 }, draw_list);
        }
    }
    zgui.end();
}
