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
    
    let placeholderColor = Color(red: 0.969, green: 0.949, blue: 0.898) // #f7f2e5
    
    @Environment(NavigationState.self) var points: NavigationState
    
    @State private var showSheet = true
    @State private var editTarget: EditingTarget?
    @State private var currentDetent: PresentationDetent = .height(325)
    
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
                onStart: onStart,
                editTarget: $editTarget,
                currentDetent: $currentDetent
            )
            .environment(points)
            .sheet(item: $editTarget) {
                target in
                ChangePointsSheet(
                    mode: target == .start ? .start : .destination,
                    onSelect: { picked in
                        points.start = picked
                        editTarget = nil
                    },
                    onSelectDestination: { picked in
                        points.resolveDestination(picked)
                        editTarget = nil
                    },
                    sheetTitle: target == .start ? "Ganti Lokasi" : "Ganti Destinasi"
                )
                .environment(points)
            }
            .presentationDetents([.height(325), .height(100)], selection: $currentDetent)
            .interactiveDismissDisabled(true)
            .presentationBackground(Color(.systemGroupedBackground))
            .presentationBackgroundInteraction(.enabled)
        }
        
    }
}

#Preview {
    ConfirmPointsView(onStart: {})
        .environment(NavigationState())
}
