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
    
    init() {}
    
    // HealthKit 권한 요청
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        // 워크아웃을 읽고 쓰기 위해 필요한 데이터 타입
        let readTypes: Set<HKObjectType> = [
            .workoutType(),
            HKSeriesType.workoutRoute(),    // HKWorkoutRoute 관련 권한
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!, // 거리 기록 권한
            //HKObjectType.quantityType(forIdentifier: .runningSpeed)!, // Running Speed - 현재 페이스 대용 => 확인해본 결과 대부분 distanceWalkingRunning를 사용
            HKObjectType.quantityType(forIdentifier: .stepCount)!, // 걸음 수 기록 권한
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)! // 칼로리 기록 권한
        ]
        
        let writeTypes: Set<HKSampleType> = [
            HKObjectType.quantityType(forIdentifier: .runningSpeed)!,
            .workoutType(), // HKWorkout 권한
            HKSeriesType.workoutRoute(),    // HKWorkoutRoute 관련 권한
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!, // 거리 기록 권한
            //HKObjectType.quantityType(forIdentifier: .runningSpeed)!, // Running Speed - 현재 페이스 대용
            HKObjectType.quantityType(forIdentifier: .stepCount)!, // 걸음 수 기록 권한
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)! // 칼로리 기록 권한
        ]
        
        healthStore.requestAuthorization(toShare: writeTypes, read: readTypes) { success, error in
            completion(success)
        }
    }
    
    
    /// HKWorkoutBuilder 데이터 수집 시작
    func startWorkout(startDate: Date) async {
        
        // 현재 HKWorkoutBuilder가 존재(운동이 진행 or 정지 상태)하면 resumeWorkout 실행
        if workoutBuilder?.startDate != nil {
            await resumeWorkout()
            return
        }
        
        // HKWorkoutBuilder 생성
        let builder = HKWorkoutBuilder(
            healthStore: healthStore,
            configuration: workoutConfiguration,
            device: device
        )
        self.workoutBuilder = builder

        // HKWorkoutRouteBuilder 생성
        self.workoutRouteBuilder = builder.seriesBuilder(for: HKSeriesType.workoutRoute()) as? HKWorkoutRouteBuilder
        
        do {
            try await workoutBuilder?.beginCollection(at: startDate)
        } catch {
            print("Start Workout error:", error.localizedDescription)
        }
        
    }
    
    func resumeWorkout() async {
        let resumeEvent = HKWorkoutEvent(type: .resume, dateInterval: DateInterval(start: Date(), duration: 0), metadata: nil)
        
        do {
            try await workoutBuilder?.addWorkoutEvents([resumeEvent])
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func pauseWorkout() async {
        let pauseEvent = HKWorkoutEvent(type: .pause, dateInterval: DateInterval(start: Date(), duration: 0), metadata: nil)
        
        do {
            try await workoutBuilder?.addWorkoutEvents([pauseEvent])
        } catch {
            print(error.localizedDescription)
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
            // HKWorkoutRouteBuilder는 HKWorkoutBuilder를 정리할 때 알아서 정리됨
            
            // workoutBuilder, workoutRouteBuilder를 nil로 초기화
            resetWorkoutBuilder()
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
        guard startDate < endDate else {
            throw WorkoutQueryError.invalidDateRange
        }

        let workoutPredicate = HKQuery.predicateForWorkouts(with: .running)
        let datePredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [workoutPredicate, datePredicate])

        let descriptor = HKSampleQueryDescriptor(
            predicates: [.sample(type: .workoutType(), predicate: compoundPredicate)],
            sortDescriptors: [SortDescriptor(\.startDate, order: .reverse)]
        )

        let samples = try await descriptor.result(for: healthStore)

        guard let workouts = samples as? [HKWorkout] else {
            throw WorkoutQueryError.castFailed
        }

        return workouts
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

        let samples = try await descriptor.result(for: healthStore)

        guard let first = samples.first else { return nil }

        guard let workout = first as? HKWorkout else {
            throw WorkoutQueryError.castFailed
        }

        return workout
    }
    
    
    func fetchWorkoutDetails(workoutId: UUID) async throws -> (
        stepSamples: [HKQuantitySample],
        distanceSamples: [HKQuantitySample],
        speedSamples: [HKQuantitySample]
    ) {
        // UUID로 HKWorkout 객체 찾기
        guard let workout = try await findWorkout(by: workoutId) else {
            throw WorkoutQueryError.notFound
        }

        // 상세 샘플 쿼리 - stepCount, distanceWalkingRunning, runningSpeed
        let predicate = HKQuery.predicateForObjects(from: workout)
        let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let distanceWalkingRunningType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let runningSpeedType = HKQuantityType.quantityType(forIdentifier: .runningSpeed)!

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

        return (
            stepSamples: try await stepResults,
            distanceSamples: try await distanceResults,
            speedSamples: try await speedResults
        )
    }
    
    /// workoutBuilder, workoutRouteBuilder를 nil로 초기화
    func resetWorkoutBuilder() {
        workoutBuilder = nil
        workoutRouteBuilder = nil
    }
}

enum WorkoutQueryError: Error {
    case notFound
    case invalidDateRange
    case castFailed
}
