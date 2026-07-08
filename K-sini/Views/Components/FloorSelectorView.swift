//
//  FloorSelectorView.swift
//  K-sini
//
//  Created by Tiko Aqsa Alif Nugroho on 07/07/26.
//

import SwiftUI

struct FloorSelectorView: View {
	@Bindable
	var viewModel: MapViewModel
	var body: some View {
		VStack(spacing: 8) {
			ForEach(
				viewModel.levels.sorted {
					$0.number > $1.number
				}
			) { level in
				Button {
					withAnimation {
						viewModel.selectedLevelID = level.id
					}
				}
				label: {
					Text(level.name)
						.font(.headline)
						.frame(
							width: 42,
							height: 42
						)
						.background(
							viewModel.selectedLevelID == level.id ? .blue : .white
						)
						.foregroundStyle(
							viewModel.selectedLevelID == level.id ? .white : .black
						)
						.clipShape(
							RoundedRectangle(cornerRadius: 12)
						)
						.shadow(radius: 2)
				}
			}
		}
		.padding()
	}
}
