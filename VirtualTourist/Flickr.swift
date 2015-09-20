//
//  Flickr.swift
//  VirtualTourist
//
//  Created by Marius Horga on 9/18/15.
//  Copyright (c) 2015 Marius Horga. All rights reserved.
//

import CoreData

class Flickr: NSObject {
    
    private var sharedContext: NSManagedObjectContext {
        return CoreDataStack.sharedInstance().managedObjectContext
    }
    static let sharedInstance = Flickr()
    
    private override init() {
        super.init()
    }
    
    func downloadPhoto(url: NSURL, toPath path: String, completionHandler: (success: Bool, error: NSError?)->Void) {
        let request = NSURLRequest(URL: url)
        let task = NSURLSession.sharedSession().downloadTaskWithRequest(request) { url, response, error in
            if let error = error {
                completionHandler(success: false, error: error)
            } else {
                let data = NSData(contentsOfURL: url!)!
                data.writeToFile(path, atomically: true)
                completionHandler(success: true, error: nil)
            }
        }
        task.resume()
    }
    
    func startTaskForURL(pinAnnotation: Annotation, completionHandler: (urls: [NSURL]?, error: NSError?) -> Void) -> NSURLSessionTask {
        let params = [
            "method" : Constants.searchPhotos,
            "api_key" : Constants.apiKey,
            "extras" : Constants.urlExtra,
            "format" : Constants.jsonFormat,
            "nojsoncallback" : "1",
            "lat" : pinAnnotation.coordinate.latitude.description,
            "lon" : pinAnnotation.coordinate.longitude.description,
            "radius" : "5",
            "per_page" : Constants.perPage.description
        ]
        return taskForURL(params, completionHandler: completionHandler)
    }
    
    func taskForURL( parameters: [String:String], completionHandler: (urls: [NSURL]?, error: NSError?) -> Void) -> NSURLSessionTask {
        let urlString = Constants.baseURL + "?" + escapedParameters(parameters)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if let error = error {
                completionHandler(urls: nil, error: error)
            } else {
                let jsonError: NSError? = nil
                let json = (try! NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)) as! NSDictionary
                if let results = json["photos"] as? [String:AnyObject],
                    let photos = results["photo"] as? [[String:AnyObject]] {
                        let urls = photos.map { (photo: [String:AnyObject]) -> NSURL in
                            let urlString = photo[Constants.urlExtra] as! String
                            return NSURL(string: urlString)!
                        }
                        completionHandler(urls: urls, error: nil)
                } else {
                    completionHandler(urls: nil, error: jsonError)
                }
            }
        }
        task.resume()
        return task
    }
    
    func escapedParameters(dictionary: [String:String]) -> String {
        let queryItems = dictionary.map {
            NSURLQueryItem(name: $0, value: $1)
        }
        let comps = NSURLComponents()
        comps.queryItems = queryItems
        return comps.percentEncodedQuery ?? ""
    }
}
