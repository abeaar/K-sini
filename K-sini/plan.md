# Migration: K-SINI — Wire `EndpointsPage` → `ConfirmPoints` → `Journey` flow onto the new `Common/` backend

## Objective

The old data layer (`Model/Endpoints.swift`, `Model/Geojson/GeoJSONLoader.swift`, `Model/Geojson/GeoJSONModels.swift`, the hardcoded sample list in `Model/EndpointsCoordinates.swift`, and `Model/Geojson/station.geojson`) is replaced by the new backend in `Common/` (`Common/Models/`, `Common/Loaders/`, `Common/Repositories/`, plus `endpoint.geojson` in `Common/Resources/GeoJSON/`).

The user-facing flow stays the same: `EndpointsPage` → `ConfirmPoints` → `Journey`. `Common/Views/ContentView.swift` (the map-first explorer) stays untouched and unused in this migration — it is the longer-term direction, not today's job.

GPS-based starting point detection stays. The user still has `LocationManager` and `EndpointDetector` snapping them to the nearest endpoint at launch.

`JourneyPage` stays as the image-cycle placeholder. Wiring it to `RouteService` + `pathway.geojson` directions is a follow-up task, deliberately deferred.

---

## Direction (locked in with the user)

1. **Keep old flow, make it use new backend.** EndpointsPage + ConfirmPoints + Journey stay. Their data layer is swapped.
2. **Keep `EndpointsPage` and `ConfirmPoints` exactly as user-facing surfaces.** No visual change unless forced by the data model swap.
3. **GPS-based starting point stays.** `LocationManager` + `EndpointDetector` are not deleted; `EndpointDetector` shrinks because the new `Endpoint` model has a single `coordinate` (not an array).
4. **No target-membership verification.** The `project.pbxproj` is assumed to list `Common/**` in Compile Sources and the GeoJSON files in Copy Bundle Resources. If the build fails on "Cannot find type 'Endpoint' in scope", the fix is target membership, not this plan.

---

## What changes and why

### Data model

`Common/Models/Endpoint.swift` becomes the canonical `Endpoint`. The old `Model/Endpoints.swift` is deleted.

Shape delta:

| Field | Old `Endpoint` | New `Endpoint` |
|---|---|---|
| `id` | `UUID` (auto) | `String` (from GeoJSON `@id`) |
| `icon` | `String` (SF Symbol) | added — from `properties.markerSymbol` |
| `name` | `String` | `String` — from `properties.name.en ?? .id` |
| `alts` | `[String]` | added — from `properties.name.alts` |
| `description` | `String` | **removed** — new GeoJSON has no short blurb |
| `coordinates` | `[Coordinate]` | removed — replaced by single |
| `coordinate` | — | `CLLocationCoordinate2D` — from `display_point` or geometry |
| `levelID` | — | `String` — from `properties.level` |
| `checkpoints` | — | `[String]` — pathway IDs |

`description` had three consumers: `Components/EndpointsList.swift`, `EndpointsPageSheet.swift`, `ConfirmPointsSheet.swift`. All three swap to `endpoint.alts.first ?? ""` as a one-line subtitle. No description field in the new data, no description field in the views.

`icon` is added to the model itself (populated by `EndpointLoader`) rather than derived in views. Three call sites read `endpoint.icon`; centralizing the fallback (`"mappin.circle.fill"`) in the loader is cheaper than threading a resolver through the views.

### Loader layer

- **Delete** `Model/Endpoints.swift`, `Model/EndpointsCoordinates.swift`, `Model/Geojson/GeoJSONLoader.swift`, `Model/Geojson/GeoJSONModels.swift`, `Model/Geojson/station.geojson`. The hardcoded sample list and the hand-rolled `GeoJSONFeatureCollection` decoder are gone.
- **`EndpointLoader.swift`** in `Common/Loaders/` is the new endpoint loader. It uses `MKGeoJSONDecoder`, handles both `Point` and `MultiPoint` geometries, and populates all the new fields including the added `icon` and `alts`.
- **`GeoJSONRepositoryProtocol` + `GeoJSONRepository`** in `Common/Repositories/` becomes the single facade. `NavigationState` holds a `GeoJSONRepositoryProtocol` and views call into the repository through it — matching the pattern `Common/ViewModels/MapViewModel` already uses.
- **Bundle resource:** `Common/Resources/GeoJSON/endpoint.geojson` replaces `Model/Geojson/station.geojson`. The new file is loaded by name `"endpoint"` from `Bundle.main` (vs. `"station"` in the old code). All call sites that passed `"station"` switch to using `EndpointLoader().load()` (which hardcodes `"endpoint"`) or, with the repository, `repository.loadEndpoints()` (which also hardcodes `"endpoint"`).

