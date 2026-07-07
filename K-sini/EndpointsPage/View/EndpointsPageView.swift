//
//  EndpointsPageView.swift
//  k-sini GPS point POC
//
//  Created by on 05/07/26.
//

import SwiftUI

struct EndpointsPageView: View {
    @State private var showSheet = true   // starts true, never set to false
    @State private var searchText = ""
    @Environment(NavigationState.self) var points: NavigationState

    var filteredEndpoints: [Endpoint] {
        guard !searchText.isEmpty else { return endpoints }
        return endpoints.filter { endpoint in
            endpoint.name.localizedCaseInsensitiveContains(searchText) ||
            endpoint.alts.contains { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var filteredDestinations: [Destination] {
        guard !searchText.isEmpty else { return destinations }
        return destinations.filter { dest in
            dest.name.localizedCaseInsensitiveContains(searchText) ||
            dest.alts.contains { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    let searchBG = Color(red: 0.071, green: 0.608, blue: 1) // #129bff
    let searchFont = Color(red: 0.511, green: 0.879, blue: 0.986)
    let grayBG = Color(red: 0.949, green: 0.949, blue: 0.965) // #f2f2f6
    
    @State private var endpoints: [Endpoint] = []
    @State private var destinations: [Destination] = []
    let onSelect: (Endpoint) -> Void
    
    var body: some View {
        ZStack {
            Color.blue.ignoresSafeArea()
            
            VStack(){
                // content
                
                HStack(spacing: 40){
                    // left content
                    
                    VStack(alignment: .leading, spacing: 4){
                        // top content
                        Text("K-Sini")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.white)
                        
                        
                        // bottom content
                        Text("Pilih tujuanmu, kami tunjukkan pintu keluar yang tepat.")
                            .font(.caption2)
                            .fontWeight(.regular)
                            .foregroundStyle(Color.white)
                    }//.padding
                    
                    
                    //right image
                    Image("map_with_pin")
                        .resizable()
                        .frame(width: 105, height: 105)
                        .padding(.trailing, 20)
                    
                }.padding(.horizontal, 15)
                
                // search bar
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.white)
                    
                    TextField(
                        "",
                        text: $searchText,
                        prompt: Text("Mau ke mana?")
                            .foregroundStyle(searchFont)
                    )
                    .foregroundStyle(.white)
                    
                }
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 20).fill(searchBG))
                .padding(.horizontal, 15)
                .padding(.top, 10)
                
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.top, 10)
            
            
        }
        .sheet(isPresented: $showSheet) {
            EndpointsPageSheet(
                endpoints: filteredEndpoints,
                destinations: filteredDestinations,
                onSelect: { pickedPoint in
                    showSheet = false
                    points.selectedDestination = nil
                    onSelect(pickedPoint)
                },
                onSelectDestination: { destination in
                    showSheet = false
                    points.resolveDestination(destination)
                    if points.destination != nil {
                        onSelect(points.destination!)
                    }
                }
            )
                .presentationDetents([.height(600), .large])
                .presentationDragIndicator(.hidden)
                .interactiveDismissDisabled(true)
                .presentationBackground(grayBG)
                .presentationBackgroundInteraction(.enabled)
        }
        .task {
            endpoints = EndpointLoader().load()
            destinations = DestinationLoader().load()
            print("Loaded \(endpoints.count) endpoints, \(destinations.count) destinations")
        }
        .onAppear {
            showSheet = true
        }
    }
}

#Preview {
    EndpointsPageView(
        onSelect: { _ in }
        
    )
}
