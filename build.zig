const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "aoc",
        .root_source_file = b.path("src/day1.zig"),
        .target = target,
        .optimize = optimize,
    });

    // This *creates* a Run step in the build graph, to be executed when another
    // step is evaluated that depends on it. The next line below will establish
    // such a dependency.
    const run_cmd = b.addRunArtifact(exe);

    // By making the run step depend on the install step, it will be run from the
    // installation directory rather than directly from within the cache directory.
    // This is not necessary, however, if the application depends on other installed
    // files, this ensures they will be present and in the expected location.
    run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build run`
    // This will evaluate the `run` step rather than the default, which is "install".
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/day1.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);

    const day1 = b.addExecutable(.{
        .name = "day1",
        .root_source_file = b.path("src/day1.zig"),
        .target = target,
        .optimize = optimize,
    });
    const day1_run = b.addRunArtifact(day1);
    const day1_step = b.step("day1", "Solve Advent of Code Day 1");
    day1_step.dependOn(&day1_run.step);

    const day2 = b.addExecutable(.{
        .name = "day2",
        .root_source_file = b.path("src/day2.zig"),
        .target = target,
        .optimize = optimize,
    });
    const day2_run = b.addRunArtifact(day2);
    const day2_step = b.step("day2", "Solve Advent of Code Day 2");
    day2_step.dependOn(&day2_run.step);

    const day3 = b.addExecutable(.{
        .name = "day3",
        .root_source_file = b.path("src/day3.zig"),
        .target = target,
        .optimize = optimize,
    });
    const day3_run = b.addRunArtifact(day3);
    const day3_step = b.step("day3", "Solve Advent of Code Day 3");
    day3_step.dependOn(&day3_run.step);
}
