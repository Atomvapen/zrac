// Taken from raylib-extras rlImGui examples
// https://github.com/raylib-extras/rlImGui/tree/main/examples

const std = @import("std");
const rl = @import("raylib");
const zgui = @import("zgui");

var quit = false;

const Config = struct {
    var show: bool = false;
};

var guiState = @import("../data/state.zig").RiskProfile.init();

const ImageViewerWindow = struct {
    const Self = @This();

    open: bool = false,

    fn show(self: *Self) !void {
        zgui.pushStyleVar2f(.{ .idx = .window_padding, .v = .{ 10, 10 } });
        zgui.setNextWindowSize(.{ .w = 800, .h = 800, .cond = .once });
        zgui.setNextWindowPos(.{ .x = 20.0, .y = 40.0, .cond = .once });

        if (zgui.begin("Riskprofil", .{
            .popen = &self.open,
            .flags = .{
                .no_scrollbar = true,
                .no_scroll_with_mouse = true,
                // .no_move = true,
                .no_resize = true,
                .always_auto_resize = true,
                .no_collapse = true,
            },
        })) {
            { // Show
                _ = zgui.checkbox("Visa", .{ .v = &Config.show });
            }

            zgui.separatorText("Terrängvärden");
            { // Values
                _ = zgui.comboFromEnum("Faktor", &guiState.terrainValues.factor);
                _ = zgui.inputFloat("Amin", .{ .v = &guiState.terrainValues.Amin });
                _ = zgui.inputFloat("Amax", .{ .v = &guiState.terrainValues.Amax });
                _ = zgui.inputFloat("f", .{ .v = &guiState.terrainValues.f });
                zgui.setNextItemWidth(93);
                _ = zgui.inputFloat("Skogsavstånd", .{ .v = &guiState.terrainValues.forestDist });
                zgui.sameLine(.{});
                _ = zgui.checkbox("Uppfångande", .{ .v = &guiState.terrainValues.interceptingForest });
            }

            zgui.separatorText("Vapenvärden");
            { // Weapons & Ammunition Comboboxes
                zgui.setNextItemWidth(121);
                _ = zgui.comboFromEnum("Vapentyp", &guiState.weaponValues.weapon_enum_value);
                zgui.sameLine(.{});
                _ = zgui.checkbox("Benstöd", .{ .v = &guiState.weaponValues.stead });

                // _ = zgui.comboFromEnum("Ammunitionstyp", &guiState.weaponValues.amm_enum_values);
                // TODO fixa

                // _ = zgui.comboFromEnum("Ammunitionstyp", switch (guiState.weaponValues.weapon_enum_value) {
                //     .AK5, .KSP90 => &guiState.amm556,
                //     .KSP58 => &guiState.ammK762,
                //     .KSP88 => &guiState.amm127,
                //     // else => _ = zgui.comboFromEnum("Ammunitionstyp", &guiState.weaponValues.amm_enum_values),
                // });

                switch (guiState.weaponValues.weapon_enum_value) {
                    .AK5, .KSP90 => _ = zgui.comboFromEnum("Ammunitionstyp", &guiState.weaponValues.amm556),
                    .KSP58 => _ = zgui.comboFromEnum("Ammunitionstyp", &guiState.weaponValues.amm762),
                    .KSP88 => _ = zgui.comboFromEnum("Ammunitionstyp", &guiState.weaponValues.amm127),
                    // else => _ = zgui.comboFromEnum("Ammunitionstyp", &guiState.weaponValues.amm_enum_values),
                }
                _ = zgui.comboFromEnum("Måltyp", &guiState.weaponValues.target);
            }

            zgui.end();
            zgui.popStyleVar(.{});

            rl.drawLine(
                100,
                100,
                400,
                400,
                rl.Color.maroon,
            );
        }
    }

    fn update(self: *Self) void {
        if (!self.open) return;

        // if (rl.isWindowResized()) {
        //     self.view_texture.unload();
        //     self.view_texture = rl.loadRenderTexture(rl.getScreenWidth(), rl.getScreenWidth());
        //     const widthf: f32 = @floatFromInt(rl.getScreenWidth());
        //     const heightf: f32 = @floatFromInt(rl.getScreenHeight());
        //     self.camera.offset.x = widthf / 2.0;
        //     self.camera.offset.y = heightf / 2.0;
        // }

        // const mouse_pos = rl.getMousePosition();

        // if (self.focused) {
        //     if (self.current_tool_mode == .move) {
        //         // only when in content area
        //         if (rl.isMouseButtonDown(.mouse_button_left) and rl.checkCollisionPointRec(mouse_pos, self.content_rect)) {
        //             if (!self.dragging) {
        //                 self.last_mouse_pos = mouse_pos;
        //                 self.last_target = self.camera.target;
        //             }
        //             self.dragging = true;
        //             var mouse_delta = self.last_mouse_pos.subtract(mouse_pos);

        //             mouse_delta.x /= self.camera.zoom;
        //             mouse_delta.y /= self.camera.zoom;
        //             self.camera.target = self.last_target.add(mouse_delta);

        //             self.dirty_scene = true;
        //         } else {
        //             self.dragging = false;
        //         }
        //     }
        // } else {
        //     self.dragging = false;
        // }

        // if (self.dirty_scene) {
        //     self.dirty_scene = false;
        //     self.updateRenderTexture();
        // }
    }

    // fn updateRenderTexture(self: Self) void {
    //     self.view_texture.begin();
    //     rl.clearBackground(rl.Color.blue);

    //     self.camera.begin();

    //     self.image_texture.draw(@divTrunc(self.image_texture.width, -2), @divTrunc(self.image_texture.height, -2), rl.Color.white);

    //     self.camera.end();
    //     self.view_texture.end();
    // }

    // fn shutdown(self: *Self) void {
    //     self.view_texture.unload();
    //     self.image_texture.unload();
    // }
};

