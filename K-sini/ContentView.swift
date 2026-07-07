//
//  ContentView.swift
//  k-sini GPS point POC
//
//  Created by on 05/07/26.
//

import SwiftUI

enum AppScreen: Hashable {
    case confirmPoints
    case journey
}

struct ContentView: View {
    
    @StateObject private var points = NavigationState() // instance
    @State private var path: [AppScreen] = []
    
    var body: some View {
        NavigationStack(path: $path){
            
            //pick a destination
            EndpointsPageView(
                onSelect: { pickedDestination in //closure
                    points.destination = pickedDestination
                    path.append(.confirmPoints)
                }
            )
            .environmentObject(points)
            .navigationDestination(for: AppScreen.self) { screen in
                switch screen {
                case .confirmPoints:
                    ConfirmPointsView(
                        onStart: { path.append(.journey) }
                    )
                    .environmentObject(points)
                    .task {
                        points.loadEndpoints()
                        await points.detectStartingPoint()
                    }
                case .journey:
                    JourneyPage(
                        onFinished: { path = [] }
                    )
                }
            }
            
        }
        
    }
}

#Preview {
    ContentView()
}
