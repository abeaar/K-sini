import SwiftUI

struct JourneyBackgroundView: View {
    let imageName: String

    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFill()
    }
}

#Preview {
    JourneyBackgroundView(imageName: "image1")
}
