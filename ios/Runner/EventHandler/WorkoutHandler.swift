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
    
    // MARK: - 운동 데이터 요청 쿼리
    
    /// 러닝 관련 HKWorkout 리스트 요청 쿼리
    func fetchWorkoutList(startDate: Date, endDate: Date, completion: @escaping ([HKWorkout]?) -> Void) {
        
        // 1. 러닝 타입 및 시간 범위 조건(Predicate) 설정
        let workoutPredicate = HKQuery.predicateForWorkouts(with: .running)
        let datePredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [workoutPredicate, datePredicate])
        
        // 2. 최신순 정렬
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        // 3. 쿼리 생성
        let query = HKSampleQuery(
            sampleType: .workoutType(),
            predicate: compoundPredicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]
        ) { (query, samples, error) in
            guard let workouts = samples as? [HKWorkout], error == nil else {
                completion(nil)
                return
            }
            completion(workouts)
        }
        
        healthStore.execute(query)
    }
    
    func fetchWorkoutList(startDate: Date, endDate: Date) async throws -> [HKWorkout] {
        let workoutPredicate = HKQuery.predicateForWorkouts(with: .running)
        let datePredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [workoutPredicate, datePredicate])
        
        // Descriptor 생성
        let descriptor = HKSampleQueryDescriptor(
            predicates: [.sample(type: .workoutType(), predicate: compoundPredicate)],
            sortDescriptors: [SortDescriptor(\.startDate, order: .reverse)]
        )
        
        // 실행 및 결과 반환
        let samples = try await descriptor.result(for: healthStore)

        return samples as? [HKWorkout] ?? []
    }
    
    /// WorkoutHistory.id(HKWorkout의 UUID)를 통해 HKWorkout 검색
    /// fetchWorkoutDetails(workoutId:) 내부에서 호출
    func findWorkout(by uuid: UUID) async throws -> HKWorkout? {
        let predicate = HKQuery.predicateForObject(with: uuid)
        let descriptor = HKSampleQueryDescriptor(
            predicates: [.sample(type: .workoutType(), predicate: predicate)],
            sortDescriptors: [SortDescriptor(\.startDate)],
            limit: 1
        )
        
        return try await descriptor.result(for: healthStore).first as? HKWorkout
    }
    
    
    func fetchWorkoutDetails(workoutId: UUID) async {
        do {
            // UUID로 HKWorkout 객체 찾기
            guard let workout = try await findWorkout(by: workoutId) else {
                print("해당 UUID의 운동 기록을 찾을 수 없습니다.")
                return
            }

            // 상세 샘플 쿼리 - stepoCount, runningSpeed
            let predicate = HKQuery.predicateForObjects(from: workout)
            let runningSpeedType = HKQuantityType.quantityType(forIdentifier: .runningSpeed)!
            let distanceWalkingRunningType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
            let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
            
            let stepDescriptor = HKSampleQueryDescriptor(
                predicates: [.quantitySample(type: stepCountType, predicate: predicate)],
                sortDescriptors: [SortDescriptor(\.startDate)]
            )
            
            let distanceDescriptor = HKSampleQueryDescriptor(
                predicates: [.quantitySample(type: distanceWalkingRunningType, predicate: predicate)],
                sortDescriptors: [SortDescriptor(\.startDate)]
            )

            let speedDescriptor = HKSampleQueryDescriptor(
                predicates: [.quantitySample(type: runningSpeedType, predicate: predicate)],
                sortDescriptors: [SortDescriptor(\.startDate)]
            )

            // 쿼리 실행
            async let stepResults = stepDescriptor.result(for: healthStore)
            async let distanceResults = distanceDescriptor.result(for: healthStore)
            async let speedResults = speedDescriptor.result(for: healthStore)
            
            let stepSamples = try await stepResults
            let distanceSamples = try await distanceResults
            let speedSamples = try await speedResults
            
            print("조회 성공 - 걸음수:\(stepSamples.count)개, 거리:\(distanceSamples.count)개, 속도:\(speedSamples.count)개")
        } catch {
            print("WorkoutDetail Query Failed - \(error.localizedDescription)")
        }
    }
    
    /// workoutBuilder, workoutRouteBuilder를 nil로 초기화
    func resetWorkoutBuilder() {
        workoutBuilder = nil
        workoutRouteBuilder = nil
    }
}
