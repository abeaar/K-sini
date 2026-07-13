//
//  DestinationLoader.swift
//  K-sini
//

import Foundation
import MapKit

struct DestinationLoader {

    func load() -> [Destination] {

        guard let url = Bundle.main.url(
            forResource: "destination",
            withExtension: "geojson"
        ) else {
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let objects = try MKGeoJSONDecoder().decode(data)
            var result: [Destination] = []
            for object in objects {
                guard let feature = object as? MKGeoJSONFeature
                else {
                    continue
                }
                guard let properties = feature.properties else {
                    continue
                }
                let json = try JSONSerialization.jsonObject(with: properties)
                as? [String: Any]

                let id = json?["@id"] as? String ?? UUID().uuidString

                var name = "Destination"
                var icon = "mappin.circle.fill"
                var alts: [String] = []

                if let names = json?["name"] as? [String: Any] {

                    name = names["id"] as? String ?? names["en"] as? String ?? name
                    alts = names["alts"] as? [String] ?? []
                }

                if let markerSymbol = json?["marker-symbol"] as? String, !markerSymbol.isEmpty {
                    icon = markerSymbol
                }

                var coordinate = CLLocationCoordinate2D()

                if let point = feature.geometry.first as? MKPointAnnotation {
                    coordinate = point.coordinate
                }

                result.append(
                    Destination(
                        id: id,
                        name: name,
                        icon: icon,
                        alts: alts,
                        coordinate: coordinate
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
