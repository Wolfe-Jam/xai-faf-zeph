const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Expose ZEPH core as a named module so out-of-tree consumers
    // (benchmarks, examples) can `@import("zeph")` instead of relative paths.
    const zeph_module = b.addModule("zeph", .{
        .root_source_file = b.path("src/root.zig"),
    });

    // Main library
    const lib = b.addStaticLibrary(.{
        .name = "zeph",
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(lib);

    // WASM module (freestanding for tiny size)
    const wasm = b.addExecutable(.{
        .name = "zeph",
        .root_source_file = b.path("src/root.zig"),
        .target = b.resolveTargetQuery(.{ .cpu_arch = .wasm32, .os_tag = .freestanding }),
        .optimize = .ReleaseSmall,
    });
    wasm.entry = .disabled;
    wasm.rdynamic = true; // export symbols
    b.installArtifact(wasm);

    // Tests
    const tests = b.addTest(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_tests = b.addRunArtifact(tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_tests.step);

    // Benchmarks
    const bench = b.addExecutable(.{
        .name = "benchmark",
        .root_source_file = b.path("benchmarks/main.zig"),
        .target = target,
        .optimize = .ReleaseFast,
    });
    bench.root_module.addImport("zeph", zeph_module);
    const run_bench = b.addRunArtifact(bench);
    const bench_step = b.step("benchmark", "Run performance benchmarks");
    bench_step.dependOn(&run_bench.step);

    // Example: browser demo assets
    // (static files copied in examples/browser-demo)
}