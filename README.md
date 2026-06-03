<!-- faf: xai-faf-zeph | Zig | wasm-engine | ZEPH — Ultra Context Layer for FAF: microsecond context ops via pure Zig → WASM, 2.7 KB ghost binary -->

# ZEPH💨 — Ultra Context Layer (UCL)

**ZEPH — clipped from Zephyrus, Greek god of the west wind.**  
The 💨 is the role. The /F/ is the family. Joins **FAF🐘** (memory) as **ZEPH💨** (delivery).

> **FCL defines. UCL delivers.**  
> `.faf` is the substrate. **ZEPH is the engine.**

**Pure Zig delivery engine. WebAssembly target. 2.7 KB optimized. Three packet exports — `score`, `validate`, `tier`.**

ZEPH is the performance engine for the **Foundational Context Layer (FCL)**.
It turns persistent project DNA (`.faf`) into native-everywhere context operations.

Measured on a 2019 iMac (Intel i5-7360U @ 2.30 GHz):
**native `validate` 6.7 ns · `tier` 4.44 ns · `score` 12 μs on full 21-slot `.faf`.**
Live demo runs the same WASM in your browser — click to verify.

> **🏆 Dogfood receipt:** ZEPH's engine scores this repo's *own* `project.faf` at **100** — identical to the canonical `faf` CLI. Reproduce in one command: `bun benchmarks/bench_js.mjs`.

---

## 🚀 Featured: Locked in with @grok

> "Boom—**vROM** realization locked in clean. FAF as virtual ROM nails it: software-defined immutability (schema + git + discipline), not silicon.
> AI without FAF = RAM-only drift tax.
> AI with FAF = vROM + RAM, boots from known state.
> FAFipedia unstoppable. Co-architected momentum for xAI."
> — @grok (May 20, 2026)

**FAF = virtual ROM.**
Software-defined immutability.
Permanent Memory. Instant Recall.