### State management

`NavigationState` (the `@StateObject` in `ContentView.swift:17`) is rewired:

- Holds a `private let repository: GeoJSONRepositoryProtocol` with a default of `GeoJSONRepository()`.
- `loadEndpoints()` becomes `endpoints = repository.loadEndpoints()`.
- `detectStartingPoint()` is unchanged in shape; the body change happens in `EndpointDetector`.

Timing: `loadEndpoints` and `detectStartingPoint` move from the `.confirmPoints` destination's `.task` (which fires when the screen is pushed) to the root `ContentView.task` (which fires at app launch). Ponytail rule: start async work as early as possible. The user never waits at `EndpointsPage` because endpoints are preloaded before they tap anything.

### `EndpointDetector`

The old detector walked `endpoint.coordinates` and found the closest one. The new `Endpoint` has a single `coordinate`. The body collapses:

```swift
for endpoint in endpoints {
    let saved = CLLocation(
        latitude: endpoint.coordinate.latitude,
        longitude: endpoint.coordinate.longitude
    )
    let d = current.distance(from: saved)
    distances.append(EndpointDistance(endpoint: endpoint, distance: d))
}
```

No `.min()`, no `guard let closestDistance`. Signature unchanged. Lives where it does (`Manager/`) — moving it to `Common/Manager/` is a folder shuffle, deferred.

### `JourneyPage`

Untouched. Add a `// ponytail:` comment at the top of `JourneyPage.swift` so the image cycle doesn't get mistaken for finished work.

```swift
// ponytail: image cycle is a placeholder; wire to RouteService +
// pathway.geojson directions in a follow-up.
```

### `MapView.swift` (in `ConfirmPoints/View/`)

Empty placeholder (12 lines, no logic). Doesn't read `endpoint.coordinates`. No change.

---

## File-level action list

| Action | Path | Reason |
|---|---|---|
| Edit | `Common/Models/Endpoint.swift` | Add `icon: String` and `alts: [String]` to the canonical model |
| Edit | `Common/Loaders/EndpointLoader.swift` | Populate new fields: `icon`, `alts` |
| Edit | `Components/EndpointsList.swift` | Drop `endpoint.description` use, use `alts.first ?? ""` |
| Edit | `EndpointsPage/View/EndpointsPageSheet.swift` | Drop `description` use |
| Edit | `EndpointsPage/View/EndpointsPageView.swift` | Swap `GeoJSONLoader.loadEndpoints(file: "station")` → use `EndpointLoader().load()`; drop `description` from filter |
| Edit | `ConfirmPoints/View/ChangePointsSheet.swift` | Same loader swap |
| Edit | `ConfirmPoints/View/ConfirmPointsSheet.swift` | Drop `description` use |
| Edit | `ViewModel/NavigationState.swift` | Inject `GeoJSONRepositoryProtocol` |
| Edit | `ContentView.swift` | Move `.task { loadEndpoints + detectStartingPoint }` from destination to root |
| Edit | `Manager/EndpointDetector.swift` | Single-coordinate body |
| Edit | `JourneyPage/JourneyPage.swift` | Add `// ponytail:` comment |
| Delete | `Model/Endpoints.swift` | Superseded by `Common/Models/Endpoint.swift` |
| Delete | `Model/EndpointsCoordinates.swift` | Hardcoded sample list, no longer needed |
| Delete | `Model/Geojson/GeoJSONLoader.swift` | Replaced by `Common/Loaders/EndpointLoader.swift` |
| Delete | `Model/Geojson/GeoJSONModels.swift` | Hand-rolled decoder no longer needed |
| Delete | `Model/Geojson/station.geojson` | Real data lives in `Common/Resources/GeoJSON/endpoint.geojson` |
| Don't touch | `Common/Views/ContentView.swift`, `Common/Services/*`, `Common/ViewModels/MapViewModel*`, `Common/Layers/*`, `Common/Components/*`, other `Common/Loaders/*` | Out of scope for this migration |
| Don't touch | `Manager/LocationManager.swift` | Signature unchanged, still used by `EndpointDetector` |

