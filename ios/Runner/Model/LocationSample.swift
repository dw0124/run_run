//
//  LocationSample.swift
//  Runner
//
//  Created by 김두원 on 1/20/26.
//

import Foundation
import CoreLocation
import HealthKit

struct LocationSample {
    let latitude: Double
    let longitude: Double
    let timestamp: Date

    let altitude: Double
    let altitudeAccuracy: Double
    let accuracy: Double

    let heading: Double
    let headingAccuracy: Double

    let floor: Int?
    let speed: Double
    let speedAccuracy: Double
    
    let previousTimestamp: Date?
    let distanceDelta: Double?

    init?(from dict: [String: Any]) {
        let previousTimestamp = dict["previousTimestamp"] as? Double
        let distanceDelta = dict["distanceDelta"] as? Double
        
        guard
            let position = dict["position"] as? [String: Any],
            let latitude = position["latitude"] as? Double,
            let longitude = position["longitude"] as? Double,
            let timestampMs = position["timestamp"] as? Double,
            let accuracy = position["accuracy"] as? Double,
            let altitude = position["altitude"] as? Double,
            let altitudeAccuracy = position["altitude_accuracy"] as? Double,
            let heading = position["heading"] as? Double,
            let headingAccuracy = position["heading_accuracy"] as? Double,
            let speed = position["speed"] as? Double,
            let speedAccuracy = position["speed_accuracy"] as? Double
        else { return nil }
        
        let floor = position["floor"] as? Int
        
        self.latitude = latitude
        self.longitude = longitude
        self.timestamp = Date(timeIntervalSince1970: TimeInterval(timestampMs) / 1000.0)
        
        self.accuracy = accuracy
        self.altitude = altitude
        self.altitudeAccuracy = altitudeAccuracy
        
        self.heading = heading
        self.headingAccuracy = headingAccuracy
        
        self.floor = floor
        self.speed = speed
        self.speedAccuracy = speedAccuracy
        
        if let prevTimestampMs = previousTimestamp {
            self.previousTimestamp = Date(timeIntervalSince1970: prevTimestampMs / 1000.0)
        } else {
            self.previousTimestamp = nil // 첫 번째 좌표일 경우
        }
        
        self.distanceDelta = distanceDelta
    }

    /// HealthKit Route용 CLLocation으로 변환
    func toCLLocation() -> CLLocation {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

        return CLLocation(
            coordinate: coordinate,
            altitude: altitude,
            horizontalAccuracy: accuracy,
            verticalAccuracy: altitudeAccuracy,
            course: heading,
            courseAccuracy: headingAccuracy,
            speed: speed,
            speedAccuracy: speedAccuracy,
            timestamp: timestamp
        )
    }
    
    func toDistanceQuantitySample() -> HKQuantitySample? {
        guard let distanceDelta = distanceDelta else {
            print("Distance 샘플 생성 오류 - distanceDelta")
            return nil
        }
        
        guard let previousTimestamp = previousTimestamp else {
            print("Distance 샘플 생성 오류 - previousTimestamp")
            return nil
        }
        
        let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let distanceSample = HKQuantitySample(
            type: distanceType,
            quantity: HKQuantity(unit: .meter(), doubleValue: distanceDelta),
            start: previousTimestamp,
            end: timestamp
        )
        
        return distanceSample
    }
}