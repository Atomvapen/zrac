const std = @import("std");
const rl = @import("src/raylib-zig/build.zig");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "Risk",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe.root_module.addImport("raylib", b.createModule(.{
        .root_source_file = b.path("src/raylib-zig/lib/raylib.zig"),
    }));

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const raylib_dep = b.dependency("raylib", .{ .target = target, .optimize = optimize });

    exe.linkLibrary(raylib_dep.artifact("raylib"));
    exe.linkLibC();

    b.installArtifact(exe);
}
