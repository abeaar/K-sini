//
//  PlatformLayer.swift
//  K-sini
//
//  Created by Tiko Aqsa Alif Nugroho on 07/07/26.
//

import SwiftUI
import MapKit

struct PlatformLayer: MapContent {

    let platforms: [Platform]
    let selectedLevelID: String

    var body: some MapContent {
        ForEach(platforms.filter { $0.levelID == selectedLevelID }) { platform in

            MapPolygon(
                coordinates: platform.polygon.coordinates
            )
            .foregroundStyle(
                Color(hex: platform.fillColor)
                    .opacity(0.45)
            )
            .stroke(
                Color(hex: platform.strokeColor),
                lineWidth: 2
            )

            if let point = platform.displayPoint {

                Annotation(
                    platform.name,
                    coordinate: point
                ) {
                    Image(systemName: "tram.fill")
                        .foregroundStyle(.red)
                }

            }

        }
    }

}
