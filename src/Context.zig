const Self = @This();
const std = @import("std");
const zgui = @import("zgui");
const zgpu = @import("zgpu");
const zglfw = @import("zglfw");

pub const Window = @import("gui/Window.zig");
const Camera2D = @import("gui/Camera.zig");
const Grid = @import("gui/Grid.zig");
const ContextMenu = @import("gui/ContextMenu.zig");
const Modal = @import("gui/Modal.zig");
const Frame = @import("gui/Frame.zig");

const CreateContextError = error{
    FailedToCreateGraphicsContext,
    OutOfMemory,
} || Window.CreateWindowError;

gctx: *zgpu.GraphicsContext,
draw_list: zgui.DrawList,
allocator: std.mem.Allocator,
window: *zglfw.Window,
camera: Camera2D,
grid: Grid,
contextMenu: ContextMenu,
modal: ?Modal,
frames: Frame,
state: State,

pub fn create(allocator: std.mem.Allocator) CreateContextError!*Self {
    std.log.info("[zrac] Creating Context", .{});
    std.log.info("[zrac]   Creating context object", .{});
    const context: *Self = allocator.create(Self) catch return CreateContextError.OutOfMemory;

    std.log.info("[zrac]   Creating window", .{});
    const window: *zglfw.Window = try Window.init(context);
    errdefer window.destroy();

    std.log.info("[zrac]   Creating Graphics Context", .{});
    const gctx: *zgpu.GraphicsContext = zgpu.GraphicsContext.create(allocator, .{
        .window = window,
        .fn_getTime = @ptrCast(&zglfw.getTime),
        .fn_getFramebufferSize = @ptrCast(&zglfw.Window.getFramebufferSize),
        .fn_getWin32Window = @ptrCast(&zglfw.getWin32Window),
        .fn_getX11Display = @ptrCast(&zglfw.getX11Display),
        .fn_getX11Window = @ptrCast(&zglfw.getX11Window),
        .fn_getWaylandDisplay = @ptrCast(&zglfw.getWaylandDisplay),
        .fn_getWaylandSurface = @ptrCast(&zglfw.getWaylandWindow),
        .fn_getCocoaWindow = @ptrCast(&zglfw.getCocoaWindow),
    }, .{}) catch return CreateContextError.FailedToCreateGraphicsContext;
    errdefer gctx.destroy(allocator);

    std.log.info("[zrac]   Initializing ZGUI", .{});
    zgui.init(allocator);
    errdefer zgui.deinit();

    std.log.info("[zrac]   Initializing ZGUI backend", .{});
    zgui.backend.init(
        window,
        gctx.device,
        @intFromEnum(zgpu.GraphicsContext.swapchain_format),
        @intFromEnum(zgpu.wgpu.TextureFormat.undef),
    );
    errdefer zgui.backend.deinit();

    std.log.info("[zrac]   Setting ZGUI style", .{});
    const scale: [2]f32 = window.getContentScale();
    const scale_factor: f32 = if (scale[0] > scale[1]) scale[0] else scale[1];
    const style: *zgui.Style = zgui.getStyle();
    style.scaleAllSizes(scale_factor);

    std.log.info("[zrac]   Settings context object fields", .{});
    context.* = .{
        .gctx = gctx,
        .draw_list = zgui.createDrawList(),
        .allocator = allocator,
        .window = window,
        .camera = .{},
        .grid = Grid.init(40, 100),
        .contextMenu = .{},
        .modal = null,
        .frames = .{},
        .state = .{},
    };
    errdefer context.destroy(allocator);

    return context;
}

pub fn destroy(self: *Self, allocator: std.mem.Allocator) void {
    std.log.info("[zrac] Destroying Context", .{});
    std.log.info("[zrac]   Destroying window", .{});
    self.window.destroy();
    std.log.info("[zrac]   Deinitializing ZGUI backend", .{});
    zgui.backend.deinit();
    std.log.info("[zrac]   Destroying drawlist", .{});
    zgui.destroyDrawList(self.draw_list);
    std.log.info("[zrac]   Deinitializing ZGUI", .{});
    zgui.deinit();
    std.log.info("[zrac]   Destroying Graphics Context", .{});
    self.gctx.destroy(allocator);
    std.log.info("[zrac]   Destroying Context object", .{});
    allocator.destroy(self);
}

