const std = @import("std");
const render = @import("render.zig");

pub const guiState = struct {
    const textBoxState = struct {
        value: [64]u8,
        editMode: bool,
    };

    const checkBoxState = struct {
        value: bool,
    };

    const comboBoxState = struct {
        value: i32,
    };

    const dropdownBoxState = struct {
        value: i32,
        editMode: bool,
    };

    Amin: textBoxState,
    Amax: textBoxState,
    f: textBoxState,
    forestDist: textBoxState,
    draw: checkBoxState,
    interceptingForest: checkBoxState,
    riskFactor: comboBoxState,
    ammunitionType: dropdownBoxState,
    weaponType: dropdownBoxState,
    targetType: checkBoxState,
    menu: render.Menu,
    showInfoPanel: checkBoxState,

    pub fn init(self: *guiState) !void {
        self.reset();

        try self.menu.init();
        render.gui.draw.value = true;
    }

    pub fn reset(self: *guiState) void {
        self.Amin = .{ .editMode = false, .value = std.mem.zeroes([64]u8) };
        self.Amax = .{ .editMode = false, .value = std.mem.zeroes([64]u8) };
        self.f = .{ .editMode = false, .value = std.mem.zeroes([64]u8) };
        self.forestDist = .{ .editMode = false, .value = std.mem.zeroes([64]u8) };
        self.draw = .{ .value = true };
        self.interceptingForest = .{ .value = false };
        self.riskFactor = .{ .value = 0 };
        self.ammunitionType = .{ .editMode = false, .value = 0 };
        self.weaponType = .{ .editMode = false, .value = 0 };
        self.targetType = .{ .value = false };
    }
};
