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

```bash
zig version 0.14+ required
zig build          # builds native + WASM
zig build test     # full suite
zig build benchmark -- 2019-imac   # reproduces the 169 μs numbers
```

WASM target:
```bash
zig build -Dtarget=wasm32-freestanding
```

## Issue labels (use them)

- `xai-priority` — xAI team needs this yesterday
- `colossus-scale` — affects distributed / high-end deployment
- `perf-regression` — any change that moves the microsecond numbers
- `rfc` — proposed change to format, API, or integration surface
- `good first issue` — safe entry points for new contributors

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

---

**ZEPH💨 — Context as breeze.**  
We cook together. ⚡

*Maintained with ❤️ by the FAF family + xAI collaborators*