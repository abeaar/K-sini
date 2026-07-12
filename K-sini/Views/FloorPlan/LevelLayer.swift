//
//  LevelLayer.swift
//  K-sini
//
//  Created by Tiko Aqsa Alif Nugroho on 07/07/26.
//

import SwiftUI
import MapKit

struct LevelLayer: MapContent {

    let levels: [Level]
    let selectedLevelID: String

    var body: some MapContent {
        ForEach(levels.filter { $0.id == selectedLevelID }) { level in
            ForEach(level.polygons.indices, id: \.self) { index in
                MapPolygon(
                    coordinates: level.polygons[index].coordinates
                )
				.foregroundStyle(.green.opacity(0.08))
                .stroke(.green, lineWidth: 2)
            }
        }
    }

}
