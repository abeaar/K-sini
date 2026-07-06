//
//  ContentView.swift
//  K-sini
//
//  Created by abr on 02/07/26.
//

import SwiftUI
import MapKit

struct ContentView: View {

	@State private var vm = MapViewModel()
	var body: some View {
		VStack(spacing: 0) {
			EndpointSelectorView(viewModel: vm)

			ZStack(alignment: .topTrailing) {
				Map(position: $vm.position) {
					BuildingLayer(buildings: vm.buildings)
					LevelLayer(levels: vm.levels, selectedLevelID: vm.selectedLevelID)
					PlatformLayer(platforms: vm.platforms, selectedLevelID: vm.selectedLevelID)
					UnitLayer(units: vm.units, selectedLevelID: vm.selectedLevelID)
					EndpointLayer(endpoints: vm.endpoints, selectedLevelID: vm.selectedLevelID)
					GuidanceLayer(segments: vm.currentSegments())
				}
				FloorSelectorView(viewModel: vm)
			}
		}
		.task {
			vm.loadData()
		}

	}

}
