//
//  LocationManager.swift
//  k-sini GPS point POC
//
//  Created by on 02/07/26.
//

/*
 GPS -> LocationManager -> Current CLLocation
 */

import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocation, Never>?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
    }
    
    func requestOneShotLocation() async -> CLLocation {
        await withCheckedContinuation { continuation in
            self.continuation = continuation
            manager.requestLocation()   // ← one-shot request, built into CLLocationManager
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            continuation?.resume(returning: location)
            continuation = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // error log
    }
}
