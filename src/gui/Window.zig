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
    icon: ?rl.Image = undefined,
    quit: bool = false,
    resizable: bool = false,
},
modal: ?Modal = null,
frames: struct { riskEditorFrame: Frame.RiskEditorFrame = undefined } = undefined,

pub fn init(self: *Self) void {
    rl.initWindow(self.config.size.width, self.config.size.height, self.config.title);
    zgui.rlimgui.setup(true);
    setConfigFlags(self);
    setProperties(self);
    setStyle();

    std.debug.print("INFO: Window initialized successfully:\n", .{});
    std.debug.print("INFO:     > ZGUI-RLIMGUI initialized successfully\n", .{});
    std.debug.print("INFO:     > Config flags applied successfully\n", .{});
    std.debug.print("INFO:     > Properties applied successfully\n", .{});
    std.debug.print("INFO:     > Styling applied successfully\n", .{});
}

pub fn deinit(self: *Self) void {
    if (self.config.icon) |icon| {
        rl.unloadImage(icon);
        self.config.icon = null;
    }
    zgui.rlimgui.shutdown();
    rl.closeWindow();

    std.debug.print("INFO: Window deinitialized successfully:\n", .{});
    std.debug.print("INFO:     > ZGUI-RLIMGUI deinitialized successfully\n", .{});
    std.debug.print("INFO:     > Icon unloaded successfully\n", .{});
}

fn setConfigFlags(self: *Self) void {
    rl.setConfigFlags(.{ .msaa_4x_hint = true, .vsync_hint = true, .window_resizable = self.config.resizable });
    zgui.io.setConfigWindowsMoveFromTitleBarOnly(true);
    zgui.io.setConfigFlags(.{ .nav_enable_keyboard = true });
}

fn setProperties(self: *Self) void {
    self.config.icon = rl.loadImage("assets/icon.png");
    if (self.config.icon) |icon| icon.useAsWindowIcon();
    rl.setTargetFPS(self.config.FPS);
}

fn setStyle() void {
    const zgui_style = zgui.getStyle();

    zgui_style.setColor(.header, Color.dark_grey);
    zgui_style.setColor(.window_bg, Color.white);

    zgui_style.setColor(.title_bg, Color.dark_grey);
    zgui_style.setColor(.title_bg_active, Color.dark_grey);

    zgui_style.tab_rounding = 2.0;
    zgui_style.popup_rounding = 3.0;
}
