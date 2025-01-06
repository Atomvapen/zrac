const std = @import("std");

pub fn build(b: *std.Build) void {
    const exe = b.addExecutable(.{
        .name = "ZRAC",
        .root_source_file = b.path("src/main.zig"),
        .target = b.standardTargetOptions(.{}),
        .optimize = b.standardOptimizeOption(.{}),
    });

    // const math = b.addModule("math", .{ .root_source_file = b.path("libs/math/main.zig") });
    // exe.root_module.addImport("math", math);

    // const data = b.addModule("data", .{ .root_source_file = b.path("libs/data/main.zig") });
    // exe.root_module.addImport("data", data);

    const zgui = b.dependency("zgui", .{});
    exe.root_module.addImport("zgui", zgui.module("root"));
    exe.linkLibrary(zgui.artifact("imgui"));

    const rl = b.dependency("raylib-zig", .{});
    exe.root_module.addImport("raylib", rl.module("raylib"));
    exe.linkLibrary(rl.artifact("raylib"));
    // math.addImport("raylib", rl.module("raylib"));

    const install_exe = b.addInstallArtifact(exe, .{});
    b.getInstallStep().dependOn(&install_exe.step);
    b.step("build", "Build").dependOn(&install_exe.step);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(&install_exe.step);
    b.step("run", "Run").dependOn(&run_cmd.step);
}
