// Loads the ZEPH wasm beside this file and calls the four packet exports.
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";

const wasmPath = fileURLToPath(new URL("./cascade.wasm", import.meta.url));
const INPUT_OFFSET = 65536;

export const FIND_SECTION_NOT_FOUND = 0xffffffff;

export async function load() {
  const wasm = readFileSync(wasmPath);
  const { instance } = await WebAssembly.instantiate(wasm);
  const api = instance.exports;
  const enc = new TextEncoder();

  function write(bytes, at) {
    const need = at + bytes.length;
    if (api.memory.buffer.byteLength < need) {
      api.memory.grow(Math.ceil((need - api.memory.buffer.byteLength) / 65536));
    }
    new Uint8Array(api.memory.buffer).set(bytes, at);
  }

  return {
    byteLength: wasm.byteLength,
    score(yaml) {
      const bytes = enc.encode(yaml);
      write(bytes, INPUT_OFFSET);
      return api.score(INPUT_OFFSET, bytes.length);
    },
    validate(data) {
      const bytes = data instanceof Uint8Array ? data : enc.encode(data);
      write(bytes, INPUT_OFFSET);
      return api.validate(INPUT_OFFSET, bytes.length);
    },
    tier(value) {
      return api.tier(value & 0xff);
    },
    findSection(data, name) {
      const bytes = data instanceof Uint8Array ? data : enc.encode(data);
      const nameBytes = enc.encode(name);
      const nameAt = INPUT_OFFSET + bytes.length;
      write(bytes, INPUT_OFFSET);
      write(nameBytes, nameAt);
      return api.find_section(INPUT_OFFSET, bytes.length, nameAt, nameBytes.length) >>> 0;
    },
  };
}
