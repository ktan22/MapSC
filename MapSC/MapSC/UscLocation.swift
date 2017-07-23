import UIKit
import CoreLocation

/*
 Class for storing USC locations
 Keep on adding information when relevant, remember to update usc_locations.swift
 */
class UscLocation {
    var name : String
    var address : String
    var abbreviation : String
    var id : String
    var coordinate: CLLocationCoordinate2D
    var content: String
    var image_named: String
    
    init()
    {
        self.name = ""
        self.address = ""
        self.abbreviation = ""
        self.id = ""
        self.coordinate = CLLocationCoordinate2D()
        self.content = ""
        self.image_named = ""
    }
    
    func set_up_values(name: String, address: String, abbreviation: String, id: String, coordinate: CLLocationCoordinate2D, content: String, image_named: String)
    {
        self.name = name
        self.address = address
        self.abbreviation = abbreviation
        self.id = id
        self.coordinate = coordinate
        self.content = content
        self.image_named = image_named
        
    }
    
    func clear_values(){
        self.name = ""
        self.address = ""
        self.abbreviation = ""
        self.id = ""
        self.coordinate = CLLocationCoordinate2D()
        self.content = ""
        self.image_named = ""
    }
    
    
    
};
