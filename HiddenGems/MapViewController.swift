//
//  MapViewController.swift
//  HiddenGems
//
//  Created by Melissa Rojas on 2/23/16.
//  Copyright © 2016 Melissa Rojas. All rights reserved.
//

import UIKit
import CoreLocation
import AddressBook
import MapKit

var xloc : CLLocationDegrees!
var yloc : CLLocationDegrees!

var venueList : [NSDictionary]!
var exploreVenueList : NSMutableArray!

var exploreImageCache = [String: NSData]()

var radius : Double!
var centerPoint : CLLocationCoordinate2D!

var tempSize: Int!


class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    let fqClient_id = "XC5G1YSZQWRNB0UH1VMDAMKZWX453N1IPUHWNO1XHG5AC3VH"
    let fqClient_secret = "5XGRVKYPGJHPK5NGODYBTI2GKQU2JUMJQMAXYMTS2TTZ3RXX"
    
    //@IBOutlet weak var findEvents: UIButton!
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var radiusText: UITextField!
    
    @IBOutlet weak var radiusSlider: UISlider!
    
    let locationManager = CLLocationManager()
    
    //Swift 2:
    //var centerPoint = CLLocationCoordinate2D()
    //var centerPoint : CLLocationCoordinate2D!
    
    var circleOverlay = MKCircle()
    
    var circleRenderer = MKCircleRenderer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.delegate = self
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        self.locationManager.requestWhenInUseAuthorization()
        
        self.locationManager.startUpdatingLocation()
        
        mapView.delegate = self
        
        self.mapView.showsUserLocation = true
        
        self.mapView.mapType = .Standard
        
        self.radiusText.enabled = false
        
        //self.findEvents.layer.cornerRadius = 10
        
        if(exploreVenueList != nil){
            
            if tempSize != preferenceList.count {
                tempSize = preferenceList.count
                explore()
            }
            else{
                pinExploreVenuesList()
            }
        }
        
        if radius != nil && centerPoint != nil {
            radiusText.text = toString(radius)
            radiusSlider.value = Float(radius)
            //mapView.removeOverlays(mapView.overlays)
            
            //note: cllocationdistance is in meters
            mapView.addOverlay(MKCircle(centerCoordinate: centerPoint, radius: CLLocationDistance(Double(radius))))
        }
        

        //Remove keyboard on touch
        self.hideKeyboardWhenTappedAround()
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Delegate Methods
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let myLocation = locations.last
        
        centerPoint = CLLocationCoordinate2D(latitude: myLocation!.coordinate.latitude, longitude: myLocation!.coordinate.longitude)
        
        //let regionDistance:CLLocationDistance = 3300
        
        //let region = MKCoordinateRegion(center: centerPoint, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
        
        let region = MKCoordinateRegion(center: centerPoint, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.mapView.setRegion(region, animated: true)
        
        //self.locationManager.stopUpdatingLocation()

        if(xloc != myLocation!.coordinate.latitude || xloc == nil){
            xloc = myLocation!.coordinate.latitude
            yloc = myLocation!.coordinate.longitude
            //search()
            print("calling explore()")
            explore()

        }
        
    }
    
    
    func explore(){
        //Using foursquare api: "explore"
        
        //Setup for formatting date to use in foursquare api
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyymmdd"
        
        //format todays date to yymmdd format
        let date : String = dateFormatter.stringFromDate(NSDate())
        
        let baseURL : NSString = "https://api.foursquare.com/v2/venues/explore?ll="+toString(xloc)+","+toString(yloc) as NSString
        
        let creds : NSString = "&client_id="+fqClient_id+"&client_secret="+fqClient_secret+"&v="+date as NSString
        
        let radius : NSString = "&radius="+toString(radiusText.text)+"&limit=50" as NSString
        
        exploreImageCache = [String: NSData]()
        
        var first = true
        
        var t = 0

        for pref in preferenceList{
            let pref = pref["place_name"] as String
            let section : NSString = "&section=" + toString(pref) as NSString
            let venues : NSString = baseURL + creds + radius + section as NSString
            
            print(venues)
            
            //venues url
            let venuesURL = NSURL(string: venues)
            
            if let url = venuesURL {
                
                //create session
                let session = NSURLSession.sharedSession().dataTaskWithURL(url){ (data, response, error) -> Void in
                    let status_code = (response as NSHTTPURLResponse).statusCode
                    
                    if status_code == 200{
                        //check for content
                        if let urlContent = data{
                            
                            //convert to json
                            let jsondata = NSData(data: urlContent)
                            
                            let content = NSJSONSerialization.JSONObjectWithData(jsondata, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
                            
                            let response = content["response"] as NSDictionary
                            
                            let groups = response["groups"] as NSArray
                            
                            let items = groups[0] as NSDictionary
                            
                            //let venues = items["items"] as NSArray
                            let venues = items["items"] as NSMutableArray
                            
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                //print(venues)
                                print("\n\n")
                                if first {
                                    //exploreVenueList.addObject(venues)
                                    exploreVenueList = venues as NSMutableArray
                                    first = false
                                }
                                else{
                                    for i in venues{
                                        exploreVenueList.addObject(i)
                                    }
                                }
                                //print(t)
                                if t == preferenceList.count {
                                    self.pinExploreVenuesList()
                                }
                                //exploreImageCache = [String: NSData]()
                                //self.pinExploreVenuesList()
                                
                            })
                            
                            t += 1
                            
                            
                        }
                        
                    }
                    
                }
                session.resume()
                
                
            }
            
            
        }
        

    }
    
    func pinExploreVenuesList(){
        
        //remove all annotations
        mapView.removeAnnotations(mapView.annotations)

        //print("Start \n\n")

        
        if exploreVenueList != nil {
            
            for venue in exploreVenueList{
                //print(venue)
                //print("\n\n\n\n\n")
                
                var location = (venue["venue"] as NSDictionary)["location"] as NSDictionary
                
                var name = (venue["venue"] as NSDictionary)["name"] as String
                
                var category = ((venue["venue"] as NSDictionary)["categories"] as NSArray)[0] as NSDictionary
                var prefix = (category["icon"] as NSDictionary)["prefix"] as NSString
                var suffix = (category["icon"] as NSDictionary)["suffix"] as NSString
                var url = NSURL(string: prefix+"bg_512"+suffix)!
                var id = (venue["venue"] as NSDictionary)["id"] as NSString
                
                let session = NSURLSession.sharedSession().dataTaskWithURL(url){ (data, response, error) -> Void in
                    //if error == nil{
                    if (data != nil) {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            exploreImageCache[id] = data as NSData
                        })
                    }
                }
                session.resume()
                
                
                //get lattitude longitude
                var lat : CLLocationDegrees = location["lat"] as CLLocationDegrees
                var lng : CLLocationDegrees = location["lng"] as CLLocationDegrees
                
                //convert coordinate to CLLocationCoordinate2D type
                var newCoordinate : CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat, lng)
                
                //create new annotation for each venue
                var annotation = MKPointAnnotation()
                //var annotation = CustomPointAnnotation(pinColor: UIColor.purpleColor())
                annotation.coordinate = newCoordinate
                
                annotation.title = name
                
                //add annotation to the map
                mapView.addAnnotation(annotation)
                
                
                
            }
            
        }

    }
    

    
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Errors:" + error.localizedDescription)
    }
    
    
    
    
    // MARK: - Radius
    
    @IBAction func setARadius(sender: UISlider) {
        
        let slider = sender.value
        
        //Swift 2:
        //radiusText.text = String(slider)
        radiusText.text = toString(slider)
        
        radius = Double(slider)
        
        //update() or explore() call whenever radius is adjust
        //search()
        explore()
        
        mapView.removeOverlays(mapView.overlays)
        
        //note: cllocationdistance is in meters
        mapView.addOverlay(MKCircle(centerCoordinate: centerPoint, radius: CLLocationDistance(Double(slider))))

        
        
    }
    
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlay = overlay as? MKCircle {
            circleRenderer = MKCircleRenderer(circle: overlay)
            circleRenderer.fillColor = UIColor.purpleColor()
            circleRenderer.alpha = 0.2
            
        }
        return circleRenderer
    }

    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Nearby", style: .Plain, target: self, action: "nearbyTapped")
    }
    
    
    func nearbyTapped(){
        self.performSegueWithIdentifier("nearbyList", sender: nil)
    }
    
    
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    
    /*
  
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let annotationView = MKPinAnnotationView()
        
        annotationView.image = UIImage(named: "marker_purple.png")
        
        annotationView.canShowCallout = true
        
        
        // Resize image
        
        let pinImage = UIImage(named: "marker_purple.png")
        let height = pinImage?.size.height
        let width = pinImage?.size.width

        let size = CGSize(width: width!/3, height: height!/3)
        UIGraphicsBeginImageContext(size)
        pinImage!.drawInRect(CGRectMake(0, 0, size.width, size.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        annotationView.image = resizedImage

        
        return annotationView
    }
    */

}


