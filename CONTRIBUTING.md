# Contributing to ZEPH💨

**ZEPH — clipped from Zephyrus, Greek god of the west wind.**  
The 💨 is the role. The /F/ is the family.

This repository is the **ongoing public collaboration channel** between the .faf author, the xAI team, and the broader community. It is not a finished product — it is the workspace where we take Context Ultra to Colossus together.

**Peer relationship, not vendor/client.** The team and I build side-by-side.

## How to contribute

### 1. For the xAI team (priority lane)
- Open any issue with the `xai-priority` label — it jumps the queue.
- Comment directly on RFCs or performance regressions.
- Propose changes to Grok integration paths at any time.
- Request maintainer status or repo transfer to `github.com/xAI/xai-faf-zeph` whenever ready (the path is already prepared).

### 2. For everyone else
- **Performance first**: All changes must include before/after microbenchmark numbers (see `/benchmarks`).
- **Compatibility second**: No breaking changes to FAFb v1/v2 or existing `.faf` files without RFC.
- **Small & focused PRs**: One experiment, one feature, one doc improvement per PR.
- Use the issue templates (especially `xai-priority` and `perf-regression`).

## Development setup

Zig 0.16+ required (`build.zig` uses the post-0.15 `addLibrary` / `createModule` API).

```bash
zig build           # builds native lib + WASM (zig-out/bin/zeph.wasm)
zig build test      # full WJTTC suite
zig build benchmark # skeleton harness (real perf harness lands in Phase 2)
```

WASM size optimization (post-build):
```bash
wasm-opt -Oz --strip-debug zig-out/bin/zeph.wasm -o docs/zeph.wasm
```

## Issue labels (use them)

- `xai-priority` — xAI team needs this yesterday
- `colossus-scale` — affects distributed / high-end deployment
- `perf-regression` — any change that moves the microsecond numbers
- `rfc` — proposed change to format, API, or integration surface
- `good first issue` — safe entry points for new contributors

## WJTTC test convention (4-tier discipline)

Test names in `src/` and `benchmarks/` follow the FAF-family WJTTC tier convention. Prefix each test with its tier so the suite tells you what *kind* of confidence you have at a glance:

- **BRAKE**  — ABI / memory safety / error paths (the test that catches you when something breaks)
- **ENGINE** — core functionality (parse / validate / score / retrieve correctness)
- **AERO**   — optimization (size / speed / allocation count / cache behaviour)
- **PIT**    — setup / teardown / fixtures / harness plumbing

Example: `test "BRAKE: parser rejects truncated header"`, `test "ENGINE: section retrieval round-trips"`, `test "AERO: full parse stays under 200 μs"`.

Convention only — no framework dependency. A `/wjttc` skill (planned) will audit the suite and report tier balance / coverage gaps that `zig test` alone cannot.

## RFC process (required for impactful changes)

1. Open issue with `rfc` label describing the change and why.
2. 7-day comment window (xAI team gets veto or fast-track).
3. PR only after consensus or explicit xAI approval.
4. Changes touching Grok context injection or FAFb spec require xAI sign-off.

## Sigil doctrine (cultural)

Every FAF-family brand mark earns a one-character role-compression sigil:
- FAF🐘 — never forgets (foundational memory)
- ZEPH💨 — never delays (ultra delivery)

The mark is the name. The sigil is the function. Use them proudly in docs, demos, and tweets.

## Code of conduct

- Assume best intent.
- Performance is the north star, but correctness and compatibility are non-negotiable.
- Credit is shared. When xAI ships something powered by ZEPH, we celebrate together.

## Contact / escalation

- For xAI-internal matters: open private issue or tag `@Wolfe-Jam` in the thread.
- For public technical discussion: use this repo’s issues and discussions.
- Reference thread: https://x.com/wolfe_jam/status/2036534380215050638

## Contributors

**wolfejam** ([@Wolfe-Jam](https://github.com/Wolfe-Jam)) — repo, code, formats, ideas.

Two AI contributors:
- **Grok 4.3** (xAI)
- **Claude Opus 4.7** (Anthropic)

---

**ZEPH💨 — Context as breeze.**  
We cook together. ⚡

*Maintained with ❤️ by the FAF family + xAI collaborators*