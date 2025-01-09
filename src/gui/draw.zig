const std = @import("std");
const rl = @import("raylib");
const reg = @import("reg");
const geo = reg.math.geometry;
const trig = reg.math.trig;
const DrawBuffer = reg.gui.DrawBuffer;
const State = reg.data.state.RiskProfile;

const origin: rl.Vector2 = .{ .x = 600, .y = 750 };

pub fn draw(sort: enum { Half, Box, SST }, riskProfile: State, draw_buffer: *DrawBuffer) !void {
    try switch (sort) {
        .Half => drawHalf(riskProfile, draw_buffer),
        .SST => drawSST(riskProfile, draw_buffer),
        .Box => drawBox(riskProfile, draw_buffer),
    };
}

fn drawHalf(riskProfile: State, draw_buffer: *DrawBuffer) !void {
    try drawRisk(riskProfile, .{
        .x = origin.x,
        .y = origin.y,
    }, 0, draw_buffer);
}

fn drawSST(riskProfile: State, draw_buffer: *DrawBuffer) !void {
    // const sst: DrawBuffer.Command = .{ .Line = DrawBuffer.Command.create(.Line).init(
    //     &[_]rl.Vector2{
    //         rl.Vector2{ .x = origin.x - (riskProfile.sst.width / 2), .y = origin.y },
    //         rl.Vector2{ .x = origin.x + (riskProfile.sst.width / 2), .y = origin.y },
    //     },
    //     rl.Color.red,
    // ) };

    // try draw_buffer.append(sst);

    try drawRisk(riskProfile, .{
        .x = origin.x + (riskProfile.sst.width / 2),
        .y = origin.y,
    }, riskProfile.sst.hh, draw_buffer);
}

fn drawBox(riskProfile: State, draw_buffer: *DrawBuffer) !void {
    // const box: DrawBuffer.Command = .{ .Line = DrawBuffer.Command.create(.Line).init(
    //     &[_]rl.Vector2{
    //         rl.Vector2{ .x = origin.x - (riskProfile.box.width / 2), .y = origin.y },
    //         rl.Vector2{ .x = origin.x + (riskProfile.box.width / 2), .y = origin.y },
    //         rl.Vector2{ .x = origin.x + (riskProfile.box.width / 2), .y = origin.y - riskProfile.box.length },
    //         rl.Vector2{ .x = origin.x - (riskProfile.box.width / 2), .y = origin.y - riskProfile.box.length },
    //         rl.Vector2{ .x = origin.x - (riskProfile.box.width / 2), .y = origin.y },
    //     },
    //     rl.Color.red,
    // ) };

    // try draw_buffer.append(box);

    try drawRisk(riskProfile, .{
        .x = origin.x + (riskProfile.box.width / 2),
        .y = origin.y,
    }, riskProfile.box.h, draw_buffer);

    try drawRisk(riskProfile, .{
        .x = origin.x + (riskProfile.box.width / 2),
        .y = origin.y - riskProfile.box.length,
    }, riskProfile.box.h, draw_buffer);
}

