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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let longPress = UILongPressGestureRecognizer(target: self, action: "handleGesture:")
        longPress.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPress)
        fetchRegion()
        loadPins()
    }
    
    func handleGesture(tap: UILongPressGestureRecognizer) {
        if tap.state != UIGestureRecognizerState.Began {
            return
        } else {
            let point = tap.locationInView(tap.view)
            let coordinate = mapView.convertPoint(point, toCoordinateFromView: mapView)
            let pin = createPin(coordinate)
            let annotation = Annotation(pin: pin)
            annotation.coordinate = coordinate
            createAnnotation(annotation)
            mapView.addAnnotation(annotation)
        }
    }
    
    func createPin(coordinate: CLLocationCoordinate2D) -> Pin {
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        let dictionary: [String : AnyObject] = [
            "latitude" : latitude,
            "longitude" : longitude,
            "name" : "Location"
        ]
        let pin = Pin(dictionary: dictionary, context: sharedContext)
        return pin
    }
    
    func loadPins() {
        let pins = fetchLocations(nil, longitude: nil)
        for pin in pins {
            let annotation = Annotation(pin: pin)
            let coordinate = CLLocationCoordinate2D(latitude: pin.latitude as CLLocationDegrees, longitude: pin.longitude as CLLocationDegrees)
            annotation.coordinate = coordinate
            createAnnotation(annotation)
        }
    }
    
    func createAnnotation(var annotation: Annotation) {
        addLocationName(&annotation)
        mapView.addAnnotation(annotation)
    }

    func addLocationName(inout annotation: Annotation) {
        let location = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        CLGeocoder().reverseGeocodeLocation(location) { placemark, error in
            if error == nil && !placemark.isEmpty {
                if placemark.count > 0 {
                    let topPlaceMark = placemark.last as! CLPlacemark
                    var annotationTitle = topPlaceMark.locality
                    let annotationSubtitle = topPlaceMark.country
                    if annotationSubtitle == "United States" {
                        annotationTitle = "\(topPlaceMark.locality), \(topPlaceMark.administrativeArea)"
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        annotation.title = annotationTitle
                        annotation.subtitle = annotationSubtitle
                    }
                }
            }
        }
    }
    
    func fetchLocations(latitude: Double?, longitude: Double?) -> [Pin] {
        let error: NSErrorPointer = nil
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        let results = sharedContext.executeFetchRequest(fetchRequest, error: error)
        if error != nil {
            println("Error: \(error.debugDescription)")
        }
        return results as! [Pin]
    }
    
    func fetchRegion() {
        if let region: AnyObject = NSUserDefaults.standardUserDefaults().objectForKey("region") {
            let latitude = region["latitude"] as! CLLocationDegrees
            let longitude = region["longitude"] as! CLLocationDegrees
            let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let longitudeDelta = region["latitudeDelta"] as! CLLocationDegrees
            let latitudeDelta = region["latitudeDelta"] as! CLLocationDegrees
            let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
            let newRegion = MKCoordinateRegion(center: center, span: span)
            mapView.setRegion(newRegion, animated: true)
        }
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
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        pin!.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
        pin!.canShowCallout = true
        pin!.animatesDrop = true
        pin!.draggable = true
        return pin
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        if newState == .Ending {
            var annotation = view.annotation as! Annotation
            createAnnotation(annotation)
            CoreDataStack.sharedInstance().saveContext()
        }
    }
    
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == annotationView.rightCalloutAccessoryView {
            let destination = storyboard?.instantiateViewControllerWithIdentifier("photos") as! PhotosViewController
            let annotation = annotationView.annotation as! Annotation
            destination.annotation = annotation
            navigationController?.pushViewController(destination, animated: true)
        }
    }
}
