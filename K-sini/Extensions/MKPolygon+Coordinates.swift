//
//  MKPolygon+Coordinates.swift
//  K-sini
//
//  Created by Tiko Aqsa Alif Nugroho on 06/07/26.
//

import MapKit

extension MKPolygon {
	var coordinates: [CLLocationCoordinate2D] {
		var coords = Array(
			repeating: CLLocationCoordinate2D(),
			count: pointCount
		)
		getCoordinates(
			&coords,
			range: NSRange(location: 0, length: pointCount)
		)
		return coords
	}
}
