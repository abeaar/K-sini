import SwiftUI

struct JourneyTabBarView: View {
    let onArrived: () -> Void
    var body: some View {
        
        HStack(spacing: 12) {
            Button(action: onArrived) {
                Text("I'm arrived")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 52)
            }
            .glassEffect(.regular.tint(.blue).interactive(), in: Capsule())
            
            Button(action: openMore) {
                Label("More options", systemImage: "ellipsis")
                    .labelStyle(.iconOnly)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .frame(width: 52, height: 52)
            }
            .glassEffect(.regular.tint(.white).interactive(), in: Circle())
        }
    }
    private func openMore() {}
}

#Preview {
    JourneyTabBarView(onArrived: {})
}
