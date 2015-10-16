//
//  CardRelation.swift
//  CardMemo
//
//  Created by knut on 23/03/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation
import CoreData

class CardRelation: NSManagedObject {
    
    @NSManaged var marked: DarwinBoolean
    @NSManaged var name: String
    @NSManaged var other: String
    @NSManaged var picture: String
    @NSManaged var subject: String
    @NSManaged var suite: Int16
    @NSManaged var verb: String
    @NSManaged var value: Int16

    //@NSManaged var numberrelationsubject: String
    
    class func createInManagedObjectContext(moc: NSManagedObjectContext, name: String, suite: suitEnum, value: Int16) -> CardRelation{
        let newitem = NSEntityDescription.insertNewObjectForEntityForName("CardRelation", inManagedObjectContext: moc) as! CardRelation
        newitem.name = name
        newitem.other = ""

        newitem.marked = false
        newitem.picture = ""
        newitem.subject = ""
        newitem.suite = suite.rawValue
        newitem.verb = ""
        newitem.value = value

        return newitem
    }

    
}

