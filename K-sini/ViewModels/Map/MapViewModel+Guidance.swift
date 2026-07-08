//
//  MapViewModel+Guidance.swift
//  K-sini
//
//  Created by Tiko Aqsa Alif Nugroho on 06/07/26.
//

import CoreLocation

extension MapViewModel {

	func currentSegments()

	-> [[CLLocationCoordinate2D]]

	{

		GuidanceService.segments(

			route: routeSegments,

			levelID: selectedLevelID

		)

	}

}
