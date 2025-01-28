const std = @import("std");
const rl = @import("raylib");
const zgui = @import("zgui");
const reg = @import("reg");
const camera = reg.gui.camera;
const Context = reg.data.Context;
const Modal = reg.gui.Modal;
const geo = reg.math.geometry;
const trig = reg.math.trig;

const origin: rl.Vector2 = .{ .x = 600, .y = 750 };

pub fn main(ctx: *Context) !void {
    while (!rl.windowShouldClose() and !ctx.window.config.quit) {
        ctx.update();

        rl.beginDrawing();
        defer rl.endDrawing();

        zgui.rlimgui.begin();
        defer zgui.rlimgui.end();

        camera.enabled = (ctx.window.modal == null);
        if (camera.enabled) camera.handle();

        rl.clearBackground(rl.Color.white);

        drawMainMenu(ctx);
        try drawPlane(ctx);
        drawFrames(ctx);

        try ctx.draw_buffer.clear();
    }
}

fn drawMainMenu(ctx: *Context) void {
    if (zgui.beginMainMenuBar()) {
        if (zgui.beginMenu("Fil", true)) {
            if (zgui.menuItem("Importera", .{})) {
                if (ctx.window.modal == null) ctx.window.modal = Modal.create(.importModal);
            }
            if (zgui.menuItem("Exportera", .{})) {
                if (ctx.window.modal == null) ctx.window.modal = Modal.create(.exportModal);
            }
            zgui.separator();
            if (zgui.menuItem("Avsluta", .{})) ctx.window.config.quit = true;
            zgui.endMenu();
        }

        if (zgui.beginMenu("Fönster", true)) {
            if (zgui.menuItem("Riskprofil", .{})) ctx.window.frames.riskEditorFrame.open = !ctx.window.frames.riskEditorFrame.open;
            zgui.endMenu();
        }

        zgui.endMainMenuBar();
    }
}

fn drawFrames(ctx: *Context) void {
    if (ctx.window.frames.riskEditorFrame.open) ctx.window.frames.riskEditorFrame.show(ctx);

    if (ctx.window.modal) |*modal| {
        if (!modal.isOpen()) ctx.window.modal = null;
        modal.show();
    }
}

fn drawPlane(ctx: *Context) !void {
    camera.begin();
    defer camera.end();

    rl.gl.rlPushMatrix();
    rl.gl.rlTranslatef(50 * 50, 50 * 50, 0);
    rl.gl.rlRotatef(90, 1, 0, 0);
    rl.drawGrid(200, 200);
    rl.gl.rlPopMatrix();

    if (ctx.state.config.valid) {
        errdefer ctx.draw_buffer.clear() catch {};

        try switch (ctx.state.config.sort) {
            .Halva => drawHalf(ctx),
            .SST => drawSST(ctx),
            .Box => drawBox(ctx),
        };
        ctx.draw_buffer.execute();
    }
}

