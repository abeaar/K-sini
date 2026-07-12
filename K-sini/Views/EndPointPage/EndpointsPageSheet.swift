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
	@Environment(\.colorScheme) var colorScheme
    @Environment(NavigationState.self) var points: NavigationState
    
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        
        VStack(spacing: 16){
            
            // search bar
            if currentDetent == .large {
                HStack{
                    // search bar
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
							.foregroundStyle(.primary)
                        
                        TextField(
                            "",
                            text: $searchText,
                            prompt: Text("Mau ke mana?")
								.foregroundStyle(.white.opacity(0.3))
                        )
						.foregroundStyle(.primary)
                        .focused($isSearchFocused)
                        .onAppear {
                            isSearchFocused = true
                        }
                        
                    }
                    .padding()
					.glassEffect()
					.background(
						RoundedRectangle(cornerRadius: 24).fill(Color(.clear))
					)
                    .padding(.leading, 15)
                    .padding(.top, 10)
                    
                    // button xmark
                    Button(action: {
                        currentDetent = .height(600)
                        searchText = ""
                    }) {
						Image(systemName: "xmark")
							.padding()
                    }
                    .foregroundStyle(.primary)
                    .labelStyle(.iconOnly)
					.glassEffect()
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
                        onSelect: onSelectDestination,
                        distanceFor: { destination in
                            points.getDistance(to: destination)
                        }
                    )
					.listRowBackground(
						currentDetent == .large ?
						Color.gray.opacity(0.1) :
						colorScheme == .dark ?
						Color.gray.opacity(0.1) :
						Color.white.opacity(0.3)
					)
                } else {
                    Text("No data found")
                        .foregroundStyle(.secondary)
                        .listRowBackground(Color.clear)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 40)
                }
            }
            .scrollContentBackground(.hidden)
            .contentMargins(.top, 0)
            
            
        }
        .padding(.top, 15)
    }
}
