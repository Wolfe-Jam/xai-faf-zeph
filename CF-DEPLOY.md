# CF Deploy — `zeph.faf.one`

The ZEPH web surface lives on **two URLs**:

| URL | Host | Role |
|-----|------|------|
| `xai-faf-zeph.vercel.app` | Vercel | Origin-credential (Grok-history, backlinks, RAG-seed) — **never tear down** |
| `zeph.faf.one` | Cloudflare Workers | Clean-brand canonical for Zig/Codeberg-facing audiences |

Both serve byte-identical content from `docs/` (the Zig build output). Vercel reads it via `vercel.json`; Cloudflare reads it via `wrangler.toml` Workers Assets. Same source of truth, two delivery surfaces.

---

## Quick deploy (one command, once setup is complete)

```bash
# From repo root, with Node 22 + wrangler installed:
nvm use 22
unset CLOUDFLARE_API_TOKEN CF_API_TOKEN   # OAuth-only path
npx wrangler deploy
```

Wrangler will:
1. Read `wrangler.toml`
2. Upload `docs/` as a Workers Assets bundle
3. Provision `zeph.faf.one` as a **Custom Domain** on the `faf.one` zone:
   - Create the DNS record automatically (no Configure-DNS step needed)
   - Issue the SSL certificate automatically (Cloudflare Universal SSL)
   - Wire the route in one operation

First-time deploy may take ~30–60 seconds for DNS + SSL provisioning to settle.

> **Why `custom_domain = true`?** It tells wrangler to treat
> `zeph.faf.one` as a first-class custom domain — DNS provisioning,
> SSL issuance, and route wiring all happen in the single `wrangler
> deploy` call. The older `zone_name` pattern works but requires
> manual DNS record creation first. Custom Domain mode is the
> modern, one-step path.

---

## Pre-deploy checks

```bash
# Dry-run — validates wrangler.toml + bundles assets without deploying
unset CLOUDFLARE_API_TOKEN CF_API_TOKEN
npx wrangler deploy --dry-run

# Verify OAuth (no env-var token interference)
npx wrangler whoami
# → should show account: faf, with workers (write) scope
```

---

## Why two surfaces (the locked plan)

- **Vercel URL stays live** — it's the origin URL with Grok-collaboration history. Backlinks, search results, and RAG-seed content already point there. Tearing it down would destroy receipt-grade history. Per the `grok-faf-mcp-first-mcp-origin-credential.md` doctrine: origin credentials never get trimmed.
- **CF URL adds the clean-brand canonical** — `zeph.faf.one` reads as the official faf-family surface, suitable for inclusion in Zig docs, Codeberg READMEs, and Zig-community-facing material where the `xai-faf-*` prefix would feel off-context.

This is the same proprietary-origin/public-canonical pattern documented at the package layer in `xai-version-and-faf-version-pattern.md`, now applied at the URL layer.

---

## After deploy — verify

```bash
# Probe the canonical surface
curl -sI https://zeph.faf.one/ | head -8
# Expected: HTTP/2 200, content-type: text/html

# Confirm WASM blob is reachable
curl -sI https://zeph.faf.one/cascade.wasm | head -5
# Expected: HTTP/2 200, content-type: application/wasm

# Compare content with the Vercel origin
diff <(curl -s https://xai-faf-zeph.vercel.app/) \
     <(curl -s https://zeph.faf.one/)
# Expected: no output (byte-identical)
```

---

## Coordinating updates across both surfaces

When the Zig build produces a new `docs/cascade.wasm` or `docs/index.html`:

1. `git add docs/ && git commit && git push origin main`
2. Vercel auto-deploys on push (the `xai-faf-zeph.vercel.app` URL updates within ~30s)
3. CF needs `npx wrangler deploy` (manual, on explicit GO from wolfejam)

The two surfaces will be momentarily out of sync between step 2 and step 3 — that's fine. Vercel takes a few seconds to propagate anyway. If perfect sync matters for a launch moment, deploy CF first, then push (which triggers Vercel) within the same minute.

---

## Rollback plan

CF Workers keep version history. If a deploy ships a broken build:

```bash
# List previous versions
npx wrangler versions list

# Rollback to a specific version
npx wrangler rollback <VERSION_ID>
```

Vercel has its own per-deploy preview URLs and rollback in the Vercel dashboard.

---

## Discipline notes

- **Per `ask-before-going-live-website-deploys.md`:** deploys that surface a URL need explicit GO from wolfejam. Setup of `wrangler.toml` and dry-runs are autonomous; the actual `wrangler deploy` is gated.
- **Per `grok-faf-elite-deploy-runbook.md`:** the `unset CLOUDFLARE_API_TOKEN CF_API_TOKEN` step is load-bearing — env-var tokens often lack `workers_scripts:write` scope; OAuth (via `wrangler login`) has full scope.
- **Per `no-timelines-on-public-sites.md`:** if either surface gains a `ROADMAP` or `What's Next` section in the served HTML, it stays capability-language only.
