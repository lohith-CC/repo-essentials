---
name: nextjs-perf
description: Audit a Next.js project or file for performance issues — bundle size, rendering strategy, image/font loading, caching, and Core Web Vitals impact
---

Audit the Next.js code the user provides for performance issues that affect load time, Core Web Vitals, and user experience.

## Step 1 — Establish scope

- If the user provides a file path, read it.
- If the user says "whole project", scan: `app/` or `pages/`, `components/`, `next.config.js`/`next.config.ts`.
- Run `cat next.config.js` (or `next.config.ts`) to understand current config.

## Step 2 — Bundle size and imports

### Heavy imports
- Flag `import * as _ from 'lodash'` — should be `import debounce from 'lodash/debounce'` (tree-shaking)
- Flag large libraries imported in Client Components that are not needed at page load (e.g., chart libraries, rich text editors) — suggest `next/dynamic` with `{ ssr: false }`
- Flag `moment` — suggest `date-fns` or `dayjs` (much smaller)

### Dynamic imports
- Look for large components rendered conditionally — suggest `next/dynamic` so they are only loaded when shown
- Check that `next/dynamic` is used with a `loading` fallback to prevent layout shift

## Step 3 — Rendering strategy

- Flag pages using `getServerSideProps` (SSR) for content that does not change per-request — suggest `getStaticProps` with `revalidate` (ISR) instead
- Flag App Router pages with `cache: 'no-store'` on all fetches when some data could be cached — suggest splitting fetches by freshness requirement
- Flag missing `generateStaticParams` for dynamic routes with known param sets — they should be statically generated at build time

## Step 4 — Images

- Flag `<img>` tags — `next/image` gives automatic WebP conversion, lazy loading, and size optimization
- Flag `<Image>` without `priority` on above-the-fold images (hero images, LCP candidates) — missing `priority` causes lazy loading where eager loading is needed
- Flag `<Image>` with `priority` on below-the-fold images — wastes preload bandwidth
- Flag images without `sizes` prop when using `fill` or responsive layouts — causes oversized image downloads on mobile

## Step 5 — Fonts

- Flag `@import url('https://fonts.googleapis.com/...')` in CSS — use `next/font/google` instead for self-hosted, zero-CLS font loading
- Flag fonts loaded without `display: 'swap'` — can cause invisible text during load (FOIT)
- Flag multiple font families loaded on the same page without subsetting — suggest `subsets: ['latin']`

## Step 6 — Caching and headers

- Check `next.config` for `headers()` config — flag missing `Cache-Control` on static asset routes
- Flag API routes that return dynamic data without any cache headers when the data could be cached for even a few seconds
- Flag missing `revalidatePath` or `revalidateTag` calls after mutations in Server Actions — stale cache after writes

## Step 7 — Core Web Vitals

### LCP (Largest Contentful Paint)
- Flag hero images or above-the-fold content not using `priority` on `<Image>`
- Flag large inline SVGs that block rendering

### CLS (Cumulative Layout Shift)
- Flag images without explicit `width`/`height` or `fill` + sized container — causes layout shift as image loads
- Flag fonts without `font-display: swap` or `next/font`
- Flag dynamically injected content above existing content

### INP (Interaction to Next Paint)
- Flag heavy computations in event handlers without `useDeferredValue` or `startTransition`
- Flag large Client Component trees that could be split to reduce hydration cost

## Step 8 — Format the report

### Performance Score
[One-line overall assessment: what's the biggest win available?]

### Critical Issues (high impact, fix first)
For each issue:
- **Location**: file:line
- **Impact**: Which Core Web Vital or metric is affected, and estimated severity
- **Fix**: Concrete corrected code or config

### Improvements (medium impact)
Same format.

### Quick Wins (low effort, good return)
Bullet list — no need for full format on minor items.
