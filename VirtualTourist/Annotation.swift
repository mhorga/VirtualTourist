//
//  Annotation.swift
//  VirtualTourist
//
//  Created by Marius Horga on 9/18/15.
//  Copyright (c) 2015 Marius Horga. All rights reserved.
//

import MapKit

class Annotation: MKPointAnnotation {
    
    let pin: Pin?
    
    init(pin: Pin) {
        self.pin = pin
    }
}