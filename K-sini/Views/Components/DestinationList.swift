import SwiftUI

struct DestinationList: View {
    let title: String
    let destinations: [Destination]
    let onSelect: (Destination) -> Void

    var distanceFor: ((Destination) -> Double?)? = nil

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
                        
//                        if let dist = distanceFor?(destination) {
//                            if dist > 0 {
//                                VStack(alignment: .trailing, spacing: 2) {
//									Text("Estimasi ke pintu keluar")
//										.font(.caption)
//										.fontWeight(.light)
//										.foregroundStyle(.primary)
//                                    Text("\(Int(dist)) m")
//                                        .font(.subheadline)
//                                        .fontWeight(.semibold)
//                                        .foregroundStyle(.blue)
//                                    
//                                    // Menggunakan rata-rata kecepatan berjalan orang Indonesia (sekitar 1.1 m/s)
//                                    let mins = Int(ceil(dist / 1.1 / 60))
//                                    Text("\(mins) min")
//                                        .font(.caption2)
//                                        .foregroundStyle(.secondary)
//                                }
//                                .padding(.trailing, 4)
//								
//								Image(systemName: "chevron.right")
//									.foregroundStyle(.tertiary)
//                            } else {
//                                Text("Anda sudah di titik terdekat ke destinasi ini")
//									.multilineTextAlignment(.trailing)
//                                    .font(.caption)
//                                    .fontWeight(.medium)
//                                    .foregroundStyle(.blue)
//                                    .padding(.trailing, 4)
//                            }
//                        }
                    }
//                    Image(systemName: "chevron.right").foregroundStyle(.tertiary)
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
