//
//  Head_Image.swift
//  App
//
//  Created by Kyle Tan on 5/18/17.
//  Copyright © 2017 Kyle Tan. All rights reserved.
//

import Foundation
import UIKit

class LocationImageManager
{
    func setImage(parameter:UscLocation, image_name: String) -> UIImage
    {
        let image = UIImage(named: image_name)
        let point = CGPoint(x: 10, y: 20)
        let id = parameter.id
        let address = parameter.address
        let abbreviation = parameter.abbreviation
        let name = parameter.name
        
        let text = "ID: "+id + ") " + name + " ("+abbreviation+")\n" + address
        let new_image = textOnImage(drawText: text as NSString, inImage: image!, atPoint: point)
        return new_image
    }
    
    func textOnImage(drawText text: NSString, inImage image: UIImage, atPoint point: CGPoint) -> UIImage {
        let textColor = UIColor.red
        let textFont = UIFont(name: "Helvetica Bold", size: 10)!
        
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
        
        let textFontAttributes = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: textColor,
            ] as [String : Any]
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        
        let rect = CGRect(origin: point, size: image.size)
        text.draw(in: rect, withAttributes: textFontAttributes)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
