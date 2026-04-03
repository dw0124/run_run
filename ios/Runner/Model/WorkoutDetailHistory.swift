import HealthKit

struct WorkoutDetailHistory {
    let stepCountSamples: [[String: Any]]
    let distanceSamples: [[String: Any]]
    let runningSpeedSamples: [[String: Any]]

    init(
        stepSamples: [HKQuantitySample],
        distanceSamples: [HKQuantitySample],
        speedSamples: [HKQuantitySample]
    ) {
        self.stepCountSamples = stepSamples.map {
            WorkoutDetailHistory.sampleToMap($0, unit: .count())
        }
        self.distanceSamples = distanceSamples.map {
            WorkoutDetailHistory.sampleToMap($0, unit: .meter())
        }
        self.runningSpeedSamples = speedSamples.map {
            WorkoutDetailHistory.sampleToMap($0, unit: HKUnit.meter().unitDivided(by: .second()))
        }
    }

    func toMap() -> [String: Any] {
        
//        [
//            "stepCountSamples": [[String: Any]]
//        ]
        
        
        return [
            "stepCountSamples": stepCountSamples,
            "distanceSamples": distanceSamples,
            "runningSpeedSamples": runningSpeedSamples,
        ]
    }

    private static func sampleToMap(_ sample: HKQuantitySample, unit: HKUnit) -> [String: Any] {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return [
            "startDate": formatter.string(from: sample.startDate),
            "endDate": formatter.string(from: sample.endDate),
            "value": sample.quantity.doubleValue(for: unit),
        ]
    }
}
