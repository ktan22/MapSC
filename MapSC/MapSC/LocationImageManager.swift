//
//  Head_Image.swift
//  App
//
//  Created by Kyle Tan on 5/18/17.
//  Copyright © 2017 Kyle Tan. All rights reserved.
//

import Foundation
import UIKit

/*
 Class for managing images rendered on top of Google Maps SDK 
 */
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
    
    func imageOnImage(bottom_image: UIImage , top_image: UIImage) -> UIImage
    {
        let newSize = CGSize(width: 200, height: 200) // set this to what you need
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        
        bottom_image.draw(in: CGRect(origin: CGPoint(), size: newSize))
        top_image.draw(in: CGRect(origin: CGPoint(x:10,y:10), size: newSize))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
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
    
    func make_button_circle(button: UIButton)
    {
        button.frame = CGRect(x: 160, y: 100, width: 50, height: 50)
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
        button.clipsToBounds = true
        //button.setImage(UIImage(named:"button_my_location.png"), for: .normal)
        //button.addTarget(self, action: #selector(thumbsUpButtonPressed), for: .touchUpInside)
    }
    
    
    
    
    
    
    
    
}
