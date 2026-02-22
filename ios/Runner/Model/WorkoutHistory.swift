//
//  WorkoutHitsory.swift
//  Runner
//
//  Created by 김두원 on 2/9/26.
//

import Foundation

struct WorkoutHistory: Codable {
    let id: UUID           // UUID
    let startDate: Date
    let endDate: Date
    let duration: TimeInterval
    
    var totalDistance: Double?      // 미터 단위
    var averageRunningSpeed: Double?
    var totalEnergyBurned: Double?  // 칼로리
    
    // 상세 조회에서 사용될 Optional 배열
    var runningSpeedList: [Date: Double]?   // runningSpeed - 페이스 차트용
    var stepCountList: [Date: Double]?      // stepCount - 케이던스 차트용
    
    mutating func copyWith(
        totalDistance: Double? = nil,
        averageRunningSpeed: Double? = nil,
        totalEnergyBurned: Double? = nil,
        runningSpeedList: [Date: Double]? = nil,
        stepCountList: [Date: Double]? = nil
    ) {
        self.totalDistance = totalDistance ?? self.totalDistance
        self.averageRunningSpeed = averageRunningSpeed ?? self.averageRunningSpeed
        self.totalEnergyBurned = totalEnergyBurned ?? self.totalEnergyBurned
        self.runningSpeedList = runningSpeedList ?? self.runningSpeedList
        self.stepCountList = stepCountList ?? self.stepCountList
    }
}
