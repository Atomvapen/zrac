const rl = @import("raylib");
const geo = @import("../math/geo.zig");
const state = @import("../data/state.zig").RiskProfile;

fn drawLinesPoly(riskProfile: state, origin: rl.Vector2, angle: f32) void {
    // h
    var h: geo.Line = try geo.Line.init(rl.Vector2{
        .x = origin.x,
        .y = origin.y,
    }, rl.Vector2{
        .x = origin.x,
        .y = origin.y - riskProfile.terrainValues.h,
    }, true, angle);
    if (riskProfile.config.showText) h.drawText("h", -20, 0, 40);

    // Amin
    var Amin: geo.Line = try geo.Line.init(rl.Vector2{
        .x = origin.x,
        .y = origin.y,
    }, rl.Vector2{
        .x = origin.x,
        .y = origin.y - riskProfile.terrainValues.Amin,
    }, true, angle);
    if (riskProfile.config.showText) Amin.drawText("Amin", -100, 0, 40);

    // v
    var v: geo.Line = try geo.Line.init(rl.Vector2{
        .x = origin.x,
        .y = origin.y,
    }, rl.Vector2{
        .x = origin.x,
        .y = origin.y - riskProfile.terrainValues.h,
    }, true, angle + riskProfile.weaponValues.v);
    if (riskProfile.config.showText) v.drawText("v", -5, -30, 40);

    var f: geo.Line = try geo.Line.init(rl.Vector2{
        .x = origin.x,
        .y = origin.y - riskProfile.terrainValues.Amin + riskProfile.terrainValues.f,
    }, rl.Vector2{
        .x = origin.x,
        .y = Amin.end.y + riskProfile.terrainValues.f,
    }, false, undefined);
    if (riskProfile.config.showText) f.drawText("f", -70, 0, 40);

    // h -> v
    var hv: geo.Line = try geo.Line.init(rl.Vector2{
        .x = origin.x,
        .y = origin.y,
    }, rl.Vector2{
        .x = undefined,
        .y = undefined,
    }, true, riskProfile.weaponValues.v);
    // hv.drawCircleSector(riskProfile.terrainValues.h, -90 + geo.milsToDegree(angle));

    // ch
    var ch: geo.Line = try geo.Line.init(rl.Vector2{
        .x = v.end.x,
        .y = v.end.y,
    }, rl.Vector2{
        .x = v.end.x - 1.0,
        .y = v.end.y - 100.0,
    }, true, angle + 3200.0 - riskProfile.terrainValues.ch);

    //c
    const c: geo.Line = try geo.getParallelLine(v, riskProfile.weaponValues.c);

    //q
    var q = try geo.Line.init(rl.Vector2.zero(), rl.Vector2.zero(), false, undefined);

    // q1
    var q1: geo.Line = try geo.Line.init(rl.Vector2{
        .x = geo.calculateXfromAngle(riskProfile.terrainValues.Amin - riskProfile.terrainValues.f, v.angle) + origin.x,
        .y = origin.y - riskProfile.terrainValues.Amin + riskProfile.terrainValues.f,
    }, rl.Vector2{
        .x = v.end.x,
        .y = v.end.y,
    }, true, riskProfile.terrainValues.q1);

    // q2
    var q2: geo.Line = try geo.Line.init(rl.Vector2{
        .x = geo.calculateXfromAngle(riskProfile.terrainValues.forestDist, v.angle) + origin.x,
        .y = origin.y - riskProfile.terrainValues.forestDist,
    }, rl.Vector2{
        .x = v.end.x,
        .y = v.end.y,
    }, true, riskProfile.terrainValues.q2);

    // forestMin
    var forestMin: geo.Line = try geo.Line.init(rl.Vector2{
        .x = undefined,
        .y = undefined,
    }, rl.Vector2{
        .x = origin.x,
        .y = origin.y - riskProfile.terrainValues.forestDist,
    }, false, undefined);

    if (riskProfile.terrainValues.forestDist > 0) {
        if (riskProfile.config.showText) forestMin.drawText("forestMin", -220, 0, 40);
        if (riskProfile.config.showText) ch.drawText("ch", -5, -20, 40);
        if (riskProfile.config.showText) q2.drawText("q2", 25, 0, 40);
        q = q2;
    } else {
        if (riskProfile.terrainValues.factor != .I) {
            q1.end = c.start;
            ch.end = c.end;
        }
        if (riskProfile.config.showText) q1.drawText("q1", 15, 0, 40);
        if (riskProfile.config.showText) ch.drawText("ch", -5, -20, 40);
        q = q1;
    }

    const half = [_]rl.Vector2{
        h.end,
        h.start,
        v.end,
        geo.getLineIntersectionPoint(ch, c) orelse rl.Vector2{ .x = 0, .y = 0 },
        geo.getLineIntersectionPoint(c, q) orelse rl.Vector2{ .x = 0, .y = 0 },
        q.start,
    };

    hv.drawCircleSector(riskProfile.terrainValues.h, -90 + geo.milsToDegree(angle));
    geo.drawPolylineV(half[0..], rl.Color.maroon);
}

