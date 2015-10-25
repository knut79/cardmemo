//
//  FlashcardViewController.swift
//  CardMemo
//
//  Created by knut on 24/03/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import iAd


class FlashcardViewController: UIViewController, ADBannerViewDelegate{
    
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var cards:Array<Card> = Array<Card>()
    var currentCard = 0
    var front: UIImageView!
    var back: UILabel!
    var cardView: UIView!
    let slideInFromRightTransition = CATransition()
    let slideInFromLeftTransition = CATransition()
    var randomize: Bool = false
    var cardHeigh:CGFloat!
    var cardWidth:CGFloat!
    var bannerView:ADBannerView?
    

    
    @IBOutlet var TapGesture: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.canDisplayBannerAds = true
        bannerView = ADBannerView(frame: CGRectMake(0, UIScreen.mainScreen().bounds.size.height - 44, UIScreen.mainScreen().bounds.size.width, 44))
        self.view.addSubview(bannerView!)
        self.bannerView?.delegate = self
        self.bannerView?.hidden = false

        slideInFromRightTransition.delegate = self
        // Customize the animation's properties
        slideInFromRightTransition.type = kCATransitionPush
        slideInFromRightTransition.subtype = kCATransitionFromRight
        slideInFromRightTransition.duration = 0.5
        slideInFromRightTransition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        slideInFromRightTransition.fillMode = kCAFillModeRemoved

        slideInFromLeftTransition.delegate = self
        // Customize the animation's properties
        slideInFromLeftTransition.type = kCATransitionPush
        slideInFromLeftTransition.subtype = kCATransitionFromLeft
        slideInFromLeftTransition.duration = 0.5
        slideInFromLeftTransition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        slideInFromLeftTransition.fillMode = kCAFillModeRemoved

