//
//  BuildingLoader.swift
//  K-sini
//
//  Created by Tiko Aqsa Alif Nugroho on 06/07/26.
//

import Foundation
import MapKit

struct BuildingLoader {
	func load() -> [Building] {
		GeoJSONLoader
			.polygons(
				named: "building"
			)
			.map {
				Building(
					id: UUID().uuidString,
					
					polygon: $0
				)
			}
	}
}
