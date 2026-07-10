//
//  FullScreenMapView.swift
//  K-sini
//
//  Created by Tiko Aqsa Alif Nugroho on 09/07/26.
//

import SwiftUI
import MapKit

struct FullScreenMapView: View {

	@Environment(\.dismiss) private var dismiss
	@Bindable var mapVM: MapViewModel
	@Bindable var hapticVM: DirectionalHapticViewModel

	var body: some View {

		NavigationStack {

			ZStack(alignment: .bottomTrailing) {
				IndoorMapView(
					mapVM: mapVM,
					allowsInteraction: true
				)
				.ignoresSafeArea()
				
				// Re-center button
				Button {
					withAnimation {
						mapVM.shouldFollowUser = true
						mapVM.centerOnUser()
					}
				} label: {
					Image(systemName: mapVM.shouldFollowUser ? "location.fill" : "location")
						.font(.title2)
						.foregroundStyle(.white)
						.frame(width: 50, height: 50)
						.background(Color.blue)
						.clipShape(Circle())
						.shadow(radius: 4)
				}
				.padding(16)
			}
			.onAppear {
				mapVM.zoomDistance = MapZoom.fullscreen
				mapVM.centerOnUser()
			}
			.onDisappear {
				mapVM.zoomDistance = MapZoom.mini
				mapVM.shouldFollowUser = true
				mapVM.centerOnUser()
			}
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					Button("Close") {
						dismiss()
					}
				}
			}
		}
	}
}
