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
    
    init(name: String, address: String, abbreviation: String, id: String, coordinate: CLLocationCoordinate2D)
    {
        self.name = name
        self.address = address
        self.abbreviation = abbreviation
        self.id = id
        self.coordinate = coordinate
    }
    
    
};
