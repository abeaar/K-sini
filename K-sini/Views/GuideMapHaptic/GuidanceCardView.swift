//
//  GuidanceCardView.swift
//  K-sini
//
//  Created by Tiko Aqsa Alif Nugroho on 08/07/26.
//

import SwiftUI

struct GuidanceCardView: View {

	let instruction: String
	let detail: String
	let imageName: String
	
	var body: some View {
		ZStack {
			Image(imageName)
			VStack {
				Text(instruction)
				Text(detail)
			}
		}
	}
}
