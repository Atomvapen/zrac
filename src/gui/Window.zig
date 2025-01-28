const Self = @This();

const std = @import("std");
const rl = @import("raylib");
const zgui = @import("zgui");
const reg = @import("reg");
const Color = reg.gui.Color;
const Modal = reg.gui.Modal;
const Context = reg.data.Context;
const Frame = reg.gui.Frame;

config: struct {
    title: [*:0]const u8 = "ZRAC",
    size: struct { width: i32, height: i32 } = .{ .width = 1200, .height = 800 },
    FPS: i32 = 60,
    icon: rl.Image = undefined,
    quit: bool = false,
},
modal: ?Modal = null,
frames: struct { riskEditorFrame: Frame.RiskEditorFrame = undefined } = undefined,

pub fn init(self: *Self) void {
    defer std.debug.print("INFO: Window initialization successfully\n", .{});
    errdefer std.debug.print("INFO: Window initialization failed\n", .{});

    rl.initWindow(self.config.size.width, self.config.size.height, self.config.title);
    zgui.rlimgui.setup(true);
    rl.setConfigFlags(.{ .msaa_4x_hint = true, .vsync_hint = true });
    zgui.io.setConfigWindowsMoveFromTitleBarOnly(true);
}

pub fn deinit(_: *Self) void {
    defer std.debug.print("INFO: Window deinitialization successfully\n", .{});
    errdefer std.debug.print("INFO: Window deinitialization failed\n", .{});

    zgui.rlimgui.shutdown();
    rl.closeWindow();
}

pub fn setProperties(_: *Self, ctx: *Context) void {
    defer std.debug.print("INFO: Window set properties successfully\n", .{});
    errdefer std.debug.print("INFO: Window set properties failed\n", .{});

    ctx.window.config.icon = rl.loadImage("assets/icon.png");
    ctx.window.config.icon.useAsWindowIcon();
    rl.setTargetFPS(ctx.window.config.FPS);
}

pub fn style(_: *Self) void {
    defer std.debug.print("INFO: Window set style successfully\n", .{});
    errdefer std.debug.print("INFO: Window set style failed\n", .{});

    const zgui_style = zgui.getStyle();

    zgui_style.setColor(.header, Color.dark_grey);
    zgui_style.setColor(.window_bg, Color.white);
    zgui_style.setColor(.check_mark, Color.white);

    zgui_style.setColor(.button, Color.dark_grey);
    zgui_style.setColor(.button_active, Color.grey);
    zgui_style.setColor(.button_hovered, Color.grey);

    zgui_style.setColor(.title_bg, Color.dark_grey);
    zgui_style.setColor(.title_bg_active, Color.dark_grey);

    zgui_style.setColor(.border, Color.grey);

    zgui_style.setColor(.frame_bg, Color.dark_grey);
    zgui_style.setColor(.frame_bg_active, Color.dark_grey);
    zgui_style.setColor(.frame_bg_hovered, Color.grey);

    zgui_style.setColor(.tab, Color.grey);
    zgui_style.setColor(.tab_hovered, Color.dark_grey);
    zgui_style.setColor(.tab_selected, Color.dark_grey);
    zgui_style.setColor(.tab_selected_overline, Color.white);

    zgui_style.tab_rounding = 2;
    zgui_style.popup_rounding = 3.0;
    zgui_style.window_min_size = .{ 320.0, 240.0 };
}
