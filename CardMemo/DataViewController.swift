//
//  DataViewController.swift
//  CardMemo
//
//  Created by knut on 23/03/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

//
//  ViewController.swift
//  NumberMemo
//
//  Created by knut on 15/03/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import UIKit
import CoreData

class DataViewController: UIViewController, UITableViewDataSource  , UITableViewDelegate{
    
    
    // Retreive the managedObjectContext from AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    // Create the table view as soon as this class loads
    var relationsTableView = UITableView(frame: CGRectZero, style: .Plain)
    
    var relationItems = [CardRelation]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Store the full frame in a temporary variable
        var viewFrame = self.view.frame
        
        // Adjust it down by 20 points
        viewFrame.origin.y += ( self.navigationController!.navigationBar.frame.size.height + UIApplication.sharedApplication().statusBarFrame.size.height )
        
        viewFrame.size.height -= (self.navigationController!.navigationBar.frame.size.height +
            UIApplication.sharedApplication().statusBarFrame.size.height)
        
        // Set the logTableview's frame to equal our temporary variable with the full size of the view
        // adjusted to account for the status bar height
        relationsTableView.frame = viewFrame
        
        // Add the table view to this view controller's view
        self.view.addSubview(relationsTableView)
        
        // Here, we tell the table view that we intend to use a cell we're going to call "LogCell"
        // This will be associated with the standard UITableViewCell class for now
        relationsTableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "RelationCell")
        
        // This tells the table view that it should get it's data from this class, ViewController
        relationsTableView.delegate = self
        relationsTableView.dataSource = self
        
        
        fetchRelations()
        
        var noRelationsSet = true
        for item in relationItems
        {
            if item.verb != ""
            {
                noRelationsSet = false
                break
            }
            if item.subject != ""
            {
                noRelationsSet = false
                break
            }
        }
        
        if noRelationsSet
        {
            self.populateExampleData()
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return relationItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RelationCell")
        //cell.textLabel?.text = "\(indexPath.row)"
        
        // Get the LogItem for this index
        let relationItem = relationItems[indexPath.row]
        
        //let name = relationItem.name
        let suite = relationItem.suite//dropFirst(relationItem.name)
        //♠️ ♣️ ♥️ ♦️
        let relationItemName = relationItem.name.stringByReplacingOccurrencesOfString("H", withString: "♥️").stringByReplacingOccurrencesOfString("D", withString: "♦️").stringByReplacingOccurrencesOfString("C", withString: "♣️").stringByReplacingOccurrencesOfString("S", withString: "♠️")
        
        let adFree = NSUserDefaults.standardUserDefaults().boolForKey("adFree")
        if suite == Int16(suitEnum.hearts.rawValue) && !adFree
        {
            cell?.textLabel?.text = relationItemName +
            "     " + "Can´t set value"
        }
        else
        {
        
            // Set the title of the cell to be the title of the logItem
            let noVerbRelation = relationItem.verb == ""
            let noSubjectRelation = relationItem.subject == ""
            let noOtherRelation = relationItem.other == ""
            let noRelations = noVerbRelation && noSubjectRelation && noOtherRelation
            let allRelationsSet = !noVerbRelation && !noSubjectRelation && !noOtherRelation
            
            cell?.textLabel?.text = relationItemName +
                "     " +
                (noRelations ? "(No relation defined)😒":"") +
                ((noRelations == false && noSubjectRelation) ? "(No subject relation)😑" : "") +
                ((noRelations == false && noVerbRelation) ? "(No verb relation)😑" : "")
            
            if allRelationsSet
            {
                cell?.textLabel?.text = relationItemName +  "     " + "😎"
            }
            else if !noVerbRelation && !noSubjectRelation
            {
                cell?.textLabel?.text = relationItemName +  "     " + "😊"
            }
            
            let imageName:String = relationItemName + ".png"
            if let image = UIImage(named: imageName)
            {
                cell?.imageView?.image = image
            }
            
            //let imageView = UIImageView(image: image!)
        }
        
        
        return cell!
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let relationItem = relationItems[indexPath.row]
        
        
        let adFree = NSUserDefaults.standardUserDefaults().boolForKey("adFree")
        
        let suite = relationItem.suite
        if suite == Int16(suitEnum.hearts.rawValue) && !adFree
        {
            let numberRelationPrompt = UIAlertController(title: "Locked😓",
                message: "Unlock to set value for ♥️ suite",
                preferredStyle: .Alert)
            numberRelationPrompt.addAction(UIAlertAction(title: "Ok",
                style: .Default,
                handler: { (action) -> Void in

            }))
            self.presentViewController(numberRelationPrompt,
                animated: true,
                completion: nil)
        }
        else
        {
            let numberRelationPrompt = UIAlertController(title: "Enter",
                message: "Enter relations for card \(relationItem.name)",
                preferredStyle: .Alert)
            
            var subjectRelationTextField: UITextField?
            numberRelationPrompt.addTextFieldWithConfigurationHandler {
                (textField) -> Void in
                subjectRelationTextField = textField
                textField.text = relationItem.subject
                textField.placeholder = "subject relation"
                textField.keyboardType = UIKeyboardType.Default
            }
            
            var verbRelationTextField: UITextField?
            numberRelationPrompt.addTextFieldWithConfigurationHandler {
                (textField) -> Void in
                verbRelationTextField = textField
                textField.text = relationItem.verb
                textField.placeholder = "verb relation"
                textField.keyboardType = UIKeyboardType.Default
            }
            
            var otherRelationsTextField: UITextField?
            numberRelationPrompt.addTextFieldWithConfigurationHandler {
                (textField) -> Void in
                otherRelationsTextField = textField
                textField.text = relationItem.other
                textField.placeholder = "other relations"
                textField.keyboardType = UIKeyboardType.Default
            }
            
            numberRelationPrompt.addAction(UIAlertAction(title: "Ok",
                style: .Default,
                handler: { (action) -> Void in
                    
                    relationItem.other = otherRelationsTextField!.text!
                    relationItem.verb = verbRelationTextField!.text!
                    relationItem.subject = subjectRelationTextField!.text!
                    self.save()
                    
                    //self.fetchRelations()
                    tableView.reloadData()
            }))
            self.presentViewController(numberRelationPrompt,
                animated: true,
                completion: nil)
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if(editingStyle == .Delete ) {
            // Find the LogItem object the user is trying to delete
            let relationItemToDelete = relationItems[indexPath.row]
            
            // Delete it from the managedObjectContext
            managedObjectContext?.deleteObject(relationItemToDelete)
            
            // Refresh the table view to indicate that it's deleted
            self.fetchRelations()
            
            // Tell the table view to animate out that row
            relationsTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            save()
        }
    }
    
    func fetchRelations() {
        
        // Create a new fetch request using the LogItem entity
        // eqvivalent to select * from Relation
        let fetchRequest = NSFetchRequest(entityName: "CardRelation")
        
        // Create a sort descriptor object that sorts on the "title"
        // property of the Core Data object
        let sortSuiteDescriptor = NSSortDescriptor(key: "suite", ascending: true)
        let sortValueDescriptor = NSSortDescriptor(key: "value", ascending: true)
        
        // Set the list of sort descriptors in the fetch request,
        // so it includes the sort descriptor
        fetchRequest.sortDescriptors = [sortSuiteDescriptor,sortValueDescriptor]

        
        if let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [CardRelation] {
            relationItems = fetchResults
        }
    }
    
    func populateExampleData()
    {

        let numberPrompt = UIAlertController(title: "Populate example data",
            message: "Want to populate some example data\nThat way U may get the point",
            preferredStyle: .Alert)
        
        numberPrompt.addAction(UIAlertAction(title: "YES",
            style: .Default,
            handler: { (action) -> Void in
                for item in self.relationItems
                {
                    //println("\((item as CardRelation).name)")
                    if (item as CardRelation).name == "AC"
                    {
                        item.subject = "Elvis"
                        item.verb = "Eating a club sandwitch"
                    }
                    if (item as CardRelation).name == "5C"
                    {
                        item.subject = "Carl Sagan"
                        item.verb = "Driving an old car"
                    }
                    if (item as CardRelation).name == "4C"
                    {
                        item.verb = "Explosion of C4"
                    }
                    if (item as CardRelation).name == "6C"
                    {
                        item.subject = "A .... whatever... u find an assosiation"
                    }
                }
                self.save()
                
                self.relationsTableView.reloadData()

        }))
        
        numberPrompt.addAction(UIAlertAction(title: "NO",
            style: .Default,
            handler: { (action) -> Void in
                return
        }))
        
        self.presentViewController(numberPrompt,
            animated: true,
            completion: nil)
    }
    

    
 
    func save() {
        do{
            try managedObjectContext!.save()
        } catch {
            print(error)
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.Portrait
    }
    
    
}