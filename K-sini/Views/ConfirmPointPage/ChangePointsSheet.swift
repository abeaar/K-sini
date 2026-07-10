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

    @State private var endpoints: [Endpoint] = []
    @State private var destinations: [Destination] = []
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
                            endpoints: endpoints,
                            onSelect: onSelect
                        )
                    case .destination:
                        DestinationList(
                            title: "",
                            destinations: destinations,
                            onSelect: onSelectDestination
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
        .task {
            switch mode {
            case .start:
                endpoints = points.endpoints
            case .destination:
                destinations = DestinationLoader().load()
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
