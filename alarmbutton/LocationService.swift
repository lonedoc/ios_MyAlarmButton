//
//  LocationService.swift
//  alarmbutton
//
//  Created by Rubeg NPO on 27/06/2020.
//  Copyright © 2020 Rubeg NPO. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationService {
    var lastLatitude: Double? { get }
    var lastLongitude: Double? { get }
    func requestAuthorization()
    func startLocationSharing(addresses: [InetAddress], initialAddressIndex: Int)
    func stopLocationSharing()
}

class LocationServiceImpl : NSObject {
    
    let locationManager: CLLocationManager
    let networkService: NetworkService
    
    var addresses = [InetAddress]()
    var currentAddressIndex = 0
    
    // TODO: Make it thread-safe
    private(set) var lastLatitude: Double? = nil
    private(set) var lastLongitude: Double? = nil
    
    init(networkService: NetworkService) {
        self.networkService = networkService
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.allowsBackgroundLocationUpdates = true
    
        super.init()
        
        locationManager.delegate = self
    }
    
    private func sendUpdateLocationRequest(latitude: Double, longitude: Double, accuracy: Double, speed: Double) {
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
            speed: speed
        )
        
        networkService.send(request: request, to: address) { success in
            if !success {
                self.currentAddressIndex += 1
            }
        }
    }
        
}

// MARK: CLLocationManagerDelegate

extension LocationServiceImpl : CLLocationManagerDelegate {
    
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
            speed: location.speed
        )
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // TODO: Implement this
    }
    
}

// MARK: LocationService

extension LocationServiceImpl : LocationService {
    
    func requestAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }
    
    func startLocationSharing(addresses: [InetAddress], initialAddressIndex: Int) {
        self.addresses = addresses
        self.currentAddressIndex = initialAddressIndex
        
        locationManager.startUpdatingLocation()
    }
    
    func stopLocationSharing() {
        locationManager.stopUpdatingLocation()
    }
    
}
