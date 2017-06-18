import UIKit

/*
 The model for any potential user information.
 Must be a singleton because we are dealing with per user data
 Can leave alone for now
 */
class UserModel {
    static let sharedInstance = UserModel()
    private init() {} //This prevents others from using the default '()' initializer for this class.
    
    var new_user = true
    
}
