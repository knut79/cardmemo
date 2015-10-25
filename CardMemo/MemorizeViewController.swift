//
//  MemorizeViewController.swift
//  CardMemo
//
//  Created by knut on 24/03/15.
//  Copyright (c) 2015 knut. All rights reserved.
//
import Foundation
import UIKit
import CoreData
import iAd


class MemorizeViewController:UIViewController, ADBannerViewDelegate{
    
    
    @IBOutlet weak var numberOfCardsPicker: UIPickerView!
    var startButton: UIButton!
    var reShuffleButton: UIButton!
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var cards:Array<Card> = Array<Card>()
    var currentCard = 0
    var front: UIImageView!
    var back: UIImageView!
    var cardView: UIView!
    let slideInFromRightTransition = CATransition()
    let slideInFromLeftTransition = CATransition()
    var cardHeigh:CGFloat!
    var cardWidth:CGFloat!
    let numbersOfCardsArray  = ["1","2","3","4","5","6","7","8","9","10",
        "11","12","13","14","15","16","17","18","19","20",
        "21","22","23","24","25","26","27","28","29","30",
        "31","32","33","34","35","36","37","38","39","40",
        "41","42","43","44","45","46","47","48","49","50",
        "51","52","52 x 2","52 x 3","52 x 4","52 x 5",
        "52 x 6","52 x 7","52 x 8","52 x 9"]
    var currentNumberOfCards = 1
    
    var bannerView:ADBannerView?
    
    var dummyCards:[UIView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.canDisplayBannerAds = true
        bannerView = ADBannerView(frame: CGRectMake(0, UIScreen.mainScreen().bounds.size.height - 44, UIScreen.mainScreen().bounds.size.width, 44))
        self.view.addSubview(bannerView!)
        self.bannerView?.delegate = self
        self.bannerView?.hidden = false
        
        // Now that the view loaded, we have a frame for the view, which will be (0,0,screen width, screen height)
        // This is a good size for the table view as well, so let's use that
        // The only adjust we'll make is to move it down by 20 pixels, and reduce the size by 20 pixels
        // in order to account for the status bar
        
        
        // Adjust it down by 20 points
        //viewFrame.origin.y += 20
        
        
        slideInFromRightTransition.delegate = self
        // Customize the animation's properties
        slideInFromRightTransition.type = kCATransitionReveal
        slideInFromRightTransition.subtype = kCATransitionFromRight
        slideInFromRightTransition.duration = 0.25
        slideInFromRightTransition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        slideInFromRightTransition.fillMode = kCAFillModeRemoved
        
        
        slideInFromLeftTransition.delegate = self
        // Customize the animation's properties
        slideInFromLeftTransition.type = kCATransitionMoveIn
        slideInFromLeftTransition.subtype = kCATransitionFromLeft
        slideInFromLeftTransition.duration = 0.25
        slideInFromLeftTransition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        slideInFromLeftTransition.fillMode = kCAFillModeForwards
        
        
        let cSelector : Selector = "nextCard:"
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: cSelector)
        leftSwipe.direction = UISwipeGestureRecognizerDirection.Left
        view.addGestureRecognizer(leftSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: "lastCard:")
        rightSwipe.direction = UISwipeGestureRecognizerDirection.Right
        view.addGestureRecognizer(rightSwipe)
        
        
        cardWidth = UIScreen.mainScreen().bounds.size.width * 0.35
        let withToHeightCardRatio:CGFloat = 314 / 226
        let rect = CGRectMake(0, 0, cardWidth, cardWidth * withToHeightCardRatio)
        cardView = UIView(frame: rect)
        cardView.layer.cornerRadius = 5
        cardView.layer.masksToBounds = true
        cardView.backgroundColor = UIColor.lightGrayColor()
        cardView.center = CGPoint(x: UIScreen.mainScreen().bounds.size.width/2, y: (UIScreen.mainScreen().bounds.size.height * 0.5))
        
        
        cardHeigh = rect.height

        
        fetchRelations()
        
