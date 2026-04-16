---
name: flutter-review
description: Review Flutter/Dart code for widget tree correctness, state management patterns, null safety, performance anti-patterns, and Dart idioms
---

Review the Flutter/Dart file or directory the user provides for correctness and best practices.

## Step 1 — Establish scope

- If the user provides a file path, read it fully.
- If the user says "staged changes" or "diff", run `git diff --staged`.
- If no scope is given, look for `.dart` files in `lib/`.

## Step 2 — Null safety

- Flag `!` (null assertion operator) used where the value could reasonably be null at runtime — suggest null-aware alternatives (`?.`, `??`, `if (x != null)`)
- Flag `late` variables that are never guaranteed to be initialized before use
- Flag `dynamic` type used where a concrete type is known — loses null safety guarantees
- Flag missing null checks on values coming from external sources (JSON decoding, platform channels)

## Step 3 — Widget tree and build method

### Build method hygiene
- Flag heavy computation (sorting, filtering, parsing) done directly inside `build()` — it re-runs on every rebuild; move to `initState`, a `ValueNotifier`, or a state management layer
- Flag `print()` calls left in build methods or state lifecycle methods — use a logger
- Flag deeply nested widget trees (more than ~5 levels without extraction) — suggest extracting into named widget classes or builder methods

### Stateful widget patterns
- Flag `setState()` called after `dispose()` — causes "setState() called after dispose()" errors; check `mounted` before calling setState in async callbacks
- Flag `initState()` calling async methods without handling errors or checking `mounted` after `await`
- Flag `dispose()` missing when the widget creates controllers (`TextEditingController`, `AnimationController`, `ScrollController`, `FocusNode`) — memory leak

### Keys
- Flag lists of widgets rendered without keys when items can reorder or be removed — causes incorrect state retention
- Flag `UniqueKey()` used in `build()` — recreated every rebuild, forces widget remount; use `ValueKey` or `ObjectKey` instead

## Step 4 — State management

- Flag direct `setState` used for state that is shared across multiple widgets — suggest lifting state or using a state management solution
- Flag `Provider.of<T>(context)` without `listen: false` in callbacks/handlers — unnecessary rebuilds
- Flag `BuildContext` stored in a field and used after async gaps — may be deactivated; check `mounted` or use `context.mounted` (Flutter 3.7+)

## Step 5 — Performance

- Flag `const` missing on widgets that could be `const` — every eligible widget that isn't `const` is rebuilt unnecessarily
- Flag `ListView` without `.builder` for long or dynamic lists — loads all children at once
- Flag `Image.network` without `cacheWidth`/`cacheHeight` for images displayed at a fixed size — downloads full resolution unnecessarily
- Flag `Opacity` widget used for show/hide animation — use `AnimatedOpacity` or `Visibility` with `maintainState`

## Step 6 — Dart idioms

- Flag C-style for loops (`for (int i = 0; i < list.length; i++)`) where `for (final item in list)` or `.map()` is cleaner
- Flag `.forEach()` used where a `for` loop is clearer (especially with `await` inside — `forEach` doesn't await)
- Flag string concatenation in loops — use `StringBuffer`
- Flag `as` casts without a type check — prefer `is` check first or `as?`-style null-safe patterns

## Step 7 — Format the review

### Summary
[1-2 sentences: overall quality, biggest strength, biggest concern]

### Issues (required changes)
For each issue:
- **Location**: file.dart:line
- **Problem**: What is wrong and why it matters
- **Fix**: Concrete corrected Dart code

### Suggestions (optional improvements)
Same format — non-blocking.

### Positives
[2-3 things done well]
