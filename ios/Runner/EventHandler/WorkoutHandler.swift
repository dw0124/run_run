//
//  WorkoutHandler.swift
//  Runner
//
//  Created by 김두원 on 1/7/26.
//

import Foundation
import HealthKit
import CoreLocation

class WorkoutHandler {
    private let healthStore = HKHealthStore()
    
    private var workoutBuilder: HKWorkoutBuilder? = nil
    private var workoutRouteBuilder: HKWorkoutRouteBuilder? = nil
    
    private let workoutConfiguration: HKWorkoutConfiguration = {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .running
        configuration.locationType = .outdoor
        return configuration
    }()
    
    private let device: HKDevice? = .local()
    
    init() {
        // HKWorkoutBuilder 생성
        let builder = HKWorkoutBuilder(
            healthStore: healthStore,
            configuration: workoutConfiguration,
            device: device
        )
        self.workoutBuilder = builder

        // HKWorkoutRouteBuilder 생성
        self.workoutRouteBuilder = builder.seriesBuilder(for: HKSeriesType.workoutRoute()) as? HKWorkoutRouteBuilder
    }
    
    // HealthKit 권한 요청
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
    
    
    /// HKWorkoutBuilder 데이터 수집 시작
    func startWorkout(startDate: Date) async {
        do {
            try await workoutBuilder?.beginCollection(at: startDate)
        } catch {
            print("Start Workout error:", error.localizedDescription)
        }
        
    }
    
    /// HKWorkoutBuilder에 [HKSample] 추가
    func add(samples: [HKSample]) {
        guard let builder = workoutBuilder else { return }
        
        builder.add(samples) { success, error in
            if let error = error {
                print("Add sample error:", error.localizedDescription)
            }
        }
    }
    
    /// HKWorkoutRouteBuilder에 [CLLocation] 추가
    func addRoute(routes: [CLLocation]) {
        guard let routeBuilder = workoutRouteBuilder else { return }
        
        routeBuilder.insertRouteData(routes) { success, error in
            if let error = error {
                print("Add route error:", error.localizedDescription)
            }
        }
    }
    
    func finishWorkout() async {
        guard let builder = workoutBuilder, let routeBuilder = workoutRouteBuilder else { return }
        
        let endDate = Date()

        do {
            try await builder.endCollection(at: endDate)
            guard let workout = try await builder.finishWorkout() else { return }
            try await routeBuilder.finishRoute(with: workout, metadata: nil)
        } catch {
            print("Finish workout error: \(error.localizedDescription)")
        }
    }
}
