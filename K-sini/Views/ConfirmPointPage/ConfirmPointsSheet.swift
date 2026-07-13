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
                .fontWeight(.semibold)
                .padding(.top, 25)
//            
//            if let dist = getRouteDistance(), dist > 0 {
//                let mins = Int(ceil(dist / 1.1 / 60))
//				Text("Estimasi ke pintu keluar: \(Int(dist)) m • \(mins) mnt jalan kaki")
//					.font(.subheadline)
//					.foregroundStyle(.blue)
//            }
            
            //rows
            
            if currentDetent != .height(100) {
                VStack(spacing: 12) {
                    //lokasi saat ini
                    Button {
                        editTarget = .start
                    } label: {
                        pointRow(
                            color: .blue,
                            icon: "location.north.fill",
                            label: "Lokasi Kamu",
                            title: points.start?.name ?? "Titik Awal",
                            subtitle: points.start?.alts.first ?? ""
                        )
                    }
                    .buttonStyle(.plain)

                    //destinasi
                    Button {
                        editTarget = .destination
                    } label: {
                        if let dest = points.selectedDestination {
                            pointRow(
                                color: .green,
                                icon: "figure.walk",
                                label: "Destinasi",
                                title: dest.name,
                                subtitle: "via \(points.destination?.name ?? "")"
                            )
                        } else {
                            pointRow(
                                color: .green,
                                icon: "figure.walk",
                                label: "Destinasi",
                                title: points.destination?.name ?? "Titik Akhir",
                                subtitle: points.destination?.alts.first ?? ""
                            )
                        }
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
                .padding(.bottom,4)

                //button
                Button("Mulai Navigasi"){
                    dismiss()  // close the sheet first, then navigate
                    onStart()  // push .journey onto the NavigationStack path
                }
                .frame(maxWidth: .infinity)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(15)
                .background(Color("BlueMain"))
                .cornerRadius(50)
                .padding(.horizontal, 15)
            }
            
        }
        .padding(.horizontal, 5)
    }
    
    @ViewBuilder
    private func pointRow(color: Color, icon: String, label: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(color.opacity(0.2))
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(color)
            }
            .frame(width: 30, height: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.footnote)
                    .foregroundStyle(.primary)
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.systemBackground))
        )
        .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
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

