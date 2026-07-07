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

    var body: some MapContent {

        ForEach(
            endpoints.filter {
                $0.levelID == selectedLevelID
            }
        ) { endpoint in

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
