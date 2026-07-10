//
//  MapViewModel+Loading.swift
//  K-sini
//
//  Created by Tiko Aqsa Alif Nugroho on 06/07/26.
//

import MapKit
import SwiftUI

extension MapViewModel {

	func loadData(near coordinate: CLLocationCoordinate2D? = nil) {

		buildings = repository.loadBuildings()

		let targetCoord: CLLocationCoordinate2D
		if let coordinate {
			targetCoord = coordinate
		} else if let userLocation {
			targetCoord = userLocation
		} else {
			targetCoord = buildings.first?.coordinate ?? CLLocationCoordinate2D(latitude: -6.324, longitude: 106.641)
		}
		
		let loc = CLLocation(latitude: targetCoord.latitude, longitude: targetCoord.longitude)
		if let nearestBuilding = buildings.min(by: { a, b in
			let distA = loc.distance(from: CLLocation(latitude: a.coordinate.latitude, longitude: a.coordinate.longitude))
			let distB = loc.distance(from: CLLocation(latitude: b.coordinate.latitude, longitude: b.coordinate.longitude))
			return distA < distB
		}) {
			let activeBuildingID = nearestBuilding.id
			
			// Filter map features
			buildings = [nearestBuilding]
			levels = repository.loadLevels().filter { $0.buildingID == activeBuildingID }
			platforms = repository.loadPlatforms().filter { $0.buildingID == activeBuildingID }
			units = repository.loadUnits().filter { $0.buildingID == activeBuildingID }
			endpoints = repository.loadEndpoints().filter { $0.buildingID == activeBuildingID }
			
			let levelIDs = Set(levels.map { $0.id })
			pathways = repository.loadPathways().filter { levelIDs.contains($0.levelID) }
		} else {
			levels = repository.loadLevels()
			platforms = repository.loadPlatforms()
			units = repository.loadUnits()
			endpoints = repository.loadEndpoints()
			pathways = repository.loadPathways()
		}

		if let region =
			BuildingRegionService.region(
				from: buildings
			)
		{

			position = .camera(
				MapCamera(
				centerCoordinate: region.center,
				distance: MapZoom.overview,
				heading: 0,
				pitch: 0
				)
			)
		}

		let sortedEndpoints =

			endpoints.sorted {

				$0.name < $1.name

			}

		if selectedStartID.isEmpty {

			selectedStartID =

				sortedEndpoints.first?.id

				?? ""

		}

		if selectedLevelID.isEmpty {

			selectedLevelID =

				levels.first?.id

				?? ""

		}

		if selectedDestinationID.isEmpty {

			selectedDestinationID =

				sortedEndpoints.last?.id

				?? ""

		}

		navigate()

	}

}
