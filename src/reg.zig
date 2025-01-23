pub const math = struct {
    pub const geometry = @import("math/geo.zig");
    pub const risk = @import("math/risk.zig");
    pub const trig = @import("math/trig.zig");
};

pub const data = struct {
    pub const State = @import("data/State.zig");
    pub const validation = @import("data/validation.zig");
    pub const ammunition = @import("data/ammunition.zig");
    pub const weapon = @import("data/weapon.zig");
};

pub const io = struct {
    pub const sync = @import("io/sync.zig");
    pub const json = @import("io/json.zig");
};

pub const gui = struct {
    pub const renderer = @import("gui/renderer.zig");
    pub const camera = @import("gui/camera.zig");
    pub const DrawBuffer = @import("gui/drawBuffer.zig");
    pub const plane = @import("gui/plane.zig");
    pub const Color = @import("gui/Color.zig");
    pub const Modals = @import("gui/modals.zig").Modal;
    pub const Frames = @import("gui/frames.zig");
};
