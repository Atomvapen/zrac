const std = @import("std");
const rl = @import("raylib");
const zgui = @import("zgui");

const draw = @import("draw.zig");
const camera_fn = @import("camera.zig");

var guiState = @import("../data/state.zig").RiskProfile.init();

var camera = rl.Camera2D{
    .target = .{ .x = 9.785727e2, .y = -4.9193994e2 },
    .offset = .{ .x = 7.23e2, .y = 2.23e2 },
    .zoom = 4.0960002e-1,
    .rotation = 0,
};

var risk_editor_viewer: RiskEditorViewerWindow = undefined;

const RiskEditorViewerWindow = struct {
    const Self = @This();

    open: bool = false,
    quit: bool = false,

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
                .no_collapse = true, //TODO Fix crash at : .no_collapse = true
            },
        })) {
            { // Config values
                if (zgui.button("Återställ", .{})) guiState.reset();
                zgui.sameLine(.{});
                zgui.setNextItemWidth(70);
                _ = zgui.comboFromEnum("Typ", &guiState.config.sort);

                _ = zgui.checkbox("Visa linjer", .{ .v = &guiState.config.show });
                zgui.sameLine(.{});

                if (!guiState.config.show) zgui.beginDisabled(.{ .disabled = true });
                _ = zgui.checkbox("Visa text", .{ .v = &guiState.config.showText });
                if (!guiState.config.show) zgui.endDisabled();
            }

            { // Terrain Values
                zgui.separatorText("Terrängvärden");
                _ = zgui.comboFromEnum("Faktor", &guiState.terrainValues.factor);
                _ = zgui.inputFloat("Amin", .{ .v = &guiState.terrainValues.Amin });
                _ = zgui.inputFloat("Amax", .{ .v = &guiState.terrainValues.Amax });
                _ = zgui.inputFloat("f", .{ .v = &guiState.terrainValues.f });
                zgui.setNextItemWidth(93);
                _ = zgui.inputFloat("Skogsavstånd", .{ .v = &guiState.terrainValues.forestDist });
                zgui.sameLine(.{});
                _ = zgui.checkbox("Uppfångande", .{ .v = &guiState.terrainValues.interceptingForest });
            }

            { // Weapons & Ammunition Values
                zgui.separatorText("Vapenvärden");
                zgui.setNextItemWidth(121);
                _ = zgui.comboFromEnum("Vapentyp", &guiState.weaponValues.weapon_enum_value);
                zgui.sameLine(.{});

                if (!guiState.getHasSupport()) {
                    guiState.weaponValues.support = false;
                    zgui.beginDisabled(.{ .disabled = true });
                }
                _ = zgui.checkbox("Benstöd", .{ .v = &guiState.weaponValues.support });
                if (!guiState.getHasSupport()) zgui.endDisabled();

                switch (guiState.weaponValues.weapon_enum_value) {
                    .AK5, .KSP90 => _ = zgui.comboFromEnum("Ammunitionstyp", &guiState.weaponValues.amm556),
                    .KSP58 => _ = zgui.comboFromEnum("Ammunitionstyp", &guiState.weaponValues.amm762),
                    .KSP88, .AG90 => _ = zgui.comboFromEnum("Ammunitionstyp", &guiState.weaponValues.amm127),
                    .P88 => _ = zgui.comboFromEnum("Ammunitionstyp", &guiState.weaponValues.amm9),
                }
                _ = zgui.comboFromEnum("Måltyp", &guiState.weaponValues.target);
            }

            { // Box values
                if (guiState.config.sort == .Box) {
                    zgui.separatorText("Övningsområde");
                    _ = zgui.inputFloat("Bredd", .{ .v = &guiState.box.width });
                    _ = zgui.inputFloat("Längd", .{ .v = &guiState.box.length });

                    zgui.setNextItemWidth(80);
                    _ = zgui.inputFloat("Höger", .{ .v = &guiState.box.rightMils });
                    zgui.sameLine(.{});
                    zgui.setNextItemWidth(80);
                    _ = zgui.inputFloat("Vänster", .{ .v = &guiState.box.leftMils });
                }
            }

            { // Information text
                zgui.newLine();
                zgui.separator();
                zgui.newLine();
                zgui.textUnformatted("Flytta: Höger musknapp.");
                zgui.textUnformatted(" Zooma: Scrollhjulet.");
            }

            zgui.end();
            zgui.popStyleVar(.{});
        }
    }

    fn update(self: *Self) void {
        if (!self.open) return;

        guiState.update();
    }
};

fn drawGrid() void {
    { // Moveable UI
        camera.begin();
        defer camera.end();

        rl.gl.rlPushMatrix();
        rl.gl.rlTranslatef(0, 50 * 50, 0);
        rl.gl.rlRotatef(90, 1, 0, 0);
        rl.drawGrid(200, 100);
        rl.gl.rlPopMatrix();

        if (guiState.config.valid) {
            if (guiState.config.sort == .Box) draw.drawBox(guiState);

            // draw.drawLines(guiState);
        }
    }
}

fn doMainMenu() void {
    if (zgui.beginMainMenuBar()) {
        if (zgui.beginMenu("Fil", true)) {
            if (zgui.menuItem("Spara", .{})) std.debug.print("Save\n", .{});
            if (zgui.menuItem("Ladda", .{})) std.debug.print("Load\n", .{});
            if (zgui.menuItem("Avsluta", .{})) risk_editor_viewer.quit = true;
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

    const icon: rl.Image = rl.loadImage("assets/icon.png");
    icon.useAsWindowIcon();

    rl.setTargetFPS(60);
    zgui.rlimgui.setup(true);
    defer zgui.rlimgui.shutdown();
    zgui.io.setConfigWindowsMoveFromTitleBarOnly(true);

    risk_editor_viewer.open = true;

    while (!rl.windowShouldClose() and !risk_editor_viewer.quit) {
        camera_fn.handleCamera(&camera);
        risk_editor_viewer.update();

        rl.beginDrawing();
        rl.clearBackground(rl.Color.white);

        zgui.rlimgui.begin();
        drawGrid();
        doMainMenu();

        if (risk_editor_viewer.open) try risk_editor_viewer.show();

        zgui.rlimgui.end();

        rl.endDrawing();
    }
}
