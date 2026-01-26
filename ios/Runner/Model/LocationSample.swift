//
//  LocationSample.swift
//  Runner
//
//  Created by 김두원 on 1/20/26.
//

import Foundation
import CoreLocation

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

    init?(from dict: [String: Any]) {
        guard
            let latitude = dict["latitude"] as? Double,
            let longitude = dict["longitude"] as? Double,
            let timestampMs = dict["timestamp"] as? Int,
            let accuracy = dict["accuracy"] as? Double,
            let altitude = dict["altitude"] as? Double,
            let altitudeAccuracy = dict["altitude_accuracy"] as? Double,
            let heading = dict["heading"] as? Double,
            let headingAccuracy = dict["heading_accuracy"] as? Double,
            let speed = dict["speed"] as? Double,
            let speedAccuracy = dict["speed_accuracy"] as? Double
        else {
            return nil
        }

        self.latitude = latitude
        self.longitude = longitude
        self.timestamp = Date(timeIntervalSince1970: TimeInterval(timestampMs) / 1000.0)

        self.accuracy = accuracy
        self.altitude = altitude
        self.altitudeAccuracy = altitudeAccuracy

        self.heading = heading
        self.headingAccuracy = headingAccuracy

        self.floor = dict["floor"] as? Int
        self.speed = speed
        self.speedAccuracy = speedAccuracy
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
}

//
//Map<String, dynamic> toJson() => {
//      'longitude': longitude,
//      'latitude': latitude,
//      'timestamp': timestamp.millisecondsSinceEpoch,
//      'accuracy': accuracy,
//      'altitude': altitude,
//      'altitude_accuracy': altitudeAccuracy,
//      'floor': floor,
//      'heading': heading,
//      'heading_accuracy': headingAccuracy,
//      'speed': speed,
//      'speed_accuracy': speedAccuracy,
//      'is_mocked': isMocked,
//    };

//final double latitude;
//final double longitude;
//final DateTime timestamp;
//final double altitude;
//final double altitudeAccuracy;
//final double accuracy;
//final double heading;
//final double headingAccuracy;
//final int? floor;
//final double speed;
//final double speedAccuracy;
//final bool isMocked;
