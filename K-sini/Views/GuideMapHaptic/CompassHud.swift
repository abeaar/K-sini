//

import SwiftUI

struct CompassHUD: View {
    let heading: Double
    let targetBearing: Double?
    var body: some View {
        ZStack {
//            CompassTicks()
            NorthMarker()
            Circle()
                .stroke(.white.opacity(0.15), lineWidth: 2)
            if let targetBearing {
                TargetMarker(angle: targetBearing - heading)
            }
            PlayerArrow()
        }
    }
}

private struct PlayerArrow: View {
    var body: some View {
        Image(systemName: "location.north.fill")
            .font(.title2)
            .foregroundStyle(.blue)
    }
}

private struct NorthMarker: View {
    var body: some View {
        VStack {
            Text("N")
                .font(.caption)
                .bold()
                .foregroundStyle(.red)
            Spacer()
        }
        .padding(.top,8)
    }
}

private struct TargetMarker: View {
    let angle: Double
    var body: some View {
        VStack {
            Circle()
                .fill(
                    .orange
                )
                .frame(
                    width: 12,
                    height: 12
                )
            Spacer()
        }
        .padding(.top,6)
        .rotationEffect(
            .degrees(angle)
        )
    }
}
