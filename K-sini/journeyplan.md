# Plan: Journey page — image checkpoint and instruction

## Objective

Wire `JourneyPage` so each step of the route shows the **right image** and the **right instruction** for the user's current position. Today the page renders a hardcoded `image1`/`image2`/`image3` rotation (`JourneyPage.swift:48-51`) and a fallback `"—"` instruction when the `PathDirection` has no `instructionID`. The data model already carries the real instruction text (`Pathway.swift:18-24`), the per-step image, and the pathway graph, but the views don't use it. This plan replaces the placeholder cycle with a per-step image tied to the current `PathDirection`, and surfaces the actual instruction text in the header.

GPS detection, the mini-map, and the full-screen map are out of scope.

## Direction (locked in with the user)

1. **Per-step image, not a background cycle.** Each `PathDirection` carries the image name for that step. The background image is whatever the current `PathDirection` says it is. If the data is missing, fall back to the first asset — no placeholder cycle.
2. **Instruction text, not `Image(systemName: "map")`.** `JourneyHeaderView` already reads `direction.instructionID ?? direction.instructionEN ?? "—"` (`JourneyHeaderView.swift:40`). The fix is to make sure the data path actually has the ID for the current step, and to add an `image` field on `PathDirection` to drive the background.
3. **One `PathDirection` per visual step.** Step counter already counts `route.reduce(0) { $0 + $1.directions.count }` (`JourneyViewModel.swift:39`). Each `PathDirection` is one step. Don't change the step model.
4. **No map changes.** `JourneyFullMapView` and `JourneyMiniMap.swift` stay as they are. The mini-map's `Map`-based rewrite from the previous turn stays too; the user explicitly skipped the mini-map feature, not the file.
5. **No new services.** Use the existing `RouteService` + `PathwayLoader`. Only add data fields and view rendering.

## What's broken

- `JourneyPage.swift:47-51` — `backgroundImageName` is a `currentStepIndex % 3` rotation over a hardcoded `["image1", "image2", "image3"]`. The user is on step 5 of 24 and the page is showing `image2` regardless of where they are.
- `Models/Pathway.swift:18-24` — `PathDirection` has no `image` field. There's no way to know which image belongs to which step.
- `Loaders/PathwayLoader.swift` — need to check if `image` is already in the GeoJSON. If yes, just decode it. If no, add to the GeoJSON and the loader.
- `Assets.xcassets/` — assets exist (`Cari gate`, `Jalan Lurus no tangga`, `Naik Eskalator`, `Peron 1`, `Turuni tangga`, etc.) but there's no mapping from step to image.
- `JourneyImageCycle.swift` — the class is unused. `JourneyPage.swift` does the rotation itself inline. Delete the class.
- `JourneyHeaderView.swift:40` — `instructionID ?? instructionEN ?? "—"` is correct, but the field name should be `instruction` to match the asset. Verify against the actual GeoJSON.

## What changes

### Data model

`PathDirection` gains one field:

```swift
struct PathDirection {
    let key: String
    let instructionID: String?
    let instructionEN: String?
    let to: String
    let endpoints: [String]
    let image: String   // <-- new
}
```

Image name matches the asset catalog entry (e.g. `"Cari gate"`, `"Jalan Lurus no tangga"`, `"Naik Eskalator"`). Empty string = no image override, caller falls back to the first asset.

### Loader

`Loaders/PathwayLoader.swift` — read `properties.image` from each direction feature in `pathway.geojson`. If the field is missing, default to `""`. The GeoJSON itself is the source of truth for which image is which step.

### State

`JourneyViewModel` — no schema change. Add one computed property:

```swift
var currentImageName: String {
    currentDirection?.image.flatMap { $0.isEmpty ? nil : $0 } ?? ""
}
```

Empty string when the current step has no image; the view falls back to the first asset.

### Views

**`JourneyPage.swift`**
- Delete `backgroundImageName` (lines 47-51).
- Pass `vm.currentImageName` into `JourneyBackgroundView(imageName: ...)`.
- Fallback to the first asset name (`"Cari gate"` or whichever is canonical) when the current step has no image. One-liner ternary in the call site.

**`JourneyHeaderView.swift`**
- No change to the instruction text line. It already reads `direction.instructionID ?? direction.instructionEN ?? "—"`. The fix is upstream — make sure the loader is putting the right text in the right field.

**`JourneyBackgroundView.swift`**
- No change. Already takes `imageName: String` and renders `Image(imageName)`.

**`JourneyImageCycle.swift`**
- Delete the file. It's unreferenced; the inline rotation in `JourneyPage` was the only user. After this plan, the inline rotation is gone too, so the class has zero callers.

### Mini-map

- `JourneyMiniMap.swift` — leave the current `Map`-based version in place. The user said "skip for now" on the mini-map feature, not "revert the file." Reverting adds work without changing the user-facing behavior (the `JourneyHeaderView` block that would render the mini-map is commented out at lines 57-79).
- `JourneyHeaderView.swift:57-79` — the mini-map block stays commented. The `Image(systemName: "map")` placeholder is what the user sees in the corner, and that's fine for this plan.

## File-level action list

