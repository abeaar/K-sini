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
    @State private var currentDetent: PresentationDetent = .height(600)
    
    @Environment(NavigationState.self) var points: NavigationState
    
    let searchBG = Color(red: 0.071, green: 0.608, blue: 1) // #129bff
    let searchFont = Color(red: 0.511, green: 0.879, blue: 0.986)
    
    let onSelect: (Endpoint) -> Void

    //harusnya viewmodel i think
    var filteredEndpoints: [Endpoint] {
        guard !searchText.isEmpty else { return points.endpoints }
        return points.endpoints.filter { endp in
            endp.name.localizedCaseInsensitiveContains(searchText) ||
            endp.alts.contains { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var filteredDestinations: [Destination] {
        guard !searchText.isEmpty else { return points.destinations }
        return points.destinations.filter { dest in
            dest.name.localizedCaseInsensitiveContains(searchText) ||
            dest.alts.contains { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    //viewmodel end i think
    
    var body: some View {
        ZStack {
            Color("BlueMain").ignoresSafeArea()
            
            VStack(){
                // content
                
                HStack(spacing: 40){
                    // left content
                    
                    VStack(alignment: .leading, spacing: 4){
                        // top content
                        Text("K-SINI")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.white)
                        
                        
                        // bottom content
                        Text("Pilih tujuanmu, kami tunjukkan pintu keluar yang tepat.")
							.font(.default)
                            .fontWeight(.regular)
                            .foregroundStyle(Color.white)
                    }//.padding
                    
                    
                    //right image
                    Image("header-icon")
                        .resizable()
                        .frame(width: 105, height: 105)
                        .padding(.trailing, 20)
                    
                }.padding(.horizontal, 15)
                
                // search bar
                Button{
                    currentDetent = .large
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
							.foregroundStyle(.gray)
                        
                        Text("Mau ke mana?")
							.foregroundStyle(.gray)
                            
                        Spacer()
                    }
                    .padding(10)
					.background(RoundedRectangle(cornerRadius: 20).fill(Color.gray.opacity(0.1)))
                    .glassEffect()
                    .padding(.horizontal, 15)
                    .padding(.top, 10)
                }
                
                
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
                },
                currentDetent: $currentDetent,
                searchText: $searchText
            )
            .environment(points)
            .presentationDetents([.height(600), .large], selection: $currentDetent)
            .presentationDragIndicator(.hidden)
            .interactiveDismissDisabled(true)
            .presentationBackgroundInteraction(.enabled)
        }
        .onAppear {
            showSheet = true
        }
    }
}

#Preview {
    EndpointsPageView(
        onSelect: { _ in }
    ).environment(NavigationState())
}
