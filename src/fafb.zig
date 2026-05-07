// FAFb v1 binary format (Phase 1 — v1 only)
// extern struct for C-ABI binary layout
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
