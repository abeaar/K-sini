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

			IndoorMapView(
				mapVM: mapVM,
				allowsInteraction: true
			)
			.ignoresSafeArea()
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
