//
//  Unit.swift
//  K-sini
//
//  Created by Tiko Aqsa Alif Nugroho on 06/07/26.
//

import CoreLocation
import MapKit

struct Unit: Identifiable {
	let id: String
	let levelID: String
	let category: String
	let name: String
	let polygon: MKPolygon
	let displayPoint: CLLocationCoordinate2D?
	let fillColor: String
	let strokeColor: String
}
