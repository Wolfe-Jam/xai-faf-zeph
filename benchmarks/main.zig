// ZEPH💨 Benchmark Suite
// Reproducible microsecond measurements for UCL engine
// Run: zig build benchmark

const std = @import("std");
const zeph = @import("zeph");

// Native benchmark binary — std.debug.print is fine here (writes to stderr).
// Note: never use std.debug.print in WASM release builds — it bloats binary.
pub fn main() !void {
    std.debug.print("ZEPH💨 Benchmark — Phase 1 skeleton\n", .{});
    std.debug.print("Full per-call native timing harness lands in Phase 2.\n", .{});
    std.debug.print("For live numbers now: bun benchmarks/bench_js.mjs\n\n", .{});

    // Skeleton call — real timing harness + 9 experiments lands with the engine work.
    const v = zeph.zeph_version();
    std.debug.print("zeph_version() = {} (skeleton; real harness in Phase 2)\n", .{v});
}
