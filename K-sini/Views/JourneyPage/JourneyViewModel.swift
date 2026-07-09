//
//  JourneyViewModel.swift
//  k-sini GPS point POC
//
//  ponytail: data plumbing for the wired journey; JourneyPage rewire to
//  render currentDirection + segments is the next pass.
//

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

}
