const zgui = @import("zgui");
const rl = @import("raylib");
const reg = @import("reg");
const Context = reg.gui.renderer.Context;
const Color = reg.gui.Color;

const Frame = @This();

const Types = enum {
    riskEditorFrame,
};

pub const RiskEditorFrame = struct {
    open: bool = false,

    pub fn show(self: *RiskEditorFrame, ctx: *Context) void {
        zgui.pushStyleVar2f(.{ .idx = .window_padding, .v = .{ 10, 10 } });
        zgui.setNextWindowSize(.{ .w = 100, .h = 100, .cond = .once });
        zgui.setNextWindowPos(.{ .x = 20.0, .y = 40.0, .cond = .once });

        const zgui_style = zgui.getStyle();
        if (ctx.modal != null) zgui_style.setColor(.window_bg, Color.light_grey);

        if (zgui.begin("Riskprofil", .{
            .popen = &self.open,
            .flags = .{
                .no_scrollbar = true,
                .no_scroll_with_mouse = true,
                .no_resize = true,
                .always_auto_resize = true,
                .no_collapse = true, //TODO Fix crash at : .no_collapse = false
                .no_bring_to_front_on_focus = if (ctx.modal != null) true else false,
                .no_mouse_inputs = if (ctx.modal != null) true else false,
                .no_move = if (ctx.modal != null) true else false,
                .no_nav_inputs = if (ctx.modal != null) true else false,
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
        zgui.pushStyleColor4f(.{ .idx = .text, .c = Color.black });

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
        zgui.pushStyleColor4f(.{ .idx = .text, .c = Color.black });
        { // Config values
            zgui.pushStyleColor4f(.{ .idx = .text, .c = Color.black });
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
