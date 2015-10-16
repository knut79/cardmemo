//
//  PictureButton.swift
//  CardMemo
//
//  Created by knut on 24/09/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation
import UIKit

class PictureButton: UIButton
{
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(frame: CGRect, image:String) {
        super.init(frame: frame)

        self.backgroundColor = UIColor.blackColor()
        
        self.layer.borderColor = UIColor.blackColor().CGColor
        self.layer.borderWidth = 2
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
        
        let image = UIImage(named: image) as UIImage?
        let resizedImage = imageResize(image!,sizeChange: CGSizeMake(self.bounds.width * 0.8,self.bounds.height * 0.8))
        
        let imageView = UIImageView(image: resizedImage)
        imageView.frame.offsetInPlace(dx: self.bounds.width * 0.1, dy: self.bounds.height * 0.1)
        self.addSubview(imageView)
        //self.setImage(image, forState: UIControlState.Normal)
        
    }
    
    func imageResize (imageObj:UIImage, sizeChange:CGSize)-> UIImage{
        
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        imageObj.drawInRect(CGRect(origin: CGPointZero, size: sizeChange))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage
    }
}