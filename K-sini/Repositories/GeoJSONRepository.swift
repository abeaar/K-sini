//
//  GeoJSONRepository.swift
//  K-sini
//
//  Created by Tiko Aqsa Alif Nugroho on 06/07/26.
//

final class GeoJSONRepository:
	GeoJSONRepositoryProtocol
{

	private let buildingLoader =
		BuildingLoader()

	private let levelLoader =
		LevelLoader()

	private let platformLoader =
		PlatformLoader()

	private let unitLoader =
		UnitLoader()

	private let endpointLoader =
		EndpointLoader()

	private let pathwayLoader =
		PathwayLoader()

	private let destinationLoader =
		DestinationLoader()

	func loadBuildings() -> [Building] {

		buildingLoader.load()

	}

	func loadLevels() -> [Level] {

		levelLoader.load()

	}

	func loadPlatforms() -> [Platform] {

		platformLoader.load()

	}

	func loadUnits() -> [Unit] {

		unitLoader.load()

	}

	func loadEndpoints() -> [Endpoint] {

		endpointLoader.load()

	}

	func loadPathways() -> [Pathway] {

		pathwayLoader.load()

	}

	func loadDestinations() -> [Destination] {

		destinationLoader.load()

	}

}
