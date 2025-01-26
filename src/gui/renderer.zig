const std = @import("std");
const rl = @import("raylib");
const zgui = @import("zgui");
const reg = @import("reg");
const plane = reg.gui.plane;
const camera = reg.gui.camera;
const DrawBuffer = reg.gui.DrawBuffer;
const Color = reg.gui.Color;
const Modal = reg.gui.Modal;
const Frame = reg.gui.Frames;
const State = reg.data.State;

pub const Context = struct {
    state: State,
    draw_buffer: DrawBuffer,
    window: Window,
    modal: ?Modal,
    frames: struct {
        riskEditorFrame: Frame.RiskEditorFrame = undefined,
    },

    pub fn create(allocator: std.mem.Allocator) Context {
        defer std.debug.print("INFO: Context created successfully\n", .{});
        errdefer std.debug.print("INFO: Context creation failed\n", .{});

        return Context{
            .state = State{},
            .draw_buffer = DrawBuffer.init(allocator),
            .window = Window{ .config = .{} },
            .modal = null,
            .frames = .{
                .riskEditorFrame = Frame.RiskEditorFrame{ .open = true },
            },
        };
    }

    pub fn destroy(self: *Context) void {
        defer std.debug.print("INFO: Context destroyed successfully\n", .{});
        errdefer std.debug.print("INFO: Context destruction failed\n", .{});

        self.modal = null;
        self.draw_buffer.clearAndFree();
        self.draw_buffer.deinit();
    }

    pub fn update(self: *Context) void {
        self.state.update();
    }
};

pub const Window = struct {
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
                if (zgui.menuItem("Importera", .{})) ctx.modal = Modal.set(.importModal);
                if (zgui.menuItem("Exportera", .{})) ctx.modal = Modal.set(.exportModal);
                zgui.separator();
                if (zgui.menuItem("Avsluta", .{})) ctx.window.config.quit = true;
                zgui.endMenu();
            }

            if (zgui.beginMenu("Fönster", true)) {
                if (zgui.menuItem("Riskprofil", .{})) ctx.frames.riskEditorFrame.open = !ctx.frames.riskEditorFrame.open;
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

        try draw(&ctx);

        camera.enabled = (ctx.modal == null);
        if (camera.enabled) camera.handle();
    }
}

fn draw(ctx: *Context) !void {
    rl.clearBackground(rl.Color.white);
    try ctx.window.drawPlane(ctx);
    ctx.window.drawMainMenu(ctx);

    if (ctx.frames.riskEditorFrame.open) ctx.frames.riskEditorFrame.show(ctx);

    if (ctx.modal) |*modal| {
        if (!modal.isOpen()) ctx.modal = null;
        modal.show();
    }

    try ctx.draw_buffer.clear();
}