pub fn drawHalf(riskProfile: state) void {
    const origin: rl.Vector2 = .{ .x = 600, .y = 750 };

    drawLinesPoly(riskProfile, .{
        .x = origin.x,
        .y = origin.y,
    }, 0);
}

pub fn drawSST(riskProfile: state) void {
    const origin: rl.Vector2 = .{ .x = 600, .y = 750 };

    const sst = [_]rl.Vector2{
        rl.Vector2{ .x = origin.x - (riskProfile.sst.width / 2), .y = origin.y },
        rl.Vector2{ .x = origin.x + (riskProfile.sst.width / 2), .y = origin.y },
    };

    geo.drawPolylineV(sst[0..], rl.Color.maroon);

    // // Width
    // var w_b: geo.Line = try geo.Line.init(.{
    //     .x = origin.x - (riskProfile.sst.width / 2),
    //     .y = origin.y,
    // }, .{
    //     .x = origin.x + (riskProfile.sst.width / 2),
    //     .y = origin.y,
    // }, false, undefined);
    // w_b.drawLineV();

    drawLines(riskProfile, .{
        .x = origin.x + (riskProfile.sst.width / 2),
        .y = origin.y,
    }, riskProfile.sst.hh);
}

pub fn drawBox(riskProfile: state) void {
    const origin: rl.Vector2 = .{ .x = 600, .y = 750 };

    const box = [_]rl.Vector2{
        rl.Vector2{ .x = origin.x - (riskProfile.box.width / 2), .y = origin.y },
        rl.Vector2{ .x = origin.x + (riskProfile.box.width / 2), .y = origin.y },
        rl.Vector2{ .x = origin.x + (riskProfile.box.width / 2), .y = origin.y - riskProfile.box.length },
        rl.Vector2{ .x = origin.x - (riskProfile.box.width / 2), .y = origin.y - riskProfile.box.length },
        rl.Vector2{ .x = origin.x - (riskProfile.box.width / 2), .y = origin.y },
    };

    geo.drawPolylineV(box[0..], rl.Color.maroon);

    // // Width
    // var w_b: geo.Line = try geo.Line.init(.{
    //     .x = origin.x - (riskProfile.box.width / 2),
    //     .y = origin.y,
    // }, .{
    //     .x = origin.x + (riskProfile.box.width / 2),
    //     .y = origin.y,
    // }, false, undefined);
    // w_b.drawLineV();

    // var w_t: geo.Line = try geo.Line.init(.{
    //     .x = origin.x - (riskProfile.box.width / 2),
    //     .y = origin.y - riskProfile.box.length,
    // }, .{
    //     .x = origin.x + (riskProfile.box.width / 2),
    //     .y = origin.y - riskProfile.box.length,
    // }, false, undefined);
    // w_t.drawLineV();

    // // Length
    // var l_l: geo.Line = try geo.Line.init(.{
    //     .x = origin.x - (riskProfile.box.width / 2),
    //     .y = origin.y,
    // }, .{
    //     .x = origin.x - (riskProfile.box.width / 2),
    //     .y = origin.y - riskProfile.box.length,
    // }, false, undefined);
    // l_l.drawLineV();

    // var l_r: geo.Line = try geo.Line.init(.{
    //     .x = origin.x + (riskProfile.box.width / 2),
    //     .y = origin.y,
    // }, .{
    //     .x = origin.x + (riskProfile.box.width / 2),
    //     .y = origin.y - riskProfile.box.length,
    // }, false, undefined);
    // l_r.drawLineV();

    // Draw
    drawLines(riskProfile, .{
        .x = origin.x + (riskProfile.box.width / 2),
        .y = origin.y,
    }, riskProfile.box.h);

    drawLines(riskProfile, .{
        .x = origin.x + (riskProfile.box.width / 2),
        .y = origin.y - riskProfile.box.length,
    }, riskProfile.box.h);
}

