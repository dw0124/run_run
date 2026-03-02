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
        guard let startDateStr = dict["startDate"] as? String,
              let endDateStr = dict["endDate"] as? String,
              let stepDelta = dict["stepDelta"] as? Int,
              let distanceDelta = dict["distanceDelta"] as? Double
        else {
            print("PedometerSample Parse Error")
            return nil
        }
        
        let currentPace = dict["currentPace"] as? Double
        let currentCadence = dict["currentCadence"] as? Double
        
        let endDate = formatter.date(from: endDateStr)!
        let startDate = formatter.date(from: startDateStr)!
        
        self.start = startDate
        self.end = endDate
        self.steps = stepDelta
        self.distance = distanceDelta
        self.currentPace = currentPace
        self.currentCadence = currentCadence
    }
    
    let start: Date
    let end: Date
    let steps: Int
    let distance: Double?
    let currentPace: Double?
    let currentCadence: Double?
    
    func toHKSamples() -> [HKQuantitySample] {
        var samples: [HKQuantitySample] = []

        // step Sample
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let stepSample = HKQuantitySample(
            type: stepType,
            quantity: HKQuantity(unit: .count(), doubleValue: Double(steps)),
            start: start,
            end: end
        )
        samples.append(stepSample)
        
        /* ---- distanceWalkingRunning, runningSpeed 샘플은 LocationSample에서 처리하도록 수정 ----
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
        ---- distanceWalkingRunning, runningSpeed 샘플은 LocationSample에서 처리하도록 수정 ---- */

        return samples
    }

}
