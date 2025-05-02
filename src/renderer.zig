const zgui = @import("zgui");
const zgpu = @import("zgpu");
const zglfw = @import("zglfw");
const std = @import("std");
const Context = @import("Context.zig");

pub fn begin(ctx: *Context) void {
    zglfw.pollEvents();

    zgui.backend.newFrame(
        ctx.gctx.swapchain_descriptor.width,
        ctx.gctx.swapchain_descriptor.height,
    );
}

pub fn update(ctx: *Context) void {
    ctx.state.update();
    Context.Window.Drag.handle(ctx.window);
    if (ctx.modal == null) ctx.camera.update(ctx);

    ctx.grid.draw(ctx, 1);
    // ctx.grid.addLine(ctx, .{ 10.0, 10.0 }, .{ 50.0, 50.0 }, 0xFFFF0000, 2);
    // ctx.grid.addRect(ctx, .{ 10.0, 10.0 }, .{ 50.0, 50.0 }, 0xFF00FF00, 5.0, 2.0);
    // ctx.grid.addCircle(ctx, .{ 20.0, 20.0 }, 15.0, 0xFF0000FF);
    // ctx.grid.addCircleSector(ctx, .{ 100.0, 100.0 }, 50.0, 0xFF00FF00, 0.0, 3.14159, 2);
    // ctx.grid.addCircleSector(ctx, .{ 100.0, 100.0 }, 50.0, 0xFFFF0000, 3.14159, 6.28319, 2);

    if (ctx.state.config.valid) switch (ctx.state.config.sort) {
        .Halva => drawHalf(ctx),
        // .SST => drawSST(ctx),
        // .Box => drawBox(ctx),
        else => {},
    };

    ctx.frames.show(ctx);
    if (ctx.modal) |*modal| {
        if (!modal.open) ctx.modal = null;
        modal.show();
    }

    Context.Window.draw(ctx);
    ctx.contextMenu.draw(ctx);
}

pub fn draw(ctx: *Context) void {
    const gctx: *zgpu.GraphicsContext = ctx.gctx;

    const swapchain_texv: zgpu.wgpu.TextureView = gctx.swapchain.getCurrentTextureView();
    defer swapchain_texv.release();

    const commands: zgpu.wgpu.CommandBuffer = commands: {
        const encoder: zgpu.wgpu.CommandEncoder = gctx.device.createCommandEncoder(null);
        defer encoder.release();

        {
            const pass: zgpu.wgpu.RenderPassEncoder = zgpu.beginRenderPassSimple(
                encoder,
                .load,
                swapchain_texv,
                null,
                null,
                null,
            );
            defer zgpu.endReleasePass(pass);
            zgui.backend.draw(pass);
        }

        break :commands encoder.finish(null);
    };
    defer commands.release();

    gctx.submit(&.{commands});
    _ = gctx.present();
}

const vec = @import("math/vector.zig");
const Vec2f = vec.Vec2f;
const trig = @import("math/trig.zig");

const Line = struct {
    start: Vec2f,
    end: Vec2f,
};

const SemiCircle = struct {
    center: Vec2f,
    start_angle: f32,
    end_angle: f32,
    radius: f32,
};

const Point = struct {
    pos: Vec2f,
};

pub fn drawHalf(ctx: *Context) void {
    const origin: Vec2f = .{ 0, 0 };
    const angle: f32 = 0;
    const millsToRad = std.math.tau / 6400.0;

    // h
    var h: Line = .{
        .start = .{
            origin[0],
            origin[1],
        },
        .end = .{
            origin[0],
            origin[1] - ctx.state.terrainValues.h,
        },
    };
    h.end = vec.rotate2D(h.end, angle);
    ctx.grid.addLine(ctx, h.start, h.end, 0xFF00FF00, 2);

    // Amin
    var Amin: Point = .{ .pos = .{
        origin[0],
        origin[1] - ctx.state.terrainValues.Amin,
    } };
    Amin.pos = vec.rotate2D(Amin.pos, angle * millsToRad);

    // v
    var v: Line = .{
        .start = .{
            origin[0],
            origin[1],
        },
        .end = .{
            origin[0],
            origin[1] - ctx.state.terrainValues.h,
        },
    };
    v.end = vec.rotate2D(v.end, (angle + ctx.state.weaponValues.v) * millsToRad);
    ctx.grid.addLine(ctx, v.start, v.end, 0xFF00FF00, 2);

    // Amin
    var f: Point = .{ .pos = .{
        origin[0],
        Amin.pos[1] + ctx.state.terrainValues.f,
    } };
    f.pos = vec.rotate2D(f.pos, angle * millsToRad);

    //hv
    const hv: SemiCircle = .{
        .center = origin,
        .start_angle = (-1600.0 + angle) * millsToRad,
        .end_angle = (-1600.0 + angle + ctx.state.weaponValues.v) * millsToRad,
        .radius = ctx.state.terrainValues.h,
    };
    ctx.grid.addCircleSector(ctx, hv.center, hv.radius, 0xFFFF0000, hv.start_angle, hv.end_angle, 2);

    //c
    var c: Line = blk: {
        const val: [2]Vec2f = trig.getParallelLine(v.start, v.end, ctx.state.weaponValues.c);
        break :blk .{ .start = val[0], .end = val[1] };
    };

    // ch
    var ch: Line = .{
        .start = .{
            v.end[0],
            v.end[1],
        },
        .end = .{
            v.end[0] - 100.0,
            v.end[1] - 1000.0,
        },
    };
    ch.end = vec.rotate2D(ch.end, (angle + 3200.0 - ctx.state.terrainValues.ch) * millsToRad);
    ch.end = if (trig.getIntersectionPoint(ch.start, ch.end, c.start, c.end)) |val| val else c.end;
    ctx.grid.addLine(ctx, ch.start, ch.end, 0xFF00FF00, 2);

    c.end = if (trig.getIntersectionPoint(c.start, c.end, ch.start, ch.end)) |val| val else c.end;
    ctx.grid.addLine(ctx, c.start, c.end, 0xFF00FF00, 2);

    // forestMin
    var forestMin: Point = .{ .pos = .{
        origin[0],
        Amin.pos[1] - ctx.state.terrainValues.forestDist,
    } };
    forestMin.pos = vec.rotate2D(forestMin.pos, angle * millsToRad);

    // q1
    var q1: Line = .{
        .start = .{
            trig.triangleOppositeLeg(ctx.state.terrainValues.Amin - ctx.state.terrainValues.f, angle + ctx.state.weaponValues.v) + origin[0],
            origin[1] - ctx.state.terrainValues.Amin + ctx.state.terrainValues.f,
        },
        .end = .{
            v.end[0],
            v.end[1],
        },
    };
    q1.end = vec.rotate2D(q1.end, ctx.state.terrainValues.q1 * millsToRad);
    // q1.addText("q1", 15, 0, 40, rl.Color.black, q1.end, ctx.state.config.showText);

    // q2
    var q2: Line = .{
        .start = .{
            trig.triangleOppositeLeg(ctx.state.terrainValues.forestDist, angle + ctx.state.weaponValues.v) + origin[0],
            origin[1] - ctx.state.terrainValues.forestDist,
        },
        .end = .{
            v.end[0],
            v.end[1],
        },
    };
    q2.end = vec.rotate2D(q2.end, ctx.state.terrainValues.q2 * millsToRad);
    // q2.addText("q2", 25, 0, 40, rl.Color.black, q2.end, ctx.state.config.showText);
}
