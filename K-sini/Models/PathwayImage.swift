import Foundation
import CoreLocation
import SwiftUI

// Represents an entire A-Z journey (e.g., "Entrance to Platform 1")
struct GuidedRoute: Identifiable {
    let id: String
    let title: String
    let description: String
    let steps: [JourneyStep]
}

// Represents a single screen/turn in the journey
struct JourneyStep: Identifiable {
    let id: String
    let instruction: String
    let imageName: String // Must match the exact name in Assets.xcassets
}

let routeToPlatform1 = GuidedRoute(
    id: "route_peron1_to_GateA",
    title: "Stasiun Peron 1 ke Gate A",
    description: "Rute langsung menuju Gate A arah Rangasbitung",
    steps: [
        JourneyStep(id: "step_1", instruction: "Cari Eskalator di Sekitar", imageName: "Cari Eskalator"),
        JourneyStep(id: "step_2", instruction: "Naik Eskalator", imageName: "Naik Eskalator"),
        JourneyStep(id: "step_3", instruction: "Belok kanan lalu Belok Kiri", imageName: "Cari gate"),
        JourneyStep(id: "step_4", instruction: "Lewati Gate untuk Tap Out", imageName: "Gate tap"),
        JourneyStep(id: "step_5", instruction: "Cari Arah Alfamart lalu belok kiri", imageName: "Kiri alfa"),
        JourneyStep(id: "step_7", instruction: "Lurus Mencari Tangga", imageName: "Jalan Lurus no tangga"),
        JourneyStep(id: "step_8", instruction: "Belok Kanan Menuju Tangga", imageName: "Jalan lurus ada tangga"),
        JourneyStep(id: "step_9", instruction: "Menuruni Tangga", imageName: "Turuni tangga"),
        JourneyStep(id: "step_10", instruction: "Sampai di Gate A", imageName: "Gate keluar")   
    ]
)
