import SwiftUI

struct JourneyEndAlertView: View {
    let onAkhiri: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Image(systemName: "flag.checkered")
                    .font(.title3)
                    .foregroundStyle(.primary)
                Text("Anda telah tiba di tujuan!")
                    .font(.headline)
                    .foregroundStyle(.primary)
            }
            .padding(.top, 16)
            
            Button {
                onAkhiri()
            } label: {
                Text("Akhiri Perjalanan")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .background(Color("BlueMain")) // Or dark blue as in screenshot?
                    .clipShape(Capsule())
            }
        }
        .padding(24)
		.glassEffect(
			.regular.tint(Color.primary.opacity(0.1)),
			in: RoundedRectangle(cornerRadius: 32)
		)
        .padding(40)
    }
}