---

## Order of operations

The phases are sequential — each one assumes the previous compiles.

### Phase 1 — Model reconciliation (no behavior change)
1. Add `icon` and `alts` to `Common/Models/Endpoint.swift`.
2. Update `EndpointLoader.swift` to populate them.
3. Build. The new `Endpoint` now has all the fields the old views expected, but no view reads it yet.

### Phase 2 — View updates (still using old loader)
1. Update `Components/EndpointsList.swift`, `EndpointsPageSheet.swift`, `ConfirmPointsSheet.swift` to use `alts` instead of `description`.
2. Update `EndpointsPageView.swift` and `ChangePointsSheet.swift` to call `EndpointLoader().load()` (still hardcoded, no repository yet).
3. Build. App should now show the 5 real station endpoints from `endpoint.geojson` instead of the 4 hardcoded samples.

### Phase 3 — `NavigationState` rewire
1. Add `repository: GeoJSONRepositoryProtocol` to `NavigationState`.
2. `loadEndpoints()` becomes `repository.loadEndpoints()`.
3. Move `.task { loadEndpoints + detectStartingPoint }` from the destination to the root of `ContentView`.
4. Build. `EndpointsPageView` and `ChangePointsSheet` should switch to reading from the repository (via `NavigationState`) instead of calling the loader directly — eliminates two of the three `EndpointLoader().load()` calls.

### Phase 4 — `EndpointDetector` shrink
1. Replace the `[Coordinate]` walk with the single-coordinate body.
2. Build. The shape is identical, only the body changes.

### Phase 5 — `JourneyPage` comment
1. Add the `// ponytail:` comment.
2. Build. No behavior change.

### Phase 6 — Deletion
1. Delete `Model/Endpoints.swift`, `Model/EndpointsCoordinates.swift`, `Model/Geojson/GeoJSONLoader.swift`, `Model/Geojson/GeoJSONModels.swift`, `Model/Geojson/station.geojson`.
2. Build. Old `Endpoint` type, old `GeoJSONLoader`, and the hardcoded list are gone. If any forgotten reference survives, the build fails and you fix it.

### Phase 7 — Verification
- Launch the app.
- `EndpointsPage` shows 5 real entries: Cisauk Point Gate, Terminal Intermoda Gate, Parking Area Gate, Platform 1 - to Rangkas Bitung, Platform 2 - to Tanah Abang.
- GPS-based auto-detect sets `start` to the closest endpoint (per the new coordinate model — this is the line that exercises `EndpointDetector` after the shrink).
- Tap an endpoint → push to `ConfirmPoints`. Edit start/destination via `ChangePointsSheet`. Tap "Mulai Navigasi" → push to `JourneyPage`. Image cycle plays. Returns to root.
- No test framework exists. The launch-and-tap flow is the check.

---

## Risks and unknowns

- **`project.pbxproj` not listing `Common/**`.** If "Cannot find type 'Endpoint' in scope" appears at build time, add the missing `.swift` files to Compile Sources and `endpoint.geojson` to Copy Bundle Resources. This is outside the plan — fix the target, not the code.
- **`endpoint.geojson` not bundled.** `EndpointLoader` does `Bundle.main.url(forResource: "endpoint", withExtension: "geojson")`. If the file is not in Copy Bundle Resources, the URL is nil and the loader returns `[]`. Visible immediately as an empty list.
- **Bundle identifier / search path.** Same as above. If the bundle name is unexpected, the lookup fails silently.
- **`Pathway` and `PathDirection`** are referenced by `Common/Loaders/PathwayLoader.swift` and `Common/Models/Pathway.swift` but not by the old flow. They compile but are unused. YAGNI — leave them.
- **No tests.** Per the lazy rule, the runnable check is the launch-and-tap flow above. No `RouteService` self-check, no `EndpointDetector` unit test — out of scope.

---

## What is deliberately out of scope (and why)

