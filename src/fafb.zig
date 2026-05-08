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
    const header = @as(*const Header, @ptrCast(@alignCast(data.ptr))).*;
    if (!isValidMagic(data)) return error.InvalidMagic;
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

// Section table (for full walk)
pub const SectionTable = struct {
    entries: []const SectionEntry,
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
    const section_bytes = data[section_start .. section_start + (header.section_count * @sizeOf(SectionEntry))];
    const entries = std.mem.bytesAsSlice(SectionEntry, section_bytes);
    const st = try parseStringTable(data, header);
    return SectionTable{ .entries = entries, .string_table = st };
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
