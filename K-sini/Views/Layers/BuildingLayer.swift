//
//  BuildingLayer.swift
//  K-sini
//
//  Created by Tiko Aqsa Alif Nugroho on 07/07/26.
//

import SwiftUI
import MapKit

struct BuildingLayer: MapContent {

    let buildings: [Building]

    var body: some MapContent {
        ForEach(buildings) { building in
            MapPolygon(coordinates: building.polygon.coordinates)
                .foregroundStyle(.gray.opacity(0.1))
                .stroke(.gray, lineWidth: 2)
        }
    }

}
