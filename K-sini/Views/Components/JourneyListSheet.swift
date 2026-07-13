//
//  CheckpointsListSheet.swift
//  K-sini
//
//  Created by on 10/07/26.
//

import SwiftUI

struct JourneyListSheet: View {
    
    @Environment(\.dismiss) private var dismiss
    
    let route1 : GuidedRoute
    
    var body: some View {
        
        NavigationStack{
            VStack {
                List {
                    ForEach(route1.steps) { checkpoint in
                        HStack(spacing: 10) {
                            Image(checkpoint.imageName)
                                .font(.title)
                                .foregroundStyle(.primary)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(checkpoint.instruction)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.primary)
                                
                                Text("lorem ipsum") // ganti jadi instruction desc
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                    
                    
                }.padding(.top, -30)
                
            }
            .navigationTitle("Detail Perjalanan")
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
    JourneyListSheet(
        route1: GuidedRoute(
            id: "route_peron1_to_GateA",
            title: "Stasiun Peron 1 ke Gate A",
            description: "Rute langsung menuju Gate A arah Rangasbitung",
            steps: [
                JourneyStep(id: "step_1", instruction: "Cari Eskalator di Sekitar", imageName: "Cari Eskalator"),
                JourneyStep(id: "step_2", instruction: "Naik Eskalator", imageName: "Naik Eskalator"),
                JourneyStep(id: "step_3", instruction: "Belok kanan lalu Belok Kiri", imageName: "Cari gate"),
                JourneyStep(id: "step_4", instruction: "Lewati Gate untuk Tap Out", imageName: "Gate tap"),
                JourneyStep(id: "step_5", instruction: "Cari Arah Alfamart lalu belok kiri", imageName: "Kiri alfa"),
                JourneyStep(id: "step_7", instruction: "Lurus Mencari Tangga", imageName: "Jalan Lurus no tangga"),
                JourneyStep(id: "step_8", instruction: "Belok Kanan Menuju Tangga", imageName: "Jalan lurus ada tangga"),
                JourneyStep(id: "step_9", instruction: "Menuruni Tangga", imageName: "Turuni tangga"),
                JourneyStep(id: "step_10", instruction: "Sampai di Gate A", imageName: "Gate keluar")
            ]
        ))
    
    
}
