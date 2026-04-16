# Claude Plugins — Architecture & Usage Guide

> A single GitHub repo serves as a **plugin marketplace** for Claude Code. Teams install only what is relevant to their project — one universal base layer, one project-specific layer on top.

---

## TL;DR — Who installs what

| Team | Plugins to install | Skills unlocked | Hooks active |
| ---- | ------------------ | --------------- | ------------ |
| **Every team** | `repo-essentials` | `humanize`, `code-review`, `security-audit`, `pr-description`, `changelog` | Block `.env`, block sensitive files, block force-push, audit log |
| **Next.js teams** | `repo-essentials` + `nextjs-essentials` | All of above + `nextjs-review`, `nextjs-perf` | All of above + block `next.config` edits, block `.env.local`, warn on `"use client"` in layouts |
| **Flutter teams** | `repo-essentials` + `flutter-essentials` | All of above + `flutter-review`, `flutter-widget-docs` | All of above + block `pubspec.yaml` writes, block Android signing files, warn on missing `dispose()` |

---

## The Big Picture

```
github.com/your-org/repo-essentials          ← one repo, one marketplace
│
├── One marketplace.json                     ← lists all plugins
│
├── repo-essentials/        ← installed by EVERYONE
│   ├── Universal safety guardrails
│   ├── Writing & review skills
│   └── Git discipline hooks
│
├── nextjs-essentials/      ← installed by NEXT.JS teams only
│   ├── App Router / Server Component review
│   ├── Performance audit
│   └── Next.js-specific hooks
│
└── flutter-essentials/     ← installed by FLUTTER teams only
    ├── Widget & Dart review
    ├── Widget documentation generator
    └── Flutter-specific hooks
```

The key insight: **hooks are filename-aware, not directory-aware.** A Flutter hook only fires when a Flutter-specific file is touched (`pubspec.yaml`, `*.jks`). A Next.js hook only fires on Next.js-specific files (`next.config.ts`, `.env.local`, `layout.tsx`). This means a monorepo project — one that contains multiple Next.js apps or packages — can install `nextjs-essentials` once and have it cover the entire repo without any extra configuration.

---

## Repository Structure (Full)

```
repo-essentials/                            ← GitHub repo root
│
├── .claude-plugin/
│   └── marketplace.json                    ← Marketplace index (lists all 3 plugins)
│
├── repo-essentials/                        ← Plugin 1: Universal
│   ├── .claude-plugin/
│   │   └── plugin.json
│   ├── skills/
│   │   ├── humanize/
│   │   │   └── SKILL.md
│   │   ├── code-review/
│   │   │   └── SKILL.md
│   │   ├── security-audit/
│   │   │   └── SKILL.md
│   │   ├── pr-description/
│   │   │   └── SKILL.md
│   │   └── changelog/
│   │       └── SKILL.md
│   ├── hooks/
│   │   └── hooks.json
│   └── scripts/
│       ├── block-env-files.sh
│       ├── block-sensitive-files.sh
│       ├── block-risky-git.sh
│       └── audit-log.sh
│
├── nextjs-essentials/                      ← Plugin 2: Next.js
│   ├── .claude-plugin/
│   │   └── plugin.json
│   ├── skills/
│   │   ├── nextjs-review/
│   │   │   └── SKILL.md
│   │   └── nextjs-perf/
│   │       └── SKILL.md
│   ├── hooks/
│   │   └── hooks.json
│   └── scripts/
│       ├── block-nextjs-env.sh
│       ├── block-nextjs-config.sh
│       └── warn-client-component.sh
│
└── flutter-essentials/                     ← Plugin 3: Flutter
    ├── .claude-plugin/
    │   └── plugin.json
    ├── skills/
    │   ├── flutter-review/
    │   │   └── SKILL.md
    │   └── flutter-widget-docs/
    │       └── SKILL.md
    ├── hooks/
    │   └── hooks.json
    └── scripts/
        ├── block-pubspec.sh
        ├── block-android-signing.sh
        └── warn-missing-dispose.sh
```

---

## Plugin 1 — `repo-essentials` (Universal Base)

> Install this on **every project**, regardless of stack. It enforces the fundamentals that apply everywhere: file safety, git discipline, and consistent writing quality.

### Skills

| Skill | Invoke with | What it does |
| ----- | ----------- | ------------ |
| `humanize` | `/humanize` | Rewrites error messages, UI labels, and comments to be warm, jargon-free, and positively framed |
| `code-review` | `/code-review` | Reviews a file or staged diff for correctness, readability, maintainability, and bugs |
| `security-audit` | `/security-audit` | Checks for hardcoded secrets, SQL injection, XSS, insecure patterns, and bad dependencies |
| `pr-description` | `/pr-description` | Generates a structured PR description from staged changes or a git diff |
| `changelog` | `/changelog` | Generates a Keep-a-Changelog entry from commits since the last tag |

