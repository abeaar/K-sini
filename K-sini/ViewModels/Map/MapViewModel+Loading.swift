//
//  MapViewModel+Loading.swift
//  K-sini
//
//  Created by Tiko Aqsa Alif Nugroho on 06/07/26.
//

import MapKit
import SwiftUI

extension MapViewModel {

	func loadData() {

		buildings = repository.loadBuildings()

		levels = repository.loadLevels()

		platforms = repository.loadPlatforms()

		units = repository.loadUnits()

		endpoints = repository.loadEndpoints()

		pathways = repository.loadPathways()

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
