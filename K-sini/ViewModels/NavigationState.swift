//
//  NavigationState.swift
//  k-sini GPS point POC
//
//  Created by on 03/07/26.
//

import Foundation
import SwiftUI

@Observable
final class NavigationState {

    var start: Endpoint?
    var destination: Endpoint?

    /// The external destination the user picked (e.g. AEON Mall).
    /// nil when the user picked a station endpoint directly.
    var selectedDestination: Destination?

    var pathways: [Pathway] = []
    var destinations: [Destination] = []
    var levels: [Level] = []

    private let repository: GeoJSONRepositoryProtocol
    private let locationManager = LocationManager()
    private var endpoints: [Endpoint] = []

    init(repository: GeoJSONRepositoryProtocol = GeoJSONRepository()) {
        self.repository = repository
    }

    func loadEndpoints() {
        endpoints = repository.loadEndpoints()
    }

    func loadDestinations() {
        destinations = repository.loadDestinations()
    }

    func loadPathways() {
        pathways = repository.loadPathways()
    }

    func loadLevels() {
        levels = repository.loadLevels()
    }

    func detectStartingPoint() async{
        let location = await locationManager.requestOneShotLocation()
        let nearest = EndpointDetector.nearestEndpoints(current: location, endpoints: endpoints)
        start = nearest.first?.endpoint
    }

    /// Resolves an external destination to the nearest station endpoint.
    func resolveDestination(_ destination: Destination) {
        selectedDestination = destination
        self.destination = DestinationResolver.nearestEndpoint(
            to: destination,
            from: endpoints
        )
    }

}
