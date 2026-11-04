// Packs npm/faf-zeph and loads that tarball.
//   node benchmarks/pack_faf_zeph.mjs
// The tarball must contain the wasm and the loader. It must not contain Zig sources.

import { createHash } from "node:crypto";
import { execFileSync } from "node:child_process";
import { mkdtempSync, readFileSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";

const root = fileURLToPath(new URL("..", import.meta.url));
const pkgDir = join(root, "npm", "faf-zeph");

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

const DNA = new Uint8Array([
  0x46, 0x41, 0x46, 0x42, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00,
  0x00, 0x00, 0x34, 0x00, 0x00, 0x00, 0x05, 0x00, 0x00, 0x00, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 1, 0, 0, 0, 0x40, 0, 0, 0, 0x10, 0, 0, 0, 0x05, 0, 0, 0,
  3, 0x44, 0x4e, 0x41, 0,
]);

const BASELINE = new Uint8Array(32);
BASELINE.set(new TextEncoder().encode("FAFB"), 0);
BASELINE[4] = 0x01;

function npm(args, cwd) {
  return execFileSync("npm", args, { cwd, encoding: "utf8" });
}

function parsePack(stdout) {
  const start = stdout.indexOf("[");
  const obj = stdout.indexOf("{");
  const at = start === -1 ? obj : obj === -1 ? start : Math.min(start, obj);
  if (at === -1) throw new Error("npm pack did not print JSON");
  const parsed = JSON.parse(stdout.slice(at));
  return Array.isArray(parsed) ? parsed[0] : parsed;
}

function names(entry) {
  return entry.files.map((file) => file.path.replace(/^package\//, ""));
}

function assertPack(entry, label) {
  const paths = names(entry);
  console.log(`${label} files:`);
  for (const path of paths) console.log(`  ${path}`);
  const forbidden = paths.filter(
    (path) => path.endsWith(".zig") || path.split("/").includes("src"),
  );
  if (forbidden.length) {
    console.error(`Zig or src leaked into the tarball: ${forbidden.join(", ")}`);
    process.exit(1);
  }
  for (const required of ["index.mjs", "cascade.wasm"]) {
    if (!paths.includes(required)) {
      console.error(`${label} is missing ${required}`);
      process.exit(1);
    }
  }
  return paths;
}

function md5(path) {
  return createHash("md5").update(readFileSync(path)).digest("hex");
}

const docsWasm = join(root, "docs", "cascade.wasm");
const pkgWasm = join(pkgDir, "cascade.wasm");
const docsHash = md5(docsWasm);
const pkgHash = md5(pkgWasm);
if (docsHash !== pkgHash) {
  console.error(`wasm drift docs ${docsHash} package ${pkgHash}`);
  process.exit(1);
}
console.log(`wasm md5 ${docsHash}`);

const dry = parsePack(npm(["pack", "--dry-run", "--json"], pkgDir));
assertPack(dry, "dry-run");

const dest = mkdtempSync(join(tmpdir(), "faf-zeph-pack-"));
try {
  const packed = parsePack(npm(["pack", "--json", "--pack-destination", dest], pkgDir));
  assertPack(packed, "pack");
  const tgz = join(dest, packed.filename);
  execFileSync("tar", ["-xzf", tgz, "-C", dest]);
  const { load } = await import(pathToFileURL(join(dest, "package", "index.mjs")).href);
  const zeph = await load();
  const score = zeph.score(REFERENCE_YAML);
  const known = zeph.findSection(DNA, "DNA");
  const missing = zeph.findSection(DNA, "NOPE");
  const valid = zeph.validate(BASELINE);
  const tier = zeph.tier(100);
  console.log(
    `packed wasm ${zeph.byteLength} B  score=${score}  findSection=${known}  missing=${missing}  validate=${valid}  tier(100)=${tier}`,
  );
  if (zeph.byteLength !== 2986 || score !== 100 || known !== 64 || missing !== 0xffffffff || valid !== 0 || tier !== 7) {
    console.error("packed fixture failed");
    process.exit(1);
  }
  console.log("PASS");
} finally {
  rmSync(dest, { recursive: true, force: true });
}
