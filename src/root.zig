// ZEPH💨 — Ultra Context Layer (UCL)
// Pure Zig → WASM microsecond context engine for .faf / FAFb
// Phase 1: real FAFb v1 parser + WJTTC tier convention

const std = @import("std");
const fafb = @import("fafb.zig");

// Public WASM exports — also importable from Zig consumers (`pub`).
pub export fn zeph_version() u32 {
    return 1; // v0.1.0
}

pub export fn zeph_load_context(ptr: [*]const u8, len: usize) u32 {
    const data = ptr[0..len];
    if (!fafb.isValidMagic(data)) return 0;
    return 94; // placeholder until full scorer
}

pub export fn zeph_get_section(name_ptr: [*]const u8, name_len: usize) u32 {
    // TODO: O(1) string table lookup + zero-copy return
    _ = name_ptr;
    _ = name_len;
    return 0; // placeholder offset
}

// Re-export for module consumers
pub const FafbHeader = fafb.Header;
pub const parse_fafb = fafb.parseHeader;

// High-level context API (future)
pub const Context = struct {
    score: u8,
    sections: u16,

    pub fn load(allocator: std.mem.Allocator, path: []const u8) !Context {
        _ = allocator;
        _ = path;
        return Context{ .score = 94, .sections = 21 };
    }
};

// Tests follow WJTTC 4-tier convention (see CONTRIBUTING.md):
//   BRAKE  = ABI / memory safety / error paths
//   ENGINE = core functionality (parse / validate / score / retrieve)
//   AERO   = optimization (size / speed / zero-alloc)
//   PIT    = setup / teardown / fixtures

test "BRAKE: zeph_version returns u32 ABI version" {
    try std.testing.expectEqual(@as(u32, 1), zeph_version());
}

test "BRAKE: rejects too-short input" {
    const short = "FAF";
    try std.testing.expect(!fafb.isValidMagic(short));
}

test "BRAKE: rejects bad magic" {
    const bad = "XXXX\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00";
    try std.testing.expect(!fafb.isValidMagic(bad));
}

test "ENGINE: parseHeader returns valid v1 header" {
    // 32-byte FAFb v1 header. Version field is u16 native-endian; on x86/ARM that's LE,
    // so version=1 → bytes "\x01\x00".
    const data align(@alignOf(fafb.Header)) = [_]u8{
        'F', 'A', 'F', 'B',     // magic (4)
        0x01, 0x00,             // version u16 LE = 1 (2)
        0x00, 0x00,             // flags (2)
        0x00, 0x00, 0x00, 0x00, // crc32 (4)
        0x00, 0x00,             // section_count (2)
        0x00, 0x00,             // pad to align u32 (2)
        0x00, 0x00, 0x00, 0x00, // string_table_offset (4)
        0x00, 0x00, 0x00, 0x00, // string_table_size (4)
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // _reserved (8)
    };
    const header = try fafb.parseHeader(&data);
    try std.testing.expectEqualSlices(u8, "FAFB", &header.magic);
    try std.testing.expectEqual(@as(u16, 1), header.version);
}

test "ENGINE: parse_fafb recognizes FAFB magic bytes via re-export" {
    const data align(@alignOf(fafb.Header)) = [_]u8{
        'F', 'A', 'F', 'B',
        0x01, 0x00,
        0x00, 0x00,
        0x00, 0x00, 0x00, 0x00,
        0x00, 0x00,
        0x00, 0x00,
        0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    };
    const header = try parse_fafb(&data);
    try std.testing.expectEqualSlices(u8, "FAFB", &header.magic);
}
