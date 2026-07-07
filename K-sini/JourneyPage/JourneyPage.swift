import SwiftUI

struct JourneyPage: View {
    /// Called when the user has tapped through all images — signals return to root.
    let onFinished: () -> Void

    @State private var imageCycle = JourneyImageCycle(
        images: ["image1", "image2", "image3"],
        startingAt: 0
    )

    var body: some View {
        VStack(spacing: 0) {
            JourneyHeaderView()
            Spacer()
            JourneyTabBarView(onArrived: handleArrived)
                .padding(.horizontal)
        }
        .background {
            JourneyBackgroundView(imageName: imageCycle.currentImageName)
                .ignoresSafeArea()
        }
        .navigationBarBackButtonHidden(true) // back handled by onFinished
    }

    private func handleArrived() {
        if imageCycle.isFinished {
            // All images shown — return to root
            onFinished()
        } else {
            imageCycle.advance()
        }
    }
}

#Preview {
    JourneyPage(onFinished: {})
}