// const SceneViewWindow = struct {
//     const Self = @This();

//     open: bool = false,
//     focused: bool = false,
//     view_texture: rl.RenderTexture,
//     content_rect: rl.Rectangle = std.mem.zeroes(rl.Rectangle),

//     camera: rl.Camera3D = std.mem.zeroes(rl.Camera3D),
//     grid_texture: rl.Texture = std.mem.zeroes(rl.Texture),

//     fn setup(self: *Self) void {
//         self.view_texture = rl.loadRenderTexture(rl.getScreenWidth(), rl.getScreenHeight());

//         self.camera.fovy = 45;
//         self.camera.up.y = 1;
//         self.camera.position.y = 3;
//         self.camera.position.z = -25;

//         const img = rl.genImageChecked(256, 256, 32, 32, rl.Color.dark_gray, rl.Color.white);
//         var grid_texture = rl.loadTextureFromImage(img);
//         img.unload();
//         rl.genTextureMipmaps(&grid_texture);
//         rl.setTextureFilter(grid_texture, .texture_filter_anisotropic_16x);
//         rl.setTextureWrap(grid_texture, .texture_wrap_clamp);
//     }

//     fn shutdown(self: *Self) void {
//         self.view_texture.unload();
//         self.grid_texture.unload();
//     }

//     fn show(self: *Self) void {
//         zgui.pushStyleVar2f(.{ .idx = .window_padding, .v = .{ 0, 0 } });
//         zgui.setNextWindowSize(.{ .w = 400, .h = 400, .cond = .once });

//         if (zgui.begin("3D View", .{ .popen = &self.open, .flags = .{ .no_scrollbar = true } })) {
//             self.focused = zgui.isWindowFocused(.{ .child_windows = true });
//             zgui.rlimgui.imageRenderTextureFit(&self.view_texture, true);
//         }
//         zgui.end();
//         zgui.popStyleVar(.{});
//     }

//     fn update(self: *Self) void {
//         if (!self.open) return;

//         if (rl.isWindowResized()) {
//             self.view_texture.unload();
//             self.view_texture = rl.loadRenderTexture(rl.getScreenWidth(), rl.getScreenHeight());
//         }

//         const period = 10.0;
//         const magnitude = 25.0;
//         const timef: f32 = @floatCast(rl.getTime());

//         self.camera.position.x = @sin(timef / period) * magnitude;

//         self.view_texture.begin();
//         rl.clearBackground(rl.Color.sky_blue);

//         self.camera.begin();

//         // draw world
//         rl.drawPlane(rl.Vector3.zero(), .{ .x = 50, .y = 50 }, rl.Color.beige);
//         const spacing = 4;
//         const count = 5;

//         var x: f32 = -count * spacing;
//         while (x <= count * spacing) : (x += spacing) {
//             var z: f32 = -count * spacing;
//             while (z <= count * spacing) : (z += spacing) {
//                 rl.drawCube(.{ .x = x, .y = 1.5, .z = z }, 1, 1, 1, rl.Color.green);
//                 rl.drawCube(.{ .x = x, .y = 0.5, .z = z }, 0.25, 1, 0.25, rl.Color.brown);
//             }
//         }

//         self.camera.end();
//         self.view_texture.end();
//     }
// };

var image_viewer: ImageViewerWindow = undefined;
// var scene_view: SceneViewWindow = undefined;

fn doMainMenu() void {
    if (zgui.beginMainMenuBar()) {
        if (zgui.beginMenu("Fil", true)) {
            if (zgui.menuItem("Avsluta", .{})) quit = true;

            zgui.endMenu();
        }

        if (zgui.beginMenu("Fönster", true)) {
            if (zgui.menuItem("Riskprofil", .{})) image_viewer.open = !image_viewer.open;

            zgui.endMenu();
        }
        zgui.endMainMenuBar();
    }
}

pub fn main() !void {
    const screen_width = 1280;
    const screen_height = 800;

    rl.setConfigFlags(.{ .msaa_4x_hint = true, .vsync_hint = true });
    rl.initWindow(screen_width, screen_height, "ZRAC");
    defer rl.closeWindow();
    rl.setTargetFPS(144);
    zgui.rlimgui.setup(true);
    defer zgui.rlimgui.shutdown();
    zgui.io.setConfigWindowsMoveFromTitleBarOnly(true);

    image_viewer.open = true;

    while (!rl.windowShouldClose() and !quit) {
        image_viewer.update();
        // scene_view.update();

        rl.beginDrawing();
        rl.clearBackground(rl.Color.dark_gray);

        zgui.rlimgui.begin();
        doMainMenu();

        if (image_viewer.open) try image_viewer.show();

        zgui.rlimgui.end();

        rl.endDrawing();
    }
}
