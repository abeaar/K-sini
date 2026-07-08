////
////  JourneyMiniMap.swift
////  K-sini
////
////  Created by on 07/07/26.
////
//
//import CoreLocation
//import MapKit
//import SwiftUI
//
//struct JourneyMiniMap: View {
//
//    let route: [Pathway]
//    let currentPathwayIndex: Int
//    let levelPolygons: [MKPolygon]
//
//    private struct RouteSegment {
//        let from: CLLocationCoordinate2D
//        let to: CLLocationCoordinate2D
//        let isCurrent: Bool
//    }
//
//    private var camera: MapCamera {
//        guard route.count >= 2,
//              currentPathwayIndex >= 0,
//              currentPathwayIndex < route.count - 1
//        else {
//            return MapCamera(
//                centerCoordinate: route.first?.coordinate
//                    ?? CLLocationCoordinate2D(latitude: 0, longitude: 0),
//                distance: 500
//            )
//        }
//
//        let curr = route[currentPathwayIndex].coordinate
//        let next = route[currentPathwayIndex + 1].coordinate
//        let center = midpoint(curr, next)
//        let heading = bearingDegrees(from: curr, to: next)
//        let distance = lookaheadDistance()
//
//        return MapCamera(
//            centerCoordinate: center,
//            distance: distance,
//            heading: heading,
//            pitch: 0
//        )
//    }
//
//    var body: some View {
//        Map(initialPosition: .camera(camera), interactionModes: []) {
//            ForEach(Array(levelPolygons.enumerated()), id: \.offset) { _, polygon in
//                MapPolygon(coordinates: polygon.coordinates)
//                    .foregroundStyle(.blue.opacity(0.08))
//                    .stroke(.blue, lineWidth: 2)
//            }
//
//            ForEach(Array(segments.enumerated()), id: \.offset) { _, segment in
//                MapPolyline(coordinates: [segment.from, segment.to])
//                    .stroke(
//                        segment.isCurrent ? .orange : .gray.opacity(0.4),
//                        style: StrokeStyle(
//                            lineWidth: segment.isCurrent ? 6 : 4,
//                            lineCap: .round,
//                            lineJoin: .round
//                        )
//                    )
//            }
//
//            ForEach(Array(route.enumerated()), id: \.offset) { index, pathway in
//                Annotation("", coordinate: pathway.coordinate) {
//                    Circle()
//                        .fill(index == currentPathwayIndex ? .red : .gray.opacity(0.5))
//                        .frame(width: 10, height: 10)
//                        .overlay(
//                            Circle().stroke(.white, lineWidth: 1.5)
//                        )
//                }
//            }
//        }
//        .frame(width: 120, height: 120)
//        .clipShape(Circle())
//        .overlay(Circle().stroke(Color(.systemBackground), lineWidth: 6))
//    }
//
//    private var segments: [RouteSegment] {
//        route.indices.dropLast().map { i in
//            RouteSegment(
//                from: route[i].coordinate,
//                to: route[i + 1].coordinate,
//                isCurrent: i == currentPathwayIndex
//            )
//        }
//    }
//
//    private func lookaheadDistance() -> Double {
//        let i = currentPathwayIndex
//        let window = 2
//        let lo = max(0, i - window)
//        let hi = min(route.count - 1, i + window)
//        let coords = (lo...hi).map { route[$0].coordinate }
//        guard coords.count >= 2 else { return 500 }
//        let bbox = unionBbox(coords)
//        let width = max(bbox.maxLon - bbox.minLon, 1e-9)
//        let height = max(bbox.maxLat - bbox.minLat, 1e-9)
//        let span = max(width, height)
//        return span * 120 * 1.2
//    }
//}
//
//private func midpoint(
//    _ a: CLLocationCoordinate2D,
//    _ b: CLLocationCoordinate2D
//) -> CLLocationCoordinate2D {
//    CLLocationCoordinate2D(
//        latitude: (a.latitude + b.latitude) / 2,
//        longitude: (a.longitude + b.longitude) / 2
//    )
//}
//
//private func bearingDegrees(
//    from start: CLLocationCoordinate2D,
//    to end: CLLocationCoordinate2D
//) -> CLLocationDistance {
//    let lat1 = start.latitude * .pi / 180
//    let lat2 = end.latitude * .pi / 180
//    let dLon = (end.longitude - start.longitude) * .pi / 180
//    let y = sin(dLon) * cos(lat2)
//    let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
//    let radians = atan2(y, x)
//    return radians * 180 / .pi
//}
//
//private struct Bbox {
//    let minLat: Double
//    let maxLat: Double
//    let minLon: Double
//    let maxLon: Double
//}
//
//private func unionBbox(_ coords: [CLLocationCoordinate2D]) -> Bbox {
//    guard let first = coords.first else {
//        return Bbox(minLat: 0, maxLat: 0, minLon: 0, maxLon: 0)
//    }
//    var minLat = first.latitude, maxLat = first.latitude
//    var minLon = first.longitude, maxLon = first.longitude
//    for c in coords.dropFirst() {
//        minLat = min(minLat, c.latitude); maxLat = max(maxLat, c.latitude)
//        minLon = min(minLon, c.longitude); maxLon = max(c.longitude, c.longitude)
//    }
//    return Bbox(minLat: minLat, maxLat: maxLat, minLon: minLon, maxLon: maxLon)
//}
