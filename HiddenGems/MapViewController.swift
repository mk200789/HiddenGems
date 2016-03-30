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

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    
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
        
        let region = MKCoordinateRegionMakeWithDistance(centerPoint, regionDistance, regionDistance)
        
       // let region = MKCoordinateRegion(center: centerPoint, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
        
        self.mapView.setRegion(region, animated: true)
        
        self.locationManager.stopUpdatingLocation()
        
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
        
        print(radiusSlider.value)
    }
    
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlay = overlay as? MKCircle {
            circleRenderer = MKCircleRenderer(circle: overlay)
            circleRenderer.fillColor = UIColor.purpleColor()
            circleRenderer.alpha = 0.2
            
        }
        return circleRenderer
    }
    
    
    @IBAction func DrawCircle(sender: UIButton) {
        
        //let radius:CLLocationDistance = (Double)radiusText.text
        
        let radiusCircle:CLLocationDistance = Double(radiusSlider.value)
        
       // mapView.removeOverlay(MKCircle(centerCoordinate: centerPoint, radius: radius))
        
        mapView.addOverlay(MKCircle(centerCoordinate: centerPoint, radius: radiusCircle))

}
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
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