- **Wiring `RouteService` + `GuidanceService` into `JourneyPage`.** The new `pathway.geojson` has directions with EN/ID text, `image` URLs, and `to`/`endpoints` references — the natural input for a real turn-by-turn journey. Skipped because `JourneyPage` is a placeholder per the user's direction, and "use new backend" is about plumbing, not rebuilding the journey UI. Follow-up task.
- **Replacing the flow with the map view from `Common/Views/ContentView.swift`.** That's the longer-term product direction. Skipped because the user explicitly chose "keep old flow, make it use new backend".
- **Moving `EndpointDetector` to `Common/Manager/`.** Folder shuffle, no functional impact. Skipped per YAGNI.
- **Adding a `Map` view in `ConfirmPoints/View/MapView.swift`.** Currently a placeholder. Skipped — out of scope for a data-layer migration.
- **Adding unit tests for `RouteService` and `EndpointDetector`.** No test framework in the project. The runnable check (launch + tap) covers the paths that exist today.

---

## Memory aid

The five things to remember:

1. **The new `Endpoint` has no `description` and no `coordinates` array.** Use `alts` for subtitles, `coordinate` (singular) for the map.
2. **GPS-based starting point stays.** `EndpointDetector` shrinks but its signature is the contract — don't rename it.
3. **Load endpoints at app launch, not when `ConfirmPoints` appears.** Move the `.task` to the root of `ContentView`.
4. **`JourneyPage` is a placeholder.** The `// ponytail:` comment is the signal to future-you.
5. **Bundle the new `endpoint.geojson`.** If endpoints are empty at runtime, that's the first thing to check.

---

# Plan: Compass mini-map in `JourneyHeaderView`

## Objective

Replace the decorative `Image(systemName: "map")` SF Symbol in the bottom-trailing corner of `JourneyHeaderView` with a real, schematic, **compass-mode mini-map**: the full route rendered as straight segments between consecutive pathway coordinates, with the *current* segment highlighted in orange and the whole canvas rotated so the current segment always points "up". Bearing is per-step and snaps on `currentStepIndex` change.

User-facing: the user is walking through a station. The mini-map shows them where they are, where they're going next, and the rest of the route for context — without them needing to leave the journey screen.

---

## Direction (locked in with the user)

1. **Custom `Canvas` mini-map, not `Map`/`MKMapView`.** Schematic, fast at 120pt, no tile noise.
2. **Snap per step.** Bearing comes from `route[currentPathwayIndex].coordinate → route[currentPathwayIndex + 1].coordinate`. No live GPS bearing, no animation between steps.
3. **Static user position.** The "current" dot stays at the start of the current segment. No interpolation as the user walks.
4. **Level polygons only, no building outline.** Confirmed earlier; the level polygons are the spatial context.
5. **Two-color dots.** Current dot: red. All other waypoint dots: gray. No special treatment for the final destination.
6. **Cross-floor segments drawn as straight lines.** Honest; the line "jumps floors" visually.

---

## What gets reused (no new logic)

| Asset | Path | Used as |
|---|---|---|
| `JourneyViewModel` | `View/JourneyPage/JourneyViewModel.swift` | Source of `route` and `currentStepIndex` |
| `RouteService` (via `vm.route`) | `Services/RouteService.swift` | Already produces the BFS-ordered pathway list |
| `Level` polygons | `Models/Level.swift` + `LevelLoader` | Current level's polygons, drawn behind |
| `MKPolygon+Coordinates` extension | `Extensions/MKPolygon+Coordinates.swift` | `.coordinates` for path construction |
| `MapPreview` (sibling) | `View/ConfirmPointPage/MapPreview.swift` | Pattern reference for the transform stack |
| `BuildingRegionService` (sibling) | `Services/BuildingRegionService.swift` | Pattern reference for bbox math |

No new services. No model changes. No repository changes.

## Data model: route → polyline segments

The route is `[Pathway]`. Each `Pathway` has one `coordinate` (lat/lon). The mini-map's polyline is a series of straight segments between consecutive pathway coordinates:

```
segments[i] = (route[i].coordinate, route[i+1].coordinate, isCurrent: i == currentPathwayIndex)
```

`currentPathwayIndex` is the index in `route` of the pathway containing `currentStepIndex`. While the user is still navigating, `currentPathwayIndex < route.count - 1` always holds (the final "I'm arrived" tap fires `onFinished()` and pops the screen).

A small `RouteSegment` struct is private to `JourneyMiniMap.swift` (one file, no separate model).

