const vec = @import("vector.zig");
const trig = @import("trig.zig");
const Context = @import("../Context.zig");

const Vec2f = vec.Vec2f;

pub const Line = struct {
    start: Vec2f,
    end: Vec2f,

    pub fn draw(self: *Line, ctx: *Context) void {
        ctx.grid.addLine(ctx, self.start, self.end, 0xFF0000FF, 2);
    }
};

pub const SemiCircle = struct {
    center: Vec2f,
    start_angle: f32,
    end_angle: f32,
    radius: f32,

    pub fn draw(self: *const SemiCircle, ctx: *Context) void {
        ctx.grid.addCircleSector(ctx, self.center, self.radius, 0xFF0000FF, self.start_angle, self.end_angle, 2);
    }
};

pub const Point = struct {
    pos: Vec2f,
};
