const std = @import("std");
const rl = @import("raylib");
const zgui = @import("zgui");
const reg = @import("reg");
const draw = reg.gui.draw;
const sync = reg.io.sync;
const camera = reg.gui.camera;
const DrawBuffer = reg.gui.DrawBuffer;
const Color = reg.gui.Color;

const Context = struct {
    state: reg.data.state.RiskProfile,
    draw_buffer: DrawBuffer,
    risk_editor_viewer: RiskEditorWindow,

    pub fn create(allocator: std.mem.Allocator) !Context {
        return Context{
            .state = reg.data.state.RiskProfile.init(),
            .draw_buffer = DrawBuffer.init(allocator),
            .risk_editor_viewer = RiskEditorWindow{},
        };
    }

    pub fn destroy(self: *Context) void {
        self.draw_buffer.deinit();
    }

    pub fn update(self: *Context) void {
        self.state.update();
    }
};

const windowConfig = struct {
    const title: [*:0]const u8 = "ZRAC";
    const size = .{ .width = 1200, .height = 800 };
    const FPS: i32 = 60;

    var icon: rl.Image = undefined;
    var quit: bool = false;
};

const RiskEditorWindow = struct {
    const Self = @This();

    open: bool = true,
    quit: bool = false,

    pub fn show(self: *Self, ctx: *Context) !void {
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
            if (zgui.beginTabBar("Type", .{})) {
                if (zgui.beginTabItem("Halva", .{})) {
                    ctx.state.config.sort = .Halva;
                    zgui.endTabItem();
                }
                if (zgui.beginTabItem("SST", .{})) {
                    ctx.state.config.sort = .SST;
                    zgui.endTabItem();
                }
                if (zgui.beginTabItem("Box", .{})) {
                    ctx.state.config.sort = .Box;
                    zgui.endTabItem();
                }

                zgui.endTabBar();
            }

            drawGeneral(ctx);

            switch (ctx.state.config.sort) {
                .Halva => {},
                .SST => drawSST(ctx),
                .Box => drawBox(ctx),
            }

            drawEnd(ctx);

            zgui.end();
            zgui.popStyleVar(.{});
        }
    }

    fn drawEnd(ctx: *Context) void {
        _ = ctx;
        zgui.pushStyleColor4f(.{ .idx = .text, .c = .{ 0.0, 0.0, 0.0, 1 } });
        // { // Reset
        //     zgui.newLine();
        //     zgui.separator();
        //     zgui.newLine();
        // zgui.pushStyleColor4f(.{ .idx = .text, .c = .{ 1.0, 1.0, 1.0, 1 } });
        // {
        //     if (zgui.button("Återställ", .{})) ctx.state.reset();
        // }
        // zgui.popStyleColor(.{ .count = 1 });
        // }

        { // Information text
            zgui.newLine();
            zgui.separator();
            zgui.newLine();
            zgui.textUnformatted("Flytta: Höger musknapp.");
            zgui.textUnformatted(" Zooma: Scrollhjul.");
        }
        zgui.popStyleColor(.{ .count = 1 });
    }

    fn drawGeneral(ctx: *Context) void {
        zgui.pushStyleColor4f(.{ .idx = .text, .c = .{ 0.0, 0.0, 0.0, 1 } });
        { // Config values
            zgui.pushStyleColor4f(.{ .idx = .text, .c = .{ 0.0, 0.0, 0.0, 1 } });
            {
                _ = zgui.checkbox("Visa linjer", .{ .v = &ctx.state.config.show });
                zgui.sameLine(.{});

                if (!ctx.state.config.show) zgui.beginDisabled(.{ .disabled = true });
                _ = zgui.checkbox("Visa text", .{ .v = &ctx.state.config.showText });
                if (!ctx.state.config.show) zgui.endDisabled();

                zgui.sameLine(.{});
                zgui.pushStyleColor4f(.{ .idx = .text, .c = .{ 1.0, 1.0, 1.0, 1 } });
                {
                    if (zgui.button("Återställ", .{})) ctx.state.reset();
                }
                zgui.popStyleColor(.{ .count = 1 });
            }
            zgui.popStyleColor(.{ .count = 1 });
        }

        // { // Type value
        //     zgui.separatorText("Typ");
        //     zgui.pushStyleColor4f(.{ .idx = .text, .c = .{ 1.0, 1.0, 1.0, 1 } });
        //     {
        //         _ = zgui.comboFromEnum("Typ", &ctx.state.config.sort);
        //     }
        //     zgui.popStyleColor(.{ .count = 1 });
        // }

        { // Terrain Values
            zgui.separatorText("Terrängvärden");

            zgui.pushStyleColor4f(.{ .idx = .text, .c = .{ 1.0, 1.0, 1.0, 1 } });
            {
                _ = zgui.comboFromEnum("Faktor", &ctx.state.terrainValues.factor);
                _ = zgui.inputFloat("Amin", .{ .v = &ctx.state.terrainValues.Amin });
                _ = zgui.inputFloat("Amax", .{ .v = &ctx.state.terrainValues.Amax });
                _ = zgui.inputFloat("f", .{ .v = &ctx.state.terrainValues.f });
                zgui.setNextItemWidth(93);
                _ = zgui.inputFloat("Skogsavstånd", .{ .v = &ctx.state.terrainValues.forestDist });
            }
            zgui.popStyleColor(.{ .count = 1 });

            zgui.sameLine(.{});
            _ = zgui.checkbox("Uppfångande", .{ .v = &ctx.state.terrainValues.interceptingForest });
        }

        { // Weapons & Ammunition Values
            zgui.separatorText("Vapenvärden");
            zgui.pushStyleColor4f(.{ .idx = .text, .c = .{ 1.0, 1.0, 1.0, 1 } });
            {
                zgui.setNextItemWidth(121);
                _ = zgui.comboFromEnum("Vapentyp", &ctx.state.weaponValues.weapon_enum_value);
                zgui.sameLine(.{});

                if (!ctx.state.getHasSupport()) {
                    ctx.state.weaponValues.support = false;
                    zgui.beginDisabled(.{ .disabled = true });
                }
            }
            zgui.popStyleColor(.{ .count = 1 });

            _ = zgui.checkbox("Benstöd", .{ .v = &ctx.state.weaponValues.support });
            if (!ctx.state.getHasSupport()) zgui.endDisabled();

            zgui.pushStyleColor4f(.{ .idx = .text, .c = .{ 1.0, 1.0, 1.0, 1 } });
            {
                switch (ctx.state.weaponValues.weapon_enum_value) {
                    .AK5, .KSP90 => _ = zgui.comboFromEnum("Ammunitionstyp", &ctx.state.weaponValues.amm556),
                    .KSP58 => _ = zgui.comboFromEnum("Ammunitionstyp", &ctx.state.weaponValues.amm762),
                    .KSP88, .AG90 => _ = zgui.comboFromEnum("Ammunitionstyp", &ctx.state.weaponValues.amm127),
                    .P88 => _ = zgui.comboFromEnum("Ammunitionstyp", &ctx.state.weaponValues.amm9),
                }
                _ = zgui.comboFromEnum("Måltyp", &ctx.state.weaponValues.target);
            }
            zgui.popStyleColor(.{ .count = 1 });
        }

        zgui.popStyleColor(.{ .count = 1 });
    }

    fn drawSST(ctx: *Context) void {
        zgui.separatorText("Övningsområde");
        _ = zgui.inputFloat("Bredd", .{ .v = &ctx.state.sst.width });

        zgui.setNextItemWidth(91);
        _ = zgui.inputFloat("HH", .{ .v = &ctx.state.sst.hh });
        zgui.sameLine(.{});
        zgui.setNextItemWidth(91);
        _ = zgui.inputFloat("HV", .{ .v = &ctx.state.sst.hv });

        zgui.setNextItemWidth(91);
        _ = zgui.inputFloat("VV", .{ .v = &ctx.state.sst.vv });
        zgui.sameLine(.{});
        zgui.setNextItemWidth(91);
        _ = zgui.inputFloat("VH", .{ .v = &ctx.state.sst.vh });
    }

    fn drawBox(ctx: *Context) void {
        zgui.separatorText("Övningsområde");
        _ = zgui.inputFloat("Bredd", .{ .v = &ctx.state.box.width });
        _ = zgui.inputFloat("Längd", .{ .v = &ctx.state.box.length });

        zgui.setNextItemWidth(80);
        _ = zgui.inputFloat("Höger", .{ .v = &ctx.state.box.h });
        zgui.sameLine(.{});
        zgui.setNextItemWidth(80);
        _ = zgui.inputFloat("Vänster", .{ .v = &ctx.state.box.v });
    }
};

