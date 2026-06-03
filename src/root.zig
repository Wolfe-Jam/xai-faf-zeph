// ZEPH💨 — Ultra Context Layer (UCL)
// Pure Zig → WASM microsecond context engine for .faf / FAFb
//
// The exports here are the FAFb *structural* layer — real, public, MIT:
//   validate · score (structural) · tier (ladder).
// The Mk4 `.faf`-YAML 0..100 scorer is the private engine, shipped as the
// prebuilt artifact docs/cascade.wasm (see README "Dogfood"). These two layers
// are deliberately distinct: this source never claims to be the Mk4 scorer.

const std = @import("std");
const fafb = @import("fafb.zig");

/// ABI version of this engine surface.
pub export fn zeph_version() u32 {
    return 1; // v0.1.0
}

/// FAFb structural validity of `data`:
///   0 = valid v1 · 1 = bad magic · 2 = truncated · 3 = unsupported version
pub export fn validate(ptr: [*]const u8, len: usize) u8 {
    const data = ptr[0..len];
    _ = fafb.parseHeader(data) catch |e| return switch (e) {
        error.InvalidMagic => 1,
        error.TooShort => 2,
        error.UnsupportedVersion => 3,
    };
    return 0;
}

/// FAFb *structural* score: count of populated sections (0..21).
/// NOTE: this is the binary-structural metric, NOT the Mk4 `.faf`-YAML 0..100
/// score — that is delivered by the engine artifact (docs/cascade.wasm).
pub export fn score(ptr: [*]const u8, len: usize) u8 {
    const data = ptr[0..len];
    const header = fafb.parseHeader(data) catch return 0;
    return fafb.scoreContext(data, header).populated;
}

/// Map a 0..100 score to the public FAF tier ladder (0=White … 7=Trophy).
pub export fn tier(s: u8) u8 {
    return if (s >= 100) 7 // Trophy
    else if (s >= 99) 6 // Gold
    else if (s >= 95) 5 // Silver
    else if (s >= 85) 4 // Bronze
    else if (s >= 70) 3 // Green
    else if (s >= 55) 2 // Yellow
    else if (s >= 1) 1 // Red
    else 0; // White
}

// Re-exports for Zig module consumers (`@import("zeph")`).
pub const FafbHeader = fafb.Header;
pub const parse_fafb = fafb.parseHeader;
pub const scoreContext = fafb.scoreContext;
pub const findSectionByName = fafb.findSectionByName;

// Tests follow the WJTTC 4-tier convention (see CONTRIBUTING.md):
//   BRAKE  = ABI / memory safety / error paths
//   ENGINE = core functionality (parse / validate / score / retrieve)
//   AERO   = optimization (size / speed / zero-alloc)

test "BRAKE: zeph_version returns u32 ABI version" {
    try std.testing.expectEqual(@as(u32, 1), zeph_version());
}

test "BRAKE: validate rejects too-short input" {
    const short: []const u8 = "FAF";
    try std.testing.expectEqual(@as(u8, 2), validate(short.ptr, short.len));
}

test "BRAKE: validate rejects bad magic" {
    const bad: []const u8 = "XXXX\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00";
    try std.testing.expectEqual(@as(u8, 1), validate(bad.ptr, bad.len));
}

test "ENGINE: validate accepts a valid v1 header" {
    const data align(@alignOf(fafb.Header)) = [_]u8{
        'F', 'A', 'F', 'B', // magic
        0x01, 0x00, // version u16 LE = 1
        0x00, 0x00, // flags
        0x00, 0x00, 0x00, 0x00, // crc32
        0x00, 0x00, // section_count
        0x00, 0x00, // pad
        0x00, 0x00, 0x00, 0x00, // string_table_offset
        0x00, 0x00, 0x00, 0x00, // string_table_size
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // _reserved
    };
    try std.testing.expectEqual(@as(u8, 0), validate(&data, data.len));
}

test "ENGINE: tier maps the published FAF ladder" {
    try std.testing.expectEqual(@as(u8, 7), tier(100)); // Trophy
    try std.testing.expectEqual(@as(u8, 6), tier(99)); // Gold
    try std.testing.expectEqual(@as(u8, 5), tier(95)); // Silver
    try std.testing.expectEqual(@as(u8, 4), tier(85)); // Bronze
    try std.testing.expectEqual(@as(u8, 3), tier(70)); // Green
    try std.testing.expectEqual(@as(u8, 2), tier(55)); // Yellow
    try std.testing.expectEqual(@as(u8, 1), tier(1)); // Red
    try std.testing.expectEqual(@as(u8, 0), tier(0)); // White
}

test "AERO: tier is allocation-free and monotonic across 0..=100" {
    var last: u8 = 0;
    var s: u8 = 0;
    while (s <= 100) : (s += 1) {
        const t = tier(s);
        try std.testing.expect(t >= last);
        last = t;
    }
}
