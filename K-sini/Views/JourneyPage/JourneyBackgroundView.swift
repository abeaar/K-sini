import SwiftUI

struct JourneyBackgroundView: View {
    let imageName: String

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: geometry.size.height)
            }
            .defaultScrollAnchor(.center)
        }
    }
}

#Preview {
    JourneyBackgroundView(imageName: "Cari gate")
}
