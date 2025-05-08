const zgui = @import("zgui");
const zgpu = @import("zgpu");
const zglfw = @import("zglfw");
const std = @import("std");
const Context = @import("Context.zig");
const vec = @import("math/vector.zig");
const geo = @import("math/geo.zig");
const trig = @import("math/trig.zig");

const Vec2f = vec.Vec2f;
const Line = geo.Line;
const SemiCircle = geo.SemiCircle;
const Point = geo.Point;

pub fn begin(ctx: *Context) void {
    zglfw.pollEvents();

    zgui.backend.newFrame(
        ctx.gctx.swapchain_descriptor.width,
        ctx.gctx.swapchain_descriptor.height,
    );
}

pub fn update(ctx: *Context) void {
    const draw_list: zgui.DrawList = zgui.getBackgroundDrawList();
    const screen_size: [2]c_int = ctx.window.getSize();

    draw_list.addRectFilled(.{
        .pmin = .{ 0.0, 0.0 },
        .pmax = .{ @floatFromInt(screen_size[0]), @floatFromInt(screen_size[1]) },
        .col = 0xFFFFFFFF,
    });

    ctx.state.update();
    Context.Window.Drag.handle(ctx.window);
    if (ctx.modal == null) ctx.camera.update(ctx);

    ctx.grid.draw(ctx, 1);

    if (ctx.state.config.valid) switch (ctx.state.config.sort) {
        .Halva => drawHalf(ctx),
        .SST => drawSST(ctx),
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

pub fn drawHalf(ctx: *Context) void {
    const origin: Vec2f = .{ 0, 0 };
    const angle: f32 = 0;
    const millsToRad: f32 = std.math.tau / 6400.0;

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

    //c
    var c: Line = blk: {
        const val: [2]Vec2f = vec.getParallelVector2(v.start, v.end, ctx.state.weaponValues.c);
        break :blk .{ .start = val[0], .end = val[1] };
    };

    // ch
    var ch: Line = .{
        .start = .{
            v.end[0],
            v.end[1],
        },
        .end = .{
            v.end[0] - 1000.0,
            v.end[1] - 10000000.0,
        },
    };
    ch.end = vec.rotate2D(ch.end, (angle + 3200.0 - ctx.state.terrainValues.ch) * millsToRad);
    ch.end = if (vec.getVector2Intersection(ch.start, ch.end, c.start, c.end)) |val| val else c.end;

    c.end = if (vec.getVector2Intersection(c.start, c.end, ch.start, ch.end)) |val| val else c.end;

    // forestMin
    var forestMin: Point = .{
        .pos = .{
            origin[0],
            Amin.pos[1] - ctx.state.terrainValues.forestDist,
        },
    };
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

    // q
    var q: Line = if (ctx.state.terrainValues.forestDist > 0) q2 else q1;
    q.end = if (vec.getVector2Intersection(q.start, q.end, c.start, c.end)) |val| val else q.end;
    q.start = if (vec.getVector2Intersection(q.start, q.end, v.start, v.end)) |val| val else q.start;

    v.end = if (vec.getVector2Intersection(v.start, v.end, q.start, q.end)) |val| val else v.end;
    c.end = if (vec.getVector2Intersection(c.start, c.end, ch.start, ch.end)) |val| val else c.end;
    c.start = if (vec.getVector2Intersection(c.start, c.end, q.start, q.end)) |val| val else c.start;

    h.draw(ctx);
    v.draw(ctx);
    hv.draw(ctx);
    ch.draw(ctx);
    c.draw(ctx);
    q.draw(ctx);
}

pub fn drawSST(ctx: *Context) void {
    const millsToRad = std.math.tau / 6400.0;
    const origin: Vec2f = .{ 0, 0 };
    const origin_v: Vec2f = .{ origin[0] - (ctx.state.sst.width / 2), origin[1] };
    // const origin_h: Vec2f = .{ origin[0] + (ctx.state.sst.width / 2), origin[1] };
    const angle = ctx.state.sst.hh;

    // sst
    var sst: Line = .{ .start = .{
        origin[0] - (ctx.state.sst.width / 2),
        origin[1],
    }, .end = .{
        origin[0] + (ctx.state.sst.width / 2),
        origin[1],
    } };

    // // h
    // var h_h: Line = .{
    //     .start = .{
    //         origin_h[0],
    //         origin_h[1],
    //     },
    //     .end = .{
    //         origin_h[0],
    //         origin_h[1] - ctx.state.terrainValues.h,
    //     },
    // };
    // h_h.end = vec.rotate2D(h_h.end, angle * millsToRad);

    // // Amin
    // var h_Amin: Point = .{ .pos = .{
    //     origin_h[0],
    //     origin_h[1] - ctx.state.terrainValues.Amin,
    // } };
    // h_Amin.pos = vec.rotate2D(h_Amin.pos, angle * millsToRad);

    // // v
    // var h_v: Line = .{
    //     .start = .{
    //         origin_h[0],
    //         origin_h[1],
    //     },
    //     .end = .{
    //         origin_h[0],
    //         origin_h[1] - ctx.state.terrainValues.h,
    //     },
    // };
    // h_v.end = vec.rotate2D(h_v.end, (angle + ctx.state.weaponValues.v) * millsToRad);

    // // Amin
    // var h_f: Point = .{ .pos = .{
    //     origin_h[0],
    //     h_Amin.pos[1] + ctx.state.terrainValues.f,
    // } };
    // h_f.pos = vec.rotate2D(h_f.pos, angle * millsToRad);

    // //hv
    // const h_hv: SemiCircle = .{
    //     .center = origin_h,
    //     .start_angle = (-1600.0 + angle) * millsToRad,
    //     .end_angle = (-1600.0 + angle + ctx.state.weaponValues.v) * millsToRad,
    //     .radius = ctx.state.terrainValues.h,
    // };

    // //c
    // var h_c: Line = blk: {
    //     const val: [2]Vec2f = vec.getParallelVector2(h_v.start, h_v.end, ctx.state.weaponValues.c);
    //     break :blk .{ .start = val[0], .end = val[1] };
    // };

    // // ch
    // var h_ch: Line = .{
    //     .start = .{
    //         h_v.end[0],
    //         h_v.end[1],
    //     },
    //     .end = .{
    //         h_v.end[0] - 1000.0,
    //         h_v.end[1] - 10000000.0,
    //     },
    // };
    // h_ch.end = vec.rotate2D(h_ch.end, (angle + 3200.0 - ctx.state.terrainValues.ch) * millsToRad);
    // h_ch.end = if (vec.getVector2Intersection(h_ch.start, h_ch.end, h_c.start, h_c.end)) |val| val else h_c.end;

    // h_c.end = if (vec.getVector2Intersection(h_c.start, h_c.end, h_ch.start, h_ch.end)) |val| val else h_c.end;

    // // forestMin
    // var h_forestMin: Point = .{
    //     .pos = .{
    //         origin_h[0],
    //         h_Amin.pos[1] - ctx.state.terrainValues.forestDist,
    //     },
    // };
    // h_forestMin.pos = vec.rotate2D(h_forestMin.pos, angle * millsToRad);

    // // q1
    // var h_q1: Line = .{
    //     .start = .{
    //         trig.triangleOppositeLeg(ctx.state.terrainValues.Amin - ctx.state.terrainValues.f, angle + ctx.state.weaponValues.v) + origin_h[0],
    //         origin_h[1] - ctx.state.terrainValues.Amin + ctx.state.terrainValues.f,
    //     },
    //     .end = .{
    //         h_v.end[0],
    //         h_v.end[1],
    //     },
    // };
    // h_q1.end = vec.rotate2D(h_q1.end, ctx.state.terrainValues.q1 * millsToRad);
    // // q1.addText("q1", 15, 0, 40, rl.Color.black, q1.end, ctx.state.config.showText);

    // // q2
    // var h_q2: Line = .{
    //     .start = .{
    //         trig.triangleOppositeLeg(ctx.state.terrainValues.forestDist, angle + ctx.state.weaponValues.v) + origin_h[0],
    //         origin_h[1] - ctx.state.terrainValues.forestDist,
    //     },
    //     .end = .{
    //         h_v.end[0],
    //         h_v.end[1],
    //     },
    // };
    // h_q2.end = vec.rotate2D(h_q2.end, ctx.state.terrainValues.q2 * millsToRad);
    // // // q2.addText("q2", 25, 0, 40, rl.Color.black, q2.end, ctx.state.config.showText);

    // // q
    // var h_q: Line = if (ctx.state.terrainValues.forestDist > 0) h_q2 else h_q1;
    // h_q.end = if (vec.getVector2Intersection(h_q.start, h_q.end, h_c.start, h_c.end)) |val| val else h_q.end;
    // h_q.start = if (vec.getVector2Intersection(h_q.start, h_q.end, h_v.start, h_v.end)) |val| val else h_q.start;

    // h_v.end = if (vec.getVector2Intersection(h_v.start, h_v.end, h_q.start, h_q.end)) |val| val else h_v.end;
    // h_c.end = if (vec.getVector2Intersection(h_c.start, h_c.end, h_ch.start, h_ch.end)) |val| val else h_c.end;
    // h_c.start = if (vec.getVector2Intersection(h_c.start, h_c.end, h_q.start, h_q.end)) |val| val else h_c.start;

    // h
    var v_h: Line = .{
        .start = .{
            origin_v[0],
            origin_v[1],
        },
        .end = .{
            origin_v[0],
            origin_v[1] - ctx.state.terrainValues.h,
        },
    };
    v_h.end = vec.rotate2D(v_h.end, -angle * millsToRad);

    // Amin
    var v_Amin: Point = .{ .pos = .{
        origin_v[0],
        origin_v[1] - ctx.state.terrainValues.Amin,
    } };
    v_Amin.pos = vec.rotate2D(v_Amin.pos, angle * millsToRad);

    // v
    var v_v: Line = .{
        .start = .{
            origin_v[0],
            origin_v[1],
        },
        .end = .{
            origin_v[0],
            origin_v[1] - ctx.state.terrainValues.h,
        },
    };
    v_v.end = vec.rotate2D(v_v.end, (-angle - ctx.state.weaponValues.v) * millsToRad);

    // Amin
    var v_f: Point = .{ .pos = .{
        origin_v[0],
        v_Amin.pos[1] + ctx.state.terrainValues.f,
    } };
    v_f.pos = vec.rotate2D(v_f.pos, angle * millsToRad);

    //hv
    const v_hv: SemiCircle = .{
        .center = origin_v,
        .start_angle = (-1600.0 - angle) * millsToRad,
        .end_angle = (-1600.0 - angle - ctx.state.weaponValues.v) * millsToRad,
        .radius = ctx.state.terrainValues.h,
    };

    //c
    var v_c: Line = blk: {
        const val: [2]Vec2f = vec.getParallelVector2(v_v.start, v_v.end, -ctx.state.weaponValues.c);
        break :blk .{ .start = val[0], .end = val[1] };
    };

    // ch
    var v_ch: Line = .{
        .start = .{
            v_v.end[0],
            v_v.end[1],
        },
        .end = .{
            v_v.end[0] + 1000.0,
            v_v.end[1] - 10000000.0,
        },
    };
    v_ch.end = vec.rotate2D(v_ch.end, (-angle - 3200.0 + ctx.state.terrainValues.ch) * millsToRad);
    v_ch.end = if (vec.getVector2Intersection(v_ch.start, v_ch.end, v_c.start, v_c.end)) |val| val else v_c.end;

    // v_c.end = if (vec.getVector2Intersection(v_c.start, v_c.end, v_ch.start, v_ch.end)) |val| val else v_c.end;

    // forestMin
    var v_forestMin: Point = .{
        .pos = .{
            origin_v[0],
            origin_v[1] - ctx.state.terrainValues.forestDist,
        },
    };
    v_forestMin.pos = vec.rotate2D(v_forestMin.pos, angle * millsToRad);

    // // q1
    // var v_q1: Line = .{
    //     .start = .{
    //         trig.triangleOppositeLeg(ctx.state.terrainValues.Amin - ctx.state.terrainValues.f, -angle - ctx.state.weaponValues.v) - origin_v[0],
    //         origin_v[1] - ctx.state.terrainValues.Amin + ctx.state.terrainValues.f,
    //     },
    //     .end = .{
    //         v_v.end[0],
    //         v_v.end[1],
    //     },
    // };
    // v_q1.end = vec.rotate2D(v_q1.end, ctx.state.terrainValues.q1 * millsToRad);
    // // q1.addText("q1", 15, 0, 40, rl.Color.black, q1.end, ctx.state.config.showText);

    // // q2
    var v_q2: Line = .{
        .start = .{
            trig.triangleOppositeLeg(ctx.state.terrainValues.forestDist, (-angle + ctx.state.weaponValues.v) * millsToRad) + origin_v[0],
            origin_v[1] - ctx.state.terrainValues.forestDist,
        },
        .end = .{
            v_c.end[0],
            v_c.end[1],
        },
    };
    v_q2.end = vec.rotate2D(v_q2.end, ctx.state.terrainValues.q2 * millsToRad);
    // // q2.addText("q2", 25, 0, 40, rl.Color.black, q2.end, ctx.state.config.showText);
    v_q2.end = if (vec.getVector2Intersection(v_q2.start, v_q2.end, v_c.start, v_c.end)) |val| val else v_q2.end;
    v_q2.start = if (vec.getVector2Intersection(v_q2.start, v_q2.end, v_v.start, v_v.end)) |val| val else v_q2.start;

    // // q
    // var v_q: Line = if (ctx.state.terrainValues.forestDist > 0) v_q2 else v_q1;
    // v_q.end = if (vec.getVector2Intersection(v_q.start, v_q.end, v_c.start, v_c.end)) |val| val else v_q.end;
    // v_q.start = if (vec.getVector2Intersection(v_q.start, v_q.end, v_v.start, v_v.end)) |val| val else v_q.start;

    // v_v.end = if (vec.getVector2Intersection(v_v.start, v_v.end, v_q.start, v_q.end)) |val| val else v_v.end;
    v_c.end = if (vec.getVector2Intersection(v_c.start, v_c.end, v_ch.start, v_ch.end)) |val| val else v_c.end;
    // v_c.start = if (vec.getVector2Intersection(v_c.start, v_c.end, v_q.start, v_q.end)) |val| val else v_c.start;

    sst.draw(ctx);
    // h_h.draw(ctx);
    // h_v.draw(ctx);
    // h_hv.draw(ctx);
    // h_ch.draw(ctx);
    // h_c.draw(ctx);
    // h_q.draw(ctx);
    v_h.draw(ctx);
    v_v.draw(ctx);
    v_hv.draw(ctx);
    v_ch.draw(ctx);
    v_c.draw(ctx);
    v_q2.draw(ctx);
}
