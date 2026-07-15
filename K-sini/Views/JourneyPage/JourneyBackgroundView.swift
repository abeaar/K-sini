import SwiftUI

struct JourneyBackgroundView: View {
    let imageName: String?

    var body: some View {
        GeometryReader { geometry in
            if let imgName = imageName, let uiImage = UIImage(named: imgName) {
                ScrollView(.horizontal, showsIndicators: false) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: geometry.size.height)
                }
                .defaultScrollAnchor(.center)
            } else {
                ZStack {
                    Color.black.ignoresSafeArea()
                    VStack(spacing: 16) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 64))
                            .foregroundColor(Color.white.opacity(0.3))
                        Text("No Image Available")
                            .font(.headline)
                            .foregroundColor(Color.white.opacity(0.5))
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}

#Preview {
    JourneyBackgroundView(imageName: "Cari gate")
}
