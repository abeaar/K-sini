import SwiftUI
import MapKit

struct JourneyHeaderView: View {
	let direction: PathDirection?
	let stepIndex: Int
	let totalSteps: Int

	@Bindable var mapVM: MapViewModel
	@Bindable var hapticVM: DirectionalHapticViewModel


	var body: some View {

		ZStack(alignment: .top) {
			HStack {
				VStack(alignment: .leading, spacing: 4) {
					Text(direction?.instructionID ?? direction?.instructionEN ?? "—")
						.font(.title)
						.bold()
						.foregroundStyle(.primary)

					Text(progressText)
						.font(.title2)
						.foregroundStyle(.primary)
				}
				Spacer()
			}
			.padding(.top)
			.padding(.horizontal, 24)
			.padding(.bottom, 24)
			.background(Color(.systemBackground))

			.overlay(alignment: .bottomTrailing) {
				MiniMapView(
					mapVM: mapVM,
					hapticVM: hapticVM
				)
				.offset(x: -24, y: 50)
			}
		}
	}

	private var progressText: String {
		guard totalSteps > 0 else { return "" }
		let shown = min(stepIndex + 1, totalSteps)
		return "Langkah \(shown) dari \(totalSteps)"
	}
}

#Preview {
	// Provide simple mock view models with default values
	let mapVM = MapViewModel()
	let hapticVM = DirectionalHapticViewModel()
	return JourneyHeaderView(
		direction: nil,
		stepIndex: 0,
		totalSteps: 0,
		mapVM: mapVM,
		hapticVM: hapticVM
	)
}

