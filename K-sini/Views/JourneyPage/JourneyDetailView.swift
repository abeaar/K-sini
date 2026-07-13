import SwiftUI

struct JourneyDetailView: View {
    @Environment(\.dismiss) var dismiss
    
    let currentIndex: Int
    let steps: [JourneyViewModel.JourneyDetailStep]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemBackground).ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                            HStack(alignment: .top, spacing: 16) {
                                // Icon
                                Image(systemName: step.iconName)
                                    .font(.title2)
                                    .foregroundStyle(index == currentIndex ? .blue : .primary)
                                    .frame(width: 32, alignment: .center)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(step.title)
                                        .font(.headline)
                                        .foregroundStyle(index == currentIndex ? .blue : .primary)
                                    
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
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Detail Perjalanan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundStyle(Color(UIColor.systemGray3))
                    }
                }
            }
        }
    }
}
