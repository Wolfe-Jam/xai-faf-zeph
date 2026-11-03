// ZEPH public structural benchmark.
// Times validate, structural score, and tier on the FAFb fixture from
// src/fafb.zig test "ENGINE: scoreContext counts populated vs empty sections".
// This is not the Mk4 engine receipt (docs/cascade.wasm, May 2026, 12,408 ns).
// Run: zig build benchmark

const std = @import("std");
const zeph = @import("zeph");

// Header (32) + two SectionEntry rows (20 each). Section 0 populated, section 1 empty.
const fixture = [_]u8{
    'F', 'A', 'F', 'B', 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 1,    0,    0,    0,    0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x05, 0x00, 0x00, 0x00,
    0x03, 0x00, 0x00, 0x00, 0,    0,    0,    0,    0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
};

const iters: usize = 1_000_000;
const warmup: usize = 10_000;

// crc32 byte. parseHeader and scoreContext do not read it, so flipping it
// keeps validate == 0 and score == 1 while stopping ReleaseFast from
// lifting the call out of the loop.
const crc_byte: usize = 8;

var sink: u64 = 0;

fn nowNs() u64 {
    var ts: std.c.timespec = undefined;
    _ = std.c.clock_gettime(std.c.CLOCK.MONOTONIC, &ts);
    return @as(u64, @intCast(ts.sec)) * std.time.ns_per_s + @as(u64, @intCast(ts.nsec));
}

fn timeValidateScore(buf: []u8, comptime which: enum { validate, score }) f64 {
    var i: usize = 0;
    while (i < warmup) : (i += 1) {
        buf[crc_byte] = @truncate(i);
        sink +%= switch (which) {
            .validate => @call(.never_inline, zeph.validate, .{ buf.ptr, buf.len }),
            .score => @call(.never_inline, zeph.score, .{ buf.ptr, buf.len }),
        };
    }
    const t0 = nowNs();
    i = 0;
    while (i < iters) : (i += 1) {
        buf[crc_byte] = @truncate(i);
        sink +%= switch (which) {
            .validate => @call(.never_inline, zeph.validate, .{ buf.ptr, buf.len }),
            .score => @call(.never_inline, zeph.score, .{ buf.ptr, buf.len }),
        };
    }
    return @as(f64, @floatFromInt(nowNs() - t0)) / @as(f64, @floatFromInt(iters));
}

fn timeTier() f64 {
    var i: usize = 0;
    while (i < warmup) : (i += 1) {
        sink +%= @call(.never_inline, zeph.tier, .{@as(u8, @truncate(i))});
    }
    const t0 = nowNs();
    i = 0;
    while (i < iters) : (i += 1) {
        sink +%= @call(.never_inline, zeph.tier, .{@as(u8, @truncate(i))});
    }
    return @as(f64, @floatFromInt(nowNs() - t0)) / @as(f64, @floatFromInt(iters));
}

pub fn main() !void {
    var buf = fixture;
    const got_validate = zeph.validate(&buf, buf.len);
    const got_score = zeph.score(&buf, buf.len);
    if (got_validate != 0 or got_score != 1) return error.FixtureDrift;

    const validate_ns = timeValidateScore(&buf, .validate);
    const score_ns = timeValidateScore(&buf, .score);
    const tier_ns = timeTier();
    if (validate_ns < 0.05 or score_ns < 0.05 or tier_ns < 0.05) return error.FoldedTiming;

    std.debug.print("ZEPH public structural layer — not the Mk4 engine receipt\n", .{});
    std.debug.print("fixture: FAFb v1, 2 sections, 1 populated\n", .{});
    std.debug.print("validate: {d:.1} ns\n", .{validate_ns});
    std.debug.print("score: {d:.1} ns\n", .{score_ns});
    std.debug.print("tier: {d:.1} ns\n", .{tier_ns});
    std.debug.print("sink: {d}\n", .{sink});
}
