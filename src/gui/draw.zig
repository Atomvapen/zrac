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

fn drawSST(_: State, _: *DrawBuffer) !void {
    // var sst: geo.Line = geo.Line.init(rl.Vector2{
    //     .x = origin.x - (riskProfile.sst.width / 2),
    //     .y = origin.y,
    // }, rl.Vector2{
    //     .x = origin.x + (riskProfile.sst.width / 2),
    //     .y = origin.y,
    // });
    // sst.createDrawCommand();

    // try draw_buffer.append(sst.drawCommand);

    // try drawRiskSST(riskProfile, .{
    //     .x = origin.x + (riskProfile.sst.width / 2),
    //     .y = origin.y,
    // }, riskProfile.sst.hh, draw_buffer);
}

fn drawBox(riskProfile: State, draw_buffer: *DrawBuffer) !void {
    const box_b = geo.Line.init(rl.Vector2{
        .x = origin.x - (riskProfile.box.width / 2),
        .y = origin.y,
    }, rl.Vector2{
        .x = origin.x + (riskProfile.box.width / 2),
        .y = origin.y,
    });

    const box_t = geo.Line.init(rl.Vector2{
        .x = origin.x - (riskProfile.box.width / 2),
        .y = origin.y - riskProfile.box.length,
    }, rl.Vector2{
        .x = origin.x + (riskProfile.box.width / 2),
        .y = origin.y - riskProfile.box.length,
    });

    const box_r = geo.Line.init(rl.Vector2{
        .x = origin.x + (riskProfile.box.width / 2),
        .y = origin.y,
    }, rl.Vector2{
        .x = origin.x + (riskProfile.box.width / 2),
        .y = origin.y - riskProfile.box.length,
    });

    const box_l = geo.Line.init(rl.Vector2{
        .x = origin.x - (riskProfile.box.width / 2),
        .y = origin.y,
    }, rl.Vector2{
        .x = origin.x - (riskProfile.box.width / 2),
        .y = origin.y - riskProfile.box.length,
    });

    try draw_buffer.append(geo.Shape{ .Line = box_b });
    try draw_buffer.append(geo.Shape{ .Line = box_t });
    try draw_buffer.append(geo.Shape{ .Line = box_r });
    try draw_buffer.append(geo.Shape{ .Line = box_l });

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
    h.addText("h", -20, 0, 40, rl.Color.black, h.end, riskProfile.config.showText);

    // Amin
    var Amin: geo.Point = geo.Point.init(rl.Vector2{
        .x = risk_origin.x,
        .y = risk_origin.y - riskProfile.terrainValues.Amin,
    });
    Amin.rotate(risk_origin, angle);
    Amin.addText("Amin", -100, 0, 40, rl.Color.black, riskProfile.config.showText);

    // v
    var v: geo.Line = geo.Line.init(rl.Vector2{
        .x = risk_origin.x,
        .y = risk_origin.y,
    }, rl.Vector2{
        .x = risk_origin.x,
        .y = risk_origin.y - riskProfile.terrainValues.h,
    });
    v.rotate(.End, angle + riskProfile.weaponValues.v);
    v.addText("v", -5, -30, 40, rl.Color.black, v.end, riskProfile.config.showText);

    // f
    var f: geo.Point = geo.Point.init(rl.Vector2{
        .x = risk_origin.x,
        .y = Amin.pos.y + riskProfile.terrainValues.f,
    });
    f.rotate(risk_origin, angle);
    f.addText("f", -70, 0, 40, rl.Color.black, riskProfile.config.showText);

    // hv
    const hv: geo.Semicircle = geo.Semicircle.init(
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
    ch.addText("ch", -5, -20, 40, rl.Color.black, ch.end, riskProfile.config.showText);
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
    q1.addText("q1", 15, 0, 40, rl.Color.black, q1.end, riskProfile.config.showText);

    // q2
    var q2: geo.Line = geo.Line.init(rl.Vector2{
        .x = trig.triangleOppositeLeg(riskProfile.terrainValues.forestDist, angle + riskProfile.weaponValues.v) + risk_origin.x,
        .y = risk_origin.y - riskProfile.terrainValues.forestDist,
    }, rl.Vector2{
        .x = v.end.x,
        .y = v.end.y,
    });
    q2.rotate(.End, riskProfile.terrainValues.q2);
    q2.addText("q2", 25, 0, 40, rl.Color.black, q2.end, riskProfile.config.showText);

    // forestMin
    var forestMin: geo.Point = geo.Point.init(rl.Vector2{
        .x = risk_origin.x,
        .y = Amin.pos.y - riskProfile.terrainValues.forestDist,
    });
    forestMin.rotate(risk_origin, angle);
    forestMin.addText("forestMin", -220, 0, 40, rl.Color.black, riskProfile.config.showText);

    // q
    var q: geo.Line = if (riskProfile.terrainValues.forestDist > 0) q2 else q1;
    q.end = q.getIntersectionPoint(c).?;

    v.end = v.getIntersectionPoint(q).?;
    c.end = c.getIntersectionPoint(ch).?;
    c.start = c.getIntersectionPoint(q).?;

    try draw_buffer.append(geo.Shape{ .Line = h });
    try draw_buffer.append(geo.Shape{ .Line = v });
    try draw_buffer.append(geo.Shape{ .Line = ch });
    try draw_buffer.append(geo.Shape{ .Line = c });
    try draw_buffer.append(geo.Shape{ .Line = q });
    try draw_buffer.append(geo.Shape{ .Semicircle = hv });
    try draw_buffer.append(geo.Shape{ .Point = Amin });
    try draw_buffer.append(geo.Shape{ .Point = f });
    try draw_buffer.append(geo.Shape{ .Point = forestMin });

    try draw_buffer.execute();
    try draw_buffer.clear();
}

// fn drawRiskSST(riskProfile: State, _: rl.Vector2, angle: f32, draw_buffer: *DrawBuffer) !void {
//     // const risk_origin = rl.Vector2{ .x = origin.x, .y = origin.y };
//     const risk_origin_h = rl.Vector2{ .x = origin.x + (riskProfile.sst.width / 2), .y = origin.y };
//     const risk_origin_v = rl.Vector2{ .x = origin.x - (riskProfile.sst.width / 2), .y = origin.y };

//     var sst: geo.Line = geo.Line.init(rl.Vector2{
//         .x = origin.x - (riskProfile.sst.width / 2),
//         .y = origin.y,
//     }, rl.Vector2{
//         .x = origin.x + (riskProfile.sst.width / 2),
//         .y = origin.y,
//     });
//     sst.createDrawCommand();

//     try draw_buffer.append(sst.drawCommand);

//     // h2
//     var h_h: geo.Line = geo.Line.init(rl.Vector2{
//         .x = risk_origin_v.x,
//         .y = risk_origin_v.y,
//     }, rl.Vector2{
//         .x = risk_origin_v.x,
//         .y = risk_origin_v.y - riskProfile.terrainValues.h,
//     });
//     h_h.rotate(.End, -angle);
//     h_h.createTextCommand("h", -20, 0, 40, rl.Color.black, h_h.end);

//     // v2
//     var v_h: geo.Line = geo.Line.init(rl.Vector2{
//         .x = risk_origin_v.x,
//         .y = risk_origin_v.y,
//     }, rl.Vector2{
//         .x = risk_origin_v.x,
//         .y = risk_origin_v.y - riskProfile.terrainValues.h,
//     });
//     v_h.rotate(.End, -angle - riskProfile.weaponValues.v);
//     v_h.createTextCommand("v", -5, -30, 40, rl.Color.black, v_h.end);

//     // Amin2
//     var Amin_h: geo.Line = geo.Line.init(rl.Vector2{
//         .x = risk_origin_v.x,
//         .y = risk_origin_v.y,
//     }, rl.Vector2{
//         .x = risk_origin_v.x,
//         .y = risk_origin_v.y - riskProfile.terrainValues.Amin,
//     });
//     Amin_h.rotate(.End, angle);
//     Amin_h.createTextCommand("Amin", -100, 0, 40, rl.Color.black, Amin_h.end);

//     // hv2
//     var hv_h: geo.Semicircle = geo.Semicircle.init(
//         rl.Color.red,
//         -1600 - angle,
//         -1600 - angle - riskProfile.weaponValues.v,
//         riskProfile.terrainValues.h,
//         risk_origin_v,
//         10,
//     );

//     //c2
//     var c_h: geo.Line = try v_h.getParallelLine(-riskProfile.weaponValues.c);

//     // ch2
//     var ch_h: geo.Line = geo.Line.init(rl.Vector2{
//         .x = v_h.end.x,
//         .y = v_h.end.y,
//     }, rl.Vector2{
//         .x = v_h.end.x + 100.0,
//         .y = v_h.end.y - 1000.0,
//     });
//     ch_h.rotate(.End, -angle - 3200.0 + riskProfile.terrainValues.ch);
//     ch_h.createTextCommand("ch", -5, -20, 40, rl.Color.black, ch_h.end);
//     ch_h.end = ch_h.getIntersectionPoint(c_h).?;

//     // q1
//     var q1_h: geo.Line = geo.Line.init(rl.Vector2{
//         .x = trig.triangleOppositeLeg(riskProfile.terrainValues.Amin - riskProfile.terrainValues.f, -angle - riskProfile.weaponValues.v) - risk_origin_v.x,
//         .y = risk_origin_v.y - riskProfile.terrainValues.Amin + riskProfile.terrainValues.f,
//     }, rl.Vector2{
//         .x = v_h.end.x,
//         .y = v_h.end.y,
//     });
//     q1_h.rotate(.End, riskProfile.terrainValues.q1);
//     q1_h.createTextCommand("q1", 15, 0, 40, rl.Color.black, q1_h.end);

//     // q2
//     var q2_h: geo.Line = geo.Line.init(rl.Vector2{
//         .x = -trig.triangleOppositeLeg(riskProfile.terrainValues.forestDist, -angle - riskProfile.weaponValues.v) - risk_origin_v.x,
//         .y = risk_origin_v.y - riskProfile.terrainValues.forestDist,
//     }, rl.Vector2{
//         .x = v_h.end.x,
//         .y = v_h.end.y,
//     });
//     q2_h.rotate(.End, riskProfile.terrainValues.q2);
//     q2_h.createTextCommand("q2", 25, 0, 40, rl.Color.black, q2_h.end);

//     // forestMin
//     var forestMin_h: geo.Line = geo.Line.init(rl.Vector2{
//         .x = undefined,
//         .y = undefined,
//     }, rl.Vector2{
//         .x = risk_origin_v.x,
//         .y = risk_origin_v.y - riskProfile.terrainValues.forestDist,
//     });
//     forestMin_h.createTextCommand("forestMin", -220, 0, 40, rl.Color.black, forestMin_h.end);

//     // q
//     var q_h: geo.Line = if (riskProfile.terrainValues.forestDist > 0) q2_h else q1_h;
//     q_h.end = q2_h.getIntersectionPoint(c_h).?;

//     v_h.end = v_h.getIntersectionPoint(q_h).?;
//     c_h.end = c_h.getIntersectionPoint(ch_h).?;
//     c_h.start = c_h.getIntersectionPoint(q_h).?;

//     // // hv3
//     // var hv3: geo.Semicircle = geo.Semicircle.init(
//     //     rl.Color.red,
//     //     -1600 - angle,
//     //     -1600 + angle + riskProfile.weaponValues.v,
//     //     riskProfile.terrainValues.h,
//     //     risk_origin,
//     //     10,
//     // );

//     //

//     // h
//     var h: geo.Line = geo.Line.init(rl.Vector2{
//         .x = risk_origin_h.x,
//         .y = risk_origin_h.y,
//     }, rl.Vector2{
//         .x = risk_origin_h.x,
//         .y = risk_origin_h.y - riskProfile.terrainValues.h,
//     });
//     h.rotate(.End, angle);
//     h.createTextCommand("h", -20, 0, 40, rl.Color.black, h.end);

//     // Amin
//     var Amin: geo.Line = geo.Line.init(rl.Vector2{
//         .x = risk_origin_h.x,
//         .y = risk_origin_h.y,
//     }, rl.Vector2{
//         .x = risk_origin_h.x,
//         .y = risk_origin_h.y - riskProfile.terrainValues.Amin,
//     });
//     Amin.rotate(.End, angle);
//     Amin.createTextCommand("Amin", -100, 0, 40, rl.Color.black, Amin.end);

//     // v
//     var v: geo.Line = geo.Line.init(rl.Vector2{
//         .x = risk_origin_h.x,
//         .y = risk_origin_h.y,
//     }, rl.Vector2{
//         .x = risk_origin_h.x,
//         .y = risk_origin_h.y - riskProfile.terrainValues.h,
//     });
//     v.rotate(.End, angle + riskProfile.weaponValues.v);
//     v.createTextCommand("v", -5, -30, 40, rl.Color.black, v.end);

//     var f: geo.Line = geo.Line.init(rl.Vector2{
//         .x = risk_origin_h.x,
//         .y = risk_origin_h.y - riskProfile.terrainValues.Amin + riskProfile.terrainValues.f,
//     }, rl.Vector2{
//         .x = risk_origin_h.x,
//         .y = Amin.end.y + riskProfile.terrainValues.f,
//     });
//     f.createTextCommand("f", -70, 0, 40, rl.Color.black, f.end);

//     // hv
//     var hv: geo.Semicircle = geo.Semicircle.init(
//         rl.Color.red,
//         -1600 + angle,
//         -1600 + angle + riskProfile.weaponValues.v,
//         riskProfile.terrainValues.h,
//         risk_origin_h,
//         10,
//     );

//     //c
//     var c: geo.Line = try v.getParallelLine(riskProfile.weaponValues.c);

//     // ch
//     var ch: geo.Line = geo.Line.init(rl.Vector2{
//         .x = v.end.x,
//         .y = v.end.y,
//     }, rl.Vector2{
//         .x = v.end.x - 100.0,
//         .y = v.end.y - 1000.0,
//     });
//     ch.rotate(.End, angle + 3200.0 - riskProfile.terrainValues.ch);
//     ch.createTextCommand("ch", -5, -20, 40, rl.Color.black, ch.end);
//     ch.end = ch.getIntersectionPoint(c).?;

//     // q1
//     var q1: geo.Line = geo.Line.init(rl.Vector2{
//         .x = trig.triangleOppositeLeg(riskProfile.terrainValues.Amin - riskProfile.terrainValues.f, angle + riskProfile.weaponValues.v) + risk_origin_h.x,
//         .y = risk_origin_h.y - riskProfile.terrainValues.Amin + riskProfile.terrainValues.f,
//     }, rl.Vector2{
//         .x = v.end.x,
//         .y = v.end.y,
//     });
//     q1.rotate(.End, riskProfile.terrainValues.q1);
//     q1.createTextCommand("q1", 15, 0, 40, rl.Color.black, q1.end);

//     // q2
//     var q2: geo.Line = geo.Line.init(rl.Vector2{
//         .x = trig.triangleOppositeLeg(riskProfile.terrainValues.forestDist, angle + riskProfile.weaponValues.v) + risk_origin_h.x,
//         .y = risk_origin_h.y - riskProfile.terrainValues.forestDist,
//     }, rl.Vector2{
//         .x = v.end.x,
//         .y = v.end.y,
//     });
//     q2.rotate(.End, riskProfile.terrainValues.q2);
//     q2.createTextCommand("q2", 25, 0, 40, rl.Color.black, q2.end);

//     // forestMin
//     var forestMin: geo.Line = geo.Line.init(rl.Vector2{
//         .x = undefined,
//         .y = undefined,
//     }, rl.Vector2{
//         .x = risk_origin_h.x,
//         .y = risk_origin_h.y - riskProfile.terrainValues.forestDist,
//     });
//     forestMin.createTextCommand("forestMin", -220, 0, 40, rl.Color.black, forestMin.end);

//     // q
//     var q: geo.Line = if (riskProfile.terrainValues.forestDist > 0) q2 else q1;
//     q.end = q.getIntersectionPoint(c).?;

//     v.end = v.getIntersectionPoint(q).?;
//     c.end = c.getIntersectionPoint(ch).?;
//     c.start = c.getIntersectionPoint(q).?;

//     // h2.createDrawCommand();
//     // try draw_buffer.append(h2.drawCommand);

//     v_h.createDrawCommand();
//     try draw_buffer.append(v_h.drawCommand);

//     hv_h.createDrawCommand();
//     try draw_buffer.append(hv_h.drawCommand);

//     c_h.createDrawCommand();
//     try draw_buffer.append(c_h.drawCommand);

//     ch_h.createDrawCommand();
//     try draw_buffer.append(ch_h.drawCommand);

//     q_h.createDrawCommand();
//     try draw_buffer.append(q_h.drawCommand);

//     // hv3.createDrawCommand();
//     // try draw_buffer.append(hv3.drawCommand);

//     hv.createDrawCommand();
//     h.createDrawCommand();
//     v.createDrawCommand();
//     ch.createDrawCommand();
//     c.createDrawCommand();
//     q.createDrawCommand();

//     try draw_buffer.append(hv.drawCommand);
//     try draw_buffer.append(h.drawCommand);
//     try draw_buffer.append(v.drawCommand);
//     try draw_buffer.append(ch.drawCommand);
//     try draw_buffer.append(c.drawCommand);
//     try draw_buffer.append(q.drawCommand);

//     if (riskProfile.config.showText) {
//         try draw_buffer.append(h.textCommand);
//         try draw_buffer.append(f.textCommand);
//         try draw_buffer.append(v.textCommand);
//         try draw_buffer.append(Amin.textCommand);
//         try draw_buffer.append(ch.textCommand);

//         if (riskProfile.terrainValues.forestDist > 0) {
//             try draw_buffer.append(forestMin.textCommand);
//             try draw_buffer.append(q2.textCommand);
//         } else {
//             try draw_buffer.append(q1.textCommand);
//         }
//     }

//     try draw_buffer.execute();
//     try draw_buffer.clear();
// }