pub fn drawHalf(ctx: *Context) !void {
    const risk_origin = origin;
    const angle = 0;

    // h
    var h: geo.Line = geo.Line.init(rl.Vector2{
        .x = risk_origin.x,
        .y = risk_origin.y,
    }, rl.Vector2{
        .x = risk_origin.x,
        .y = risk_origin.y - ctx.state.terrainValues.h,
    });
    h.rotate(.End, angle);
    h.addText("h", -20, 0, 40, rl.Color.black, h.end, ctx.state.config.showText);

    // Amin
    var Amin: geo.Point = geo.Point.init(rl.Vector2{
        .x = risk_origin.x,
        .y = risk_origin.y - ctx.state.terrainValues.Amin,
    });
    Amin.rotate(risk_origin, angle);
    Amin.addText("Amin", -100, 0, 40, rl.Color.black, ctx.state.config.showText);

    // v
    var v: geo.Line = geo.Line.init(rl.Vector2{
        .x = risk_origin.x,
        .y = risk_origin.y,
    }, rl.Vector2{
        .x = risk_origin.x,
        .y = risk_origin.y - ctx.state.terrainValues.h,
    });
    v.rotate(.End, angle + ctx.state.weaponValues.v);
    v.addText("v", -5, -30, 40, rl.Color.black, v.end, ctx.state.config.showText);

    // f
    var f: geo.Point = geo.Point.init(rl.Vector2{
        .x = risk_origin.x,
        .y = Amin.pos.y + ctx.state.terrainValues.f,
    });
    f.rotate(risk_origin, angle);
    f.addText("f", -70, 0, 40, rl.Color.black, ctx.state.config.showText);

    // hv
    const hv: geo.Semicircle = geo.Semicircle.init(
        rl.Color.red,
        -1600 + angle,
        -1600 + angle + ctx.state.weaponValues.v,
        ctx.state.terrainValues.h,
        risk_origin,
        10,
    );

    //c
    var c: geo.Line = try v.getParallelLine(ctx.state.weaponValues.c);

    // ch
    var ch: geo.Line = geo.Line.init(rl.Vector2{
        .x = v.end.x,
        .y = v.end.y,
    }, rl.Vector2{
        .x = v.end.x - 100.0,
        .y = v.end.y - 1000.0,
    });
    ch.rotate(.End, angle + 3200.0 - ctx.state.terrainValues.ch);
    ch.addText("ch", -5, -20, 40, rl.Color.black, ch.end, ctx.state.config.showText);
    ch.end = ch.getIntersectionPoint(c).?;

    // q1
    var q1: geo.Line = geo.Line.init(rl.Vector2{
        .x = trig.triangleOppositeLeg(ctx.state.terrainValues.Amin - ctx.state.terrainValues.f, angle + ctx.state.weaponValues.v) + risk_origin.x,
        .y = risk_origin.y - ctx.state.terrainValues.Amin + ctx.state.terrainValues.f,
    }, rl.Vector2{
        .x = v.end.x,
        .y = v.end.y,
    });
    q1.rotate(.End, ctx.state.terrainValues.q1);
    q1.addText("q1", 15, 0, 40, rl.Color.black, q1.end, ctx.state.config.showText);

    // q2
    var q2: geo.Line = geo.Line.init(rl.Vector2{
        .x = trig.triangleOppositeLeg(ctx.state.terrainValues.forestDist, angle + ctx.state.weaponValues.v) + risk_origin.x,
        .y = risk_origin.y - ctx.state.terrainValues.forestDist,
    }, rl.Vector2{
        .x = v.end.x,
        .y = v.end.y,
    });
    q2.rotate(.End, ctx.state.terrainValues.q2);
    q2.addText("q2", 25, 0, 40, rl.Color.black, q2.end, ctx.state.config.showText);

    // forestMin
    var forestMin: geo.Point = geo.Point.init(rl.Vector2{
        .x = risk_origin.x,
        .y = Amin.pos.y - ctx.state.terrainValues.forestDist,
    });
    forestMin.rotate(risk_origin, angle);
    forestMin.addText("forestMin", -220, 0, 40, rl.Color.black, ctx.state.config.showText);

    // q
    var q: geo.Line = if (ctx.state.terrainValues.forestDist > 0) q2 else q1;
    q.end = q.getIntersectionPoint(c).?;

    v.end = v.getIntersectionPoint(q).?;
    c.end = c.getIntersectionPoint(ch).?;
    c.start = c.getIntersectionPoint(q).?;

    try ctx.draw_buffer.append(geo.Shape{ .Line = h });
    try ctx.draw_buffer.append(geo.Shape{ .Line = v });
    try ctx.draw_buffer.append(geo.Shape{ .Line = ch });
    try ctx.draw_buffer.append(geo.Shape{ .Line = c });
    try ctx.draw_buffer.append(geo.Shape{ .Line = q });
    try ctx.draw_buffer.append(geo.Shape{ .Semicircle = hv });
    try ctx.draw_buffer.append(geo.Shape{ .Point = Amin });
    try ctx.draw_buffer.append(geo.Shape{ .Point = f });
    try ctx.draw_buffer.append(geo.Shape{ .Point = forestMin });
}

