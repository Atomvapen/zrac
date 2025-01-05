const std = @import("std");
const rl = @import("raylib");

const geo = @import("../../math/geo.zig");
const state = @import("../../data/state.zig").RiskProfile;
const drawBuffer = @import("drawBuffer.zig").DrawBuffer;

const origin: rl.Vector2 = .{ .x = 600, .y = 750 };

const Type = enum {
    Half,
    Box,
    SST,
};

pub fn draw(sort: Type, riskProfile: state, draw_buffer: *drawBuffer) !void {
    try switch (sort) {
        .Half => drawHalf(riskProfile, draw_buffer),
        .SST => drawSST(riskProfile, draw_buffer),
        .Box => drawBox(riskProfile, draw_buffer),
    };
}

fn drawHalf(riskProfile: state, draw_buffer: *drawBuffer) !void {
    try drawRisk(riskProfile, .{
        .x = origin.x,
        .y = origin.y,
    }, 0, draw_buffer);
}

fn drawSST(riskProfile: state, draw_buffer: *drawBuffer) !void {
    const sst: drawBuffer.Command = .{ .Line = drawBuffer.Command.create(.Line).init(
        &[_]rl.Vector2{
            rl.Vector2{ .x = origin.x - (riskProfile.sst.width / 2), .y = origin.y },
            rl.Vector2{ .x = origin.x + (riskProfile.sst.width / 2), .y = origin.y },
        },
        rl.Color.red,
    ) };

    try draw_buffer.append(sst);

    try drawRisk(riskProfile, .{
        .x = origin.x + (riskProfile.sst.width / 2),
        .y = origin.y,
    }, riskProfile.sst.hh, draw_buffer);
}

fn drawBox(riskProfile: state, draw_buffer: *drawBuffer) !void {
    const box: drawBuffer.Command = .{ .Line = drawBuffer.Command.create(.Line).init(
        &[_]rl.Vector2{
            rl.Vector2{ .x = origin.x - (riskProfile.box.width / 2), .y = origin.y },
            rl.Vector2{ .x = origin.x + (riskProfile.box.width / 2), .y = origin.y },
            rl.Vector2{ .x = origin.x + (riskProfile.box.width / 2), .y = origin.y - riskProfile.box.length },
            rl.Vector2{ .x = origin.x - (riskProfile.box.width / 2), .y = origin.y - riskProfile.box.length },
            rl.Vector2{ .x = origin.x - (riskProfile.box.width / 2), .y = origin.y },
        },
        rl.Color.red,
    ) };

    try draw_buffer.append(box);

    try drawRisk(riskProfile, .{
        .x = origin.x + (riskProfile.box.width / 2),
        .y = origin.y,
    }, riskProfile.box.h, draw_buffer);

    try drawRisk(riskProfile, .{
        .x = origin.x + (riskProfile.box.width / 2),
        .y = origin.y - riskProfile.box.length,
    }, riskProfile.box.h, draw_buffer);
}

