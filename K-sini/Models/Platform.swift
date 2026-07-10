//
//  Platform.swift
//  K-sini
//
//  Created by Tiko Aqsa Alif Nugroho on 06/07/26.
//

import CoreLocation
import MapKit

struct Platform: Identifiable {
	let id: String
	let levelID: String
	let buildingID: String
	let name: String
	let polygon: MKPolygon
	let fillColor: String
	let strokeColor: String
	let displayPoint: CLLocationCoordinate2D?
}
