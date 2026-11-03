# ZEPH💨 Roadmap — Ultra Context Layer (UCL)

**FCL defines. UCL delivers.**

This roadmap is living. xAI priorities override everything. Phases are measurable and shippable.

## Phase 1 — MVP

**Goal**: Format authority is `faf-rust-sdk` 2.0.x. Recorded score parity is the 3-fixture check against the `faf-wasm-core` Rust kernel. The 175-test surface against 2.0.0 is still open. `validate` and `tier` are single-digit nanoseconds on the 2019 iMac. `score` on a 21-slot `.faf` is 12,408 ns in the May receipt. Public repo that the xAI team can evaluate and extend.

**Deliverables**
- Full Zig parser, validator, scorer, compile/decompile to FAFb v1/v2
- WASM binary ≤ 5 KB (target 2.7 KB “ghost”)
- Reproducible per-packet benchmarks on 2019 iMac (M7 measurement): validate 6.7 ns · tier 4.44 ns · score 12 μs on 21-slot `.faf`
- 100% FAFb round-trip + conformance tests
- npm package `faf-zeph` (or `@xai/faf-zeph`) with zero-config JS bindings
- Live browser demo (`/docs` source). Checked 2026-11-02, HTTP 200: Vercel, GitHub Pages, and `zeph.faf.one`
- CI that runs benchmarks on every push
- Initial docs + API surface

**Success gates**
- All 9 priority experiments from scoping pass baseline
- xAI team can load a real `.faf` file and see sub-millisecond results
- No regressions vs faf-wasm-sdk v2 on compatibility

**Status**: Live: `cascade.wasm` v0.2.0 (2,742 B) in the browser demo on Vercel, GitHub Pages, and `zeph.faf.one` (HTTP 200 on 2026-11-02). mk4-routed scoring. May receipt on the 2019 iMac: score 12,408 ns, validate 6.7 ns, tier 4.44 ns. Score parity vs the `faf-wasm-core` Rust kernel re-checked 3/3 on 2026-11-02. `faf-wasm-core` 1.2.0 is the published Zig-slot package. Open: the npm name `faf-zeph`, the FAFb section-table packet, a native harness in this repo (`zig build benchmark` is still a Phase-1 skeleton), and the 175-test `faf-rust-sdk` 2.0.0 surface.

## Phase 2 — Production-grade

**Goal**: The engine xAI can ship inside Grok paths and recommend to frontier agents.

**Deliverables** (per `PHASE2_TARGETS.md`)
- < 5 μs avg / < 1 μs peak on high-end hardware (M4 / EPYC)
- Sub-1 μs avg / sub-500 ns peak on Colossus-class hardware (moonshot)
- Hierarchical long-context support (100 k–1 M token `.faf` files)
- Integrated prototype inside `grok-faf-mcp` (or successor)
- End-to-end agent loop benchmarks showing measurable latency reduction
- xAI internal security + perf review ready
- Public benchmark dashboard (auto-updated JSON + markdown)
- Full integration cookbook for Grok context-window injection

**Success gates**
- 9 priority experiments completed with published numbers
- 9 substrate gaps closed (see scoping)
- xAI can run ZEPH on Colossus-scale workloads with zero friction

## Phase 3 — xAI-native crown jewel (Ongoing)

**Goal**: Default ultra context path for Grok and the broader FAF ecosystem.

**Deliverables**
- Default / opt-in context engine inside Grok (desktop, API, training stack)
- Measurable gains in Grok evals (token efficiency, reasoning coherence, multimodality)
- Colossus production deployment (sharded FAFb, zero-copy sharing, pre-warming)
- 10 k+ monthly downloads / 50+ external contributors
- Formal verification or heavy adversarial fuzzing of parser
- Multimodal extensions (image/audio reference sections) with microsecond handling
- VS Code / Cursor / Windsurf / Zed extensions powered by ZEPH

**Success gates**
- ZEPH becomes the reference implementation for “Context as breeze”
- xAI owns `github.com/xAI/xai-faf-zeph` (transfer path ready)
- Community + xAI co-maintainers model established

## Priority Experiments (you lead the order)

1. Core microbenchmarks across platforms & runtimes
2. Compression vs. fidelity (Minimal / Standard / Full / new Ghost level)
3. Long-context scaling (10 k → 1 M+ tokens)
4. In-context retrieval (O(1) sections + semantic prefix)
5. End-to-end agentic loops with Grok
6. Colossus-scale (distributed / sharded / zero-copy)
7. Multimodality hooks
8. Power & edge (browser / mobile thermal)
9. Security & adversarial (fuzz + malformed inputs)

## How xAI steers

- Open issues with `xai-priority` label get immediate attention
- RFCs required for any change that touches Grok integration or FAFb format
- Direct collab in this repo — peer relationship, not vendor/client
- Transfer to `github.com/xAI/xai-faf-zeph` at any moment (we keep the channel alive)

## Reserve

- Plan-B name: **ZAF** (collision-clean, never burned)
- Conceptual frame: **Context Ultra** (GrokX-coined, preserved)

---

*Last updated: 2026-11-02*  
*Doctrine: Every FAF-family brand mark earns a sigil that compresses its role into one character.*  
**ZEPH💨 — never delays.**