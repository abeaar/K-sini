//
//  JourneyMiniMap.swift
//  K-sini
//
//  Created by on 07/07/26.
//

// ponytail: compass-mode mini-map; whole route as straight segments
// between pathway coordinates. Current step's segment is orange. To
// interpolate the user's progress along the current segment, drive the
// current dot's position from `route[i].coordinate` toward
// `route[i+1].coordinate` based on GPS distance covered.

import CoreLocation
import MapKit
import SwiftUI

struct JourneyMiniMap: View {

    let route: [Pathway]
    let currentPathwayIndex: Int
    let levelPolygons: [MKPolygon]

    private struct RouteSegment {
        let from: CLLocationCoordinate2D
        let to: CLLocationCoordinate2D
        let isCurrent: Bool
    }

    var body: some View {
        Canvas { context, size in
            guard route.count >= 2,
                  currentPathwayIndex >= 0,
                  currentPathwayIndex < route.count - 1
            else { return }

            let i = currentPathwayIndex
            let curr = route[i].coordinate
            let next = route[i + 1].coordinate
            let theta = bearingRadians(from: curr, to: next)
            let mid = midpoint(curr, next)

            let allCoords = routeCoordinates() + polygonCoordinates()
            let bbox = unionBbox(allCoords)
            let scale = fitScale(bbox: bbox, into: min(size.width, size.height), margin: 0.85)

            var ctx = context
            ctx.translateBy(x: size.width / 2, y: size.height / 2)
            ctx.scaleBy(x: 1, y: -1)
            ctx.scaleBy(x: scale, y: scale)
            ctx.rotate(by: .radians(theta))
            ctx.translateBy(x: -mid.longitude, y: -mid.latitude)

            drawLevelPolygons(context: ctx)
            drawSegments(context: ctx)
            drawDots(context: &ctx)
        }
        .frame(width: 120, height: 120)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color(.systemBackground), lineWidth: 6))
    }

    private var segments: [RouteSegment] {
        route.indices.dropLast().map { i in
            RouteSegment(
                from: route[i].coordinate,
                to: route[i + 1].coordinate,
                isCurrent: i == currentPathwayIndex
            )
        }
    }

    private func routeCoordinates() -> [CLLocationCoordinate2D] {
        route.map(\.coordinate)
    }

    private func polygonCoordinates() -> [CLLocationCoordinate2D] {
        levelPolygons.flatMap(\.coordinates)
    }

    private func drawLevelPolygons(context: GraphicsContext) {
        for polygon in levelPolygons {
            let path = pathFromCoordinates(polygon.coordinates)
            context.fill(path, with: .color(.blue.opacity(0.08)))
            context.stroke(path, with: .color(.blue), lineWidth: 2 / CGFloat(currentScale))
        }
    }

    private func drawSegments(context: GraphicsContext) {
        for segment in segments {
            var path = Path()
            path.move(to: CGPoint(x: segment.from.longitude, y: segment.from.latitude))
            path.addLine(to: CGPoint(x: segment.to.longitude, y: segment.to.latitude))
            if segment.isCurrent {
                context.stroke(
                    path,
                    with: .color(.orange),
                    style: StrokeStyle(lineWidth: 6 / CGFloat(currentScale), lineCap: .round, lineJoin: .round)
                )
            } else {
                context.stroke(
                    path,
                    with: .color(.gray.opacity(0.4)),
                    lineWidth: 4 / CGFloat(currentScale)
                )
            }
        }
    }

    private func drawDots(context: inout GraphicsContext) {
        let radius = 5.0 / CGFloat(currentScale)
        let rect = CGRect(x: -radius, y: -radius, width: radius * 2, height: radius * 2)
        for (index, pathway) in route.enumerated() {
            let dot = Path(ellipseIn: rect)
            context.translateBy(x: pathway.coordinate.longitude, y: pathway.coordinate.latitude)
            if index == currentPathwayIndex {
                context.fill(dot, with: .color(.red))
            } else {
                context.fill(dot, with: .color(.gray.opacity(0.5)))
            }
            context.translateBy(x: -pathway.coordinate.longitude, y: -pathway.coordinate.latitude)
        }
    }

    // ponytail: bbox scale is in degrees, not meters; uniform scale is fine
    // near the equator (Cisauk is at -6.3°). Replace with proper Mercator
    // projection if the app ever serves stations at high latitudes.
    private var currentScale: Double {
        let bbox = unionBbox(routeCoordinates() + polygonCoordinates())
        let s = fitScale(bbox: bbox, into: 120, margin: 0.85)
        return s.isFinite && s > 0 ? s : 1
    }

    private func pathFromCoordinates(_ coords: [CLLocationCoordinate2D]) -> Path {
        var path = Path()
        guard let first = coords.first else { return path }
        path.move(to: CGPoint(x: first.longitude, y: first.latitude))
        for coord in coords.dropFirst() {
            path.addLine(to: CGPoint(x: coord.longitude, y: coord.latitude))
        }
        path.closeSubpath()
        return path
    }
}

private func bearingRadians(
    from start: CLLocationCoordinate2D,
    to end: CLLocationCoordinate2D
) -> Double {
    let lat1 = start.latitude * .pi / 180
    let lat2 = end.latitude * .pi / 180
    let dLon = (end.longitude - start.longitude) * .pi / 180
    let y = sin(dLon) * cos(lat2)
    let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
    return atan2(y, x)
}

private func midpoint(
    _ a: CLLocationCoordinate2D,
    _ b: CLLocationCoordinate2D
) -> CLLocationCoordinate2D {
    CLLocationCoordinate2D(
        latitude: (a.latitude + b.latitude) / 2,
        longitude: (a.longitude + b.longitude) / 2
    )
}

private struct Bbox {
    let minLat: Double
    let maxLat: Double
    let minLon: Double
    let maxLon: Double
}

private func unionBbox(_ coords: [CLLocationCoordinate2D]) -> Bbox {
    guard let first = coords.first else {
        return Bbox(minLat: 0, maxLat: 0, minLon: 0, maxLon: 0)
    }
    var minLat = first.latitude, maxLat = first.latitude
    var minLon = first.longitude, maxLon = first.longitude
    for c in coords.dropFirst() {
        minLat = min(minLat, c.latitude); maxLat = max(maxLat, c.latitude)
        minLon = min(minLon, c.longitude); maxLon = max(maxLon, c.longitude)
    }
    return Bbox(minLat: minLat, maxLat: maxLat, minLon: minLon, maxLon: maxLon)
}

private func fitScale(bbox: Bbox, into size: Double, margin: Double) -> Double {
    let width = max(bbox.maxLon - bbox.minLon, 1e-9)
    let height = max(bbox.maxLat - bbox.minLat, 1e-9)
    return (size * margin) / max(width, height)
}
