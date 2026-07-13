//
//  EndpointsList.swift
//  k-sini GPS point POC
//
//  Created by on 05/07/26.
//

import SwiftUI

struct EndpointList: View {
    let title: String
    let endpoints: [Endpoint]
    let onSelect: (Endpoint) -> Void
    var distanceFor: ((Endpoint) -> Double?)? = nil
    var currentStartID: String? = nil
    var currentDestinationID: String? = nil

    var headerFont: Font = .subheadline
    var headerFontWeight: Font.Weight = .regular
    var headerColor: Color = .secondary

    var body: some View {
        Section {
            ForEach(endpoints) { endpoint in
                Button {
					if distanceFor?(endpoint) != nil && endpoint.id != currentStartID && endpoint.id != currentDestinationID {
						onSelect(endpoint)
					}
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: endpoint.icon)
                            .font(.title)
                            .foregroundStyle(.blue)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(endpoint.name)
                                .foregroundStyle(.primary)

                            Text(endpoint.alts.first ?? "")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        if endpoint.id == currentStartID {
                            Text("Lokasi sekarang")
                                .font(.caption)
                                .foregroundStyle(.blue)
                        } else if endpoint.id == currentDestinationID {
                            Text("Lokasi tujuanmu")
                                .font(.caption)
                                .foregroundStyle(.blue)
                        } else if distanceFor?(endpoint) == nil {
                            Text("Rute akan segera hadir")
                                .font(.caption2)
                                .italic()
                                .foregroundStyle(.secondary)
                        }
						if distanceFor?(endpoint) != nil && endpoint.id != currentStartID && endpoint.id != currentDestinationID {
							Image(systemName: "chevron.right")
								.foregroundStyle(.tertiary)
						}
                    }
                    .contentShape(Rectangle())
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
            }
        } header: {
            Text(title)
                .font(headerFont)
                .fontWeight(headerFontWeight)
                .foregroundStyle(headerColor)
        }
    }
}