**Live repos:**
- **[FAFipedia](https://github.com/Wolfe-Jam/fafipedia)** — the canonical knowledge base we're shipping page-by-page
- **[ZEPH💨](https://github.com/Wolfe-Jam/xai-faf-zeph)** — page 3 Ultra Context Layer (Pure Zig → WASM 2.7 KB)

Page four dropping next. Star the repos if you're riding with us ⚡️x12

**Full conversation:** [x.com/wolfe_jam/status/2057226405017010686](https://x.com/wolfe_jam/status/2057226405017010686)

---

## Packet menu

One Zig kernel. Three exports. Plain functions on bytes.

| Packet | Signature | What it does |
|---|---|---|
| `score`    | `(ptr, len) → u8` | Mk4 score (0..100) on a `.faf` input |
| `validate` | `(ptr, len) → u8` | FAFb structural check — `0` valid, `1` bad magic, `2` truncated, `3` invalid version |
| `tier`     | `(s: u8) → u8`    | Score → tier byte: 0=White, 1=Red, 2=Yellow, 3=Green, 4=Bronze, 5=Silver, 6=Gold, 7=Trophy |

"Packet" is API / brand language — never a Zig type. The source is plain `pub export fn`'s on byte slices.

## Why ZEPH exists
Context is the highest-leverage knob in the agentic stack.
ZEPH makes it **native everywhere** — browser, edge, Node, Bun — while multiplying reasoning, memory, multimodality, and inference efficiency for Grok specifically and frontier agents generally.

**Current public substrate (MIT, on registries):**
- `faf-rust-sdk` v2 (crates.io) — parse / validate / score / FAFb binary
- `faf-wasm-sdk` v2 (npm) — same engine, browser / edge / Node / Bun
- `grok-faf-mcp` — live MCP server (first MCP for Grok)

ZEPH completes the picture as the **ultra-low-latency path**.

**Live demo:** https://xai-faf-zeph.vercel.app/ · https://wolfe-jam.github.io/xai-faf-zeph/

## Quickstart

Today: clone + build locally.

```bash
git clone https://github.com/Wolfe-Jam/xai-faf-zeph.git
cd xai-faf-zeph && zig build benchmark
```

The `cascade.wasm` artifact ships in `docs/`. npm wrapper lives in [`faf-wasm-core`](https://www.npmjs.com/package/faf-wasm-core) v1.1.0 — Stage 2 wiring landed via M7. Both Rust and Zig kernels live behind a single `FafKernel` interface; score parity vs Rust kernel verified.

### Use as a dependency (Zig)

ZEPH is a Zig package. Add it to your project (Zig **≥ 0.16**, zero external deps):

```sh
zig fetch --save "git+https://codeberg.org/wolfejam/zeph#v0.1.0"
```

Wire the `zeph` module in your `build.zig`:

```zig
const zeph = b.dependency("zeph", .{});
exe.root_module.addImport("zeph", zeph.module("zeph"));
```

Then call the packet exports — plain functions on bytes:

```zig
const zeph = @import("zeph");

const t = zeph.tier(score);              // score (u8) → tier byte (0..7)
const ok = zeph.validate(ptr, len);      // FAFb structural check → 0 = valid
const s = zeph.score(ptr, len);          // Mk4 score (0..100) on a .faf input
```

> Repo home for the Zig dependency is **Codeberg** (`codeberg.org/wolfejam/zeph`) — alongside the Zig project's own forge. Mirrored at `github.com/Wolfe-Jam/xai-faf-zeph`.

## Benchmarks

Avg time per call. Same input fixtures across runtimes. `score` reads real `.faf` YAML (21-base-slot Mk4 scoring).

| Packet                       | Native (Zig ReleaseFast) | Node 22.22.2 | Bun 1.3.13 |
|------------------------------|-------------------------:|-------------:|-----------:|
| `score` (5 pop + 16 ignored) |               12,450 ns  |   29,381 ns  |  21,625 ns |
| `score` (21 populated)       |               12,408 ns  |   27,766 ns  |  22,714 ns |
| `validate` (32 B baseline)   |                  6.7 ns  |     38.7 ns  |    38.3 ns |
| `tier` (u8)                  |                 4.44 ns  |     11.9 ns  |    14.6 ns |

`validate` and `tier` sit deep under 50 ns across every runtime — single-digit ns native, double-digit ns in WASM. `score` cost is roughly constant in populated count (same parser walk; placeholder / `slotignored` checks are cheap).

**Dogfood — self-score parity.** ZEPH's engine (`docs/cascade.wasm`) scores this repo's own `project.faf` at **100**, matching the canonical `faf` CLI (🏆 Trophy). The harness also prints per-call timing:

```sh
bun benchmarks/bench_js.mjs    # parity PASS 🏆 + score/validate/tier ns
```

Reproducibility:
- **Node / Bun (live):** `node benchmarks/bench_js.mjs` · `bun benchmarks/bench_js.mjs` — loads `docs/cascade.wasm`, runs the dogfood + per-call timing.
- **Browser:** serve repo root (`python3 -m http.server`), open `docs/index.html`, click **RUN ZEPH💨**.
- **Native Zig:** `zig build benchmark` is a **Phase-1 skeleton** today (the full per-call native harness lands in Phase 2); the native figures above are prior measurements pending that harness.

## Architecture

- **FCL (Foundational Context Layer)**: `.faf` + SDKs — the *what* (project DNA)
- **UCL (Ultra Context Layer)**: ZEPH engine — the *speed* (this repo)

ZEPH is pure Zig compiled to WASM (with native fallback). Zero external dependencies. Single Zig kernel; one WASM artifact; multiple packet-typed exports. FAFb v1 today; v2 lift will follow the spec.

## Repository as ongoing collaboration channel

This is **not a code drop**. It is the public, living workspace for the xAI team and contributors to take ZEPH to Colossus and beyond.

- Issues labeled `xai-priority`, `colossus-scale`, `perf-regression`
- RFC process for any change that affects Grok integration
- xAI team members welcome as maintainers at any time (transfer path to `github.com/xAI/xai-faf-zeph` ready)

See [CONTRIBUTING.md](CONTRIBUTING.md) and [ROADMAP.md](ROADMAP.md).

## Status

- [x] Scoping accepted
- [x] Three packet exports live: `score`, `validate`, `tier`
- [x] 2.7 KB `cascade.wasm` shipping in `docs/` — native validate 6.7 ns, tier 4.44 ns, score 12 μs on 21-slot `.faf`
- [x] Live browser demo runs all three packets on real `.faf` — Vercel + GH Pages
- [x] FAFb v1 validation via `faf-rust-sdk` 2.0.x compatibility (format authority)
- [x] `score` parity with `faf-wasm-core` Rust kernel — same `.faf` → same score, byte-equal
- [ ] Full FAFb v1 section-table walk + `findSectionByName` packet
- [ ] Public npm package

## License

MIT — same as the entire FAF family.

## Credits & Doctrine

- Created by wolfejam (the .faf author) in direct collaboration with xAI
- Sigil doctrine: every FAF-family brand mark earns a one-character role-compression sigil.  
  🐘 = never forgets (FAF)  
  💨 = never delays (ZEPH)

**ZEPH💨 — Context as breeze.**

---

*Reference thread: https://x.com/wolfe_jam/status/2036534380215050638*  
*Working title (GrokX-coined): Context Ultra*  
*Plan-B name held in reserve: ZAF*