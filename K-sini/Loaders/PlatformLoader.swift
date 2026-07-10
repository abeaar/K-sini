//
//  PlatformLoader.swift
//  K-sini
//
//  Created by Tiko Aqsa Alif Nugroho on 06/07/26.
//

import Foundation
import MapKit

struct PlatformLoader {
	func load() -> [Platform] {
		
		guard let url = Bundle.main.url(
			forResource: "platform",
			withExtension: "geojson"
		) else {
			return []
		}

		do {
			let data = try Data(contentsOf: url)
			let objects = try MKGeoJSONDecoder().decode(data)
			var result:[Platform] = []
			for object in objects {
				guard
					let feature = object
						as? MKGeoJSONFeature
				else {
					continue
				}
				guard
					let polygon =
					feature.geometry.first
					as? MKPolygon
				else {
					continue
				}

				guard
					let properties =
					feature.properties
				else {
					continue
				}

				let json = try JSONSerialization
					.jsonObject(
						with: properties
					)

				as? [String:Any]
				let id = json?["@id"]

					as? String

					?? UUID().uuidString

				let levelID =

					json?["level"]

					as? String

					?? ""

				let buildingID =

					json?["building_id"]

					as? String

					?? ""

				var name = ""

				if let names =

					json?["name"]

					as? [String:Any] {

					name =

						names["id"]

						as? String

						??

						names["en"]

						as? String

						?? ""

				}

				var fill = "#ffeeee"

				var stroke = "#cf3030"

				if let style =

					json?["style"]

					as? [String:Any] {

					fill =

						style["fill"]

						as? String

						?? fill

					stroke =

						style["stroke"]

						as? String

						?? stroke

				}

				var point:

				CLLocationCoordinate2D?

				if let display =

					json?["display_point"]

					as? [String:Any],

				   let coords =

					display["coordinates"]

					as? [Double],

				   coords.count == 2 {

					point =

						CLLocationCoordinate2D(

							latitude: coords[1],

							longitude: coords[0]

						)

				}

				result.append(

					Platform(

						id: id,

						levelID: levelID,

						buildingID: buildingID,

						name: name,

						polygon: polygon,

						fillColor: fill,

						strokeColor: stroke,

						displayPoint: point

					)

				)

			}

			return result

		}

		catch {

			print(error)

		}

		return []

	}
}
