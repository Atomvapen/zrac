const zgui = @import("zgui");
const rl = @import("raylib");
const reg = @import("reg");
const sync = reg.io.sync;
const Context = reg.gui.renderer.Context;
const Color = reg.gui.Color;

const Modal = @This();

const Types = enum {
    exportModal,
    importModal,
    settingsModal,
};

const ExportModal = struct {
    open: bool = false,

    pub fn show(self: *ExportModal, ctx: *Context) void {
        const frame_width: f32 = 600.0;
        const frame_height: f32 = 400.0;

        setup(frame_width, frame_height);

        if (zgui.begin("Exportera", .{
            .popen = &self.open,
            .flags = .{
                .no_scrollbar = true,
                .no_scroll_with_mouse = true,
                .no_resize = true,
                .no_collapse = true,
                .no_move = true,
            },
        })) {
            var v: f32 = 0;
            zgui.pushStyleColor4f(.{ .idx = .text, .c = Color.black });
            zgui.textUnformatted("Location");
            zgui.popStyleColor(.{});
            zgui.sameLine(.{ .offset_from_start_x = 100 });
            _ = zgui.dragFloat("label", .{ .v = &v });
            zgui.sameLine(.{ .spacing = 4 });
            _ = zgui.button("X", .{ .h = 20, .w = 20 });

            zgui.pushStyleColor4f(.{ .idx = .text, .c = Color.black });
            zgui.textUnformatted("Name");
            zgui.popStyleColor(.{});
            zgui.sameLine(.{ .offset_from_start_x = 100 });
            _ = zgui.dragFloat("label", .{ .v = &v });
            zgui.sameLine(.{ .spacing = 4 });
            _ = zgui.button("X", .{ .h = 20, .w = 20 });

            if (zgui.button("Acceptera", .{ .h = 20, .w = 100 })) {
                sync.save();
            }
            zgui.sameLine(.{});
            if (zgui.button("Avbryt", .{ .h = 20, .w = 100 })) {
                ctx.modal = null;
            }
            zgui.end();
            zgui.popStyleVar(.{});
        }
    }
};
const ImportModal = struct {
    open: bool = false,

    pub fn show(self: *ImportModal, ctx: *Context) void {
        const frame_width: f32 = 600.0;
        const frame_height: f32 = 400.0;

        setup(frame_width, frame_height);

        if (zgui.begin("Importera", .{
            .popen = &self.open,
            .flags = .{
                .no_scrollbar = true,
                .no_scroll_with_mouse = true,
                .no_resize = true,
                .no_collapse = true,
                .no_move = true,
            },
        })) {
            if (zgui.button("Acceptera", .{ .h = 20, .w = 100 })) {
                sync.load();
            }
            zgui.sameLine(.{});
            if (zgui.button("Avbryt", .{ .h = 20, .w = 100 })) {
                ctx.modal = null;
            }
            zgui.end();
            zgui.popStyleVar(.{});
        }
    }
};
const SettingsModal = struct {
    open: bool = false,

    pub fn show(self: *SettingsModal, ctx: *Context) void {
        const frame_width: f32 = 600.0;
        const frame_height: f32 = 400.0;

        setup(frame_width, frame_height);

        if (zgui.begin("Inställningar", .{
            .popen = &self.open,
            .flags = .{
                .no_scrollbar = true,
                .no_scroll_with_mouse = true,
                .no_resize = true,
                .no_collapse = true,
                .no_move = true,
            },
        })) {
            if (zgui.button("Acceptera", .{ .h = 20, .w = 100 })) {
                sync.load();
            }
            zgui.sameLine(.{});
            if (zgui.button("Avbryt", .{ .h = 20, .w = 100 })) {
                ctx.modal = null;
            }
            zgui.end();
            zgui.popStyleVar(.{});
        }
    }
};

type: Types,
exportModal: ExportModal = undefined,
importModal: ImportModal = undefined,
settingsModal: SettingsModal = undefined,

pub fn create(sort: Types) Modal {
    return switch (sort) {
        .exportModal => Modal{ .type = .exportModal, .exportModal = .{ .open = true } },
        .importModal => Modal{ .type = .importModal, .importModal = .{ .open = true } },
        .settingsModal => Modal{ .type = .settingsModal, .settingsModal = .{ .open = true } },
    };
}

pub fn show(self: *Modal, ctx: *Context) void {
    const zgui_style = zgui.getStyle();
    zgui_style.setColor(.window_bg, Color.white);

    switch (self.type) {
        .exportModal => if (self.exportModal.open) self.exportModal.show(ctx),
        .importModal => if (self.importModal.open) self.importModal.show(ctx),
        .settingsModal => if (self.settingsModal.open) self.settingsModal.show(ctx),
    }
}

pub fn isOpen(self: *Modal) bool {
    return switch (self.type) {
        .exportModal => self.exportModal.open,
        .importModal => self.importModal.open,
        .settingsModal => self.settingsModal.open,
    };
}

fn setup(frame_width: f32, frame_height: f32) void {
    const window_width: i32 = rl.getScreenWidth();
    const window_height: i32 = rl.getScreenHeight();

    { // Center Position
        const center_x = (@as(f32, @floatFromInt(window_width)) - frame_width) / 2.0;
        const center_y = (@as(f32, @floatFromInt(window_height)) - frame_height) / 2.0;

        zgui.setNextWindowSize(.{ .w = frame_width, .h = frame_height, .cond = .once });
        zgui.setNextWindowPos(.{ .x = center_x, .y = center_y, .cond = .always });
    }

    { // Style
        zgui.pushStyleVar2f(.{ .idx = .window_padding, .v = .{ 10, 10 } });
    }

    { // Dim Background
        rl.drawRectangle(0, 0, window_width, window_height, rl.Color.fade(rl.Color.black, 0.5));
    }
}
