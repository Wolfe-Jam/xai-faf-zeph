// Three cases for the find_section packet.
//   node benchmarks/find_section.mjs <wasm>
// JavaScript presents the u32 sentinel 0xFFFFFFFF as signed -1.
// Compare with >>> 0.

import { readFileSync } from "node:fs";

const NOT_FOUND = 0xffffffff;
const wasmPath = process.argv[2];
if (!wasmPath) {
  console.error("usage: node benchmarks/find_section.mjs <wasm>");
  process.exit(2);
}

const dna = new Uint8Array([
  0x46, 0x41, 0x46, 0x42, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00,
  0x00, 0x00, 0x34, 0x00, 0x00, 0x00, 0x05, 0x00, 0x00, 0x00, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 1, 0, 0, 0, 0x40, 0, 0, 0, 0x10, 0, 0, 0, 0x05, 0, 0, 0,
  3, 0x44, 0x4e, 0x41, 0,
]);

const { instance } = await WebAssembly.instantiate(readFileSync(wasmPath));
const e = instance.exports;
if (typeof e.find_section !== "function") {
  console.error("find_section is not exported");
  process.exit(1);
}

const base = 1024;
function call(data, name) {
  const need = base + data.length + name.length + 8;
  if (e.memory.buffer.byteLength < need) {
    e.memory.grow(Math.ceil((need - e.memory.buffer.byteLength) / 65536));
  }
  const mem = new Uint8Array(e.memory.buffer);
  mem.set(data, base);
  const nameAt = base + data.length;
  mem.set(new TextEncoder().encode(name), nameAt);
  return e.find_section(base, data.length, nameAt, name.length) >>> 0;
}

const known = call(dna, "DNA");
const missing = call(dna, "NOPE");
const badBytes = dna.slice();
badBytes[0] = 0x58;
const bad = call(badBytes, "DNA");
const short = call(dna.slice(0, 3), "DNA");

const ok = known === 64 && missing === NOT_FOUND && bad === NOT_FOUND && short === NOT_FOUND;
console.log(`${wasmPath}: known=${known} missing=${missing} bad=${bad} short=${short} ${ok ? "PASS" : "FAIL"}`);
if (!ok) process.exit(1);
