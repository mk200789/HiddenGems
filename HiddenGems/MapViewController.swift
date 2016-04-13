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
    var centerPoint : CLLocationCoordinate2D!
    
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
            update()
            print("calling update()")

        }
        
    }
    
    
    func update(){
        //Using foursquare api: "search" - venues search using userless access
        
        //Setup for formatting date to use in foursquare api
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyymmdd"
        
        //format todays date to yymmdd format
        let date : String = dateFormatter.stringFromDate(NSDate())
        
        let baseURL : NSString = "https://api.foursquare.com/v2/venues/search?ll="+toString(xloc)+","+toString(yloc) as NSString
        
        let creds : NSString = "&client_id="+fqClient_id+"&client_secret="+fqClient_secret+"&v="+date as NSString
        
        let radius : NSString = "&radius="+toString(radiusText.text)+"&intent=browse" as NSString
        
        let venues : NSString = baseURL + creds + radius as NSString
        
        //print(venues)
        
        //venues url
        let venuesURL = NSURL(string: venues)
        
        if let url = venuesURL {
            
            //create session
            let session = NSURLSession.sharedSession().dataTaskWithURL(url){ (data, response, error) -> Void in
                let status_code = (response as NSHTTPURLResponse).statusCode
                
                if status_code == 200{
                    print("success!")
                    
                    //check for content
                    if let urlContent = data{
                        
                        //convert to json
                        let jsondata = NSData(data: urlContent)
                        
                        let content = NSJSONSerialization.JSONObjectWithData(jsondata, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
                        
                        
                        let data = content["response"] as NSDictionary
                        
                        let jsonVenue = data["venues"] as [NSDictionary]
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            venueList = data["venues"] as [NSDictionary]
                            print("hello")
                            self.pinUpdates()
                        })
                        
                    }
                    
                }
            }
            session.resume()
        }
    }
    
    func pinUpdates(){
        
        //remove all annotations
        mapView.removeAnnotations(mapView.annotations)
        
        for venue in venueList{
            var location = venue["location"] as NSDictionary
            
            //get lattitude longitude
            var lat : CLLocationDegrees = location["lat"] as CLLocationDegrees
            var lng : CLLocationDegrees = location["lng"] as CLLocationDegrees
            
            //convert coordinate to CLLocationCoordinate2D type
            var newCoordinate : CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat, lng)
            
            //create new annotation for each venue
            var annotation = MKPointAnnotation()
            annotation.coordinate = newCoordinate
            annotation.title = venue["name"] as String
            
            //add annotation to the map
            mapView.addAnnotation(annotation)
            
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
        
        //update()call whenever radius is adjust
        update()
        
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
        print("performed!")
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
    
}


class CustomPointAnnotation : MKPointAnnotation {
    var imageName : String = "marker_purple.png" as String
}
