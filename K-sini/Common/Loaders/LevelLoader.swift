//
//  LevelLoader.swift
//  K-sini
//
//  Created by Tiko Aqsa Alif Nugroho on 06/07/26.
//

import Foundation
import MapKit

struct LevelLoader {
	func load() ->  [Level] {
		guard let url = Bundle.main.url(
			forResource: "level",
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
			var result:[Level] = []
			for object in objects {
				guard let feature = object as? MKGeoJSONFeature
				else {
					continue
				}
				var polygons:[MKPolygon] = []
				
				if let poly = feature.geometry.first as? MKPolygon {
					polygons.append(poly)
				}
				else if let multi = feature.geometry.first as? MKMultiPolygon {
					polygons = multi.polygons
				}
				
				guard !polygons.isEmpty else {
					continue
				}
				var id = UUID()
					.uuidString
				var level = 0
				var name = ""
				if let properties = feature.properties {
					let json = try JSONSerialization
						.jsonObject(
							with: properties
						)
					as? [String:Any]
					id = (json?["@id"] as? String)
					?? (json?["id"] as? String)
					?? id
					
					if let intLevel = json?["level"] as? Int {
						level = intLevel
					}
					else if let stringLevel = json?["level"] as? String {
						level = Int(stringLevel) ?? 0
					}
					
					if let names = json?["name"] as? [String:Any] {
						name = names["key"] as? String
						?? names["id"] as? String
						?? "\(level)"
					}
					else {
						name = "\(level)"
					}
				}
				result.append(
					Level(
						id: id,
						number: level,
						name: name,
						polygons: polygons
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
