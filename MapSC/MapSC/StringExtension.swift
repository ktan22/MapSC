//
//  StringExtension.swift
//  MapSC
//
//  Created by Olivia Hong on 7/13/17.
//  Copyright © 2017 BITS. All rights reserved.
//

import Foundation

extension String
{
    //returns length of string
    var length : Int {
        return self.characters.count
    }
    
    //trims whitespace
    func trimmed() -> String{
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    //checks if string is number
    var isNumber : Bool {
        get{
            return !self.isEmpty && self.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
        }
    }
}
