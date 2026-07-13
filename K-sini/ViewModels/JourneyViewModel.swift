

import Foundation
import CoreLocation
import SwiftUI

@Observable
final class JourneyViewModel {

    private let routeService: RouteService

    private(set) var route: [Pathway] = []
    private(set) var currentStepIndex: Int = 0

    var start: Endpoint? {
        didSet { recompute() }
    }

    var destination: Endpoint? {
        didSet { recompute() }
    }

    var pathways: [Pathway] = [] {
        didSet { recompute() }
    }

    init(routeService: RouteService = RouteService()) {
        self.routeService = routeService
    }

    /// Total number of `PathDirection` steps across the route's pathways.
    var totalSteps: Int {
        route.reduce(0) { $0 + $1.directions.count }
    }

    /// The direction the user is currently on. nil if the route is empty
    /// or the user has finished all steps.
    var currentDirection: PathDirection? {
        let steps = totalSteps
        guard steps > 0, currentStepIndex < steps else { return nil }
        return direction(at: currentStepIndex)
    }

    var isFinished: Bool {
        let steps = totalSteps
        return steps > 0 && currentStepIndex >= steps
    }

    /// Index in `route` of the pathway that contains the current step.
    /// nil when the route is empty or the user has finished.
    var currentPathwayIndex: Int? {
        guard !route.isEmpty, currentStepIndex < totalSteps else { return nil }
        var remaining = currentStepIndex
        for (index, pathway) in route.enumerated() {
            if remaining < pathway.directions.count {
                return index
            }
            remaining -= pathway.directions.count
        }
        return nil
    }

    /// The pathway coordinate the user is currently on, with the level it belongs to.
    var currentCheckpoint: (coordinate: CLLocationCoordinate2D, levelID: String)? {
        guard let i = currentPathwayIndex else { return nil }
        let p = route[i]
        return (p.coordinate, p.levelID)
    }

    /// Coordinate of the next pathway referenced by the current step's `PathDirection.to`.
    /// nil on the last step or when `to` is empty.
    var nextCheckpoint: CLLocationCoordinate2D? {
        guard let i = currentPathwayIndex else { return nil }
        let pathway = route[i]
        var remaining = currentStepIndex
        for prior in route.prefix(i) {
            remaining -= prior.directions.count
        }
        guard pathway.directions.indices.contains(remaining) else { return nil }
        let toID = pathway.directions[remaining].to
        guard !toID.isEmpty else { return nil }
        return pathways.first(where: { $0.id == toID })?.coordinate
    }

    func advance() {
        guard !isFinished else { return }
        currentStepIndex += 1
    }

    private func direction(at flatIndex: Int) -> PathDirection? {
        var remaining = flatIndex
        for pathway in route {
            if remaining < pathway.directions.count {
                return pathway.directions[remaining]
            }
            remaining -= pathway.directions.count
        }
        return nil
    }

    private func recompute() {
        guard let start, let destination else {
            route = []
            currentStepIndex = 0
            return
        }
        route = routeService.findRoute(from: start, to: destination, pathways: pathways)
        currentStepIndex = 0
    }
    
    // UI Helpers
    
    var distanceToNext: Double? {
        guard let current = currentCheckpoint?.coordinate, let next = nextCheckpoint else { return nil }
        let currentLoc = CLLocation(latitude: current.latitude, longitude: current.longitude)
        let nextLoc = CLLocation(latitude: next.latitude, longitude: next.longitude)
        return currentLoc.distance(from: nextLoc)
    }
    
    var distanceToNextString: String {
        guard let dist = distanceToNext else { return "-" }
        return "\(Int(dist)) Meter"
    }

    struct JourneyDetailStep: Identifiable {
        let id = UUID()
        let iconName: String
        let title: String
        let subtitle: String?
    }

    var detailSteps: [JourneyDetailStep] {
        var steps = [JourneyDetailStep]()
        for pathway in route {
            for dir in pathway.directions {
                let text = (dir.instructionID ?? dir.instructionEN ?? "").lowercased()
                
                // Determine icon based on text
                var icon = "arrow.up"
                if text.contains("peron") { icon = "figure.walk.circle.fill" }
                else if text.contains("naik") || text.contains("eskalator") || text.contains("tangga") { icon = "stairs" }
                else if text.contains("kiri") { icon = "arrow.turn.up.left" }
                else if text.contains("kanan") { icon = "arrow.turn.up.right" }
                else if text.contains("keluar") { icon = "a.circle" }
                
                // Determine title and subtitle
				let title = dir.instructionID ?? dir.instructionEN ?? "Lanjutkan"
                var subtitle: String? = nil
                
                // Hardcode logic similar to mockups for a better UI experience
                if title.lowercased().contains("keluar dari peron 1") {
                    subtitle = "Ikuti jalur menuju area concourse."
                } else if title.lowercased().contains("menuju eskalator") {
                    subtitle = "Cari eskalator terdekat di depan Anda."
                } else if title.lowercased().contains("naik ke lantai 1") {
                    subtitle = "Gunakan eskalator menuju lantai 1."
                } else if title.lowercased().contains("belok kiri") {
                    subtitle = "Ikuti arah menuju plang keluar."
                } else if title.lowercased().contains("jalan lurus") {
                    subtitle = "Menuju gate keluar dengan lampu panah hijau."
                } else if title.lowercased().contains("lurus lalu belok kiri") {
                    subtitle = "Ikuti arah menuju Pintu Keluar A."
                } else if title.lowercased().contains("turuni tangga") {
                    subtitle = "Lanjutkan hingga mencapai area luar stasiun."
                } else if title.lowercased().contains("keluar melalui pintu") {
                    subtitle = "Anda telah tiba di area luar stasiun."
                }
                
                steps.append(JourneyDetailStep(iconName: icon, title: title, subtitle: subtitle))
            }
        }
        return steps
    }

}
