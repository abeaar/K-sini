import SwiftUI

struct JourneyBottomCardView: View {
    @Bindable var journeyVM: JourneyViewModel
    
    let onLanjut: () -> Void
    let onAkhiri: () -> Void
    
    @State private var showEndAlert = false
    @State private var showDetailSheet = false
    
    var body: some View {
        GeometryReader { geo in
            let isExpanded = geo.size.height > 150
            
            VStack(spacing: 16) {
                if isExpanded {
                    // Expanded State
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Titik Berikutnya")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text(journeyVM.distanceToNextString)
								.font(.title)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                        }
                        
                        VStack(spacing: 12) {
                            Button(action: onLanjut) {
                                Text("Lanjut")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity, minHeight: 52)
                            }
                            .glassEffect(.regular.tint(Color("BlueMain")).interactive(), in: Capsule())
                            
                            Button(action: { showDetailSheet = true }) {
                                Text("Detail Perjalanan")
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                    .frame(maxWidth: .infinity, minHeight: 52)
                            }
                            .glassEffect(.regular.tint(.white).interactive(), in: Capsule())
                            
                            Button(action: { showEndAlert = true }) {
                                Text("Akhiri Perjalanan")
                                    .font(.headline)
                                    .foregroundStyle(.red)
                                    .frame(maxWidth: .infinity, minHeight: 52)
                            }
                            .glassEffect(.regular.tint(.white).interactive(), in: Capsule())
                        }
                    }
                } else {
                    // Compact State
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Titik Berikutnya")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text(journeyVM.distanceToNextString)
								.font(.title)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                        }
                        
                        Spacer()
                        
                        Button(action: onLanjut) {
                            Text("Lanjut")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 32)
                                .frame(minHeight: 52)
                        }
                        .glassEffect(.regular.tint(Color("BlueMain")).interactive(), in: Capsule())
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            
            Spacer()
        }
        .alert("Akhiri Perjalanan", isPresented: $showEndAlert) {
            Button("Akhiri", role: .destructive) {
                onAkhiri()
            }
            Button("Batal", role: .cancel) {}
        } message: {
            Text("Apakah Anda yakin ingin mengakhiri perjalanan ini?")
        }
        .sheet(isPresented: $showDetailSheet) {
            JourneyDetailView(steps: journeyVM.detailSteps)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}
