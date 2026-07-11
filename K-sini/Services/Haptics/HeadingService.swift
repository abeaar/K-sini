//
//  HeadingService.swift
//  K-sini
//
//  Created by Tiko Aqsa Alif Nugroho on 08/07/26.
//

import CoreLocation
import Observation

@Observable
final class HeadingService: NSObject {

    var heading: Double = 0
    var currentCoordinate: CLLocationCoordinate2D?
    var targetBearing: Double?
    var targetCoordinate = CLLocationCoordinate2D(latitude: -6.173949, longitude: 106.872374)
    var onHeadingChanged: ((Double) -> Void)?
    var onLocationChanged: ((CLLocationCoordinate2D) -> Void)?
    var onBearingChanged: ((Double?) -> Void)?

    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.headingFilter = 1
        locationManager.distanceFilter = 1
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func start() {
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startUpdatingLocation()
        if CLLocationManager.headingAvailable() {
            locationManager.startUpdatingHeading()
        }
    }

    func stop() {
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
    }

    func setTargetCoordinate(_ coordinate: CLLocationCoordinate2D) {
        targetCoordinate = coordinate

        if let currentCoordinate {
            targetBearing = BearingCalculator.bearing(
                from: currentCoordinate,
                to: targetCoordinate
            )
            onBearingChanged?(targetBearing)
        }
    }
}

extension HeadingService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let magnetic = newHeading.magneticHeading
        let trueNorth = newHeading.trueHeading
        heading = trueNorth >= 0 ? trueNorth : magnetic
        onHeadingChanged?(heading)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard
            let coordinate =
            locations.last?.coordinate
        else {
            return
        }
        currentCoordinate = coordinate
        onLocationChanged?(coordinate)
        targetBearing = BearingCalculator.bearing(from: coordinate, to: targetCoordinate)
        onBearingChanged?(targetBearing)
    }
}
