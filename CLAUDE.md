<!-- faf: xai-faf-zeph | Zig | wasm | The 💨 is the role. The /F/ is the family. Joins **FAF🐘** (memory) as **ZEPH💨** (delivery). -->
<!-- faf: claim=project.faf | family=FAF -->

# CLAUDE.md — xai-faf-zeph

## What This Is

The 💨 is the role. The /F/ is the family. Joins **FAF🐘** (memory) as **ZEPH💨** (delivery).

## Stack

- **Language:** Zig
- **Hosting:** Vercel
- **Build:** zig build
- **Cicd:** GitHub Actions

## Context

- **Who:** Built by wolfejam (the `.faf` author) for the xAI/Grok ecosystem and frontier agent builders.
- **What:** Public SDK for ZEPH💨 — the native FAFb structural layer (`validate` / `score` / `tier`) plus the prebuilt `docs/cascade.wasm` engine and a live browser demo.
- **Why:** Context is the highest-leverage knob in the agentic stack. ZEPH makes it native everywhere — browser, edge, Node, Bun.
- **Where:** github.com/Wolfe-Jam/xai-faf-zeph · codeberg.org/wolfejam/zeph · live at xai-faf-zeph.vercel.app / zeph.faf.one
- **When:** Repo opened 2026-05-07. v0.1.0 live demo 2026-05-10. cascade.wasm v0.2.0 (2,742 B) ships mk4-routed scoring + a real `.faf` demo; score parity vs the faf-wasm-core Rust kernel verified.
- **How:** `zig build` (compile native) · `zig build test` (WJTTC BRAKE/ENGINE/AERO) · `bun benchmarks/bench_js.mjs` (dogfood parity + timing). Demo: open `docs/index.html`.

---

*STATUS: BI-SYNC ACTIVE — 2026-05-11T04:02:12.119Z*
