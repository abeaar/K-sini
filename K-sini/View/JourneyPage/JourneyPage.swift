import MapKit
import SwiftUI

// ponytail: image cycle is the background placeholder; header now reads
// JourneyViewModel.currentDirection. Map + GuidanceService polylines
// are a follow-up (no map assets in the bundle yet).

struct JourneyPage: View {
    /// Called when the user has tapped through all directions — signals return to root.
    let onFinished: () -> Void

    @Environment(NavigationState.self) var points: NavigationState
    @State private var vm = JourneyViewModel()
    @State private var showFullMap = false

    var body: some View {
        VStack(spacing: 0) {
            JourneyHeaderView(
                direction: vm.currentDirection,
                stepIndex: vm.currentStepIndex,
                totalSteps: vm.totalSteps,
                route: vm.route,
                currentPathwayIndex: vm.currentPathwayIndex ?? 0,
                levelPolygons: currentLevelPolygons,
                onMiniMapTap: { showFullMap = true }
            )
            Spacer()
            JourneyTabBarView(onArrived: handleArrived)
                .padding(.horizontal)
        }
        .fullScreenCover(isPresented: $showFullMap) {
            JourneyFullMapView()
                .environment(points)
        }
        .background {
            JourneyBackgroundView(imageName: backgroundImageName)
                .ignoresSafeArea()
        }
        .navigationBarBackButtonHidden(true) // back handled by onFinished
        .task {
            vm.start = points.start
            vm.destination = points.destination
            vm.pathways = points.pathways
        }
    }

    private var backgroundImageName: String {
        guard vm.totalSteps > 0 else { return "image1" }
        let bucket = vm.currentStepIndex % 3
        return ["image1", "image2", "image3"][bucket]
    }

    private var currentLevelPolygons: [MKPolygon] {
        guard let levelID = vm.currentCheckpoint?.levelID else { return [] }
        return points.levels.first(where: { $0.id == levelID })?.polygons ?? []
    }

    private func handleArrived() {
        if vm.isFinished {
            onFinished()
        } else {
            vm.advance()
        }
    }
}

#Preview {
    JourneyPage(onFinished: {})
        .environment(NavigationState())
}