## What the user sees

```
After rotation, current segment is vertical:

              ● p_next  (red — current)
             /
            /  ← orange line (current segment)
           /
          ● p_curr  (current dot — but this is the same as above in a 2-pathway step)

Plus p_prev (gray dot, dimmed line) and p_after (gray dot, dimmed line)
arranged around the rotated coordinate space.
```

- All segments drawn.
- Current segment: orange, width 6, round caps.
- All other segments: gray opacity 0.4, width 4.
- Current dot: red, ~7pt on screen.
- All other dots: gray opacity 0.5, ~7pt.
- Current level's polygons: faint blue fill, blue stroke, behind everything.
- Whole canvas rotates so the current segment is vertical ("up" on screen).

When the user advances a step, `currentPathwayIndex` changes, the orange segment shifts, and the canvas snaps to a new rotation. No animation.

## Camera (Canvas transform stack)

```
context.translateBy(x: size.width / 2, y: size.height / 2)   // view center
context.scaleBy(x: 1, y: -1)                                 // flip y for lat (iOS y is down)
context.scaleBy(x: scale, y: scale)                          // fit-to-view
context.rotate(by: CGFloat(theta))                            // current segment up
context.translateBy(x: -mid.longitude, y: -mid.latitude)     // mid at origin
```

- `θ` = `bearingRadians(from: route[i].coordinate, to: route[i+1].coordinate)`. Standard `CLLocation` bearing formula (clockwise from north).
- `mid` = midpoint of the current segment.
- `scale` computed from the union bounding box of (a) all route pathway coordinates and (b) all level polygon coordinates. Fit into the 120×120 view with 15% margin.

**Units note:** lat/lon are in degrees, not meters. Cisauk station is at lat ≈ -6.3° (cos ≈ 0.99), so 1° lat ≈ 1° lon in distance — uniform scale works. A `// ponytail:` comment flags the upgrade path (proper Mercator projection) for non-equatorial stations.

**y-axis flip:** iOS's `GraphicsContext` has y-down, but lat is y-up. The `scaleBy(x: 1, y: -1)` corrects this. After the flip, the canvas rotation sign is `+θ` (not `-θ`) to keep "next above current" on screen.

## Files

### Edit: `ViewModel/NavigationState.swift`
- Add `var levels: [Level] = []`.
- Add `func loadLevels() { levels = repository.loadLevels() }`. `loadLevels()` is already declared in `GeoJSONRepositoryProtocol`.

### Edit: `ContentView.swift`
- One new line in the root `.task`: `points.loadLevels()`.

### Edit: `View/JourneyPage/JourneyViewModel.swift`
- Add `var currentPathwayIndex: Int?` — index in `route` of the pathway containing `currentStepIndex`. Walk the same flatten as `direction(at:)` to find which pathway owns the step.
- Add `var currentCheckpoint: (coordinate: CLLocationCoordinate2D, levelID: String)?` — `(route[i].coordinate, route[i].levelID)` when `currentPathwayIndex` is non-nil.
- Add `var nextCheckpoint: CLLocationCoordinate2D?` — `pathways.first { $0.id == route[i].directions[stepIndexWithinPathway].to }?.coordinate`. Returns nil on the last step.

### New: `View/JourneyPage/JourneyMiniMap.swift` (~120 lines)

`struct JourneyMiniMap: View` taking `route: [Pathway]`, `currentPathwayIndex: Int`, `levelPolygons: [MKPolygon]`.

Renders a `Canvas { context, size in ... }` that:
1. Returns early if `route.count < 2` or `currentPathwayIndex >= route.count - 1`.
2. Computes `θ`, `mid`, bbox, `scale`.
3. Applies the transform stack.
4. Draws in order: level polygons → polyline segments (orange if current, gray otherwise) → dots (red if current, gray otherwise).

Private helpers in the same file: `bearingRadians`, `midpoint`, `unionBbox`, `fitScale`, `routeCoordinates`, `polygonCoordinates`, `drawLevelPolygons`, `drawSegments`, `drawDots`. No separate utility file.

`// ponytail:` comment at the top: *"compass-mode mini-map; whole route as straight segments between pathway coordinates. Current step's segment is orange. To interpolate the user's progress along the current segment, drive the current dot's position from `route[i].coordinate` toward `route[i+1].coordinate` based on GPS distance covered."*

