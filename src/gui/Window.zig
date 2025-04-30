const std = @import("std");
const zglfw = @import("zglfw");
const zstbi = @import("zstbi");
const zgui = @import("zgui");
const Context = @import("../Context.zig");

const InitError = error{
    FailedToCreateWindow,
    FailedToGetExecutableDirectory,
    FailedToChangeExecutableDirectory,
    FailedToLoadIcon,
};

const WindowError = InitError;

pub const Config = struct {
    pub const title: [:0]const u8 = "zrac";
    pub const width: i32 = 900;
    pub const height: i32 = 600;
    pub const refresh_rate: i32 = 60;
    pub const icon_path: [:0]const u8 = "../../assets/icon.png";
    pub var contextmenu_is_open: bool = false;
};

pub fn init() WindowError!*zglfw.Window {
    zglfw.windowHint(.client_api, .no_api);
    zglfw.windowHint(.refresh_rate, Config.refresh_rate);
    zglfw.windowHint(.decorated, false);
    zglfw.windowHint(.resizable, false);

    std.debug.print("info: [zrac] Creating GLFW window ({d}x{d}) titled \"{s}\"\n", .{ Config.width, Config.height, Config.title });
    const window: *zglfw.Window = zglfw.Window.create(Config.width, Config.height, Config.title, null) catch {
        return InitError.FailedToCreateWindow;
    };
    window.setSizeLimits(Config.width, Config.height, Config.width, Config.height);
    window.setPos(100, 100);

    std.debug.print("info: [zrac]   Setting input callbacks\n", .{});
    _ = zglfw.setKeyCallback(window, Keybinds.keyCallback);
    // _ = zglfw.setDropCallback(window, fs.dropCallback);
    _ = zglfw.setCursorPosCallback(window, cursorPositionCallback);
    _ = zglfw.setMouseButtonCallback(window, mouseButtonCallback);

    // Use Relative Paths
    std.debug.print("info: [zrac]   Changing working directory to executable location\n", .{});
    var buffer: [std.fs.max_path_bytes]u8 = undefined;
    const path: []const u8 = std.fs.selfExeDirPath(buffer[0..]) catch {
        return InitError.FailedToGetExecutableDirectory;
    };
    std.posix.chdir(path) catch {
        return InitError.FailedToChangeExecutableDirectory;
    };

    // Set Icon
    std.debug.print("info: [zrac]   Loading icon image from path: {s}\n", .{Config.icon_path});
    var zstbi_icon: zstbi.Image = zstbi.Image.loadFromFile(Config.icon_path, 4) catch {
        return InitError.FailedToLoadIcon;
    };

    defer zstbi_icon.deinit();
    std.debug.print("info: [zrac]   Setting window icon\n", .{});
    const zglfw_icon: zglfw.Image = zglfw.Image{
        .width = @intCast(zstbi_icon.width),
        .height = @intCast(zstbi_icon.height),
        .pixels = @ptrCast(zstbi_icon.data),
    };
    zglfw.setWindowIcon(window, &.{zglfw_icon});

    std.debug.print("info: [zrac]   Window initialization complete\n", .{});
    return window;
}

pub fn draw(ctx: *Context) void {
    Toolbar.draw(ctx);
}

fn cursorPositionCallback(window: *zglfw.Window, x: f64, y: f64) callconv(.c) void {
    _ = window;

    zgui.io.addMousePositionEvent(@floatCast(x), @floatCast(y));

    if (Drag.dragging) {
        Drag.offset_cpx = @as(i32, @intFromFloat(x)) - Drag.cp_x;
        Drag.offset_cpy = @as(i32, @intFromFloat(y)) - Drag.cp_y;
    }
}

fn mouseButtonCallback(window: *zglfw.Window, button: zglfw.MouseButton, action: zglfw.Action, mods: zglfw.Mods) callconv(.c) void {
    _ = mods;

    const button_translation: zgui.MouseButton = switch (button) {
        .right => zgui.MouseButton.right,
        .left => zgui.MouseButton.left,
        .middle => zgui.MouseButton.middle,
        else => zgui.MouseButton.middle,
    };

    const action_translation: bool = switch (action) {
        .press => true,
        .release => false,
        .repeat => true,
    };

    zgui.io.addMouseButtonEvent(button_translation, action_translation);

    if (zgui.isAnyItemHovered()) {
        return;
    }

    switch (button) {
        .left => switch (action) {
            .press => Drag.start(window),
            .release => Drag.stop(),
            else => {},
        },
        else => {},
    }
}

