const vec = @import("vector.zig");
const Context = @import("../Context.zig");

const Vec2f = vec.Vec2f;

// pub fn Line2(comptime T: type) type {
//     return struct {
//         const Self = @This();

//         start: @Vector(2, T),
//         end: @Vector(2, T),
//         color: u32,

//         pub fn init(color: u32, start: @Vector(2, T), end: @Vector(2, T)) Self {
//             return Self{ .color = color, .start = start, .end = end };
//         }

//         pub fn draw(self: *Self, ctx: *Context) void {
//             ctx.grid.addLine(ctx, self.start, self.end, self.color, 2);
//         }
//     };
// }

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
