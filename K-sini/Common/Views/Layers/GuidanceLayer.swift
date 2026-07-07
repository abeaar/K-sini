//
//  GuidanceLayer.swift
//  K-sini
//
//  Created by Tiko Aqsa Alif Nugroho on 07/07/26.
//

import SwiftUI
import MapKit

struct GuidanceLayer: MapContent {

    let segments: [[CLLocationCoordinate2D]]

    var body: some MapContent {

        ForEach(
            segments.indices,
            id: \.self
        ) { index in

            MapPolyline(
                coordinates: segments[index]
            )
            .stroke(
                .orange,
                style: StrokeStyle(
                    lineWidth: 8,
                    lineCap: .round,
                    lineJoin: .round
                )
            )

        }

    }

}
