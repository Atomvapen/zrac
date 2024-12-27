const rl = @import("raylib");
const geo = @import("../math/geo.zig");
const state = @import("../data/state.zig").RiskProfile;

// var origin: rl.Vector2 = .{ .x = 0, .y = 0 };

pub fn drawHalf(riskProfile: state) void {
    const origin: rl.Vector2 = .{ .x = 600, .y = 750 };

    drawLines(riskProfile, .{
        .x = origin.x,
        .y = origin.y,
    }, 0);
}

pub fn drawSST(riskProfile: state) void {
    const origin: rl.Vector2 = .{ .x = 600, .y = 750 };

    // Width
    var w_b: geo.Line = try geo.Line.init(.{
        .x = origin.x - (riskProfile.sst.width / 2),
        .y = origin.y,
    }, .{
        .x = origin.x + (riskProfile.sst.width / 2),
        .y = origin.y,
    }, false, undefined);
    w_b.drawLine();

    drawLines(riskProfile, .{
        .x = origin.x + (riskProfile.sst.width / 2),
        .y = origin.y,
    }, riskProfile.sst.hh);
}

pub fn drawBox(riskProfile: state) void {
    const origin: rl.Vector2 = .{ .x = 600, .y = 750 };

    // Width
    var w_b: geo.Line = try geo.Line.init(.{
        .x = origin.x - (riskProfile.box.width / 2),
        .y = origin.y,
    }, .{
        .x = origin.x + (riskProfile.box.width / 2),
        .y = origin.y,
    }, false, undefined);
    w_b.drawLine();

    var w_t: geo.Line = try geo.Line.init(.{
        .x = origin.x - (riskProfile.box.width / 2),
        .y = origin.y - riskProfile.box.length,
    }, .{
        .x = origin.x + (riskProfile.box.width / 2),
        .y = origin.y - riskProfile.box.length,
    }, false, undefined);
    w_t.drawLine();

    // Length
    var l_l: geo.Line = try geo.Line.init(.{
        .x = origin.x - (riskProfile.box.width / 2),
        .y = origin.y,
    }, .{
        .x = origin.x - (riskProfile.box.width / 2),
        .y = origin.y - riskProfile.box.length,
    }, false, undefined);
    l_l.drawLine();

    var l_r: geo.Line = try geo.Line.init(.{
        .x = origin.x + (riskProfile.box.width / 2),
        .y = origin.y,
    }, .{
        .x = origin.x + (riskProfile.box.width / 2),
        .y = origin.y - riskProfile.box.length,
    }, false, undefined);
    l_r.drawLine();

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
    h.drawLine();
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
    v.drawLine();
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
        ch.drawLine();
        if (riskProfile.config.showText) ch.drawText("ch", -5, -20, 40);

        c.endAtIntersection(ch);
        c.drawLine();

        q2.endAtIntersection(c);
        q2.drawLine();
        if (riskProfile.config.showText) q2.drawText("q2", 25, 0, 40);
    } else {
        ch.endAtIntersection(q1);

        q1.endAtIntersection(ch);

        c.startAtIntersection(q1);
        c.endAtIntersection(ch);

        if (riskProfile.terrainValues.factor != .I) {
            q1.end = c.start;
            ch.end = c.end;
            c.drawLine();
        }

        q1.drawLine();
        if (riskProfile.config.showText) q1.drawText("q1", 15, 0, 40);

        ch.drawLine();
        if (riskProfile.config.showText) ch.drawText("ch", -5, -20, 40);
    }
}
