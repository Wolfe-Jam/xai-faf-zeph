// ZEPH cascade.wasm  ↔  faf-cli  — score-PARITY harness (ZEPH swap prep).
//
// Scores a RANGE of .faf fixtures (not just 100) through BOTH engines and
// compares. Partial fixtures (no slotignored) expose the slot MODEL via the
// denominator: e.g. 6 populated → 6/21=29% (Mk3.1) vs 6/33=18% (Mk4). If the
// two engines agree across the range, the ZEPH swap is byte-safe. If they
// diverge, that's the 21-vs-33 / Mk gap to resolve BEFORE swapping.
//
//   bun benchmarks/parity_vs_cli.mjs    (or: node …)

import { readFileSync, writeFileSync, mkdtempSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { execSync } from "node:child_process";
import { tmpdir } from "node:os";
import { join } from "node:path";

// ---- ZEPH engine (cascade.wasm) -----------------------------------------
const wasmPath = fileURLToPath(new URL("../docs/cascade.wasm", import.meta.url));
const { instance } = await WebAssembly.instantiate(readFileSync(wasmPath));
const c = instance.exports;
const enc = new TextEncoder();
const OFF = 65536;
function zephScore(yaml) {
  const bytes = enc.encode(yaml);
  const need = OFF + bytes.length;
  if (c.memory.buffer.byteLength < need)
    c.memory.grow(Math.ceil((need - c.memory.buffer.byteLength) / 65536));
  new Uint8Array(c.memory.buffer).set(bytes, OFF);
  return c.score(OFF, bytes.length);
}

// ---- faf-cli engine (GFM's current scorer, via the bridge) --------------
function cliScore(yaml) {
  const dir = mkdtempSync(join(tmpdir(), "zeph-parity-"));
  writeFileSync(join(dir, "project.faf"), yaml);
  try {
    const out = execSync("npx --yes faf-cli score --json", {
      cwd: dir, encoding: "utf8", stdio: ["pipe", "pipe", "ignore"],
    });
    const j = JSON.parse(out);
    return { score: j.score, total: j.total };
  } catch (e) {
    return { score: null, total: null, err: String(e).slice(0, 60) };
  }
}

// ---- Fixtures: span the score range; partials carry NO slotignored so the
//      denominator (21 vs 33) is exposed. ----------------------------------
const F = {};
F["min (name only)"] = `faf_version: "2.5.0"\nproject:\n  name: parity-min\n`;
F["+goal +lang"] = `faf_version: "2.5.0"\nproject:\n  name: p\n  goal: a parity fixture\n  main_language: TypeScript\n`;
F["+3 of 6Ws"] = `faf_version: "2.5.0"\nproject:\n  name: p\n  goal: a parity fixture\n  main_language: TypeScript\nhuman_context:\n  who: devs\n  what: a tool\n  why: testing parity\n`;
F["+full 6Ws"] = `faf_version: "2.5.0"\nproject:\n  name: p\n  goal: a parity fixture\n  main_language: TypeScript\nhuman_context:\n  who: devs\n  what: a tool\n  why: testing parity\n  how: by scoring\n  where: local\n  when: now\n`;
F["+partial stack"] = `faf_version: "2.5.0"\nproject:\n  name: p\n  goal: a parity fixture\n  main_language: TypeScript\nhuman_context:\n  who: devs\n  what: a tool\n  why: testing parity\n  how: by scoring\n  where: local\n  when: now\nstack:\n  backend: Node\n  runtime: Node.js\n  build: tsc\n`;
F["reference (5pop+16ign→100)"] = `project:\n  name: zeph\n  goal: Ultra Context Layer\n  main_language: Zig\nhuman_context:\n  who: xAI / Grok\n  what: ZEPH delivery engine\n  why: slotignored\n  where: slotignored\n  when: slotignored\n  how: slotignored\nstack:\n  frontend: slotignored\n  css_framework: slotignored\n  ui_library: slotignored\n  state_management: slotignored\n  backend: slotignored\n  api_type: slotignored\n  runtime: slotignored\n  database: slotignored\n  connection: slotignored\n  hosting: slotignored\n  build: slotignored\n  cicd: slotignored`;

console.log("ZEPH cascade.wasm  ↔  faf-cli  — score parity\n");
console.log("fixture".padEnd(30), "ZEPH".padStart(6), "CLI".padStart(6), "CLI/total".padStart(10), "  match");
console.log("-".repeat(66));
let allMatch = true;
for (const [name, yaml] of Object.entries(F)) {
  const z = zephScore(yaml);
  const cli = cliScore(yaml);
  const match = cli.score !== null && z === cli.score;
  if (!match) allMatch = false;
  console.log(
    name.padEnd(30),
    String(z).padStart(6),
    String(cli.score ?? "ERR").padStart(6),
    String(cli.total ?? "?").padStart(10),
    "  " + (match ? "✅" : "❌"),
  );
}
console.log("-".repeat(66));
console.log(allMatch
  ? "\n🏆 PARITY — ZEPH == faf-cli across the range. Swap is score-safe."
  : "\n⚠️  DIVERGENCE — ZEPH and faf-cli use different scoring (likely 21-slot Mk3.1 vs 33-slot Mk4). Resolve before swapping; see CLI/total column for the model.");
process.exitCode = allMatch ? 0 : 1;
