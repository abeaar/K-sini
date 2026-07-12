//
//  ConfirmPointsSheet.swift
//  k-sini GPS point POC
//
//  Created by on 03/07/26.
//

// displays both start and destination. comes second

import SwiftUI

struct ConfirmPointsSheet: View {
    
    let onStart: () -> Void  // triggers .journey navigation
    
    @Environment(\.dismiss) private var dismiss
    @Environment(NavigationState.self) var points: NavigationState
    
    @Binding var editTarget: EditingTarget?
    @Binding var currentDetent: PresentationDetent
    
    var body: some View {
        VStack{ // title + rows + button
            //title
            
            Text("Pratinjau Arah")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.top, 25)
            
            if let dist = getRouteDistance(), dist > 0 {
                let mins = Int(ceil(dist / 1.1 / 60))
				Text("Estimasi ke pintu keluar: \(Int(dist)) m • \(mins) mnt jalan kaki")
					.font(.subheadline)
					.foregroundStyle(.blue)
            }
            
            //rows
            
            if currentDetent != .height(120) {
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
                .background(Color("BlueMain"))
                .cornerRadius(50)
                .padding(.horizontal, 15)
            }
            
        }
        .padding(.horizontal, 5)
    }
    
    private func getRouteDistance() -> Double? {
        if let target = points.selectedDestination {
            return points.getDistance(to: target)
        } else if let endpoint = points.destination {
            return points.getDistance(to: endpoint)
        }
        return nil
    }
}

#Preview {
    ConfirmPointsSheet(onStart: {}, editTarget: .constant(nil), currentDetent: .constant(.height(325)))
        .environment(NavigationState())
}

