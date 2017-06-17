import UIKit

class UserModel {
    static let sharedInstance = UserModel()
    private init() {} //This prevents others from using the default '()' initializer for this class.
    
    var new_user = true
    
}
