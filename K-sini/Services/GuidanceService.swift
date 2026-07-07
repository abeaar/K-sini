//
//  GuidanceService.swift
//  K-sini
//
//  Created by Tiko Aqsa Alif Nugroho on 06/07/26.
//

import CoreLocation

enum GuidanceService {

	static func segments(
		route: [Pathway],
		levelID: String
	) -> [[CLLocationCoordinate2D]] {

		guard route.count > 1 else {
			return []
		}
		var result: [[CLLocationCoordinate2D]] = []
		var current: [CLLocationCoordinate2D] = []
		for index in 0..<(route.count - 1) {
			let from = route[index]
			let to = route[index + 1]
			let sameFloor = from.levelID == levelID && to.levelID == levelID
			if sameFloor {
				if current.isEmpty {
					current.append(from.coordinate)
				}
				current.append(to.coordinate)
			}
			else {
				if current.count > 1 {
					result.append(current)
				}
				current = []
			}
		}
		if current.count > 1 {
			result.append(current)
		}
		return result
	}
}
