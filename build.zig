const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "ZRAC",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const reg = b.addModule("reg", .{ .root_source_file = b.path("src/reg.zig") });
    exe.root_module.addImport("reg", reg);
    reg.addImport("reg", reg);

    const zgui = b.dependency("zgui", .{});
    exe.root_module.addImport("zgui", zgui.module("root"));
    exe.linkLibrary(zgui.artifact("imgui"));
    reg.addImport("zgui", zgui.module("root"));

    const rl = b.dependency("raylib-zig", .{});
    exe.root_module.addImport("raylib", rl.module("raylib"));
    exe.linkLibrary(rl.artifact("raylib"));
    reg.addImport("raylib", rl.module("raylib"));

    const install_exe = b.addInstallArtifact(exe, .{});
    b.getInstallStep().dependOn(&install_exe.step);
    b.step("build", "Build").dependOn(&install_exe.step);

    // ZLS Build check
    const exe_check = b.addExecutable(.{
        .name = "ZRAC",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe_check.linkLibrary(zgui.artifact("imgui"));
    exe_check.root_module.addImport("reg", reg);

    // const check = b.step("check", "Check if ZRAC compiles");
    // check.dependOn(&exe_check.step);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(&install_exe.step);
    b.step("run", "Run").dependOn(&run_cmd.step);
}
