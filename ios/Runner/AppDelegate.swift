import Flutter
import CoreLocation
import HealthKit
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller: FlutterViewController =
            window?.rootViewController as! FlutterViewController

        //MARK: Pedometer Event Channel
        let pedometerStreamHandler = PedometerStreamHandler()
        let eventChannel = FlutterEventChannel(
            name: "com.example.runRun/pedometer_channel",
            binaryMessenger: controller.binaryMessenger
        )
        eventChannel.setStreamHandler(pedometerStreamHandler)

        //MARK: Workout Method Channel
        let workoutHandler = WorkoutHandler()

        let testChannel = FlutterMethodChannel(
            name: "com.example.runRun/workout_channel",
            binaryMessenger: controller.binaryMessenger)

        testChannel.setMethodCallHandler {
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            
            switch call.method {
            case "requestAuthorization":
                workoutHandler.requestAuthorization { bool in
                    print("Request Authorization Result: \(bool)")
                    result(true)
                }
            case "start":
                Task {
                    await workoutHandler.startWorkout(startDate: Date())
                    result(true)
                }
            case "pause":
                Task {
                    await workoutHandler.pauseWorkout()
                    result(true)
                }
            case "finish":
                Task {
                    await workoutHandler.finishWorkout()
                    result(true)
                }
                
            case "workout":
                
                guard let args = call.arguments as? [String: Any],
                      let locations = args["locationSamples"] as? [[String: Any]],
                      let pedometers = args["pedometerSamples"] as? [[String: Any]]
                else {
                    result(FlutterError(code: "WORKOUT - INVALID_ARGS", message: nil, details: nil))
                    return
                }
                
                let pedometerSamples = pedometers.compactMap {
                    PedometerSample(from: $0)
                }
                
                let stepCountQuantitySamples = pedometerSamples.flatMap {
                    $0.toHKSamples()
                }
                
                let locationSamples = locations.compactMap {
                    LocationSample(from: $0)
                }
                
                var distanceSamples: [HKQuantitySample] = []
                var clLocations: [CLLocation] = []

                for sample in locationSamples {
                    if let distanceSample = sample.toDistanceQuantitySample() {
                        distanceSamples.append(distanceSample)
                    }
                    
                    let location = sample.toCLLocation()
                    clLocations.append(location)
                }
        
                let quantitySamples = stepCountQuantitySamples + distanceSamples
                
                if !clLocations.isEmpty {
                    workoutHandler.addRoute(routes: clLocations)
                }
                
                if !quantitySamples.isEmpty {
                    workoutHandler.add(samples: quantitySamples)
                }
                
                result(true)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
            
        // MARK: Workout History Method Channel (Read-only)
        let workoutHistoryChannel = FlutterMethodChannel(
            name: "com.example.runRun/workout_history_channel",
            binaryMessenger: controller.binaryMessenger)

        workoutHistoryChannel.setMethodCallHandler {
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in

            switch call.method {
            case "fetchWorkoutList":
                guard let args = call.arguments as? [String: Any],
                      let startDateStr = args["startDate"] as? String,
                      let endDateStr = args["endDate"] as? String
                else {
                    result(FlutterError(code: "INVALID_ARGS", message: "startDate, endDate 필요", details: nil))
                    return
                }
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                guard let startDate = formatter.date(from: startDateStr),
                      let endDate = formatter.date(from: endDateStr)
                else {
                    result(FlutterError(code: "INVALID_DATE", message: "ISO8601 형식이어야 합니다", details: nil))
                    return
                }
                Task {
                    do {
                        let workouts = try await workoutHandler.fetchWorkoutList(startDate: startDate, endDate: endDate)
                        let maps = workouts.map { WorkoutHistory(from: $0).toMap() }
                        result(maps)
                    } catch {
                        result(FlutterError(code: "FETCH_FAILED", message: error.localizedDescription, details: nil))
                    }
                }

            case "fetchWorkoutDetails":
                guard let args = call.arguments as? [String: Any],
                      let workoutIdStr = args["workoutId"] as? String,
                      let workoutId = UUID(uuidString: workoutIdStr)
                else {
                    result(FlutterError(code: "INVALID_ARGS", message: "workoutId 필요", details: nil))
                    return
                }
                Task {
                    do {
                        let details = try await workoutHandler.fetchWorkoutDetails(workoutId: workoutId)
                        let map = WorkoutDetailHistory(
                            stepSamples: details.stepSamples,
                            distanceSamples: details.distanceSamples,
                            speedSamples: details.speedSamples
                        ).toMap()
                        result(map)
                    } catch {
                        result(FlutterError(code: "FETCH_FAILED", message: error.localizedDescription, details: nil))
                    }
                }

            default:
                result(FlutterMethodNotImplemented)
            }
        }

        GeneratedPluginRegistrant.register(with: self)
        return super.application(
            application, didFinishLaunchingWithOptions: launchOptions)
    }
}
