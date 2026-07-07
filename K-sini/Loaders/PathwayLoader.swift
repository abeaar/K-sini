//
//  PathwayLoader.swift
//  K-sini
//
//  Created by Tiko Aqsa Alif Nugroho on 06/07/26.
//

import Foundation
import MapKit

struct PathwayLoader {

	func load() -> [Pathway] {
		
		guard let url = Bundle.main.url(
			
			forResource: "pathway",
			
			withExtension: "geojson"
			
		)
				
		else {
			
			return []
			
		}
		
		do {
			
			let data = try Data(contentsOf: url)
			
			let objects = try MKGeoJSONDecoder()
			
				.decode(data)
			
			var result:[Pathway] = []
			
			for object in objects {
				
				guard let feature =
						
						object as? MKGeoJSONFeature
						
				else {
					
					continue
					
				}
				
				guard let geometry = feature.geometry.first as? MKPointAnnotation
				else {
					continue
				}
				
				guard let properties =
						
						feature.properties
						
				else {
					
					continue
					
				}
				
				let json = try JSONSerialization
				
					.jsonObject(
						
						with: properties
						
					)
				
				as? [String:Any]
				
				let id =
				
				json?["@id"]
				
				as? String
				
				?? UUID().uuidString
				
				let category =
				
				json?["category"]
				
				as? String
				
				?? ""
				
				let levelID =
				
				json?["level"]
				
				as? String
				
				?? ""
				
				var directions:
				
				[PathDirection]
				
				= []
				
				if let rawDirections =
					
					json?["directions"]
					
					as? [[String:Any]]
					
				{
					
					directions = rawDirections.map {
						
						item in
						
						PathDirection(
							
							key:
								
								item["key"]
							
							as? String
							
							?? "",
							
							instructionID:
								
								item["id"]
							
							as? String,
							
							instructionEN:
								
								item["en"]
							
							as? String,
							
							to:
								
								item["to"]
							
							as? String
							
							?? "",
							
							endpoints:
								
								item["endpoints"]
							
							as? [String]
							
							?? []
							
						)
						
					}
					
				}
				
				result.append(
					
					Pathway(
						
						id:id,
						
						levelID:levelID,
						
						category:category,
						
						coordinate: geometry.coordinate,
						
						directions:
							
							directions
						
					)
					
				)
				
			}
			let ids = Set(

				result.map {

					$0.id

				}

			)

			for pathway in result {

				for direction in pathway.directions {

					if direction.to.isEmpty {

						continue

					}

					if !ids.contains(

						direction.to

					){

						print(

							"BROKEN",

							pathway.id,

							"->",

							direction.to

						)

					}

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
