//
//  MiniMapView.swift
//  K-sini
//
//  Created by Tiko Aqsa Alif Nugroho on 08/07/26.
//

import SwiftUI
import MapKit

struct MiniMapView: View {

    @Bindable var mapVM: MapViewModel
    @State private var showFullMap = false
//    @Bindable var hapticVM: DirectionalHapticViewModel

    var body: some View {
        ZStack {
            IndoorMapView(
                mapVM: mapVM,
                allowsInteraction: false
            )
            .clipShape(Circle())

//            CompassHUD(
//                heading: hapticVM.heading,
//                targetBearing: hapticVM.targetBearing
//            )
//            .padding(.bottom, 12)
//
//            SuccessIndicatorView(isCompleted: $hapticVM.isAligned)
        }
        .frame(width: 110, height: 110)
        .background(.ultraThinMaterial)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(.white.opacity(0.2), lineWidth: 2)
        )
        .onTapGesture {
            showFullMap = true
        }
        .fullScreenCover(isPresented: $showFullMap) {
            JourneyFullMapView(viewModel: mapVM)
                .overlay(alignment: .topLeading) {
                    Button { showFullMap = false } label: {
                        Image(systemName: "chevron.left")
                            .font(.title3.bold())
                            .padding(10)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .padding(.leading, 16)
                    .padding(.top, 16)
                }
        }
    }
}

//private struct IntensityIndicator: View {
//    let intensity: Float
//    var body: some View {
//        Capsule()
//            .fill(LinearGradient(colors: [.green, .yellow, .orange, .red], startPoint: .leading, endPoint: .trailing))
//            .frame(width: CGFloat(intensity)*80, height: 80)
//    }
//}
