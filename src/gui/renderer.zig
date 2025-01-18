const std = @import("std");
const rl = @import("raylib");
const zgui = @import("zgui");
const reg = @import("reg");
const draw = reg.gui.draw;
const sync = reg.io.sync;
const camera = reg.gui.camera;
const DrawBuffer = reg.gui.DrawBuffer;

var riskProfile = reg.data.state.RiskProfile.init();

var risk_editor_viewer: RiskEditorWindow = undefined;

const windowConfig = struct {
    const title: [*:0]const u8 = "ZRAC";
    const size = .{ .width = 1200, .height = 800 };
    const FPS: i32 = 60;

    var icon: rl.Image = undefined;
    var quit: bool = false;
};

const RiskEditorWindow = struct {
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
                .no_collapse = true, //TODO Fix crash at : .no_collapse = false
            },
        })) {
            if (zgui.beginTabBar("test", .{})) {
                if (zgui.beginTabItem("Halva", .{})) {
                    zgui.pushStyleColor4f(.{ .idx = .text, .c = .{ 0.0, 0.0, 0.0, 1 } });
                    {
                        zgui.textUnformatted("1");
                    }
                    zgui.popStyleColor(.{ .count = 1 });
                    zgui.endTabItem();
                }
                if (zgui.beginTabItem("SST", .{})) {
                    zgui.pushStyleColor4f(.{ .idx = .text, .c = .{ 0.0, 0.0, 0.0, 1 } });
                    {
                        zgui.textUnformatted("2");
                    }
                    zgui.popStyleColor(.{ .count = 1 });
                    zgui.endTabItem();
                }
                if (zgui.beginTabItem("Box", .{})) {
                    zgui.pushStyleColor4f(.{ .idx = .text, .c = .{ 0.0, 0.0, 0.0, 1 } });
                    {
                        zgui.textUnformatted("3");
                    }
                    zgui.popStyleColor(.{ .count = 1 });
                    zgui.endTabItem();
                }

                zgui.endTabBar();
            }

            zgui.pushStyleColor4f(.{ .idx = .text, .c = .{ 0.0, 0.0, 0.0, 1 } });
            { // Config values
                zgui.pushStyleColor4f(.{ .idx = .text, .c = .{ 0.0, 0.0, 0.0, 1 } });
                {
                    _ = zgui.checkbox("Visa linjer", .{ .v = &riskProfile.config.show });
                    zgui.sameLine(.{});

                    if (!riskProfile.config.show) zgui.beginDisabled(.{ .disabled = true });
                    _ = zgui.checkbox("Visa text", .{ .v = &riskProfile.config.showText });
                    if (!riskProfile.config.show) zgui.endDisabled();
                }
                zgui.popStyleColor(.{ .count = 1 });
            }

            { // Type value
                zgui.separatorText("Typ");
                zgui.pushStyleColor4f(.{ .idx = .text, .c = .{ 0.0, 0.0, 0.0, 1 } });
                {
                    _ = zgui.comboFromEnum("Typ", &riskProfile.config.sort);
                }
                zgui.popStyleColor(.{ .count = 1 });
            }

            { // Terrain Values
                zgui.separatorText("Terrängvärden");

                zgui.pushStyleColor4f(.{ .idx = .text, .c = .{ 1.0, 1.0, 1.0, 1 } });
                {
                    _ = zgui.comboFromEnum("Faktor", &riskProfile.terrainValues.factor);
                    _ = zgui.inputFloat("Amin", .{ .v = &riskProfile.terrainValues.Amin });
                    _ = zgui.inputFloat("Amax", .{ .v = &riskProfile.terrainValues.Amax });
                    _ = zgui.inputFloat("f", .{ .v = &riskProfile.terrainValues.f });
                    zgui.setNextItemWidth(93);
                    _ = zgui.inputFloat("Skogsavstånd", .{ .v = &riskProfile.terrainValues.forestDist });
                }
                zgui.popStyleColor(.{ .count = 1 });

                zgui.sameLine(.{});
                _ = zgui.checkbox("Uppfångande", .{ .v = &riskProfile.terrainValues.interceptingForest });
            }

            { // Weapons & Ammunition Values
                zgui.separatorText("Vapenvärden");
                zgui.pushStyleColor4f(.{ .idx = .text, .c = .{ 1.0, 1.0, 1.0, 1 } });
                {
                    zgui.setNextItemWidth(121);
                    _ = zgui.comboFromEnum("Vapentyp", &riskProfile.weaponValues.weapon_enum_value);
                    zgui.sameLine(.{});

                    if (!riskProfile.getHasSupport()) {
                        riskProfile.weaponValues.support = false;
                        zgui.beginDisabled(.{ .disabled = true });
                    }
                }
                zgui.popStyleColor(.{ .count = 1 });

                _ = zgui.checkbox("Benstöd", .{ .v = &riskProfile.weaponValues.support });
                if (!riskProfile.getHasSupport()) zgui.endDisabled();

                zgui.pushStyleColor4f(.{ .idx = .text, .c = .{ 1.0, 1.0, 1.0, 1 } });
                {
                    switch (riskProfile.weaponValues.weapon_enum_value) {
                        .AK5, .KSP90 => _ = zgui.comboFromEnum("Ammunitionstyp", &riskProfile.weaponValues.amm556),
                        .KSP58 => _ = zgui.comboFromEnum("Ammunitionstyp", &riskProfile.weaponValues.amm762),
                        .KSP88, .AG90 => _ = zgui.comboFromEnum("Ammunitionstyp", &riskProfile.weaponValues.amm127),
                        .P88 => _ = zgui.comboFromEnum("Ammunitionstyp", &riskProfile.weaponValues.amm9),
                    }
                    _ = zgui.comboFromEnum("Måltyp", &riskProfile.weaponValues.target);
                }
                zgui.popStyleColor(.{ .count = 1 });
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
                zgui.pushStyleColor4f(.{ .idx = .text, .c = .{ 1.0, 1.0, 1.0, 1 } });
                {
                    if (zgui.button("Återställ", .{})) riskProfile.reset();
                }
                zgui.popStyleColor(.{ .count = 1 });
            }

            { // Information text
                zgui.newLine();
                zgui.separator();
                zgui.newLine();
                zgui.textUnformatted("Flytta: Höger musknapp.");
                zgui.textUnformatted(" Zooma: Scrollhjul.");
            }
            zgui.popStyleColor(.{ .count = 1 });

            // listTest();

            zgui.getStyle().frame_padding = .{ 5, 5 };
            if (zgui.beginListBox("test", .{ .w = 500, .h = 100 })) {
                listTest();
                zgui.endListBox();
            }

            zgui.end();
            zgui.popStyleVar(.{});
        }
    }

    fn update(self: *Self) void {
        if (!self.open) return;

        riskProfile.update();
    }
};

