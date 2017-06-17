import UIKit
import CoreLocation

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
