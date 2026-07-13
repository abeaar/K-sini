//
//  BuildingLoader.swift
//  K-sini
//
//  Created by Tiko Aqsa Alif Nugroho on 06/07/26.
//

import Foundation
import MapKit

struct BuildingLoader {
    func load() -> [Building] {
        guard let url = Bundle.main.url(
            forResource: "building",
            withExtension: "geojson"
        ) else {
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let objects = try MKGeoJSONDecoder().decode(data)
            var result: [Building] = []
            
            for object in objects {
                guard let feature = object as? MKGeoJSONFeature else { continue }
                guard let properties = feature.properties else { continue }
                
                let json = try JSONSerialization.jsonObject(with: properties) as? [String: Any]
                
                let id = json?["@id"] as? String ?? UUID().uuidString
                
                var name = "Building"
                if let names = json?["name"] as? [String: Any] {
                    name = names["id"] as? String ?? names["en"] as? String ?? name
                }
                
                var coordinate = CLLocationCoordinate2D()
                if let display = json?["display_point"] as? [String: Any],
                   let coords = display["coordinates"] as? [Double],
                   coords.count == 2 {
                    coordinate = CLLocationCoordinate2D(
                        latitude: coords[1],
                        longitude: coords[0]
                    )
                }
                
                let polygon = (feature.geometry.first as? MKPolygon) ?? MKPolygon()
                
                result.append(
                    Building(
                        id: id,
                        name: name,
                        coordinate: coordinate,
                        polygon: polygon
                    )
                )
            }
            return result
        } catch {
            print("Error loading buildings: \(error)")
        }
        return []
    }
}