        let aSelector : Selector = "flipCard:"
        let tapGesture = UITapGestureRecognizer(target: self, action: aSelector)
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGesture)
        
        let cSelector : Selector = "nextCard:"
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: cSelector)
        leftSwipe.direction = UISwipeGestureRecognizerDirection.Left
        view.addGestureRecognizer(leftSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: "lastCard:")
        rightSwipe.direction = UISwipeGestureRecognizerDirection.Right
        view.addGestureRecognizer(rightSwipe)
        
        let withToHeightCardRatio:CGFloat = 314 / 226
        cardWidth = UIScreen.mainScreen().bounds.size.width * 0.7
        let rect = CGRectMake(0, 0, cardWidth, cardWidth * withToHeightCardRatio)
        cardView = UIView(frame: rect)
        cardView.layer.cornerRadius = 10
        cardView.layer.masksToBounds = true
        cardView.backgroundColor = UIColor.lightGrayColor()
        cardView.center = CGPoint(x: UIScreen.mainScreen().bounds.size.width/2, y: UIScreen.mainScreen().bounds.size.height/2)
        
        cardView.layer.borderColor = UIColor.blackColor().CGColor
        cardView.layer.borderWidth = 1
        cardView.layer.cornerRadius = 10
        cardView.layer.masksToBounds = true
        
        cardHeigh = rect.height

        
        fetchRelations()


        
        
        let imageName:String = cards[currentCard].front + ".png"
        if let imagefront = UIImage(named: imageName)
        {
            
            //cell.imageView?.image = image
            front = UIImageView(image: imageResize(imagefront,sizeChange: CGSizeMake(cardWidth,cardHeigh)))
            front.layer.cornerRadius = 10
            front.layer.masksToBounds = true
            self.view.addSubview(front)
        }
        else
        {
            let imagefront = UIImage(named: "girl.jpg")

            front = UIImageView(image: imageResize(imagefront!,sizeChange: CGSizeMake(cardWidth,cardHeigh)))
            front.layer.cornerRadius = 10
            front.layer.masksToBounds = true
            self.view.addSubview(front)

        }

        
        
        back = UILabel(frame: CGRectMake(0, 0, cardView.bounds.size.width * 0.8, cardView.bounds.size.height * 0.8))
        back.textAlignment = NSTextAlignment.Left
        back.center = CGPoint(x: cardView.bounds.size.width/2,y: cardView.bounds.size.height/2)
        back.numberOfLines = 6
        back.text = cards[currentCard].back
        back.hidden = true
        self.view.addSubview(back)
        
        cardView.addSubview(front)
        view.addSubview(cardView)
        
        
        
    }
    

    
    func fetchRelations() {
        
        let fetchRequest = NSFetchRequest(entityName: "CardRelation")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [CardRelation] {
            for(var i = 0; i < fetchResults.count ; i++)
            {
                if(fetchResults[i].other != "" || fetchResults[i].subject != "" || fetchResults[i].verb != "")
                {
                    cards.append(Card(front: fetchResults[i].name, back:
                        (fetchResults[i].subject != "" ? "Subject: " + fetchResults[i].subject : "") + "\n" +
                        (fetchResults[i].verb != "" ? "Verb: " + fetchResults[i].verb : "") + "\n" +
                        fetchResults[i].other))
                }
            }
            
            if(cards.count == 0)
            {
                cards.append(Card(front: fetchResults[0].name, back: "Write some relations for the cards!!  \nLearn to memorize with your own relations"))
            }
            
            if(randomize)
            {
                cards = shuffle(cards)
            }
            //relationItems = fetchResults
        }
    }
    
    func shuffle<C: MutableCollectionType where C.Index == Int>(var list: C) -> C {
        let ecount = list.count
        for i in 0..<(ecount - 1) {
            let j = Int(arc4random_uniform(UInt32(ecount - i))) + i
            swap(&list[i], &list[j])
        }
        return list
    }
    
    var showingBack = false
    
    func flipCard(sender: AnyObject) {
        
        back.hidden = false
        if (showingBack) {
            UIView.transitionFromView(back, toView: front, duration: 1, options: UIViewAnimationOptions.TransitionFlipFromRight, completion: nil)
            showingBack = false
        } else {
            UIView.transitionFromView(front, toView: back, duration: 1, options: UIViewAnimationOptions.TransitionFlipFromLeft, completion: nil)
            showingBack = true
        }
    }
    
    func imageResize (imageObj:UIImage, sizeChange:CGSize)-> UIImage{
        
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        imageObj.drawInRect(CGRect(origin: CGPointZero, size: sizeChange))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage
    }
    
    @IBAction func nextCard(sender: AnyObject) {
        
        
        if (showingBack) {
            UIView.transitionFromView(back, toView: front, duration: 1, options: UIViewAnimationOptions.TransitionFlipFromRight, completion: nil)
            showingBack = false
            back.hidden = true
        }
        // Add the animation to the View's layer
        self.cardView.layer.addAnimation(slideInFromRightTransition, forKey: "slideInFromRightTransition")
        
        
        self.currentCard++
        self.currentCard = self.currentCard % cards.count

        let imageName:String = cards[currentCard].front + ".png"
        if let imagefront = UIImage(named: imageName)
        {
            front.image = imageResize(imagefront,sizeChange: CGSizeMake(cardWidth,cardHeigh))
        }
        else
        {
            let imagefront = UIImage(named: "girl.jpg")
           
            front.image = imageResize(imagefront!,sizeChange: CGSizeMake(cardWidth,cardHeigh))
        }
        
        back.text = cards[currentCard].back
    }
    
    @IBAction func lastCard(sender: AnyObject) {
        
        if (showingBack) {
            UIView.transitionFromView(back, toView: front, duration: 1, options: UIViewAnimationOptions.TransitionFlipFromRight, completion: nil)
            showingBack = false
            back.hidden = true
        }
        // Add the animation to the View's layer
        self.cardView.layer.addAnimation(slideInFromLeftTransition, forKey: "slideInFromLeftTransition")
        
        self.currentCard--
        self.currentCard = self.currentCard < 0 ? (cards.count - 1) : self.currentCard
        
        let imageName:String = cards[currentCard].front + ".png"
        if let imagefront = UIImage(named: imageName)
        {
            front.image = imageResize(imagefront,sizeChange: CGSizeMake(cardWidth,cardHeigh))
        }
        else
        {
            let imagefront = UIImage(named: "girl.jpg")
            front.image = imageResize(imagefront!,sizeChange: CGSizeMake(cardWidth,cardHeigh))
        }
        
        back.text = cards[currentCard].back
    }
    

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
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
}

