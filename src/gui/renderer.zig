const std = @import("std");
const rl = @import("raylib");
const zgui = @import("zgui");

const draw = @import("draw.zig");
const camera_fn = @import("camera.zig");

var guiState = @import("../data/state.zig").RiskProfile.init();

var camera = rl.Camera2D{
    .target = .{ .x = 0, .y = 0 },
    .offset = .{ .x = 0, .y = 0 },
    .zoom = 1.0,
    .rotation = 0,
};

const RiskEditorViewerWindow = struct {
    const Self = @This();

    open: bool = false,

    fn show(self: *Self) !void {
        zgui.pushStyleVar2f(.{ .idx = .window_padding, .v = .{ 10, 10 } });
        zgui.setNextWindowSize(.{ .w = 100, .h = 100, .cond = .once });
        zgui.setNextWindowPos(.{ .x = 20.0, .y = 40.0, .cond = .once });

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


        { // Moveable UI
            camera.begin();
            defer camera.end();

            rl.gl.rlPushMatrix();
            rl.gl.rlTranslatef(0, 50 * 50, 0);
            rl.gl.rlRotatef(90, 1, 0, 0);
            rl.drawGrid(200, 100);
            rl.gl.rlPopMatrix();

            draw.drawLines(guiState);
        }
        }
    }

    fn update(self: *Self) void {
        if (!self.open) return;
        guiState.update();
    }
};

var risk_editor_viewer: RiskEditorViewerWindow = undefined;

fn doMainMenu() void {
    if (zgui.beginMainMenuBar()) {
        if (zgui.beginMenu("Fil", true)) {
            if (zgui.menuItem("Spara", .{})) std.debug.print("Save",.{});
            if (zgui.menuItem("Ladda", .{})) std.debug.print("Load",.{});
            if (zgui.menuItem("Avsluta", .{})) guiState.config.quit = true;
            zgui.endMenu();
        }

        if (zgui.beginMenu("Fönster", true)) {
            if (zgui.menuItem("Riskprofil", .{})) risk_editor_viewer.open = !risk_editor_viewer.open;
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

    risk_editor_viewer.open = true;

    while (!rl.windowShouldClose() and !guiState.config.quit) {
        camera_fn.handleCamera(&camera);
        risk_editor_viewer.update();

        rl.beginDrawing();
        rl.clearBackground(rl.Color.ray_white);

        zgui.rlimgui.begin();
        doMainMenu();

        if (risk_editor_viewer.open) try risk_editor_viewer.show();

        zgui.rlimgui.end();

        rl.endDrawing();
    }
}
