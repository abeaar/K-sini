import SwiftUI

@Observable
class JourneyImageCycle {
    let images: [String]
    private(set) var currentIndex: Int

    var currentImageName: String {
        images.isEmpty ? "" : images[currentIndex]
    }

    /// True once the user has tapped through all images (sitting on the last one)
    var isFinished: Bool {
        guard !images.isEmpty else { return true }
        return currentIndex >= images.count - 1
    }

    init(images: [String], startingAt index: Int = 0) {
        self.images = images
        self.currentIndex = images.isEmpty ? 0 : min(max(index, 0), images.count - 1)
    }

    /// Advances to the next image. Does nothing if already on the last image.
    func advance() {
        guard !images.isEmpty, !isFinished else { return }
        currentIndex += 1
    }
}