pub const State = struct {
    const RenderMode = enum { Half, SST, Box };
    const weapon = @import("data/weapon.zig");
    const ammunition = @import("data/ammunition.zig");
    const risk = @import("math/risk.zig");
    const Config = struct {
        show: bool = true,
        valid: bool = false,
        sort: enum { Box, SST, Halva } = .Halva,
        showText: bool = false,
    };
    const TerrainValues = struct {
        interceptingForest: bool = false,
        factor: enum { I, II, III } = .I,
        Amin: f32 = 100,
        Amax: f32 = 200,
        f: f32 = 50,
        forestDist: f32 = 300,
        l: f32 = 0,
        h: f32 = 0,
        q1: f32 = 0,
        q2: f32 = 0,
        ch: f32 = 1000,
    };
    const WeaponValues = struct {
        weapon_enum_value: weapon.Models = .P88,
        target: enum { Fast, Flyttbart } = .Fast,
        model: weapon.Model = .EHV,
        caliber: ammunition.Caliber = .ptr9_sk_39b,
        v: f32 = 0,
        amm556: ammunition.Calibers.ptr556 = .ptr556_sk_prj_slprj,
        amm762: ammunition.Calibers.ptr762 = .ptr762_sk_10_pprj,
        amm9: ammunition.Calibers.ptr9 = .ptr9_sk_39b,
        amm127: ammunition.Calibers.ptr127 = .ptr127_sk_45_nprj_slnprj,
        support: bool = false,
        c: f32 = 0,
    };
    const Box = struct {
        length: f32 = 100,
        width: f32 = 50,
        h: f32 = 300,
        v: f32 = 300,
    };
    const SST = struct {
        width: f32 = 50,
        hh: f32 = 100,
        hv: f32 = 100,
        vv: f32 = 100,
        vh: f32 = 100,
    };

    renderMode: RenderMode = .Half,
    showLines: bool = true,
    showText: bool = false,
    valid: bool = false,

    terrainValues: TerrainValues = TerrainValues{},
    weaponValues: WeaponValues = WeaponValues{},
    config: Config = Config{},
    box: Box = Box{},
    sst: SST = SST{},

    pub fn reset(self: *State) void {
        self.terrainValues = TerrainValues{};
        self.weaponValues = WeaponValues{};
        self.config = Config{};
        self.box = Box{};
        self.sst = SST{};
    }

    pub fn validate(self: *State) bool {
        return Validate.validate(self);
    }

    pub fn update(self: *State) void {
        self.weaponValues.caliber = switch (self.weaponValues.weapon_enum_value) {
            .AK5, .KSP90 => ammunition.Calibers.getCaliber(.{ .ptr556 = self.weaponValues.amm556 }),
            .KSP58 => ammunition.Calibers.getCaliber(.{ .ptr762 = self.weaponValues.amm762 }),
            .KSP88, .AG90 => ammunition.Calibers.getCaliber(.{ .ptr127 = self.weaponValues.amm127 }),
            .P88 => ammunition.Calibers.getCaliber(.{ .ptr9 = self.weaponValues.amm9 }),
        };

        self.terrainValues.l = risk.calculateL(self.*);
        self.terrainValues.h = risk.calculateH(self.*);
        self.terrainValues.q1 = risk.calculateQ1(self.*);
        self.terrainValues.q2 = risk.calculateQ2(self.*);
        self.weaponValues.c = risk.calculateC(self.*);
        self.weaponValues.model = self.weaponValues.weapon_enum_value.getModel(self.weaponValues.support);
        self.weaponValues.v = if (self.weaponValues.target == .Fast) self.weaponValues.model.v_still else self.weaponValues.model.v_moveable;

        self.config.valid = self.validate();
    }

    const Validate = struct {
        pub fn validate(state: *State) bool {
            if (!state.config.show) return false;
            if (!validateZeroValues(state)) return false;
            if (!validateRangeConditions(state)) return false;
            if (!validateNegativeValues(state)) return false;
            if (!validateOverflow(state)) return false;
            switch (state.config.sort) {
                .Box => if (!validateBox(state)) return false,
                .SST => if (!validateSST(state)) return false,
                .Halva => return true,
            }

            return true;
        }

        fn validateBox(state: *State) bool {
            return (state.box.length > 0 and
                state.box.width > 0 and
                state.box.v > 0 and
                state.box.h > 0);
        }

        fn validateSST(state: *State) bool {
            return (state.sst.width > 0 and
                state.sst.hh > 0 and
                state.sst.hv > 0 and
                state.sst.vv > 0 and
                state.sst.vh > 0);
        }

        fn validateZeroValues(state: *State) bool {
            return (state.terrainValues.Amax != 0 and
                state.terrainValues.h != 0 and
                state.terrainValues.l != 0 and
                state.weaponValues.v != 0);
        }

        fn validateRangeConditions(state: *State) bool {
            return (state.terrainValues.Amin < state.terrainValues.Amax and
                state.terrainValues.f < state.terrainValues.Amax and
                state.terrainValues.f < state.terrainValues.Amin and
                state.terrainValues.forestDist < state.terrainValues.h);
        }

        fn validateNegativeValues(state: *State) bool {
            return (state.terrainValues.Amax >= 0 and
                state.terrainValues.Amin >= 0 and
                state.terrainValues.f >= 0 and
                state.terrainValues.l >= 0 and
                state.terrainValues.h >= 0 and
                state.terrainValues.forestDist >= 0);
        }

        fn validateOverflow(state: *State) bool {
            const max = std.math.floatMax(f32);
            return (state.terrainValues.Amax < max and
                state.terrainValues.Amin < max and
                state.terrainValues.f < max and
                state.terrainValues.forestDist < max);
        }
    };
};
