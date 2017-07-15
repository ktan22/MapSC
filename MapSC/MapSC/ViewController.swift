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

class ViewController: UIViewController,GMSMapViewDelegate,CLLocationManagerDelegate, UITextFieldDelegate {

    //The overall map view displaying google maps that is spliced across the screen
    lazy var mapView = GMSMapView()
    
    //Current location of user stored in a variable
    var curLocation = CLLocationCoordinate2D()
    var curHeading = 0.0
    
    //Location manager that keeps track of user location: from CoreLocation API
    var locationManager = CLLocationManager()
    
    //Custom image manager. When dealing with image processing, always make functions in this class and call 
    //from this variable
    let locationImageManager = LocationImageManager()
    
    //Not an IBOutlet, but still an object to be rendered on screen. Only difference is that it attaches itself onto
    //Google maps instead of the screen. UI for a brief descriptor of location inputed
    var marker = GMSMarker(position:CLLocationCoordinate2D(latitude: 0, longitude: 0))
    var polyline = GMSPolyline()
    
    //When a user fills out a destination, this variable gets populated with data. Used to make data collection easier
    var usc_location = UscLocation(name: "",address: "",abbreviation:"",id:"",coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0))
    
    //The other IBOutlets that fill up the page
    @IBOutlet weak var usc_location_image: UIImageView!
    @IBOutlet weak var navigate_button: UIButton!
    //@IBOutlet weak var search_button: UIButton!
    @IBOutlet weak var location_textfield: UITextField!
    @IBOutlet weak var view_segmented_control: UISegmentedControl!
    @IBOutlet weak var destination_label: UILabel!
    
    @IBOutlet weak var distance_duration_label: UILabel!
    
    //Variables that control functionality of menu
    var menu_showing = false
    @IBOutlet weak var menu: UIView!
    
    @IBOutlet weak var navigation_menu: UIView!
    @IBOutlet weak var menu_button_view: UIView!
    @IBOutlet weak var menu_constraint: NSLayoutConstraint!
    
    @IBOutlet weak var cancel_navigation_button: UIButton!
    @IBOutlet weak var current_location_button: UIButton!
    @IBOutlet weak var navigation_constraint: NSLayoutConstraint!
    //Navigation Variables
    
    @IBAction func navigation_button(_ sender: Any) {
        self.get_navigation()
        //navigate_button.setTitle("Start", for: .normal)
        //destination_label.isHidden = true

    }
    
    @IBAction func cancel_navigation_button_pressed(_ sender: Any) {
        set_default_values()
        if(grab_usc_locations(word: usc_location.abbreviation) == true)
        {
            destination_label.text = "("+usc_location.abbreviation + ") " + usc_location.name
            location_textfield.text = ""
            navigation_constraint.constant = 0
            UIView.animate(withDuration: 0.3, animations: { self.view.layoutIfNeeded()})
        }
    }
    @IBAction func current_location_button_pressed(_ sender: Any) {
        get_navigation()
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
    
    @IBAction func open_google_map_button_pressed(_ sender: Any) {
        
        let address_request = (usc_location.address).replacingOccurrences(of: " ", with: "+")
        let url = URL(string: "https://www.google.com/maps/search/?api=1&query=\(address_request)")!
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    
    @IBAction func ClearButtonPress(_ sender: Any) {
        set_default_values()
    }
    
    @IBAction func cancel_button_pressed_down_menu(_ sender: Any) {
        set_default_values()
    }
    
    //Action linked to the press of the "search" button: Take the contents of the text field
    //and try to get a USC location out of it using the usc_location.swift local database
    //If match not found, do nothing    
    func search()
    {
        let word = location_textfield.text
        
        if(word == "")
        {
            return
        }
        
        set_default_values()
        if(grab_usc_locations(word: word!) == true)
        {
            //navigate_button.isHidden = false
            destination_label.text = "("+usc_location.abbreviation + ") " + usc_location.name
            //destination_label.isHidden = false
            location_textfield.text = ""
            navigation_constraint.constant = 0
            UIView.animate(withDuration: 0.3, animations: { self.view.layoutIfNeeded()})
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        self.search()
        return true
    }
    
    
    //Function that happens when the view comes into play: Include all setup code here
    override func viewDidLoad() {
        super.viewDidLoad()
        location_textfield.returnKeyType =  UIReturnKeyType.search
        location_textfield.delegate = self;
        
        //Location manager initialization to get current location. Make sure to
        // set info.plist "Privacy - Location When In Use Usage Description" to enable the setting as well
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter=kCLDistanceFilterNone;
        locationManager.requestWhenInUseAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        
        //Setting initial camera to USC campus (34.0220386047, -118.2858178101) is hard coded value
        let camera = GMSCameraPosition.camera(withLatitude: 34.0220386047, longitude: -118.2858178101, zoom: 15.0)
        mapView = GMSMapView.map(withFrame: self.view.bounds, camera: camera)
        
        //Adding Google maps subview so that we can layer IBOutlets on top
        self.view.addSubview(mapView)
        
        //locationImageManager.make_button_circle(button: current_location_button)
        //IBOutlet layering hierarchy (Order does matter!)
        self.view.insertSubview(menu_button_view, aboveSubview: self.mapView)
        self.view.insertSubview(menu, aboveSubview: self.mapView)
        self.view.insertSubview(location_textfield, aboveSubview: self.mapView)
        location_textfield.autocorrectionType = .no
        //self.view.insertSubview(search_button, aboveSubview: self.mapView)
        //self.view.insertSubview(view_segmented_control, aboveSubview: self.mapView)
        //self.view.insertSubview(navigate_button, aboveSubview: self.mapView)
        //self.view.insertSubview(distance_duration_label, aboveSubview: self.mapView)
        self.view.insertSubview(navigation_menu, aboveSubview: self.mapView)
        self.view.insertSubview(current_location_button, aboveSubview: self.mapView)
        self.view.insertSubview(cancel_navigation_button, aboveSubview: self.mapView)
        
        //Make sure "navigate" button and "destination" label are hidden at first 
        //because user has not inputted anything yet
        //Also make sure menu is out of the picture because user has not hit menu button yet
        //navigate_button.isHidden = true
        //destination_label.isHidden = true
        menu_constraint.constant = -140
        navigation_constraint.constant = -230
        cancel_navigation_button.isHidden = true
        current_location_button.isHidden = true
    }
    
    //The location manager delegate called whenever user location is updated
    //just update the current position for curLocation as well as render it on screen
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let l = (self.locationManager.location?.coordinate)!
        curLocation = l
        //curLocation = CLLocationCoordinate2D(latitude: 34.0220386047, longitude: -118.2878178101) //For testing closer locations only
        mapView.isMyLocationEnabled = true
    }
    func locationManager(_ manager:CLLocationManager, didUpdateHeading heading: CLHeading){
        curHeading = Double(heading.magneticHeading)
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
        
        let address_request = (usc_location.address).replacingOccurrences(of: " ", with: "+")
        
        let get_request = "https://maps.googleapis.com/maps/api/geocode/json?address=\(address_request)&key=AIzaSyBIIkq2aJwHsjwujPSptKQXJeyCeQQvTjE"
        
        Alamofire.request(get_request).responseJSON
            { response in
                
                if let JSON = response.result.value
                {
                    let response: [String: AnyObject] = JSON as! [String : AnyObject]
                    let _results = (response["results"] as? Array) ?? []
                    let results = (_results.first as? Dictionary<String, AnyObject>) ?? [:]
                    let geometry = (results["geometry"] as? Dictionary<String, AnyObject>) ?? [:]
                    let location = (geometry["location"] as? Dictionary<String, AnyObject>) ?? [:]
                    
                    let lat = location["lat"] as! CLLocationDegrees
                    let long = location["lng"] as! CLLocationDegrees

                    //place picker
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    self.usc_location.coordinate = coordinate
                    //let icon_image = self.locationImageManager.setImage(parameter: self.usc_location, image_name: "speechbubble")
                    let pic_image = UIImage(named: self.usc_location.abbreviation)
                    
                    self.usc_location_image.image = pic_image
                    
                    self.marker.map = nil
                    self.marker = GMSMarker(position:coordinate)
                    self.marker.title = self.usc_location.address
                    //self.marker.icon = icon_image
                    self.marker.map = self.mapView
                    
                    //let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: long, zoom: 18.0)
                    //self.mapView.animate(to: camera)
                    
                    let source_lat = self.curLocation.latitude
                    let source_long = self.curLocation.longitude
                    let dest_lat = self.usc_location.coordinate.latitude
                    let dest_long = self.usc_location.coordinate.longitude
                    
                    let get_request_2 = "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=\(source_lat),\(source_long)&destinations=\(dest_lat),\(dest_long)&key=AIzaSyDZ4PsIpEVmrBXBMsXmotfl_h1bvG_gLvk"
                    
                    Alamofire.request(get_request_2).responseJSON
                        { response in
                            
                            if let JSON = response.result.value
                            {
                                let mapResponse: [String: AnyObject] = JSON as! [String : AnyObject]
                                let rows_array = (mapResponse["rows"] as? Array) ?? []
                                let rows_map = (rows_array.first as? Dictionary<String, AnyObject>) ?? [:]
                                let element_array = (rows_map["elements"] as? Array) ?? []
                                let element_map = (element_array.first as? Dictionary<String, AnyObject>) ?? [:]
                                
                                
                                
                                // let duration_map = (duration_array.first as? Dictionary<String, AnyObject>) ?? [:]
                                //let distance_array = (element_map["distance"] as? Array) ?? []
                                //let distance_map = (distance_array.first as? Dictionary<String, AnyObject>) ?? [:]
                                let duration_map = element_map["duration"] as! Dictionary<String, AnyObject>
                                let distance_map = element_map["distance"] as! Dictionary<String, AnyObject>
                                let distance = distance_map["text"] as! String
                                let duration = duration_map["text"] as! String
                                
                                self.distance_duration_label.text = distance + "\n(" + duration + ")"
                                
                            }
                            
                    }
                    
                    let get_request3 = "https://maps.googleapis.com/maps/api/directions/json?origin=\(source_lat),\(source_long)&destination=\(dest_lat),\(dest_long)&mode=walking&key=AIzaSyC-FtOPLb_MO38GqZcOLk7swhzabZbO8lQ"
                    
                    Alamofire.request(get_request3).responseJSON
                        { response in
                            
                            if let JSON = response.result.value
                            {
                                let mapResponse: [String: AnyObject] = JSON as! [String : AnyObject]
                                let routesArray = (mapResponse["routes"] as? Array) ?? []
                                let routes = (routesArray.first as? Dictionary<String, AnyObject>) ?? [:]
                                
                                //print(duration["text"])
                                
                                let overviewPolyline = (routes["overview_polyline"] as? Dictionary<String,AnyObject>) ?? [:]
                                let polypoints = (overviewPolyline["points"] as? String) ?? ""
                                let line  = polypoints
                                
                                self.addPolyLine(encodedString: line)
                                
                            }
                            
                    }
                    
                    
                    
                }
                
        }
        
        return true
            
    }
    
    //Set the default values back. Put all default code every search here (NOT INITIALIZATION)
    //TODO: Add more default values here: (i.e. path line etc. -basically, whatever needs to be cleared)
    func set_default_values()
    {
        //navigate_button.isHidden = true
        //destination_label.isHidden = true
        marker.map = nil
        
        close_menus()
        
        polyline.map = nil
        distance_duration_label.text = ""
        self.menu_showing = false
        cancel_navigation_button.isHidden = true
        current_location_button.isHidden = true
    }
    
    func get_navigation()
    {
        let camera = GMSCameraPosition.camera(withLatitude: self.curLocation.latitude, longitude: self.curLocation.longitude, zoom: 18.0,bearing:curHeading, viewingAngle: 55)
        self.mapView.animate(to: camera)
        close_menus()
        cancel_navigation_button.isHidden = false
        current_location_button.isHidden = false
    }
    
    
    
    func close_menus()
    {
        menu_constraint.constant = -140
        navigation_constraint.constant = -230
        UIView.animate(withDuration: 0.3, animations: { self.view.layoutIfNeeded()})
    }
    
    func addPolyLine(encodedString: String) {
        
        let path = GMSMutablePath(fromEncodedPath: encodedString)
        //print(encodedString)
        
        polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 5
        polyline.strokeColor = .blue
        polyline.map = mapView
        
        //shift camera
        let bounds = GMSCoordinateBounds(path: path!)
        self.mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 100.0))
        
    }
    
    
    
    
}




