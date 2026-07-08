//
//  ConfirmPointsView.swift
//  k-sini GPS point POC
//
//  Created by on 05/07/26.
//

import SwiftUI

enum EditingTarget : Identifiable {
    case start
    case destination

    var id: Self { self }
}

struct ConfirmPointsView: View {

    let onStart: () -> Void  // called when user taps "Mulai Navigasi"

    let grayBG = Color(red: 0.949, green: 0.949, blue: 0.965) // #f2f2f6

    @State private var showSheet = true
    @Environment(NavigationState.self) var points: NavigationState
    @State private var editTarget: EditingTarget?
    @State private var mapVM = MapViewModel()

    var body: some View {

        ZStack{
            MapPreview(viewModel: mapVM)

        }
        .task {
            mapVM.loadData()
            seedRoute()
        }
        .onChange(of: points.start) { _, _ in
            seedRoute()
        }
        .onChange(of: points.destination) { _, _ in
            seedRoute()
        }
        .onAppear {
            showSheet = true
        }
        .sheet(isPresented: $showSheet) {
            ConfirmPointsSheet(
                editTarget: $editTarget,
                onStart: onStart
            )
            .environment(points)
            .sheet(item: $editTarget) {
                target in
                ChangePointsSheet(
                    onSelect: { picked in
                        switch target {
                        case .start:
                            points.start = picked
                        case .destination:
                            points.destination = picked
                        }
                        editTarget = nil
                    }
                )
                .environment(points)
            }
                .presentationDetents([.height(325)])
                .presentationDragIndicator(.hidden)
                .interactiveDismissDisabled(true)
                .presentationBackground(grayBG)
                .presentationBackgroundInteraction(.enabled)
        }

    }

    private func seedRoute() {
        mapVM.selectedStartID = points.start?.id ?? ""
        mapVM.selectedDestinationID = points.destination?.id ?? ""
        mapVM.navigate()
    }
}


#Preview {
    ConfirmPointsView(onStart: {})
        .environment(NavigationState())
}
