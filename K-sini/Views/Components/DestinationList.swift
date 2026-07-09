import SwiftUI

struct DestinationList: View {
    let title: String
    let destinations: [Destination]
    let onSelect: (Destination) -> Void

    var headerFont: Font = .title3
    var headerFontWeight: Font.Weight = .bold
    var headerColor: Color = .primary

    var body: some View {
        Section {
            ForEach(destinations) { destination in
                Button {
                    onSelect(destination)
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
