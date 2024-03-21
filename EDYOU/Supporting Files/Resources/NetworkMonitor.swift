//
//  NetworkMonitor.swift
//  EDYOU
//
//  Created by amjad on 23/09/2022.
//

import Network
import Foundation

class NetworkMonitor {
    static let shared = NetworkMonitor()

    let monitor = NWPathMonitor()
    private var status: NWPath.Status = .requiresConnection
    var isReachable: Bool { status == .satisfied }
    var isReachableOnCellular: Bool = true
    @Published var isInternetAvailable: Bool = false
    @Published var isNetworkAvailable:Bool = false

    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.status = path.status
            self?.isReachableOnCellular = path.isExpensive
            if path.status == .satisfied {
                self?.isNetworkAvailable = true
                print("We're connected!")
//                self?.isInternetAvailable = false
                if(!(self?.isInternetAvailable ?? false)){
                    NotificationCenter.default.post(name: .statusChanged, object: self)
                }
                // post connected notification
            } else {
                print("No connection.")
                self?.isNetworkAvailable =  false
                self?.isInternetAvailable = true
                // post disconnected notification
            }
            print(path.isExpensive)
        }

        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }

    func stopMonitoring() {
        monitor.cancel()
    }
}


extension Notification.Name {
    static let statusChanged = Notification.Name("InternetStatusChanged")
}
