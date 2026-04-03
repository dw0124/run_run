import HealthKit

struct WorkoutHistory {
    let id: String
    let startDate: String
    let endDate: String
    let duration: Double
    let totalDistance: Double
    let averageRunningSpeed: Double
    let totalEnergyBurned: Double

    init(from workout: HKWorkout) {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let stats = workout.allStatistics

        let totalDistance = stats[HKQuantityType(.distanceWalkingRunning)]?
            .sumQuantity()?.doubleValue(for: .meter()) ?? 0.0

        let averageRunningSpeed = stats[HKQuantityType(.runningSpeed)]?
            .averageQuantity()?.doubleValue(for: HKUnit.meter().unitDivided(by: .second())) ?? 0.0

        let totalEnergyBurned = stats[HKQuantityType(.activeEnergyBurned)]?
            .sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0.0

        self.id = workout.uuid.uuidString
        self.startDate = formatter.string(from: workout.startDate)
        self.endDate = formatter.string(from: workout.endDate)
        self.duration = workout.duration
        self.totalDistance = totalDistance
        self.averageRunningSpeed = averageRunningSpeed
        self.totalEnergyBurned = totalEnergyBurned
    }

    func toMap() -> [String: Any] {
        return [
            "id": id,
            "startDate": startDate,
            "endDate": endDate,
            "duration": duration,
            "totalDistance": totalDistance,
            "averageRunningSpeed": averageRunningSpeed,
            "totalEnergyBurned": totalEnergyBurned,
        ]
    }
}