fn listTest() void {
    const items = [_][:0]const u8{ "1", "2", "3" };

    for (items, 0..) |item, index| {
        zgui.pushStyleColor4f(.{ .idx = .check_mark, .c = .{ 0.0, 0.0, 0.0, 1 } });
        zgui.pushStyleColor4f(.{ .idx = .frame_bg, .c = .{ 1.0, 1.0, 1.0, 1 } });
        zgui.pushStyleColor4f(.{ .idx = .frame_bg_hovered, .c = .{ 0.7, 0.7, 0.7, 1 } });

        _ = zgui.checkbox(item, .{ .v = &riskProfile.terrainValues.interceptingForest });
        zgui.popStyleColor(.{ .count = 3 });

        zgui.sameLine(.{});
        zgui.pushStyleColor4f(.{ .idx = .text, .c = .{ 0.0, 0.0, 0.0, 1 } });
        zgui.textUnformatted(item);
        zgui.sameLine(.{});
        zgui.textUnformatted(item);
        zgui.popStyleColor(.{ .count = 1 });
        zgui.pushStyleColor4f(.{ .idx = .separator, .c = .{ 1.0, 1.0, 1.0, 1 } });
        if (index != items.len - 1) zgui.separator();
        zgui.popStyleColor(.{ .count = 1 });
    }
}

