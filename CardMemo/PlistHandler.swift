//
//  PlistHandler.swift
//  CardMemo
//
//  Created by knut on 26/09/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation





class PlistHandler {
    
    init()
    {

    }
    
    
    let DataPopulatedKey = "DataPopulated"
    let OkScoreKey = "OkScore"
    let GoodScoreKey = "GoodScore"
    let LoveScoreKey = "LoveScore"
    let TagsKey = "Tags"
    let LevelKey = "Level"
    let EventsUpdateKey = "EventsUpdate"
    let GameResultsKey = "GameResults"
    let AdFreeKey = "AdFree"
    
    var dataPopulatedValue:AnyObject = 0
    var okScoreValue:AnyObject = 0
    var goodScoreValue:AnyObject = 0
    var loveScoreValue:AnyObject = 0
    var tagsValue:AnyObject = 0
    var levelValue:AnyObject = 0
    var eventsUpdateValue:AnyObject = 0
    var adFreeValue:AnyObject = 0
    
    var gameResultsValues:[AnyObject] = []
    
    func loadGameData() {
        // getting path to GameData.plist
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        let documentsDirectory = paths[0] as! String
        let path = (documentsDirectory as NSString).stringByAppendingPathComponent("GameData.plist")
        let fileManager = NSFileManager.defaultManager()
        //check if file exists
        if(!fileManager.fileExistsAtPath(path)) {
            // If it doesn't, copy it from the default file in the Bundle
            if let bundlePath = NSBundle.mainBundle().pathForResource("GameData", ofType: "plist") {
                let resultDictionary = NSMutableDictionary(contentsOfFile: bundlePath)
                print("Bundle GameData.plist file is --> \(resultDictionary?.description)")
                do {
                    try fileManager.copyItemAtPath(bundlePath, toPath: path)
                } catch _ {
                }
                print("copy")
            } else {
                print("GameData.plist not found. Please, make sure it is part of the bundle.")
            }
        } else {
            print("GameData.plist already exits at path. \(path)")
            // use this to delete file from documents directory
            //fileManager.removeItemAtPath(path, error: nil)
        }
        let resultDictionary = NSMutableDictionary(contentsOfFile: path)
        print("Loaded GameData.plist file is --> \(resultDictionary?.description)")
        let myDict = NSDictionary(contentsOfFile: path)
        if let dict = myDict {
            //loading values
            dataPopulatedValue = dict.objectForKey(DataPopulatedKey)!
            okScoreValue = dict.objectForKey(OkScoreKey)!
            goodScoreValue = dict.objectForKey(GoodScoreKey)!
            loveScoreValue = dict.objectForKey(LoveScoreKey)!
            tagsValue = dict.objectForKey(TagsKey)!
            levelValue = dict.objectForKey(LevelKey)!
            eventsUpdateValue = dict.objectForKey(EventsUpdateKey)!
            adFreeValue = dict.objectForKey(AdFreeKey)!
            NSUserDefaults.standardUserDefaults().setBool(adFreeValue as! NSNumber == 1 ? true : false, forKey: "adFree")
            gameResultsValues = dict.objectForKey(GameResultsKey)! as! [AnyObject]
        } else {
            print("WARNING: Couldn't create dictionary from GameData.plist! Default values will be used!")
        }
    }
    
    func saveGameData() {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        let documentsDirectory = paths.objectAtIndex(0) as! NSString
        let path = documentsDirectory.stringByAppendingPathComponent("GameData.plist")
        let dict: NSMutableDictionary = ["XInitializerItem": "DoNotEverChangeMe"]
        //saving values
        dict.setObject(dataPopulatedValue, forKey: DataPopulatedKey)
        dict.setObject(okScoreValue, forKey: OkScoreKey)
        dict.setObject(goodScoreValue, forKey: GoodScoreKey)
        dict.setObject(loveScoreValue, forKey: LoveScoreKey)
        dict.setObject(tagsValue, forKey: TagsKey)
        dict.setObject(levelValue, forKey: LevelKey)
        dict.setObject(eventsUpdateValue, forKey: EventsUpdateKey)
        dict.setObject(adFreeValue, forKey: AdFreeKey)
        
        dict.setObject(gameResultsValues, forKey: GameResultsKey)
        //writing to GameData.plist
        dict.writeToFile(path, atomically: false)
        let resultDictionary = NSMutableDictionary(contentsOfFile: path)
        print("Saved GameData.plist file is --> \(resultDictionary?.description)")
    }

}