fn drawPlane(ctx: *Context) !void {
    camera.begin();
    defer camera.end();

    rl.gl.rlPushMatrix();
    rl.gl.rlTranslatef(50 * 50, 50 * 50, 0);
    rl.gl.rlRotatef(90, 1, 0, 0);
    rl.drawGrid(200, 200);
    rl.gl.rlPopMatrix();

    if (ctx.state.config.valid) try draw.draw(switch (ctx.state.config.sort) {
        .Box => .Box,
        .SST => .SST,
        .Halva => .Half,
    }, ctx.state, &ctx.draw_buffer);
}

fn doMainMenu(ctx: *Context) void {
    if (zgui.beginMainMenuBar()) {
        if (zgui.beginMenu("Fil", true)) {
            if (zgui.menuItem("Importera", .{})) sync.load();
            if (zgui.menuItem("Exportera", .{})) sync.save();
            zgui.separator();
            if (zgui.menuItem("Avsluta", .{})) windowConfig.quit = true;
            zgui.endMenu();
        }

        if (zgui.beginMenu("Fönster", true)) {
            if (zgui.menuItem("Riskprofil", .{})) ctx.risk_editor_viewer.open = !ctx.risk_editor_viewer.open;
            zgui.endMenu();
        }

        zgui.endMainMenuBar();
    }
}

