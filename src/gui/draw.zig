const state = @import("../data/state.zig");
const rl = @import("raylib");
const geo = @import("../math/geo.zig");

pub fn drawLines(riskProfile: *state.riskState) void {
    // Origin
    const origin: rl.Vector2 = rl.Vector2{ .x = @as(f32, @floatFromInt(rl.getScreenWidth())) / 2, .y = @as(f32, @floatFromInt(rl.getScreenHeight())) - 50 };

    // h
    var h: geo.Line = try geo.Line.init(rl.Vector2{
        .x = origin.x,
        .y = origin.y,
    }, rl.Vector2{
        .x = origin.x,
        .y = origin.y - riskProfile.h,
    }, false, undefined);
    h.drawLine();
    h.drawText("h", 0, -30, 30);

    // Amin
    var Amin: geo.Line = try geo.Line.init(rl.Vector2{
        .x = undefined,
        .y = undefined,
    }, rl.Vector2{
        .x = origin.x,
        .y = origin.y - riskProfile.getAmin(),
    }, false, undefined);
    Amin.drawText("Amin", -70, 0, 30);

    // v
    var v: geo.Line = try geo.Line.init(rl.Vector2{
        .x = origin.x,
        .y = origin.y,
    }, rl.Vector2{
        .x = origin.x,
        .y = origin.y - riskProfile.h,
    }, true, riskProfile.v);
    v.drawLine();
    v.drawText("v", -5, -30, 30);

    if (riskProfile.getF() > riskProfile.getAmin()) return;
    var f: geo.Line = try geo.Line.init(rl.Vector2{
        .x = origin.x,
        .y = origin.y - riskProfile.getAmin() + riskProfile.getF(),
    }, rl.Vector2{
        .x = origin.x,
        .y = Amin.end.y + (riskProfile.getF() + 50.0),
    }, false, undefined);
    f.drawText("f", -30, -70, 30);

    // q1
    var q1: geo.Line = try geo.Line.init(rl.Vector2{
        .x = geo.calculateXfromAngle(@intFromFloat(riskProfile.getAmin() - riskProfile.getF()), v.angle) + origin.x,
        .y = origin.y - riskProfile.getAmin() + riskProfile.getF(),
    }, rl.Vector2{
        .x = v.end.x,
        .y = v.end.y,
    }, true, riskProfile.q1);

    // h -> v
    var hv: geo.Line = try geo.Line.init(rl.Vector2{
        .x = origin.x,
        .y = origin.y,
    }, rl.Vector2{
        .x = undefined,
        .y = undefined,
    }, false, riskProfile.v);
    hv.drawCircleSector(riskProfile.h);

    // ch
    var ch: geo.Line = try geo.Line.init(rl.Vector2{
        .x = v.end.x,
        .y = v.end.y,
    }, rl.Vector2{
        .x = v.end.x - 30000.0,
        .y = v.end.y - 30000.0,
    }, true, riskProfile.ch);

    //TODO: Fix interceptingForest
    // if (riskProfile.interceptingForest == false and riskProfile.forestDist < 0) {
    //     ch.endAtIntersection(q1);
    //     // ch.drawLine();
    //     // ch.drawText("ch", -5, -20, 30);

    //     q1.endAtIntersection(ch);
    //     // q1.drawLine();
    //     // q1.drawText("q1", 15, 0, 30);

    //     // c
    //     var c: geo.Line = try geo.getParallelLine(v, riskProfile.c);
    //     c.startAtIntersection(q1);
    //     c.endAtIntersection(ch);
    //     // c.drawLine();

    //     if (riskProfile.factor > 0) {
    //         q1.end = c.start;
    //         ch.end = c.end;
    //         c.drawLine();
    //     }

    //     q1.drawLine();
    //     q1.drawText("q1", 15, 0, 30);
    //     ch.drawLine();
    //     ch.drawText("ch", -5, -20, 30);
    // }

    if (riskProfile.getForestDist() > 0) {
        // forestMin
        var forestMin: geo.Line = try geo.Line.init(rl.Vector2{
            .x = undefined,
            .y = undefined,
        }, rl.Vector2{
            .x = origin.x,
            .y = origin.y - riskProfile.getForestDist(),
        }, false, undefined);
        forestMin.drawText("forestMin", -65, -70, 30);

        // q2
        var q2: geo.Line = try geo.Line.init(rl.Vector2{
            .x = geo.calculateXfromAngle(@intFromFloat(riskProfile.getForestDist()), v.angle) + origin.x,
            .y = origin.y - riskProfile.getForestDist(),
        }, rl.Vector2{
            .x = v.end.x,
            .y = v.end.y,
        }, true, riskProfile.q2);

        var c: geo.Line = try geo.getParallelLine(v, riskProfile.c);
        c.startAtIntersection(q2);

        ch.endAtIntersection(c);
        ch.drawLine();
        ch.drawText("ch", -5, -20, 30);

        c.endAtIntersection(ch);
        c.drawLine();

        q2.endAtIntersection(c);
        q2.drawLine();
        q2.drawText("q2", 25, 0, 30);
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

        if (riskProfile.factor > 0) {
            q1.end = c.start;
            ch.end = c.end;
            c.drawLine();
        }

        q1.drawLine();
        q1.drawText("q1", 15, 0, 30);
        ch.drawLine();
        ch.drawText("ch", -5, -20, 30);
    }

    // q2
    // if (riskProfile.interceptingForest == true) {
    //     // q2
    //     var q2: geo.Line = try geo.Line.init(rl.Vector2{
    //         .x = origin.x,
    //         .y = origin.y,
    //     }, rl.Vector2{
    //         .x = v.end.x,
    //         .y = v.end.y,
    //     }, true, riskProfile.q2);

    //     var c: geo.Line = try geo.getParallelLine(v, riskProfile.c);
    //     c.startAtIntersection(q2);

    //     ch.endAtIntersection(c);
    //     ch.drawLine();
    //     ch.drawText("ch", -5, -20, 30);

    //     c.end = ch.end;
    //     // c.end.y = ch.end.y;
    //     c.drawLine();

    //     q2.end = c.start;
    //     q2.drawLine();
    //     q2.drawText("q2", 25, 0, 30);
    // } else if (riskProfile.forestDist >= 0 and riskProfile.forestDist <= riskProfile.h) {
    //     // forestMin
    //     var forestMin: geo.Line = try geo.Line.init(rl.Vector2{
    //         .x = undefined,
    //         .y = undefined,
    //     }, rl.Vector2{
    //         .x = origin.x,
    //         .y = origin.y - riskProfile.forestDist,
    //     }, false, undefined);
    //     forestMin.drawText("forestMin", -65, -70, 30);

    //     // q2
    //     var q2: geo.Line = try geo.Line.init(rl.Vector2{
    //         .x = geo.calculateXfromAngle(@intFromFloat(riskProfile.forestDist), v.angle) + origin.x,
    //         .y = origin.y - riskProfile.forestDist,
    //     }, rl.Vector2{
    //         .x = v.end.x,
    //         .y = v.end.y,
    //     }, true, riskProfile.q2);

    //     var c: geo.Line = try geo.getParallelLine(v, riskProfile.c);
    //     c.startAtIntersection(q2);

    //     ch.endAtIntersection(c);
    //     ch.drawLine();
    //     ch.drawText("ch", -5, -20, 30);

    //     c.endAtIntersection(ch);
    //     c.drawLine();

    //     q2.endAtIntersection(c);
    //     q2.drawLine();
    //     q2.drawText("q2", 25, 0, 30);
    // }
}
