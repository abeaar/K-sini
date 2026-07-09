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
    
    let searchBG = Color(red: 0.863, green: 0.863, blue: 0.882) // #dcdce1
    
    @Binding var currentDetent: PresentationDetent
    @Binding var searchText : String
    
    var body: some View {
        
        VStack(spacing: 16){
            
            // search bar
            if currentDetent == .large {
                HStack{
                    // search bar
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        
                        TextField(
                            "",
                            text: $searchText,
                            prompt: Text("Mau ke mana?")
                                .foregroundStyle(.secondary)
                        )
                        .foregroundStyle(.secondary)
                        
                    }
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 20).fill(searchBG))
                    .padding(.leading, 15)
                    .padding(.top, 10)
                    
                    // button xmark
                    Button(action: {
                        currentDetent = .height(600)
                        searchText = ""
                    }) {
                        Label("", systemImage: "xmark")
                            .padding(7)
                    }
                    .foregroundStyle(.primary)
                    .labelStyle(.iconOnly)
                    .buttonStyle(.glassProminent)
                    .tint(searchBG)
                    .buttonBorderShape(.circle)
                    .padding(.top, 8)
                    
                }
                .padding(.trailing, 10)
                                
                
            }
            
            // list
            List {
                if !destinations.isEmpty {
                    DestinationList(
                        title: "Terdekat dari Lokasimu",
                        destinations: destinations,
                        onSelect: onSelectDestination
                    )
                }
            }
            .contentMargins(.top, 0)
            
            
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
                coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),
                checkpoints: [])
        ],
        destinations: [
            Destination(
                id: "preview-dest-1",
                name: "AEON Mall BSD",
                icon: "cart.fill",
                alts: ["AEON"],
                coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
        ],
        onSelect: { _ in },
        onSelectDestination: { _ in },
        currentDetent: .constant(.height(600)),
        searchText: .constant("")
    )
}
