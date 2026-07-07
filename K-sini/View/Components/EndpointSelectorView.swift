//
//  EndpointSelectorView.swift
//  K-sini
//
//  Created by Tiko Aqsa Alif Nugroho on 07/07/26.
//

import SwiftUI

struct EndpointSelectorView: View {

	@Bindable
	var viewModel: MapViewModel
	var body: some View {
		VStack(
			spacing: 8
		) {
			Picker(
				"Start",
				selection: $viewModel.selectedStartID
			) {
				Text("Pilih Titik Awal")
				.tag("")
				ForEach(
					viewModel.endpoints.sorted {
						$0.name < $1.name
					}
				) {
					endpoint in
					Text(endpoint.name)
					.tag(endpoint.id)
				}
			}

			Picker(
				"Destination",
				selection: $viewModel.selectedDestinationID
			) {
				Text("Pilih Tujuan")
				.tag("")
				ForEach(
					viewModel.endpoints.sorted {
						$0.name < $1.name
					}
				) {
					endpoint in
					Text(endpoint.name)
					.tag(endpoint.id)
				}
			}
		}
		.pickerStyle(.menu)
		.padding(.horizontal)
		.padding(.top, 8)
		.onChange(
			of: viewModel.selectedStartID
		) { _, _ in
			viewModel.navigate()
		}
		.onChange(
			of: viewModel.selectedDestinationID
		) { _, _ in
			viewModel.navigate()
		}
	}
}