pub fn drawSST(ctx: *Context) !void {
    const risk_origin_h = rl.Vector2{ .x = origin.x + (ctx.state.sst.width / 2), .y = origin.y };
    const risk_origin_v = rl.Vector2{ .x = origin.x - (ctx.state.sst.width / 2), .y = origin.y };
    const angle = ctx.state.sst.hh;

    const sst_b = geo.Line.init(rl.Vector2{
        .x = origin.x - (ctx.state.sst.width / 2),
        .y = origin.y,
    }, rl.Vector2{
        .x = origin.x + (ctx.state.sst.width / 2),
        .y = origin.y,
    });

    try ctx.draw_buffer.append(geo.Shape{ .Line = sst_b });

    // h2
    var h_h: geo.Line = geo.Line.init(rl.Vector2{
        .x = risk_origin_v.x,
        .y = risk_origin_v.y,
    }, rl.Vector2{
        .x = risk_origin_v.x,
        .y = risk_origin_v.y - ctx.state.terrainValues.h,
    });
    h_h.rotate(.End, -angle);
    h_h.addText("h", -20, 0, 40, rl.Color.black, h_h.end, ctx.state.config.showText);

    // v2
    var v_h: geo.Line = geo.Line.init(rl.Vector2{
        .x = risk_origin_v.x,
        .y = risk_origin_v.y,
    }, rl.Vector2{
        .x = risk_origin_v.x,
        .y = risk_origin_v.y - ctx.state.terrainValues.h,
    });
    v_h.rotate(.End, -angle - ctx.state.weaponValues.v);
    v_h.addText("v", -5, -30, 40, rl.Color.black, v_h.end, ctx.state.config.showText);

    // Amin2
    var Amin_h: geo.Line = geo.Line.init(rl.Vector2{
        .x = risk_origin_v.x,
        .y = risk_origin_v.y,
    }, rl.Vector2{
        .x = risk_origin_v.x,
        .y = risk_origin_v.y - ctx.state.terrainValues.Amin,
    });
    Amin_h.rotate(.End, angle);
    Amin_h.addText("Amin", -100, 0, 40, rl.Color.black, Amin_h.end, ctx.state.config.showText);

    // hv2
    const hv_h: geo.Semicircle = geo.Semicircle.init(
        rl.Color.red,
        -1600 - angle,
        -1600 - angle - ctx.state.weaponValues.v,
        ctx.state.terrainValues.h,
        risk_origin_v,
        10,
    );

    //c2
    var c_h: geo.Line = try v_h.getParallelLine(-ctx.state.weaponValues.c);

    // ch2
    var ch_h: geo.Line = geo.Line.init(rl.Vector2{
        .x = v_h.end.x,
        .y = v_h.end.y,
    }, rl.Vector2{
        .x = v_h.end.x + 100.0,
        .y = v_h.end.y - 1000.0,
    });
    ch_h.rotate(.End, -angle - 3200.0 + ctx.state.terrainValues.ch);
    ch_h.addText("ch", -5, -20, 40, rl.Color.black, ch_h.end, ctx.state.config.showText);
    ch_h.end = ch_h.getIntersectionPoint(c_h).?;

    // q1
    // var q1_h: geo.Line = geo.Line.init(rl.Vector2{
    //     .x = trig.triangleOppositeLeg(ctx.state.terrainValues.Amin - ctx.state.terrainValues.f, -angle - ctx.state.weaponValues.v) - risk_origin_v.x,
    //     .y = risk_origin_v.y - ctx.state.terrainValues.Amin + ctx.state.terrainValues.f,
    // }, rl.Vector2{
    //     .x = v_h.end.x,
    //     .y = v_h.end.y,
    // });
    // q1_h.rotate(.End, ctx.state.terrainValues.q1);
    // q1_h.addText("q1", 15, 0, 40, rl.Color.black, q1_h.end, ctx.state.config.showText);

    // q2
    var q2_h: geo.Line = geo.Line.init(rl.Vector2{
        .x = trig.triangleOppositeLeg(ctx.state.terrainValues.forestDist, -angle - ctx.state.weaponValues.v) - risk_origin_v.x,
        .y = risk_origin_v.y - ctx.state.terrainValues.forestDist,
    }, rl.Vector2{
        .x = v_h.end.x,
        .y = v_h.end.y,
    });
    q2_h.rotate(.End, ctx.state.terrainValues.q2);
    q2_h.addText("q2", 25, 0, 40, rl.Color.black, q2_h.end, ctx.state.config.showText);

    // forestMin
    var forestMin_h: geo.Line = geo.Line.init(rl.Vector2{
        .x = undefined,
        .y = undefined,
    }, rl.Vector2{
        .x = risk_origin_v.x,
        .y = risk_origin_v.y - ctx.state.terrainValues.forestDist,
    });
    forestMin_h.addText("forestMin", -220, 0, 40, rl.Color.black, forestMin_h.end, ctx.state.config.showText);

    // q
    // var q_h: geo.Line = if (ctx.state.terrainValues.forestDist > 0) q2_h else q1_h;
    var q_h: geo.Line = q2_h;
    q_h.end = q2_h.getIntersectionPoint(c_h).?;

    v_h.end = v_h.getIntersectionPoint(q_h).?;
    c_h.end = c_h.getIntersectionPoint(ch_h).?;
    c_h.start = c_h.getIntersectionPoint(q_h).?;

    // // hv3
    // var hv3: geo.Semicircle = geo.Semicircle.init(
    //     rl.Color.red,
    //     -1600 - angle,
    //     -1600 + angle + ctx.state.weaponValues.v,
    //     ctx.state.terrainValues.h,
    //     risk_origin,
    //     10,
    // );

    //

    // h
    var h: geo.Line = geo.Line.init(rl.Vector2{
        .x = risk_origin_h.x,
        .y = risk_origin_h.y,
    }, rl.Vector2{
        .x = risk_origin_h.x,
        .y = risk_origin_h.y - ctx.state.terrainValues.h,
    });
    h.rotate(.End, angle);
    h.addText("h", -20, 0, 40, rl.Color.black, h.end, ctx.state.config.showText);

    // Amin
    var Amin: geo.Line = geo.Line.init(rl.Vector2{
        .x = risk_origin_h.x,
        .y = risk_origin_h.y,
    }, rl.Vector2{
        .x = risk_origin_h.x,
        .y = risk_origin_h.y - ctx.state.terrainValues.Amin,
    });
    Amin.rotate(.End, angle);
    Amin.addText("Amin", -100, 0, 40, rl.Color.black, Amin.end, ctx.state.config.showText);

    // v
    var v: geo.Line = geo.Line.init(rl.Vector2{
        .x = risk_origin_h.x,
        .y = risk_origin_h.y,
    }, rl.Vector2{
        .x = risk_origin_h.x,
        .y = risk_origin_h.y - ctx.state.terrainValues.h,
    });
    v.rotate(.End, angle + ctx.state.weaponValues.v);
    v.addText("v", -5, -30, 40, rl.Color.black, v.end, ctx.state.config.showText);

    var f: geo.Line = geo.Line.init(rl.Vector2{
        .x = risk_origin_h.x,
        .y = risk_origin_h.y - ctx.state.terrainValues.Amin + ctx.state.terrainValues.f,
    }, rl.Vector2{
        .x = risk_origin_h.x,
        .y = Amin.end.y + ctx.state.terrainValues.f,
    });
    f.addText("f", -70, 0, 40, rl.Color.black, f.end, ctx.state.config.showText);

    // hv
    const hv: geo.Semicircle = geo.Semicircle.init(
        rl.Color.red,
        -1600 + angle,
        -1600 + angle + ctx.state.weaponValues.v,
        ctx.state.terrainValues.h,
        risk_origin_h,
        10,
    );

    //c
    var c: geo.Line = try v.getParallelLine(ctx.state.weaponValues.c);

    // ch
    var ch: geo.Line = geo.Line.init(rl.Vector2{
        .x = v.end.x,
        .y = v.end.y,
    }, rl.Vector2{
        .x = v.end.x - 100.0,
        .y = v.end.y - 1000.0,
    });
    ch.rotate(.End, angle + 3200.0 - ctx.state.terrainValues.ch);
    ch.addText("ch", -5, -20, 40, rl.Color.black, ch.end, ctx.state.config.showText);
    ch.end = ch.getIntersectionPoint(c).?;

    // q1
    var q1: geo.Line = geo.Line.init(rl.Vector2{
        .x = trig.triangleOppositeLeg(ctx.state.terrainValues.Amin - ctx.state.terrainValues.f, angle + ctx.state.weaponValues.v) + risk_origin_h.x,
        .y = risk_origin_h.y - ctx.state.terrainValues.Amin + ctx.state.terrainValues.f,
    }, rl.Vector2{
        .x = v.end.x,
        .y = v.end.y,
    });
    q1.rotate(.End, ctx.state.terrainValues.q1);
    q1.addText("q1", 15, 0, 40, rl.Color.black, q1.end, ctx.state.config.showText);

    // q2
    var q2: geo.Line = geo.Line.init(rl.Vector2{
        .x = trig.triangleOppositeLeg(ctx.state.terrainValues.forestDist, angle + ctx.state.weaponValues.v) + risk_origin_h.x,
        .y = risk_origin_h.y - ctx.state.terrainValues.forestDist,
    }, rl.Vector2{
        .x = v.end.x,
        .y = v.end.y,
    });
    q2.rotate(.End, ctx.state.terrainValues.q2);
    q2.addText("q2", 25, 0, 40, rl.Color.black, q2.end, ctx.state.config.showText);

    // forestMin
    var forestMin: geo.Line = geo.Line.init(rl.Vector2{
        .x = undefined,
        .y = undefined,
    }, rl.Vector2{
        .x = risk_origin_h.x,
        .y = risk_origin_h.y - ctx.state.terrainValues.forestDist,
    });
    forestMin.addText("forestMin", -220, 0, 40, rl.Color.black, forestMin.end, ctx.state.config.showText);

    // q
    var q: geo.Line = if (ctx.state.terrainValues.forestDist > 0) q2 else q1;
    q.end = q.getIntersectionPoint(c).?;

    v.end = v.getIntersectionPoint(q).?;
    c.end = c.getIntersectionPoint(ch).?;
    c.start = c.getIntersectionPoint(q).?;

    try ctx.draw_buffer.append(geo.Shape{ .Line = h_h });
    try ctx.draw_buffer.append(geo.Shape{ .Line = v_h });
    try ctx.draw_buffer.append(geo.Shape{ .Semicircle = hv_h });
    try ctx.draw_buffer.append(geo.Shape{ .Line = c_h });
    try ctx.draw_buffer.append(geo.Shape{ .Line = q_h });
    try ctx.draw_buffer.append(geo.Shape{ .Line = ch_h });

    try ctx.draw_buffer.append(geo.Shape{ .Line = h });
    try ctx.draw_buffer.append(geo.Shape{ .Line = v });
    try ctx.draw_buffer.append(geo.Shape{ .Line = ch });
    try ctx.draw_buffer.append(geo.Shape{ .Line = c });
    try ctx.draw_buffer.append(geo.Shape{ .Line = q });
    try ctx.draw_buffer.append(geo.Shape{ .Semicircle = hv });
    // try ctx.draw_buffer.append(geo.Shape{ .Point = Amin });
    // try ctx.draw_buffer.append(geo.Shape{ .Point = f });
    // try ctx.draw_buffer.append(geo.Shape{ .Point = forestMin });
}