### Hooks

```
Event         Matcher              Hook                        What it does
──────────────────────────────────────────────────────────────────────────────
PreToolUse    Write/Edit/MultiEdit  block-env-files.sh         Blocks writes to .env,
                                                               .env.local, .env.production,
                                                               .env.staging, etc.

PreToolUse    Write/Edit/MultiEdit  block-sensitive-files.sh   Blocks writes to .pem, .key,
                                                               .p12, .pfx, id_rsa, id_ed25519,
                                                               and other key/cert files

PreToolUse    Bash                  block-risky-git.sh         Blocks: git push --force / -f /
                                                               --force-with-lease
                                                               and git reset --hard

PostToolUse   Write/Edit/MultiEdit  audit-log.sh               Appends a timestamped record
                                                               to ~/.claude/plugin-data/
                                                               repo-essentials/audit.log
```

### MCP Servers

| MCP | Scope | What it provides |
| --- | ----- | ---------------- |
| `context7` | User-level | Live documentation for any library or SDK — fetches from source on demand |
| `filesystem` | Project-level | Scoped filesystem access for the workspace directory |

---

## Plugin 2 — `nextjs-essentials`

> Install on any project that contains a Next.js application — including monorepos with multiple Next.js apps and shared packages. The hooks are filename-aware and fire correctly across the whole repo without extra configuration.

### Skills

#### `nextjs-review` — `/nextjs-review`

Reviews Next.js-specific code patterns across the full App Router / Pages Router split.

| What it checks | Examples |
| -------------- | -------- |
| **Server vs Client boundaries** | `"use client"` used in a Server Component, browser APIs in a Server Component, unnecessary `"use client"` pushed high in the tree |
| **Data fetching** | `useEffect + fetch` in a Server Component, missing `cache` options on `fetch()`, `getServerSideProps` used in `app/` |
| **Route handlers** | Wrong Request/Response types, missing auth checks, hardcoded secrets |
| **Metadata** | Missing `metadata` export or `generateMetadata` on SEO-relevant pages |
| **Images & Links** | `<img>` instead of `next/image`, `<a href>` instead of `next/link`, missing `alt` |
| **Environment variables** | Server-only env vars referenced in Client Components, vars used without fallback |

#### `nextjs-perf` — `/nextjs-perf`

Audits a Next.js file or project for performance issues that affect Core Web Vitals.

| What it checks | Core Web Vital |
| -------------- | -------------- |
| Large libraries imported in Client Components without `next/dynamic` | — Bundle size |
| `getServerSideProps` used where ISR would be faster | — TTFB |
| `<Image>` without `priority` on above-the-fold content | LCP |
| `<Image>` without `width`/`height` or sized container | CLS |
| Fonts not using `next/font` | CLS |
| Google Fonts imported via CSS `@import` instead of `next/font/google` | CLS |
| Missing `Suspense` boundaries around async Client Components | INP |
| Heavy event handlers without `startTransition` | INP |

### Hooks

```
Event         Matcher              Hook                        What it does
──────────────────────────────────────────────────────────────────────────────────
PreToolUse    Write/Edit/MultiEdit  block-nextjs-env.sh        Blocks writes to .env.local,
                                                               .env.production.local,
                                                               .env.development.local,
                                                               .env.test.local

PreToolUse    Write/Edit/MultiEdit  block-nextjs-config.sh     Blocks writes to next.config.js /
                                                               .ts / .mjs — explains the risks
                                                               (routing, secret exposure, webpack)
                                                               and asks user to apply manually

PostToolUse   Write/Edit/MultiEdit  warn-client-component.sh   After writing layout.tsx or
                                                               page.tsx: warns if "use client"
                                                               was added at this level, explains
                                                               the subtree impact, and suggests
                                                               extracting to a leaf component
```

### Works across Next.js monorepos

```
my-nextjs-monorepo/
├── apps/
│   ├── app-one/
│   │   ├── next.config.ts        ← block-nextjs-config.sh fires ✓
│   │   ├── .env.local            ← block-nextjs-env.sh fires ✓
│   │   └── app/layout.tsx        ← warn-client-component.sh fires ✓
│   └── app-two/
│       ├── next.config.ts        ← block-nextjs-config.sh fires ✓
│       ├── .env.local            ← block-nextjs-env.sh fires ✓
│       └── app/layout.tsx        ← warn-client-component.sh fires ✓
└── packages/
    ├── ui/                       ← no Next.js-specific files → hooks stay silent ✓
    └── utils/                    ← no Next.js-specific files → hooks stay silent ✓
```

