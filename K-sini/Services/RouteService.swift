//
//  RouteService.swift
//  K-sini
//
//  Created by Tiko Aqsa Alif Nugroho on 06/07/26.
//

import Foundation

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

			for direction in node.directions {

				guard
					!direction.to.isEmpty
				else {
					continue
				}

				guard let next = pathwayByID[direction.to]
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
}
