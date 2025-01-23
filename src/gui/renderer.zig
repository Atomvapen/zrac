const std = @import("std");
const rl = @import("raylib");
const zgui = @import("zgui");
const reg = @import("reg");
const plane = reg.gui.plane;
const sync = reg.io.sync;
const camera = reg.gui.camera;
const DrawBuffer = reg.gui.DrawBuffer;
const Color = reg.gui.Color;

const Context = struct {
    state: reg.data.State,
    draw_buffer: DrawBuffer,
    window: Window,
    // frames: struct { risk_editor: RiskEditorFrame, export_frame: ExportFrame },
    // frame: ?*Frame = null,
    frame: ?Frame = undefined,

    pub fn create(allocator: std.mem.Allocator) Context {
        // const frame = Frame{ .riskFrame = RiskEditorFrame{ .open = true } };
        return Context{
            .state = reg.data.State{},
            .draw_buffer = DrawBuffer.init(allocator),
            .window = Window{ .config = .{} },
            // .frames = .{
            //     .risk_editor = RiskEditorFrame{ .open = true },
            //     .export_frame = ExportFrame{ .open = false },
            // },
            // .frame = undefined,
            // .frame = &frame,
            .frame = Frame{ .riskFrame = RiskEditorFrame{ .open = true } },
        };
    }

    // pub fn closeActiveFrame(self: *Context) void {
    //     if (self.frame) |frame| {
    //         switch (frame.*) {
    //             .riskEditorFrame => |risk_editor| risk_editor.open = false,
    //             .exportFrame => |export_frame| export_frame.open = false,
    //         }
    //     }
    //     self.frame = null;
    // }

    pub fn destroy(self: *Context) void {
        self.draw_buffer.clearAndFree();
        self.draw_buffer.deinit();
    }

    pub fn update(self: *Context) void {
        self.state.update();
    }
};

const Frames = enum {
    riskFrame,
    exportFrame,
};

const Frame = union(Frames) {
    riskFrame: RiskEditorFrame,
    exportFrame: ExportFrame,

    pub fn show(self: *Frame, ctx: *Context) void {
        switch (self.*) {
            .riskFrame => |*risk_frame| if (risk_frame.open) risk_frame.show(ctx),
            .exportFrame => |*export_frame| if (export_frame.open) export_frame.*.show(ctx),
        }
    }
};

