//
//  NavigationState.swift
//  k-sini GPS point POC
//
//  Created by on 03/07/26.
//

import Foundation
import SwiftUI
import MapKit

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
    var endpoints: [Endpoint] = []

    private let repository: GeoJSONRepositoryProtocol
    private let locationManager = LocationManager()

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

    func detectStartingPoint() async {
        let location = await locationManager.requestOneShotLocation()
        
        let buildings = repository.loadBuildings()
        if let nearestBuilding = buildings.min(by: { a, b in
            let distA = location.distance(from: CLLocation(latitude: a.coordinate.latitude, longitude: a.coordinate.longitude))
            let distB = location.distance(from: CLLocation(latitude: b.coordinate.latitude, longitude: b.coordinate.longitude))
            return distA < distB
        }) {
            self.endpoints = repository.loadEndpoints().filter { $0.buildingID == nearestBuilding.id }
            self.levels = repository.loadLevels().filter { $0.buildingID == nearestBuilding.id }
            
            let levelIDs = Set(self.levels.map { $0.id })
            self.pathways = repository.loadPathways().filter { levelIDs.contains($0.levelID) }
            
            let buildingLoc = CLLocation(latitude: nearestBuilding.coordinate.latitude, longitude: nearestBuilding.coordinate.longitude)
            self.destinations = repository.loadDestinations().filter { dest in
                let destLoc = CLLocation(latitude: dest.coordinate.latitude, longitude: dest.coordinate.longitude)
                return destLoc.distance(from: buildingLoc) <= 3000
            }
        } else {
            self.endpoints = repository.loadEndpoints()
            self.levels = repository.loadLevels()
            self.pathways = repository.loadPathways()
            self.destinations = repository.loadDestinations()
        }
        
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

    private var distanceCache: [String: Double] = [:]
    private let routeService = RouteService()

    func getDistance(to target: Endpoint) -> Double? {
        guard let start = self.start else { return nil }
        if start.id == target.id { return 0 }
        
        let cacheKey = "\(start.id)-\(target.id)"
        if let cached = distanceCache[cacheKey] {
            return cached
        }
        let route = routeService.findRoute(from: start, to: target, pathways: pathways)
        let distance = routeService.calculateDistance(route: route)
        distanceCache[cacheKey] = distance
        return distance
    }

    func getDistance(to target: Destination) -> Double? {
        guard let endpoint = DestinationResolver.nearestEndpoint(to: target, from: endpoints) else {
            return nil
        }
        return getDistance(to: endpoint)
    }
}