| Action | Path | Reason |
|---|---|---|
| Edit | `Models/Pathway.swift` | Add `image: String` to `PathDirection` |
| Edit | `Loaders/PathwayLoader.swift` | Read `properties.image` per direction; default to `""` |
| Edit | `View/JourneyPage/JourneyViewModel.swift` | Add `currentImageName` computed property |
| Edit | `View/JourneyPage/JourneyPage.swift` | Replace `backgroundImageName` with `currentImageName` + fallback; pass through to `JourneyBackgroundView` |
| Edit | `View/JourneyPage/JourneyHeaderView.swift` | No logic change — confirm the existing `instructionID` line is what we want |
| Delete | `View/JourneyPage/JourneyImageCycle.swift` | Unreferenced after `JourneyPage` no longer cycles |
| Don't touch | `View/JourneyPage/JourneyMiniMap.swift` | Feature paused per user direction |
| Don't touch | `View/JourneyPage/JourneyFullMapView.swift` | Out of scope |
| Don't touch | `View/JourneyPage/JourneyTabBarView.swift` | Out of scope |
| Don't touch | `Services/RouteService.swift`, `Services/GuidanceService.swift` | No behavior change |
| Don't touch | `Assets.xcassets/*` | Existing assets reused |

## Order of operations (one build per phase)

1. **Phase 1 — Add `image` to `PathDirection` and the loader.**
   - Edit `Models/Pathway.swift`.
   - Edit `Loaders/PathwayLoader.swift` to read the new field. All existing `PathDirection(...)` call sites get a new `image:` argument. Use `""` as the default if you can give `PathDirection` an `init(image: String = "")` style member-wise initializer, or update each call site.
   - Build. The new field exists; no view reads it yet.
2. **Phase 2 — `currentImageName` in `JourneyViewModel`.**
   - Add the computed property.
   - Build. No view change.
3. **Phase 3 — `JourneyPage` uses `currentImageName`.**
   - Replace the `backgroundImageName` computed property with a single `vm.currentImageName` read (or a one-line fallback to the first asset).
   - Pass it to `JourneyBackgroundView(imageName:)`.
   - Build. Background image now follows the route.
4. **Phase 4 — Delete `JourneyImageCycle.swift`.**
   - Remove the file.
   - Build. No behavior change.

## Risks and unknowns

1. **`pathway.geojson` has no `image` field yet.** Open `Common/Resources/GeoJSON/pathway.geojson` (or wherever it lives) and check. If absent, Phase 1 needs the GeoJSON updated too. Add the field to each direction feature pointing at the asset name.
2. **Asset catalog names** must match the strings in the GeoJSON exactly. `Assets.xcassets/Cari gate.imageset` is referenced as `"Cari gate"`. The strings in the GeoJSON need to match. Add a unit-style check: `assets.contains { $0 == imageName }` in the loader, log a warning if not. Don't crash — fall back to the first asset.
3. **Asset catalog is missing images for some steps.** The 8 image sets in the catalog cover the most common Cisauk routes. If a route hits a step with no matching image, the loader's `""` default makes the view fall back to `"Cari gate"`. Honest fallback, not a crash.
4. **`PathDirection.init` member-wise change.** Adding `image: String` to the struct changes the synthesized member-wise initializer. Every call site that does `PathDirection(key: ..., instructionID: ..., instructionEN: ..., to: ..., endpoints: ...)` needs `image: ...` added. Grep for `PathDirection(` and fix.
5. **`JourneyImageCycle` might be referenced elsewhere.** Grep before deleting. If `JourneyTabBarView` or `JourneyFullMapView` uses it, leave the file. (I checked — no callers in the Journey page; safe to delete.)
6. **Localization.** `instructionID` is Indonesian, `instructionEN` is English. Header shows ID first. If the user wants a language toggle, that's a separate plan.

## Out of scope (and why)

- **Mini-map.** User said skip for now. File stays as-is.
- **GPS-driven step advance.** Step advance is currently button-driven (`JourneyTabBarView` "I'm arrived" → `vm.advance()`). GPS-based detection of arriving at the next checkpoint is a follow-up — needs `LocationManager` streaming + a `GuidanceService` rule.
- **Voice instructions.** `GuidanceService` exists but isn't wired to `JourneyPage`. Out of scope.
- **Localization toggle.** Header shows Indonesian only for now.
- **Animation between steps.** Step transitions are instant. Could add a cross-fade, but the screenshot shows the user is fine with snaps.
- **Full-screen map polish.** `JourneyFullMapView` works; not touching.

## Memory aid

The five things to remember:

1. **`PathDirection` gains one field: `image: String`.** That's the only data-model change.
2. **`JourneyPage.backgroundImageName` is the bug.** It cycles `image1`/`image2`/`image3` regardless of step. Delete it; read `vm.currentImageName` instead.
3. **Asset names in the GeoJSON must match `Assets.xcassets/` exactly.** Mismatch falls back to the first asset, no crash.
4. **Header instruction text is already correct.** `direction.instructionID ?? direction.instructionEN ?? "—"` is the right line. Fix is upstream in the data, not the view.
5. **Mini-map stays paused.** `JourneyMiniMap.swift` is untouched; the header block that would use it stays commented out.
