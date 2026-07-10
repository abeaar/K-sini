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
	let image: String
}

extension PathDirection {
	var displayImageName: String {
		if !image.isEmpty {
			return image
		}
		let text = (instructionID ?? instructionEN ?? "").lowercased()
		if text.contains("peron") || text.contains("turun dari kereta") {
			return "Peron 1 "
		} else if text.contains("eskalator") {
			if text.contains("naik") {
				return "Naik Eskalator"
			}
			return "Cari Eskalator"
		} else if text.contains("alfa") || text.contains("alfamart") {
			return "Kiri alfa"
		} else if text.contains("tap out") || text.contains("gerbang tiket") || text.contains("tap tiket") || text.contains("tap in") {
			return "Gate tap"
		} else if text.contains("sampai di tujuan") || text.contains("sampai tujuan") || text.contains("pintu") || text.contains("keluar") {
			return "Gate keluar"
		} else if text.contains("tangga") {
			if text.contains("turun") {
				return "Turuni tangga"
			}
			return "Jalan lurus ada tangga"
		} else if text.contains("belok kiri") {
			return "Kiri alfa"
		} else if text.contains("belok kanan") {
			return "Cari gate"
		} else if text.contains("lurus") {
			return "Jalan Lurus no tangga"
		}
		return "Cari Eskalator"
	}
}
