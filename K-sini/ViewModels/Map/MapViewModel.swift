//
//  MapViewModel.swift
//  K-sini
//
//  Created by Tiko Aqsa Alif Nugroho on 06/07/26.
//

import Foundation
import SwiftUI
import MapKit
import CoreLocation

@Observable
final class MapViewModel {

	// MARK: Repository

	let repository: GeoJSONRepositoryProtocol

	// MARK: Services

	let routeService = RouteService()

	// MARK: State

	var position: MapCameraPosition = .automatic
	
	var mapRotation: Double = 0
	var userLocation: CLLocationCoordinate2D?
	var heading: CLLocationDirection = 0
	var shouldFollowUser = true
	var zoomDistance: CLLocationDistance = MapZoom.mini
	var region = MKCoordinateRegion(
		center: CLLocationCoordinate2D(
			latitude: -6.173949,
			longitude: 106.872374
		),
		span: MKCoordinateSpan(
			latitudeDelta: 0.001,
			longitudeDelta: 0.001
		)
	)
	var buildings: [Building] = []
	var levels: [Level] = []
	var units: [Unit] = []
	var platforms: [Platform] = []
	var endpoints: [Endpoint] = []
	var pathways: [Pathway] = []
	var routeSegments: [Pathway] = []
	var selectedLevelID = "1"
	var selectedStartID = ""
	var selectedDestinationID = ""

	init(repository: GeoJSONRepositoryProtocol = GeoJSONRepository()) {
		self.repository = repository
	}

	// MARK: - User Location

	var simulatedLocation: CLLocationCoordinate2D?

	func updateUserLocation(_ coordinate: CLLocationCoordinate2D) {
		let stationCenter = CLLocation(latitude: -6.324, longitude: 106.641)
		let userLoc = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
		
		if userLoc.distance(from: stationCenter) < 10000 {
			userLocation = coordinate
		} else {
			userLocation = simulatedLocation ?? coordinate
		}
		
		guard shouldFollowUser, let loc = userLocation else { return }
		region.center = loc
		position = .camera(
			MapCamera(
				centerCoordinate: loc,
				distance: zoomDistance,
				heading: heading,
				pitch: 0
			)
		)
	}
	
	func updateHeading(_ heading: CLLocationDirection) {
		self.heading = heading
		guard shouldFollowUser,
			  let coordinate = userLocation
		else {
			return
		}

		position = .camera(
			MapCamera(
				centerCoordinate: coordinate,
				distance: zoomDistance,
				heading: heading,
				pitch: 0
			)
		)
	}
	
	func setFollowUser(_ follow: Bool) {
		shouldFollowUser = follow
		if follow {
			centerOnUser()
		}
	}

	func centerOnUser() {
		guard let coordinate = userLocation else {
			   return
		   }
		   position = .camera(
			   MapCamera(
				   centerCoordinate: coordinate,
				   distance: zoomDistance,
				   heading: heading,
				   pitch: 0
			   )
		   )
	}

}


enum MapZoom {

	static let mini: CLLocationDistance = 18
	static let overview: CLLocationDistance = 35
	static let fullscreen: CLLocationDistance = 60
}
