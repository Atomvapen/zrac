const Self = @This();
const std = @import("std");

const Window = @import("gui/Window.zig");
const DrawBuffer = @import("gui/DrawBuffer.zig");

allocator: std.mem.Allocator,
window: *Window,
state: State,
draw_buffer: DrawBuffer,

pub fn create(allocator: std.mem.Allocator) !*Self {
    const self: *Self = try allocator.create(Self);
    errdefer allocator.destroy(self);
    const window: *Window = try Window.create(allocator);

    self.* = .{
        .allocator = allocator,
        .window = window,
        .state = .{},
        .draw_buffer = DrawBuffer.init(allocator),
    };

    return self;
}

pub fn destroy(self: *Self, allocator: std.mem.Allocator) void {
    // self.window.destroy(allocator);
    allocator.destroy(self);
}

pub fn update(self: *Self) void {
    self.state.update();
}

pub const State = struct {
    const weapon = @import("data/weapon.zig");
    const ammunition = @import("data/ammunition.zig");
    const risk = @import("math/risk.zig");
    const Config = struct {
        show: bool = true,
        valid: bool = false,
        sort: enum { Box, SST, Halva } = .Halva,
        showText: bool = false,
    };
    const TerrainValues = struct {
        interceptingForest: bool = false,
        factor: enum { I, II, III } = .I,
        Amin: f32 = 100,
        Amax: f32 = 200,
        f: f32 = 50,
        forestDist: f32 = 300,
        l: f32 = 0,
        h: f32 = 0,
        q1: f32 = 0,
        q2: f32 = 0,
        ch: f32 = 1000,
    };
    const WeaponValues = struct {
        weapon_enum_value: weapon.Models = .P88,
        target: enum { Fast, Flyttbart } = .Fast,
        model: weapon.Model = .EHV,
        caliber: ammunition.Caliber = .ptr9_sk_39b,
        v: f32 = 0,
        amm556: ammunition.Calibers.ptr556 = .ptr556_sk_prj_slprj,
        amm762: ammunition.Calibers.ptr762 = .ptr762_sk_10_pprj,
        amm9: ammunition.Calibers.ptr9 = .ptr9_sk_39b,
        amm127: ammunition.Calibers.ptr127 = .ptr127_sk_45_nprj_slnprj,
        support: bool = false,
        c: f32 = 0,
    };
    const Box = struct {
        length: f32 = 100,
        width: f32 = 50,
        h: f32 = 300,
        v: f32 = 300,
    };
    const SST = struct {
        width: f32 = 50,
        hh: f32 = 100,
        hv: f32 = 100,
        vv: f32 = 100,
        vh: f32 = 100,
    };

    renderMode: enum(u8) { Half, SST, Box } = .Half,
    showLines: bool = true,
    showText: bool = false,
    valid: bool = false,

    terrainValues: TerrainValues = TerrainValues{},
    weaponValues: WeaponValues = WeaponValues{},
    config: Config = Config{},
    box: Box = Box{},
    sst: SST = SST{},

    pub fn reset(self: *State) void {
        self.terrainValues = TerrainValues{};
        self.weaponValues = WeaponValues{};
        self.config = Config{};
        self.box = Box{};
        self.sst = SST{};
    }

    pub fn validate(self: *State) bool {
        return Validate.validate(self);
    }

    pub fn update(self: *State) void {
        self.weaponValues.caliber = switch (self.weaponValues.weapon_enum_value) {
            .AK5, .KSP90 => ammunition.Calibers.getCaliber(.{ .ptr556 = self.weaponValues.amm556 }),
            .KSP58 => ammunition.Calibers.getCaliber(.{ .ptr762 = self.weaponValues.amm762 }),
            .KSP88, .AG90 => ammunition.Calibers.getCaliber(.{ .ptr127 = self.weaponValues.amm127 }),
            .P88 => ammunition.Calibers.getCaliber(.{ .ptr9 = self.weaponValues.amm9 }),
        };

        self.terrainValues.l = risk.calculateL(self.*);
        self.terrainValues.h = risk.calculateH(self.*);
        self.terrainValues.q1 = risk.calculateQ1(self.*);
        self.terrainValues.q2 = risk.calculateQ2(self.*);
        self.weaponValues.c = risk.calculateC(self.*);
        self.weaponValues.model = self.weaponValues.weapon_enum_value.getModel(self.weaponValues.support);
        self.weaponValues.v = if (self.weaponValues.target == .Fast) self.weaponValues.model.v_still else self.weaponValues.model.v_moveable;

        self.config.valid = self.validate();
    }

    const Validate = struct {
        const ValidationError = error{
            NoValue,
            NegativeValue,
            InvalidRange,
            Overflow,
            UnknownError,
        };

        pub fn validate(state: *State) bool {
            if (!state.config.show) return false;
            if (!validateZeroValues(state)) return false;
            if (!validateRangeConditions(state)) return false;
            if (!validateNegativeValues(state)) return false;
            if (!validateOverflow(state)) return false;
            switch (state.config.sort) {
                .Box => if (!validateBox(state)) return false,
                .SST => if (!validateSST(state)) return false,
                .Halva => return true,
            }

            return true;
        }

        fn validateBox(state: *State) bool {
            return (state.box.length > 0 and
                state.box.width > 0 and
                state.box.v > 0 and
                state.box.h > 0);
        }

        fn validateSST(state: *State) bool {
            return (state.sst.width > 0 and
                state.sst.hh > 0 and
                state.sst.hv > 0 and
                state.sst.vv > 0 and
                state.sst.vh > 0);
        }

        fn validateZeroValues(state: *State) bool {
            return (state.terrainValues.Amax != 0 and
                state.terrainValues.h != 0 and
                state.terrainValues.l != 0 and
                state.weaponValues.v != 0);
        }

        fn validateRangeConditions(state: *State) bool {
            return (state.terrainValues.Amin < state.terrainValues.Amax and
                state.terrainValues.f < state.terrainValues.Amax and
                state.terrainValues.f < state.terrainValues.Amin and
                state.terrainValues.forestDist < state.terrainValues.h);
        }

        fn validateNegativeValues(state: *State) bool {
            return (state.terrainValues.Amax >= 0 and
                state.terrainValues.Amin >= 0 and
                state.terrainValues.f >= 0 and
                state.terrainValues.l >= 0 and
                state.terrainValues.h >= 0 and
                state.terrainValues.forestDist >= 0);
        }

        fn validateOverflow(state: *State) bool {
            const max = std.math.floatMax(f32);
            return (state.terrainValues.Amax < max and
                state.terrainValues.Amin < max and
                state.terrainValues.f < max and
                state.terrainValues.forestDist < max);
        }
    };
};