One plugin install covers both apps and all packages. No per-app configuration needed.

---

## Plugin 3 — `flutter-essentials`

> Install on any Flutter project. The hooks protect the two most common sources of Flutter project breakage: `pubspec.yaml` accidental mutations and Android signing credential exposure.

### Skills

#### `flutter-review` — `/flutter-review`

Reviews Flutter/Dart code for correctness, safety, and idiomatic patterns.

| What it checks | Examples |
| -------------- | -------- |
| **Null safety** | Unsafe `!` assertions, uninitialized `late` variables, `dynamic` where type is known |
| **Widget build hygiene** | Heavy computation in `build()`, deeply nested trees, `print()` in lifecycle methods |
| **StatefulWidget patterns** | `setState()` after `dispose()`, missing `mounted` check after `await`, missing `dispose()` for controllers |
| **Keys** | Missing keys in dynamic lists, `UniqueKey()` created inside `build()` |
| **State management** | `setState` for cross-widget state, `Provider.of` without `listen: false` in callbacks, stale `BuildContext` after async gap |
| **Performance** | Missing `const` constructors, `ListView` without `.builder`, `Image.network` without size hints |
| **Dart idioms** | C-style loops, `forEach` with `await` inside, string concat in loops, unsafe `as` casts |

#### `flutter-widget-docs` — `/flutter-widget-docs`

Generates Dart doc comments (`///`) for Flutter widgets in `dartdoc` format.

| What it generates | Format |
| ----------------- | ------ |
| Class-level doc | One-sentence description + usage context + `{@tool snippet}` code example + See also |
| Constructor doc | Summary line + parameter constraints |
| Per-parameter doc | Semantic description, null-callback behavior, valid ranges |
| Public method docs | Purpose, side effects, when to call |

### Hooks

```
Event         Matcher              Hook                        What it does
──────────────────────────────────────────────────────────────────────────────────
PreToolUse    Write/Edit/MultiEdit  block-pubspec.sh           Blocks direct writes to
                                                               pubspec.yaml — explains the risk
                                                               of accidental dep removal and
                                                               suggests: flutter pub add/remove

PreToolUse    Write/Edit/MultiEdit  block-android-signing.sh   Blocks writes to key.properties,
                                                               *.jks, *.keystore — signing
                                                               credentials must never be
                                                               AI-edited

PostToolUse   Write/Edit/MultiEdit  warn-missing-dispose.sh    After writing a .dart file:
                                                               checks if a controller was
                                                               instantiated (TextEditingController,
                                                               AnimationController, etc.) without
                                                               a dispose() override — the most
                                                               common Flutter memory leak
```

---

## How Plugins Layer Together

```
                    ┌─────────────────────────────────────┐
                    │         repo-essentials              │
                    │  (Universal — install everywhere)    │
                    │                                      │
                    │  Skills:  humanize                   │
                    │           code-review                │
                    │           security-audit             │
                    │           pr-description             │
                    │           changelog                  │
                    │                                      │
                    │  Hooks:   block .env writes          │
                    │           block key/cert files       │
                    │           block force-push           │
                    │           audit log on writes        │
                    │                                      │
                    │  MCPs:    context7                   │
                    │           filesystem                 │
                    └────────────────┬────────────────────┘
                                     │
               ┌─────────────────────┴──────────────────────┐
               │                                            │
               ▼                                            ▼
  ┌─────────────────────────┐              ┌─────────────────────────┐
  │    nextjs-essentials     │              │   flutter-essentials    │
  │  (Next.js teams only)    │              │  (Flutter teams only)   │
  │                          │              │                         │
  │  Skills:                 │              │  Skills:                │
  │    nextjs-review         │              │    flutter-review       │
  │    nextjs-perf           │              │    flutter-widget-docs  │
  │                          │              │                         │
  │  Hooks:                  │              │  Hooks:                 │
  │    block .env.local      │              │    block pubspec.yaml   │
  │    block next.config     │              │    block signing files  │
  │    warn "use client"     │              │    warn missing dispose │
  │    in layouts            │              │                         │
  └─────────────────────────┘              └─────────────────────────┘
```

---

## Development Flow

