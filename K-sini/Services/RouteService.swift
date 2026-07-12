//
//  RouteService.swift
//  K-sini
//
//  Created by Tiko Aqsa Alif Nugroho on 06/07/26.
//

import Foundation
import CoreLocation

final class RouteService {

	func findRoute(
		from start: Endpoint,
		to destination: Endpoint,
		pathways: [Pathway]
	) -> [Pathway] {

		let destinationSet = Set(destination.checkpoints)

		let pathwayByID = Dictionary(
			uniqueKeysWithValues:
				pathways.map {
					($0.id, $0)
				}
		)

		var queue: [([Pathway], Pathway)] = []

		var visited = Set<String>()

		for checkpointID in start.checkpoints {

			guard let pathway = pathwayByID[checkpointID]
			else {
				continue
			}

			queue.append(
				([pathway], pathway)
			)

			visited.insert(
				pathway.id
			)

		}

		while !queue.isEmpty {

			let (route, node) = queue.removeFirst()

			if destinationSet.contains(node.id) {
				return route
			}
            
            // Or if any of the node's directions point to the destination endpoint
            for direction in node.directions {
                if direction.endpoints.contains(destination.id) {
                    return route
                }
            }

			for direction in node.directions {

				guard
					!direction.to.isEmpty
				else {
					continue
				}

				guard
					let next =
					pathwayByID[direction.to]
				else {
					continue
				}

				if visited.contains(next.id) {
					continue
				}

				visited.insert(next.id)

				queue.append((route + [next], next))
			}
		}
		return []
	}

	func calculateDistance(route: [Pathway]) -> Double {
		var distance: Double = 0
		guard route.count > 1 else { return 0 }
		for i in 0..<route.count - 1 {
			let p1 = route[i]
			let p2 = route[i+1]
			let loc1 = CLLocation(latitude: p1.coordinate.latitude, longitude: p1.coordinate.longitude)
			let loc2 = CLLocation(latitude: p2.coordinate.latitude, longitude: p2.coordinate.longitude)
			distance += loc1.distance(from: loc2)
		}
		return distance
	}

	func calculateTime(distance: Double) -> Double {
		// Assuming average walking speed of 1.4 m/s
		return distance / 1.4
	}
}
