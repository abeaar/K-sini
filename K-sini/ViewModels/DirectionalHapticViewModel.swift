//
//
//import Foundation
//import Observation
//import CoreLocation
//
//@Observable
//final class DirectionalHapticViewModel {
//
//    // MARK: - Dependencies
//
//    let headingService: HeadingService
//    let hapticService: DirectionalHapticService
//
//    // MARK: - State
//
//    var onHeadingChanged: ((Double) -> Void)?
//    var heading: Double = 0
//    var targetBearing: Double?
//    var onLocationChanged: ((CLLocationCoordinate2D) -> Void)?
//    var intensity: Float = 0
//    var isAligned = false
//    var isEnabled = false
//    var isVibrationEnabled = true
//
//    init(
//        headingService: HeadingService = HeadingService(),
//        hapticService: DirectionalHapticService = DirectionalHapticService()
//    ) {
//        self.headingService = headingService
//        self.hapticService = hapticService
//        configureCallbacks()
//    }
//
//    // MARK: - Lifecycle
//
//    func start() {
//        isEnabled = true
//        headingService.start()
//        if isVibrationEnabled {
//            hapticService.start()
//        }
//        update()
//    }
//
//    func stop() {
//        isEnabled = false
//        headingService.stop()
//        hapticService.stop()
//    }
//
//    // MARK: - Navigation
//
//    func updateTargetBearing(_ bearing: Double?) {
//        targetBearing = bearing
//        update()
//    }
//
//    func update() {
//        heading = headingService.heading
//        targetBearing = headingService.targetBearing
//
//        guard let bearing = targetBearing else {
//            intensity = 0
//            isAligned = false
//            return
//        }
//
//        let delta = headingDifference(current: heading, target: bearing)
//
//        intensity = max(0, min(1, Float(abs(delta) / 180)))
//        isAligned = abs(delta) <= 10
//
//        if isVibrationEnabled {
//            hapticService.isEnabled = true
//            hapticService.start()
//            hapticService.update(
//                heading: heading,
//                targetBearing: bearing
//            )
//        } else {
//            hapticService.stop()
//        }
//    }
//
//    // MARK: - Callbacks
//
//    private func configureCallbacks() {
//
//        headingService.onHeadingChanged = { [weak self] heading in
//            guard let self else { return }
//            self.update()
//            self.onHeadingChanged?(heading)
//        }
//
//        headingService.onBearingChanged = { [weak self] _ in
//            self?.update()
//        }
//
//        headingService.onLocationChanged = { [weak self] coordinate in
//            self?.onLocationChanged?(coordinate)
//        }
//    }
//
//    // MARK: - Helpers
//
//    private func headingDifference(
//        current: Double,
//        target: Double
//    ) -> Double {
//
//        var diff = target - current
//
//        while diff > 180 {
//            diff -= 360
//        }
//
//        while diff < -180 {
//            diff += 360
//        }
//
//        return diff
//    }
//}
