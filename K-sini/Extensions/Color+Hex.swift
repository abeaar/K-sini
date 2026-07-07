//
//  Color+Hex.swift
//  K-sini
//
//  Created by Tiko Aqsa Alif Nugroho on 06/07/26.
//

import SwiftUI

extension Color {

	init(hex: String) {

		let hex = hex.trimmingCharacters(
			in: CharacterSet.alphanumerics.inverted
		)

		var int: UInt64 = 0

		Scanner(string: hex).scanHexInt64(&int)

		let r: Double
		let g: Double
		let b: Double
		let a: Double

		switch hex.count {

		case 3:

			let r4 = (int >> 8) & 0xF
			let g4 = (int >> 4) & 0xF
			let b4 = int & 0xF

			r = Double((r4 << 4) | r4) / 255
			g = Double((g4 << 4) | g4) / 255
			b = Double((b4 << 4) | b4) / 255

			a = 1

		case 6:

			let r8 = (int >> 16) & 0xFF
			let g8 = (int >> 8) & 0xFF
			let b8 = int & 0xFF

			r = Double(r8) / 255
			g = Double(g8) / 255
			b = Double(b8) / 255

			a = 1

		case 8:

			let a8 = (int >> 24) & 0xFF
			let r8 = (int >> 16) & 0xFF
			let g8 = (int >> 8) & 0xFF
			let b8 = int & 0xFF

			r = Double(r8) / 255
			g = Double(g8) / 255
			b = Double(b8) / 255
			a = Double(a8) / 255

		default:
			
			r = 0
			g = 0
			b = 0
			a = 1
			
		}

		self.init(
			red: r,
			green: g,
			blue: b,
			opacity: a
		)

	}

}
