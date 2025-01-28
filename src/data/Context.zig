const Self = @This();

const std = @import("std");
const reg = @import("reg");
const DrawBuffer = reg.gui.DrawBuffer;
const Modal = reg.gui.Modal;
const Frame = reg.gui.Frame;
const State = reg.data.State;
const Window = reg.gui.Window;

allocator: std.mem.Allocator,
state: State,
draw_buffer: DrawBuffer,
window: Window,

pub fn create(allocator: std.mem.Allocator) Self {
    return Self{
        .allocator = allocator,
        .state = State{},
        .draw_buffer = DrawBuffer.init(allocator),
        .window = Window{
            .config = .{},
            .frames = .{
                .riskEditorFrame = Frame.RiskEditorFrame{ .open = true },
            },
            .modal = null,
        },
    };
}

pub fn destroy(self: *Self) void {
    self.allocator = undefined;
    self.window.modal = null;
    self.draw_buffer.clearAndFree();
    self.draw_buffer.deinit();
}

pub fn update(self: *Self) void {
    // TODO: Only update on change
    self.state.update();
}
