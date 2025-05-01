const Self = @This();
const zgui = @import("zgui");
const Context = @import("../Context.zig");
const Color = @import("Color.zig");

const Mode = enum(u8) {
    none,
    explorer,
    item,
    background,
};

// var mode: Mode = .none;
var mouse_pos: [2]f32 = undefined;
var current_menu: Mode = .none;
var menu_open: bool = false;

fn show(_: *Context, menu: Mode) void {
    current_menu = menu;
    mouse_pos = zgui.getMousePos();
    menu_open = true;
    zgui.openPopup("Context Menu", .{
        .mouse_button_right = true,
        .no_open_over_existing_popup = true,
    });
}

fn update(ctx: *Context) void {
    if (zgui.isMouseClicked(.right)) menu_open = false;

    if (zgui.isMouseReleased(.right) and !menu_open) {
        show(ctx, .explorer);
    }
}

pub fn draw(_: *Self, ctx: *Context) void {
    update(ctx);
    if (!menu_open or current_menu == .none) return;

    zgui.pushStyleVar1f(.{ .idx = .child_rounding, .v = 2 });
    zgui.pushStyleVar1f(.{ .idx = .popup_rounding, .v = 2 });
    zgui.pushStyleColor4f(.{ .idx = .border, .c = Color.gainsboro });
    zgui.pushStyleColor4f(.{ .idx = .text, .c = Color.black });
    zgui.pushStyleColor4f(.{ .idx = .button, .c = Color.white });
    zgui.pushStyleColor4f(.{ .idx = .button_hovered, .c = Color.porcelain });
    zgui.pushStyleColor4f(.{ .idx = .popup_bg, .c = Color.white });

    zgui.setNextWindowPos(.{ .x = mouse_pos[0], .y = mouse_pos[1], .cond = .always });

    if (zgui.beginPopup("Context Menu", .{})) {
        switch (current_menu) {
            .background => backgroundMenu(ctx),
            .explorer => explorerMenu(ctx),
            .item => itemMenu(ctx),
            else => {},
        }
        zgui.endPopup();
    }

    zgui.popStyleColor(.{ .count = 5 });
    zgui.popStyleVar(.{ .count = 2 });
}

fn explorerMenu(_: *Context) void {
    if (zgui.menuItem("Open Folder", .{})) menu_open = false;
    if (zgui.menuItem("New Folder", .{})) menu_open = false;
    zgui.separator();
    if (zgui.menuItem("Refresh", .{})) menu_open = false;
}

fn itemMenu(_: *Context) void {
    if (zgui.menuItem("Inspect", .{})) menu_open = false;
    if (zgui.menuItem("Delete", .{})) menu_open = false;
}

fn backgroundMenu(_: *Context) void {
    if (zgui.menuItem("New File", .{})) menu_open = false;
    if (zgui.menuItem("New Folder", .{})) menu_open = false;
}
