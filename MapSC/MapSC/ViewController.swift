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
    var cur_user_location = CLLocationCoordinate2D()
    var cur_phone_angle = 0.0
    var directory_string = ""
    
    
    //Location manager that keeps track of user location: from CoreLocation API
    var location_manager = CLLocationManager()
    
    //Custom image manager. When dealing with image processing, always make functions in this class and call 
    //from this variable
    let location_image_manager = LocationImageManager()
    
    //Not an IBOutlet, but still an object to be rendered on screen. Only difference is that it attaches itself onto
    //Google maps instead of the screen. UI for a brief descriptor of location inputed
    var marker = GMSMarker(position:CLLocationCoordinate2D(latitude: 0, longitude: 0))
    var polyline = GMSPolyline()
    
    //When a user fills out a destination, this variable gets populated with data. Used to make data collection easier
    var usc_location = UscLocation()
    
    //The other IBOutlets that fill up the page
    
    @IBOutlet weak var content_label: UILabel!
    
    
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
    
    //BUTTONS
    @IBAction func dining_filter_button_pressed(_ sender: Any) {
        filter(with: "DINING")
    }
    @IBAction func village_filter_button_pressed(_ sender: Any) {
        filter(with: "VILLAGE")
    }
    
    @IBAction func athletics_filter_button_pressed(_ sender: Any) {
        filter(with: "ATHLETICS")
    }
    
    @IBAction func libraries_filter_button_pressed(_ sender: Any) {
        filter(with: "LIBRARIES")
    }
    
    //Tapping on marker function
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        let name = marker.title!
        let type = marker.snippet!
        
        var map_to_use = ConstantMap.usc_dining
        if(type == "athletics")
        {
            map_to_use = ConstantMap.usc_athletics
        }
        else if(type == "libraries")
        {
            map_to_use = ConstantMap.usc_libraries
        }
        else if(type == "village")
        {
            map_to_use = ConstantMap.usc_village
        }
        
        for location in map_to_use
        {
            let location_map = ConstantMap.usc_map[location]!
            if(String(name) == String(describing: location_map["name"]!))
            {
                let code = location
                let lat = Double(location_map["lat"]!)
                let long = Double(location_map["lng"]!)
                let image_name = String(describing: location_map["image"]!)
                let loc_name = String(describing: location_map["name"]!)
                let content = String(describing: location_map["content"]!)
                //let coordinate = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
                
                //self.marker = marker
                //marker.tracksInfoWindowChanges = true
                let coordinate = CLLocationCoordinate2D(latitude: lat as! CLLocationDegrees, longitude: long as! CLLocationDegrees)
                self.usc_location.set_up_values(name: loc_name, address: "", abbreviation: code, id: "", coordinate: coordinate, content: content, image_named: image_name)
                self.display_dest_usc_location_info_using_lat_long()
                return true
            }
        }

        return true
    }
    
    @objc(mapView:didTapAtCoordinate:) func mapView(_ mapView: GMSMapView, didTapAt didTapAtCoordinate: CLLocationCoordinate2D) {
        print("lat :\(didTapAtCoordinate.latitude)")
        print("long :\(didTapAtCoordinate.longitude)")
    }
    

    @IBAction func simple_guidance_button_down_menu_pressed(_ sender: Any) {
        self.orient_simple_navigation()
    }
    
    @IBAction func cancel_button_during_navigation_pressed(_ sender: Any) {
        set_default_values()
        
        move_camera_to(to: "ME")
        
        display_dest_usc_location_info_using_lat_long()
        //destination_label.text = "("+usc_location.abbreviation + ") " + usc_location.name
        location_textfield.text = ""
        navigation_constraint.constant = 0
        UIView.animate(withDuration: 0.3, animations: { self.view.layoutIfNeeded()})
    }

    @IBAction func orient_button_during_navigation_pressed(_ sender: Any) {
        self.orient_simple_navigation()
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
    @IBAction func switch_views_segmented_control_touched(_ sender: Any) {
        switch view_segmented_control.selectedSegmentIndex {
        case 0:
            move_camera_to(to: "USC")
        case 1:
            move_camera_to(to: "ME")
        case 2:
            move_camera_to(to: "HSC")
        default:
            break;
        }
    }
    
    @IBAction func open_google_map_button_pressed(_ sender: Any) {
        
        //let address_request = (usc_location.address).replacingOccurrences(of: " ", with: "+")
        //let url = URL(string: "https://www.google.com/maps/search/?api=1&query=\(address_request)")!
        let url = URL(string: "https://www.google.com/maps/search/?api=1&query=\(usc_location.coordinate.latitude),\(usc_location.coordinate.longitude)")
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url!)
        }
    }
    
    @IBAction func clear_button_pressed_side_menu(_ sender: Any) {
        set_default_values()

    }
    
    @IBAction func cancel_button_pressed_down_menu(_ sender: Any) {
        set_default_values()
    }
    
    //Action linked to the press of the "search" button: Take the contents of the text field
    //and try to get a USC location out of it using the usc_location.swift local database
    //If match not found, do nothing    
    func search_from_text_field()
    {
        let word = location_textfield.text
        if(word == "")
        {
            return
        }
        
        set_default_values()
        if(!get_lat_long_from_dest_address_in_usc_map(word: word!))
        {
            print("Location not found at USC. Try Again.")
        }
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        self.search_from_text_field()
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let search = UserDefaults.standard.string(forKey: "directory_search")
        if((search) != nil)
        {
            set_default_values()
            print("SEARCH: " + search!)
            get_lat_long_from_dest_address_in_usc_map(word: search!)
            UserDefaults.standard.removeObject(forKey: "directory_search")
        }
    }

    
    
    //Function that happens when the view comes into play: Include all setup code here
    override func viewDidLoad() {
        super.viewDidLoad()
        location_textfield.returnKeyType =  UIReturnKeyType.search
        location_textfield.delegate = self;
        
        //Location manager initialization to get current location. Make sure to
        // set info.plist "Privacy - Location When In Use Usage Description" to enable the setting as well
        location_manager.delegate = self
        location_manager.desiredAccuracy = kCLLocationAccuracyBest
        location_manager.distanceFilter=kCLDistanceFilterNone;
        location_manager.requestWhenInUseAuthorization()
        location_manager.startMonitoringSignificantLocationChanges()
        location_manager.startUpdatingLocation()
        location_manager.startUpdatingHeading()
        
        
        //Setting initial camera to USC campus (34.0220386047, -118.2858178101) is hard coded value
        let camera = GMSCameraPosition.camera(withLatitude: 34.0220386047, longitude: -118.2858178101, zoom: 15.0)
        mapView = GMSMapView.map(withFrame: self.view.bounds, camera: camera)
        
        //Adding Google maps subview so that we can layer IBOutlets on top
        self.view.addSubview(mapView)
        
        //locationImageManager.make_button_circle(button: current_location_button)
        //IBOutlet layering hierarchy (Order does matter!)
        self.view.insertSubview(menu_button_view, aboveSubview: self.mapView)
        self.view.insertSubview(menu, aboveSubview: self.mapView)
        //self.view.insertSubview(location_textfield, aboveSubview: self.mapView)
        location_textfield.autocorrectionType = .no
        self.view.insertSubview(navigation_menu, aboveSubview: self.mapView)
        self.view.insertSubview(current_location_button, aboveSubview: self.mapView)
        self.view.insertSubview(cancel_navigation_button, aboveSubview: self.mapView)
        
        //Make sure "navigate" button and "destination" label are hidden at first 
        //because user has not inputted anything yet
        //Also make sure menu is out of the picture because user has not hit menu button yet
        menu_constraint.constant = -140
        navigation_constraint.constant = -230
        cancel_navigation_button.isHidden = true
        current_location_button.isHidden = true
        mapView.delegate = self
    }
    
    //The location manager delegate called whenever user location is updated
    //just update the current position for curLocation as well as render it on screen
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let l = (self.location_manager.location?.coordinate)!
        cur_user_location = l
        cur_user_location = CLLocationCoordinate2D(latitude: 34.0220386047, longitude: -118.2878178101) //For testing closer locations only
        mapView.isMyLocationEnabled = true
    }
    
    //To track direction phone is facing
    func locationManager(_ manager:CLLocationManager, didUpdateHeading heading: CLHeading){
        cur_phone_angle = Double(heading.magneticHeading)
    }
    
    //looks through the location database to find a match for user's search input
    func find_usc_location(word: String) -> String
    {
        var location = ""   //holds key of the desired location
        
        // Create a CharacterSet of delimiters to parse user search input
        let separators = CharacterSet(charactersIn: ":,-, ,(,),,")
        let trimmed_word = word.trimmingCharacters(in: .whitespaces)
        var search_words : [String] = trimmed_word.components(separatedBy: separators)
        
        //exclude empty words
        search_words = search_words.filter {
            (x) -> Bool in !x.isEmpty
        }
        
        //print(search_words)
        
        //check for match with building code first
        if (ConstantMap.usc_map[word.uppercased()] != nil) {
            location = word.uppercased()
            return location
        }
        
        
        //check if id is exact match for *one word* search inputs only to avoid
        //mixing up with building addresses
        if (search_words.count == 1) {
            for (key, value) in ConstantMap.usc_map {
                if (value["id"] == search_words[0]) {
                    location = key
                    return location
                }
            }
        }
        
        //iterate through database to check each location's address and name for a match
        for (key, value) in ConstantMap.usc_map {
            var found = true
            var address : [String] = value["address"]!.lowercased().components(separatedBy: separators)
            address = address.filter { (x) -> Bool in !x.isEmpty }
            var name : [String] = value["name"]!.lowercased().components(separatedBy: separators)
            name = name.filter { (x) -> Bool in !x.isEmpty }
            print(name)
            
            //check if location contains exact match of all words in user's search input
            for word in search_words {
                print(word)
                if (address.contains(word.lowercased()) || name.contains(word.lowercased())) {
                    continue
                }
                else {
                    found = false
                    break
                }
            }
            
            //found an exact match
            if (found) {
                location = key;
                return location;
            }
        }
        
        //look for nonexact match if no exact match was found
        for (key, value) in ConstantMap.usc_map {
            var found = true
            for word in search_words {
                if (value["address"]!.lowercased().range(of:word.lowercased()) != nil) {
                    continue
                }
                else if (value["name"]!.lowercased().range(of:word.lowercased()) != nil) {
                    continue
                }
                else {
                    found = false
                    break
                }
            }
            if (found) {
                location = key
                return location
            }
        }
        return location
    }
    
    //Search local usc building database for input string
    //If match, then update usc_location variable with information
    //If no match, then return false
    func get_lat_long_from_dest_address_in_usc_map(word: String) -> Bool
    {
        let matched_key = find_usc_location(word: word)
        
        //exist function if no location was found
        if (matched_key == "") {
            print("Location not found at USC. Try Again.")
            return false
        }
        
        let dict = ConstantMap.usc_map[matched_key]!
        
        let lookup_address = dict["address"]!
        let lookup_name = dict["name"]!
        let lookup_id = dict["id"]!
        let lookup_abbreviation = matched_key
        let lookup_lat = Double(dict["lat"]!)
        let lookup_lng = Double(dict["lng"]!)
        let lookup_content = dict["content"]!
        let lookup_image = dict["image"]!
        let coordinate = CLLocationCoordinate2D(latitude: lookup_lat as! CLLocationDegrees, longitude: lookup_lng as! CLLocationDegrees)
        
        self.usc_location.set_up_values(name: lookup_name, address: lookup_address, abbreviation: lookup_abbreviation, id: lookup_id, coordinate: coordinate, content: lookup_content, image_named: lookup_image)
        self.display_dest_usc_location_info_using_lat_long()
        self.move_camera_to(to: "DEST") // maybe change later
        
        
        return true
            
    }
    
    //Set the default values back. Put all default code every search here (NOT INITIALIZATION)
    //TODO: Add more default values here: (i.e. path line etc. -basically, whatever needs to be cleared)
    func set_default_values()
    {
        //navigate_button.isHidden = true
        //destination_label.isHidden = true
        //self.usc_location.clear_values()
        marker.map = nil
        close_side_and_bottom_menus()
        location_textfield.text = ""
        polyline.map = nil
        distance_duration_label.text = ""
        self.menu_showing = false
        cancel_navigation_button.isHidden = true
        current_location_button.isHidden = true
        self.mapView.clear()
        self.content_label.text = ""
    }
    
    func orient_simple_navigation()
    {
        close_side_and_bottom_menus()
        move_camera_to(to: "NAVIGATION")
        cancel_navigation_button.isHidden = false
        current_location_button.isHidden = false
    }
    
    func move_camera_to(to: String)
    {
        if(to == "USC")
        {
            //USC latitude: 34.0220386047, USC longitude:-118.2858178101
            let camera = GMSCameraPosition.camera(withLatitude: 34.0220386047, longitude: -118.2858178101, zoom: 15.0)
            mapView.animate(to: camera)
        }
        else if(to == "ME")
        {
            let camera = GMSCameraPosition.camera(withLatitude: cur_user_location.latitude, longitude: cur_user_location.longitude, zoom: 18.0)
            mapView.animate(to: camera)
        }
        else if(to == "NAVIGATION")
        {
            let camera = GMSCameraPosition.camera(withLatitude: self.cur_user_location.latitude, longitude: self.cur_user_location.longitude, zoom: 18.0,bearing:cur_phone_angle, viewingAngle: 45)
            self.mapView.animate(to: camera)
        }
        else if(to == "DEST")
        {
            let camera = GMSCameraPosition.camera(withLatitude: self.usc_location.coordinate.latitude, longitude: self.usc_location.coordinate.longitude, zoom: 18.0)
            self.mapView.animate(to: camera)
        }
        else if(to == "HSC")
        {
            let camera = GMSCameraPosition.camera(withLatitude: 34.0595, longitude: -118.2082, zoom: 15.0)
            self.mapView.animate(to: camera)
        }
    }
    
    func filter(with: String)
    {
        move_camera_to(to: "USC")
        set_default_values()
        
        if (with == "DINING")
        {
            for location in ConstantMap.usc_dining
            {
                let location_map = ConstantMap.usc_map[location]
                let name = location_map?["name"]
                let type = location_map?["type"]
                let lat = CLLocationDegrees((location_map?["lat"]!)!)
                let long = CLLocationDegrees((location_map?["lng"]!)!)
                let marker_dining = GMSMarker(position: CLLocationCoordinate2D(latitude: lat!, longitude: long!))
                marker_dining.title = name
                marker_dining.map = self.mapView
                marker_dining.snippet = type
            }
        }
        else if (with == "VILLAGE")
        {
            for location in ConstantMap.usc_village
            {
                let location_map = ConstantMap.usc_map[location]
                let name = location_map?["name"]
                let type = location_map?["type"]
                let lat = CLLocationDegrees((location_map?["lat"]!)!)
                let long = CLLocationDegrees((location_map?["lng"]!)!)
                print(lat!)
                let marker_village = GMSMarker(position: CLLocationCoordinate2D(latitude: lat!, longitude: long!))
                marker_village.title = name
                marker_village.map = self.mapView
                marker_village.snippet = type
            }
        }
        else if (with == "ATHLETICS")
        {
            for location in ConstantMap.usc_athletics
            {
                let location_map = ConstantMap.usc_map[location]
                let name = location_map?["name"]
                let type = location_map?["type"]
                let lat = CLLocationDegrees((location_map?["lat"]!)!)
                let long = CLLocationDegrees((location_map?["lng"]!)!)
                let marker_dining = GMSMarker(position: CLLocationCoordinate2D(latitude: lat!, longitude: long!))
                marker_dining.title = name
                marker_dining.map = self.mapView
                marker_dining.snippet = type
            }
        }
        else if (with == "LIBRARIES")
        {
            for location in ConstantMap.usc_libraries
            {
                let location_map = ConstantMap.usc_map[location]
                let name = location_map?["name"]
                let type = location_map?["type"]
                let lat = CLLocationDegrees((location_map?["lat"]!)!)
                let long = CLLocationDegrees((location_map?["lng"]!)!)
                let marker_dining = GMSMarker(position: CLLocationCoordinate2D(latitude: lat!, longitude: long!))
                marker_dining.title = name
                marker_dining.map = self.mapView
                marker_dining.snippet = type
            }
        }
        
    }
    
    //make sure usc_location is set before calling this function!
    func display_dest_usc_location_info_using_lat_long()
    {
        let source_lat = self.cur_user_location.latitude
        let source_long = self.cur_user_location.longitude
        let dest_lat = self.usc_location.coordinate.latitude
        let dest_long = self.usc_location.coordinate.longitude
        
        //placing marker down
        self.marker = GMSMarker(position:usc_location.coordinate)
        self.marker.title = self.usc_location.address
        self.marker.map = self.mapView
        
        //display content and location image, if possible
        self.content_label.text = self.usc_location.content
        let pic_image = UIImage(named: self.usc_location.image_named)
        self.usc_location_image.image = pic_image

        
        //get duration and distance to destination
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
        
        //get and display path to destination
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
                    
                    self.add_path_on_google_maps_from(encodedString: line)
                    
                }
            }
        
        //animate down menu going up and setting destination text label
        destination_label.text = "("+usc_location.abbreviation + ") " + usc_location.name
        location_textfield.text = ""
        navigation_constraint.constant = 0
        UIView.animate(withDuration: 0.3, animations: { self.view.layoutIfNeeded()})
        
    }
    
    func add_path_on_google_maps_from(encodedString: String) {
        self.polyline.map = nil
        let path = GMSMutablePath(fromEncodedPath: encodedString)
        //print(encodedString)
        
        polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 5
        polyline.strokeColor = .blue
        polyline.map = mapView
        
        //shift camera
        //let bounds = GMSCoordinateBounds(path: path!)
        //self.mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 120.0))
    }
    
    func close_side_and_bottom_menus()
    {
        menu_constraint.constant = -140
        navigation_constraint.constant = -230
        UIView.animate(withDuration: 0.3, animations: { self.view.layoutIfNeeded()})
        menu_showing = false
    }
}