pub fn drawBox(ctx: *Context) !void {
    const box_b = geo.Line.init(rl.Vector2{
        .x = origin.x - (ctx.state.box.width / 2),
        .y = origin.y,
    }, rl.Vector2{
        .x = origin.x + (ctx.state.box.width / 2),
        .y = origin.y,
    });

    const box_t = geo.Line.init(rl.Vector2{
        .x = origin.x - (ctx.state.box.width / 2),
        .y = origin.y - ctx.state.box.length,
    }, rl.Vector2{
        .x = origin.x + (ctx.state.box.width / 2),
        .y = origin.y - ctx.state.box.length,
    });

    const box_r = geo.Line.init(rl.Vector2{
        .x = origin.x + (ctx.state.box.width / 2),
        .y = origin.y,
    }, rl.Vector2{
        .x = origin.x + (ctx.state.box.width / 2),
        .y = origin.y - ctx.state.box.length,
    });

    const box_l = geo.Line.init(rl.Vector2{
        .x = origin.x - (ctx.state.box.width / 2),
        .y = origin.y,
    }, rl.Vector2{
        .x = origin.x - (ctx.state.box.width / 2),
        .y = origin.y - ctx.state.box.length,
    });

    try ctx.draw_buffer.append(geo.Shape{ .Line = box_b });
    try ctx.draw_buffer.append(geo.Shape{ .Line = box_t });
    try ctx.draw_buffer.append(geo.Shape{ .Line = box_r });
    try ctx.draw_buffer.append(geo.Shape{ .Line = box_l });

    try drawRisk(ctx, .{
        .x = origin.x + (ctx.state.box.width / 2),
        .y = origin.y,
    }, ctx.state.box.h);

    try drawRisk(ctx, .{
        .x = origin.x + (ctx.state.box.width / 2),
        .y = origin.y - ctx.state.box.length,
    }, ctx.state.box.h);
}

