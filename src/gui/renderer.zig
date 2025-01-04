const std = @import("std");
const rl = @import("raylib");
const zgui = @import("zgui");

const draw = @import("draw/draw.zig");
const camera_fn = @import("camera.zig");
const drawBuffer = @import("draw/drawBuffer.zig").DrawBuffer;

var riskProfile = @import("../data/state.zig").RiskProfile.init();

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
                _ = zgui.checkbox("Visa linjer", .{ .v = &riskProfile.config.show });
                zgui.sameLine(.{});

                if (!riskProfile.config.show) zgui.beginDisabled(.{ .disabled = true });
                _ = zgui.checkbox("Visa text", .{ .v = &riskProfile.config.showText });
                if (!riskProfile.config.show) zgui.endDisabled();
            }

            { // Type value
                zgui.separatorText("Typ");
                _ = zgui.comboFromEnum("Typ", &riskProfile.config.sort);
            }

            { // Terrain Values
                zgui.separatorText("Terrängvärden");
                _ = zgui.comboFromEnum("Faktor", &riskProfile.terrainValues.factor);
                _ = zgui.inputFloat("Amin", .{ .v = &riskProfile.terrainValues.Amin });
                _ = zgui.inputFloat("Amax", .{ .v = &riskProfile.terrainValues.Amax });
                _ = zgui.inputFloat("f", .{ .v = &riskProfile.terrainValues.f });
                zgui.setNextItemWidth(93);
                _ = zgui.inputFloat("Skogsavstånd", .{ .v = &riskProfile.terrainValues.forestDist });
                zgui.sameLine(.{});
                _ = zgui.checkbox("Uppfångande", .{ .v = &riskProfile.terrainValues.interceptingForest });
            }

            { // Weapons & Ammunition Values
                zgui.separatorText("Vapenvärden");
                zgui.setNextItemWidth(121);
                _ = zgui.comboFromEnum("Vapentyp", &riskProfile.weaponValues.weapon_enum_value);
                zgui.sameLine(.{});

                if (!riskProfile.getHasSupport()) {
                    riskProfile.weaponValues.support = false;
                    zgui.beginDisabled(.{ .disabled = true });
                }
                _ = zgui.checkbox("Benstöd", .{ .v = &riskProfile.weaponValues.support });
                if (!riskProfile.getHasSupport()) zgui.endDisabled();

                switch (riskProfile.weaponValues.weapon_enum_value) {
                    .AK5, .KSP90 => _ = zgui.comboFromEnum("Ammunitionstyp", &riskProfile.weaponValues.amm556),
                    .KSP58 => _ = zgui.comboFromEnum("Ammunitionstyp", &riskProfile.weaponValues.amm762),
                    .KSP88, .AG90 => _ = zgui.comboFromEnum("Ammunitionstyp", &riskProfile.weaponValues.amm127),
                    .P88 => _ = zgui.comboFromEnum("Ammunitionstyp", &riskProfile.weaponValues.amm9),
                }
                _ = zgui.comboFromEnum("Måltyp", &riskProfile.weaponValues.target);
            }

            { // Box values
                if (riskProfile.config.sort == .Box) {
                    zgui.separatorText("Övningsområde");
                    _ = zgui.inputFloat("Bredd", .{ .v = &riskProfile.box.width });
                    _ = zgui.inputFloat("Längd", .{ .v = &riskProfile.box.length });

                    zgui.setNextItemWidth(80);
                    _ = zgui.inputFloat("Höger", .{ .v = &riskProfile.box.h });
                    zgui.sameLine(.{});
                    zgui.setNextItemWidth(80);
                    _ = zgui.inputFloat("Vänster", .{ .v = &riskProfile.box.v });
                }
            }

            { // SST values
                if (riskProfile.config.sort == .SST) {
                    zgui.separatorText("Övningsområde");
                    _ = zgui.inputFloat("Bredd", .{ .v = &riskProfile.sst.width });

                    zgui.setNextItemWidth(91);
                    _ = zgui.inputFloat("HH", .{ .v = &riskProfile.sst.hh });
                    zgui.sameLine(.{});
                    zgui.setNextItemWidth(91);
                    _ = zgui.inputFloat("HV", .{ .v = &riskProfile.sst.hv });

                    zgui.setNextItemWidth(91);
                    _ = zgui.inputFloat("VV", .{ .v = &riskProfile.sst.vv });
                    zgui.sameLine(.{});
                    zgui.setNextItemWidth(91);
                    _ = zgui.inputFloat("VH", .{ .v = &riskProfile.sst.vh });
                }
            }

            { // Reset
                zgui.newLine();
                zgui.separator();
                zgui.newLine();
                if (zgui.button("Återställ", .{})) riskProfile.reset();
            }

            { // Information text
                zgui.newLine();
                zgui.separator();
                zgui.newLine();
                zgui.textUnformatted("Flytta: Höger musknapp.");
                zgui.textUnformatted(" Zooma: Scrollhjulet.");
            }

            // const draw_list = zgui.getBackgroundDrawList();

            // draw.drawTest(draw_list);

            zgui.end();
            zgui.popStyleVar(.{});
        }
    }

    fn update(self: *Self) void {
        if (!self.open) return;

        riskProfile.update();
    }
};

fn drawGrid(draw_buffer: *drawBuffer) void {
    { // Moveable UI
        camera.begin();
        defer camera.end();

        rl.gl.rlPushMatrix();
        rl.gl.rlTranslatef(0, 50 * 50, 0);
        rl.gl.rlRotatef(90, 1, 0, 0);
        rl.drawGrid(200, 100);
        rl.gl.rlPopMatrix();

        if (riskProfile.config.valid) draw.draw(switch (riskProfile.config.sort) {
            .Box => .Box,
            .SST => .SST,
            .Halva => .Half,
        }, riskProfile, draw_buffer);
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

pub fn main(allocator: std.mem.Allocator) !void {
    var draw_buffer = drawBuffer.init(allocator);
    defer draw_buffer.deinit();

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
        drawGrid(&draw_buffer);
        doMainMenu();

        if (risk_editor_viewer.open) try risk_editor_viewer.show();

        zgui.rlimgui.end();

        rl.endDrawing();
    }
}
