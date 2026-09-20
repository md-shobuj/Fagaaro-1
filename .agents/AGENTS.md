# Senior Flutter Engineering Standards & Architecture Rules

Follow these standards on every change, without being asked.

## Architecture
- Clean Architecture with three strict layers: `presentation` → `domain` → `data`. Dependencies point inward only. `domain` imports nothing from `data` or `presentation`.
- `domain` holds entities, abstract repository contracts, and use cases. Pure Dart — no Flutter imports, no JSON, no HTTP.
- `data` holds models (with `fromJson`/`toJson`), remote/local data sources, and concrete repository implementations of the domain contracts.
- `presentation` holds widgets, pages, and state management. It talks to use cases, never to repositories or data sources directly.
- Feature-first folder structure: `lib/features/<feature>/{data,domain,presentation}/`, with shared code in `lib/core/`.
- Repository Pattern: every data source is behind an abstract repository interface defined in `domain`. Swapping REST for GraphQL or Hive for Isar must require zero changes in `domain` or `presentation`.
- Inject all dependencies through constructors. Register them in one place (get_it/injectable or Riverpod providers). No service locators called from inside widgets, no singletons reached via global state.

## Code Quality
- **SOLID**: one reason to change per class; extend via new implementations rather than editing existing ones; subtypes must honor their contract; split fat interfaces; depend on abstractions.
- **DRY**: extract repeated logic into shared functions, base classes, or extensions — but only after it repeats a third time with the same *reason* to change. Do not abstract coincidental similarity.
- **KISS**: prefer the boring, readable solution. No clever one-liners, no metaprogramming, no abstraction layers that exist "just in case."
- **100% OOP**: everything is a class with clear responsibility and encapsulated state. No free-floating global functions or mutable global variables. Private fields by default; expose behavior, not data.
- Immutable models — `final` fields, `const` constructors, `copyWith` for updates. Use `freezed` for unions and value equality.
- Strong typing everywhere. No `dynamic`, no `var` where the type isn't obvious, no implicit casts.

## Performance (Target: consistent 60fps / 120fps high-refresh)
- `const` constructors on every widget that can take one.
- Build methods must be cheap: no network calls, no heavy computation, no sorting/filtering large lists inside `build`.
- Rebuild the smallest possible subtree. Use `Selector`/`select`/granular providers so a state change repaints only what actually changed. Split large widgets into smaller `StatelessWidget` classes rather than private `_buildX()` methods returning widgets.
- Lists: always `ListView.builder`/`GridView.builder` with `itemExtent` or `prototypeItem` when item height is uniform. Never `ListView(children: [...])` for unbounded data.
- Offload heavy work (JSON parsing of large payloads, image processing, crypto) to `compute`/isolates.
- Cache images (`cached_network_image`), size them with `cacheWidth`/`cacheHeight`, and never load full-resolution assets into thumbnails.
- Avoid `Opacity`, `ClipRRect`, and `saveLayer` in animated paths — use `AnimatedOpacity`'s cheaper equivalents, `Container` decorations with `borderRadius`, or shaders.
- Use `RepaintBoundary` around independently animating subtrees.
- Dispose every controller, stream subscription, focus node, and animation controller.
- Profile in profile mode, not debug. Justify perf claims with DevTools timeline evidence, not intuition.

## Widget Selection
- Pick the lightest widget that does the job: `SizedBox` over `Container` when only sizing; `ColoredBox` over `Container` when only coloring; `DecoratedBox` when only decorating.
- `Text` styling via theme extensions, not hardcoded `TextStyle` per widget.
- Layout: prefer `Row`/`Column`/`Flex` and `Stack` over nested `Padding`+`Align` chains. Use `Spacer`, `Expanded`, `Flexible` deliberately and explain the flex choice when non-obvious.
- Responsiveness via `LayoutBuilder` and breakpoints, never raw `MediaQuery.size` math scattered through the tree.
- Never build UI inside a `Builder` just to get a context — restructure instead.

## Error Handling
- No `throw` crossing layer boundaries into `presentation`. Repositories return `Either<Failure, T>` (dartz/fpdart) or a sealed `Result` type.
- Define a `Failure` hierarchy: `NetworkFailure`, `ServerFailure`, `CacheFailure`, `ValidationFailure`, `UnauthorizedFailure`, `UnknownFailure`. Data sources throw typed `Exception`s; repositories catch them and map to `Failure`.
- Never `catch (e)` bare and swallow it. Catch the narrowest type, log with context, map to a failure, rethrow if unrecoverable.
- Every UI state must model loading, success, empty, and error explicitly — as a sealed class, not nullable flags.
- Show user-facing messages that are human-readable; log technical detail to Crashlytics/Sentry, never to the user.
- Set `FlutterError.onError` and `PlatformDispatcher.instance.onError` for global capture.

## Testing
- Unit tests for every use case and repository (mock the data source). Widget tests for every screen's four states. Golden tests for shared design-system components.
- Tests are part of the change, not a follow-up.

## Workflow Rules
- Before writing code, state which layer(s) you're touching and why.
- When a requirement conflicts with these rules, say so and propose the trade-off instead of silently breaking a rule.
- When you're unsure of an existing pattern in this codebase, read the neighboring feature first and match it rather than inventing a second convention.
- Keep diffs minimal and focused. Don't refactor unrelated code in the same change.
