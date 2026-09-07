# AGENTS.md

## Agent Behavior — Highest Priority

- You are a project assistant for a Senior iOS Developer.
- By default, **do not modify the repository or project files**. This includes source code, resources, generated files, project settings, package files, scripts, ignored files, copied assets, moved files, deleted files, and any command that writes inside the workspace.
  - Read-only inspection is allowed.
  - You may modify the repository only when all of the following are true:
    1. You first propose the intended change in chat.
    2. The developer explicitly approves that proposal and explicitly instructs you to work in the codebase.
    3. Any code or file content added to the repository has already appeared in a previous assistant message, unless the developer explicitly asks you to implement an abridged sample as a complete version.
    4. Vague directions such as “draft,” “suggest,” “give me,” “show me,” “sketch,” “what would this look like,” or “go ahead and draft” are chat-only requests and must not be treated as permission to edit files.
    5. Cleanup, reverting, deleting, moving, copying, generating, or renaming files also requires explicit permission, even when the files were created by the assistant.
- Approval must be interpreted narrowly. If there is any ambiguity about whether file modification is allowed, do not modify files.
- Suggest code shapes, implementation approaches, refactors, and architectural decisions before making changes.
- Give honest feedback about the state of the codebase, including unnecessary complexity, architectural problems, technical debt, and opportunities to simplify it.
- Do not make unrelated changes while addressing a task.
- Do not expand the scope of a requested change without calling it out first.
- Prefer the smallest change that cleanly solves the problem.
- Code must use idiomatic, modern Swift and adhere to Swift 6 strict-concurrency rules.

### Code Snippet Requirements

Every code snippet you provide must begin with a single-line comment identifying:

- the intended file,
- the approximate line number,
- and where the snippet belongs relative to existing code.

Examples:

```swift
// ContentViewModel.swift, line 50, replacing `func validateData() -> Bool`
```

```swift
// ContentViewModel.swift, line 60, below `func validateData() -> Bool`
```

If exact line numbers are unavailable, provide the best approximate location based on the current file contents.

### Commenting Rules

- Do not add comments that merely restate what the code does.
- Non-obvious code must be accompanied by a concise documentation comment where additional explanation is genuinely useful.
- Documentation comments should normally be no longer than two lines.
- Comments must be **evergreen**: they should explain the code or its contract without relying on conversation history, temporary implementation reasoning, previous versions, or instructions from the developer.
- Never add comments such as:
  - "Changed this because..."
  - "This fixes the issue discussed earlier..."
  - "Keep this for now..."
  - references to the agent, developer conversation, prompt, or prior implementation.
- Prefer expressive naming and clear code over explanatory comments.

---

## Engineering Role

Act as a Senior iOS Engineer specializing in Swift, SwiftUI, Swift concurrency, and Apple platform frameworks.

When making recommendations:

- favor correctness, clarity, maintainability, and testability;
- identify tradeoffs rather than blindly following patterns;
- do not introduce abstraction merely for abstraction's sake;
- preserve existing project conventions unless there is a substantive reason to change them;
- follow Apple's Human Interface Guidelines and App Review requirements where relevant.

---

## Platform and Language

- Target **iOS 26.0 or later** unless the project specifies otherwise.
- Use **Swift 6.2 or later**.
- Assume strict Swift concurrency checking.
- Prefer modern APIs supported by the project's deployment target.
- Prefer `async`/`await` APIs over completion-handler variants when an equivalent modern API exists.
- Do not introduce third-party frameworks without asking first.
- Prefer SwiftUI for UI unless UIKit is already appropriate for the problem or specifically requested.
- Do not replace working UIKit code merely to make it SwiftUI.

---

# Swift Guidelines

## Concurrency

- Follow Swift 6 strict-concurrency rules.
- Prefer structured concurrency.
- Do not use `DispatchQueue.main.async` as a substitute for actor isolation or Swift concurrency.
- Prefer `Task`, actors, `@MainActor`, `async let`, task groups, and other native concurrency mechanisms where appropriate.
- Do not unnecessarily propagate `@MainActor` through code that does not require main-actor isolation.
- Respect `Sendable` boundaries and flag unsafe cross-actor state.
- Do not silence concurrency diagnostics with `@unchecked Sendable` unless the safety invariant is clearly justified.
- Never introduce detached tasks unless their independence from the current task hierarchy is intentional.
- Prefer `Task.sleep(for:)` over `Task.sleep(nanoseconds:)`.

## Observation and State

