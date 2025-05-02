const Self = @This();

const std = @import("std");
const zgui = @import("zgui");
const Color = @import("Color.zig");
const Window = @import("Window.zig");

pub const Modals = union(enum) {
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
                    .no_title_bar = true,
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

                if (zgui.button("Acceptera", .{ .h = 20, .w = 100 })) {}
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
                    .no_title_bar = true,
                },
            })) {
                if (zgui.button("Acceptera", .{ .h = 20, .w = 100 })) {}
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
                    .no_title_bar = true,
                },
            })) {
                if (zgui.button("Acceptera", .{ .h = 20, .w = 100 })) {}
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

content: Modals,
open: bool = false,

pub fn init(sort: enum { exportModal, importModal, settingsModal }) Self {
    return switch (sort) {
        .exportModal => Self{ .open = true, .content = .{ .exportModal = .{ .open = true } } },
        .importModal => Self{ .open = true, .content = .{ .importModal = .{ .open = true } } },
        .settingsModal => Self{ .open = true, .content = .{ .settingsModal = .{ .open = true } } },
    };
}

pub fn show(self: *Self) void {
    const zgui_style: *zgui.Style = zgui.getStyle();
    zgui_style.setColor(.window_bg, Color.white);

    switch (self.content) {
        .exportModal => |*modal| if (modal.open) modal.show(),
        .importModal => |*modal| if (modal.open) modal.show(),
        .settingsModal => |*modal| if (modal.open) modal.show(),
    }

    self.open = switch (self.content) {
        .exportModal => |*modal| modal.open,
        .importModal => |*modal| modal.open,
        .settingsModal => |*modal| modal.open,
    };
}

fn setup(frame_width: f32, frame_height: f32) void {
    const window_width: f32 = @floatFromInt(Window.Config.width);
    const window_height: f32 = @floatFromInt(Window.Config.height);

    // Center Position
    const center_x: f32 = (window_width - frame_width) / 2.0;
    const center_y: f32 = (window_height - frame_height) / 2.0;

    zgui.setNextWindowSize(.{ .w = frame_width, .h = frame_height, .cond = .once });
    zgui.setNextWindowPos(.{ .x = center_x, .y = center_y, .cond = .always });

    // Style
    zgui.pushStyleVar2f(.{ .idx = .window_padding, .v = .{ 10, 10 } });

    // Dim Background
    const draw_list: zgui.DrawList = zgui.getBackgroundDrawList();
    draw_list.addRectFilled(.{
        .pmin = .{ 0, 0 },
        .pmax = .{ window_width, window_height },
        .col = zgui.colorConvertFloat4ToU32(.{ 0, 0, 0, 128 }),
    });
}
