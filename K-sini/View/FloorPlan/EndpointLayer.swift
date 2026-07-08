//
//  EndpointLayer.swift
//  K-sini
//
//  Created by Tiko Aqsa Alif Nugroho on 07/07/26.
//

import SwiftUI
import MapKit

struct EndpointLayer: MapContent {

    let endpoints: [Endpoint]
    let selectedLevelID: String
    var showAllLevels: Bool = false

    var body: some MapContent {

        let visible = showAllLevels
            ? endpoints
            : endpoints.filter { $0.levelID == selectedLevelID }

        ForEach(visible) { endpoint in

            Annotation(
                endpoint.name,
                coordinate: endpoint.coordinate
            ) {
                Circle()
                    .fill(.red)
                    .frame(
                        width: 12,
                        height: 12
                    )
            }

        }

    }

}