pub fn drawRisk(ctx: *Context, risk_origin: rl.Vector2, angle: f32) !void {
    // h
    var h: geo.Line = geo.Line.init(rl.Vector2{
        .x = risk_origin.x,
        .y = risk_origin.y,
    }, rl.Vector2{
        .x = risk_origin.x,
        .y = risk_origin.y - ctx.state.terrainValues.h,
    });
    h.rotate(.End, angle);
    h.addText("h", -20, 0, 40, rl.Color.black, h.end, ctx.state.config.showText);

    // Amin
    var Amin: geo.Point = geo.Point.init(rl.Vector2{
        .x = risk_origin.x,
        .y = risk_origin.y - ctx.state.terrainValues.Amin,
    });
    Amin.rotate(risk_origin, angle);
    Amin.addText("Amin", -100, 0, 40, rl.Color.black, ctx.state.config.showText);

    // v
    var v: geo.Line = geo.Line.init(rl.Vector2{
        .x = risk_origin.x,
        .y = risk_origin.y,
    }, rl.Vector2{
        .x = risk_origin.x,
        .y = risk_origin.y - ctx.state.terrainValues.h,
    });
    v.rotate(.End, angle + ctx.state.weaponValues.v);
    v.addText("v", -5, -30, 40, rl.Color.black, v.end, ctx.state.config.showText);

    // f
    var f: geo.Point = geo.Point.init(rl.Vector2{
        .x = risk_origin.x,
        .y = Amin.pos.y + ctx.state.terrainValues.f,
    });
    f.rotate(risk_origin, angle);
    f.addText("f", -70, 0, 40, rl.Color.black, ctx.state.config.showText);

    // hv
    const hv: geo.Semicircle = geo.Semicircle.init(
        rl.Color.red,
        -1600 + angle,
        -1600 + angle + ctx.state.weaponValues.v,
        ctx.state.terrainValues.h,
        risk_origin,
        10,
    );

    //c
    var c: geo.Line = try v.getParallelLine(ctx.state.weaponValues.c);

    // ch
    var ch: geo.Line = geo.Line.init(rl.Vector2{
        .x = v.end.x,
        .y = v.end.y,
    }, rl.Vector2{
        .x = v.end.x - 100.0,
        .y = v.end.y - 1000.0,
    });
    ch.rotate(.End, angle + 3200.0 - ctx.state.terrainValues.ch);
    ch.addText("ch", -5, -20, 40, rl.Color.black, ch.end, ctx.state.config.showText);
    ch.end = ch.getIntersectionPoint(c).?;

    // q1
    var q1: geo.Line = geo.Line.init(rl.Vector2{
        .x = trig.triangleOppositeLeg(ctx.state.terrainValues.Amin - ctx.state.terrainValues.f, angle + ctx.state.weaponValues.v) + risk_origin.x,
        .y = risk_origin.y - ctx.state.terrainValues.Amin + ctx.state.terrainValues.f,
    }, rl.Vector2{
        .x = v.end.x,
        .y = v.end.y,
    });
    q1.rotate(.End, ctx.state.terrainValues.q1);
    q1.addText("q1", 15, 0, 40, rl.Color.black, q1.end, ctx.state.config.showText);

    // q2
    var q2: geo.Line = geo.Line.init(rl.Vector2{
        .x = trig.triangleOppositeLeg(ctx.state.terrainValues.forestDist, angle + ctx.state.weaponValues.v) + risk_origin.x,
        .y = risk_origin.y - ctx.state.terrainValues.forestDist,
    }, rl.Vector2{
        .x = v.end.x,
        .y = v.end.y,
    });
    q2.rotate(.End, ctx.state.terrainValues.q2);
    q2.addText("q2", 25, 0, 40, rl.Color.black, q2.end, ctx.state.config.showText);

    // forestMin
    var forestMin: geo.Point = geo.Point.init(rl.Vector2{
        .x = risk_origin.x,
        .y = Amin.pos.y - ctx.state.terrainValues.forestDist,
    });
    forestMin.rotate(risk_origin, angle);
    forestMin.addText("forestMin", -220, 0, 40, rl.Color.black, ctx.state.config.showText);

    // q
    var q: geo.Line = if (ctx.state.terrainValues.forestDist > 0) q2 else q1;
    q.end = q.getIntersectionPoint(c).?;

    v.end = v.getIntersectionPoint(q).?;
    c.end = c.getIntersectionPoint(ch).?;
    c.start = c.getIntersectionPoint(q).?;

    try ctx.draw_buffer.append(geo.Shape{ .Line = h });
    try ctx.draw_buffer.append(geo.Shape{ .Line = v });
    try ctx.draw_buffer.append(geo.Shape{ .Line = ch });
    try ctx.draw_buffer.append(geo.Shape{ .Line = c });
    try ctx.draw_buffer.append(geo.Shape{ .Line = q });
    try ctx.draw_buffer.append(geo.Shape{ .Semicircle = hv });
    try ctx.draw_buffer.append(geo.Shape{ .Point = Amin });
    try ctx.draw_buffer.append(geo.Shape{ .Point = f });
    try ctx.draw_buffer.append(geo.Shape{ .Point = forestMin });
}
