//
//  Building.swift
//  K-sini
//
//  Created by Tiko Aqsa Alif Nugroho on 06/07/26.
//

import MapKit

struct Building: Identifiable {
    let id: String
    let name: String
    let coordinate: CLLocationCoordinate2D
    let polygon: MKPolygon
}
