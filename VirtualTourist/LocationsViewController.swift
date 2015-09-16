//
//  LocationsViewController.swift
//  VirtualTourist
//
//  Created by Marius Horga on 9/7/15.
//  Copyright (c) 2015 Marius Horga. All rights reserved.
//

import MapKit
import CoreData
import CoreLocation

class LocationsViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!

    private var sharedContext: NSManagedObjectContext {
        return CoreDataStack.sharedInstance().managedObjectContext!
    }
    private var annotations = [Pin]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UILongPressGestureRecognizer(target: self, action: "dropPin:")
        tap.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(tap)
        fetchRegion()
        loadPins()
    }
    
    func dropPin(tap: UILongPressGestureRecognizer) {
        if tap.state != UIGestureRecognizerState.Began {
            return
        } else {
            let point = tap.locationInView(mapView)
            let coordinate = mapView.convertPoint(point, toCoordinateFromView: mapView)
            let annotation = createPinFromCoordinate(coordinate)
            savePin(annotation)
        }
    }
    
    func createPinFromCoordinate(coordinate: CLLocationCoordinate2D) -> MKPointAnnotation {
        let newLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Location"
        annotation.subtitle = "X photos available"
        CLGeocoder().reverseGeocodeLocation(newLocation) { placemark, error in
            if error == nil && !placemark.isEmpty {
                if placemark.count > 0 {
                    let topPlaceMark = placemark.last as! CLPlacemark
                    let annotationTitle = "\(topPlaceMark.locality), \(topPlaceMark.country)"
                    dispatch_async(dispatch_get_main_queue()) {
                        // this line does not finish by the time Core Data saves context
                        annotation.title = annotationTitle
                    }
                }
            }
        }
        return annotation
    }
    
    func savePin(annotation: MKPointAnnotation) {
        let locationInfo: [String : AnyObject] = [
            "latitude": annotation.coordinate.latitude,
            "longitude": annotation.coordinate.longitude,
            "name": annotation.title
        ]
        let location = Pin(dictionary: locationInfo, context: sharedContext)
        mapView.addAnnotation(annotation)
        annotations.append(location)
        CoreDataStack.sharedInstance().saveContext()
    }
    
    func deletePin(annotation: MKPointAnnotation) {
        let locationInfo: [String : AnyObject] = [
            "latitude": annotation.coordinate.latitude,
            "longitude": annotation.coordinate.longitude,
            "name": annotation.title
        ]
        let location = Pin(dictionary: locationInfo, context: sharedContext)
        mapView.removeAnnotation(annotation)
        sharedContext.deleteObject(location)
        CoreDataStack.sharedInstance().saveContext()
    }
    
    func loadPins() {
        annotations = fetchAllLocations()
        var pins = [MKPointAnnotation]()
        for location in annotations {
            let annotation = MKPointAnnotation()
            let latitude = location.latitude as CLLocationDegrees
            let longitude = location.longitude as CLLocationDegrees
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            annotation.coordinate = coordinate
            annotation.title = location.name
            annotation.subtitle = "X photos available"
            pins.append(annotation)
        }
        mapView.addAnnotations(pins)
    }
    
    func fetchAllLocations() -> [Pin] {
        let error: NSErrorPointer = nil
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        let results = sharedContext.executeFetchRequest(fetchRequest, error: error)
        if error != nil {
            println("Error in fectchAllActors(): \(error)")
        }
        return results as? [Pin] ?? [Pin]()
    }
    
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        let region = [
            "latitude" : mapView.region.center.latitude,
            "longitude" : mapView.region.center.longitude,
            "latitudeDelta" : mapView.region.span.latitudeDelta,
            "longitudeDelta" : mapView.region.span.longitudeDelta
        ]
        NSUserDefaults.standardUserDefaults().setObject(region, forKey: "region")
    }
    
    func fetchRegion() {
        if let region: AnyObject = NSUserDefaults.standardUserDefaults().objectForKey("region") {
            let longitude = region["longitude"] as! CLLocationDegrees
            let latitude = region["latitude"] as! CLLocationDegrees
            let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let longitudeDelta = region["latitudeDelta"] as! CLLocationDegrees
            let latitudeDelta = region["latitudeDelta"] as! CLLocationDegrees
            let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
            let newRegion = MKCoordinateRegion(center: center, span: span)
            mapView.setRegion(newRegion, animated: true)
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var pin = mapView.dequeueReusableAnnotationViewWithIdentifier("pin") as? MKPinAnnotationView
        if pin == nil {
            pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            pin!.pinColor = .Red
            pin!.canShowCallout = true
            pin!.animatesDrop = true
            pin!.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
            pin!.draggable = true
        } else {
            pin!.annotation = annotation
        }
        return pin
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        switch (newState) {
            case .Starting:
                view.dragState = .Dragging
                let annotation = view.annotation as! MKPointAnnotation
//                deletePin(annotation)
            case .Ending, .Canceling:
                view.dragState = MKAnnotationViewDragState.Ending
                let coordinate = view.annotation.coordinate
//                let annotation = createPinFromCoordinate(coordinate)
//                savePin(annotation)
            default: break
        }
    }
    
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == annotationView.rightCalloutAccessoryView {
            navigationController?.performSegueWithIdentifier("show", sender: self)
        }
    }
}
