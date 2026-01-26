//
//  PedometerEventHandler.swift
//  Runner
//
//  Created by 김두원 on 12/19/25.
//

import Foundation
import CoreMotion
import Flutter

class PedometerStreamHandler: NSObject, FlutterStreamHandler {
    private let pedometer = CMPedometer()
    private var eventSink: FlutterEventSink?

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        
        guard CMPedometer.isStepCountingAvailable() else {
            return FlutterError(
                code: "PEDOMETER_UNAVAILABLE",
                message: "걸음수 측정 미지원 기기입니다.",
                details: nil
            )
        }

        self.eventSink = events
        let startDate = Date()

        // CMPedometer 스트림 시작
        pedometer.startUpdates(from: startDate) { [weak self] data, error in
            guard let self = self, let data = data else { return }

            do {
                let dto = PedometerDataDTO(from: data)
                let json = try dto.toJson()

                DispatchQueue.main.async {
                    self.eventSink?(json)
                }
            } catch {
                DispatchQueue.main.async {
                    self.eventSink?(
                        FlutterError(
                            code: "JSON_ENCODING_ERROR",
                            message: error.localizedDescription,
                            details: nil
                        )
                    )
                }
            }
        }
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        pedometer.stopUpdates()
        eventSink = nil
        return nil
    }
}
