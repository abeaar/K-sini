import MapKit
import SwiftUI

struct JourneyPage: View {
    /// Called when the user has tapped through all directions — signals return to root.
    let onFinished: () -> Void

    @Environment(NavigationState.self) var points: NavigationState
    @State private var journeyVM = JourneyViewModel()
    @State private var showFullMap = false
    @Bindable private var mapVM = MapViewModel()

    var body: some View {
        VStack(spacing: 0) {
            JourneyHeaderView(
                direction: journeyVM.currentDirection,
                stepIndex: journeyVM.currentStepIndex,
                totalSteps: journeyVM.totalSteps,
                
//                route: journeyVM.route,
//                currentPathwayIndex: journeyVM.currentPathwayIndex ?? 0,
//                levelPolygons: currentLevelPolygons,
                onMiniMapTap: { showFullMap = true },
                mapVM: mapVM
            )
            Spacer()
            JourneyTabBarView(onArrived: handleArrived)
                .padding(.horizontal)
        }
        .fullScreenCover(isPresented: $showFullMap) {
            MapPreview(viewModel: mapVM)
                .environment(points)
        }
        .background {
            JourneyBackgroundView(imageName: backgroundImageName)
                .ignoresSafeArea()
        }
        .navigationBarBackButtonHidden(true) // back handled by onFinished
        .task {
            journeyVM.start = points.start
            journeyVM.destination = points.destination
            journeyVM.pathways = points.pathways
            mapVM.loadData()
            mapVM.selectedStartID = points.start?.id ?? ""
            mapVM.selectedDestinationID = points.destination?.id ?? ""
            mapVM.navigate()
            mapVM.focus(on: journeyVM.currentCheckpoint?.coordinate)
        }
        .onChange(of: points.start) { _, _ in
            mapVM.selectedStartID = points.start?.id ?? ""
            mapVM.navigate()
        }
        .onChange(of: points.destination) { _, _ in
            mapVM.selectedDestinationID = points.destination?.id ?? ""
            mapVM.navigate()
        }
        .onChange(of: journeyVM.currentStepIndex) { _, _ in
            mapVM.focus(on: journeyVM.currentCheckpoint?.coordinate)
        }
    }

    private var backgroundImageName: String {
        let i = journeyVM.currentStepIndex
        guard routeToPlatform1.steps.indices.contains(i) else { return "Cari Eskalator" }
        return routeToPlatform1.steps[i].imageName
    }

    private var currentLevelPolygons: [MKPolygon] {
        guard let levelID = journeyVM.currentCheckpoint?.levelID else { return [] }
        return points.levels.first(where: { $0.id == levelID })?.polygons ?? []
    }

    private func handleArrived() {
        if journeyVM.isFinished {
            onFinished()
        } else {
            journeyVM.advance()
        }
    }
}

#Preview {
    JourneyPage(onFinished: {})
        .environment(NavigationState())
}
