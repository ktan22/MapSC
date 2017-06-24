//
//  ViewController.swift
//  MapSC
//
//  Created by Kyle Tan on 6/11/17.
//  Copyright © 2017 BITS. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import Alamofire
import GooglePlacePicker

class ViewController: UIViewController,GMSMapViewDelegate,CLLocationManagerDelegate {

    //The overall map view displaying google maps that is spliced across the screen
    lazy var mapView = GMSMapView()
    
    //Current location of user stored in a variable
    var curLocation = CLLocationCoordinate2D()
    
    //Location manager that keeps track of user location: from CoreLocation API
    var locationManager = CLLocationManager()
    
    //Custom image manager. When dealing with image processing, always make functions in this class and call 
    //from this variable
    let locationImageManager = LocationImageManager()
    
    //Not an IBOutlet, but still an object to be rendered on screen. Only difference is that it attaches itself onto
    //Google maps instead of the screen. UI for a brief descriptor of location inputed
    var marker = GMSMarker(position:CLLocationCoordinate2D(latitude: 0, longitude: 0))
    
    //When a user fills out a destination, this variable gets populated with data. Used to make data collection easier
    var usc_location = UscLocation(name: "",address: "",abbreviation:"",id:"",coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0))
    
    //The other IBOutlets that fill up the page
    @IBOutlet weak var navigate_button: UIButton!
    @IBOutlet weak var search_button: UIButton!
    @IBOutlet weak var location_textfield: UITextField!
    @IBOutlet weak var view_segmented_control: UISegmentedControl!
    @IBOutlet weak var destination_label: UILabel!
    
    //Variables that control functionality of menu
    var menu_showing = false
    @IBOutlet weak var menu: UIView!
    @IBOutlet weak var menu_button_view: UIView!
    @IBOutlet weak var menu_constraint: NSLayoutConstraint!

    
    @IBAction func navigation_button(_ sender: Any) {
        let dest = usc_location.coordinate;
        self.get_navigation(source: curLocation, dest: usc_location.coordinate)
    }
    
    
    //Action Linked to the press of the "menu" button: Pushes the menu view onto the screen with animation.
    //Because every other IBOutlet is built in relationship to this menu view, when it gets pushed out
    //All other objects also get pushed.
    @IBAction func menu_button(_ sender: Any) {
        if(!menu_showing){
            menu_constraint.constant = 0
            UIView.animate(withDuration: 0.3, animations: { self.view.layoutIfNeeded()})
        }
        else {
            menu_constraint.constant = -140
            UIView.animate(withDuration: 0.3, animations: { self.view.layoutIfNeeded()})
        }
        menu_showing = !menu_showing
    }
    
    //Linked to the "USC/ME" segmented view: Just changes the camera view based on which option selected
    //USC: The USC campus, ME: Current location
    @IBAction func switchViews(_ sender: Any) {
        switch view_segmented_control.selectedSegmentIndex {
        case 0:
            //USC latitude: 34.0220386047, USC longitude:-118.2858178101
            let camera = GMSCameraPosition.camera(withLatitude: 34.0220386047, longitude: -118.2858178101, zoom: 15.0)
            mapView.animate(to: camera)
        case 1:
            let camera = GMSCameraPosition.camera(withLatitude: curLocation.latitude, longitude: curLocation.longitude, zoom: 18.0)
            mapView.animate(to: camera)
        default:
            break;
        }
    }
    
    //Action linked to the press of the "search" button: Take the contents of the text field
    //and try to get a USC location out of it using the usc_location.swift local database
    //If match not found, do nothing
    @IBAction func search(_ sender: Any) {
        let word = location_textfield.text
        
        if(grab_usc_locations(word: word!) == true)
        {
            navigate_button.isHidden = false
            
            destination_label.text = "to " + usc_location.abbreviation
            destination_label.isHidden = false
        }
        else{
            set_default_values()
        }
    }
    
    //Function that happens when the view comes into play: Include all setup code here
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Location manager initialization to get current location. Make sure to
        // set info.plist "Privacy - Location When In Use Usage Description" to enable the setting as well
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter=kCLDistanceFilterNone;
        locationManager.requestWhenInUseAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.startUpdatingLocation()
        
        //Setting initial camera to USC campus (34.0220386047, -118.2858178101) is hard coded value
        let camera = GMSCameraPosition.camera(withLatitude: 34.0220386047, longitude: -118.2858178101, zoom: 18.0)
        mapView = GMSMapView.map(withFrame: self.view.bounds, camera: camera)
        
        //Adding Google maps subview so that we can layer IBOutlets on top
        self.view.addSubview(mapView)
        
        //IBOutlet layering hierarchy (Order does matter!)
        self.view.insertSubview(menu_button_view, aboveSubview: self.mapView)
        self.view.insertSubview(menu, aboveSubview: self.mapView)
        self.view.insertSubview(location_textfield, aboveSubview: self.mapView)
        self.view.insertSubview(search_button, aboveSubview: self.mapView)
        self.view.insertSubview(view_segmented_control, aboveSubview: self.mapView)
        self.view.insertSubview(navigate_button, aboveSubview: self.mapView)
        self.view.insertSubview(destination_label, aboveSubview: self.mapView)
        
        //Make sure "navigate" button and "destination" label are hidden at first 
        //because user has not inputted anything yet
        //Also make sure menu is out of the picture because user has not hit menu button yet
        navigate_button.isHidden = true
        destination_label.isHidden = true
        menu_constraint.constant = -140
    }
    
    //The location manager delegate called whenever user location is updated
    //just update the current position for curLocation as well as render it on screen
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let l = (self.locationManager.location?.coordinate)!
        //curLocation = l
        curLocation = CLLocationCoordinate2D(latitude: 34.1220386047, longitude: -118.2878178101)
        mapView.isMyLocationEnabled = true
    }
    
    //Search local usc building database for input string
    //If match, then update usc_location variable with information
    //If no match, then return false
    func grab_usc_locations(word: String) -> Bool
    {
        if(ConstantMap.usc_map[word.uppercased()] == nil)
        {
            print("Location not found at USC. Try Again.")
            return false
        }
        
        let dict = ConstantMap.usc_map[word.uppercased()]!
        
        let lookup_address = dict["address"]!
        let lookup_name = dict["name"]!
        let lookup_id = dict["id"]!
        let lookup_abbreviation = word.uppercased()
        
        usc_location.name = lookup_name
        usc_location.address = lookup_address
        usc_location.id = lookup_id
        usc_location.abbreviation = lookup_abbreviation
        
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(lookup_address) { (placemarks, error) in
                let location = placemarks?.first?.location
                
                let long = location?.coordinate.longitude
                let lat = location?.coordinate.latitude
            
                //place picker
                let coordinate = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
                self.usc_location.coordinate = coordinate
                let icon_image = self.locationImageManager.setImage(parameter: self.usc_location, image_name: "speechbubble")
            
                self.marker.map = nil
                self.marker = GMSMarker(position:coordinate)
                self.marker.title = self.usc_location.name
                self.marker.icon = icon_image
                self.marker.map = self.mapView
            
                let camera = GMSCameraPosition.camera(withLatitude: lat!, longitude: long!, zoom: 18.0)
                self.mapView.animate(to: camera)
            }
        
        return true
            
    }
    
    //Set the default values back. Put all default code every search here (NOT INITIALIZATION)
    func set_default_values()
    {
        navigate_button.isHidden = true
        destination_label.isHidden = true
        marker.map = nil
    }
    
    func get_navigation(source : CLLocationCoordinate2D, dest :CLLocationCoordinate2D)
    {
        let source_long = "\(source.longitude)"
        let source_lat = "\(source.latitude)"
        let dest_long = "\(dest.longitude)"
        let dest_lat = "\(dest.latitude)"
        
        let get_request = "https://maps.googleapis.com/maps/api/directions/json?origin=\(source_lat),\(source_long)&destination=\(dest_lat),\(dest_long)&key=AIzaSyC-FtOPLb_MO38GqZcOLk7swhzabZbO8lQ"
    
        Alamofire.request(get_request).responseJSON
        { response in
                // print response as string for debugging, testing, etc.
                //let data = response.result.value as String
            if let JSON = response.result.value
            {
                let mapResponse: [String: AnyObject] = JSON as! [String : AnyObject]
                let routesArray = (mapResponse["routes"] as? Array) ?? []
                let routes = (routesArray.first as? Dictionary<String, AnyObject>) ?? [:]
                
                let overviewPolyline = (routes["overview_polyline"] as? Dictionary<String,AnyObject>) ?? [:]
                let polypoints = (overviewPolyline["points"] as? String) ?? ""
                let line  = polypoints
                
                self.addPolyLine(encodedString: line)
            }
            
        }
    }
    
    func addPolyLine(encodedString: String) {
        
        let path = GMSMutablePath(fromEncodedPath: encodedString)
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 5
        polyline.strokeColor = .blue
        polyline.map = mapView
        
    }
    
    
    
}




