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
    let placeholderColor = Color(red: 0.969, green: 0.949, blue: 0.898) // #f7f2e5
    
    @State private var showSheet = true
    @Environment(NavigationState.self) var points: NavigationState
    @State private var editTarget: EditingTarget?
    
    var body: some View {
        
        ZStack{
            //background (mapView)
            placeholderColor.ignoresSafeArea()
            
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
}


#Preview {
    ConfirmPointsView(onStart: {})
        .environment(NavigationState())
}
