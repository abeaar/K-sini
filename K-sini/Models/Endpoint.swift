//
//  Endpoint.swift
//  K-sini
//
//  Created by Tiko Aqsa Alif Nugroho on 06/07/26.
//

import CoreLocation

struct Endpoint: Identifiable {
	let id: String
	let name: String
	let levelID: String
	let coordinate: CLLocationCoordinate2D
	let checkpoints: [String]
}
