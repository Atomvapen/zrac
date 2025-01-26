const Self = @This();

const zgui = @import("zgui");
const rl = @import("raylib");
const reg = @import("reg");
const sync = reg.io.sync;
const Color = reg.gui.Color;

pub const Type = union(enum) {
    const ExportModal = struct {
        open: bool = false,

        pub fn show(self: *ExportModal) void {
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
                    self.open = false;
                }
                zgui.end();
                zgui.popStyleVar(.{});
            }
        }
    };
    const ImportModal = struct {
        open: bool = false,

        pub fn show(self: *ImportModal) void {
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
                    self.open = false;
                }
                zgui.end();
                zgui.popStyleVar(.{});
            }
        }
    };
    const SettingsModal = struct {
        open: bool = false,

        pub fn show(self: *SettingsModal) void {
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
                    self.open = false;
                }
                zgui.end();
                zgui.popStyleVar(.{});
            }
        }
    };

    exportModal: ExportModal,
    importModal: ImportModal,
    settingsModal: SettingsModal,
};

type: Type,

pub fn set(sort: enum { exportModal, importModal, settingsModal }) Self {
    return switch (sort) {
        .exportModal => Self{ .type = .{ .exportModal = .{ .open = true } } },
        .importModal => Self{ .type = .{ .importModal = .{ .open = true } } },
        .settingsModal => Self{ .type = .{ .settingsModal = .{ .open = true } } },
    };
}

pub fn show(self: *Self) void {
    const zgui_style = zgui.getStyle();
    zgui_style.setColor(.window_bg, Color.white);

    switch (self.type) {
        .exportModal => |*modal| if (modal.open) modal.show(),
        .importModal => |*modal| if (modal.open) modal.show(),
        .settingsModal => |*modal| if (modal.open) modal.show(),
    }
}

pub fn isOpen(self: *Self) bool {
    return switch (self.type) {
        .exportModal => |*modal| modal.open,
        .importModal => |*modal| modal.open,
        .settingsModal => |*modal| modal.open,
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
