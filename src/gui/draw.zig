const rl = @import("raylib");
const geo = @import("../math/geo.zig");
const state = @import("../data/state.zig").RiskProfile;

pub fn drawLines(riskProfile: state) void {
    // Origin
    const origin = rl.Vector2{ .x = 600, .y = 750 };

    // h
    var h: geo.Line = try geo.Line.init(rl.Vector2{
        .x = origin.x,
        .y = origin.y,
    }, rl.Vector2{
        .x = origin.x,
        .y = origin.y - riskProfile.terrainValues.h,
    }, false, undefined);
    h.drawLine();
    h.drawText("h", -20, 0, 40);

    // Amin
    var Amin: geo.Line = try geo.Line.init(rl.Vector2{
        .x = undefined,
        .y = undefined,
    }, rl.Vector2{
        .x = origin.x,
        .y = origin.y - riskProfile.terrainValues.Amin,
    }, false, undefined);
    Amin.drawText("Amin", -60, 0, 40);

    // v
    var v: geo.Line = try geo.Line.init(rl.Vector2{
        .x = origin.x,
        .y = origin.y,
    }, rl.Vector2{
        .x = origin.x,
        .y = origin.y - riskProfile.terrainValues.h,
    }, true, riskProfile.weaponValues.v);
    v.drawLine();
    v.drawText("v", -5, -30, 40);

    var f: geo.Line = try geo.Line.init(rl.Vector2{
        .x = origin.x,
        .y = origin.y - riskProfile.terrainValues.Amin + riskProfile.terrainValues.f,
    }, rl.Vector2{
        .x = origin.x,
        .y = Amin.end.y + riskProfile.terrainValues.f,
    }, false, undefined);
    f.drawText("f", -30, -70, 40);

    // h -> v
    var hv: geo.Line = try geo.Line.init(rl.Vector2{
        .x = origin.x,
        .y = origin.y,
    }, rl.Vector2{
        .x = undefined,
        .y = undefined,
    }, false, riskProfile.weaponValues.v);
    hv.drawCircleSector(riskProfile.terrainValues.h);

    // ch
    var ch: geo.Line = try geo.Line.init(rl.Vector2{
        .x = v.end.x,
        .y = v.end.y,
    }, rl.Vector2{
        .x = v.end.x - 1.0,
        .y = v.end.y - 100.0,
    }, true, 3200.0 - riskProfile.ch);

    // q1
    var q1: geo.Line = try geo.Line.init(rl.Vector2{
        .x = geo.calculateXfromAngle(riskProfile.terrainValues.Amin - riskProfile.terrainValues.f, v.angle) + origin.x,
        .y = origin.y - riskProfile.terrainValues.Amin + riskProfile.terrainValues.f,
    }, rl.Vector2{
        .x = v.end.x,
        .y = v.end.y,
    }, true, riskProfile.q1);

    if (riskProfile.terrainValues.forestDist > 0) {
        // forestMin
        var forestMin: geo.Line = try geo.Line.init(rl.Vector2{
            .x = undefined,
            .y = undefined,
        }, rl.Vector2{
            .x = origin.x,
            .y = origin.y - riskProfile.terrainValues.forestDist,
        }, false, undefined);
        forestMin.drawText("forestMin", -65, -70, 40);

        // q2
        var q2: geo.Line = try geo.Line.init(rl.Vector2{
            .x = geo.calculateXfromAngle(riskProfile.terrainValues.forestDist, v.angle) + origin.x,
            .y = origin.y - riskProfile.terrainValues.forestDist,
        }, rl.Vector2{
            .x = v.end.x,
            .y = v.end.y,
        }, true, riskProfile.q2);

        var c: geo.Line = try geo.getParallelLine(v, riskProfile.c);

        c.startAtIntersection(q2);

        ch.endAtIntersection(c);
        ch.drawLine();
        ch.drawText("ch", -5, -20, 40);

        c.endAtIntersection(ch);
        c.drawLine();

        q2.endAtIntersection(c);
        q2.drawLine();
        q2.drawText("q2", 25, 0, 40);
    } else {
        ch.endAtIntersection(q1);
        // ch.drawLine();
        // ch.drawText("ch", -5, -20, 30);

        q1.endAtIntersection(ch);
        // q1.drawLine();
        // q1.drawText("q1", 15, 0, 30);

        // c
        var c: geo.Line = try geo.getParallelLine(v, riskProfile.c);
        c.startAtIntersection(q1);
        c.endAtIntersection(ch);
        // c.drawLine();

        if (riskProfile.terrainValues.factor != .I) {
            q1.end = c.start;
            ch.end = c.end;
            c.drawLine();
        }

        q1.drawLine();
        q1.drawText("q1", 15, 0, 40);
        ch.drawLine();
        ch.drawText("ch", -5, -20, 40);
    }
}
