import SwiftUI

struct JourneyBackgroundView: View {
    let imageName: String
    
    // Tracks the active drag translation and the final saved position
    @State private var currentOffset: CGFloat = 0
    @State private var accumulatedOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            let imageWidth = screenHeight * (16 / 9)
            let maxOverflow = (imageWidth - screenWidth) / 2
            
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: screenWidth, height: screenHeight)
                .offset(x: currentOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let predictedOffset = accumulatedOffset + value.translation.width
                            currentOffset = min(max(predictedOffset, -maxOverflow), maxOverflow)
                        }
                        .onEnded { _ in
                            accumulatedOffset = currentOffset
                        }
                )
        }
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    JourneyBackgroundView(imageName: "Cari gate")
}
