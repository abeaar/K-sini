//
//  UnitLoader.swift
//  K-sini
//
//  Created by Tiko Aqsa Alif Nugroho on 06/07/26.
//

import Foundation
import MapKit

struct UnitLoader {

	func load() -> [Unit] {
		
		guard let url = Bundle.main.url(
			
			forResource: "unit",
			
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
			
			var result:[Unit] = []
			
			for object in objects {
				
				guard let feature = object
						
						as? MKGeoJSONFeature
						
				else {
					
					continue
					
				}
				
				guard let polygon =
						
						feature.geometry.first
						
						as? MKPolygon
						
				else {
					
					continue
					
				}
				
				var id = UUID()
				
					.uuidString
				
				var name = ""
				
				var category = ""
				
				var levelID = ""
				
				var displayPoint: CLLocationCoordinate2D?
				
				var fillColor = "#D9D9D9"
				var strokeColor = "#666666"
				
				if let properties =
					
					feature.properties {
					
					let json = try JSONSerialization
					
						.jsonObject(
							
							with: properties
							
						)
					
					as? [String:Any]
					
					id =
					
					json?["@id"]
					
					as? String
					
					?? id
					
					if let names = json?["name"] as? [String:Any] {
						name = names["id"] as? String
						?? names["en"] as? String
						?? ""
					}
					
					category =
					
					json?["category"]
					
					as? String
					
					?? ""
					
					levelID =
					
					json?["level"]
					
					as? String
					
					?? ""
					
					let buildingID = json?["building_id"] as? String ?? ""
					
					if let display = json?["display_point"] as? [String:Any],
					   let coords = display["coordinates"] as? [Double],
					   coords.count == 2 {
						
						displayPoint = CLLocationCoordinate2D(
							latitude: coords[1],
							longitude: coords[0]
						)
						
					}
					else if let point =
								feature.geometry.first as? MKPointAnnotation {
						
						displayPoint = point.coordinate
						
					}
					
					if let style = json?["style"] as? [String:Any] {
						
						fillColor = style["fill"] as? String
						?? fillColor
						
						strokeColor = style["stroke"] as? String
						?? strokeColor
						
					}
					
					result.append(
						
						Unit(
							
							id: id,
							
							levelID: levelID,
							
							buildingID: buildingID,
							
							category: category,
							
							name: name,
							
							polygon: polygon,
							
							displayPoint: displayPoint,
							fillColor: fillColor,
							strokeColor: strokeColor
					)
						)
					
				}
			}
			
			return result
			
		}
		
		catch {
			
			print(error)
			
		}
		
		return []
		
	}

}
