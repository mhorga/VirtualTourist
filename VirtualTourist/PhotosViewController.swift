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
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    let sharedContext = CoreDataStack.sharedInstance().managedObjectContext
    var annotation: Annotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = true
        if let annotation = annotation {
            let region = MKCoordinateRegionMake(annotation.coordinate, MKCoordinateSpanMake(0.4, 0.4))
            mapView.setRegion(region, animated: true)
            mapView.addAnnotation(annotation)
            getPhotos(annotation)
        }
    }
    
    func getPhotos(annotation: Annotation) {
        Flickr.sharedInstance.startTaskForURL(annotation) { urls, error in
            if error != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    let alert = UIAlertView(title: "Could not retrieve photos", message: "Photos cannot be retrieved at this time", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                }
            } else if urls == nil {
                print("Invalid API key.")
                return
            } else {
                for (_, url) in (urls!).enumerate() {
                    let docPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first
                    let path = "/" + annotation.pin!.latitude.description.stringByReplacingOccurrencesOfString(".", withString: "_", options: .LiteralSearch, range: nil) + "-" + annotation.pin!.longitude.description.stringByReplacingOccurrencesOfString(".", withString: "_", options: .LiteralSearch, range: nil) + "-" + url.lastPathComponent!
                    let dict = ["imagePath" : path, "pin" : annotation.pin!]
                    let photo = Photo(dictionary: dict, context: self.sharedContext)
                    Flickr.sharedInstance.downloadPhoto(url, toPath: (docPath! + path)) { success, error in
                        dispatch_async(dispatch_get_main_queue()) {
                            if error != nil {
                                self.sharedContext.deleteObject(photo)
                                try! self.sharedContext.save()
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
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (annotation?.pin!.pictures.count)!
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoCell
        let docPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first
        let imagePath = annotation?.pin?.pictures[indexPath.row].imagePath
        if let image = UIImage(contentsOfFile: (docPath! + imagePath!)) {
            cell.activityIndicator.stopAnimating()
            cell.activityIndicator.hidden = true
            cell.imageView.image = image
            cell.imageView.backgroundColor = UIColor.whiteColor()
        } else {
            cell.activityIndicator.startAnimating()
            cell.activityIndicator.hidden = false
            cell.imageView.backgroundColor = UIColor.grayColor()
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 22) / 2
        return CGSize(width: width, height: width)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.5
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.5
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoCell
        cell.alpha = 0.4
        deleteButton.enabled = true
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoCell
        cell.alpha = 1.0
        if collectionView.indexPathsForSelectedItems()!.count == 0 {
            deleteButton.enabled = false
        }
    }
    
    @IBAction func refresh(sender: UIBarButtonItem) {
        for index in collectionView.indexPathsForSelectedItems()! {
            collectionView.deselectItemAtIndexPath(index, animated: true)
            collectionView(collectionView, didDeselectItemAtIndexPath: index)
        }
        for photo in annotation!.pin!.pictures {
            sharedContext.deleteObject(photo)
        }
        collectionView.reloadData()
        getPhotos(annotation!)
    }
    
    
    @IBAction func deletes(sender: UIBarButtonItem) {
        while let index = collectionView.indexPathsForSelectedItems()!.first {
            let row = index.row
            let photo = annotation?.pin!.pictures[row]
            sharedContext.deleteObject(photo!)
            try! sharedContext.save()
            collectionView.deleteItemsAtIndexPaths([index])
        }
    }
}
