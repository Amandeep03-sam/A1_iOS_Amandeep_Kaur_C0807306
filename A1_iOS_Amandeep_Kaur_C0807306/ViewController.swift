//
//  ViewController.swift
//  A1_iOS_Amandeep_Kaur_C0807306
//
//  Created by Amandeep Kaur on 17/05/21.
//
import UIKit
import MapKit
class ViewController: UIViewController {
@IBOutlet weak var map: MKMapView!
@IBOutlet weak var directionBtn: UIButton!
    //destination
    var destination: CLLocationCoordinate2D!
    var locationManager = CLLocationManager()
    var oldValue: Double = 0
var places:[CLLocationCoordinate2D] = []
var titles:[String:Bool] = ["A":false, "B": false, "C": false]
var middleArray:[MKAnnotation] = []
override func viewDidLoad() {
super.viewDidLoad()
map.isZoomEnabled = false
map.showsUserLocation = true
directionBtn.isHidden = false
locationManager.delegate = self
locationManager.desiredAccuracy = kCLLocationAccuracyBest
locationManager.requestWhenInUseAuthorization()
locationManager.startUpdatingLocation()
addTap()
map.delegate = self }
    @IBAction func zoomInOut(_ sender: UIStepper) {
        if sender.value > oldValue {
            oldValue += 1
            let span = MKCoordinateSpan(latitudeDelta: map.region.span.latitudeDelta / 2, longitudeDelta: map.region.span.longitudeDelta / 2)
            let region = MKCoordinateRegion(center: map.region.center, span: span)
            map.setRegion(region, animated: true)
        } else {
            oldValue -= 1
            let span = MKCoordinateSpan(latitudeDelta: map.region.span.latitudeDelta * 2, longitudeDelta: map.region.span.longitudeDelta * 2)
            let region = MKCoordinateRegion(center: map.region.center, span: span)
            map.setRegion(region, animated: true)
        }
    }/*
    @IBAction func navigate(_ sender: UIButton) {
        
            let sourcePlacemark = MKPlacemark(coordinate: locationManager.location!.coordinate)
            let destinationPlacemark = MKPlacemark(coordinate: (destination))
            
            // direction request
            let directionRequest = MKDirections.Request()
            directionRequest.source = MKMapItem(placemark: sourcePlacemark)
            directionRequest.destination = MKMapItem(placemark: destinationPlacemark)
            
            //transport type
            directionRequest.transportType = .walking
            
            // calculate the direction
            let directions = MKDirections(request: directionRequest);
            directions.calculate { response, error in
                guard let directionResponse = response else { return }
                // create route
                let route = directionResponse.routes[0]
                //draw polyline
                self.map.addOverlay(route.polyline, level: .aboveRoads)
                
               // self.map.addOverlays(route.po)
                // define boundary
                let rect = route.polyline.boundingMapRect
                self.map.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 100, left: 100 , bottom: 100, right: 100), animated: true)
         
            }}
    
    */

    
    
    func addPolyline() {
        var polyLinePlaces = places
        if let  first = places.first {
            polyLinePlaces.append(first)
            let polyline = MKPolyline(coordinates: polyLinePlaces, count: polyLinePlaces.count)
            polyline.title = "Draw Markers"
            map.addOverlay(polyline) } }
    
    func addPolygon() {
        let polygon = MKPolygon(coordinates: places, count: places.count)
        map.addOverlay(polygon) }
    
    
    @IBAction func drawRoute(_ sender: UIButton) {
        map.removeOverlays(map.overlays)
        self.removeDistanceAnnotations()
        var polyLinePlaces = places
        if let  first = places.first {
            polyLinePlaces.append(first)
            for i in 0 ..< polyLinePlaces.count {
                let place = polyLinePlaces[i]
                if i >= places.count {
                    return
                }
                let destination: CLLocationCoordinate2D = polyLinePlaces[i + 1]
                let sourcePlaceMark = MKPlacemark(coordinate: place)
                let destinationPlaceMark = MKPlacemark(coordinate: destination)
                let directionRequest = MKDirections.Request()
                directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
                directionRequest.destination = MKMapItem(placemark: destinationPlaceMark)
                directionRequest.transportType = .automobile
                let directions = MKDirections(request: directionRequest)
                directions.calculate { (response, error) in
                    guard let directionResponse = response else {return}
                    let route = directionResponse.routes[0]
                    self.map.addOverlay(route.polyline, level: .aboveRoads)
                    let rect = route.polyline.boundingMapRect
                    self.map.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
                    self.map.setRegion(MKCoordinateRegion(rect), animated: true) } }
} }
    
