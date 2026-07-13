//
//  MapViewModel+Camera.swift
//  K-sini
//
//

import MapKit
import SwiftUI

extension MapViewModel {

	// ponytail: fixed 30 m span suits indoor wayfinding — expose a tuning
	// constant when designers ask.
	static let followSpan: MKCoordinateSpan = MKCoordinateSpan(
		latitudeDelta: 0.0003,
		longitudeDelta: 0.0003
	)

	func focus(on coordinate: CLLocationCoordinate2D?) {
		guard let coordinate else { return }
		let region = MKCoordinateRegion(center: coordinate, span: Self.followSpan)
		position = .region(region)
	}
}
