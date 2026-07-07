//
//  Destination.swift
//  K-sini
//

import CoreLocation

struct Destination: Identifiable {
    let id: String
    let name: String
    let icon: String
    let alts: [String]
    let coordinate: CLLocationCoordinate2D
}
