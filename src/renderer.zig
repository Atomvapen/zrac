const zgui = @import("zgui");
const zgpu = @import("zgpu");
const zglfw = @import("zglfw");
const Context = @import("Context.zig");

pub fn beginFrame(ctx: *Context) void {
    zglfw.pollEvents();

    zgui.backend.newFrame(
        ctx.gctx.swapchain_descriptor.width,
        ctx.gctx.swapchain_descriptor.height,
    );
}

pub fn update(ctx: *Context) void {
    Context.Window.Drag.handle(ctx.window);
    if (ctx.modal == null) ctx.camera.update(ctx);

    ctx.grid.draw(ctx, 1);
    ctx.grid.addLine(ctx, .{ 10.0, 10.0 }, .{ 50.0, 50.0 }, 0xFFFF0000, 2);
    ctx.grid.addRect(ctx, .{ 10.0, 10.0 }, .{ 50.0, 50.0 }, 0xFF00FF00, 5.0, 2.0);
    ctx.grid.addCircle(ctx, .{ 20.0, 20.0 }, 15.0, 0xFF0000FF);
    ctx.grid.addCircleSector(ctx, .{ 100.0, 100.0 }, 50.0, 0xFF00FF00, 0.0, 3.14159, 2);
    ctx.grid.addCircleSector(ctx, .{ 100.0, 100.0 }, 50.0, 0xFFFF0000, 3.14159, 6.28319, 2);

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