        let imageName:String = cards[currentCard].front + ".png"
        if let imagefront = UIImage(named: imageName)
        {
            front = UIImageView(image: imageResize(imagefront,sizeChange: CGSizeMake(cardWidth,cardHeigh)))
            front.layer.cornerRadius = 5
            front.layer.masksToBounds = true
        }
        else
        {
            print("Could not find the image \(imageName)")
            let imagefront = UIImage(named: "girl.jpg")
            front = UIImageView(image: imageResize(imagefront!,sizeChange: CGSizeMake(cardWidth,cardHeigh)))
            front.layer.cornerRadius = 10
            front.layer.masksToBounds = true
        }
        
        let imageBack = UIImage(named: "back.png")
        back = UIImageView(image: imageResize(imageBack!,sizeChange: CGSizeMake(cardWidth,cardHeigh)))
        back.layer.cornerRadius = 5
        back.layer.masksToBounds = true
        
        //self.view.addSubview(front)
        
        cardView.addSubview(front)
        view.addSubview(cardView)
        
        
        let margin:CGFloat = UIScreen.mainScreen().bounds.size.width * 0.15
        let buttonWidth:CGFloat = (UIScreen.mainScreen().bounds.size.width - (margin * 3)) / 2
        let buttonHeight = buttonWidth * 0.35
        reShuffleButton = UIButton(frame:CGRectMake(margin, cardView.frame.maxY + (margin * 2), buttonWidth, buttonHeight))
        reShuffleButton.addTarget(self, action: "reshuffleAction:", forControlEvents: UIControlEvents.TouchUpInside)
        reShuffleButton.setTitle("Reshuffle", forState: UIControlState.Normal)
        reShuffleButton.backgroundColor = UIColor.blueColor()
        reShuffleButton.layer.cornerRadius = 5
        reShuffleButton.layer.masksToBounds = true
        reShuffleButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.view.addSubview(reShuffleButton)
        
        startButton = UIButton(frame:CGRectMake(reShuffleButton.frame.maxX + margin, cardView.frame.maxY + (margin * 2), buttonWidth, buttonHeight))
        startButton.addTarget(self, action: "startAction", forControlEvents: UIControlEvents.TouchUpInside)
        startButton.setTitle("Start", forState: UIControlState.Normal)
        startButton.backgroundColor = UIColor.blueColor()
        startButton.layer.cornerRadius = 5
        startButton.layer.masksToBounds = true
        startButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.view.addSubview(startButton)
        startButton.enabled = false
        startButton.alpha = 0.5
        self.startButton.transform = CGAffineTransformScale(self.startButton.transform, 0.3, 0.3)
        
