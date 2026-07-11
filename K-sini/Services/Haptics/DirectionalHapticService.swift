//
//  DirectionalHapticService.swift
//  K-sini
//
//  Created by Tiko Aqsa Alif Nugroho on 08/07/26.
//

import Foundation
import CoreHaptics

final class DirectionalHapticService {
    
    private var engine: CHHapticEngine?
    private var player: CHHapticAdvancedPatternPlayer?
    private var isPlaying = false
    var isEnabled = false
    var isTargetAligned = false
    var currentIntensity: Float = 0
    
    init() {
        prepareEngine()
    }
    
    private func prepareEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            return
        }
        do {
            engine = try CHHapticEngine()
            engine?.stoppedHandler = { reason in
                print("Haptic engine stopped: \(reason)")
            }
            engine?.resetHandler = { [weak self] in
                guard let self else { return }
                do {
                    try self.engine?.start()
                    self.player = nil
                    self.isPlaying = false
                } catch {
                    print("Failed to restart haptic engine: \(error)")
                }
            }
            try engine?.start()
        } catch {
            print(error)
        }
    }
    
    func start() {
        isEnabled = true
        do {
            try engine?.start()
        } catch {
            print("Failed to start haptic engine: \(error)")
        }
    }
    
    func stop() {
        isEnabled = false
        stopContinuousHaptic()
        engine?.stop(completionHandler: nil)
    }
    
    func update(
        heading: Double,
        targetBearing: Double
    ) {
        guard isEnabled else {
            return
        }

        var difference = targetBearing - heading
        
        while difference > 180 {
            difference -= 360
        }

        while difference < -180 {
            difference += 360
        }

        let absDifference = abs(difference)
        let intensity = intensity(from: absDifference)
        
        isTargetAligned = absDifference <= 15

        if isTargetAligned {
            if isPlaying {
                updateContinuousHaptic(intensity: 0)
            }
            return
        }

        if !isPlaying {
            startContinuousHaptic(intensity: intensity)
        } else {
            updateContinuousHaptic(intensity: intensity)
        }
    }

    private func intensity(from difference: Double) -> Float {

        let value = min(max((difference - 15) / 75, 0), 1)
        return Float(value)
    }
    private func startContinuousHaptic(intensity: Float) {

        guard let engine else { return }
        if isPlaying {
            updateContinuousHaptic(intensity: max(intensity, 0))
            return
        }

        let event = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(
                    parameterID: .hapticIntensity,
                    value: 1.0),
                CHHapticEventParameter(
                    parameterID: .hapticSharpness,
                    value: 1.0
                )
            ],
            relativeTime: 0,
            duration: 60
        )

        do {

            let pattern = try CHHapticPattern(
                events: [event],
                parameters: []
            )

            player = try engine.makeAdvancedPlayer(
                with: pattern
            )

            try player?.start(atTime: CHHapticTimeImmediate)

            isPlaying = true

        } catch {
            print(error)
        }
    }
    
    private func updateContinuousHaptic(intensity: Float) {

        guard let player else {
            return
        }

        let parameter = CHHapticDynamicParameter(
            parameterID: .hapticIntensityControl,
            value: intensity,
            relativeTime: 0
        )

        do {
            try player.sendParameters(
                [parameter],
                atTime: CHHapticTimeImmediate
            )
        } catch {
            print(error)
        }
    }
    
    private func stopContinuousHaptic() {
        guard isPlaying else {
            return
        }
        do {
            try player?.stop(
                atTime: CHHapticTimeImmediate
            )
        } catch {
            print(error)
        }

        player = nil
        isPlaying = false
    }
}