fn drawRisk(riskProfile: state, risk_origin: rl.Vector2, angle: f32, draw_buffer: *drawBuffer) !void {
    // h
    var h: geo.Line = geo.Line.init(rl.Vector2{
        .x = risk_origin.x,
        .y = risk_origin.y,
    }, rl.Vector2{
        .x = risk_origin.x,
        .y = risk_origin.y - riskProfile.terrainValues.h,
    });
    h.rotate(.End, angle);
    h.addText("h", -20, 0, 40, rl.Color.black, h.end);

    // Amin
    var Amin: geo.Line = geo.Line.init(rl.Vector2{
        .x = risk_origin.x,
        .y = risk_origin.y,
    }, rl.Vector2{
        .x = risk_origin.x,
        .y = risk_origin.y - riskProfile.terrainValues.Amin,
    });
    Amin.rotate(.End, angle);
    Amin.addText("Amin", -100, 0, 40, rl.Color.black, Amin.end);

    // v
    var v: geo.Line = geo.Line.init(rl.Vector2{
        .x = risk_origin.x,
        .y = risk_origin.y,
    }, rl.Vector2{
        .x = risk_origin.x,
        .y = risk_origin.y - riskProfile.terrainValues.h,
    });
    v.rotate(.End, angle + riskProfile.weaponValues.v);
    v.addText("v", -5, -30, 40, rl.Color.black, v.end);

    var f: geo.Line = geo.Line.init(rl.Vector2{
        .x = risk_origin.x,
        .y = risk_origin.y - riskProfile.terrainValues.Amin + riskProfile.terrainValues.f,
    }, rl.Vector2{
        .x = risk_origin.x,
        .y = Amin.end.y + riskProfile.terrainValues.f,
    });
    f.addText("f", -70, 0, 40, rl.Color.black, f.end);

    // hv
    var hv: geo.Semicircle = geo.Semicircle.init(
        rl.Color.red,
        -90 + geo.milsToDegree(angle),
        -90 + geo.milsToDegree(angle + riskProfile.weaponValues.v),
        riskProfile.terrainValues.h,
        risk_origin,
        10,
    );

    //c
    var c: geo.Line = try geo.getParallelLine(v, riskProfile.weaponValues.c);

    // ch
    var ch: geo.Line = geo.Line.init(rl.Vector2{
        .x = v.end.x,
        .y = v.end.y,
    }, rl.Vector2{
        .x = v.end.x - 100.0,
        .y = v.end.y - 1000.0,
    });
    ch.rotate(.End, angle + 3200.0 - riskProfile.terrainValues.ch);
    ch.addText("ch", -5, -20, 40, rl.Color.black, ch.end);
    ch.endAtIntersection(c);

    // q1
    var q1: geo.Line = geo.Line.init(rl.Vector2{
        .x = geo.calculateXfromAngle(riskProfile.terrainValues.Amin - riskProfile.terrainValues.f, angle + riskProfile.weaponValues.v) + risk_origin.x,
        .y = risk_origin.y - riskProfile.terrainValues.Amin + riskProfile.terrainValues.f,
    }, rl.Vector2{
        .x = v.end.x,
        .y = v.end.y,
    });
    q1.rotate(.End, riskProfile.terrainValues.q1);
    q1.addText("q1", 15, 0, 40, rl.Color.black, q1.end);

    // q2
    var q2: geo.Line = geo.Line.init(rl.Vector2{
        .x = geo.calculateXfromAngle(riskProfile.terrainValues.forestDist, angle + riskProfile.weaponValues.v) + risk_origin.x,
        .y = risk_origin.y - riskProfile.terrainValues.forestDist,
    }, rl.Vector2{
        .x = v.end.x,
        .y = v.end.y,
    });
    q2.rotate(.End, riskProfile.terrainValues.q2);
    q2.addText("q2", 25, 0, 40, rl.Color.black, q2.end);

    // forestMin
    var forestMin: geo.Line = geo.Line.init(rl.Vector2{
        .x = undefined,
        .y = undefined,
    }, rl.Vector2{
        .x = risk_origin.x,
        .y = risk_origin.y - riskProfile.terrainValues.forestDist,
    });
    forestMin.addText("forestMin", -220, 0, 40, rl.Color.black, forestMin.end);

    // q
    var q: geo.Line = if (riskProfile.terrainValues.forestDist > 0) q2 else q1;
    q.endAtIntersection(c);

    v.endAtIntersection(q);
    c.endAtIntersection(ch);
    c.startAtIntersection(q);

    try draw_buffer.append(hv.createCommand());
    try draw_buffer.append(h.createCommand());
    try draw_buffer.append(v.createCommand());
    try draw_buffer.append(ch.createCommand());
    try draw_buffer.append(c.createCommand());
    try draw_buffer.append(q.createCommand());

    if (riskProfile.config.showText) {
        try draw_buffer.append(h.text);
        try draw_buffer.append(f.text);
        try draw_buffer.append(v.text);
        try draw_buffer.append(Amin.text);
        try draw_buffer.append(ch.text);

        if (riskProfile.terrainValues.forestDist > 0) {
            try draw_buffer.append(forestMin.text);
            try draw_buffer.append(q2.text);
        } else {
            try draw_buffer.append(q1.text);
        }
    }

    try draw_buffer.execute();
    try draw_buffer.clear();
}
