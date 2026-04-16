---
name: flutter-widget-docs
description: Generate Dart doc comments for Flutter widgets — documents constructor parameters, usage examples, and behavior notes in dartdoc format
---

Generate documentation comments for the Flutter widget(s) the user specifies.

## Step 1 — Read the widget

- If the user provides a file path, read the full file.
- If the user names a specific widget class, find it in the file and read from the class declaration through its `build` method.
- Understand: what the widget renders, what its constructor parameters control, and any notable behavior (animations, gestures, async loading).

## Step 2 — Document the class

Write a `///` dartdoc comment block above the class declaration:

```dart
/// A [WidgetName] that [one-sentence description of what it renders/does].
///
/// [2-3 sentences of context: when to use it, what problem it solves,
/// any important constraints or behaviors the caller should know about.]
///
/// {@tool snippet}
/// Basic usage:
///
/// ```dart
/// WidgetName(
///   requiredParam: value,
///   optionalParam: value,
/// )
/// ```
/// {@end-tool}
///
/// See also:
///  * [RelatedWidget], which [how it relates].
```

Rules:
- Lead with the widget name in brackets as a cross-reference
- Keep the first line to one sentence — it appears in IDE tooltips
- The `{@tool snippet}` block is optional but strongly recommended for widgets with non-obvious constructor usage
- The "See also" section is optional — include only if there is a meaningfully related widget

## Step 3 — Document the constructor

Write a `///` comment above the constructor (if it is not the default unnamed constructor):

```dart
/// Creates a [WidgetName].
///
/// The [requiredParam] must not be null and determines [what it affects].
```

Only document the constructor body if there is logic worth calling out (assertions, defaults that are non-obvious).

## Step 4 — Document each constructor parameter

Write a `///` comment above each parameter in the constructor:

```dart
const WidgetName({
  super.key,
  /// The label displayed below the icon. Defaults to an empty string.
  this.label = '',
  /// Called when the user taps the widget. If null, the widget is non-interactive.
  this.onTap,
  /// Controls the size of the icon. Must be positive.
  required this.iconSize,
});
```

Rules:
- One line per parameter is usually enough — expand only if the behavior is genuinely non-obvious
- For nullable callbacks (`VoidCallback?`), always say what happens when it is null
- For numeric parameters, note valid ranges or constraints if they exist
- Do not restate the type — dartdoc already shows it; focus on semantics

## Step 5 — Document public methods (if any)

For any public methods on a StatefulWidget's State or a custom widget class:

```dart
/// Resets the widget to its initial state.
///
/// Call this after [someEvent] to clear user input without rebuilding
/// the parent. This method calls [setState] internally.
void reset() { ... }
```

## Step 6 — Output format

- Show the full updated file with documentation added, or show only the documented sections if the file is large (offer to apply to the full file)
- Do not change any logic — only add/update `///` comments
- Preserve existing comments that are already accurate; only replace ones that are missing or wrong
- After showing the changes, offer to write them back to the file
