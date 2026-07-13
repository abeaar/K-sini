import MapKit
import SwiftUI

struct JourneyPage: View {
    /// Called when the user has tapped through all directions — signals return to root.
    let onFinished: () -> Void

    @Environment(NavigationState.self) var points: NavigationState
    @State private var journeyVM = JourneyViewModel()
    @Bindable private var mapVM = MapViewModel()
    @Bindable private var hapticVM = DirectionalHapticViewModel()
    
    @State private var showCardSheet = true
    @State private var currentDetent: PresentationDetent = .height(120)

    var body: some View {
        VStack(spacing: 0) {
            JourneyHeaderView(
                journeyVM: journeyVM,

                mapVM: mapVM,
                hapticVM: hapticVM
            )
            Spacer()
        }
        .background {
            JourneyBackgroundView(imageName: backgroundImageName)
                .ignoresSafeArea()
        }
        .navigationBarBackButtonHidden(true) // back handled by onFinished
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showCardSheet) {
            JourneyBottomCardView(
                journeyVM: journeyVM,
                onLanjut: handleArrived,
                onAkhiri: { onFinished() }
            )
            .presentationDetents([.height(100), .height(290)])
            .presentationDragIndicator(.visible)
            .interactiveDismissDisabled(true)
            .presentationBackgroundInteraction(.enabled)
        }
        .task {
            journeyVM.start = points.start
            journeyVM.destination = points.destination
            journeyVM.pathways = points.pathways
            mapVM.loadData()
            mapVM.selectedStartID = points.start?.id ?? ""
            mapVM.selectedDestinationID = points.destination?.id ?? ""
            mapVM.navigate()
            
            mapVM.focus(on: journeyVM.currentCheckpoint?.coordinate)
            hapticVM.start()
//          hapticVM.headingService.setTargetCoordinate(coordinate)
        }
        .onChange(of: points.start) { _, _ in
            mapVM.selectedStartID = points.start?.id ?? ""
            mapVM.navigate()
        }
        .onChange(of: points.destination) { _, _ in
            mapVM.selectedDestinationID = points.destination?.id ?? ""
            mapVM.navigate()
        }
        .onChange(of: journeyVM.currentStepIndex) { _, _ in
            mapVM.focus(on: journeyVM.currentCheckpoint?.coordinate)
            if let coordinate = journeyVM.currentCheckpoint?.coordinate {
                hapticVM.headingService.setTargetCoordinate(coordinate)
            }
        }
        .onAppear {
            showCardSheet = true
        }
    }
    

    private var backgroundImageName: String? {
        let image = journeyVM.currentDirection?.image ?? ""
        return image.isEmpty ? nil : image
    }

    private var currentLevelPolygons: [MKPolygon] {
        guard let levelID = journeyVM.currentCheckpoint?.levelID else { return [] }
        return points.levels.first(where: { $0.id == levelID })?.polygons ?? []
    }

    private func handleArrived() {
        if journeyVM.currentStepIndex >= journeyVM.totalSteps - 1 {
            onFinished()
        } else {
            journeyVM.advance()
        }
    }
}
