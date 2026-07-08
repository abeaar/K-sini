import MapKit
import SwiftUI

struct JourneyHeaderView: View {
    let direction: PathDirection?
    let stepIndex: Int
    let totalSteps: Int
    let route: [Pathway]
    let currentPathwayIndex: Int
    let levelPolygons: [MKPolygon]
    var onMiniMapTap: (() -> Void)? = nil

    init(
        direction: PathDirection?,
        stepIndex: Int = 0,
        totalSteps: Int = 0,
        route: [Pathway] = [],
        currentPathwayIndex: Int = 0,
        levelPolygons: [MKPolygon] = [],
        onMiniMapTap: (() -> Void)? = nil
    ) {
        self.direction = direction
        self.stepIndex = stepIndex
        self.totalSteps = totalSteps
        self.route = route
        self.currentPathwayIndex = currentPathwayIndex
        self.levelPolygons = levelPolygons
        self.onMiniMapTap = onMiniMapTap
    }

    private var canShowMiniMap: Bool {
        route.count >= 2 && currentPathwayIndex < route.count - 1
    }

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
                if canShowMiniMap {
                    JourneyMiniMap(
                        route: route,
                        currentPathwayIndex: currentPathwayIndex,
                        levelPolygons: levelPolygons
                    )
                    .offset(x: -24, y: 50)
                    .contentShape(Circle())
                    .onTapGesture { onMiniMapTap?() }
                } else {
                    Image(systemName: "map")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color(.systemBackground), lineWidth: 6)
                        )
                        .offset(x: -24, y: 50)
                        .contentShape(Circle())
                        .onTapGesture { onMiniMapTap?() }
                }
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
    JourneyHeaderView(direction: nil as PathDirection?, stepIndex: 0, totalSteps: 0)
}
