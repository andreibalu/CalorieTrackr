//
//  WatchConnectivityManager.swift
//  CalorieTrackr
//
//  Created by Andrei Tatucu on 09.06.2023.
//

import Foundation
import WatchConnectivity

struct NotificationMessage: Identifiable {
    let id = UUID()
    let text: String
}

final class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()
    @Published var notificationMessage: NotificationMessage? = nil

    private override init() {
        super.init()

        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    private let kMessageKey = "message"

    func send(_ message: String) {
        guard WCSession.default.activationState == .activated else {
            return
        }
        #if os(iOS)
        guard WCSession.default.isWatchAppInstalled else {
            return
        }
        #else
        guard WCSession.default.isCompanionAppInstalled else {
            return
        }
        #endif

        WCSession.default.sendMessage([kMessageKey: message], replyHandler: nil) { error in
            print("Cannot send message: \(String(describing: error))")
        }
    }
    
    var burnedCalories = 0;
    var consumedCalories = 0;
    var proteins = 0;
    var carbs = 0;
    var fats = 0;
}


func createJson(from jsonObject: [String: Any]) -> String? {
    do {
        // Convert the dictionary to JSON data
        let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
        
        // Convert the JSON data to a string
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
    } catch {
        print("Error: \(error)")
    }
    return nil
    }

extension WatchConnectivityManager: WCSessionDelegate {
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        print(message)
        if let notificationText = message[kMessageKey] as? String {
            DispatchQueue.main.async { [weak self] in
                self?.notificationMessage = NotificationMessage(text: notificationText)
            }
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    #endif
}