        if let banner = self.bannerView
        {
            if reShuffleButton.frame.maxY > banner.frame.minY
            {
                let offsetY = (reShuffleButton.frame.maxY - banner.frame.minY) + 10
                reShuffleButton.frame.offsetInPlace(dx: 0, dy: offsetY * -1)
                startButton.frame.offsetInPlace(dx: 0, dy: offsetY * -1)
            }
        }

    }
    
    var infoMessage:UILabel!
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        infoMessage = UILabel(frame: CGRectMake(100, (UIScreen.mainScreen().bounds.size.height / 2) - 50, UIScreen.mainScreen().bounds.size.width - 200, 100))
        infoMessage.layer.borderColor = UIColor.blackColor().CGColor
        infoMessage.layer.borderWidth = 1
        infoMessage.layer.cornerRadius = 5
        infoMessage.layer.masksToBounds = true
        infoMessage.backgroundColor = UIColor.whiteColor()
        infoMessage.textAlignment = NSTextAlignment.Center
        infoMessage.text = "Select number of\ncards to remember"
        infoMessage.numberOfLines = 2
        infoMessage.adjustsFontSizeToFitWidth = true
        infoMessage.alpha = 0
        self.view.addSubview(infoMessage)
        
        UIView.animateWithDuration(1, animations: { () -> Void in
                self.infoMessage.alpha = 1
            }, completion: { (value: Bool) in
                UIView.animateWithDuration(1, animations: { () -> Void in
                    self.infoMessage.center = CGPointMake(UIScreen.mainScreen().bounds.size.width - (self.infoMessage.frame.width / 2),self.numberOfCardsPicker.frame.minY + (self.infoMessage.frame.height / 2))
                    self.infoMessage.transform = CGAffineTransformScale(self.infoMessage.transform, 0.65, 0.65)
                    //infoMessage.alpha = 0
                    }, completion: { (value: Bool) in
                        //infoMessage.removeFromSuperview()
                        let pulseAnimation:CABasicAnimation = CABasicAnimation(keyPath: "opacity");
                        pulseAnimation.duration = 0.3
                        pulseAnimation.toValue = NSNumber(float: 0.3)
                        pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                        pulseAnimation.autoreverses = true;
                        pulseAnimation.repeatCount = 3
                        pulseAnimation.delegate = self
                        self.numberOfCardsPicker.layer.addAnimation(pulseAnimation, forKey: "numberOfCardsPickerPulse")
                        
                })
                
        })
        
        //reShuffleButton.frame = CGRectMake(0, 0, (UIScreen.mainScreen().bounds.size.width/2), buttonHeight)
        //startButton.frame = CGRectMake(0, 0, (UIScreen.mainScreen().bounds.size.width/2), buttonHeight)
        numberOfCardsPicker.center = CGPoint(x:  (UIScreen.mainScreen().bounds.size.width/2), y:
            self.navigationController!.navigationBar.frame.maxY + (numberOfCardsPicker.frame.height / 2))
        
        cardView.center = CGPointMake((UIScreen.mainScreen().bounds.size.width/2), numberOfCardsPicker.frame.maxY + (cardView.frame.height / 2))
        
        bannerView?.frame = CGRectZero
        bannerView!.center = CGPoint(x: bannerView!.center.x, y: self.view.bounds.size.height - bannerView!.frame.size.height / 2)
    }
    
    func reshuffleAction(sender: UIButton) {
        
        
        let numberPrompt = UIAlertController(title: "Reshuffle",
            message: "Sure you want to reshuffle",
            preferredStyle: .Alert)
        
        
        numberPrompt.addAction(UIAlertAction(title: "Ok",
            style: .Default,
            handler: { (action) -> Void in
                
                let ordCardFrame = self.cardView.frame
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                        self.cardView.transform = CGAffineTransformScale(self.cardView.transform, 0.1, 0.1)
                        for item in self.dummyCards
                        {
                            item.transform = CGAffineTransformScale(item.transform, 0.1, 0.1)
                        }
                    }, completion: { (value: Bool) in
                        self.resetCardStack()
                        if(self.backUp)
                        {
                            UIView.transitionFromView(self.back, toView: self.front, duration: 0, options: [], completion: nil)
                        }
                        
                        
                        for item in self.dummyCards
                        {
                            item.removeFromSuperview()
                        }
                        self.dummyCards = []
                        let maxNumberOfDummyCardsVisible = (self.currentNumberOfCards - 1) > 20 ? 20 : (self.currentNumberOfCards - 1)
                        for var i = maxNumberOfDummyCardsVisible ; i > 0 ; i--
                        {
                            let alpha:CGFloat = CGFloat(1.0) - (CGFloat(i) / CGFloat(21))
                            
                            if alpha <= 0
                            {
                                break
                            }
                            
                            let dummyCard = UIView(frame: ordCardFrame)
                            dummyCard.backgroundColor = UIColor.whiteColor()
                            dummyCard.layer.cornerRadius = 5
                            dummyCard.layer.masksToBounds = true
                            dummyCard.layer.borderColor = UIColor.blackColor().CGColor
                            dummyCard.layer.borderWidth = 1
                            
                            dummyCard.alpha = alpha
                            dummyCard.frame.offsetInPlace(dx: CGFloat((i * 3) + 1), dy: CGFloat((i * 2) + 1))
                            dummyCard.transform = CGAffineTransformScale(dummyCard.transform, 0.1, 0.1)
                            self.dummyCards.append(dummyCard)
                            self.view.addSubview(dummyCard)
                            
                        }
                        self.view.bringSubviewToFront(self.cardView)

                
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            self.cardView.transform = CGAffineTransformIdentity
                            for item in self.dummyCards
                            {
                                item.transform = CGAffineTransformIdentity
                            }
                            }, completion: { (value: Bool) in
       
                                
                        })
                })
                
                

                
        }))
        numberPrompt.addAction(UIAlertAction(title: "Cancel",
            style: .Default,
            handler: { (action) -> Void in
                
        }))
        
        
        self.presentViewController(numberPrompt,
            animated: true,
            completion: nil)
        

    }
    
    func startAction()
    {
        self.performSegueWithIdentifier("SequeFromMemorizeToTest", sender: nil)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    var pickerTimer:NSTimer?
    func pickerView(pickerView: UIPickerView,
        didSelectRow row: Int,
        inComponent component: Int)
    {
      /*
        if let timer = pickerTimer
        {
            timer.invalidate()
        }

        pickerTimer = NSTimer.scheduledTimerWithTimeInterval(2, target: self,
            selector: "pickerViewAtStill",
            userInfo: row, repeats: false)
        */
        


        let adFree = NSUserDefaults.standardUserDefaults().boolForKey("adFree")
        if row > 20 && !adFree
        {
            
            let numberPrompt = UIAlertController(title: "Locked😓",
                message: "Unlock from mainmenu\nSorry for the inconvenience",
                preferredStyle: .Alert)
            
            
            numberPrompt.addAction(UIAlertAction(title: "Ok",
                style: .Default,
                handler: { (action) -> Void in
                }))
        
            self.presentViewController(numberPrompt,
                animated: true,
                completion: nil)
            
            return
        }
        
        
        for item in self.dummyCards
        {
            item.removeFromSuperview()
        }
        self.dummyCards = []
        let orgCardViewFrame = self.cardView.frame

        UIView.animateWithDuration(0.3, animations: { () -> Void in
        
            self.cardView.transform = CGAffineTransformScale(self.cardView.transform, 0.1, 0.1)

            }, completion: { (value: Bool) in

                self.newNumberOfCardsAction(row)

                let maxNumberOfDummyCardsVisible = (self.currentNumberOfCards - 1) > 20 ? 20 : (self.currentNumberOfCards - 1)
                for var i = maxNumberOfDummyCardsVisible ; i > 0 ; i--
                {
                    let alpha:CGFloat = CGFloat(1.0) - (CGFloat(i) / CGFloat(21))
                    if alpha <= 0
                    {
                        break
                    }
                    let dummyCard = UIView(frame: orgCardViewFrame)
                    dummyCard.backgroundColor = UIColor.whiteColor()
                    dummyCard.layer.cornerRadius = 5
                    dummyCard.layer.masksToBounds = true
                    dummyCard.layer.borderColor = UIColor.blackColor().CGColor
                    dummyCard.layer.borderWidth = 1
                    dummyCard.alpha = alpha
                    dummyCard.frame.offsetInPlace(dx: CGFloat((i * 3) + 1), dy: CGFloat((i * 2) + 1))
                    dummyCard.transform = CGAffineTransformScale(self.cardView.transform, 0.1, 0.1)
                    self.dummyCards.append(dummyCard)
                    self.view.addSubview(dummyCard)
                }
                self.view.bringSubviewToFront(self.cardView)
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    
                    self.cardView.transform = CGAffineTransformIdentity
                    for item in self.dummyCards
                    {
                        item.transform = CGAffineTransformIdentity
                    }
                    }, completion: { (value: Bool) in
                        
                        if self.infoMessage != nil
                        {
                            self.infoMessage.removeFromSuperview()
                            self.infoMessage = nil
                            
                            /*
                            self.view.bringSubviewToFront(self.infoMessage)
                            self.infoMessage.frame = CGRectMake(0, (UIScreen.mainScreen().bounds.size.height / 2) - 100, UIScreen.mainScreen().bounds.size.width , 200)
                            self.infoMessage.alpha = 0
                            self.infoMessage.layer.borderWidth = 0
                            self.infoMessage.backgroundColor = UIColor.clearColor()
                            self.infoMessage.text = "👇\nSwipe to reveal cards"
                            self.infoMessage.numberOfLines = 2
                            self.infoMessage.adjustsFontSizeToFitWidth = true
                            self.infoMessage.center = self.cardView.center
                            
                            UIView.animateWithDuration(1, animations: { () -> Void in
                                self.infoMessage.alpha = 1
                                }, completion: { (value: Bool) in
                                    UIView.animateWithDuration(1, animations: { () -> Void in
                                    self.infoMessage.frame.offset(dx: (UIScreen.mainScreen().bounds.width / 2) * -1, dy: 0)
                                    //infoMessage.alpha = 0
                                    }, completion: { (value: Bool) in
                                        self.infoMessage.removeFromSuperview()
                                        self.infoMessage = nil
                            
                                    })
                            
                            })*/
                        }
                        
                })
        })
        
        

    }
    
    func newNumberOfCardsAction(row:Int)
    {
        if(self.backUp)
        {
            UIView.transitionFromView(self.back, toView: self.front, duration: 0, options: [], completion: nil)
        }
        
        if(numbersOfCardsArray[row].utf16.count > 2)
        {
            let indexEnd: String.Index = numbersOfCardsArray[row].startIndex.advancedBy(numbersOfCardsArray[row].utf16.count - 1)
            let power = numbersOfCardsArray[row].substringFromIndex(indexEnd)
            
            currentNumberOfCards = Int(power)! * 52
        }
        else
        {
            currentNumberOfCards = Int(numbersOfCardsArray[row])!
        }
        fetchRelations()
        resetCardStack()
    }
    
    
    func pickerViewAtStill()
    {

        //var row = pickerTimer?.userInfo as! Int
        //pickerTimer?.invalidate()


    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return numbersOfCardsArray.count
    }
    
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String
    {

        //resetCardStack()

        return numbersOfCardsArray[row]
    }


    
    func resetCardStack()
    {
        cards = shuffle(cards)
        currentCard = 0
        setCardFront()
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.startButton.transform = CGAffineTransformScale(self.startButton.transform, 0.1, 0.1)
            
            }, completion: { (value: Bool) in
                self.startButton.enabled = false
                self.startButton.alpha = 0
            })
        
    }
    

    
    func setCardFront()
    {
        let imageName:String = cards[currentCard].front + ".png"
        if let imagefront = UIImage(named: imageName)
        {
            front.image = imageResize(imagefront,sizeChange: CGSizeMake(cardWidth,cardHeigh))
        }
        else
        {
            print("Could not find the image \(imageName)")
            let imagefront = UIImage(named: "girl.jpg")
            front.image = imageResize(imagefront!,sizeChange: CGSizeMake(cardWidth,cardHeigh))
        }
    }
    
    
    
    func fetchRelations() {
        
        let fetchRequest = NSFetchRequest(entityName: "CardRelation")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        cards = []
        if let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [CardRelation] {
            
            for(var i = 0; i < fetchResults.count ; i++)
            {
                cards.append(Card(front: fetchResults[i].name, back:""))
            }
            //must shuffle twice as appending cards to the tempcard list must be randomized
            cards = shuffle(cards)
            
            var tempCards :Array<Card> = Array<Card>()
            for(var i = 0; i < currentNumberOfCards ; i++)
            {
                let index = i % cards.count
                tempCards.append(cards[index])
            }
            cards = shuffle(tempCards)

        }
    }
    
    func shuffle<C: MutableCollectionType where C.Index == Int>(var list: C) -> C {
        let ecount = list.count
        for i in 0..<(ecount - 1) {
            let j = Int(arc4random_uniform(UInt32(ecount - i))) + i
            if j != i {
                swap(&list[i], &list[j])
            }
        }
        return list
    }
    
    
    func imageResize (imageObj:UIImage, sizeChange:CGSize)-> UIImage{
        
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        imageObj.drawInRect(CGRect(origin: CGPointZero, size: sizeChange))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage
    }
    
    var backUp = false
    @IBAction func nextCard(sender: AnyObject) {

        /*
        if(backUp)
        {
            UIView.transitionFromView(front, toView: back, duration: 1, options: UIViewAnimationOptions.TransitionFlipFromRight, completion: nil)
            backUp = false
            return
        }*/
        self.currentCard++
        
        if(self.currentCard >= currentNumberOfCards)
        {
            UIView.transitionFromView(front, toView: back, duration: 0.7, options: UIViewAnimationOptions.TransitionFlipFromRight, completion: { (value: Bool) in
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.startButton.alpha = 1.0
                    self.startButton.transform = CGAffineTransformIdentity
                    
                    }, completion: { (value: Bool) in
                        
                        self.backUp = true
                        self.startButton.enabled = true
                        
                        
                        let pulseAnimation:CABasicAnimation = CABasicAnimation(keyPath: "opacity");
                        pulseAnimation.duration = 0.3
                        pulseAnimation.toValue = NSNumber(float: 0.3)
                        pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                        pulseAnimation.autoreverses = true;
                        pulseAnimation.repeatCount = 3
                        pulseAnimation.delegate = self
                        self.startButton.layer.addAnimation(pulseAnimation, forKey: "asd")
                        
                        
                        self.currentCard = self.currentNumberOfCards
                })
            })
        }
        else
        {
            for item in dummyCards
            {
                item.removeFromSuperview()
            }
            self.dummyCards = []
            let maxNumberOfDummyCardsVisible = ((currentNumberOfCards - 1) - currentCard) > 20 ? 20 : ((currentNumberOfCards - 1) - currentCard)
            for var i = maxNumberOfDummyCardsVisible ; i > 0 ; i--
            {
                let alpha:CGFloat = CGFloat(1.0) - (CGFloat(i) / CGFloat(21))
                if alpha <= 0
                {
                    break
                }
                let dummyCard = UIView(frame: cardView.frame)
                dummyCard.backgroundColor = UIColor.whiteColor()
                dummyCard.layer.cornerRadius = 5
                dummyCard.layer.masksToBounds = true
                dummyCard.layer.borderColor = UIColor.blackColor().CGColor
                dummyCard.layer.borderWidth = 1
                
                dummyCard.alpha = alpha
                dummyCard.frame.offsetInPlace(dx: CGFloat((i * 3) + 1), dy: CGFloat((i * 2) + 1))
                dummyCards.append(dummyCard)
                self.view.addSubview(dummyCard)
            }
            self.view.bringSubviewToFront(cardView)
            
            //self.currentCard = self.currentCard % cards.count
            self.cardView.layer.addAnimation(slideInFromRightTransition, forKey: "slideInFromRightTransition")
            setCardFront()
        }
    }
    
    @IBAction func lastCard(sender: AnyObject) {
        // Add the animation to the View's layer
        if(self.currentCard == 0)
        {
            return
        }
        
        self.currentCard--
        if(backUp)
        {
            UIView.transitionFromView(back, toView: front, duration: 0.7, options: UIViewAnimationOptions.TransitionFlipFromLeft, completion: nil)
            backUp = false
            return
            
        }
        else
        {
            self.currentCard = self.currentCard < 0 ? 0 : self.currentCard
            
            for item in dummyCards
            {
                item.removeFromSuperview()
            }
            self.dummyCards = []
            let maxNumberOfDummyCardsVisible = ((currentNumberOfCards - 1) - currentCard) > 20 ? 20 : ((currentNumberOfCards - 1) - currentCard)
            for var i = maxNumberOfDummyCardsVisible ; i > 0 ; i--
            {
                let alpha:CGFloat = CGFloat(1.0) - (CGFloat(i) / CGFloat(21))
                if alpha <= 0
                {
                    break
                }
                let dummyCard = UIView(frame: cardView.frame)
                dummyCard.backgroundColor = UIColor.whiteColor()
                dummyCard.layer.cornerRadius = 5
                dummyCard.layer.masksToBounds = true
                dummyCard.layer.borderColor = UIColor.blackColor().CGColor
                dummyCard.layer.borderWidth = 1
                
                dummyCard.alpha = alpha
                dummyCard.frame.offsetInPlace(dx: CGFloat((i * 3) + 1), dy: CGFloat((i * 2) + 1))
                dummyCards.append(dummyCard)
                self.view.addSubview(dummyCard)
            }
            self.view.bringSubviewToFront(cardView)

            self.cardView.layer.addAnimation(slideInFromLeftTransition, forKey: "slideInFromLeftTransition")
            setCardFront()
        }
    }
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {
        if (segue.identifier == "SequeFromMemorizeToTest") {
            let svc = segue!.destinationViewController as! TestMemoryViewController;
            
            svc.cardsToMemorize = cards
            
        }
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
