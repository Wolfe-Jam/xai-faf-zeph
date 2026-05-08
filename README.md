# ZEPH💨 — Ultra Context Layer (UCL)

**ZEPH — clipped from Zephyrus, Greek god of the west wind.**  
The 💨 is the role. The /F/ is the family. Joins **FAF🐘** (memory) as **ZEPH💨** (delivery).

> **FCL defines. UCL delivers.**  
> `.faf` is the substrate. **ZEPH is the engine.**

**Microsecond context ops for Grok and frontier agents — pure Zig → WASM, 269-byte ghost binary.**

ZEPH is the performance engine for the **Foundational Context Layer (FCL)**.  
It turns persistent project DNA (`.faf`) into **stupidly fast**, scalable, native-everywhere context operations.

Measured on a 2019 iMac: **169 μs avg / 3.36 μs peak** (full reproducible methodology in `/benchmarks`). Live demo also runs the WASM in your browser — measurements land in single-digit nanoseconds.

## Why ZEPH exists
Context is the highest-leverage knob in the agentic stack.  
ZEPH makes it **native everywhere** — browser, edge, Node, Bun, and (soon) Colossus — while multiplying reasoning, memory, multimodality, and inference efficiency for Grok specifically and frontier agents generally.

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

Or drop the `zeph.wasm` (269 B) directly into any WASM runtime.

## Benchmarks (live)

| Platform          | Avg (μs) | Peak (μs) | Binary Size | Notes                  |
|-------------------|----------|-----------|-------------|------------------------|
| 2019 iMac         | 169      | 3.36      | 269 B       | Measured baseline      |
| V8 (Chrome) live  | 0.004    | 0.017     | 269 B       | In-browser, click-and-verify |
| M3 MacBook        | —        | —         | 269 B       | Pending                |
| wasmtime          | —        | —         | 269 B       | Pending                |
| Colossus          | < 0.1    | < 0.02    | 269 B       | Targets per PHASE2_TARGETS.md |

Full reproducible suite in `/benchmarks`. Run with `zig build benchmark`.

## Architecture

- **FCL (Foundational Context Layer)**: `.faf` + SDKs — the *what* (project DNA)
- **UCL (Ultra Context Layer)**: ZEPH engine — the *speed* (this repo)

ZEPH is pure Zig compiled to WASM (with native fallback). Zero external dependencies. SIMD-friendly parser. O(1) section lookup via string table. FAFb binary format compatible with v1/v2.

## Repository as ongoing collaboration channel

This is **not a code drop**. It is the public, living workspace for the xAI team and contributors to take ZEPH to Colossus and beyond.

- Issues labeled `xai-priority`, `colossus-scale`, `perf-regression`
- RFC process for any change that affects Grok integration
- xAI team members welcome as maintainers at any time (transfer path to `github.com/xAI/xai-faf-zeph` ready)

See [CONTRIBUTING.md](CONTRIBUTING.md) and [ROADMAP.md](ROADMAP.md).

## Status

**Phase 1 MVP**

- [x] Scoping accepted
- [x] 169 μs avg / 3.36 μs peak on 2019 iMac (measured)
- [x] Real Zig-WASM in browser — 269 B blob, single-digit-ns ABI roundtrips
- [x] Live browser demo — Vercel + GH Pages
- [ ] Full parser + FAFb v1/v2 round-trip
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