//
//  EndpointDetector.swift
//  k-sini GPS point POC
//
//  Created by on 02/07/26.
//

import Foundation
import CoreLocation

struct EndpointDistance {
    let endpoint: Endpoint
    let distance: Double
}

class EndpointDetector {

    static func nearestEndpoints(
        current: CLLocation,
        endpoints: [Endpoint]
    ) -> [EndpointDistance] {

        var distances: [EndpointDistance] = []

        for endpoint in endpoints {

            let saved = CLLocation(
                latitude: endpoint.coordinate.latitude,
                longitude: endpoint.coordinate.longitude
            )
            let d = current.distance(from: saved)

            distances.append(
                EndpointDistance(
                    endpoint: endpoint,
                    distance: d
                )
            )
        }
        
        distances.sort {
            $0.distance < $1.distance
        }

        return Array(distances.prefix(3))
    }

}
