import MapKit
import SwiftUI

struct JourneyHeaderView: View {
    @Bindable var journeyVM: JourneyViewModel
    
    @Bindable var mapVM: MapViewModel
    @Bindable var hapticVM: DirectionalHapticViewModel
    @Binding var showFullMap: Bool
    
    @State private var showHapticTooltip = false
    @State private var tooltipTask: Task<Void, Never>? = nil
    
    var body: some View {
        
        ZStack(alignment: .top) {
            HStack {
                HStack(alignment: .top, spacing: 12) {
                    if let icon = journeyVM.currentDetailStep?.iconName {
                        Image(systemName: icon)
                            .font(.title)
                            .foregroundStyle(.primary)
                            .padding(.top, 2)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(journeyVM.currentDirection?.instructionID ?? journeyVM.currentDirection?.instructionEN ?? "—")
                            .font(.title)
                            .bold()
                            .foregroundStyle(.primary)
                        Text(progressText)
                            .font(.title2)
                            .foregroundStyle(.primary)
                    }
                }
                Spacer()
            }
            .padding(.top)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            .background(Color(.systemBackground).ignoresSafeArea(.container, edges: .top))
            .overlay(alignment: .bottomTrailing) {
                VStack(alignment: .trailing, spacing: 8) {
                    MiniMapView(
                        mapVM: mapVM,
                        journeyVM: journeyVM,
                        showFullMap: $showFullMap,
                        hapticVM: hapticVM
                    )
                    
                    Button {
                        hapticVM.isVibrationEnabled.toggle()
                        showTooltip()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: hapticVM.isVibrationEnabled ? "iphone.radiowaves.left.and.right" : "iphone.slash")
                                .font(.caption)
                                .bold()
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                    }
                    .background(.regularMaterial, in: Capsule())
                    .foregroundStyle(hapticVM.isVibrationEnabled ? .blue : .primary)
                    .background(alignment: .trailing) {
                        if showHapticTooltip {
                            HapticTooltipView()
                                .fixedSize()
                                .padding(.trailing, 48)
                                .transition(.asymmetric(insertion: .opacity.combined(with: .move(edge: .trailing)), removal: .opacity))
                        }
                    }
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
    
    private func showTooltip() {
        tooltipTask?.cancel()
        withAnimation {
            showHapticTooltip = true
        }
        tooltipTask = Task {
            do {
                try await Task.sleep(nanoseconds: 3_000_000_000)
                guard !Task.isCancelled else { return }
                withAnimation {
                    showHapticTooltip = false
                }
            } catch {
                // Task cancelled
            }
        }
    }
}

struct HapticTooltipView: View {
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(.primary)
                .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Haptic Feedback")
                    .font(.caption)
                    .bold()
                Text("Turn vibration on or off during navigation.")
                    .font(.caption2)
                    .foregroundStyle(.primary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            ZStack(alignment: .trailing) {
                Capsule()
                    .fill(Color(UIColor.systemGray4))
                
                // Pointer triangle pointing right
                Image(systemName: "arrowtriangle.right.fill")
                    .font(.caption2)
                    .foregroundStyle(Color(UIColor.systemGray4))
                    .offset(x: 4) 
            }
        )
        .padding(.trailing, 6) // Space for the pointer
    }
}


