import MapKit
import SwiftUI

struct JourneyHeaderView: View {
    @Bindable var journeyVM: JourneyViewModel
    
    @Bindable var mapVM: MapViewModel
    @Bindable var hapticVM: DirectionalHapticViewModel
    @Binding var showFullMap: Bool
    var body: some View {
        
        ZStack(alignment: .top) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(journeyVM.currentDirection?.instructionID ?? journeyVM.currentDirection?.instructionEN ?? "—")
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
            .background(Color(.systemBackground).ignoresSafeArea(.container, edges: .top))
            .overlay(alignment: .bottomTrailing) {
                VStack(spacing: 8) {
                    MiniMapView(
                        mapVM: mapVM,
                        journeyVM: journeyVM,
                        showFullMap: $showFullMap,
                        hapticVM: hapticVM
                    )
                    
                    Button {
                        hapticVM.isVibrationEnabled.toggle()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: hapticVM.isVibrationEnabled ? "iphone.radiowaves.left.and.right" : "iphone.slash")
                            
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
                .offset(x: -24, y: 95)
            }
        }
    }
    
    private var progressText: String {
        guard journeyVM.totalSteps > 0 else { return "" }
        let shown = min(journeyVM.currentStepIndex + 1, journeyVM.totalSteps)
        return "Langkah \(shown) dari \(journeyVM.totalSteps)"
    }
}


