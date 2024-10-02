//
//  LocationManager.swift
//  Andlet
//
//  Created by Daniel Arango Cruz on 1/10/24.
//

import CoreLocation
import UserNotifications

class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    private var locationManager = CLLocationManager()
    
    //University coordinates
    private let universityLatitude = 4.628997
    private let universityLongitude = -74.083394
    
    override init() {
        super.init()
        locationManager.delegate = self
        requestPermissions()
//        locationManager.startUpdatingLocation()
    }
    
    private func requestPermissions () {
        locationManager.requestAlwaysAuthorization()
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { garanted, error in
            if let error = error {
                print("Error requesting notification authorizatoin \(error)")
            }
            else{
                print("Notification permission garanted: \(garanted)")
            }
            
        }
        
    }
    
    func registerUniversityGeofence() {
        let universityCenter = CLLocationCoordinate2D(latitude: universityLatitude, longitude: universityLongitude)
        let geofenceRegion = CLCircularRegion(center: universityCenter, radius: 500, identifier: "universityGeofence")
        geofenceRegion.notifyOnEntry = true
        geofenceRegion.notifyOnExit = false
        
        locationManager.startMonitoring(for: geofenceRegion)
        print("Geofence registered around the university")
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error){
        print("Failed to monitor region: \(error.localizedDescription)")
    }
    
    private func sendNotification() {
            let content = UNMutableNotificationContent()
            content.title = "Hey!"
            content.body = "Don't miss the latest offers near the university!"
            content.sound = .default

            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)

            UNUserNotificationCenter.current().add(request) { error in
                print("Notification sended")
                if let error = error {
                    print("Failed to send notification: \(error)")
                }
            }
        }
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
            if region.identifier == "universityGeofence" {
                print("Entered university geofence region")
                sendNotification()  // Trigger the notification
            }
        }

        // Error handling in case geofencing monitoring fails
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with error: \(error.localizedDescription)")
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let currentLocation = locations.last else { return }

            // Define the university's location as a CLLocation object
            let universityLocation = CLLocation(latitude: universityLatitude, longitude: universityLongitude)
            
            // Check if the user is already within the geofence region
            let distance = currentLocation.distance(from: universityLocation)
            if distance <= 500 {
                print("User is already within the university geofence")
                sendNotification()  // Trigger notification manually
                print("Stop updating")
//                locationManager.stopUpdatingLocation()
                
            }
        }
}
