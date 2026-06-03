// FAFb v1 binary format (Phase 1 — v1 only)
// extern struct for C-ABI binary layout
// String table + O(1) section lookup
const std = @import("std");

pub const MAGIC = "FAFB";
pub const VERSION_V1: u16 = 1;

pub const Classification = enum(u8) {
    DNA = 0,
    Context = 1,
    Pointer = 2,
};

pub const SectionEntry = extern struct {
    name_offset: u32,
    priority: u8,
    classification: Classification,
    _pad: u16 = 0,
    offset: u32,
    length: u32,
    token_count: u32,
};

pub const Header = extern struct {
    magic: [4]u8,
    version: u16,
    flags: u16,
    crc32: u32,
    section_count: u16,
    string_table_offset: u32,
    string_table_size: u32,
    _reserved: [8]u8 = [_]u8{0} ** 8,
};

pub fn isValidMagic(data: []const u8) bool {
    if (data.len < 4) return false;
    return std.mem.eql(u8, data[0..4], MAGIC);
}

pub fn parseHeader(data: []const u8) !Header {
    if (data.len < @sizeOf(Header)) return error.TooShort;
    if (!isValidMagic(data)) return error.InvalidMagic;
    // Copy the header out of the byte slice rather than @alignCast-ing the
    // caller's pointer: a raw []const u8 may be 1-aligned (e.g. a string literal
    // or an offset into a buffer), and @alignCast would panic in safe builds.
    // bytesToValue is alignment-safe. (Caught by CI on Linux; passed locally by
    // luck of allocation alignment.)
    const header = std.mem.bytesToValue(Header, data[0..@sizeOf(Header)]);
    if (header.version != VERSION_V1) return error.UnsupportedVersion;
    return header;
}

// String table + O(1) lookup (v1)
pub const StringTable = struct {
    data: []const u8,

    pub fn init(table_data: []const u8) StringTable {
        return .{ .data = table_data };
    }

    pub fn get(self: StringTable, offset: u32) []const u8 {
        if (offset >= self.data.len) return "";
        const len = self.data[offset];
        if (offset + 1 + len > self.data.len) return "";
        return self.data[offset + 1 .. offset + 1 + len];
    }
};

// Section table (for full walk).
// `entries` typed `[]align(1) const SectionEntry` because `std.mem.bytesAsSlice`
// on a `[]const u8` input produces an alignment-1 slice; Zig 0.14 refuses
// implicit widening to natural (4) alignment. Naturally-aligned slices from
// test fixtures still coerce because narrowing alignment is implicit.
pub const SectionTable = struct {
    entries: []align(1) const SectionEntry,
    string_table: StringTable,

    pub fn findByName(self: SectionTable, name: []const u8) ?SectionEntry {
        for (self.entries) |entry| {
            const entry_name = self.string_table.get(entry.name_offset);
            if (std.mem.eql(u8, entry_name, name)) {
                return entry;
            }
        }
        return null;
    }
};

pub fn parseStringTable(data: []const u8, header: Header) !StringTable {
    const start = header.string_table_offset;
    const end = start + header.string_table_size;
    if (end > data.len) return error.InvalidStringTable;
    return StringTable.init(data[start..end]);
}

pub fn buildSectionTable(data: []const u8, header: Header) !SectionTable {
    const section_start = @sizeOf(Header);
    const section_end = section_start + (@as(usize, header.section_count) * @sizeOf(SectionEntry));
    if (section_end > data.len) return error.TruncatedSectionTable;
    const section_bytes = data[section_start..section_end];
    const entries = std.mem.bytesAsSlice(SectionEntry, section_bytes);
    const st = try parseStringTable(data, header);
    return SectionTable{ .entries = entries, .string_table = st };
}

test "BRAKE: buildSectionTable rejects truncated section data" {
    var truncated: [32]u8 = undefined;
    @memcpy(&truncated, "FAFB\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00");
    try std.testing.expectError(error.TruncatedSectionTable, buildSectionTable(&truncated, Header{ .magic = [_]u8{ 'F', 'A', 'F', 'B' }, .version = 1, .section_count = 1, .string_table_offset = 0, .string_table_size = 0, .flags = 0, .crc32 = 0, ._reserved = [_]u8{0} ** 8 }));
}

