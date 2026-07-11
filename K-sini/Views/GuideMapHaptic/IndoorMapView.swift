//
//  IndoorMapView.swift
//  K-sini
//
//  Created by Tiko Aqsa Alif Nugroho on 09/07/26.
//

import SwiftUI
import MapKit

struct IndoorMapView: View {
    @Bindable var mapVM: MapViewModel
    let allowsInteraction: Bool
    private var allLevelIDs: [String] { mapVM.levels.map(\.id) }
    
    
    var body: some View {
        Map(position: $mapVM.position) {
            ForEach(GeoJSONLoader.polygons(named: "level"), id: \.self) { polygon in
                MapPolygon(polygon)
                    .foregroundStyle(.blue.opacity(0.08))
                    .stroke(.blue, lineWidth: 2)
            }
            ForEach(GeoJSONLoader.polygons(named: "unit"), id: \.self) { polygon in
                MapPolygon(polygon)
                    .foregroundStyle(.blue.opacity(0.08))
                    .stroke(.blue, lineWidth: 2)
            }
            
//            GuidanceLayer(segments: mapVM.currentSegments())
//            
//            if let userLoc = mapVM.userLocation {
//                Annotation("Lokasi Anda", coordinate: userLoc) {
//                    Image(systemName: "location.north.fill")
//                        .font(.title2)
//                        .foregroundStyle(.blue)
//                        .rotationEffect(.degrees(mapVM.heading))
//                }
//            }
        }
        .mapStyle(.standard(elevation: .flat))
        .allowsHitTesting(allowsInteraction)
//        .onMapCameraChange {
//            if mapVM.position.positionedByUser {
//                mapVM.shouldFollowUser = false
//            }
//        }
    }
}
