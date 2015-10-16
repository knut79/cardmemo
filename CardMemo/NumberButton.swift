//
//  NumberButton.swift
//  CardMemo
//
//  Created by knut on 24/09/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation
import UIKit

class NumberButton: UIButton
{

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //self.layer.borderColor = UIColor.greenColor().CGColor
        //self.layer.borderWidth = 2

        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
        self.backgroundColor = UIColor.blackColor()
        
    }
}