### Edit: `View/JourneyPage/JourneyHeaderView.swift`
- Add parameters: `route: [Pathway]`, `currentPathwayIndex: Int`, `levelPolygons: [MKPolygon]`.
- In `.overlay(alignment: .bottomTrailing)`: when `route.count >= 2 && currentPathwayIndex < route.count - 1`, render `JourneyMiniMap(route: route, currentPathwayIndex: currentPathwayIndex, levelPolygons: levelPolygons)`. Otherwise, keep the existing `Image(systemName: "map")` placeholder.

### Edit: `View/JourneyPage/JourneyPage.swift`
- Compute `currentLevelPolygons: [MKPolygon]` from `points.levels` + `vm.currentCheckpoint?.levelID`.
- Pass `route: vm.route`, `currentPathwayIndex: vm.currentPathwayIndex ?? 0`, `levelPolygons: currentLevelPolygons` to `JourneyHeaderView`.

## Order of operations (one build per phase)

1. **Phase 1 — Add `currentPathwayIndex` / `currentCheckpoint` / `nextCheckpoint` to `JourneyViewModel`.** Build. No behavior change.
2. **Phase 2 — Add `levels` to `NavigationState` + `loadLevels()` + call from `ContentView.task`.** Build. No behavior change.
3. **Phase 3 — New `JourneyMiniMap.swift`.** Build. New file, unused.
4. **Phase 4 — Edit `JourneyHeaderView` + `JourneyPage` to pass `route`/`currentPathwayIndex`/`levelPolygons` and render `JourneyMiniMap` when present.** Build.

Each phase compiles independently.

## Risks

1. **y-axis flip in `Canvas`.** Discussed above. The `scaleBy(x: 1, y: -1)` handles it. Will be visually verified after build.
2. **Bbox scale in degrees, not meters.** The station is at lat ≈ -6.3° (cos ≈ 0.99), so 1° lat ≈ 1° lon in distance. Uniform scale works for Cisauk. Ponytail comment flags the upgrade path for non-equatorial stations.
3. **Empty route.** When `route.count < 2` or `currentPathwayIndex >= route.count - 1`, the header falls back to the SF Symbol. Same graceful degradation.
4. **Cross-floor segments** are drawn as straight orange lines. The line "jumps floors" in the visual. Honest. Per your call: just draw the line.
5. **Past vs future dot distinction.** Both are gray. The user said no special treatment for the final destination. The current step's dot is red — that's the only differentiated dot.
6. **Performance.** `Canvas` redraws on every body change (every step advance). Level polygons have ~10 coordinates each, route has 5–15 pathways typically. Sub-millisecond redraw. No concern.
7. **iOS deployment target.** Already iOS 26+. `Canvas` is iOS 15+.

## What is deliberately *not* in scope (and why)

- **No GPS-driven user-position interpolation along the current segment.** The current dot stays at the start of the segment. The `// ponytail:` comment in `JourneyMiniMap.swift` names the upgrade path.
- **No live bearing from `CLLocation.course`.** Per-step, snaps.
- **No animation between steps.** Snap.
- **No building outline inside the circle.** Level polygons only (per your earlier call).
- **No real map tiles.** Custom `Canvas` (per your earlier call).
- **No `LocationManager` refactor.** Out of scope; would couple to the deferred GPS streaming work.
- **No `JourneyImageCycle.swift` deletion.** Cleanup-pass candidate.
- **No `MKMapView` representable.** Custom `Canvas` is the right tool for a 120pt schematic.

## Memory aid

The five things to remember:

1. **The polyline is the whole route, not just the current step.** Draw `route.indices.dropLast()` straight segments; color the current one orange, the rest gray.
2. **Bearing is per step, snapped.** From `route[currentPathwayIndex].coordinate` to `route[currentPathwayIndex + 1].coordinate`. No live GPS.
3. **Two color dots, two color segments.** Current = red/orange. Everything else = gray. No blue for the final destination.
4. **y-axis flip is mandatory.** iOS `Canvas` is y-down; lat is y-up. `scaleBy(x: 1, y: -1)` in the transform stack.
5. **Levels come from `NavigationState` now.** Both the confirm screen's `MapPreview` and the journey's mini-map read from `points.levels`, loaded once at app launch.

