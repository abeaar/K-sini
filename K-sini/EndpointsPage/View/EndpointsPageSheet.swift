//
//  EndpointsPageSheet.swift
//  k-sini GPS point POC
//
//  Created on 05/07/26.
//

import CoreLocation
import SwiftUI

struct EndpointsPageSheet: View {
    
    var title: String = "Tujuan"
    let endpoints: [Endpoint]
    let destinations: [Destination]
    let onSelect: (Endpoint) -> Void
    let onSelectDestination: (Destination) -> Void
    
    var body: some View {
        
        VStack(spacing: 16){
            
            // search bar
            
            
            // list
            List {
                // destinations section
                if !destinations.isEmpty {
                    Section {
                        ForEach(destinations) { destination in
                            Button {
                                onSelectDestination(destination)
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: destination.icon)
                                        .font(.title)
                                        .foregroundStyle(.blue)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(destination.name)
                                            .foregroundStyle(.primary)

                                        Text(destination.alts.first ?? "")
                                            .font(.callout)
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(.tertiary)
                                }
                                .padding(.vertical, 4)
                            }
                            .buttonStyle(.plain)
                        }
                    } header: {
                        Text("Tujuan Populer")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                    }
                }
                
                // station endpoints sections
                EndpointList(
                    title: "Terbaru",
                    endpoints: endpoints,
                    onSelect: onSelect,
                    headerFont: .title3,
                    headerFontWeight: .bold,
                    headerColor: .primary
                )
                
                EndpointList(
                    title: "Terdekat Dari Lokasimu",
                    endpoints: endpoints,
                    onSelect: onSelect,
                    headerFont: .title3,
                    headerFontWeight: .bold,
                    headerColor: .primary
                )
            }
            
        }.padding(.top, 15)
        
    }
}

#Preview {
    EndpointsPageSheet(
        endpoints: [
            Endpoint(
                id: "preview-1",
                name: "Hallway (Start)",
                icon: "arrowshape.left",
                alts: [],
                levelID: "",
                coordinate: CLLocationCoordinate2D(latitude: -6.30222222, longitude: 106.65222222),
                checkpoints: [])
        ],
        destinations: [
            Destination(
                id: "preview-dest-1",
                name: "AEON Mall BSD",
                icon: "cart.fill",
                alts: ["AEON"],
                coordinate: CLLocationCoordinate2D(latitude: -6.3047067, longitude: 106.6437751))
        ],
        onSelect: { _ in },
        onSelectDestination: { _ in }
    )
}
