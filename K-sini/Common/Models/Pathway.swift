//
//  Pathway.swift
//  K-sini
//
//  Created by Tiko Aqsa Alif Nugroho on 06/07/26.
//

import CoreLocation

struct Pathway: Identifiable {
	let id: String
	let levelID: String
	let category: String
	let coordinate: CLLocationCoordinate2D
	let directions: [PathDirection]
}

struct PathDirection {
	let key: String
	let instructionID: String?
	let instructionEN: String?
	let to: String
	let endpoints: [String]
}
