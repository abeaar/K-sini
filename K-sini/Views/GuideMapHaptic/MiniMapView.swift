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
	@Bindable var hapticVM: DirectionalHapticViewModel
	@State private var showFullMap = false
	
	var body: some View {
		ZStack {
			IndoorMapView(
				mapVM: mapVM,
				allowsInteraction: false
			)
			.clipShape(Circle())

			CompassHUD(
				heading: hapticVM.heading,
				targetBearing: hapticVM.targetBearing
			)
			
//			VStack {
//                Spacer()
//				IntensityIndicator(intensity: hapticVM.intensity)
//			}

			.padding(.bottom, 12)

			if hapticVM.isAligned {
				SuccessIndicatorView(isCompleted: .constant(true))
			}
		}
		.frame(width: 220, height: 220)
		.background(.ultraThinMaterial)
		.clipShape(Circle())
		.overlay(
			Circle()
				.stroke(.white.opacity(0.2), lineWidth: 2)
		)
		.onTapGesture {
			showFullMap = true
		}
		.fullScreenCover(isPresented: $showFullMap){
			FullScreenMapView(
				mapVM: mapVM,
				hapticVM: hapticVM
			)
		}
	}
}

//private struct IntensityIndicator: View {
//	let intensity: Float
//	var body: some View {
//		Capsule()
//			.fill(LinearGradient(colors: [.green, .yellow, .orange, .red], startPoint: .leading, endPoint: .trailing))
//			.frame(width: CGFloat(intensity)*80, height: 80)
//	}
//}
