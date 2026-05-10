# ZEPH💨 — Ultra Context Layer (UCL)

**ZEPH — clipped from Zephyrus, Greek god of the west wind.**  
The 💨 is the role. The /F/ is the family. Joins **FAF🐘** (memory) as **ZEPH💨** (delivery).

> **FCL defines. UCL delivers.**  
> `.faf` is the substrate. **ZEPH is the engine.**

**Pure Zig delivery engine. WebAssembly target. 2.4 KB optimized. Three packet exports — `score`, `validate`, `tier`.**

ZEPH is the performance engine for the **Foundational Context Layer (FCL)**.
It turns persistent project DNA (`.faf`) into native-everywhere context operations.

Measured on a 2019 iMac (Intel i5-7360U @ 2.30 GHz):
**native `score` 683 ns · `validate` 5.8 ns · `tier` 2.64 ns.**
Live demo runs the same WASM in your browser — click to verify.

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

## Quickstart (30 seconds)

```bash
# Coming soon — npm package
npm install faf-zeph
```

```js
import { loadContext } from 'faf-zeph';

const ctx = await loadContext('./project.faf');
console.log(ctx.score);           // 94
console.log(ctx.getSection('DNA')); // < 5 μs
```

Or drop `cascade.wasm` (2.4 KB) directly into any WASM runtime — `fetch` + `instantiate` + call the packet you need.

## Benchmarks

Avg time per call (2019 iMac, Intel i5-7360U @ 2.30 GHz; same input fixtures across all runtimes).

| Packet              | Native (Zig ReleaseFast) | Node 22.22.2 | Bun 1.3.13 |
|---------------------|-------------------------:|-------------:|-----------:|
| `score` (5-slot)    |                  683 ns  |    3,162 ns  |  3,809 ns  |
| `validate` (32 B)   |                  5.8 ns  |       27 ns  |     29 ns  |
| `tier` (u8)         |                 2.64 ns  |     11.7 ns  |    9.5 ns  |

`validate` and `tier` sit deep under 20 ns on native — single-cycle-ish work, branch + load.
`score` is YAML-parse-bound; the WASM crossing adds ~3-5× over native on the work-heavy path.

Reproducibility:
- Native: `zig build benchmark`
- Node: `node benchmarks/bench_js.mjs`
- Bun: `bun benchmarks/bench_js.mjs`
- Browser: serve repo root (`python3 -m http.server`), open `docs/index.html`, click **RUN ZEPH💨**

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
- [x] 2.4 KB `cascade.wasm` shipping in `docs/` — native validate 5.8 ns, tier 2.64 ns, score 683 ns on 2019 iMac
- [x] Live browser demo runs all three packets — Vercel + GH Pages
- [x] FAFb v1 validation via `faf-rust-sdk` 2.0.x compatibility (format authority)
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