import SwiftUI

struct JourneyHeaderView: View {
    let direction: PathDirection?
    let stepIndex: Int
    let totalSteps: Int

    init(direction: PathDirection?, stepIndex: Int = 0, totalSteps: Int = 0) {
        self.direction = direction
        self.stepIndex = stepIndex
        self.totalSteps = totalSteps
    }

    var body: some View {

        ZStack(alignment: .top) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(direction?.instructionID ?? direction?.instructionEN ?? "—")
                        .font(.title)
                        .bold()
                        .foregroundStyle(.primary)

                    Text(progressText)
                        .font(.title2)
                        .foregroundStyle(.primary)
                }
                Spacer()
            }
            .padding(.top)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            .background(Color(.systemBackground))

            .overlay(alignment: .bottomTrailing) {
                Image(systemName: "map")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color(.systemBackground), lineWidth: 6)
                    )
                    .offset(x: -24, y: 50)
            }
        }
    }

    private var progressText: String {
        guard totalSteps > 0 else { return "" }
        let shown = min(stepIndex + 1, totalSteps)
        return "Langkah \(shown) dari \(totalSteps)"
    }
}

#Preview {
    JourneyHeaderView(direction: nil, stepIndex: 0, totalSteps: 0)
}
