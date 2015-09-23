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

    let sharedContext = CoreDataStack.sharedInstance().managedObjectContext
    var annotation: Annotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        _ = NSEntityDescription.entityForName("Pin", inManagedObjectContext: sharedContext)!
        let longPress = UILongPressGestureRecognizer(target: self, action: "handleGesture:")
        longPress.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPress)
        fetchRegion()
        loadPins()
    }
    
    func loadPins() {
        let request = NSFetchRequest(entityName: "Pin")
        let pins = (try! sharedContext.executeFetchRequest(request)) as! [Pin]
        for pin in pins {
            let pinAnnotation = Annotation(pin: pin)
            pinAnnotation.coordinate = CLLocationCoordinate2DMake(pin.latitude, pin.longitude)
            mapView.addAnnotation(pinAnnotation)
        }
    }
    
    func addPinAnnotationAtPoint(point: CGPoint) -> Annotation {
        let coordinate = mapView.convertPoint(point, toCoordinateFromView: mapView)
        let pinAnnotation = addPinAnnotationToCoordinate(coordinate)
        return pinAnnotation
    }
    
    func addPinAnnotationToCoordinate(location: CLLocationCoordinate2D) -> Annotation {
        let pin = Pin(dictionary: ["latitude" : Double(location.latitude), "longitude" : Double(location.longitude)], context: sharedContext)
        let annotation = Annotation(pin: pin)
        annotation.coordinate = location
        mapView.addAnnotation(annotation)
        return annotation
    }
    
    func handleGesture(sender: UILongPressGestureRecognizer) {
        let point = sender.locationInView(sender.view)
        switch sender.state {
        case .Began:
            annotation = addPinAnnotationAtPoint(point)
        case .Changed:
            annotation!.coordinate = mapView.convertPoint(point, toCoordinateFromView: mapView)
            let photosVC = PhotosViewController()
            photosVC.getPhotos(annotation!)
        case .Cancelled:
            mapView.removeAnnotation(annotation!)
            annotation = nil
        default:
            annotation = nil
        }
    }
    
    func addLocationName(inout annotation: Annotation) {
        let location = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        CLGeocoder().reverseGeocodeLocation(location) { placemark, error in
            if error == nil && !placemark!.isEmpty {
                if placemark!.count > 0 {
                    let topPlaceMark = placemark!.last
                    var annotationTitle = topPlaceMark!.locality
                    let annotationSubtitle = topPlaceMark!.country
                    if annotationSubtitle == "United States" {
                        annotationTitle = "\(topPlaceMark!.locality), \(topPlaceMark!.administrativeArea)"
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        annotation.title = annotationTitle
                        annotation.subtitle = annotationSubtitle
                    }
                }
            }
        }
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
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
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
//        pin.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIButton
//        pin.canShowCallout = true
        pin.animatesDrop = true
        pin.draggable = true
        return pin
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        if newState == .Ending {
            let annotation = view.annotation as! Annotation
            addPinAnnotationToCoordinate(annotation.coordinate)
            CoreDataStack.sharedInstance().saveContext()
        }
    }
    
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == annotationView.rightCalloutAccessoryView {
//            let destination = storyboard?.instantiateViewControllerWithIdentifier("photos") as! PhotosViewController
//            let annotation = annotationView.annotation as! Annotation
//            destination.annotation = annotation
//            navigationController?.pushViewController(destination, animated: true)
        }
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: true)
        let annotation = view.annotation as! Annotation
        performSegueWithIdentifier("show", sender: annotation)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "show" {
            let annotation = sender as! Annotation
            let destination = segue.destinationViewController as! PhotosViewController
            destination.annotation = annotation
        }
    }
}
