//
//  JourneyFullMapView.swift
//  K-sini
//
//  Created by on 08/07/26.
//

// ponytail: re-implements `MapPreview`'s body inline (plan B). When a
// third caller appears, extract the body into a generic `OverviewMap`
// view that takes the `MapViewModel` and the camera-fit closure.

import MapKit
import SwiftUI

struct JourneyFullMapView: View {

    @Bindable var mapVM: MapViewModel
    @State private var hasInitiallyFitted = false
    @Environment(\.dismiss) private var dismiss
    @Environment(NavigationState.self) var points: NavigationState

    private var allLevelIDs: [String] {
        mapVM.levels.map(\.id)
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Map(position: $mapVM.position) {
                BuildingLayer(buildings: mapVM.buildings)

                ForEach(allLevelIDs, id: \.self) { levelID in
                    LevelLayer(
                        levels: mapVM.levels,
                        selectedLevelID: levelID
                    )
                }

                EndpointLayer(
                    endpoints: mapVM.endpoints,
                    selectedLevelID: "",
                    showAllLevels: true
                )

                GuidanceLayer(segments: mapVM.currentSegments())
                
                if let userLoc = mapVM.userLocation {
                    Annotation("Lokasi Anda", coordinate: userLoc) {
                        Image(systemName: "location.north.fill")
                            .font(.title2)
                            .foregroundStyle(.blue)
                            .rotationEffect(.degrees(mapVM.heading))
                    }
                }
            }
            .mapStyle(.standard(elevation: .flat))
            .ignoresSafeArea()
            .onAppear { fitWideShotIfNeeded() }
            .onChange(of: mapVM.routeSegments.count) { _, _ in
                fitToRouteIfReady()
            }
            .onMapCameraChange {
                if mapVM.position.positionedByUser {
                    mapVM.shouldFollowUser = false
                }
            }

            // Re-center button
            Button {
                withAnimation {
                    mapVM.shouldFollowUser = true
                    mapVM.centerOnUser()
                }
            } label: {
                Image(systemName: mapVM.shouldFollowUser ? "location.fill" : "location")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 50, height: 50)
                    .background(Color.blue)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
            .padding(.bottom, 24)
            .padding(.trailing, 24)

            Button { dismiss() } label: {
                Text("Tutup")
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
            }
            .glassEffect(.regular.tint(.white).interactive(), in: Capsule())
            .padding(.top, 8)
            .padding(.trailing, 16)
        }
    }

    private func fitWideShotIfNeeded() {
        guard !hasInitiallyFitted else { return }
        if let region = BuildingRegionService.region(from: mapVM.buildings) {
            mapVM.position = .region(region)
        }
        hasInitiallyFitted = true
    }

    private func fitToRouteIfReady() {
        guard hasInitiallyFitted else { return }
        guard !mapVM.routeSegments.isEmpty else { return }
        guard let region = region(for: mapVM.routeSegments) else { return }
        mapVM.position = .region(region)
    }

    private func region(for route: [Pathway]) -> MKCoordinateRegion? {
        var coords: [CLLocationCoordinate2D] = []
        if let start = mapVM.endpoints.first(where: { $0.id == mapVM.selectedStartID }) {
            coords.append(start.coordinate)
        }
        if let dest = mapVM.endpoints.first(where: { $0.id == mapVM.selectedDestinationID }) {
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

#Preview {
    JourneyFullMapView(mapVM: MapViewModel())
        .environment(NavigationState())
}
