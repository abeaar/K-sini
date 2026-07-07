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
