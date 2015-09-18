//
//  PhotosViewController.swift
//  VirtualTourist
//
//  Created by Marius Horga on 9/15/15.
//  Copyright (c) 2015 Marius Horga. All rights reserved.
//

import MapKit
import CoreData

class PhotosViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var sharedContext: NSManagedObjectContext {
        return CoreDataStack.sharedInstance().managedObjectContext!
    }
    var annotation: Annotation?
    var photos: [Photo]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showMap()
    }
    
    func showMap() {
        if let annotation = self.annotation {
            getPhotos(annotation)
            let latitude = annotation.pin!.latitude as! CLLocationDegrees
            let longitude = annotation.pin!.longitude as! CLLocationDegrees
            let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3)
            let newRegion = MKCoordinateRegion(center: center, span: span)
            mapView.setRegion(newRegion, animated: true)
            photos = annotation.pin?.photos
            var pin = MKPointAnnotation()
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            pin.coordinate = coordinate
            mapView.addAnnotation(pin)
        }
    }
    
    func getPhotos(annotation: Annotation) {
        Flickr.sharedInstance.startTaskForURL(annotation) { urls, error in
            if error != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    let alert = UIAlertView(title: "Could not retrieve photos", message: "Photos cannot be retrieved at this time", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                    self.collectionView.reloadData()
                }
            } else {
                let pin = self.createPin(annotation.coordinate)
                for (index, url) in enumerate(urls!) {
                    let docPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first as! String
                    let path = "/" + annotation.coordinate.latitude.description.stringByReplacingOccurrencesOfString(".", withString: "_", options: .LiteralSearch, range: nil) + "-" + annotation.coordinate.longitude.description.stringByReplacingOccurrencesOfString(".", withString: "_", options: .LiteralSearch, range: nil) + "-" + url.lastPathComponent!
                    let dict = ["url" : path, "pin" : pin]
                    let photo = Photo(dictionary: dict, context: self.sharedContext)
                    Flickr.sharedInstance.downloadPhoto(url, toPath: (docPath + path)) { success, error in
                        dispatch_async(dispatch_get_main_queue()) {
                            if error != nil {
                                self.sharedContext.deleteObject(photo)
                                self.sharedContext.save(nil)
                            } else {
                                self.collectionView.reloadData()
                            }
                        }
                    }
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.collectionView.reloadData()
                }
            }
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

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 1) / 2
        return CGSize(width: width, height: width)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.5
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.5
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos!.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoCell
        let docPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first as! String
        let url = annotation!.pin!.photos[indexPath.row].url
        if let image = UIImage(contentsOfFile: (docPath + url)) {
            cell.activityIndicator.stopAnimating()
            cell.activityIndicator.hidden = true
            cell.imageView.image = image
            cell.imageView.backgroundColor = UIColor.yellowColor()
        } else {
            cell.activityIndicator.startAnimating()
            cell.activityIndicator.hidden = false
            cell.imageView.backgroundColor = UIColor.grayColor()
            cell.label.text = annotation?.title
        }
        return cell
    }
}
