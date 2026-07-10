//
//  EndpointLoader.swift
//  K-sini
//
//  Created by Tiko Aqsa Alif Nugroho on 06/07/26.
//

import Foundation
import MapKit

struct EndpointLoader {

	func load()  -> [Endpoint] {
		
		guard let url = Bundle.main.url(
			forResource: "endpoint",
			withExtension: "geojson"
		) else {
			return []
		}
		
		do {
			
			let data = try Data(contentsOf: url)
			
			let objects = try MKGeoJSONDecoder()
				.decode(data)
			
			var result: [Endpoint] = []
			
			for object in objects {
				guard let feature = object as? MKGeoJSONFeature
				else {
					continue
				}
				guard let properties = feature.properties else {
					continue
				}
				let json = try JSONSerialization
					.jsonObject(with: properties)
				as? [String: Any]
				
				let id =
				json?["@id"] as? String
				?? UUID().uuidString
				
				let levelID =
				json?["level"] as? String
				?? ""
				
				let buildingID =
				json?["building_id"] as? String
				?? ""
				
				let checkpoints =
				json?["checkpoints"] as? [String]
				?? []
				
				var name = "Endpoint"

				var icon = "mappin.circle.fill"

				var alts: [String] = []

				if let names =
					json?["name"]
					as? [String: Any] {

					name =
					names["id"] as? String
					?? names["en"] as? String
					?? names["key"] as? String
					?? name

					alts =
					names["alts"] as? [String]
					?? []

					if let symbol = names["key"] as? String,
					   symbol.count == 1,
					   symbol.allSatisfy({ $0.isLetter }) {
						icon = symbol.lowercased() + ".circle.fill"
					}
				}

				if let markerSymbol = json?["marker-symbol"] as? String,
				   !markerSymbol.isEmpty {
					icon = markerSymbol
				}

				var coordinate = CLLocationCoordinate2D()
				
				if let display = json?["display_point"] as? [String:Any],
				   let coords = display["coordinates"] as? [Double],
				   coords.count == 2 {
					
					coordinate = CLLocationCoordinate2D(
						latitude: coords[1],
						longitude: coords[0]
					)
					
				}
				else if let point = feature.geometry.first as? MKPointAnnotation {
					
					coordinate = point.coordinate
					
				}
				
				result.append(

					Endpoint(

						id: id,

						name: name,

						icon: icon,

						alts: alts,

						levelID: levelID,

						buildingID: buildingID,

						coordinate: coordinate,

						checkpoints: checkpoints

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
