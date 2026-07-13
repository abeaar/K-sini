//
//  MapViewModel.swift
//  K-sini
//
//  Created by Tiko Aqsa Alif Nugroho on 06/07/26.
//

import Foundation
import SwiftUI
import MapKit

@Observable
final class MapViewModel {

	// MARK: Repository

	let repository: GeoJSONRepositoryProtocol

	// MARK: Services

	let routeService = RouteService()

	// MARK: State

	var position: MapCameraPosition = .automatic

	var buildings: [Building] = []

	var levels: [Level] = []

	var units: [Unit] = []

	var platforms: [Platform] = []

	var endpoints: [Endpoint] = []
    
    var destination : [Destination] = []

	var pathways: [Pathway] = []

	var routeSegments: [Pathway] = []

	var selectedLevelID = ""

	var selectedStartID = ""

	var selectedDestinationID = ""

	init(
		repository: GeoJSONRepositoryProtocol =
			GeoJSONRepository()
	) {

		self.repository = repository

	}

}
