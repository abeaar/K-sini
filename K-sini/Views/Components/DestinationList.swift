import SwiftUI

struct DestinationList: View {
    let title: String
    let destinations: [Destination]
    let onSelect: (Destination) -> Void

    var distanceFor: ((Destination) -> Double?)? = nil
    var currentStartID: String? = nil
    var currentDestinationID: String? = nil

    var headerFont: Font = .title3
    var headerFontWeight: Font.Weight = .bold
    var headerColor: Color = .primary

    var body: some View {
        Section {
            ForEach(destinations) { destination in
                Button {
                    if let dist = distanceFor?(destination), dist > 0 {
                        onSelect(destination)
                    }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: destination.icon)
                            .font(.title)
                            .foregroundStyle(.blue)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(destination.name)
                                .foregroundStyle(.primary)

                            Text(destination.alts.first ?? "")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()
                        
                        if destination.id == currentStartID {
                            Text("Lokasi sekarang")
                                .font(.caption)
                                .foregroundStyle(.blue)
                        } else if destination.id == currentDestinationID {
                            Text("Lokasi tujuanmu")
                                .font(.caption)
                                .foregroundStyle(.blue)
                        } else if distanceFor?(destination) == nil {
                            Text("Rute akan segera hadir")
                                .font(.caption2)
                                .italic()
                                .foregroundStyle(.secondary)
                        }
                        
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.tertiary)
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
