//
//  UnitIconProvider.swift
//  K-sini
//
//  Created by Tiko Aqsa Alif Nugroho on 07/07/26.
//

import Foundation

enum UnitIconProvider {

	static func icon(
		for category: String
	) -> String {

		switch category {

		case "stairs":
			return "stairs"

		case "escalator":
			return "arrow.up.right"

		case "elevator":
			return "arrow.up.arrow.down"

		case "platform":
			return "tram.fill"

		default:
			return "mappin.circle.fill"

		}

	}

}
