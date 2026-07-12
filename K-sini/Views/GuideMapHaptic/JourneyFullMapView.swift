import MapKit
import SwiftUI

struct JourneyFullMapView: View {

    @Bindable var viewModel: MapViewModel
    @State private var coverPosition: MapCameraPosition = .automatic
    @State private var hasInitiallyFitted = false

    private var allLevelIDs: [String] {
        viewModel.levels.map(\.id)
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Map(position: $coverPosition) {
                BuildingLayer(buildings: viewModel.buildings)

                LevelLayer(
                    levels: viewModel.levels,
                    selectedLevelID: viewModel.selectedLevelID
                )

                EndpointLayer(
                    endpoints: viewModel.endpoints,
                    selectedLevelID: viewModel.selectedLevelID,
                    showAllLevels: false
                )

                GuidanceLayer(segments: viewModel.currentSegments())
            }
            .mapStyle(.standard(elevation: .flat))
            .ignoresSafeArea()
            .onAppear { fitWideShotIfNeeded() }
            .onChange(of: viewModel.buildings.count) { _, _ in
                fitWideShotIfNeeded()
            }
            .onChange(of: viewModel.routeSegments.count) { _, _ in
                fitToRouteIfReady()
            }
            
            FloorSelectorView(viewModel: viewModel)
                .padding(.top, 16)
        }
    }

    private func fitWideShotIfNeeded() {
        guard !hasInitiallyFitted else { return }
        if !viewModel.routeSegments.isEmpty,
           let region = region(for: viewModel.routeSegments) {
            coverPosition = .region(region)
            hasInitiallyFitted = true
            return
        }
        guard !viewModel.buildings.isEmpty,
              let region = BuildingRegionService.region(from: viewModel.buildings) else { return }
        coverPosition = .region(region)
        hasInitiallyFitted = true
    }

    private func fitToRouteIfReady() {
        guard hasInitiallyFitted else { return }
        guard !viewModel.routeSegments.isEmpty else { return }
        guard let region = region(for: viewModel.routeSegments) else { return }
        coverPosition = .region(region)
    }

    private func region(for route: [Pathway]) -> MKCoordinateRegion? {
        var coords: [CLLocationCoordinate2D] = []
        if let start = viewModel.endpoints.first(where: { $0.id == viewModel.selectedStartID }) {
            coords.append(start.coordinate)
        }
        if let dest = viewModel.endpoints.first(where: { $0.id == viewModel.selectedDestinationID }) {
            coords.append(dest.coordinate)
        }
        coords.append(contentsOf: route.map(\.coordinate))
        guard !coords.isEmpty else { return nil }

        let lats = coords.map(\.latitude)
        let lons = coords.map(\.longitude)
        guard let minLat = lats.min(), let maxLat = lats.max(),
              let minLon = lons.min(), let maxLon = lons.max() else { return nil }

        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        let span = MKCoordinateSpan(
            latitudeDelta: max((maxLat - minLat) * 1.4, 0.0005),
            longitudeDelta: max((maxLon - minLon) * 1.4, 0.0005)
        )
        return MKCoordinateRegion(center: center, span: span)
    }
}
