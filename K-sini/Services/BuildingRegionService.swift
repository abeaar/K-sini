//
//  BuildingRegionService.swift
//  K-sini
//
//  Created by Tiko Aqsa Alif Nugroho on 06/07/26.
//

import MapKit

enum BuildingRegionService {

	static func region(
		from buildings: [Building]
	) -> MKCoordinateRegion? {

		let polygons = buildings.map {$0.polygon}

		guard !polygons.isEmpty else {
			return nil
		}

		var minLat = Double.greatestFiniteMagnitude
		var maxLat = -Double.greatestFiniteMagnitude
		var minLon = Double.greatestFiniteMagnitude
		var maxLon = -Double.greatestFiniteMagnitude

		for polygon in polygons {
			for coordinate in polygon.coordinates {
				minLat = min(minLat, coordinate.latitude)
				maxLat = max(maxLat, coordinate.latitude)
				minLon = min(minLon, coordinate.longitude)
				maxLon = max(maxLon, coordinate.longitude)
			}
		}

		let center =
			CLLocationCoordinate2D(
				latitude: (minLat + maxLat) / 2,
				longitude: (minLon + maxLon) / 2
			)

		let span = MKCoordinateSpan(
			latitudeDelta: max((maxLat - minLat) * 1.4, 0.0005),
			longitudeDelta: max((maxLon - minLon) * 1.4, 0.0005)
		)

		return MKCoordinateRegion(
			center: center,
			span: span
		)
	}
}
