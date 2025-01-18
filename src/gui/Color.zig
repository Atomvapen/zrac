const zgui = @import("zgui");

pub const Color = struct {
    pub const white = [4]f32{ 1.0, 1.0, 1.0, 1.0 };
    pub const black = [4]f32{ 0.0, 0.0, 0.0, 0.0 };
    pub const dark_grey = [4]f32{ 0.094, 0.094, 0.106, 1.0 };
    pub const grey = [4]f32{ 0.184, 0.184, 0.192, 1.0 };
};

pub fn setDefaultStyle() void {}
