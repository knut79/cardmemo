//
//  MainMenuViewController.swift
//  CardMemo
//
//  Created by knut on 23/03/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import StoreKit
import iAd
import FBSDKLoginKit
import FBSDKShareKit

class MainMenuViewController: UIViewController , SKProductsRequestDelegate, ADBannerViewDelegate, HolderViewDelegate,FBSDKAppInviteDialogDelegate,FBSDKSharingDelegate, FBSDKLoginButtonDelegate{
    
    
    var memorizeButton: UIButton!
    var practiceButton: UIButton!
    var setRelationsButton: UIButton!
    var adFreeButton:UIButton?
    var loginButton: FBSDKLoginButton?
    var inviteFriendsButton:FBSDKSendButton?
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var relationItems = [CardRelation]()
    
    var bannerView:ADBannerView?
    
    var datactrl:PlistHandler!
    
    var holderView = HolderView(frame: CGRectZero)
    
    let logo1 = UILabel()
    let logo2 = UILabel()
    let logo3 = UILabel()
    
    //payment
    var product: SKProduct?
    var productID = "AdfreePlus123"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "upgrade1")
        
        
        let firstLaunch = NSUserDefaults.standardUserDefaults().boolForKey("firstlaunch")
        
        if firstLaunch
        {
            self.view.backgroundColor = UIColor.blueColor()
        }


        datactrl = PlistHandler()


        let marginBetweenButtons:CGFloat = 15
        let buttonWidth = UIScreen.mainScreen().bounds.size.width * 0.6
        let buttonHeight = buttonWidth * 0.25
        memorizeButton = UIButton(frame:CGRectMake((self.navigationController!.navigationBar.frame.size.width/2) - (buttonWidth / 2), (UIScreen.mainScreen().bounds.size.height * 0.2), buttonWidth, buttonHeight))
        memorizeButton.addTarget(self, action: "memorizeAction", forControlEvents: UIControlEvents.TouchUpInside)
        memorizeButton.setTitle("Memorize", forState: UIControlState.Normal)
        memorizeButton.backgroundColor = UIColor.blueColor()
        memorizeButton.layer.cornerRadius = 5
        memorizeButton.layer.masksToBounds = true
        memorizeButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        practiceButton = UIButton(frame:CGRectMake(memorizeButton.frame.minX, memorizeButton.frame.maxY + marginBetweenButtons, buttonWidth, buttonHeight))
        practiceButton.addTarget(self, action: "practiceAction", forControlEvents: UIControlEvents.TouchUpInside)
        practiceButton.setTitle("Practice", forState: UIControlState.Normal)
        practiceButton.backgroundColor = UIColor.blueColor()
        practiceButton.layer.cornerRadius = 5
        practiceButton.layer.masksToBounds = true
        practiceButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        setRelationsButton = UIButton(frame:CGRectMake(memorizeButton.frame.minX, practiceButton.frame.maxY + marginBetweenButtons, buttonWidth, buttonHeight))
        setRelationsButton.addTarget(self, action: "setRelationAction", forControlEvents: UIControlEvents.TouchUpInside)
        setRelationsButton.setTitle("Set card relations", forState: UIControlState.Normal)
        setRelationsButton.backgroundColor = UIColor.blueColor()
        setRelationsButton.layer.cornerRadius = 5
        setRelationsButton.layer.masksToBounds = true
        setRelationsButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        //requestProductData()
        
        /*
        let adFree = NSUserDefaults.standardUserDefaults().boolForKey("adFree")
        if !adFree
        {
            adFreeButton = UIButton(frame:CGRectMake(memorizeButton.frame.minX, setRelationsButton.frame.maxY + marginBetweenButtons, buttonWidth, buttonHeight * 2))
            //adFreeButton.center = CGPoint(x: self.navigationController!.navigationBar.frame.size.width/2, y: (UIScreen.mainScreen().bounds.size.height * 0.8))
            adFreeButton?.addTarget(self, action: "buyProductAction", forControlEvents: UIControlEvents.TouchUpInside)
            adFreeButton?.backgroundColor = UIColor.blueColor()
            adFreeButton?.userInteractionEnabled = true
            adFreeButton?.layer.cornerRadius = 5
            adFreeButton?.layer.masksToBounds = true
            adFreeButton?.titleLabel?.adjustsFontSizeToFitWidth = true

            adFreeButton?.titleLabel?.numberOfLines = 3
            adFreeButton?.titleLabel?.textAlignment = NSTextAlignment.Center
            adFreeButton?.setTitle("Remove ads\n Unlock ❤️suite\nMore cards", forState: UIControlState.Normal)
            
            bannerView = ADBannerView(frame: CGRectMake(0, 0, view.bounds.width, view.bounds.height))
            
            self.view.addSubview(bannerView!)
            self.bannerView?.delegate = self
            self.bannerView?.hidden = false
        }
        */
        bannerView = ADBannerView(frame: CGRectMake(0, 0, view.bounds.width, view.bounds.height))
        self.view.addSubview(bannerView!)

        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            let content = FBSDKShareLinkContent()
            content.contentURL = NSURL(string: "https://itunes.apple.com/no/app/i-card-memorize/id1043867425?mt=8")
            //content.imageURL = NSURL(string: "https://fbcdn-photos-h-a.akamaihd.net/hphotos-ak-xtp1/t39.2081-0/p128x128/12057212_936552496419899_597891191_n.png")
            content.imageURL = NSURL(string: "https://itunes.apple.com/no/app/i-card-memorize/id1043867425?mt=8")
            content.contentDescription = "Memorize cards with this iOS app"
            content.contentTitle = "I-card-memorize"
            inviteFriendsButton = FBSDKSendButton()
            if let button = inviteFriendsButton
            {
                button.center = CGPointMake(setRelationsButton.center.x, setRelationsButton.center.y + (setRelationsButton.frame.height * 2))
                button.shareContent = content
                button.layer.cornerRadius = 5
                button.layer.masksToBounds = true
                button.setTitle("Invite friends", forState: UIControlState.Normal)
            }
            
        }
        else
        {
           loginButton = FBSDKLoginButton()
            loginButton!.center = CGPointMake(setRelationsButton.center.x, setRelationsButton.center.y + (setRelationsButton.frame.height * 2))
            loginButton!.delegate = self
            loginButton!.readPermissions = ["public_profile", "user_friends"]
        }
        

        if !firstLaunch
        {
            
            setupAfterPotentialScreenLoad()
        }
        
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if ((error) != nil)
        {
            // Process error
            let alert = UIAlertView(title: "Facebook login error", message: "Something went wrong at login. Try again later", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            logOut()
        }
        else if result.isCancelled {
            // Handle cancellations
            logOut()
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            
            if result.grantedPermissions.contains("user_friends")
            {
                let content = FBSDKShareLinkContent()
                content.contentURL = NSURL(string: "https://itunes.apple.com/no/app/i-card-memorize/id1043867425?mt=8")
                content.imageURL = NSURL(string: "https://fbcdn-photos-h-a.akamaihd.net/hphotos-ak-xtp1/t39.2081-0/p128x128/12057212_936552496419899_597891191_n.png")
                content.contentDescription = "Memorize cards with this iOS app"
                content.contentTitle = "I-card-memorize"
            
                inviteFriendsButton = FBSDKSendButton()
                if let button = inviteFriendsButton
                {
                    button.frame = loginButton.frame
                    button.shareContent = content
                    button.layer.cornerRadius = 5
                    button.layer.masksToBounds = true
                    button.setTitle("Invite friends", forState: UIControlState.Normal)
                    self.view.addSubview(button)
                    loginButton.removeFromSuperview()
                }
                
                
            }
            else
            {
                let alert = UIAlertView(title: "Friendslist", message: "Friendslist must be premitted to invite friends", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
                
                logOut()
            }

            
        }
    }
    
    
    func logOut()
    {
        FBSDKAccessToken.setCurrentAccessToken(nil)
        FBSDKProfile.setCurrentProfile(nil)
        
        let manager = FBSDKLoginManager()
        manager.logOut()
        
        //self.performSegueWithIdentifier("segueFromChallengeToMainMenu", sender: nil)
    }
    
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
        self.logOut()
    }
    
    
    func memorizeAction()
    {
        self.performSegueWithIdentifier("SequeFromMainMenuToMemorize", sender: nil)
    }
    
    func practiceAction()
    {
        self.performSegueWithIdentifier("SequeFromMainMenuToFlash", sender: nil)
    }
    
    func setRelationAction()
    {
        
        self.performSegueWithIdentifier("SequeFromMainMenuToData", sender: nil)
    }
    
    
    func setupAfterPotentialScreenLoad()
    {
        self.view.addSubview(memorizeButton)
        self.view.addSubview(practiceButton)
        self.view.addSubview(setRelationsButton)
        if let button = loginButton
        {
            self.view.addSubview(button)
        }
        if let button = inviteFriendsButton
        {
            self.view.addSubview(button)
        }
        let adFree = NSUserDefaults.standardUserDefaults().boolForKey("adFree")
        if !adFree
        {
            if let button = adFreeButton
            {
                self.view.addSubview(button)
            }
        }
        self.canDisplayBannerAds = true
        bannerView = ADBannerView(frame: CGRectMake(0, UIScreen.mainScreen().bounds.size.height - 44, UIScreen.mainScreen().bounds.size.width, 44))
        //bannerView = ADBannerView(frame: CGRectZero)
        self.view.addSubview(bannerView!)
        self.bannerView?.delegate = self
        self.bannerView?.hidden = false
        

        if !adFree
        {
            if let button = adFreeButton
            {
                button.setTitle("Remove ads\n&\n Unlock ❤️suite", forState: UIControlState.Normal)
            }
        }
        
        
        fetchRelations()
        if(relationItems.count == 0)
        {
            populateItems()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let firstLaunch = NSUserDefaults.standardUserDefaults().boolForKey("firstlaunch")
        if firstLaunch
        {
            let boxSize: CGFloat = 100.0
            holderView.frame = CGRect(x: view.bounds.width / 2 - boxSize / 2,
                y: view.bounds.height / 2 - boxSize / 2,
                width: boxSize,
                height: boxSize)
            holderView.parentFrame = view.frame
            holderView.delegate = self
            view.addSubview(holderView)
            holderView.startAnimation()
            
            logo1.frame = CGRectMake((UIScreen.mainScreen().bounds.size.width / 2) - 100, UIScreen.mainScreen().bounds.size.height * 0.75, 30, 50)
            logo1.textAlignment = NSTextAlignment.Right
            logo1.textColor = UIColor.whiteColor()
            logo1.font = UIFont.boldSystemFontOfSize(25)
            logo1.alpha = 0
            logo1.adjustsFontSizeToFitWidth = true
            logo1.text = "I"
            
            self.view.addSubview(logo1)
            
            logo2.frame = CGRectMake(logo1.frame.maxX, UIScreen.mainScreen().bounds.size.height * 0.75, 70, 50)
            logo2.textAlignment = NSTextAlignment.Center
            logo2.textColor = UIColor.whiteColor()
            logo2.font = UIFont.boldSystemFontOfSize(25)
            logo2.alpha = 0
            logo2.adjustsFontSizeToFitWidth = true
            logo2.text = "Card"
            
            self.view.addSubview(logo2)

            logo3.frame = CGRectMake(logo2.frame.maxX, UIScreen.mainScreen().bounds.size.height * 0.75, 100, 50)
            logo3.textAlignment = NSTextAlignment.Left
            logo3.textColor = UIColor.whiteColor()
            logo3.font = UIFont.boldSystemFontOfSize(25)
            logo3.adjustsFontSizeToFitWidth = true
            logo3.alpha = 0
            logo3.text = "Memorize"
            
            self.view.addSubview(logo3)
            
            let orgLogo1Center = logo1.center
            let orgLogo2Center = logo2.center
            let orgLogo3Center = logo3.center
            logo1.transform = CGAffineTransformScale(logo1.transform, 0.1, 0.1)
            logo2.transform = CGAffineTransformScale(logo2.transform, 0.1, 0.1)
            logo3.transform = CGAffineTransformScale(logo3.transform, 0.1, 0.1)
            logo1.center = CGPointMake(UIScreen.mainScreen().bounds.size.width / 2, UIScreen.mainScreen().bounds.size.height / 2)
            logo2.center = logo1.center
            logo3.center = logo1.center
            UIView.animateWithDuration(0.35, animations: { () -> Void in
                self.logo1.transform = CGAffineTransformIdentity
                self.logo1.alpha = 1
                self.logo1.center = orgLogo1Center
                }, completion: { (value: Bool) in
                    
                    UIView.animateWithDuration(0.35, animations: { () -> Void in
                        self.logo2.transform = CGAffineTransformIdentity
                        self.logo2.alpha = 1
                        self.logo2.center = orgLogo2Center
                        }, completion: { (value: Bool) in
                            UIView.animateWithDuration(0.35, animations: { () -> Void in
                                self.logo3.transform = CGAffineTransformIdentity
                                self.logo3.alpha = 1
                                self.logo3.center = orgLogo3Center
                            })
                            
                    })

                    
            })
            
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "firstlaunch")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        bannerView?.frame = CGRectZero
        bannerView?.center = CGPoint(x: bannerView!.center.x, y: self.view.bounds.size.height - bannerView!.frame.size.height / 2)
    }
    
    func loadScreenFinished() {
        self.view.backgroundColor = UIColor.whiteColor()
        //holderView.removeFromSuperview()
        holderView.hidden = true
        self.setupAfterPotentialScreenLoad()
        
        memorizeButton.transform = CGAffineTransformScale(memorizeButton.transform, 0.1, 0.1)
        practiceButton.transform = CGAffineTransformScale(practiceButton.transform, 0.1, 0.1)
        setRelationsButton.transform = CGAffineTransformScale(setRelationsButton.transform, 0.1, 0.1)
        adFreeButton?.transform = CGAffineTransformScale(adFreeButton!.transform, 0.1, 0.1)
        
        
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.memorizeButton.transform = CGAffineTransformIdentity
            self.practiceButton.transform = CGAffineTransformIdentity
            self.setRelationsButton.transform = CGAffineTransformIdentity
            self.adFreeButton?.transform = CGAffineTransformIdentity
            }, completion: { (value: Bool) in
                
        })

    }

    func populateItems() {
        
        let testData: [(String,suitEnum,Int16)] = [
            ("AC",suitEnum.clubs,1),
            ("2C",suitEnum.clubs,2),
            ("3C",suitEnum.clubs,3),
            ("4C",suitEnum.clubs,4),
            ("5C",suitEnum.clubs,5),
            ("6C",suitEnum.clubs,6),
            ("7C",suitEnum.clubs,7),
            ("8C",suitEnum.clubs,8),
            ("9C",suitEnum.clubs,9),
            ("10C",suitEnum.clubs,10),
            ("JC",suitEnum.clubs,11),
            ("QC",suitEnum.clubs,12),
            ("KC",suitEnum.clubs,13),
            ("AD",suitEnum.diamonds,1),
            ("2D",suitEnum.diamonds,2),
            ("3D",suitEnum.diamonds,3),
            ("4D",suitEnum.diamonds,4),
            ("5D",suitEnum.diamonds,5),
            ("6D",suitEnum.diamonds,6),
            ("7D",suitEnum.diamonds,7),
            ("8D",suitEnum.diamonds,8),
            ("9D",suitEnum.diamonds,9),
            ("10D",suitEnum.diamonds,10),
            ("JD",suitEnum.diamonds,11),
            ("QD",suitEnum.diamonds,12),
            ("KD",suitEnum.diamonds,13),
            ("AH",suitEnum.hearts,1),
            ("2H",suitEnum.hearts,2),
            ("3H",suitEnum.hearts,3),
            ("4H",suitEnum.hearts,4),
            ("5H",suitEnum.hearts,5),
            ("6H",suitEnum.hearts,6),
            ("7H",suitEnum.hearts,7),
            ("8H",suitEnum.hearts,8),
            ("9H",suitEnum.hearts,9),
            ("10H",suitEnum.hearts,10),
            ("JH",suitEnum.hearts,11),
            ("QH",suitEnum.hearts,12),
            ("KH",suitEnum.hearts,13),
            ("AS",suitEnum.spades,1),
            ("2S",suitEnum.spades,2),
            ("3S",suitEnum.spades,3),
            ("4S",suitEnum.spades,4),
            ("5S",suitEnum.spades,5),
            ("6S",suitEnum.spades,6),
            ("7S",suitEnum.spades,7),
            ("8S",suitEnum.spades,8),
            ("9S",suitEnum.spades,9),
            ("10S",suitEnum.spades,10),
            ("JS",suitEnum.spades,11),
            ("QS",suitEnum.spades,12),
            ("KS",suitEnum.spades,13)
        ]
        
        
        for values in testData
        {
            self.saveNewItem(values.0,suite: values.1, value: values.2)
            
        }
    }
    
    func requestProductData()
    {
        let adFree = NSUserDefaults.standardUserDefaults().boolForKey("adFree")
        if adFree
        {
            return
        }
        if SKPaymentQueue.canMakePayments() {
            let request = SKProductsRequest(productIdentifiers:  NSSet(objects: self.productID) as! Set<String>)
            request.delegate = self
            request.start()
        } else {
            let alert = UIAlertController(title: "In-App Purchases Not Enabled", message: "Please enable In App Purchase in Settings", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Settings", style: UIAlertActionStyle.Default, handler: { alertAction in
                alert.dismissViewControllerAnimated(true, completion: nil)
                
                let url: NSURL? = NSURL(string: UIApplicationOpenSettingsURLString)
                if url != nil
                {
                    UIApplication.sharedApplication().openURL(url!)
                }
                
            }))
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { alertAction in
                alert.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        
        var products = response.products
        
        if (products.count != 0) {
            product = products[0]
            
            adFreeButton?.backgroundColor = UIColor.blueColor()
            adFreeButton?.userInteractionEnabled = true
            
        } else {
            print("Product not found: \(product)")
        }
        
        let invalidProducts = response.invalidProductIdentifiers
        
        for product in invalidProducts
        {
            print("Product not found: \(product)")
        }
    }
    
    func buyProductAction() {
        
        let numberPrompt = UIAlertController(title: "Remove ads",
            message: "",
            preferredStyle: .Alert)
        
        
        numberPrompt.addAction(UIAlertAction(title: "Buy",
            style: .Default,
            handler: { (action) -> Void in
                self.addProductPayment()
        }))
        numberPrompt.addAction(UIAlertAction(title: "Restore purchase",
            style: .Default,
            handler: { (action) -> Void in
                
                self.addProductPayment()
                
        }))
        
        self.presentViewController(numberPrompt,
            animated: true,
            completion: nil)
    }
    
    func addProductPayment()
    {
        //_? test
        //self.removeAdds()
        
        let payment = SKPayment(product: product!)
        SKPaymentQueue.defaultQueue().addPayment(payment)
        
    }
    
    func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {
        
        for transaction in transactions as! [SKPaymentTransaction] {
            
            switch transaction.transactionState {
                
            case SKPaymentTransactionState.Purchased:
                self.removeAdds()
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
            case SKPaymentTransactionState.Restored:
                self.removeAdds()
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
            case SKPaymentTransactionState.Failed:
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
            default:
                break
            }
        }
    }
    
    func removeAdds() {
        
        datactrl.adFreeValue = 1
        datactrl.saveGameData()
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "adFree")
        self.bannerView?.hidden = true
        
        adFreeButton?.backgroundColor = UIColor.grayColor()
        adFreeButton?.userInteractionEnabled = false
        adFreeButton?.removeFromSuperview()
    }

    func saveNewItem(name: String, suite: suitEnum, value: Int16) {
        CardRelation.createInManagedObjectContext(self.managedObjectContext!, name: name, suite: suite, value: value)
    }
    
    func fetchRelations() {
        
        // Create a new fetch request using the LogItem entity
        // eqvivalent to select * from Relation
        let fetchRequest = NSFetchRequest(entityName: "CardRelation")
        
        // Create a sort descriptor object that sorts on the "title"
        // property of the Core Data object
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        
        // Set the list of sort descriptors in the fetch request,
        // so it includes the sort descriptor
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [CardRelation] {
            relationItems = fetchResults
        }
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
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        let adFree = NSUserDefaults.standardUserDefaults().boolForKey("adFree")
        self.bannerView?.hidden = adFree
    }
    
    func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        return willLeave
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        self.bannerView?.hidden = true
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
    
    
    //test
    func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        
        let temp = results
        for item in temp
        {
            print(item)
        }
    }
    
    func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
        print(error)
    }
    
    func sharerDidCancel(sharer: FBSDKSharing!) {
        
    }
    
    func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        //TODO
        let v = "v"
    }
    func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: NSError!) {
        print(error)
    }
    
}