import Foundation
import CoreLocation

class LocationManagerService: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var lastKnownLongitude: Double?
    @Published var permissionDenied: Bool = false
    @Published var isLocationAvailable: Bool = false

    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestLocation() {
        let status = locationManager.authorizationStatus
        
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied, .restricted:
            permissionDenied = true
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            permissionDenied = false
            locationManager.requestLocation()
        case .denied, .restricted:
            permissionDenied = true
            isLocationAvailable = false
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location failed: \(error.localizedDescription)")
        
        #if DEBUG
        if error.localizedDescription.contains("network") {
            lastKnownLongitude = 34.8
            isLocationAvailable = true
            print("Using simulated location for testing")
        }
        #endif
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            lastKnownLongitude = location.coordinate.longitude
            isLocationAvailable = true
            print("Location updated: \(location.coordinate.longitude)")
            
            
            locationManager.stopUpdatingLocation()
        }
    }
}
