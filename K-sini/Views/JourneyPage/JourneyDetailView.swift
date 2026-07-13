import SwiftUI

struct JourneyDetailView: View {
    @Environment(\.dismiss) var dismiss
    
    let steps: [JourneyViewModel.JourneyDetailStep]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                            HStack(alignment: .top, spacing: 16) {
                                // Icon
                                Image(systemName: step.iconName)
                                    .font(.title2)
                                    .foregroundStyle(index == 0 ? .blue : .primary)
                                    .frame(width: 32, alignment: .center)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(step.title)
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                    
                                    if let subtitle = step.subtitle {
                                        Text(subtitle)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                Spacer()
                            }
                            .padding(.vertical, 16)
                            
                            if index < steps.count - 1 {
                                Divider()
                                    .padding(.leading, 48)
                            }
                        }
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .padding()
                }
            }
            .navigationTitle("Detail Perjalanan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Color(UIColor.systemGray3))
                    }
                }
            }
        }
    }
}