```
 ┌──────────────────────┐      ┌──────────────────────┐      ┌──────────────────────┐      ┌──────────────────────┐
 │   1. ORG SETUP       │      │  2. PROJECT SETUP    │      │  3. DEV ONBOARDING   │      │  4. CODING SESSION   │
 │      (done once)      │      │    (once per repo)   │      │   (once per machine) │      │    (every session)   │
 ├──────────────────────┤      ├──────────────────────┤      ├──────────────────────┤      ├──────────────────────┤
 │                      │      │                      │      │                      │      │                      │
 │ Create & push to     │      │ In your project      │      │ Add the marketplace: │      │ Claude Code starts   │
 │ GitHub:              │      │ repo root:           │      │                      │      │                      │
 │                      │      │                      │      │  /plugin marketplace │      │ Auto-loads:          │
 │ repo-essentials/     │      │  CLAUDE.md           │      │  add lohith-CC/      │      │                      │
 │  ├ repo-essentials   │      │  ─────────────────   │      │  repo-essentials     │      │  ✓ CLAUDE.md         │
 │  ├ nextjs-essentials │─────▶│  · project stack     │─────▶│                      │─────▶│    project rules &   │
 │  └ flutter-essentials│      │  · conventions       │      │ Install plugins:     │      │    conventions       │
 │                      │      │  · hard rules        │      │                      │      │                      │
 │ marketplace.json     │      │  · architecture      │      │  repo-essentials     │      │  ✓ Skills            │
 │ lists all 3 plugins  │      │                      │      │  + nextjs-ess.       │      │    /code-review      │
 │                      │      │ Committed to your    │      │    or flutter-ess.   │      │    /security-audit   │
 │                      │      │ project repo, not    │      │                      │      │    /pr-description…  │
 │                      │      │ the plugin repo      │      │                      │      │                      │
 │                      │      │                      │      │                      │      │  ✓ Hooks auto-fire   │
 │                      │      │                      │      │                      │      │    on every write    │
 │                      │      │                      │      │                      │      │                      │
 │                      │      │                      │      │                      │      │  ✓ MCPs active       │
 │                      │      │                      │      │                      │      │    context7…         │
 └──────────────────────┘      └──────────────────────┘      └──────────────────────┘      └──────────────────────┘
       Plugin source                 Project context              One-time install              All active together
```

> **Key distinction:** `CLAUDE.md` lives in your **project repo** and holds project-specific context (stack, conventions, rules). Plugins live in the **plugin marketplace repo** and provide reusable skills, hooks, and MCPs. Both are loaded automatically when a session starts — they complement each other.

---

## Installation Guide

### Step 1 — Add the marketplace (one-time, per machine)

```bash
/plugin marketplace add lohith-CC/repo-essentials
```

### Step 2 — Install based on your project type

**Next.js project (including monorepos with multiple Next.js apps):**
```
/plugin install repo-essentials@claude-plugins
/plugin install nextjs-essentials@claude-plugins
```

**Flutter project:**
```
/plugin install repo-essentials@claude-plugins
/plugin install flutter-essentials@claude-plugins
```

**Project with both Next.js and Flutter (mixed monorepo):**
```
/plugin install repo-essentials@claude-plugins
/plugin install nextjs-essentials@claude-plugins
/plugin install flutter-essentials@claude-plugins
```

### Step 3 — Optional: pre-configure for your team

Add to your project's `.claude/settings.json` so teammates skip Step 1:

```json
{
  "extraKnownMarketplaces": {
    "claude-plugins": {
      "source": {
        "source": "github",
        "repo": "lohith-CC/repo-essentials"
      }
    }
  }
}
```

With this in the repo, teammates only need Step 2.

---

## Design Decisions

**Why one marketplace repo, not three separate repos?**
One marketplace URL to share, one place to send PRs, one version history. Teams add one marketplace and cherry-pick the plugin they need.

**Why keep repo-essentials separate instead of bundling everything into nextjs-essentials?**
A Next.js developer who fixes a typo in a README still benefits from `humanize`, `pr-description`, and the `.env` guard. Those are not Next.js concerns — they are universal development concerns. Bundling them into a stack-specific plugin would mean Flutter teams miss out on them unless they also install the Next.js plugin, which makes no sense.

**Why can't a plugin declare another plugin as a dependency?**
Claude Code's plugin system intentionally has no dependency resolution — installations are always explicit. This is a security and control decision. The workaround: document install order clearly (this guide), and optionally check in `extraKnownMarketplaces` to your repo so the marketplace step is automatic.

**Why are hooks filename-based rather than directory-based?**
It makes them work correctly in monorepos without any per-project configuration. The trade-off: if you ever need a hook to apply only under a specific subdirectory, add a path-prefix check (`[[ "$FILE" != */apps/web/* ]] && exit 0`) to the relevant script.
