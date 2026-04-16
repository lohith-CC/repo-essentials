---
name: nextjs-review
description: Review Next.js code for App Router patterns, Server vs Client Component boundaries, data fetching correctness, and common Next.js pitfalls
---

Review the file or directory the user provides for Next.js-specific correctness and best practices.

## Step 1 — Establish scope

- If the user provides a file path, read it fully.
- If the user says "staged changes" or "diff", run `git diff --staged`.
- If no scope is given, check the current directory for Next.js files (`app/`, `pages/`, `components/`).

## Step 2 — Detect the router type

- Check for `app/` directory → App Router
- Check for `pages/` directory → Pages Router
- Apply the corresponding rules below. If both exist, flag it — mixed routing is a common source of confusion.

## Step 3 — App Router checks

### Server vs Client Component boundaries
- Files with `"use client"` at the top are Client Components — check that they do not import Server-only modules (`fs`, `path`, `server-only`, database clients)
- Files without `"use client"` are Server Components by default — check that they do not use browser APIs (`window`, `document`, `localStorage`), React hooks (`useState`, `useEffect`, `useContext`), or event handlers
- Look for unnecessary `"use client"` directives pushed too high in the tree — they convert entire subtrees; suggest moving them to the leaf component that actually needs interactivity

### Data fetching
- Server Components should use `async/await` with `fetch()` or ORM calls directly — not `useEffect` + `fetch`
- Check that `fetch()` calls include appropriate cache options: `{ cache: 'no-store' }` for dynamic data, `{ next: { revalidate: N } }` for ISR
- Flag missing `loading.tsx` or `error.tsx` for routes that do slow data fetching
- Flag `getServerSideProps` / `getStaticProps` used in `app/` — these are Pages Router only

### Route handlers (`app/api/`)
- Check that `Request` and `Response` use the Web API types, not Node `req`/`res`
- Look for missing `NextResponse` usage where response manipulation is needed
- Flag hardcoded secrets or direct DB calls without auth checks

### Metadata
- Check that `layout.tsx` or `page.tsx` exports a `metadata` object or `generateMetadata` function for SEO-relevant pages
- Flag missing `title` and `description` fields in metadata

## Step 4 — Pages Router checks

- Flag `getServerSideProps` used where `getStaticProps` + ISR would suffice (unnecessary SSR)
- Check that API routes in `pages/api/` validate the HTTP method before processing
- Flag missing `getStaticPaths` when `getStaticProps` is used with dynamic routes

## Step 5 — General Next.js checks (both routers)

### Images
- Flag `<img>` tags — should use `next/image` (`<Image>`) for automatic optimization
- Check that `<Image>` has `width`, `height`, or `fill` prop set
- Flag missing `alt` attributes on images

### Links and navigation
- Flag `<a href="...">` for internal routes — should use `next/link` (`<Link>`)
- Flag `router.push` called inside a Server Component (requires `"use client"`)

### Environment variables
- Flag any `process.env.SECRET_*` or similar server-only vars referenced in Client Components — they will be undefined at runtime and may be leaked if prefixed with `NEXT_PUBLIC_`
- Flag env vars used without a fallback where `undefined` would cause a crash

### Performance
- Flag large third-party libraries imported in Client Components that could be lazy-loaded with `next/dynamic`
- Flag missing `Suspense` boundaries around Client Components that do async work

## Step 6 — Format the review

### Summary
[1-2 sentences: overall assessment — router type detected, biggest strength, biggest concern]

### Issues (required changes)
For each issue:
- **Location**: file:line
- **Problem**: What is wrong and why it matters in Next.js
- **Fix**: Concrete corrected code

### Suggestions (optional improvements)
Same format — non-blocking improvements.

### Positives
[2-3 things done well]