fn drawRisk(riskProfile: State, risk_origin: rl.Vector2, angle: f32, draw_buffer: *DrawBuffer) !void {
    // h
    var h: geo.Line = geo.Line.init(rl.Vector2{
        .x = risk_origin.x,
        .y = risk_origin.y,
    }, rl.Vector2{
        .x = risk_origin.x,
        .y = risk_origin.y - riskProfile.terrainValues.h,
    });
    h.rotate(.End, angle);
    h.createTextCommand("h", -20, 0, 40, rl.Color.black, h.end);

    // Amin
    var Amin: geo.Line = geo.Line.init(rl.Vector2{
        .x = risk_origin.x,
        .y = risk_origin.y,
    }, rl.Vector2{
        .x = risk_origin.x,
        .y = risk_origin.y - riskProfile.terrainValues.Amin,
    });
    Amin.rotate(.End, angle);
    Amin.createTextCommand("Amin", -100, 0, 40, rl.Color.black, Amin.end);

    // v
    var v: geo.Line = geo.Line.init(rl.Vector2{
        .x = risk_origin.x,
        .y = risk_origin.y,
    }, rl.Vector2{
        .x = risk_origin.x,
        .y = risk_origin.y - riskProfile.terrainValues.h,
    });
    v.rotate(.End, angle + riskProfile.weaponValues.v);
    v.createTextCommand("v", -5, -30, 40, rl.Color.black, v.end);

    var f: geo.Line = geo.Line.init(rl.Vector2{
        .x = risk_origin.x,
        .y = risk_origin.y - riskProfile.terrainValues.Amin + riskProfile.terrainValues.f,
    }, rl.Vector2{
        .x = risk_origin.x,
        .y = Amin.end.y + riskProfile.terrainValues.f,
    });
    f.createTextCommand("f", -70, 0, 40, rl.Color.black, f.end);

    // hv
    var hv: geo.Semicircle = geo.Semicircle.init(
        rl.Color.red,
        -1600 + angle,
        -1600 + angle + riskProfile.weaponValues.v,
        riskProfile.terrainValues.h,
        risk_origin,
        10,
    );

    //c
    var c: geo.Line = try v.getParallelLine(riskProfile.weaponValues.c);

    // ch
    var ch: geo.Line = geo.Line.init(rl.Vector2{
        .x = v.end.x,
        .y = v.end.y,
    }, rl.Vector2{
        .x = v.end.x - 100.0,
        .y = v.end.y - 1000.0,
    });
    ch.rotate(.End, angle + 3200.0 - riskProfile.terrainValues.ch);
    ch.createTextCommand("ch", -5, -20, 40, rl.Color.black, ch.end);
    ch.end = ch.getIntersectionPoint(c).?;

    // q1
    var q1: geo.Line = geo.Line.init(rl.Vector2{
        .x = trig.triangleOppositeLeg(riskProfile.terrainValues.Amin - riskProfile.terrainValues.f, angle + riskProfile.weaponValues.v) + risk_origin.x,
        .y = risk_origin.y - riskProfile.terrainValues.Amin + riskProfile.terrainValues.f,
    }, rl.Vector2{
        .x = v.end.x,
        .y = v.end.y,
    });
    q1.rotate(.End, riskProfile.terrainValues.q1);
    q1.createTextCommand("q1", 15, 0, 40, rl.Color.black, q1.end);

    // q2
    var q2: geo.Line = geo.Line.init(rl.Vector2{
        .x = trig.triangleOppositeLeg(riskProfile.terrainValues.forestDist, angle + riskProfile.weaponValues.v) + risk_origin.x,
        .y = risk_origin.y - riskProfile.terrainValues.forestDist,
    }, rl.Vector2{
        .x = v.end.x,
        .y = v.end.y,
    });
    q2.rotate(.End, riskProfile.terrainValues.q2);
    q2.createTextCommand("q2", 25, 0, 40, rl.Color.black, q2.end);

    // forestMin
    var forestMin: geo.Line = geo.Line.init(rl.Vector2{
        .x = undefined,
        .y = undefined,
    }, rl.Vector2{
        .x = risk_origin.x,
        .y = risk_origin.y - riskProfile.terrainValues.forestDist,
    });
    forestMin.createTextCommand("forestMin", -220, 0, 40, rl.Color.black, forestMin.end);

    // q
    var q: geo.Line = if (riskProfile.terrainValues.forestDist > 0) q2 else q1;
    q.end = q.getIntersectionPoint(c).?;

    v.end = v.getIntersectionPoint(q).?;
    c.end = c.getIntersectionPoint(ch).?;
    c.start = c.getIntersectionPoint(q).?;

    hv.createDrawCommand();
    h.createDrawCommand();
    v.createDrawCommand();
    ch.createDrawCommand();
    c.createDrawCommand();
    q.createDrawCommand();

    try draw_buffer.append(hv.drawCommand);
    try draw_buffer.append(h.drawCommand);
    try draw_buffer.append(v.drawCommand);
    try draw_buffer.append(ch.drawCommand);
    try draw_buffer.append(c.drawCommand);
    try draw_buffer.append(q.drawCommand);

    if (riskProfile.config.showText) {
        try draw_buffer.append(h.textCommand);
        try draw_buffer.append(f.textCommand);
        try draw_buffer.append(v.textCommand);
        try draw_buffer.append(Amin.textCommand);
        try draw_buffer.append(ch.textCommand);

        if (riskProfile.terrainValues.forestDist > 0) {
            try draw_buffer.append(forestMin.textCommand);
            try draw_buffer.append(q2.textCommand);
        } else {
            try draw_buffer.append(q1.textCommand);
        }
    }

    try draw_buffer.execute();
    try draw_buffer.clear();
}