fn drawPlane(draw_buffer: *DrawBuffer) !void {
    camera.begin();
    defer camera.end();

    rl.gl.rlPushMatrix();
    rl.gl.rlTranslatef(50 * 50, 50 * 50, 0);
    rl.gl.rlRotatef(90, 1, 0, 0);
    rl.drawGrid(200, 200);
    rl.gl.rlPopMatrix();

    if (riskProfile.config.valid) try draw.draw(switch (riskProfile.config.sort) {
        .Box => .Box,
        .SST => .SST,
        .Halva => .Half,
    }, riskProfile, draw_buffer);
}

fn doMainMenu() void {
    if (zgui.beginMainMenuBar()) {
        if (zgui.beginMenu("Fil", true)) {
            if (zgui.menuItem("Importera", .{})) sync.load();
            if (zgui.menuItem("Exportera", .{})) sync.save();
            zgui.separator();
            if (zgui.menuItem("Avsluta", .{})) windowConfig.quit = true;
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
    var draw_buffer = DrawBuffer.init(allocator);
    defer draw_buffer.deinit();

    rl.setConfigFlags(.{ .msaa_4x_hint = true, .vsync_hint = true });
    rl.initWindow(windowConfig.size.width, windowConfig.size.height, windowConfig.title);
    defer rl.closeWindow();

    windowConfig.icon = rl.loadImage("assets/icon.png");
    windowConfig.icon.useAsWindowIcon();

    rl.setTargetFPS(60);
    zgui.rlimgui.setup(true);
    defer zgui.rlimgui.shutdown();
    zgui.io.setConfigWindowsMoveFromTitleBarOnly(true);

    { // Styling
        const style = zgui.getStyle();

        style.setColor(.header, .{ 0.094, 0.094, 0.106, 1.0 });
        style.setColor(.window_bg, .{ 1.0, 1.0, 1.0, 1.0 });
        style.setColor(.check_mark, .{ 1.0, 1.0, 1.0, 1.0 });

        style.setColor(.button, .{ 0.094, 0.094, 0.106, 1.0 });
        style.setColor(.button_active, .{ 0.184, 0.184, 0.192, 1.0 });
        style.setColor(.button_hovered, .{ 0.184, 0.184, 0.192, 1.0 });

        style.setColor(.title_bg, .{ 0.094, 0.094, 0.106, 1.0 });
        style.setColor(.title_bg_active, .{ 0.094, 0.094, 0.106, 1.0 });

        style.setColor(.border, .{ 0.184, 0.184, 0.192, 1.0 });

        style.setColor(.frame_bg, .{ 0.094, 0.094, 0.106, 1.0 });
        style.setColor(.frame_bg_active, .{ 0.094, 0.094, 0.106, 1.0 });
        style.setColor(.frame_bg_hovered, .{ 0.184, 0.184, 0.192, 1.0 });

        style.setColor(.tab, .{ 0.184, 0.184, 0.192, 1.0 });
        style.setColor(.tab_hovered, .{ 0.094, 0.094, 0.106, 1.0 });
        style.setColor(.tab_selected, .{ 0.094, 0.094, 0.106, 1.0 });
        style.setColor(.tab_selected_overline, .{ 1.0, 1.0, 1.0, 1.0 });

        style.tab_rounding = 2;
        style.popup_rounding = 3.0;
        style.window_min_size = .{ 320.0, 240.0 };
        style.scrollbar_size = 6.0;
        {
            var color = style.getColor(.scrollbar_grab);
            color[1] = 0.8;
            style.setColor(.scrollbar_grab, color);
        }
    }

    risk_editor_viewer.open = true;

    while (!rl.windowShouldClose() and !windowConfig.quit) {
        camera.handle();
        risk_editor_viewer.update();

        rl.beginDrawing();
        rl.clearBackground(rl.Color.white);

        zgui.rlimgui.begin();
        try drawPlane(&draw_buffer);
        doMainMenu();

        if (risk_editor_viewer.open) try risk_editor_viewer.show();

        try draw_buffer.clear();
        zgui.rlimgui.end();

        rl.endDrawing();
    }
}
