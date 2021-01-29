//
//  LocationService.swift
//  alarmbutton
//
//  Created by Rubeg NPO on 27/06/2020.
//  Copyright © 2020 Rubeg NPO. All rights reserved.
//

import RubegProtocol_v2_0
import Foundation
import CoreLocation

protocol LocationService {
    var lastLatitude: Double? { get }
    var lastLongitude: Double? { get }
    func requestAuthorization()
    func startLocationSharing(addresses: [InetAddress], initialAddressIndex: Int, isTest: Bool)
    func stopLocationSharing()
}

class LocationServiceImpl: NSObject {

    let locationManager: CLLocationManager
    let networkService: NetworkService

    var addresses = [InetAddress]()
    var currentAddressIndex = 0

    private var isTest = false

    @Atomic private(set) var lastLatitude: Double?
    @Atomic private(set) var lastLongitude: Double?

    init(networkService: NetworkService) {
        self.networkService = networkService

        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 5
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.showsBackgroundLocationIndicator = true

        super.init()

        locationManager.delegate = self
    }

    private func sendUpdateLocationRequest(latitude: Double, longitude: Double, accuracy: Double, speed: Int) {
        guard addresses.count > 0 else {
            return
        }

        let address = addresses[currentAddressIndex % addresses.count]

        if !networkService.isStarted {
            do {
                try networkService.start()
            } catch let error {
                print(error.localizedDescription)
                return
            }
        }

        let request = UpdateLocationRequest(
            latitude: latitude,
            longitude: longitude,
            accuracy: accuracy,
            speed: speed,
            isTest: self.isTest
        )

        networkService.send(request: request, to: address) { success in
            if !success {
                self.currentAddressIndex += 1
            }
        }
    }

}

// MARK: CLLocationManagerDelegate

extension LocationServiceImpl: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }

        lastLatitude = location.coordinate.latitude
        lastLongitude = location.coordinate.longitude

        sendUpdateLocationRequest(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            accuracy: location.horizontalAccuracy,
            speed: Int(abs(location.speed * 3.6))
        )
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // TODO: Implement this
    }
}

// MARK: LocationService

extension LocationServiceImpl: LocationService {

    func requestAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }

    func startLocationSharing(addresses: [InetAddress], initialAddressIndex: Int, isTest: Bool) {
        self.isTest = isTest
        self.addresses = addresses
        self.currentAddressIndex = initialAddressIndex

        locationManager.startUpdatingLocation()
    }

    func stopLocationSharing() {
        isTest = false
        locationManager.stopUpdatingLocation()

        if networkService.isStarted {
            networkService.stop()
        }
    }

}