    func addTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin))
        map.addGestureRecognizer(doubleTap) }

    @objc func dropPin(sender: UITapGestureRecognizer) {
        let touchPoint = sender.location(in: map)
        let coordinate = map.convert(touchPoint, toCoordinateFrom: map)
        
        for i in 0 ..< places.count{
            let place = places[i]
            let coordinate1 = CLLocation(latitude: place.latitude, longitude: place.longitude)
            let coordinate2 = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            let distanceInMeters = coordinate1.distance(from: coordinate2)
            if (place.latitude == coordinate.latitude && place.latitude == coordinate.latitude) || distanceInMeters < 100{
                places.remove(at: i)
                removePin(coordinate: place)
                return } }
        if places.count == 3 {
            removePin() }
        addAnotation(title: getTitle(), subtitle: nil, coordinate: coordinate)
        places.append(coordinate)
        if places.count == 3 {
            self.addPolyline()
            self.addPolygon() } }
    
    func getTitle() -> String {
        for title in titles.keys.sorted(){
            if !(titles[title] ?? false){
                titles[title] = true
                return title
            }
        }
        return ""
    }
    
    func removeDistanceAnnotations(){
        for annotation in self.middleArray{
            map.removeAnnotation(annotation)
        }
        self.middleArray.removeAll()
    }
    func removePin(coordinate : CLLocationCoordinate2D? = nil) {
        map.removeOverlays(map.overlays)
        self.removeDistanceAnnotations()
        
        for annotation in map.annotations {
            if let coordinate = coordinate, annotation.coordinate.latitude == coordinate.latitude, annotation.coordinate.latitude == coordinate.latitude {
                map.removeAnnotation(annotation)
                titles[(annotation.title ?? "") ?? ""] = false
                return
            }
            else if coordinate == nil , places.contains(where: { (coordinate) -> Bool in
                return annotation.coordinate.latitude == coordinate.latitude &&  annotation.coordinate.latitude == coordinate.latitude
            }){
                titles[(annotation.title ?? "") ?? ""] = false
                map.removeAnnotation(annotation)
            }
        }
        places.removeAll()
    }
    func addAnotation(title:String?, subtitle: String?, coordinate:CLLocationCoordinate2D, isMiddle:Bool = false){
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.coordinate = coordinate
        annotation.subtitle = subtitle
        map.addAnnotation(annotation)
        if isMiddle{
            middleArray.append(annotation)
        }
    }
    func getDistance(title:String)-> String{
        switch title {
        case "A":
            if let lat = places.first?.latitude, let long = places.first?.longitude, let myLocation = locationManager.location{
                let coordinate1 = CLLocation(latitude: lat, longitude: long)
                let distanceInMeters = coordinate1.distance(from: myLocation)
                return String(distanceInMeters/1000) + " KM"
            }
        case "B":
            if let myLocation = locationManager.location{
                let lat = places[1].latitude
                let long = places[1].longitude
                let coordinate1 = CLLocation(latitude: lat, longitude: long)
                let distanceInMeters = coordinate1.distance(from: myLocation)
                return String(distanceInMeters/1000) + " KM"
            }
        case "C":
            if let lat = places.last?.latitude, let long = places.last?.longitude, let myLocation = locationManager.location{
                let coordinate1 = CLLocation(latitude: lat, longitude: long)
                let distanceInMeters = coordinate1.distance(from: myLocation)
                return String(distanceInMeters/1000) + " KM"
            }
        default:
            break
        }
        return "0"
    }
    
func displayLocation(latitude: CLLocationDegrees,
longitude: CLLocationDegrees,
title: String,
subtitle: String) {
        let latDelta: CLLocationDegrees = 0.05
        let lngDelta: CLLocationDegrees = 0.05
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lngDelta)
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegion(center: location, span: span)
        map.setRegion(region, animated: true)
        self.addAnotation(title: title, subtitle: subtitle, coordinate: location)
    }
func distanceLabelForMarker(){
        var polyLinePlaces = places
        if let  first = places.first {
            polyLinePlaces.append(first)
            for i in 0 ..< polyLinePlaces.count {
                let place = polyLinePlaces[i]
                if i >= places.count {
                    return
                }
                let destination: CLLocationCoordinate2D = polyLinePlaces[i + 1]
                let middle = middleLocation(location: place, location2: destination)
                let coordinate1 = CLLocation(latitude: place.latitude, longitude: place.longitude)
                let coordinate2 = CLLocation(latitude: destination.latitude, longitude: destination.longitude)
                let distance = coordinate1.distance(from: coordinate2).description
                self.addAnotation(title: distance, subtitle: nil, coordinate: middle, isMiddle: true) } } }
    
func middleLocation(location:CLLocationCoordinate2D, location2: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let lon1 = location2.longitude * Double.pi / 180
        let lon2 = location.longitude * Double.pi / 180
        let lat1 = location2.latitude * Double.pi / 180
        let lat2 = location.latitude * Double.pi / 180
        let dLon = lon2 - lon1
        let x = cos(lat2) * cos(dLon)
        let y = cos(lat2) * sin(dLon)
        
        let lat3 = atan2( sin(lat1) + sin(lat2), sqrt((cos(lat1) + x) * (cos(lat1) + x) + y * y) )
        let lon3 = lon1 + atan2(y, cos(lat1) + x)
        
        let center:CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat3 * 180 / Double.pi, lon3 * 180 / Double.pi)
        return center
    }
    }

extension ViewController: MKMapViewDelegate {
    
    
func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        if let title = annotation.title as? String, let intTitle = Double(title){
            let annotationView = DistanceAnnotationView(annotation: annotation, reuseIdentifier: "distance")
            annotationView.distance = Int(intTitle)
            return annotationView
        }
        
        switch annotation.title {
        case "my location":
            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "MyMarker")
            annotationView.markerTintColor = UIColor.blue
            return annotationView
        case "A", "B", "C":
            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
            annotationView.canShowCallout = true
            let detailLabel = UILabel()
            detailLabel.text = self.getDistance(title: (annotation.title ?? "") ?? "")
            annotationView.detailCalloutAccessoryView = detailLabel
            return annotationView
        default:
            return nil } }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let rendrer = MKPolylineRenderer(overlay: overlay)
            if overlay.title == "Draw Markers"{
                self.distanceLabelForMarker()
            }
            rendrer.strokeColor = UIColor.green
            rendrer.lineWidth = 3
            return rendrer
        } else if overlay is MKPolygon {
            let rendrer = MKPolygonRenderer(overlay: overlay)
            rendrer.fillColor = UIColor.red.withAlphaComponent(0.5)
            return rendrer }
        return MKOverlayRenderer() } }
extension ViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        removePin()
        let userLocation = locations[0]
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        displayLocation(latitude: latitude, longitude: longitude, title: "my location", subtitle: "you are here") } }
