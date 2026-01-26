//
//  WorkoutManager.swift
//  Runner
//
//  Created by 김두원 on 12/15/25.
//

import Foundation
import HealthKit

import HealthKit

class HealthKitManager {
    
    static let shared = HealthKitManager()
    private let healthStore = HKHealthStore()

    private init() {}

    func getHealthStore() -> HKHealthStore {
        return healthStore
    }
    
    // MARK: - 권한 요청
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        // 워크아웃을 읽고 쓰기 위해 필요한 데이터 타입
        let readTypes: Set<HKObjectType> = [
            .workoutType(),
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!, // 거리 기록 권한
            HKObjectType.quantityType(forIdentifier: .stepCount)!, // 걸음 수 기록 권한
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)! // 칼로리 기록 권한
        ]
        
        let writeTypes: Set<HKSampleType> = [
            .workoutType(), // HKWorkout 권한
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!, // 거리 기록 권한
            HKObjectType.quantityType(forIdentifier: .stepCount)!, // 걸음 수 기록 권한
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)! // 칼로리 기록 권한
        ]
        
        healthStore.requestAuthorization(toShare: writeTypes, read: readTypes) { success, error in
            
            completion(success)
        }
    }
}

import HealthKit

final class WorkoutManager {

    private let healthStore: HKHealthStore

    private var workoutBuilder: HKWorkoutBuilder?
    private var startDate: Date?

    init() {
        self.healthStore = HealthKitManager.shared.getHealthStore()
    }

    // MARK: - Workout Start

    func startWorkout(completion: @escaping (Result<Void, Error>) -> Void) {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .running
        configuration.locationType = .outdoor

        let startDate = Date()
        self.startDate = startDate

        let builder = HKWorkoutBuilder(
            healthStore: healthStore,
            configuration: configuration,
            device: .local()
        )

        self.workoutBuilder = builder

        builder.beginCollection(withStart: startDate) { success, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    // MARK: - Add Samples

    /// HKSample들을 워크아웃에 추가
    func add(samples: [HKSample], completion: ((Result<Void, Error>) -> Void)? = nil) {
        guard let builder = workoutBuilder else {
            completion?(.failure(WorkoutError.notStarted))
            return
        }

        builder.add(samples) { success, error in
            if let error = error {
                completion?(.failure(error))
            } else {
                completion?(.success(()))
            }
        }
    }

    // MARK: - Add Metadata

    /// 메타데이터(페이스, 케이던스 등) 워크아웃에 추가
    func addMetadata(_ metadata: [String: Any],
                     completion: ((Result<Void, Error>) -> Void)? = nil) {
        guard let builder = workoutBuilder else {
            completion?(.failure(WorkoutError.notStarted))
            return
        }

        builder.addMetadata(metadata) { success, error in
            if let error = error {
                completion?(.failure(error))
            } else {
                completion?(.success(()))
            }
        }
    }

    // MARK: - End & Save Workout

    func endAndSaveWorkout(completion: @escaping (Result<HKWorkout, Error>) -> Void) {
        guard let builder = workoutBuilder,
              let startDate = startDate else {
            completion(.failure(WorkoutError.notStarted))
            return
        }

        let endDate = Date()

        builder.endCollection(withEnd: endDate) { [weak self] success, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            builder.finishWorkout { workout, error in
                self?.workoutBuilder = nil
                self?.startDate = nil

                if let workout = workout {
                    completion(.success(workout))
                } else if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.failure(WorkoutError.unknown))
                }
            }
        }
    }
}

// MARK: - Errors

enum WorkoutError: Error {
    case notStarted
    case unknown
}