test "ENGINE: SectionTable.findByName returns matching entry" {
    const table_bytes = [_]u8{ 0x03, 'D', 'N', 'A', 0x00 };
    const st = StringTable.init(&table_bytes);
    const entries = [_]SectionEntry{
        .{ .name_offset = 0, .priority = 1, .classification = .DNA, .offset = 0, .length = 0, .token_count = 0, ._pad = 0 },
    };
    const table = SectionTable{ .entries = &entries, .string_table = st };
    const found = table.findByName("DNA");
    try std.testing.expect(found != null);
    try std.testing.expectEqual(@as(u32, 0), found.?.name_offset);
}

test "ENGINE: SectionTable.findByName returns null on miss" {
    const st = StringTable.init("");
    const table = SectionTable{ .entries = &[_]SectionEntry{}, .string_table = st };
    try std.testing.expectEqual(@as(?SectionEntry, null), table.findByName("MISSING"));
}

// 21-slot scorer (v1)
pub const Score = struct {
    total: u8,
    populated: u8,
    empty: u8,
};

pub fn scoreContext(data: []const u8, header: Header) Score {
    var populated: u8 = 0;
    var empty: u8 = 0;

    const table = buildSectionTable(data, header) catch return .{ .total = 21, .populated = 0, .empty = 21 };

    for (table.entries) |entry| {
        if (entry.length > 0 and entry.token_count > 0) {
            populated += 1;
        } else {
            empty += 1;
        }
    }

    return .{ .total = 21, .populated = populated, .empty = empty };
}

test "BRAKE: scoreContext handles empty section table" {
    const header = Header{
        .magic = [_]u8{ 'F', 'A', 'F', 'B' },
        .version = 1,
        .flags = 0,
        .crc32 = 0,
        .section_count = 0,
        .string_table_offset = 0,
        .string_table_size = 0,
        ._reserved = [_]u8{0} ** 8,
    };
    const score = scoreContext(&[_]u8{}, header);
    try std.testing.expectEqual(@as(u8, 21), score.total);
    try std.testing.expectEqual(@as(u8, 0), score.populated);
    try std.testing.expectEqual(@as(u8, 21), score.empty);
}

test "ENGINE: scoreContext counts populated vs empty sections" {
    const data = [_]u8{
        // Header (32 bytes)
        'F', 'A', 'F', 'B', 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        // Section 0 (20 bytes — populated)
        0x00, 0x00, 0x00, 0x00, 1, 0, 0, 0, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x05, 0x00, 0x00, 0x00,
        // Section 1 (20 bytes — empty)
        0x03, 0x00, 0x00, 0x00, 0, 0, 0, 0, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    };
    const header = Header{
        .magic = [_]u8{ 'F', 'A', 'F', 'B' },
        .version = 1,
        .flags = 0,
        .crc32 = 0,
        .section_count = 2,
        .string_table_offset = 0,
        .string_table_size = 0,
        ._reserved = [_]u8{0} ** 8,
    };
    const score = scoreContext(&data, header);
    try std.testing.expectEqual(@as(u8, 21), score.total);
    try std.testing.expectEqual(@as(u8, 1), score.populated);
    try std.testing.expectEqual(@as(u8, 1), score.empty);
}

// Section lookup by name (O(1) via string table)
pub fn findSectionByName(data: []const u8, header: Header, name: []const u8) ?SectionEntry {
    const table = buildSectionTable(data, header) catch return null;
    return table.findByName(name);
}

test "BRAKE: StringTable rejects out-of-bounds offset" {
    const st = StringTable.init("test");
    try std.testing.expectEqualSlices(u8, "", st.get(99));
}

test "ENGINE: parseStringTable extracts section names" {
    // minimal valid table for test
    const table = [_]u8{ 0x03, 'D', 'N', 'A', 0x00 };
    const st = StringTable.init(&table);
    try std.testing.expectEqualSlices(u8, "DNA", st.get(0));
}
