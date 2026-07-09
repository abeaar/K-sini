import MapKit
import SwiftUI

struct JourneyPage: View {
	/// Called when the user has tapped through all directions — signals return to root.
	let onFinished: () -> Void

    @Environment(NavigationState.self) var points: NavigationState
    @State private var journeyVM = JourneyViewModel()
	@Bindable private var hapticVM = DirectionalHapticViewModel()
	@Bindable private var mapVM = MapViewModel()
	@State private var showFullMap = false


    var body: some View {
        VStack(spacing: 0) {
            JourneyHeaderView(
				direction: journeyVM.currentDirection,
				stepIndex: journeyVM.currentStepIndex,
				totalSteps: journeyVM.totalSteps,
				onMiniMapTap: {showFullMap = true},
				mapVM: mapVM,
				hapticVM: hapticVM
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
			journeyVM.start = points.start
			journeyVM.destination = points.destination
			journeyVM.pathways = points.pathways
			hapticVM.onLocationChanged = { coordinate in
				mapVM.updateUserLocation(coordinate)
			}
			hapticVM.onHeadingChanged = { heading in
				mapVM.updateHeading(heading)
			}
			hapticVM.start()
        }
		.onDisappear{
			hapticVM.stop()
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
