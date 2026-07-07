//
//  GeoJSONLoader.swift
//  K-sini
//
//  Created by Tiko Aqsa Alif Nugroho on 06/07/26.
//

import Foundation
import MapKit

enum GeoJSONLoader {

	static func polygons(

		named name: String

	) -> [MKPolygon] {

		guard let url = Bundle.main.url(

			forResource: name,

			withExtension: "geojson"

		)

		else {

			return []

		}

		do {

			let data = try Data(

				contentsOf: url

			)

			let objects = try MKGeoJSONDecoder()

				.decode(data)

			return objects.compactMap {

				($0 as? MKGeoJSONFeature)?

					.geometry.first

				as? MKPolygon

			}

		}

		catch {

			print(error)

		}

		return []

	}

}
