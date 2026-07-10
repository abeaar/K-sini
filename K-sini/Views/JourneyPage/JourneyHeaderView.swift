import MapKit
import SwiftUI
import MapKit

struct JourneyHeaderView: View {
	let direction: PathDirection?
	let stepIndex: Int
	let totalSteps: Int
	var onMiniMapTap: (() -> Void)?

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
				VStack(spacing: 8) {
					MiniMapView(
						mapVM: mapVM,
						hapticVM: hapticVM
					)
					.onTapGesture {
						onMiniMapTap?()
					}
					
					Button {
						hapticVM.isVibrationEnabled.toggle()
					} label: {
						HStack(spacing: 6) {
							Image(systemName: hapticVM.isVibrationEnabled ? "iphone.radiowaves.left.and.right" : "iphone.slash")
//							Text(hapticVM.isVibrationEnabled ? "Vibrasi On" : "Vibrasi Off")
								.font(.caption)
								.bold()
						}
						.padding(.vertical, 8)
						.padding(.horizontal, 12)
						.clipShape(Capsule())
					}
                    .glassEffect(.regular.tint(.white).interactive())
					.foregroundStyle(hapticVM.isVibrationEnabled ? .blue : .secondary)
                }
//                .glassEffect(.regular.tint(.white).interactive())
				.offset(x: -24, y: 95)
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

