const Self = @This();

const std = @import("std");
const reg = @import("reg");
const DrawBuffer = reg.gui.DrawBuffer;
const Modal = reg.gui.Modal;
const Frame = reg.gui.Frames;
const State = reg.data.State;
const Window = reg.gui.renderer.Window;

state: State,
draw_buffer: DrawBuffer,
window: Window,
modal: ?Modal,
frames: struct {
    riskEditorFrame: Frame.RiskEditorFrame = undefined,
},

pub fn create(allocator: std.mem.Allocator) Self {
    defer std.debug.print("INFO: Context created successfully\n", .{});
    errdefer std.debug.print("INFO: Context creation failed\n", .{});

    return Self{
        .state = State{},
        .draw_buffer = DrawBuffer.init(allocator),
        .window = Window{ .config = .{} },
        .modal = null,
        .frames = .{
            .riskEditorFrame = Frame.RiskEditorFrame{ .open = true },
        },
    };
}

pub fn destroy(self: *Self) void {
    defer std.debug.print("INFO: Context destroyed successfully\n", .{});
    errdefer std.debug.print("INFO: Context destruction failed\n", .{});

    self.modal = null;
    self.draw_buffer.clearAndFree();
    self.draw_buffer.deinit();
}

pub fn update(self: *Self) void {
    self.state.update();
}
