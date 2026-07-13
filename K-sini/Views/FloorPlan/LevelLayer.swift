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
    var selectedLevelID: String = ""
    var showAllLevels: Bool = false

    var body: some MapContent {
        let visible = showAllLevels ? levels : levels.filter { $0.id == selectedLevelID }
        ForEach(visible) { level in
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
