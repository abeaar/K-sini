//
//  SuccessIndicatorView.swift
//  K-sini
//
//  Created by Tiko Aqsa Alif Nugroho on 08/07/26.
//

import SwiftUI

struct SuccessIndicatorView: View {

	let isCompleted: Bool
	@State private var scale: CGFloat = 0
	@State private var opacity: Double = 0

	var body: some View {

		ZStack {
			Circle()
				.fill(.green.opacity(0.15))
				.frame(width: 90, height: 90)

			Image(systemName: "checkmark")
				.font(.system(size: 38, weight: .bold))
				.foregroundStyle(.green)
				.scaleEffect(scale)
				.opacity(opacity)
		}

		.onChange(of: isCompleted) {
			_, completed in
			guard completed else {
				scale = 0
				opacity = 0
				return
			}

			withAnimation(.spring(response: 0.45, dampingFraction: 0.6)) {
				scale = 1
				opacity = 1
			}
			
		}
	}
}