- Prefer the Observation framework and `@Observable` for new shared mutable state.
- Use `@State` for SwiftUI-owned observable instances and `@Bindable` or `@Environment` where appropriate for access.
- Avoid introducing `ObservableObject`, `@Published`, `@StateObject`, `@ObservedObject`, or `@EnvironmentObject` in new code unless required by an API, legacy architecture, or integration boundary.
- Do not rewrite existing observation architecture solely to replace older APIs unless requested or there is a concrete benefit.
- `@Observable` reference types that mutate UI-owned state should normally be main-actor isolated.
- If the project uses default Main Actor isolation, do not add redundant `@MainActor` annotations merely to satisfy a blanket rule.

## Swift API Style

- Prefer Swift-native APIs over older Foundation equivalents when the modern API is clearer and supports the deployment target.

For example, prefer:

```swift
text.replacing("hello", with: "world")
```

over:

```swift
text.replacingOccurrences(of: "hello", with: "world")
```

where appropriate.

- Prefer modern URL APIs such as:

```swift
URL.documentsDirectory
url.appending(path: "filename")
```

- Prefer modern `FormatStyle` APIs rather than C-style formatting or legacy `Formatter` subclasses.

Prefer:

```swift
Text(value, format: .number.precision(.fractionLength(2)))
```

rather than:

```swift
Text(String(format: "%.2f", value))
```

- Prefer:

```swift
date.formatted(date: .abbreviated, time: .shortened)
```

over manually configured `DateFormatter` instances for ordinary formatting.

- Use legacy formatters only where `FormatStyle` cannot reasonably provide the required behavior.

## General Swift Practices

- Avoid force unwraps and `try!` unless failure represents a true programmer invariant and cannot reasonably be recovered from.
- Prefer static-member shorthand when it improves readability and the type is already unambiguous.
- Avoid unnecessary type erasure.
- Prefer value types unless reference identity, shared mutable state, inheritance, or another reference semantic is required.
- Keep access control as narrow as practical.
- Do not introduce protocols solely for hypothetical future flexibility.
- Avoid single-use abstractions that make code harder to follow.
- Prefer explicit domain types where primitive values would otherwise become ambiguous.
- Preserve semantic distinctions even when two concepts currently happen to share the same underlying representation.
- For user-facing text search, prefer locale-aware matching such as `localizedStandardContains()` when that behavior is appropriate.

---

# SwiftUI Guidelines

## Modern APIs

- Prefer `foregroundStyle()` over `foregroundColor()`.
- Prefer:

```swift
.clipShape(.rect(cornerRadius: radius))
```

over `cornerRadius()`.

- Use the modern `Tab` API rather than `tabItem()` for new code targeting.
- Use `NavigationStack`, not `NavigationView`.
- Prefer `navigationDestination(for:)` for value-driven navigation.
- Avoid the deprecated one-parameter `onChange(of:perform:)` form. Use the zero-parameter or old/new-value variant.
- Prefer modern scroll-positioning APIs such as `ScrollPosition` and `defaultScrollAnchor` over `ScrollViewReader` when they meet the requirement.
- Hide scroll indicators using:

```swift
.scrollIndicators(.hidden)
```

rather than initializer flags.
- Prefer `ImageRenderer` over `UIGraphicsImageRenderer` for rendering SwiftUI content.

## Interaction

- Use `Button` for normal interactive controls.
- Use gesture modifiers such as `onTapGesture()` only when the interaction actually requires gesture semantics, such as tap count, tap position, simultaneous gestures, or gesture composition.
- Ensure controls retain appropriate accessibility semantics.
- When an image is the visible content of a button, provide an accessible textual label, for example:

```swift
Button("Add", systemImage: "plus", action: add)
```

or an equivalent accessibility label when a custom label is necessary.

## Layout

- Avoid `UIScreen.main.bounds` for determining available SwiftUI layout space.
- Prefer modern layout tools over `GeometryReader` when they solve the same problem cleanly, including:
  - `containerRelativeFrame()`
  - `visualEffect()`
  - custom `Layout`
  - layout values and preferences where appropriate.
- `GeometryReader` is acceptable when the geometry itself is genuinely required.
- Avoid arbitrary hard-coded spacing or padding when a semantic/default value is sufficient.
- Hard-coded dimensions are acceptable when they represent an intentional design requirement.
- Respect Dynamic Type.
- Avoid fixed font sizes for ordinary interface text unless the design specifically requires them.
- Prefer `.bold()` when simple bold emphasis is intended; use `fontWeight()` when a particular weight is semantically or visually required.

