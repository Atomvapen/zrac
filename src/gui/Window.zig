const Self = @This();
const std = @import("std");
const zgui = @import("zgui");
const Context = @import("../Context.zig");
const rl = @import("raylib");
const Color = @import("Color.zig");
const Modal = @import("Modal.zig");

pub const Error = error{
    OutOfMemory,
    LoadWindowIcon,
    InitWindow,
};

const Config = struct {
    pub const title: [:0]const u8 = "zrac";
    pub const width: i32 = 900;
    pub const height: i32 = 600;
    pub const refresh_rate: i32 = 60;
    pub const icon_path: [:0]const u8 = "assets/icon.png";
};

const ContextMenu = @import("ContextMenu.zig");
const Frame = @import("Frame.zig");

quit: bool,
dragging: bool,
modal: ?Modal,
frames: struct { riskEditorFrame: Frame.RiskEditorFrame = undefined } = undefined,

var drag_offset = rl.Vector2{ .x = 0, .y = 0 };

pub fn create(allocator: std.mem.Allocator) !*Self {
    const self: *Self = allocator.create(Self) catch return Error.OutOfMemory;
    errdefer allocator.destroy(self);

    self.* = .{
        .dragging = false,
        .modal = null,
        .quit = false,
        .frames = .{
            .riskEditorFrame = Frame.RiskEditorFrame{ .open = true },
        },
    };

    rl.setConfigFlags(.{ .window_undecorated = true, .window_resizable = false });
    rl.initWindow(Config.width, Config.height, Config.title);
    if (!rl.isWindowReady()) return Error.InitWindow;
    rl.setTargetFPS(Config.refresh_rate);

    const icon: rl.Image = rl.loadImage(Config.icon_path) catch return Error.LoadWindowIcon;
    defer rl.unloadImage(icon);
    rl.setWindowIcon(icon);

    return self;
}

pub fn destroy(self: *Self, allocator: std.mem.Allocator) void {
    rl.closeWindow();
    self.quit = true;
    self.* = undefined;
    allocator.destroy(self);
}

pub fn deinit(self: *Self) void {
    self.quit = true;
}

pub fn draw(_: *Self, ctx: *Context) void {
    Toolbar.draw(ctx);
    ContextMenu.draw(ctx);
}

pub fn update(_: *Self) void {
    if (rl.isMouseButtonPressed(.left)) {
        Drag.start();
    }
    if (rl.isMouseButtonReleased(.left)) {
        Drag.stop();
    }

    // Handle the dragging (update window position)
    Drag.handle();
}

const Toolbar = struct {
    pub fn draw(ctx: *Context) void {
        zgui.pushStyleColor4f(.{ .idx = .header, .c = Color.dark_grey });
        zgui.pushStyleColor4f(.{ .idx = .border, .c = Color.grey });
        zgui.pushStyleVar1f(.{ .idx = .popup_rounding, .v = 2 });
        zgui.pushStyleVar1f(.{ .idx = .child_rounding, .v = 2 });

        if (zgui.beginMainMenuBar()) {
            zgui.popStyleColor(.{ .count = 1 });
            if (zgui.beginMenu("File", true)) {
                if (zgui.menuItem("Import", .{})) {
                    ctx.window.modal = .create(.importModal);
                }

                if (zgui.menuItem("Export", .{})) {
                    ctx.window.modal = .create(.exportModal);
                }

                zgui.separator();
                if (zgui.menuItem("Quit", .{})) {
                    ctx.window.deinit();
                }
                zgui.endMenu();
            }

            if (zgui.beginMenu("Edit", true)) {
                zgui.endMenu();
            }

            if (zgui.beginMenu("Window", true)) {
                if (zgui.menuItem("Riskprofil", .{})) ctx.window.frames.riskEditorFrame.open = !ctx.window.frames.riskEditorFrame.open;
                zgui.endMenu();
            }

            if (zgui.beginMenu("Tools", true)) {
                if (zgui.menuItem("Settings", .{})) {
                    ctx.window.modal = .create(.settingsModal);
                }

                zgui.endMenu();
            }
            zgui.sameLine(.{ .offset_from_start_x = @as(f32, @floatFromInt(rl.getScreenWidth())) - 100 });
            zgui.pushStyleVar1f(.{ .idx = .frame_rounding, .v = 0 });
            zgui.pushStyleColor4f(.{ .idx = .text, .c = Color.white });

            zgui.pushStyleColor4f(.{ .idx = .button, .c = Color.dark_grey });
            zgui.pushStyleColor4f(.{ .idx = .button_hovered, .c = Color.grey });
            if (zgui.button("_", .{})) ctx.window.deinit();
            if (zgui.button("[]", .{})) ctx.window.deinit();
            if (zgui.button("X", .{})) ctx.window.deinit();
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

// fn cursorPositionCallback(window: *zglfw.Window, x: f64, y: f64) callconv(.c) void {
//     _ = window;

//     zgui.io.addMousePositionEvent(@floatCast(x), @floatCast(y));

//     if (Drag.dragging) {
//         Drag.offset_cpx = @as(i32, @intFromFloat(x)) - Drag.cp_x;
//         Drag.offset_cpy = @as(i32, @intFromFloat(y)) - Drag.cp_y;
//     }
// }

// fn mouseButtonCallback(window: *zglfw.Window, button: zglfw.MouseButton, action: zglfw.Action, mods: zglfw.Mods) callconv(.c) void {
//     _ = mods;

//     const button_translation: zgui.MouseButton = switch (button) {
//         .right => zgui.MouseButton.right,
//         .left => zgui.MouseButton.left,
//         .middle => zgui.MouseButton.middle,
//         else => zgui.MouseButton.middle,
//     };

//     const action_translation: bool = switch (action) {
//         .press => true,
//         .release => false,
//         .repeat => true,
//     };

//     zgui.io.addMouseButtonEvent(button_translation, action_translation);

//     if (zgui.isAnyItemHovered()) {
//         return;
//     }

//     switch (button) {
//         .left => switch (action) {
//             .press => Drag.start(window),
//             .release => Drag.stop(),
//             else => {},
//         },
//         else => {},
//     }
// }

fn lerp(a: f32, b: f32, alpha: f32) f32 {
    return a + alpha * (b - a);
}

pub const Drag = struct {
    var dragging: bool = false;
    var window_pos: rl.Vector2 = .{ .x = 500, .y = 200 };

    pub fn start() void {
        const mousePos = rl.getMousePosition();
        const y: f32 = mousePos.y;
        const x: f32 = mousePos.x;
        if (y >= 30) return;
        if (x <= 240) return;
        if (x >= @as(f32, @floatFromInt(rl.getScreenWidth())) - 100) return;
        dragging = true;
    }

    pub fn stop() void {
        dragging = false;
    }

    pub fn handle() void {
        if (!dragging) return;

        // Get the mouse delta (movement since last frame)
        const mouseDelta = rl.getMouseDelta();

        // Smooth the movement by interpolating between the old position and the new position
        const smooth_factor: f32 = 0.8; // How fast the window follows the cursor
        window_pos.x = lerp(window_pos.x, window_pos.x + mouseDelta.x, smooth_factor);
        window_pos.y = lerp(window_pos.y, window_pos.y + mouseDelta.y, smooth_factor);

        // Round to avoid non-integer positions that might cause jitter
        window_pos.x = @round(window_pos.x);
        window_pos.y = @round(window_pos.y);

        // Set the new window position
        rl.setWindowPosition(@as(i32, @intFromFloat(window_pos.x)), @as(i32, @intFromFloat(window_pos.y)));
    }
};
