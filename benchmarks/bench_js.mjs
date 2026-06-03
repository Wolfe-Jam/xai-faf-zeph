// ZEPH💨 — JS/WASM harness: dogfood parity + reproducible per-packet timing.
// Loads docs/cascade.wasm (the real 2.7 KB engine), scores .faf inputs, times packets.
//
//   bun  benchmarks/bench_js.mjs
//   node benchmarks/bench_js.mjs
//
// Two jobs:
//   1) DOGFOOD — score this repo's own project.faf through ZEPH's engine and
//      compare to the canonical `faf` CLI (🏆 100). loop-the-loop receipt.
//   2) BENCH   — per-call timing for score / validate / tier (mirrors the live demo).

import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";

const root = new URL("..", import.meta.url);
const wasmPath = fileURLToPath(new URL("docs/cascade.wasm", root));
const fafPath = fileURLToPath(new URL("project.faf", root));

const CANONICAL_SCORE = 100; // `faf score project.faf` → 🏆 100% (Trophy)
const INPUT_OFFSET = 65536; // inputs go past one 64 KB WASM page (matches the live demo)

// Reference .faf (5 populated + 16 slotignored → 100). Control: proves the
// engine runs in this JS runtime and produces the known score.
const REFERENCE_YAML = `project:
  name: zeph
  goal: Ultra Context Layer — sub-microsecond delivery for .faf
  main_language: Zig
human_context:
  who: xAI / Grok team and frontier agent builders
  what: ZEPH💨 — the delivery engine for FAF
  why: slotignored
  where: slotignored
  when: slotignored
  how: slotignored
stack:
  frontend: slotignored
  css_framework: slotignored
  ui_library: slotignored
  state_management: slotignored
  backend: slotignored
  api_type: slotignored
  runtime: slotignored
  database: slotignored
  connection: slotignored
  hosting: slotignored
  build: slotignored
  cicd: slotignored`;

const { instance } = await WebAssembly.instantiate(readFileSync(wasmPath));
const c = instance.exports;
const enc = new TextEncoder();

// Write bytes at INPUT_OFFSET, growing memory if needed, returning a fresh view
// (memory.buffer detaches on grow).
function writeInput(bytes) {
  const need = INPUT_OFFSET + bytes.length;
  if (c.memory.buffer.byteLength < need) {
    c.memory.grow(Math.ceil((need - c.memory.buffer.byteLength) / 65536));
  }
  new Uint8Array(c.memory.buffer).set(bytes, INPUT_OFFSET);
  return bytes.length;
}

function score(yaml) {
  const len = writeInput(enc.encode(yaml));
  return c.score(INPUT_OFFSET, len);
}

// ---- 1) DOGFOOD ----------------------------------------------------------
const refScore = score(REFERENCE_YAML);
const ownScore = score(readFileSync(fafPath, "utf8"));

console.log("ZEPH💨 dogfood — the engine scores its own .faf");
console.log(`  reference .faf (control) : ${refScore}   (expected ${CANONICAL_SCORE})`);
console.log(`  project.faf  (this repo) : ${ownScore}   canonical faf CLI: ${CANONICAL_SCORE}`);

const controlOk = refScore === CANONICAL_SCORE;
const parityOk = ownScore === CANONICAL_SCORE;
console.log(
  `  control : ${controlOk ? "PASS ✅  engine runs, scores reference 100" : "FAIL ❌  engine not producing 100 on reference"}`,
);
console.log(
  `  parity  : ${parityOk ? "PASS 🏆  ZEPH == canonical on its own .faf" : `⚠️  ZEPH=${ownScore} vs canonical=${CANONICAL_SCORE} — investigate (CLI vs wasm scoring model)`}`,
);

// ---- 2) BENCH (per-call ns; mirrors the live demo loops) -----------------
function benchScore(yaml, iters = 50_000, warm = 5_000) {
  const len = writeInput(enc.encode(yaml));
  for (let i = 0; i < warm; i++) c.score(INPUT_OFFSET, len);
  const t0 = performance.now();
  let s = 0;
  for (let i = 0; i < iters; i++) s = (s + c.score(INPUT_OFFSET, len)) | 0;
  if (s < -1) console.log(s);
  return ((performance.now() - t0) * 1e6) / iters;
}
function benchValidate(iters = 500_000, warm = 50_000) {
  const baseline = new Uint8Array(32);
  baseline.set(enc.encode("FAFB"), 0);
  baseline[4] = 0x01;
  writeInput(baseline);
  for (let i = 0; i < warm; i++) c.validate(INPUT_OFFSET, 32);
  const mem = new Uint8Array(c.memory.buffer);
  const t0 = performance.now();
  let s = 0;
  for (let i = 0; i < iters; i++) {
    mem[INPUT_OFFSET + 12] = i & 0xff;
    s = (s + c.validate(INPUT_OFFSET, 32)) | 0;
  }
  if (s < -1) console.log(s);
  return ((performance.now() - t0) * 1e6) / iters;
}
function benchTier(iters = 2_000_000, warm = 100_000) {
  for (let i = 0; i < warm; i++) c.tier(i & 0xff);
  const t0 = performance.now();
  let s = 0;
  for (let i = 0; i < iters; i++) s = (s + c.tier(i & 0xff)) | 0;
  if (s < -1) console.log(s);
  return ((performance.now() - t0) * 1e6) / iters;
}

const fmt = (ns) => (ns < 10 ? ns.toFixed(2) : ns < 100 ? ns.toFixed(1) : ns.toFixed(0));
console.log("\nper-call timing (this runtime):");
console.log(`  score    : ${fmt(benchScore(REFERENCE_YAML))} ns`);
console.log(`  validate : ${fmt(benchValidate())} ns`);
console.log(`  tier     : ${fmt(benchTier())} ns`);

// CI gate: the engine must run (control) AND agree with the canonical scorer on
// this repo's own .faf (parity). Either failing fails the build.
process.exitCode = controlOk && parityOk ? 0 : 1;
