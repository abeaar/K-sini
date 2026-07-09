import SwiftUI

// ponytail: image cycle is the background placeholder; header now reads
// JourneyViewModel.currentDirection. Map + GuidanceService polylines
// are a follow-up (no map assets in the bundle yet).

struct JourneyPage: View {
	/// Called when the user has tapped through all directions — signals return to root.
	let onFinished: () -> Void

	@Environment(NavigationState.self) var points: NavigationState
	@State private var journeyVM = JourneyViewModel()
	@Bindable private var hapticVM = DirectionalHapticViewModel()
	@Bindable private var mapVM = MapViewModel()

	var body: some View {
		VStack(spacing: 0) {
			JourneyHeaderView(
				direction: journeyVM.currentDirection,
				stepIndex: journeyVM.currentStepIndex,
				totalSteps: journeyVM.totalSteps,
				mapVM: mapVM,
				hapticVM: hapticVM
			)
			Spacer()
			JourneyTabBarView(onArrived: handleArrived)
				.padding(.horizontal)
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
		guard journeyVM.totalSteps > 0 else { return "image1" }
		let bucket = journeyVM.currentStepIndex % 3
		return ["image1", "image2", "image3"][bucket]
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