fn drawLines(riskProfile: state, origin: rl.Vector2, angle: f32) void {
    // h
    var h: geo.Line = try geo.Line.init(rl.Vector2{
        .x = origin.x,
        .y = origin.y,
    }, rl.Vector2{
        .x = origin.x,
        .y = origin.y - riskProfile.terrainValues.h,
    }, true, angle);
    h.drawLineV();
    if (riskProfile.config.showText) h.drawText("h", -20, 0, 40);

    // Amin
    var Amin: geo.Line = try geo.Line.init(rl.Vector2{
        .x = origin.x,
        .y = origin.y,
    }, rl.Vector2{
        .x = origin.x,
        .y = origin.y - riskProfile.terrainValues.Amin,
    }, true, angle);
    if (riskProfile.config.showText) Amin.drawText("Amin", -100, 0, 40);

    // v
    var v: geo.Line = try geo.Line.init(rl.Vector2{
        .x = origin.x,
        .y = origin.y,
    }, rl.Vector2{
        .x = origin.x,
        .y = origin.y - riskProfile.terrainValues.h,
    }, true, angle + riskProfile.weaponValues.v);
    v.drawLineV();
    if (riskProfile.config.showText) v.drawText("v", -5, -30, 40);

    var f: geo.Line = try geo.Line.init(rl.Vector2{
        .x = origin.x,
        .y = origin.y - riskProfile.terrainValues.Amin + riskProfile.terrainValues.f,
    }, rl.Vector2{
        .x = origin.x,
        .y = Amin.end.y + riskProfile.terrainValues.f,
    }, false, undefined);
    if (riskProfile.config.showText) f.drawText("f", -70, 0, 40);

    // h -> v
    var hv: geo.Line = try geo.Line.init(rl.Vector2{
        .x = origin.x,
        .y = origin.y,
    }, rl.Vector2{
        .x = undefined,
        .y = undefined,
    }, true, riskProfile.weaponValues.v);
    hv.drawCircleSector(riskProfile.terrainValues.h, -90 + geo.milsToDegree(angle));

    // ch
    var ch: geo.Line = try geo.Line.init(rl.Vector2{
        .x = v.end.x,
        .y = v.end.y,
    }, rl.Vector2{
        .x = v.end.x - 1.0,
        .y = v.end.y - 100.0,
    }, true, angle + 3200.0 - riskProfile.terrainValues.ch);

    // q1
    var q1: geo.Line = try geo.Line.init(rl.Vector2{
        .x = geo.calculateXfromAngle(riskProfile.terrainValues.Amin - riskProfile.terrainValues.f, v.angle) + origin.x,
        .y = origin.y - riskProfile.terrainValues.Amin + riskProfile.terrainValues.f,
    }, rl.Vector2{
        .x = v.end.x,
        .y = v.end.y,
    }, true, riskProfile.terrainValues.q1);

    //c
    var c: geo.Line = try geo.getParallelLine(v, riskProfile.weaponValues.c);

    if (riskProfile.terrainValues.forestDist > 0) {
        // forestMin
        var forestMin: geo.Line = try geo.Line.init(rl.Vector2{
            .x = undefined,
            .y = undefined,
        }, rl.Vector2{
            .x = origin.x,
            .y = origin.y - riskProfile.terrainValues.forestDist,
        }, false, undefined);
        if (riskProfile.config.showText) forestMin.drawText("forestMin", -220, 0, 40);

        // q2
        var q2: geo.Line = try geo.Line.init(rl.Vector2{
            .x = geo.calculateXfromAngle(riskProfile.terrainValues.forestDist, v.angle) + origin.x,
            .y = origin.y - riskProfile.terrainValues.forestDist,
        }, rl.Vector2{
            .x = v.end.x,
            .y = v.end.y,
        }, true, riskProfile.terrainValues.q2);

        c.startAtIntersection(q2);

        ch.endAtIntersection(c);
        ch.drawLineV();
        if (riskProfile.config.showText) ch.drawText("ch", -5, -20, 40);

        c.endAtIntersection(ch);
        c.drawLineV();

        q2.endAtIntersection(c);
        q2.drawLineV();
        if (riskProfile.config.showText) q2.drawText("q2", 25, 0, 40);
    } else {
        ch.endAtIntersection(q1);

        q1.endAtIntersection(ch);

        c.startAtIntersection(q1);
        c.endAtIntersection(ch);

        if (riskProfile.terrainValues.factor != .I) {
            q1.end = c.start;
            ch.end = c.end;
            c.drawLineV();
        }

        q1.drawLineV();
        if (riskProfile.config.showText) q1.drawText("q1", 15, 0, 40);

        ch.drawLineV();
        if (riskProfile.config.showText) ch.drawText("ch", -5, -20, 40);
    }
}
