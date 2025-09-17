import Foundation
import CoreLocation
import Combine

@MainActor
class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    
    @Published var lastLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var locationError: Error?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
    }
    
    func requestPermission() {
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            break
        case .authorizedAlways, .authorizedWhenInUse:
            startLocationUpdates()
        @unknown default:
            break
        }
    }
    
    func requestLocation() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            requestPermission()
            return
        }
        locationManager.requestLocation()
    }
    
    // 一次性定位（可选扩展使用）
    func requestOneShotLocation() async throws -> CLLocation {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            requestPermission()
            throw CLError(.denied)
        }
        return try await withCheckedThrowingContinuation { continuation in
            let delegate = OneShotDelegate { result in
                continuation.resume(with: result)
            }
            let originalDelegate = locationManager.delegate
            locationManager.delegate = delegate
            locationManager.requestLocation()
            
            delegate.onFinish = { result in
                self.locationManager.delegate = originalDelegate
                continuation.resume(with: result)
            }
        }
    }
    
    private func startLocationUpdates() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            return
        }
        locationManager.startUpdatingLocation()
    }
    
    private func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationError = error
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationUpdates()
        case .denied, .restricted:
            stopLocationUpdates()
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
}

// 一次性定位的轻量代理
private final class OneShotDelegate: NSObject, CLLocationManagerDelegate {
    var onFinish: ((Result<CLLocation, Error>) -> Void)?
    private var didFinish = false
    
    init(onFinish: @escaping (Result<CLLocation, Error>) -> Void) {
        self.onFinish = onFinish
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard !didFinish, let loc = locations.last else { return }
        didFinish = true
        onFinish?(.success(loc))
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard !didFinish else { return }
        didFinish = true
        onFinish?(.failure(error))
    }
}
