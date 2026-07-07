//
//  DestinationResolver.swift
//  K-sini
//

import CoreLocation

class DestinationResolver {

    /// Finds the station endpoint nearest to an external destination.
    static func nearestEndpoint(
        to destination: Destination,
        from endpoints: [Endpoint]
    ) -> Endpoint? {

        let target = CLLocation(
            latitude: destination.coordinate.latitude,
            longitude: destination.coordinate.longitude
        )

        return endpoints.min(by: { a, b in
            let distA = target.distance(from: CLLocation(
                latitude: a.coordinate.latitude,
                longitude: a.coordinate.longitude
            ))
            let distB = target.distance(from: CLLocation(
                latitude: b.coordinate.latitude,
                longitude: b.coordinate.longitude
            ))
            return distA < distB
        })
    }
}
