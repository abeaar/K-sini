//
//  NavigationState.swift
//  k-sini GPS point POC
//
//  Created by on 03/07/26.
//

// just for state

import Combine
import SwiftUI

class NavigationState: ObservableObject {

    @Published var start: Endpoint?
    @Published var destination: Endpoint?
    
    /// The external destination the user picked (e.g. AEON Mall).
    /// nil when the user picked a station endpoint directly.
    @Published var selectedDestination: Destination?
    
    // new
    private var locationManager = LocationManager()
    private var endpoints: [Endpoint] = []
    @Published var destinations: [Destination] = []
    
    func loadEndpoints() {
        endpoints = EndpointLoader().load()
    }
    
    func loadDestinations() {
        destinations = DestinationLoader().load()
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

