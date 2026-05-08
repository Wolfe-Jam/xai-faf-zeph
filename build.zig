const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Expose ZEPH core as a named module — out-of-tree consumers (benchmarks,
    // examples) `@import("zeph")` instead of relative paths.
    const zeph_module = b.addModule("zeph", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Static library (native).
    // Zig 0.16: addStaticLibrary removed → addLibrary({ .linkage = .static }).
    const lib_module = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    const lib = b.addLibrary(.{
        .name = "zeph",
        .linkage = .static,
        .root_module = lib_module,
    });
    b.installArtifact(lib);

    // WASM module — wasm32-freestanding, ReleaseSmall.
    // SDK delivery target: small download, fast cold start.
    const wasm_target = b.resolveTargetQuery(.{
        .cpu_arch = .wasm32,
        .os_tag = .freestanding,
    });
    const wasm_module = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
        .target = wasm_target,
        .optimize = .ReleaseSmall,
    });
    const wasm = b.addExecutable(.{
        .name = "zeph",
        .root_module = wasm_module,
    });
    wasm.entry = .disabled;
    wasm.rdynamic = true;
    b.installArtifact(wasm);

    // Tests.
    const tests = b.addTest(.{
        .root_module = lib_module,
    });
    const run_tests = b.addRunArtifact(tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_tests.step);

    // Benchmarks.
    const bench_module = b.createModule(.{
        .root_source_file = b.path("benchmarks/main.zig"),
        .target = target,
        .optimize = .ReleaseFast,
    });
    bench_module.addImport("zeph", zeph_module);
    const bench = b.addExecutable(.{
        .name = "benchmark",
        .root_module = bench_module,
    });
    const run_bench = b.addRunArtifact(bench);
    const bench_step = b.step("benchmark", "Run performance benchmarks");
    bench_step.dependOn(&run_bench.step);
}