pub const Drag = struct {
    var cp_x: i32 = 0;
    var cp_y: i32 = 0;
    var offset_cpx: i32 = 0;
    var offset_cpy: i32 = 0;
    var dragging: bool = false;

    fn start(window: *zglfw.Window) void {
        const x: f64 = window.getCursorPos()[0];
        const y: f64 = window.getCursorPos()[1];

        if (y >= 25) return;

        dragging = true;
        cp_x = @as(i32, @intFromFloat(x));
        cp_y = @as(i32, @intFromFloat(y));
        return;
    }

    fn stop() void {
        dragging = false;
        cp_x = 0;
        cp_y = 0;
    }

    pub fn handle(window: *zglfw.Window) void {
        const alpha: f32 = 0.4;

        if (!dragging) return;

        var current_x: i32 = 0;
        var current_y: i32 = 0;
        zglfw.getWindowPos(window, &current_x, &current_y);

        const target_x = current_x + offset_cpx;
        const target_y = current_y + offset_cpy;

        const new_x: i32 = @intFromFloat(lerp(@floatFromInt(current_x), @floatFromInt(target_x), alpha));
        const new_y: i32 = @intFromFloat(lerp(@floatFromInt(current_y), @floatFromInt(target_y), alpha));

        zglfw.setWindowPos(window, new_x, new_y);

        offset_cpx = 0;
        offset_cpy = 0;
    }
};

fn lerp(a: f32, b: f32, alpha: f32) f32 {
    return a + alpha * (b - a);
}

pub const Keybinds = struct {
    const Key = zglfw.Key;

    const Commands = enum(u8) {
        _test,
        refresh,
        save,
        quit,
        _,
    };

    const Bindings = struct {
        _test: Key = Key.F1,
        refresh: Key = Key.F5,
        open: Key = Key.enter,
    };

    pub var bindigns: Bindings = .{};
    pub var ctx: ?*Context = undefined;

    pub fn init(context: *Context) void {
        ctx = context;
    }

    pub fn set(command: Commands, key: Key) void {
        switch (command) {
            .refresh => bindigns.refresh = key,
            else => {},
        }
    }

    pub fn get(command: Commands) ?Key {
        return switch (command) {
            .refresh => bindigns.refresh,
            else => null,
        };
    }

    pub fn keyCallback(window: *zglfw.Window, key: zglfw.Key, scancode: i32, action: zglfw.Action, mods: zglfw.Mods) callconv(.c) void {
        _ = scancode;
        _ = mods;
        _ = window;

        if (ctx == null) return;

        if (key == bindigns._test) {
            switch (action) {
                zglfw.Action.press => {
                    std.debug.print("F1 Pressed!\n", .{});
                },
                zglfw.Action.release => {
                    std.debug.print("F1 Released!\n", .{});
                },
                else => {},
            }
        }
    }
};

pub const Toolbar = struct {
    const Color = @import("Color.zig");

    pub fn draw(ctx: *Context) void {
        zgui.pushStyleColor4f(.{ .idx = .header, .c = Color.dark_grey });
        zgui.pushStyleColor4f(.{ .idx = .border, .c = Color.grey });
        zgui.pushStyleVar1f(.{ .idx = .popup_rounding, .v = 2 });
        zgui.pushStyleVar1f(.{ .idx = .child_rounding, .v = 2 });

        if (zgui.beginMainMenuBar()) {
            zgui.popStyleColor(.{ .count = 1 });
            if (zgui.beginMenu("Archive", true)) {
                if (zgui.menuItem("Open file", .{})) {}

                if (zgui.menuItem("Open folder", .{})) {
                    // try fs.setDirInfoUnpathed(ctx);
                }

                zgui.separator();
                if (zgui.menuItem("Quit", .{})) {
                    ctx.window.setShouldClose(true);
                }

                zgui.endMenu();
            }

            if (zgui.beginMenu("Edit", true)) {
                zgui.endMenu();
            }

            if (zgui.beginMenu("Show", true)) {
                // if (zgui.menuItem("Archiver", .{})) ctx.archiver.show = !ctx.archiver.show;
                zgui.endMenu();
            }

            if (zgui.beginMenu("Tools", true)) {
                if (zgui.menuItem("Settings", .{})) {}

                zgui.endMenu();
            }
            zgui.sameLine(.{ .offset_from_start_x = @as(f32, @floatFromInt(ctx.window.getSize()[0])) - 100 });
            zgui.pushStyleVar1f(.{ .idx = .frame_rounding, .v = 0 });
            zgui.pushStyleColor4f(.{ .idx = .text, .c = Color.white });

            zgui.pushStyleColor4f(.{ .idx = .button, .c = Color.dark_grey });
            zgui.pushStyleColor4f(.{ .idx = .button_hovered, .c = Color.grey });
            if (zgui.button("_", .{})) ctx.window.setShouldClose(true);
            if (zgui.button("[]", .{})) ctx.window.setShouldClose(true);
            if (zgui.button("X", .{})) ctx.window.setShouldClose(true);
            zgui.popStyleColor(.{ .count = 2 });

            zgui.popStyleVar(.{ .count = 1 });
            zgui.popStyleColor(.{ .count = 1 });
            zgui.endMainMenuBar();
        } else {
            zgui.popStyleColor(.{ .count = 1 });
        }
        zgui.popStyleColor(.{ .count = 1 });
        zgui.popStyleVar(.{ .count = 2 });
    }
};
