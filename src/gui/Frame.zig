const zgui = @import("zgui");
const Context = @import("../Context.zig");
const Color = @import("Color.zig");
const Window = @import("Window.zig");
const Frame = @This();

const Types = enum(u8) {
    riskEditorFrame,
};

pub const RiskEditorFrame = struct {
    open: bool = false,

    pub fn show(self: *RiskEditorFrame, ctx: *Context) void {
        const frame_width: f32 = 350.0;
        const frame_height: f32 = Window.Config.height;

        zgui.setNextWindowSize(.{ .w = frame_width, .h = frame_height - 10, .cond = .once });
        zgui.setNextWindowPos(.{ .x = 0.0, .y = 18.0, .cond = .once });

        const zgui_style = zgui.getStyle();
        zgui_style.setColor(.window_bg, if (ctx.modal == null) Color.white else Color.platinum);

        if (zgui.begin("Riskprofil", .{
            .popen = &self.open,
            .flags = .{
                .no_scrollbar = true,
                .no_scroll_with_mouse = true,
                .no_resize = true,
                .no_collapse = true,
                .no_bring_to_front_on_focus = if (ctx.modal != null) true else false,
                .no_mouse_inputs = if (ctx.modal != null) true else false,
                .no_nav_inputs = if (ctx.modal != null) true else false,
                .no_title_bar = true,
                .no_move = true,
                .always_auto_resize = false,
            },
        })) {
            zgui.pushStyleVar1f(.{ .idx = .frame_rounding, .v = 2 });
            zgui.pushStyleVar1f(.{ .idx = .frame_border_size, .v = 1 });

            zgui.pushStyleVar1f(.{ .idx = .scrollbar_rounding, .v = 2 });
            zgui.pushStyleVar1f(.{ .idx = .scrollbar_size, .v = 2 });

            zgui.pushStyleColor4f(.{ .idx = .border, .c = Color.gainsboro });
            zgui.pushStyleColor4f(.{ .idx = .frame_bg, .c = Color.gainsboro });
            zgui.pushStyleColor4f(.{ .idx = .separator, .c = Color.gainsboro });
            zgui.pushStyleColor4f(.{ .idx = .header_hovered, .c = Color.alabaster });
            zgui.pushStyleColor4f(.{ .idx = .header_active, .c = Color.alabaster });
            zgui.pushStyleColor4f(.{ .idx = .header, .c = Color.porcelain });

            zgui.pushStyleColor4f(.{ .idx = .scrollbar_bg, .c = Color.black });
            zgui.pushStyleColor4f(.{ .idx = .scrollbar_grab, .c = Color.black });
            zgui.pushStyleColor4f(.{ .idx = .scrollbar_grab_active, .c = Color.black });
            zgui.pushStyleColor4f(.{ .idx = .scrollbar_grab_hovered, .c = Color.black });

            zgui.pushStyleColor4f(.{ .idx = .button, .c = Color.porcelain });
            zgui.pushStyleColor4f(.{ .idx = .button_active, .c = Color.white });
            zgui.pushStyleColor4f(.{ .idx = .button_hovered, .c = Color.white });

            zgui.pushStyleColor4f(.{ .idx = .check_mark, .c = Color.black });
            zgui.pushStyleColor4f(.{ .idx = .text, .c = Color.black });

            zgui.pushStyleVar1f(.{ .idx = .tab_rounding, .v = 2 });
            zgui.pushStyleVar1f(.{ .idx = .tab_border_size, .v = 1 });
            zgui.pushStyleVar1f(.{ .idx = .tab_bar_border_size, .v = 2 });
            zgui.pushStyleColor4f(.{ .idx = .tab, .c = Color.white });
            zgui.pushStyleColor4f(.{ .idx = .tab_hovered, .c = Color.porcelain });
            zgui.pushStyleColor4f(.{ .idx = .tab_selected, .c = Color.porcelain });
            zgui.pushStyleColor4f(.{ .idx = .tab_selected_overline, .c = Color.white });

            zgui.pushStyleVar1f(.{ .idx = .frame_rounding, .v = 2 });
            zgui.pushStyleColor4f(.{ .idx = .frame_bg, .c = Color.white });
            zgui.pushStyleColor4f(.{ .idx = .frame_bg_active, .c = Color.porcelain });
            zgui.pushStyleColor4f(.{ .idx = .frame_bg_hovered, .c = Color.porcelain });
            zgui.pushStyleColor4f(.{ .idx = .popup_bg, .c = Color.white });

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

            zgui.popStyleColor(.{ .count = 23 });
            zgui.popStyleVar(.{ .count = 8 });
            zgui.end();
        }
    }

    fn drawEnd(ctx: *Context) void {
        _ = ctx;

        { // Information text
            zgui.newLine();
            zgui.separator();
            zgui.newLine();
            zgui.textUnformatted("Flytta: Höger musknapp.");
            zgui.textUnformatted(" Zooma: Scrollhjul.");
        }
    }

    fn drawGeneral(ctx: *Context) void {
        { // Config values

            _ = zgui.checkbox("Visa linjer", .{ .v = &ctx.state.config.show });
            zgui.sameLine(.{});

            if (!ctx.state.config.show) zgui.beginDisabled(.{ .disabled = true });
            _ = zgui.checkbox("Visa text", .{ .v = &ctx.state.config.showText });
            if (!ctx.state.config.show) zgui.endDisabled();

            zgui.sameLine(.{});
            {
                if (zgui.button("Återställ", .{})) ctx.state.reset();
            }
        }

        { // Terrain Values
            zgui.separatorText("Terrängvärden");

            _ = zgui.comboFromEnum("Faktor", &ctx.state.terrainValues.factor);
            _ = zgui.inputFloat("Amin", .{ .v = &ctx.state.terrainValues.Amin });
            _ = zgui.inputFloat("Amax", .{ .v = &ctx.state.terrainValues.Amax });
            _ = zgui.inputFloat("f", .{ .v = &ctx.state.terrainValues.f });
            zgui.setNextItemWidth(93);
            _ = zgui.inputFloat("Skogsavstånd", .{ .v = &ctx.state.terrainValues.forestDist });

            zgui.sameLine(.{});
            _ = zgui.checkbox("Uppfångande", .{ .v = &ctx.state.terrainValues.interceptingForest });
        }

        { // Weapons & Ammunition Values
            zgui.separatorText("Vapenvärden");

            zgui.setNextItemWidth(121);
            _ = zgui.comboFromEnum("Vapentyp", &ctx.state.weaponValues.weapon_enum_value);
            zgui.sameLine(.{});

            if (!ctx.state.weaponValues.model.supportable) {
                ctx.state.weaponValues.support = false;
                zgui.beginDisabled(.{ .disabled = true });
            }

            _ = zgui.checkbox("Benstöd", .{ .v = &ctx.state.weaponValues.support });
            if (!ctx.state.weaponValues.model.supportable) zgui.endDisabled();

            switch (ctx.state.weaponValues.weapon_enum_value) {
                .AK5, .KSP90 => _ = zgui.comboFromEnum("Ammunitionstyp", &ctx.state.weaponValues.amm556),
                .KSP58 => _ = zgui.comboFromEnum("Ammunitionstyp", &ctx.state.weaponValues.amm762),
                .KSP88, .AG90 => _ = zgui.comboFromEnum("Ammunitionstyp", &ctx.state.weaponValues.amm127),
                .P88 => _ = zgui.comboFromEnum("Ammunitionstyp", &ctx.state.weaponValues.amm9),
            }

            _ = zgui.comboFromEnum("Måltyp", &ctx.state.weaponValues.target);
        }
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

type: Types,
riskEditorFrame: RiskEditorFrame = undefined,

pub fn create(sort: Types) Frame {
    return switch (sort) {
        .riskEditorFrame => Frame{ .type = .riskEditorFrame, .riskEditorFrame = .{ .open = true } },
    };
}

pub fn show(self: *Frame, ctx: *Context) void {
    const zgui_style = zgui.getStyle();
    zgui_style.setColor(.window_bg, Color.white);

    switch (self.type) {
        .riskEditorFrame => if (self.riskEditorFrame.open) self.riskEditorFrame.show(ctx),
    }
}
