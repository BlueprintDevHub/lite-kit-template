import SwiftUI
import MapKit
import CoreLocation

struct RealMapComponentsView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.9042, longitude: 116.4074),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @State private var selectedLocation = MapLocation.beijing
    @State private var showLocationPicker = false
    @State private var mapType: MKMapType = .standard
    @State private var annotations: [MapAnnotation] = []
    @State private var route: MKRoute?
    @State private var showingRoute = false
    @State private var directions: MKDirections? // 支持取消
    
    let locations = [
        MapLocation.beijing,
        MapLocation.shanghai,
        MapLocation.guangzhou,
        MapLocation.shenzhen
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ComponentSection("交互式地图") {
                    RealMapView(
                        region: $region,
                        mapType: mapType,
                        annotations: annotations,
                        route: route,
                        userLocation: locationManager.lastLocation
                    )
                    .frame(height: 300)
                    .cornerRadius(12)
                    .clipped()
                }
                
                ComponentSection("地图控制") {
                    VStack(spacing: 12) {
                        HStack {
                            Text("地图样式")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Spacer()
                            Picker("地图样式", selection: $mapType) {
                                Text("标准").tag(MKMapType.standard)
                                Text("卫星").tag(MKMapType.satellite)
                                Text("混合").tag(MKMapType.hybrid)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        
                        HStack {
                            Text("位置选择")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Spacer()
                            Button(selectedLocation.name) {
                                showLocationPicker = true
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
                
                ComponentSection("地图标记") {
                    VStack(spacing: 12) {
                        Button("显示所有城市标记") {
                            showAllCityMarkers()
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("清除标记") {
                            annotations.removeAll()
                        }
                        .buttonStyle(.bordered)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
                
                ComponentSection("路径规划") {
                    VStack(spacing: 12) {
                        Button(showingRoute ? "隐藏路径" : "显示北京到上海路径") {
                            if showingRoute {
                                route = nil
                                showingRoute = false
                                directions?.cancel()
                                directions = nil
                            } else {
                                calculateRoute()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        
                        if showingRoute {
                            VStack(alignment: .leading, spacing: 4) {
                                if let route = route {
                                    Text("距离: \(String(format: "%.1f", route.distance / 1000)) 公里")
                                        .font(.caption)
                                    Text("预计时间: \(formatTime(route.expectedTravelTime))")
                                        .font(.caption)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
                
                ComponentSection("地图功能") {
                    VStack(spacing: 12) {
                        Button("定位到当前位置") {
                            requestLocationAndCenter()
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("搜索附近餐厅") {
                            searchNearbyPlaces()
                        }
                        .buttonStyle(.bordered)
                        
                        if let location = locationManager.lastLocation {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("当前位置:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("纬度: \(String(format: "%.4f", location.coordinate.latitude))")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text("经度: \(String(format: "%.4f", location.coordinate.longitude))")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
        }
        .navigationTitle("地图组件")
        .onAppear {
            locationManager.requestPermission()
        }
        .onChange(of: selectedLocation) { _, newLocation in
            withAnimation {
                region.center = CLLocationCoordinate2D(
                    latitude: newLocation.latitude,
                    longitude: newLocation.longitude
                )
            }
        }
        .onChange(of: locationManager.lastLocation) { _, newLocation in
            if let location = newLocation {
                withAnimation {
                    region.center = location.coordinate
                }
            }
        }
        .sheet(isPresented: $showLocationPicker) {
            LocationPickerView(selectedLocation: $selectedLocation, locations: locations)
        }
    }
    
    private func requestLocationAndCenter() {
        locationManager.requestLocation()
    }
    
    private func showAllCityMarkers() {
        annotations = locations.map { location in
            MapAnnotation(
                coordinate: CLLocationCoordinate2D(
                    latitude: location.latitude,
                    longitude: location.longitude
                ),
                title: location.name,
                subtitle: location.description
            )
        }
    }
    
    private func calculateRoute() {
        directions?.cancel()
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(
            coordinate: CLLocationCoordinate2D(latitude: 39.9042, longitude: 116.4074)
        ))
        request.destination = MKMapItem(placemark: MKPlacemark(
            coordinate: CLLocationCoordinate2D(latitude: 31.2304, longitude: 121.4737)
        ))
        request.transportType = .automobile
        
        let newDirections = MKDirections(request: request)
        directions = newDirections
        newDirections.calculate { response, _ in
            if let route = response?.routes.first {
                self.route = route
                self.showingRoute = true
                withAnimation {
                    self.region = MKCoordinateRegion(route.polyline.boundingMapRect)
                }
            }
        }
    }
    
    private func searchNearbyPlaces() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "餐厅"
        request.region = region
        
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            if let response = response {
                let newAnnotations = response.mapItems.prefix(10).map { item in
                    MapAnnotation(
                        coordinate: item.placemark.coordinate,
                        title: item.name ?? "未知地点",
                        subtitle: item.placemark.title ?? ""
                    )
                }
                annotations = Array(newAnnotations)
            }
        }
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)小时\(minutes)分钟"
        } else {
            return "\(minutes)分钟"
        }
    }
}

// 真实地图视图
struct RealMapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    let mapType: MKMapType
    let annotations: [MapAnnotation]
    let route: MKRoute?
    let userLocation: CLLocation?
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .none
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // 更新地图类型
        if uiView.mapType != mapType {
            uiView.mapType = mapType
        }
        
        // 更新区域
        if !uiView.region.isEqual(to: region) {
            uiView.setRegion(region, animated: true)
        }
        
        // 更新标注（差异更新，避免全量刷新）
        let existing = uiView.annotations.compactMap { $0 as? MapAnnotation }
        let toRemove = existing.filter { !annotations.contains($0) }
        let toAdd = annotations.filter { !existing.contains($0) }
        if !toRemove.isEmpty { uiView.removeAnnotations(toRemove) }
        if !toAdd.isEmpty { uiView.addAnnotations(toAdd) }
        
        // 更新路线
        if !uiView.overlays.isEmpty {
            uiView.removeOverlays(uiView.overlays)
        }
        if let route = route {
            uiView.addOverlay(route.polyline)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        let parent: RealMapView
        
        init(_ parent: RealMapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            parent.region = mapView.region
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let annotation = annotation as? MapAnnotation else { return nil }
            
            let identifier = "MapAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
            } else {
                annotationView?.annotation = annotation
            }
            
            return annotationView
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .systemBlue
                renderer.lineWidth = 4
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}

// 地图标注类
final class MapAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
    
    // 通过重写 NSObject 等价与哈希，提供“值相等”语义，避免数组 diff 仅按对象身份比较
    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? MapAnnotation else { return false }
        return coordinate.latitude == rhs.coordinate.latitude &&
               coordinate.longitude == rhs.coordinate.longitude &&
               title == rhs.title &&
               subtitle == rhs.subtitle
    }
    
    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(coordinate.latitude)
        hasher.combine(coordinate.longitude)
        hasher.combine(title)
        hasher.combine(subtitle)
        return hasher.finalize()
    }
}

// MKCoordinateRegion 相等性比较
extension MKCoordinateRegion {
    func isEqual(to other: MKCoordinateRegion, tolerance: Double = 0.0001) -> Bool {
        return abs(center.latitude - other.center.latitude) < tolerance &&
               abs(center.longitude - other.center.longitude) < tolerance &&
               abs(span.latitudeDelta - other.span.latitudeDelta) < tolerance &&
               abs(span.longitudeDelta - other.span.longitudeDelta) < tolerance
    }
}

#Preview {
    NavigationView {
        RealMapComponentsView()
    }
}