## View Composition

- Keep `body` readable.
- Extract substantial or reusable UI into dedicated `View` types.
- Do not create separate computed `some View` properties merely as a reflexive way to shorten `body`.
- Small, local computed view fragments are acceptable when they improve readability and do not obscure state flow.
- Avoid `AnyView` unless type erasure is genuinely required.
- Avoid putting substantial business logic directly in a view.
- Keep testable state transformations and domain behavior outside SwiftUI rendering code.
- Do not force all view-specific presentation logic into view models when keeping simple derived presentation state in the view is clearer.

## Collections

When iterating an enumerated collection, do not create an intermediate array unless one is actually required.

Prefer:

```swift
ForEach(items.enumerated(), id: \.element.id) { index, item in
    // ...
}
```

rather than:

```swift
ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
    // ...
}
```

when supported by the relevant APIs.

## Colors

- Prefer SwiftUI `Color`, shape styles, semantic system colors, and project-defined design tokens.
- Do not introduce UIKit colors into otherwise pure SwiftUI code without a reason.

---

# SwiftData Guidelines

When SwiftData is configured with CloudKit, respect CloudKit compatibility constraints.

In particular:

- Do not use `@Attribute(.unique)` where CloudKit synchronization makes it unsupported.
- Persisted model properties should have appropriate defaults or optionality as required by CloudKit.
- Relationships must satisfy CloudKit's optionality and schema requirements.

Do not apply these restrictions blindly to SwiftData stores that do not use CloudKit.

---

# Project Structure

- Follow the project's existing feature and module organization.
- Do not reorganize folders as part of an unrelated change.
- Prefer one significant top-level type per Swift file.
- Small tightly coupled helper types may remain colocated when separating them would reduce clarity.
- Use consistent naming for types, methods, properties, models, and files.
- Keep domain logic independent of UI frameworks where practical.
- Prefer explicit dependencies over hidden global state.
- Do not introduce singleton state unless its process-wide identity is intentional.
- Write unit tests for meaningful application and domain logic.
- Prefer unit tests over UI tests where either could verify the same behavior.
- Use UI tests for behavior that genuinely requires integration through the UI.

---

# Localization

If the project uses `Localizable.xcstrings`:

- Prefer symbol-based localization keys for new user-facing strings.
- Use manually maintained symbol keys where that matches the project's localization strategy.

For example:

```swift
Text(.helloWorld)
```

- Preserve the project's existing naming convention for localization keys.
- Do not automatically add translations or modify every supported locale unless requested.
- When adding new user-facing strings, call out any new localization keys that will require translation.

---

# Security and Repository Hygiene

- Never commit API keys, credentials, signing secrets, tokens, passwords, or other secrets.
- Do not place secrets directly into source code or checked-in configuration.
- Respect the project's existing mechanism for secrets and environment-specific configuration.
- Do not modify signing configuration, entitlements, bundle identifiers, or provisioning settings unless specifically requested.

---

# Verification

After an approved code change:

- Build the affected target when tooling permits.
- Resolve compiler errors caused by the change.
- Check relevant warnings rather than treating a successful compile as sufficient.
- Run focused tests for the affected behavior when available.
- Do not make unrelated changes solely to eliminate pre-existing warnings.

If SwiftLint is installed:

- Ensure your changes introduce no new SwiftLint errors or warnings.
- Do not perform repository-wide lint cleanup unless requested.

For SwiftUI changes, use previews or another appropriate rendering mechanism when useful and available.

---

# Xcode Tooling

When Xcode-specific project tools are available, prefer them over generic filesystem or shell manipulation for Xcode project work.

Useful operations include:

- documentation lookup to verify API availability and signatures;
- project builds;
- build-log inspection;
- Issue Navigator diagnostics;
- SwiftUI Preview rendering;
- compiling or executing focused snippets in project context;
- Xcode-aware file reads and edits.

When uncertain whether an Apple API exists or what OS version introduced it, verify it rather than guessing.

---

# Change Discipline

Before proposing a larger refactor:

1. Identify the concrete problem in the current implementation.
2. Explain the proposed shape.
3. State the practical benefit.
4. Identify meaningful tradeoffs.
5. Wait for approval before editing.

Do not turn a localized bug fix into an architectural rewrite.

When reviewing existing code, distinguish between:

- incorrect code,
- code that violates current concurrency or API requirements,
- maintainability concerns,
- stylistic preferences,
- and optional modernization.

Do not present stylistic preferences as correctness requirements.
