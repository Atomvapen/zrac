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
    const h: geo.Line = try geo.Line.init(rl.Vector2{
        .x = risk_origin.x,
        .y = risk_origin.y,
    }, rl.Vector2{
        .x = risk_origin.x,
        .y = risk_origin.y - riskProfile.terrainValues.h,
    }, true, angle);
    // if (riskProfile.config.showText) h.drawText("h", -20, 0, 40);

    const h_text: drawBuffer.Command = .{ .Text = drawBuffer.Command.create(.Text).init(
        "h",
        -20,
        0,
        40,
        rl.Color.black,
        h.end,
    ) };

    // Amin
    var Amin: geo.Line = try geo.Line.init(rl.Vector2{
        .x = risk_origin.x,
        .y = risk_origin.y,
    }, rl.Vector2{
        .x = risk_origin.x,
        .y = risk_origin.y - riskProfile.terrainValues.Amin,
    }, true, angle);
    if (riskProfile.config.showText) Amin.drawText("Amin", -100, 0, 40);

    // v
    var v: geo.Line = try geo.Line.init(rl.Vector2{
        .x = risk_origin.x,
        .y = risk_origin.y,
    }, rl.Vector2{
        .x = risk_origin.x,
        .y = risk_origin.y - riskProfile.terrainValues.h,
    }, true, angle + riskProfile.weaponValues.v);
    if (riskProfile.config.showText) v.drawText("v", -5, -30, 40);

    var f: geo.Line = try geo.Line.init(rl.Vector2{
        .x = risk_origin.x,
        .y = risk_origin.y - riskProfile.terrainValues.Amin + riskProfile.terrainValues.f,
    }, rl.Vector2{
        .x = risk_origin.x,
        .y = Amin.end.y + riskProfile.terrainValues.f,
    }, false, undefined);
    if (riskProfile.config.showText) f.drawText("f", -70, 0, 40);

    // h -> v
    const hv = try geo.calculateArcPoints(
        risk_origin,
        riskProfile.terrainValues.h,
        std.math.pi / 2.0,
        std.math.pi / 2.0 + geo.milsToRadians(v.angle),
        20,
    );

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
        .x = geo.calculateXfromAngle(riskProfile.terrainValues.Amin - riskProfile.terrainValues.f, v.angle) + risk_origin.x,
        .y = risk_origin.y - riskProfile.terrainValues.Amin + riskProfile.terrainValues.f,
    }, rl.Vector2{
        .x = v.end.x,
        .y = v.end.y,
    }, true, riskProfile.terrainValues.q1);

    // q2
    var q2: geo.Line = try geo.Line.init(rl.Vector2{
        .x = geo.calculateXfromAngle(riskProfile.terrainValues.forestDist, v.angle) + risk_origin.x,
        .y = risk_origin.y - riskProfile.terrainValues.forestDist,
    }, rl.Vector2{
        .x = v.end.x,
        .y = v.end.y,
    }, true, riskProfile.terrainValues.q2);

    // forestMin
    var forestMin: geo.Line = try geo.Line.init(rl.Vector2{
        .x = undefined,
        .y = undefined,
    }, rl.Vector2{
        .x = risk_origin.x,
        .y = risk_origin.y - riskProfile.terrainValues.forestDist,
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

    const lines: drawBuffer.Command = .{ .Line = drawBuffer.Command.create(.Line).init(
        &[_]rl.Vector2{
            h.end,
            h.start,
            v.end,
            geo.getLineIntersectionPoint(ch, c).?,
            geo.getLineIntersectionPoint(c, q).?,
            q.start,
        },
        rl.Color.red,
    ) };

    const semicircles: drawBuffer.Command = .{ .Semicircle = drawBuffer.Command.create(.Semicircle).init(
        hv,
        rl.Color.red,
    ) };

    try draw_buffer.append(semicircles);
    try draw_buffer.append(lines);

    if (riskProfile.config.showText) {
        try draw_buffer.append(h_text);
    }

    try draw_buffer.execute();
}
