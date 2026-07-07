//
//  ConfirmPointsSheet.swift
//  k-sini GPS point POC
//
//  Created by on 03/07/26.
//

// displays both start and destination. comes second

import SwiftUI

struct ConfirmPointsSheet: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(NavigationState.self) var points: NavigationState
    
    @Binding var editTarget: EditingTarget?
    let onStart: () -> Void  // triggers .journey navigation
    
    var body: some View {
        VStack{ // title + rows + button
            //title
            
            Text("Pratinjau Arah")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.top, 25)
            
            //rows
            
            List {
                //lokasi saat ini
                Button {
                    editTarget = .start
                } label: {
                    VStack(alignment: .leading){
                        // start
                        Text("Lokasi Saat Ini")
                            .font(.footnote)
                            .foregroundColor(.primary)
                        
                        // chosen location
                        Text(points.start?.name ?? "Titik Awal")
                            .font(.title3)
                            .foregroundStyle(Color.primary)
                            .fontWeight(.bold)
                     
                        // description
                        Text(points.start?.alts.first ?? "")
                            .font(.body)
                            .foregroundStyle(Color.secondary)
                    }
                    
                }
                
                //destinasi
                Button {
                    editTarget = .destination
                } label: {
                    VStack(alignment: .leading){
                        // label
                        Text("Destinasi")
                            .font(.footnote)
                            .foregroundColor(.primary)
                        
                        // chosen location — show destination name if available
                        if let dest = points.selectedDestination {
                            Text(dest.name)
                                .font(.title3)
                                .foregroundStyle(Color.primary)
                                .fontWeight(.bold)
                         
                            // via which endpoint
                            Text("via \(points.destination?.name ?? "")")
                                .font(.body)
                                .foregroundStyle(Color.secondary)
                        } else {
                            Text(points.destination?.name ?? "Titik Akhir")
                                .font(.title3)
                                .foregroundStyle(Color.primary)
                                .fontWeight(.bold)
                         
                            Text(points.destination?.alts.first ?? "")
                                .font(.body)
                                .foregroundStyle(Color.secondary)
                        }
                        
                    }
                    
                }
                
            }
            .contentMargins(.top, 10)
            .listStyle(.insetGrouped)
            .scrollDisabled(true)
            .padding(.bottom, 15)
            
            //button
            Button("Mulai Navigasi"){
                dismiss()  // close the sheet first, then navigate
                onStart()  // push .journey onto the NavigationStack path
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(.white)
            .padding(15)
            .background(Color.blue)
            .cornerRadius(50)
            .padding(.horizontal, 15)
            
        }
        .padding(.horizontal, 5)
    }
}

#Preview {
    ConfirmPointsSheet(editTarget: .constant(nil), onStart: {})
        .environment(NavigationState())
}