pub fn draw(ctx: *Self) void {
    Toolbar.draw(ctx);
}

const zgui = @import("zgui");
const Color = @import("gui/Color.zig");
const Toolbar = struct {
    pub fn draw(_: *Self) void {
        zgui.pushStyleColor4f(.{ .idx = .header, .c = Color.dark_grey });
        zgui.pushStyleColor4f(.{ .idx = .border, .c = Color.grey });
        zgui.pushStyleVar1f(.{ .idx = .popup_rounding, .v = 2 });
        zgui.pushStyleVar1f(.{ .idx = .child_rounding, .v = 2 });

        if (zgui.beginMainMenuBar()) {
            zgui.popStyleColor(.{ .count = 1 });
            if (zgui.beginMenu("File", true)) {
                if (zgui.menuItem("Import", .{})) {
                    // ctx.window.modal = .create(.importModal);
                }

                if (zgui.menuItem("Export", .{})) {
                    // ctx.window.modal = .create(.exportModal);
                }

                zgui.separator();
                if (zgui.menuItem("Quit", .{})) {
                    // ctx.window.deinit();
                }
                zgui.endMenu();
            }

            if (zgui.beginMenu("Edit", true)) {
                zgui.endMenu();
            }

            if (zgui.beginMenu("Window", true)) {
                // if (zgui.menuItem("Riskprofil", .{})) ctx.window.frames.riskEditorFrame.open = !ctx.window.frames.riskEditorFrame.open;
                zgui.endMenu();
            }

            if (zgui.beginMenu("Tools", true)) {
                if (zgui.menuItem("Settings", .{})) {
                    // ctx.window.modal = .create(.settingsModal);
                }

                zgui.endMenu();
            }
            // zgui.sameLine(.{ .offset_from_start_x = @as(f32, @floatFromInt(rl.getScreenWidth())) - 100 });
            zgui.pushStyleVar1f(.{ .idx = .frame_rounding, .v = 0 });
            zgui.pushStyleColor4f(.{ .idx = .text, .c = Color.white });

            zgui.pushStyleColor4f(.{ .idx = .button, .c = Color.dark_grey });
            zgui.pushStyleColor4f(.{ .idx = .button_hovered, .c = Color.grey });
            // if (zgui.button("_", .{})) ctx.window.deinit();
            // if (zgui.button("[]", .{})) ctx.window.deinit();
            // if (zgui.button("X", .{})) ctx.window.deinit();
            zgui.popStyleColor(.{ .count = 2 });

            zgui.popStyleVar(.{ .count = 1 });
            zgui.popStyleColor(.{ .count = 1 });
            zgui.endMainMenuBar();
        } else {
            zgui.popStyleColor(.{ .count = 1 });
        }
        zgui.popStyleColor(.{ .count = 1 });
        zgui.popStyleVar(.{ .count = 2 });
    }
};
