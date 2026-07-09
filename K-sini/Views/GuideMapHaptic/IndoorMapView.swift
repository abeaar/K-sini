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
	
	var body: some View {
		Map(position: $mapVM.position) {
			
			// Level Polygon
			ForEach(GeoJSONLoader.polygons(named: "level"), id: \.self) { polygon in
				MapPolygon(polygon)
					.foregroundStyle(.gray.opacity(0.2))
					.stroke(.gray, lineWidth: 1)
			}

			// Room Polygon
			ForEach(GeoJSONLoader.polygons(named: "unit"), id: \.self) { polygon in
				MapPolygon(polygon)
					.foregroundStyle(.gray.opacity(0.2))
					.stroke(.gray, lineWidth: 1)
			}
			
			

			// Route Polyline

			// Door Annotation

			// User Annotation

			// Destination Annotation

		}
		.mapStyle(.standard(elevation: .flat))
		.allowsHitTesting(allowsInteraction)
	}
}
