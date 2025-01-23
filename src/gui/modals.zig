const zgui = @import("zgui");
const rl = @import("raylib");
const reg = @import("reg");
const sync = reg.io.sync;
const Context = reg.gui.renderer.Context;

pub const Modal = union(Modals) {
    const Modals = enum {
        exportFrame,
        importFrame,
    };
    pub const ExportModal = struct {
        open: bool = false,

        pub fn show(self: *ExportModal, ctx: *Context) void {
            const window_width: i32 = rl.getScreenWidth();
            const window_height: i32 = rl.getScreenHeight();
            const frame_width: f32 = 600.0; // Replace with the actual frame width
            const frame_height: f32 = 400.0; // Replace with the actual frame height

            const center_x = (@as(f32, @floatFromInt(window_width)) - frame_width) / 2.0;
            const center_y = (@as(f32, @floatFromInt(window_height)) - frame_height) / 2.0;

            // Draw a fullscreen, semi-transparent rectangle to block interactions
            rl.drawRectangle(0, 0, window_width, window_height, rl.Color.fade(rl.Color.black, 0.5));

            zgui.pushStyleVar2f(.{ .idx = .window_padding, .v = .{ 10, 10 } });
            zgui.setNextWindowSize(.{ .w = frame_width, .h = frame_height, .cond = .once });
            zgui.setNextWindowPos(.{ .x = center_x, .y = center_y, .cond = .always });

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
                if (zgui.button("Acceptera", .{ .h = 50, .w = 100 })) {
                    sync.save();
                }
                zgui.sameLine(.{});
                if (zgui.button("Avbryt", .{ .h = 50, .w = 100 })) {
                    ctx.modal = null;
                }
                zgui.end();
                zgui.popStyleVar(.{});
            }
        }
    };
    pub const ImportModal = struct {
        open: bool = false,

        pub fn show(self: *ImportModal, ctx: *Context) void {
            const window_width: i32 = rl.getScreenWidth();
            const window_height: i32 = rl.getScreenHeight();
            const frame_width: f32 = 600.0; // Replace with the actual frame width
            const frame_height: f32 = 400.0; // Replace with the actual frame height

            const center_x = (@as(f32, @floatFromInt(window_width)) - frame_width) / 2.0;
            const center_y = (@as(f32, @floatFromInt(window_height)) - frame_height) / 2.0;

            rl.drawRectangle(0, 0, window_width, window_height, rl.Color.fade(rl.Color.black, 0.5));

            zgui.pushStyleVar2f(.{ .idx = .window_padding, .v = .{ 10, 10 } });
            zgui.setNextWindowSize(.{ .w = frame_width, .h = frame_height, .cond = .once });
            zgui.setNextWindowPos(.{ .x = center_x, .y = center_y, .cond = .always });

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
                if (zgui.button("Acceptera", .{ .h = 50, .w = 100 })) {
                    sync.load();
                }
                zgui.sameLine(.{});
                if (zgui.button("Avbryt", .{ .h = 50, .w = 100 })) {
                    ctx.modal = null;
                }
                zgui.end();
                zgui.popStyleVar(.{});
            }
        }
    };

    exportFrame: ExportModal,
    importFrame: ImportModal,

    pub fn show(self: *Modal, ctx: *Context) void {
        const zgui_style = zgui.getStyle();
        zgui_style.setColor(.window_bg, .{ 1.0, 1.0, 1.0, 1 });
        switch (self.*) {
            .exportFrame => |*export_frame| if (export_frame.open) export_frame.*.show(ctx),
            .importFrame => |*import_frame| if (import_frame.open) import_frame.*.show(ctx),
        }
    }
};