const RiskEditorFrame = struct {
    open: bool = false,

    pub fn show(self: *RiskEditorFrame, ctx: *Context) void {
        zgui.pushStyleVar2f(.{ .idx = .window_padding, .v = .{ 10, 10 } });
        zgui.setNextWindowSize(.{ .w = 100, .h = 100, .cond = .once });
        zgui.setNextWindowPos(.{ .x = 20.0, .y = 40.0, .cond = .once });

        if (zgui.begin("Riskprofil", .{
            .popen = &self.open,
            .flags = .{
                .no_scrollbar = true,
                .no_scroll_with_mouse = true,
                .no_resize = true,
                .always_auto_resize = true,
                .no_collapse = true, //TODO Fix crash at : .no_collapse = false
                // .no_bring_to_front_on_focus = if (ctx.frames.export_frame.open) true else false,
                // .no_mouse_inputs = if (ctx.frames.export_frame.open) true else false,
                // .no_move = if (ctx.frames.export_frame.open) true else false,
                // .no_nav_inputs = if (ctx.frames.export_frame.open) true else false,

                // .no_bring_to_front_on_focus = if (ctx.frame != self) true else false,
                // .no_bring_to_front_on_focus = if (ctx.frame) |frame| frame != self else true,
                // .no_bring_to_front_on_focus = if (ctx.frame != null and ctx.frame.* != self) true else false,
                // .no_mouse_inputs = if (ctx.frames.export_frame.open) true else false,
                // .no_move = if (ctx.frames.export_frame.open) true else false,
                // .no_nav_inputs = if (ctx.frames.export_frame.open) true else false,
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

                if (!ctx.state.weaponValues.model.supportable) {
                    ctx.state.weaponValues.support = false;
                    zgui.beginDisabled(.{ .disabled = true });
                }
            }
            zgui.popStyleColor(.{ .count = 1 });

            _ = zgui.checkbox("Benstöd", .{ .v = &ctx.state.weaponValues.support });
            if (!ctx.state.weaponValues.model.supportable) zgui.endDisabled();

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

const ExportFrame = struct {
    open: bool = false,

    pub fn show(self: *ExportFrame, ctx: *Context) void {
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
            zgui.textUnformatted("test");

            if (zgui.button("Acceptera", .{ .h = 50, .w = 100 })) {}
            zgui.sameLine(.{});
            // if (zgui.button("Avbryt", .{ .h = 50, .w = 100 })) self.open = false;
            if (zgui.button("Avbryt", .{ .h = 50, .w = 100 })) ctx.frame = null;
            zgui.end();
            zgui.popStyleVar(.{});
        }
    }
};

const Window = struct {
    config: struct {
        title: [*:0]const u8 = "ZRAC",
        size: struct { width: i32, height: i32 } = .{ .width = 1200, .height = 800 },
        FPS: i32 = 60,
        icon: rl.Image = undefined,
        quit: bool = false,
    },

    pub fn drawPlane(_: *Window, ctx: *Context) !void {
        camera.begin();
        defer camera.end();

        rl.gl.rlPushMatrix();
        rl.gl.rlTranslatef(50 * 50, 50 * 50, 0);
        rl.gl.rlRotatef(90, 1, 0, 0);
        rl.drawGrid(200, 200);
        rl.gl.rlPopMatrix();

        if (ctx.state.config.valid) try plane.draw(ctx.state.config.sort, ctx.state, &ctx.draw_buffer);
        ctx.draw_buffer.execute();
    }

    pub fn drawMainMenu(_: *Window, ctx: *Context) void {
        if (zgui.beginMainMenuBar()) {
            if (zgui.beginMenu("Fil", true)) {
                if (zgui.menuItem("Importera", .{})) sync.load();
                if (zgui.menuItem("Exportera", .{})) {
                    sync.save();
                    // var frame = Frame{ .exportFrame = ExportFrame{ .open = true } };
                    // ctx.frame = &frame;
                    ctx.frame = Frame{ .exportFrame = ExportFrame{ .open = true } };
                }
                zgui.separator();
                if (zgui.menuItem("Avsluta", .{})) ctx.window.config.quit = true;
                zgui.endMenu();
            }

            if (zgui.beginMenu("Fönster", true)) {
                if (zgui.menuItem("Riskprofil", .{})) {
                    // var frame = Frame{ .riskFrame = RiskEditorFrame{ .open = true } };
                    // ctx.frame = &frame;
                    ctx.frame = Frame{ .riskFrame = RiskEditorFrame{ .open = true } };
                }
                zgui.endMenu();
            }

            zgui.endMainMenuBar();
        }
    }

    pub fn style(_: *Window) void {
        const zgui_style = zgui.getStyle();

        zgui_style.setColor(.header, Color.dark_grey);
        zgui_style.setColor(.window_bg, Color.white);
        zgui_style.setColor(.check_mark, Color.white);

        zgui_style.setColor(.button, Color.dark_grey);
        zgui_style.setColor(.button_active, Color.grey);
        zgui_style.setColor(.button_hovered, Color.grey);

        zgui_style.setColor(.title_bg, Color.dark_grey);
        zgui_style.setColor(.title_bg_active, Color.dark_grey);

        zgui_style.setColor(.border, Color.grey);

        zgui_style.setColor(.frame_bg, Color.dark_grey);
        zgui_style.setColor(.frame_bg_active, Color.dark_grey);
        zgui_style.setColor(.frame_bg_hovered, Color.grey);

        zgui_style.setColor(.tab, Color.grey);
        zgui_style.setColor(.tab_hovered, Color.dark_grey);
        zgui_style.setColor(.tab_selected, Color.dark_grey);
        zgui_style.setColor(.tab_selected_overline, Color.white);

        zgui_style.tab_rounding = 2;
        zgui_style.popup_rounding = 3.0;
        zgui_style.window_min_size = .{ 320.0, 240.0 };
    }

    pub fn setProperties(_: *Window, ctx: *Context) void {
        ctx.window.config.icon = rl.loadImage("assets/icon.png");
        ctx.window.config.icon.useAsWindowIcon();

        rl.setTargetFPS(ctx.window.config.FPS);

        zgui.io.setConfigWindowsMoveFromTitleBarOnly(true);
    }

    pub fn setConfigFlags(_: *Window) void {
        rl.setConfigFlags(.{ .msaa_4x_hint = true, .vsync_hint = true });
    }

    pub fn init(self: *Window) void {
        rl.initWindow(self.config.size.width, self.config.size.height, self.config.title);
        zgui.rlimgui.setup(true);
    }

    pub fn deinit(_: *Window) void {
        zgui.rlimgui.shutdown();
        rl.closeWindow();
    }
};

pub fn main(allocator: std.mem.Allocator) !void {
    var ctx: Context = Context.create(allocator);
    defer ctx.destroy();

    ctx.window.setConfigFlags();
    ctx.window.init();
    defer ctx.window.deinit();
    ctx.window.setProperties(&ctx);
    ctx.window.style();

    while (!rl.windowShouldClose() and !ctx.window.config.quit) {
        ctx.update();

        rl.beginDrawing();
        defer rl.endDrawing();

        zgui.rlimgui.begin();
        defer zgui.rlimgui.end();

        rl.clearBackground(rl.Color.white);
        try ctx.window.drawPlane(&ctx);
        ctx.window.drawMainMenu(&ctx);

        // if (ctx.frames.risk_editor.open) ctx.frames.risk_editor.show(&ctx);
        // if (ctx.frames.export_frame.open) ctx.frames.export_frame.show(&ctx);

        if (ctx.frame) |*frame| {
            std.debug.print("{any}\n", .{ctx.frame});
            frame.show(&ctx);

            camera.enabled = if (switch (frame.*) {
                .exportFrame => |exp| exp.open,
                else => false,
            } == true) false else true;
        }

        try ctx.draw_buffer.clear();
        // camera.enabled = if (ctx.frames.export_frame.open) false else true;
        // camera.enabled = if (ctx.frame) |frame| frame.open = true then false else true;
        if (camera.enabled) camera.handle();
    }
}