fn styleWindow() void {
    const style = zgui.getStyle();

    style.setColor(.header, Color.dark_grey);
    style.setColor(.window_bg, Color.white);
    style.setColor(.check_mark, Color.white);

    style.setColor(.button, Color.dark_grey);
    style.setColor(.button_active, Color.grey);
    style.setColor(.button_hovered, Color.grey);

    style.setColor(.title_bg, Color.dark_grey);
    style.setColor(.title_bg_active, Color.dark_grey);

    style.setColor(.border, Color.grey);

    style.setColor(.frame_bg, Color.dark_grey);
    style.setColor(.frame_bg_active, Color.dark_grey);
    style.setColor(.frame_bg_hovered, Color.grey);

    style.setColor(.tab, Color.grey);
    style.setColor(.tab_hovered, Color.dark_grey);
    style.setColor(.tab_selected, Color.dark_grey);
    style.setColor(.tab_selected_overline, Color.white);

    style.tab_rounding = 2;
    style.popup_rounding = 3.0;
    style.window_min_size = .{ 320.0, 240.0 };
}

pub fn main(allocator: std.mem.Allocator) !void {
    var ctx = try Context.create(allocator);
    defer ctx.destroy();

    rl.setConfigFlags(.{ .msaa_4x_hint = true, .vsync_hint = true });
    rl.initWindow(windowConfig.size.width, windowConfig.size.height, windowConfig.title);
    defer rl.closeWindow();

    windowConfig.icon = rl.loadImage("assets/icon.png");
    windowConfig.icon.useAsWindowIcon();

    rl.setTargetFPS(60);
    zgui.rlimgui.setup(true);
    defer zgui.rlimgui.shutdown();
    zgui.io.setConfigWindowsMoveFromTitleBarOnly(true);

    styleWindow();

    while (!rl.windowShouldClose() and !windowConfig.quit) {
        camera.handle();
        ctx.update();

        rl.beginDrawing();
        rl.clearBackground(rl.Color.white);

        zgui.rlimgui.begin();
        try drawPlane(&ctx);
        doMainMenu(&ctx);

        if (ctx.risk_editor_viewer.open) try ctx.risk_editor_viewer.show(&ctx);

        try ctx.draw_buffer.clear();
        zgui.rlimgui.end();

        rl.endDrawing();
    }
}
