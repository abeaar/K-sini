import Foundation
import CoreHaptics
import UIKit

final class DirectionalHapticService {
    
    private(set) var currentIntensity: Float = 0
    private(set) var isEnabled = false
    private(set) var isTargetConfirmed = false
    var isTargetAligned: Bool { isTargetConfirmed }
    
    private var engine: CHHapticEngine?
    private var fallbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private var successGenerator = UINotificationFeedbackGenerator()
    private var lastPulseDate = Date.distantPast
    private var hapticTimer: DispatchSourceTimer?
    private var latestHeading: Double = 0
    private var latestTargetBearing: Double = 0
    private var hasReceivedData = false
    private var targetHoldStartDate: Date?
    
    init() {
    }
    
    func start() {
        isEnabled = true
        fallbackGenerator.prepare()
        successGenerator.prepare()
        
        if CHHapticEngine.capabilitiesForHardware().supportsHaptics {
            do {
                let engine = try CHHapticEngine()
                engine.stoppedHandler = { reason in
                    print("Haptic engine stopped: \(reason.rawValue)")
                }
                engine.resetHandler = { [weak self] in
                    try? self?.engine?.start()
                }
                try engine.start()
                self.engine = engine
            } catch {
                print("Core Haptics unavailable: \(error.localizedDescription)")
            }
        }
        
        startContinuousBuzzLoop()
    }
    
    func stop() {
        hapticTimer?.cancel()
        hapticTimer = nil
        hasReceivedData = false
        targetHoldStartDate = nil
        isTargetConfirmed = false
        currentIntensity = 0
        engine?.stop()
        engine = nil
        isEnabled = false
    }
    
    func update(heading: Double, targetBearing: Double) {
        hasReceivedData = true
        latestHeading = heading
        latestTargetBearing = targetBearing
        currentIntensity = isEnabled && !isTargetConfirmed ? Self.intensity(heading: heading, targetBearing: targetBearing) : 0
    }
    
    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        lastPulseDate = .distantPast
        targetHoldStartDate = nil
        isTargetConfirmed = false
        currentIntensity = enabled && hasReceivedData ? Self.intensity(heading: latestHeading, targetBearing: latestTargetBearing) : 0
    }
    
    private func startContinuousBuzzLoop() {
        hapticTimer?.cancel()
        
        let timer = DispatchSource.makeTimerSource(queue: .main)
        timer.schedule(deadline: .now(), repeating: 0.04)
        timer.setEventHandler { [weak self] in
            self?.tickBuzz()
        }
        timer.resume()
        hapticTimer = timer
    }
    
    private func tickBuzz() {
        guard isEnabled, hasReceivedData else { return }
        
        let headingError = Self.angularDifference(from: latestHeading, to: latestTargetBearing)
        if headingError <= 15 {
            handleTargetHold()
            return
        }
        
        targetHoldStartDate = nil
        isTargetConfirmed = false
        
        let intensity = Self.intensity(heading: latestHeading, targetBearing: latestTargetBearing)
        currentIntensity = intensity
        
        guard intensity > 0.04 else { return }
        
        let now = Date()
        let minimumDelay = TimeInterval(0.26 - Double(intensity) * 0.16)
        guard now.timeIntervalSince(lastPulseDate) >= minimumDelay else { return }
        lastPulseDate = now
        
        playBuzz(intensity: intensity)
    }
    
    private func handleTargetHold() {
        currentIntensity = 0
        
        if targetHoldStartDate == nil {
            targetHoldStartDate = Date()
            return
        }
        
        guard !isTargetConfirmed, let holdStart = targetHoldStartDate else { return }
        guard Date().timeIntervalSince(holdStart) >= 1 else { return }
        
        isTargetConfirmed = true
        playSuccessHaptic()
    }
    
    private func playBuzz(intensity: Float) {
        if let engine {
            do {
                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.36)
                let hapticIntensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)
                let event = CHHapticEvent(
                    eventType: .hapticContinuous,
                    parameters: [hapticIntensity, sharpness],
                    relativeTime: 0,
                    duration: 0.12 + TimeInterval(intensity) * 0.10
                )
                let pattern = try CHHapticPattern(events: [event], parameters: [])
                let player = try engine.makePlayer(with: pattern)
                try player.start(atTime: 0)
            } catch {
                fallbackGenerator.impactOccurred(intensity: CGFloat(intensity))
            }
        } else {
            fallbackGenerator.impactOccurred(intensity: CGFloat(intensity))
            fallbackGenerator.prepare()
        }
    }
    
    private func playSuccessHaptic() {
        successGenerator.notificationOccurred(.success)
        successGenerator.prepare()
        
        guard let engine else { return }
        
        do {
            let strong = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.65)
                ],
                relativeTime: 0
            )
            let soft = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.45),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.35)
                ],
                relativeTime: 0.12
            )
            let pattern = try CHHapticPattern(events: [strong, soft], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            successGenerator.notificationOccurred(.success)
        }
    }
    
    private static func intensity(heading: Double, targetBearing: Double) -> Float {
        let headingError = angularDifference(from: heading, to: targetBearing)
        guard headingError > 15 else { return 0 }
        
        let intensity = min(headingError - 15, 165) / 165
        return Float(max(0, min(1, intensity)))
    }
    
    private static func angularDifference(from firstAngle: Double, to secondAngle: Double) -> Double {
        let difference = abs((firstAngle - secondAngle + 540).truncatingRemainder(dividingBy: 360) - 180)
        return min(180, max(0, difference))
    }
}
