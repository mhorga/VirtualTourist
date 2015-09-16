//
//  PhotosViewController.swift
//  VirtualTourist
//
//  Created by Marius Horga on 9/15/15.
//  Copyright (c) 2015 Marius Horga. All rights reserved.
//

import MapKit

class PhotosViewController: UICollectionViewController {
    
    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView!.registerClass(PhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoCell
        cell.backgroundColor = UIColor.grayColor()
        return cell
    }
}
