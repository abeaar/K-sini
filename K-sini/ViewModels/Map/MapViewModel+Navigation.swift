//
//  MapViewModel+Navigation.swift
//  K-sini
//
//  Created by Tiko Aqsa Alif Nugroho on 06/07/26.
//

extension MapViewModel {

	func navigate() {

		guard

			!selectedStartID.isEmpty,

			!selectedDestinationID.isEmpty

		else {

			routeSegments = []

			return

		}

		guard

			let start = endpoints.first(

				where: {

					$0.id == selectedStartID

				}

			),

			let destination = endpoints.first(

				where: {

					$0.id == selectedDestinationID

				}

			)

		else {

			routeSegments = []

			return

		}

		routeSegments =

			routeService.findRoute(

				from: start,

				to: destination,

				pathways: pathways

			)

	}

}
