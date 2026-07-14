import Foundation
import Observation
import CoreLocation

@Observable
final class DirectionalHapticViewModel {

    // MARK: - Dependencies

    let headingService: HeadingService
    let hapticService: DirectionalHapticService

    // MARK: - State

    var onHeadingChanged: ((Double) -> Void)?
    var heading: Double = 0
    var targetBearing: Double?
    var onLocationChanged: ((CLLocationCoordinate2D) -> Void)?
    
    // UI state driven directly by the haptic service for true sync with the pulse
    var intensity: Float {
        return hapticService.currentIntensity
    }
    var isAligned: Bool {
        return hapticService.isTargetAligned
    }
    var isEnabled = false
    
    var isVibrationEnabled = true {
        didSet {
            if isEnabled {
                hapticService.setEnabled(isVibrationEnabled)
            }
        }
    }

    init(
        headingService: HeadingService = HeadingService(),
        hapticService: DirectionalHapticService = DirectionalHapticService()
    ) {
        self.headingService = headingService
        self.hapticService = hapticService
        configureCallbacks()
    }

    // MARK: - Lifecycle

    func start() {
        isEnabled = true
        headingService.start()
        hapticService.start()
        hapticService.setEnabled(isVibrationEnabled)
        update()
    }

    func stop() {
        isEnabled = false
        headingService.stop()
        hapticService.stop()
    }

    // MARK: - Navigation

    func updateTargetBearing(_ bearing: Double?) {
        targetBearing = bearing
        update()
    }

    func update() {
        heading = headingService.heading
        targetBearing = headingService.targetBearing

        if let bearing = targetBearing {
            hapticService.update(heading: heading, targetBearing: bearing)
        } else {
            // When no bearing, we could clear it, but wait for the next bearing.
        }
    }

    // MARK: - Callbacks

    private func configureCallbacks() {

        headingService.onHeadingChanged = { [weak self] heading in
            guard let self else { return }
            self.update()
            self.onHeadingChanged?(heading)
        }

        headingService.onBearingChanged = { [weak self] _ in
            self?.update()
        }

        headingService.onLocationChanged = { [weak self] coordinate in
            self?.onLocationChanged?(coordinate)
        }
    }
}
