//
//  PedometerDataDTO.swift
//  Runner
//
//  Created by 김두원 on 12/17/25.
//

import Foundation
import CoreMotion

struct PedometerDataDTO: Codable {

    let startDate: String
    let endDate: String

    let numberOfSteps: Double
    let distance: Double?

    let floorsAscended: Double?
    let floorsDescended: Double?

    let currentPace: Double?
    let currentCadence: Double?
    let averageActivePace: Double?

    // MARK: - Init
    init(from data: CMPedometerData) {
        let formatter = ISO8601DateFormatter()

        self.startDate = formatter.string(from: data.startDate)
        self.endDate = formatter.string(from: data.endDate)

        self.numberOfSteps = data.numberOfSteps.doubleValue
        self.distance = data.distance?.doubleValue

        self.floorsAscended = data.floorsAscended?.doubleValue
        self.floorsDescended = data.floorsDescended?.doubleValue

        self.currentPace = data.currentPace?.doubleValue
        self.currentCadence = data.currentCadence?.doubleValue
        self.averageActivePace = data.averageActivePace?.doubleValue
    }
    
    // MARK: - Encode
    func toJson() throws -> String? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let jsonData = try encoder.encode(self)
        return String(data: jsonData, encoding: .utf8)
    }
}
