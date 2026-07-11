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
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color(.systemGray4)))
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
                    .tint(Color(.systemGray4))
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
