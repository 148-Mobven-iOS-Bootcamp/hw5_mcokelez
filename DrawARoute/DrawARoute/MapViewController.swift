//
//  MapViewController.swift
//  DrawARoute
//
//  Created by MAVİ on 19.01.2022.
//

import UIKit
import MapKit


class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        checkLocationPermission()
        addLongGestureRecognizer()
    }
    
    // Variables
    
    private var currentCoordinate: CLLocationCoordinate2D?
    private var destinationCoordinate: CLLocationCoordinate2D?
    private var regionMeters: Double = 20000
    private var routes: [MKRoute] = []
    private var index: Int = 0
    private var directionsArray: [MKDirections] = []
    private var selectRoute: MKRoute?
    
    func addLongGestureRecognizer() {
        let longPressGesture = UILongPressGestureRecognizer(target: self,
                                                            action: #selector(handleLongPressGesture(_ :)))
        self.view.addGestureRecognizer(longPressGesture)
    }
    
    @objc func handleLongPressGesture(_ sender: UILongPressGestureRecognizer) {
        let point = sender.location(in: mapView)
        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
        destinationCoordinate = coordinate
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Pinned"
        mapView.addAnnotation(annotation)
    }
    

    func centerUserLocation () {
        if let location = locationManager.location?.coordinate{
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionMeters, longitudinalMeters: regionMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func checkLocationPermission() {
        switch self.locationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse, .authorized:
            locationManager.requestLocation()
            mapView.showsUserLocation = true
            centerUserLocation()
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            //popup gosterecegiz. go to settings butonuna basildiginda
            //kullaniciyi uygulamamizin settings sayfasina gonder
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            fatalError()
        }
    }
    
    private lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        return locationManager
    }()
    
    @IBAction func directionBarButtonsTapped(_ sender: UIBarButtonItem) {
        changeTheRoute(index: self.index, sender: sender)
    }
    //MARK: Get all Routes
    
    func drawRouteFirst(){
        guard let currentCoordinate = currentCoordinate,
              let destinationCoordinate = destinationCoordinate else {
            print("couldnt get coordinates")
            return
        }
        
        let direction = getDirections(currentCoordinate: currentCoordinate, destinationCoordinate: destinationCoordinate)
        
        direction.calculate {
            (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                return
            }
            
            for route in response.routes{
                self.routes.append(route)
                self.mapView.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
                
                let rect = route.polyline.boundingMapRect
                self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
            }
        }
    }
    
    //MARK: Direction Bar Buttons Function
    
    func changeTheRoute( index: Int, sender: UIBarButtonItem){
        guard let currentCoordinate = currentCoordinate,
              let destinationCoordinate = destinationCoordinate else {
            print("couldnt get coordinates")
            return
        }
        let direction = getDirections(currentCoordinate: currentCoordinate, destinationCoordinate: destinationCoordinate)
        resetRoute(withNew: direction)
        
        /*Forward Bar Button Tapped**/
        
        if sender.tag == 1 {
            if index == routes.count - 1 {
                drawItemInRouteArray(0)
            } else {
                self.index += 1
               drawItemInRouteArray(index)
            }
        }
        /*Backward Bar Button Tapped **/
        
        else if sender.tag == 2{
            if index == 0 {
                drawItemInRouteArray(self.index)
            } else {
                self.index -= 1
                drawItemInRouteArray(self.index)
            }
        }
        
        /*Draw All Routes Bar Button Tapped**/
        
        else if sender.tag == 0{
            drawRouteFirst()
        }
    }
    
    /* According to index variable, show item in routes array**/
    
    func drawItemInRouteArray(_ index: Int) {
        self.selectRoute = routes[index]
        self.mapView.addOverlay((self.selectRoute!.polyline), level: MKOverlayLevel.aboveRoads)
        let rect = self.selectRoute!.polyline.boundingMapRect
        self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
    }
    
    
    /*Clear Routes when pin location changed**/
    
    func resetRoute(withNew directions: MKDirections){
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel()}
    }
    
    func getDirections(currentCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D ) -> MKDirections {
        let sourcePlacemark = MKPlacemark(coordinate: currentCoordinate)
        let source = MKMapItem(placemark: sourcePlacemark)
        
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate)
        let destination = MKMapItem(placemark: destinationPlacemark)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = source
        directionRequest.destination = destination
        directionRequest.transportType = .automobile
        directionRequest.requestsAlternateRoutes = true
        
        return MKDirections(request: directionRequest)
    }
    
}


//MARK: Location Manager Delegate

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = locations.first?.coordinate else { return }
        currentCoordinate = coordinate
        print("latitude: \(coordinate.latitude)")
        print("longitude: \(coordinate.longitude)")
        
        mapView.setCenter(coordinate, animated: true)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationPermission()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
}

//MARK: Map View Delegate

extension MapViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor(red: 17.0/255.0, green: 147.0/255.0, blue: 255.0/255.0, alpha: 1)
        renderer.lineWidth = 5.0
        
        return renderer
    }
    
}


