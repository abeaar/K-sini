//
//  GeoJSONRepositoryProtocol.swift
//  K-sini
//
//  Created by Tiko Aqsa Alif Nugroho on 06/07/26.
//

protocol GeoJSONRepositoryProtocol {
	func loadBuildings() -> [Building]
	func loadLevels() -> [Level]
	func loadPlatforms() -> [Platform]
	func loadUnits() -> [Unit]
	func loadEndpoints() -> [Endpoint]
	func loadPathways() -> [Pathway]
}
