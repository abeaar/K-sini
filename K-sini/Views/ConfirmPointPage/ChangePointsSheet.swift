//
//  ChangePointsSheet.swift
//  k-sini GPS point POC
//
//  Created by on 06/07/26.
//

import SwiftUI

enum ChangeMode {
    case start
    case destination
}

struct ChangePointsSheet: View {

    let mode: ChangeMode
    let onSelect: (Endpoint) -> Void
    let onSelectDestination: (Destination) -> Void
    var sheetTitle: String = ""

    @Environment(\.dismiss) private var dismiss
    @Environment(NavigationState.self) var points: NavigationState

    var body: some View {

        NavigationStack{
            VStack {
                List {
                    switch mode {
                    case .start:
                        EndpointList(
                            title: "",
                            endpoints: points.endpoints,
                            onSelect: onSelect,
                            distanceFor: { endpoint in
                                points.getDistance(to: endpoint)
                            },
                            currentStartID: points.start?.id,
                            currentDestinationID: points.destination?.id
                        )
                    case .destination:
                        DestinationList(
                            title: "",
                            destinations: points.destinations,
                            onSelect: onSelectDestination,
                            distanceFor: { destination in
                                points.getDistance(to: destination)
                            },
                            currentStartID: points.start?.id,
                            currentDestinationID: points.destination?.id
                        )
                    }
                }.padding(.top, -30)

            }
            .navigationTitle(sheetTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Label("Dismiss", systemImage: "xmark")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                }

            }
        }
    }
}

#Preview {
    ChangePointsSheet(
        mode: .destination,
        onSelect: { _ in },
        onSelectDestination: { _ in }
    ).environment(NavigationState())
}
