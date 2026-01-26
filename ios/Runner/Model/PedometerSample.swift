//
//  PedometerSample.swift
//  Runner
//
//  Created by 김두원 on 1/20/26.
//

import Foundation
import HealthKit

struct PedometerSample {
    init?(from dict: [String: Any], formatter: ISO8601DateFormatter = ISO8601DateFormatter()) {
        guard let startStr = dict["start"] as? String,
              let endStr = dict["end"] as? String,
              let steps = dict["steps"] as? Double,
              let startDate = formatter.date(from: startStr),
              let endDate = formatter.date(from: endStr) else {
            return nil
        }
        
        self.start = startDate
        self.end = endDate
        self.steps = steps
        self.distance = dict["steps"] as? Double
    }
    
    let start: Date
    let end: Date
    let steps: Double
    let distance: Double?
    
    func toHKSamples() -> [HKQuantitySample] {
        var samples: [HKQuantitySample] = []

        // step Sample
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let stepSample = HKQuantitySample(
            type: stepType,
            quantity: HKQuantity(unit: .count(), doubleValue: steps),
            start: start,
            end: end
        )
        samples.append(stepSample)

        if let distance = distance, distance > 0 {
            // distance Sample
            let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
            let distanceSample = HKQuantitySample(
                type: distanceType,
                quantity: HKQuantity(unit: .meter(), doubleValue: distance),
                start: start,
                end: end
            )
            samples.append(distanceSample)

            // runngingSpeed Sample
            let duration = end.timeIntervalSince(start) // seconds
            if duration > 0 {
                let runningSpeed = distance / duration // m/s
                let speedType = HKQuantityType.quantityType(forIdentifier: .runningSpeed)!
                let speedUnit = HKUnit.meter().unitDivided(by: .second())

                let speedSample = HKQuantitySample(
                    type: speedType,
                    quantity: HKQuantity(unit: speedUnit, doubleValue: runningSpeed),
                    start: start,
                    end: end
                )
                samples.append(speedSample)
            }
        }

        return samples
    }

}
