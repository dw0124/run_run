import Flutter
import CoreLocation
import HealthKit
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication
            .LaunchOptionsKey: Any]?
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
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void
            in

            switch call.method {
            case "requestAuthorization":
                workoutHandler.requestAuthorization { bool in
                    print("Request Authorization Result: \(bool)")
                    result(true)
                }
            case "start":
                print("🚀 [iOS] Workout Session Started")
                Task {
                    await workoutHandler.startWorkout(startDate: Date())
                }
                result(true)
            case "stop":
                print("🏁 [iOS] Workout Session Stopped")
                Task {
                    await workoutHandler.finishWorkout()
                }
                result(true)

            case "workout":

                guard let args = call.arguments as? [String: Any],
                    let locations = args["locationSamples"] as? [[String: Any]],
                    let pedometers = args["pedometerSamples"] as? [[String: Any]]
                else {
                    result(FlutterError(code: "WORKOUT - INVALID_ARGS", message: nil, details: nil))
                    return
                }
 
                let quantitySamples: [HKQuantitySample] = pedometers
                    .compactMap { PedometerSample(from: $0) }
                    .flatMap { $0.toHKSamples() }

                let clLocations: [CLLocation] = locations
                    .compactMap { LocationSample(from: $0)?.toCLLocation() }

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

        GeneratedPluginRegistrant.register(with: self)
        return super.application(
            application, didFinishLaunchingWithOptions: launchOptions)
    }
}
