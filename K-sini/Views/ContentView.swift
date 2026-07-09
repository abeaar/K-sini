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

    @State private var points = NavigationState()
    @State private var path: [AppScreen] = []

    var body: some View {
        NavigationStack(path: $path){
            EndpointsPageView(
                onSelect: { pickedDestination in //closure
                    points.destination = pickedDestination
                    path.append(.confirmPoints)
                }
            )
            .environment(points)
            .task {
                points.loadEndpoints()
                points.loadPathways()
                points.loadLevels()
                await points.detectStartingPoint()
            }
            .navigationDestination(for: AppScreen.self) { screen in
                switch screen {
                case .confirmPoints:
                    ConfirmPointsView(
                        onStart: { path.append(.journey) }
                    )
                    .environment(points)
                case .journey:
                    JourneyPage(
                        onFinished: { path = [] }
                    )
                    .environment(points)
                }
            }

        }

    }
}

#Preview {
    ContentView()
}
