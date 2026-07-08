//
//  ChangePointsSheet.swift
//  k-sini GPS point POC
//
//  Created by on 06/07/26.
//

import SwiftUI

struct ChangePointsSheet: View {
    
    let onSelect: (Endpoint) -> Void
    var sheetTitle: String = ""
    
    @State private var endpoints: [Endpoint] = []
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        
        NavigationStack{
            VStack {
                
                List {
                    EndpointList(
                        title: "",
                        endpoints: endpoints,
                        onSelect: onSelect
                    )
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
            endpoints = EndpointLoader().load()
            print("Loaded \(endpoints.count) endpoints")
            
        }
    }
}

#Preview {
    ChangePointsSheet(
        onSelect: { _ in }
    ).environment(NavigationState())
}
