const std = @import("std");
const risk = @import("../risk/state.zig");
const rl = @import("raylib");
const rg = @import("raygui");
const state = @import("state.zig");

pub var gui: state.guiState = undefined;

pub const Menu = struct {
    pub const barWidth = 100;
    pub const barHeight = 30;

    page: i8, //TODO: måste ha en getPage istället så att denna inte kan ändras hur som, sidan måste ändras grafiskt om denna ändras
    origin: rl.Vector2,

    pub fn init(self: *Menu) !void {
        self.origin = rl.Vector2{
            .x = 0,
            .y = 1,
        };
        self.page = 1;
    }

    pub fn setPage(self: *Menu, value: i8) void {
        if (value != self.page) gui.reset();
        self.page = value;
    }

    pub fn drawMenu(self: *Menu, allocator: std.mem.Allocator, riskProfile: *risk.RiskArea) !void {
        //Pane
        rl.drawRectangle(@as(i32, @intFromFloat(self.origin.x)), @as(i32, @intFromFloat(self.origin.y)), (barWidth * 2), rl.getScreenHeight(), rl.Color.white);
        rl.drawRectangle(@as(i32, @intFromFloat(self.origin.x)) + (barWidth * 2), @as(i32, @intFromFloat(self.origin.y)), 1, rl.getScreenWidth(), rl.Color.black);
        rl.drawRectangle(@as(i32, @intFromFloat(self.origin.x)), @as(i32, @intFromFloat(self.origin.y)) - 1, (barWidth * 2), 1, rl.Color.black);

        // Switch Page
        switch (self.page) {
            1 => self.drawMenuSST(riskProfile),
            2 => self.drawMenuBOX(),
            else => return,
        }

        // Show calculations
        _ = rg.guiLabel(.{ .x = 10, .y = 740 - 10 - 15 - 30, .width = 180, .height = 10 }, "Visa beräknade värden");
        _ = rg.guiCheckBox(.{ .x = 10, .y = 740 - 10 - 30, .width = 30, .height = 30 }, "", &gui.showInfoPanel.value);

        // Reset button
        if (rg.guiButton(.{ .x = 10, .y = 740, .width = 180, .height = 30 }, "Nollställ") == 1) gui.reset();

        // Switch page buttons
        if (rg.guiLabelButton(.{ .x = 0 + 40, .y = 10, .width = 10, .height = 10 }, "SST") == 1) self.setPage(1);
        if (rg.guiLabelButton(.{ .x = 0 + barWidth + 40, .y = 10, .width = 10, .height = 10 }, "BOX") == 1) self.setPage(2);

        // Status bar
        {
            const mouse_pos = rl.getMousePosition();
            const string = try std.fmt.allocPrintZ(allocator, "ZRAC v0.0.1 | x: {d} y: {d}", .{ mouse_pos.x, mouse_pos.y });

            defer allocator.free(string);

            _ = rg.guiStatusBar(.{ .x = 0, .y = @as(f32, @floatFromInt(rl.getScreenHeight() - 20)), .width = @as(f32, @floatFromInt(rl.getScreenWidth())), .height = 20 }, string);
        }
    }

    pub fn drawInfoPanel(self: *Menu, riskProfile: risk.RiskArea, allocator: std.mem.Allocator) !void {
        _ = self;

        const infoPanelXOffset: i32 = 10;
        const infoPanelWidth: i32 = 100;
        const infoPanelHeight: i32 = 150;

        _ = rg.guiPanel(.{ .x = @as(f32, @floatFromInt(rl.getScreenWidth())) - infoPanelWidth - infoPanelXOffset, .y = 10, .width = infoPanelWidth, .height = infoPanelHeight }, "Values");

        const c_string = try std.fmt.allocPrintZ(allocator, "c:  {d}", .{riskProfile.c});
        defer allocator.free(c_string);
        _ = rg.guiLabel(.{ .x = @as(f32, @floatFromInt(rl.getScreenWidth())) - infoPanelWidth - infoPanelXOffset + 10, .y = 10 + 30, .width = 180, .height = 10 }, c_string);

        const l_string = try std.fmt.allocPrintZ(allocator, "l:  {d}", .{riskProfile.l});
        defer allocator.free(l_string);
        _ = rg.guiLabel(.{ .x = @as(f32, @floatFromInt(rl.getScreenWidth())) - infoPanelWidth - infoPanelXOffset + 10, .y = 10 + 30 + 15, .width = 180, .height = 10 }, l_string);

        const h_string = try std.fmt.allocPrintZ(allocator, "h:  {d}", .{riskProfile.h});
        defer allocator.free(h_string);
        _ = rg.guiLabel(.{ .x = @as(f32, @floatFromInt(rl.getScreenWidth())) - infoPanelWidth - infoPanelXOffset + 10, .y = 10 + 30 + 15 + 15, .width = 180, .height = 10 }, h_string);

        const q1_string = try std.fmt.allocPrintZ(allocator, "q1: {d}", .{riskProfile.q1});
        defer allocator.free(q1_string);
        _ = rg.guiLabel(.{ .x = @as(f32, @floatFromInt(rl.getScreenWidth())) - infoPanelWidth - infoPanelXOffset + 10, .y = 10 + 30 + 15 + 15 + 15, .width = 180, .height = 10 }, q1_string);

        const q2_string = try std.fmt.allocPrintZ(allocator, "q2: {d}", .{riskProfile.q2});
        defer allocator.free(q2_string);
        _ = rg.guiLabel(.{ .x = @as(f32, @floatFromInt(rl.getScreenWidth())) - infoPanelWidth - infoPanelXOffset + 10, .y = 10 + 30 + 15 + 15 + 15 + 15, .width = 180, .height = 10 }, q2_string);
    }

    pub fn drawMenuSST(self: *Menu, riskProfile: *risk.RiskArea) void {
        _ = riskProfile;
        // Menu Bar
        rl.drawRectangle(@as(i32, @intFromFloat(self.origin.x)), @as(i32, @intFromFloat(self.origin.y)), barWidth + 1, barHeight, rl.Color.black);
        rl.drawRectangle(@as(i32, @intFromFloat(self.origin.x)), @as(i32, @intFromFloat(self.origin.y)), barWidth, barHeight, rl.Color.white);

        rl.drawRectangle(@as(i32, @intFromFloat(self.origin.x)) + barWidth - 1, @as(i32, @intFromFloat(self.origin.y)), barWidth + 1, barHeight + 1, rl.Color.black);
        rl.drawRectangle(@as(i32, @intFromFloat(self.origin.x)) + barWidth, @as(i32, @intFromFloat(self.origin.y)), barWidth, barHeight, rl.Color.light_gray);

        // Input fields
        _ = rg.guiLabel(.{ .x = 160, .y = barHeight + 10, .width = 30, .height = 10 }, "Visa");
        _ = rg.guiCheckBox(.{ .x = 160, .y = barHeight + 25, .width = 30, .height = 30 }, "", &gui.draw.value);
        // _ = rg.guiCheckBox(.{ .x = 160, .y = barHeight + 25, .width = 30, .height = 30 }, "", &riskProfile.show);

        _ = rg.guiLabel(.{ .x = 10, .y = barHeight + 10, .width = 180, .height = 10 }, "Riskfaktor");
        _ = rg.guiComboBox(.{ .x = 10, .y = barHeight + 25, .width = 60, .height = 30 }, "I;II;III", &gui.riskFactor.value);
        // _ = rg.guiComboBox(.{ .x = 10, .y = barHeight + 25, .width = 60, .height = 30 }, "I;II;III", &riskProfile.factor);

        _ = rg.guiLabel(.{ .x = 10, .y = barHeight + 65, .width = 180, .height = 10 }, "Amin");
        if (rg.guiTextBox(.{ .x = 10, .y = barHeight + 80, .width = 180, .height = 30 }, @as([*:0]u8, @ptrCast(&gui.Amin.value)), 63, gui.Amin.editMode) != 0) gui.Amin.editMode = !gui.Amin.editMode;

        _ = rg.guiLabel(.{ .x = 10, .y = barHeight + 120, .width = 180, .height = 10 }, "Amax");
        if (rg.guiTextBox(.{ .x = 10, .y = barHeight + 135, .width = 180, .height = 30 }, @as([*:0]u8, @ptrCast(&gui.Amax.value)), 63, gui.Amax.editMode) != 0) gui.Amax.editMode = !gui.Amax.editMode;

        _ = rg.guiLabel(.{ .x = 10, .y = barHeight + 175, .width = 180, .height = 10 }, "f");
        if (rg.guiTextBox(.{ .x = 10, .y = barHeight + 190, .width = 180, .height = 30 }, @as([*:0]u8, @ptrCast(&gui.f.value)), 63, gui.f.editMode) != 0) gui.f.editMode = !gui.f.editMode;

        _ = rg.guiLabel(.{ .x = 10, .y = barHeight + 230, .width = 30, .height = 10 }, "Uppfång");
        _ = rg.guiCheckBox(.{ .x = 10, .y = barHeight + 245, .width = 30, .height = 30 }, "", &gui.interceptingForest.value);
        // _ = rg.guiCheckBox(.{ .x = 10, .y = barHeight + 245, .width = 30, .height = 30 }, "", &riskProfile.inForest);

        _ = rg.guiLabel(.{ .x = 50, .y = barHeight + 230, .width = 100, .height = 10 }, "Skogsavstånd");
        if (rg.guiTextBox(.{ .x = 50, .y = barHeight + 245, .width = 140, .height = 30 }, @as([*:0]u8, @ptrCast(&gui.forestDist.value)), 63, gui.forestDist.editMode) != 0) gui.forestDist.editMode = !gui.forestDist.editMode;

        _ = rg.guiLabel(.{ .x = 10, .y = barHeight + 340, .width = 30, .height = 10 }, "Fast");
        _ = rg.guiCheckBox(.{ .x = 10, .y = barHeight + 355, .width = 30, .height = 30 }, "", &gui.targetType.value);
        // _ = rg.guiCheckBox(.{ .x = 10, .y = barHeight + 355, .width = 30, .height = 30 }, "", &riskProfile.fixedTarget);

        _ = rg.guiLabel(.{ .x = 50, .y = barHeight + 340, .width = 140, .height = 10 }, "Ammunitionstyp");
        if (rg.guiDropdownBox(.{ .x = 50, .y = barHeight + 355, .width = 140, .height = 30 }, risk.amm.names, &gui.ammunitionType.value, gui.ammunitionType.editMode) != 0) gui.ammunitionType.editMode = !gui.ammunitionType.editMode;

        _ = rg.guiLabel(.{ .x = 10, .y = barHeight + 285, .width = 180, .height = 10 }, "Vapentyp");
        if (rg.guiDropdownBox(.{ .x = 10, .y = barHeight + 300, .width = 180, .height = 30 }, risk.weapon.names, &gui.weaponType.value, gui.weaponType.editMode) != 0) gui.weaponType.editMode = !gui.weaponType.editMode;
    }

    pub fn drawMenuBOX(self: *Menu) void {
        // Menu Bar
        rl.drawRectangle(@as(i32, @intFromFloat(self.origin.x)) - 1, @as(i32, @intFromFloat(self.origin.y)), barWidth + 1, barHeight + 1, rl.Color.black);
        rl.drawRectangle(@as(i32, @intFromFloat(self.origin.x)), @as(i32, @intFromFloat(self.origin.y)), barWidth, barHeight, rl.Color.light_gray);

        rl.drawRectangle(@as(i32, @intFromFloat(self.origin.x)) + barWidth - 1, @as(i32, @intFromFloat(self.origin.y)), barWidth + 1, barHeight, rl.Color.black);
        rl.drawRectangle(@as(i32, @intFromFloat(self.origin.x)) + barWidth, @as(i32, @intFromFloat(self.origin.y)), barWidth, barHeight, rl.Color.white);

        _ = rg.guiLabel(.{ .x = 10, .y = barHeight + 10, .width = 30, .height = 10 }, "TBA");

        // Input fields
    }
};
