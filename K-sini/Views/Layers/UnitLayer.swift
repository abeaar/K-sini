//
//  UnitLayer.swift
//  K-sini
//
//  Created by Tiko Aqsa Alif Nugroho on 07/07/26.
//

import SwiftUI
import MapKit

struct UnitLayer: MapContent {

    let units: [Unit]
    let selectedLevelID: String

    var body: some MapContent {

        ForEach(
            units.filter { $0.levelID == selectedLevelID }
        ) { unit in

            MapPolygon(
                coordinates: unit.polygon.coordinates
            )
            .foregroundStyle(
                Color(hex: unit.fillColor)
                    .opacity(0.8)
            )
            .stroke(
                Color(hex: unit.strokeColor),
                lineWidth: 1
            )

            if let point = unit.displayPoint {

                Annotation(
                    unit.name,
                    coordinate: point
                ) {
                    Image(
                        systemName:
                            UnitIconProvider.icon(
                                for: unit.category
                            )
                    )
                }

            }

        }

    }

}
