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
        
        // Do any additional setup after loading the view.
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Delegate Methods
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let myLocation = locations.last
        
        centerPoint = CLLocationCoordinate2D(latitude: myLocation!.coordinate.latitude, longitude: myLocation!.coordinate.longitude)
        
        let regionDistance:CLLocationDistance = 3300
        
        let region = MKCoordinateRegion(center: centerPoint, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        
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
        //venues search using userless access
        
        //let venues : NSString = "https://api.foursquare.com/v2/venues/search?ll=40.7,-74&client_id=XC5G1YSZQWRNB0UH1VMDAMKZWX453N1IPUHWNO1XHG5AC3VH&client_secret=5XGRVKYPGJHPK5NGODYBTI2GKQU2JUMJQMAXYMTS2TTZ3RXX&v=20160331"
        
        //let venues : NSString = "https://api.foursquare.com/v2/venues/search?ll=40.7,-74&client_id="+fqClient_id+"&client_secret="+fqClient_secret+"&v=20160331" as NSString
        
        let p1 : NSString = "https://api.foursquare.com/v2/venues/search?ll="+toString(xloc)+","+toString(yloc) as NSString
        
        let p2 : NSString = "&client_id="+fqClient_id+"&client_secret="+fqClient_secret+"&v=20160331" as NSString
        
        let venues : NSString = p1 + p2 as NSString
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
                        })
                        
                    }
                    
                }
            }
            session.resume()
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
        
        mapView.removeOverlays(mapView.overlays)
        
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
    
    /*
    @IBAction func DrawCircle(sender: UIButton) {
    
    //let radius:CLLocationDistance = (Double)radiusText.text
    
    let radiusCircle:CLLocationDistance = Double(radiusSlider.value)
    
    // mapView.removeOverlay(MKCircle(centerCoordinate: centerPoint, radius: radius))
    
    mapView.addOverlay(MKCircle(centerCoordinate: centerPoint, radius: radiusCircle))
    
    
    }*/
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
