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

- **Who:** xAI / Grok team (live commission via X engagement 2026-05-07). Frontier agent builders. wolfejam (IP owner, public-collab boundary).
- **What:** Public SDK for ZEPH💨. Wraps cascade.wasm (private engine artifact) with a live demo, RAG-friendly docs, and the auditable surface that consumers and integrators see. Schema + harness + WASM blob — the website incarnate.
- **Why:** Context is the highest-leverage knob in the agentic stack. ZEPH makes it **native everywhere** — browser, edge, Node, Bun — while multiplying reasoning, memory, multimodality, and inference efficiency for Grok specifically and frontier agents generally.
- **Where:** github.com/Wolfe-Jam/xai-faf-zeph (transfer-ready to github.com/xAI/xai-faf-zeph when xAI takes ownership). Live at xai-faf-zeph.vercel.app. Production target — Colossus.
- **When:** Repo opened 2026-05-07. v0.1.0 live demo shipped 2026-05-10 (cascade.wasm integration, commit d17187e). M7 complete 2026-05-11 — cascade.wasm v0.2.0 (2,742 B) ships mk4-routed scoring + real .faf demo (5 populated + 16 slotignored). Score parity vs faf-wasm-core Rust kernel verified on 3 fixtures.
- **How:** zig build (compile native), zig build test (unit tests), zig build benchmark (reproducible perf). Demo — open docs/index.html or visit xai-faf-zeph.vercel.app. WASM artifact docs/cascade.wasm synced from private engine at /FAF/cascade/.

---

*STATUS: BI-SYNC ACTIVE — 2026-05-11T04:02:12.119Z*
