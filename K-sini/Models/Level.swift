//
//  Level.swift
//  K-sini
//
//  Created by Tiko Aqsa Alif Nugroho on 06/07/26.
//

import MapKit

struct Level: Identifiable {
	let id: String
	let number: Int
	let name: String
	let polygons: [MKPolygon]
}
