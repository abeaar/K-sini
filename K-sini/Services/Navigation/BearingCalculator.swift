//
//  BearingCalculator.swift
//  K-sini
//
//  Created by Tiko Aqsa Alif Nugroho on 08/07/26.
//

import CoreLocation

enum BearingCalculator {

	static func bearing(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) -> Double {

		let startLatitude = start.latitude * .pi / 180
		let startLongitude = start.longitude * .pi / 180
		let endLatitude = end.latitude * .pi / 180
		let endLongitude = end.longitude * .pi / 180
		let longitudeDelta = endLongitude - startLongitude
		let y = sin(longitudeDelta) * cos(endLatitude)
		let x = cos(startLatitude) * sin(endLatitude) - sin(startLatitude) * cos(endLatitude) * cos(longitudeDelta)
		let bearing = atan2(y, x) * 180 / .pi

		return (bearing + 360).truncatingRemainder(dividingBy: 360)
	}
}
