const std = @import("std");
const rl = @import("raylib");
const zgui = @import("zgui");
const draw = @import("draw.zig");

var guiState = @import("../data/state.zig").RiskProfile.init();

const ImageViewerWindow = struct {
    const Self = @This();

    open: bool = false,

    fn show(self: *Self) !void {
        zgui.pushStyleVar2f(.{ .idx = .window_padding, .v = .{ 10, 10 } });
        zgui.setNextWindowSize(.{ .w = 100, .h = 100, .cond = .once });
        zgui.setNextWindowPos(.{ .x = 20.0, .y = 40.0, .cond = .once });

        guiState.update();

        if (zgui.begin("Riskprofil", .{
            .popen = &self.open,
            .flags = .{
                .no_scrollbar = true,
                .no_scroll_with_mouse = true,
                // .no_move = true,
                .no_resize = true,
                .always_auto_resize = true,
                .no_collapse = true,
            },
        })) {
            { // Show
                _ = zgui.checkbox("Visa", .{ .v = &guiState.config.show });
            }

            zgui.separatorText("Terrängvärden");
            { // Values
                _ = zgui.comboFromEnum("Faktor", &guiState.terrainValues.factor);
                _ = zgui.inputFloat("Amin", .{ .v = &guiState.terrainValues.Amin });
                _ = zgui.inputFloat("Amax", .{ .v = &guiState.terrainValues.Amax });
                _ = zgui.inputFloat("f", .{ .v = &guiState.terrainValues.f });
                zgui.setNextItemWidth(93);
                _ = zgui.inputFloat("Skogsavstånd", .{ .v = &guiState.terrainValues.forestDist });
                zgui.sameLine(.{});
                _ = zgui.checkbox("Uppfångande", .{ .v = &guiState.terrainValues.interceptingForest });
            }

            zgui.separatorText("Vapenvärden");
            { // Weapons & Ammunition Comboboxes
                zgui.setNextItemWidth(121);
                _ = zgui.comboFromEnum("Vapentyp", &guiState.weaponValues.weapon_enum_value);
                zgui.sameLine(.{});
                _ = zgui.checkbox("Benstöd", .{ .v = &guiState.weaponValues.stead });

                switch (guiState.weaponValues.weapon_enum_value) {
                    .AK5, .KSP90 => _ = zgui.comboFromEnum("Ammunitionstyp", &guiState.weaponValues.amm556),
                    .KSP58 => _ = zgui.comboFromEnum("Ammunitionstyp", &guiState.weaponValues.amm762),
                    .KSP88 => _ = zgui.comboFromEnum("Ammunitionstyp", &guiState.weaponValues.amm127),
                    // else => _ = zgui.comboFromEnum("Ammunitionstyp", &guiState.weaponValues.amm_enum_values),
                }
                _ = zgui.comboFromEnum("Måltyp", &guiState.weaponValues.target);
            }

            zgui.end();
            zgui.popStyleVar(.{});

            draw.drawLines(guiState);
        }
    }

    fn update(self: *Self) void {
        if (!self.open) return;

        // if (rl.isWindowResized()) {
        //     self.view_texture.unload();
        //     self.view_texture = rl.loadRenderTexture(rl.getScreenWidth(), rl.getScreenWidth());
        //     const widthf: f32 = @floatFromInt(rl.getScreenWidth());
        //     const heightf: f32 = @floatFromInt(rl.getScreenHeight());
        //     self.camera.offset.x = widthf / 2.0;
        //     self.camera.offset.y = heightf / 2.0;
        // }

        // const mouse_pos = rl.getMousePosition();

        // if (self.focused) {
        //     if (self.current_tool_mode == .move) {
        //         // only when in content area
        //         if (rl.isMouseButtonDown(.mouse_button_left) and rl.checkCollisionPointRec(mouse_pos, self.content_rect)) {
        //             if (!self.dragging) {
        //                 self.last_mouse_pos = mouse_pos;
        //                 self.last_target = self.camera.target;
        //             }
        //             self.dragging = true;
        //             var mouse_delta = self.last_mouse_pos.subtract(mouse_pos);

        //             mouse_delta.x /= self.camera.zoom;
        //             mouse_delta.y /= self.camera.zoom;
        //             self.camera.target = self.last_target.add(mouse_delta);

        //             self.dirty_scene = true;
        //         } else {
        //             self.dragging = false;
        //         }
        //     }
        // } else {
        //     self.dragging = false;
        // }

        // if (self.dirty_scene) {
        //     self.dirty_scene = false;
        //     self.updateRenderTexture();
        // }
    }

    // fn updateRenderTexture(self: Self) void {
    //     self.view_texture.begin();
    //     rl.clearBackground(rl.Color.blue);

    //     self.camera.begin();

    //     self.image_texture.draw(@divTrunc(self.image_texture.width, -2), @divTrunc(self.image_texture.height, -2), rl.Color.white);

    //     self.camera.end();
    //     self.view_texture.end();
    // }

    // fn shutdown(self: *Self) void {
    //     self.view_texture.unload();
    //     self.image_texture.unload();
    // }
};

var image_viewer: ImageViewerWindow = undefined;

fn doMainMenu() void {
    if (zgui.beginMainMenuBar()) {
        if (zgui.beginMenu("Fil", true)) {
            if (zgui.menuItem("Avsluta", .{})) guiState.config.quit = true;

            zgui.endMenu();
        }

        if (zgui.beginMenu("Fönster", true)) {
            if (zgui.menuItem("Riskprofil", .{})) image_viewer.open = !image_viewer.open;

            zgui.endMenu();
        }
        zgui.endMainMenuBar();
    }
}

pub fn main() !void {
    const window_title = "ZRAC";
    const window_size = .{ .width = 1200, .height = 800 };

    rl.setConfigFlags(.{ .msaa_4x_hint = true, .vsync_hint = true });
    rl.initWindow(window_size.width, window_size.height, window_title);
    defer rl.closeWindow();
    rl.setTargetFPS(144);
    zgui.rlimgui.setup(true);
    defer zgui.rlimgui.shutdown();
    zgui.io.setConfigWindowsMoveFromTitleBarOnly(true);

    image_viewer.open = true;

    while (!rl.windowShouldClose() and !guiState.config.quit) {
        image_viewer.update();

        rl.beginDrawing();
        rl.clearBackground(rl.Color.dark_gray);

        zgui.rlimgui.begin();
        doMainMenu();

        if (image_viewer.open) try image_viewer.show();

        zgui.rlimgui.end();

        rl.endDrawing();
    }
}
