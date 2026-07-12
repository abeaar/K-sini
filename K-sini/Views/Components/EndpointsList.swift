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

    var headerFont: Font = .subheadline
    var headerFontWeight: Font.Weight = .regular
    var headerColor: Color = .secondary

    var body: some View {
        Section {
            ForEach(endpoints) { endpoint in
                Button {
                    onSelect(endpoint)
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

                        if let dist = distanceFor?(endpoint), dist > 0 {
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("\(Int(dist)) m")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.blue)
                                    
                                    let mins = Int(ceil(dist / 1.4 / 60))
                                    Text("\(mins) min")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.trailing, 4)
                        }

                        Image(systemName: "chevron.right")
                            .foregroundStyle(.tertiary)
                    }
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
